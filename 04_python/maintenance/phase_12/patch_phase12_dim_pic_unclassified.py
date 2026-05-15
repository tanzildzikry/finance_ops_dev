from pathlib import Path

SQL_PATH = Path("01_database/sql/phase_12_reporting_views.sql")

if not SQL_PATH.exists():
    raise FileNotFoundError(f"Missing file: {SQL_PATH}")

text = SQL_PATH.read_text(encoding="utf-8")

start_marker = "CREATE OR REPLACE VIEW reporting.dim_pic AS\n"
comment_marker = "COMMENT ON VIEW reporting.dim_pic IS"

if start_marker not in text:
    raise RuntimeError("BLOCKED: reporting.dim_pic view block was not found.")

start_idx = text.index(start_marker)

if comment_marker not in text[start_idx:]:
    raise RuntimeError("BLOCKED: COMMENT ON VIEW reporting.dim_pic marker was not found after dim_pic block.")

comment_idx = text.index(comment_marker, start_idx)

# Keep the COMMENT block intact; replace only CREATE OR REPLACE VIEW reporting.dim_pic AS ... before COMMENT.
new_dim_pic_block = """CREATE OR REPLACE VIEW reporting.dim_pic AS
WITH base_pic AS (
    SELECT DISTINCT
        TRIM(pic_code) AS pic_code,
        NULLIF(TRIM(pic_full_name), '') AS pic_full_name,
        NULLIF(TRIM(division_code), '') AS division_code,
        NULLIF(TRIM(pic_status), '') AS pic_status
    FROM clean.clean_pic_list
    WHERE pic_code IS NOT NULL
      AND TRIM(pic_code) <> ''
),
pic_with_unclassified AS (
    SELECT
        pic_code,
        pic_full_name,
        division_code,
        pic_status
    FROM base_pic

    UNION ALL

    SELECT
        'UNCLASSIFIED' AS pic_code,
        'UNCLASSIFIED - PIC not input in ERP' AS pic_full_name,
        'UNCLASSIFIED' AS division_code,
        'ACTIVE' AS pic_status
    WHERE NOT EXISTS (
        SELECT 1
        FROM base_pic
        WHERE pic_code = 'UNCLASSIFIED'
    )
)
SELECT
    pic_code,
    pic_full_name,
    division_code,
    pic_status,
    CASE
        WHEN pic_code = 'UNCLASSIFIED' THEN TRUE
        ELSE FALSE
    END AS is_unclassified_pic
FROM pic_with_unclassified;

"""

new_text = text[:start_idx] + new_dim_pic_block + text[comment_idx:]

if "UNCLASSIFIED - PIC not input in ERP" not in new_text:
    raise RuntimeError("BLOCKED: patched dim_pic block does not contain UNCLASSIFIED synthetic row.")

if len(new_text.splitlines()) < len(text.splitlines()) - 50:
    raise RuntimeError("BLOCKED: patch removed too many lines unexpectedly.")

SQL_PATH.write_text(new_text.rstrip() + "\n", encoding="utf-8")

print("PASS: phase_12_reporting_views.sql dim_pic block patched.")
print("Updated:", SQL_PATH)
print()
print("Next commands:")
print("  git diff -- 01_database/sql/phase_12_reporting_views.sql")
print("  git add 01_database/sql/phase_12_reporting_views.sql patch_phase12_dim_pic_unclassified.py")
print('  git commit -m "fix: add unclassified row to phase 12 dim pic view"')
print("  git push origin main")
