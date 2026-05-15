from pathlib import Path

path = Path("01_database/sql/phase_12_reporting_views.sql")

text = path.read_text(encoding="utf-8")

# Remove missing source column from reporting.fact_issue_current.
# This column is not available in snapshot.vw_latest_bc_daily_issue_history.
text = text.replace("    issue_keyword_matched,\n", "")

path.write_text(text, encoding="utf-8")

print("PASS: removed missing column issue_keyword_matched from phase_12_reporting_views.sql")
