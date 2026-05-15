from pathlib import Path

files = [
    Path("01_database/sql/phase_12_reporting_views.sql"),
    Path("01_database/sql/phase_12_semantic_model_validation.sql"),
    Path("02_powerbi/dax/phase_12_canonical_measures.dax"),
    Path("phase_12_technical_patch_README.md"),
]

for path in files:
    text = path.read_text(encoding="utf-8")
    text = text.replace("—", "-")
    text = text.replace("â€”", "-")
    path.write_text(text, encoding="utf-8")
    print(f"PASS sanitized: {path}")

helper = Path("generate_phase12_technical_patch.py")
if helper.exists():
    helper.unlink()
    print("PASS removed helper generator: generate_phase12_technical_patch.py")
