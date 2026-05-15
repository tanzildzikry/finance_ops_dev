from pathlib import Path

SQL_PATH = Path("01_database/sql/phase_12_reporting_views.sql")

if not SQL_PATH.exists():
    raise FileNotFoundError(f"Missing file: {SQL_PATH}")

text = SQL_PATH.read_text(encoding="utf-8")

old_block_start = "CREATE OR REPLACE VIEW reporting.fact_issue_current AS\nSELECT\n"
old_block_end = "FROM snapshot.vw_latest_bc_daily_issue_history;"

if old_block_start not in text or old_block_end not in text:
    raise RuntimeError("Could not locate reporting.fact_issue_current block. Patch blocked.")

start_idx = text.index(old_block_start)
end_idx = text.index(old_block_end, start_idx) + len(old_block_end)

new_issue_block = """CREATE OR REPLACE VIEW reporting.fact_issue_current AS
SELECT
    snapshot_run_id,
    snapshot_date,
    snapshot_timestamp,
    bc_number,
    pic_internal_code,
    billing_status,
    event_status,
    invoice_completion_bucket,
    bc_closing_status,
    raw_remarks,
    raw_missing_document_notes,
    raw_po_status,
    raw_umk_status,
    issue_source_text,
    detected_issue_category,
    detected_blocker,
    responsibility_type,
    issue_confidence_level,
    classification_method,
    needs_manual_review_flag,
    created_at
FROM snapshot.vw_latest_bc_daily_issue_history;"""

text = text[:start_idx] + new_issue_block + text[end_idx:]

# Defensive cleanup in case the unavailable column appears elsewhere in comments/selects.
text = text.replace("    issue_keyword_matched,\n", "")
text = text.replace("issue_keyword_matched,\n", "")
text = text.replace("issue_keyword_matched", "")

SQL_PATH.write_text(text.rstrip() + "\n", encoding="utf-8")

print("PASS: patched reporting.fact_issue_current to match actual source columns.")
print("Updated:", SQL_PATH)
print("Next:")
print("  git diff -- 01_database/sql/phase_12_reporting_views.sql")
print("  git add 01_database/sql/phase_12_reporting_views.sql patch_phase12_fact_issue_current_schema.py")
print("  git commit -m \"fix: align phase 12 issue reporting view with actual schema\"")
print("  git push origin main")
