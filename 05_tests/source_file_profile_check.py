# =============================================================================
# Finance_Ops_Dev - Masked Source File Profile Check
# File: 05_tests/source_file_profile_check.py
#
# Purpose:
# - Validate required masked source files exist
# - Profile CSV delimiter, header count, row count, and column names
# - Generate documentation result in 00_docs/masked_source_profile_result.md
#
# Safety:
# - This script does not print data rows.
# - This script only documents file metadata and headers.
# - Real data must not be stored in this repository.
# =============================================================================

from pathlib import Path
import csv
from datetime import datetime


PROJECT_ROOT = Path.cwd()
OUTPUT_FILE = PROJECT_ROOT / "00_docs" / "masked_source_profile_result.md"

SOURCE_FILES = [
    {
        "file_id": "SRC-001",
        "file_name": "masked_bc_source_sample.csv",
        "relative_path": "03_sample_data_masked/masked_bc_source_sample.csv",
        "purpose": "Main BC source sample",
        "target_raw_table": "raw.raw_bc_source",
        "target_clean_table": "clean.clean_bc",
    },
    {
        "file_id": "SRC-002",
        "file_name": "masked_pic_list_sample.csv",
        "relative_path": "03_sample_data_masked/masked_pic_list_sample.csv",
        "purpose": "PIC list sample",
        "target_raw_table": "raw.raw_pic_list",
        "target_clean_table": "clean.clean_pic_list",
    },
]


def detect_delimiter(header_line: str) -> str:
    comma_count = header_line.count(",")
    semicolon_count = header_line.count(";")
    tab_count = header_line.count("\t")

    if comma_count >= semicolon_count and comma_count >= tab_count:
        return ","

    if semicolon_count >= comma_count and semicolon_count >= tab_count:
        return ";"

    return "\t"


def delimiter_name(delimiter: str) -> str:
    if delimiter == ",":
        return "Comma"
    if delimiter == ";":
        return "Semicolon"
    if delimiter == "\t":
        return "Tab"
    return "Unknown"


def profile_csv(file_info: dict) -> dict:
    file_path = PROJECT_ROOT / file_info["relative_path"]

    result = {
        "file_id": file_info["file_id"],
        "file_name": file_info["file_name"],
        "relative_path": file_info["relative_path"],
        "purpose": file_info["purpose"],
        "target_raw_table": file_info["target_raw_table"],
        "target_clean_table": file_info["target_clean_table"],
        "file_exists": False,
        "file_size_bytes": 0,
        "detected_delimiter": "",
        "detected_delimiter_name": "",
        "header_count": 0,
        "row_count": 0,
        "duplicate_header_count": 0,
        "duplicate_headers": [],
        "headers": [],
        "validation_result": "BLOCKED",
        "risk_level": "HIGH",
        "notes": "",
    }

    if not file_path.exists():
        result["notes"] = "File not found."
        return result

    result["file_exists"] = True
    result["file_size_bytes"] = file_path.stat().st_size

    with file_path.open("r", encoding="utf-8-sig", newline="") as file:
        first_line = file.readline()

    if not first_line.strip():
        result["validation_result"] = "NEEDS REVISION"
        result["risk_level"] = "HIGH"
        result["notes"] = "Header line is empty."
        return result

    delimiter = detect_delimiter(first_line)
    result["detected_delimiter"] = delimiter
    result["detected_delimiter_name"] = delimiter_name(delimiter)

    with file_path.open("r", encoding="utf-8-sig", newline="") as file:
        reader = csv.reader(file, delimiter=delimiter)
        rows = list(reader)

    if not rows:
        result["validation_result"] = "NEEDS REVISION"
        result["risk_level"] = "HIGH"
        result["notes"] = "No rows detected."
        return result

    headers = [header.strip().strip('"') for header in rows[0]]
    data_rows = rows[1:]

    result["headers"] = headers
    result["header_count"] = len(headers)
    result["row_count"] = len(data_rows)

    seen_headers = {}
    duplicate_headers = []

    for header in headers:
        seen_headers[header] = seen_headers.get(header, 0) + 1

    for header, count in seen_headers.items():
        if count > 1:
            duplicate_headers.append(header)

    result["duplicate_headers"] = duplicate_headers
    result["duplicate_header_count"] = len(duplicate_headers)

    if result["header_count"] == 0:
        result["validation_result"] = "NEEDS REVISION"
        result["risk_level"] = "HIGH"
        result["notes"] = "No headers detected."
    elif result["duplicate_header_count"] > 0:
        result["validation_result"] = "NEEDS REVISION"
        result["risk_level"] = "HIGH"
        result["notes"] = "Duplicate headers detected."
    elif result["row_count"] == 0:
        result["validation_result"] = "NEEDS REVIEW"
        result["risk_level"] = "MEDIUM"
        result["notes"] = "Headers detected, but no data rows found."
    else:
        result["validation_result"] = "PASS"
        result["risk_level"] = "LOW"
        result["notes"] = "File exists, headers detected, row count available, and no duplicate headers found."

    return result


def write_markdown(profiles: list[dict]) -> None:
    generated_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    all_pass = all(profile["validation_result"] == "PASS" for profile in profiles)

    final_validation_result = "PASS" if all_pass else "NEEDS REVIEW"
    final_risk_level = "LOW" if all_pass else "MEDIUM"

    lines = []

    lines.append("# Masked Source Profile Result - Finance Ops Dev")
    lines.append("")
    lines.append("## Purpose")
    lines.append("")
    lines.append("This document records the profiling result for masked source files used in the Finance_Ops_Dev project.")
    lines.append("")
    lines.append("This profile checks:")
    lines.append("")
    lines.append("- File existence")
    lines.append("- File size")
    lines.append("- Detected delimiter")
    lines.append("- Header count")
    lines.append("- Row count")
    lines.append("- Duplicate header risk")
    lines.append("- Header list")
    lines.append("")
    lines.append("This document does not include data rows.")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Generated Info")
    lines.append("")
    lines.append("Generated at:")
    lines.append("")
    lines.append("```text")
    lines.append(generated_at)
    lines.append("```")
    lines.append("")
    lines.append("Generated by:")
    lines.append("")
    lines.append("```text")
    lines.append("05_tests/source_file_profile_check.py")
    lines.append("```")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Final Validation Result")
    lines.append("")
    lines.append("Validation result:")
    lines.append("")
    lines.append("```text")
    lines.append(final_validation_result)
    lines.append("```")
    lines.append("")
    lines.append("Risk level:")
    lines.append("")
    lines.append("```text")
    lines.append(final_risk_level)
    lines.append("```")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Source File Summary")
    lines.append("")
    lines.append("| File ID | File Name | Exists | Row Count | Header Count | Duplicate Header Count | Validation Result | Risk Level |")
    lines.append("|---|---|---:|---:|---:|---:|---|---|")

    for profile in profiles:
        lines.append(
            "| {file_id} | `{file_name}` | {file_exists} | {row_count} | {header_count} | {duplicate_header_count} | {validation_result} | {risk_level} |".format(
                file_id=profile["file_id"],
                file_name=profile["file_name"],
                file_exists=profile["file_exists"],
                row_count=profile["row_count"],
                header_count=profile["header_count"],
                duplicate_header_count=profile["duplicate_header_count"],
                validation_result=profile["validation_result"],
                risk_level=profile["risk_level"],
            )
        )

    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Detailed File Profiles")
    lines.append("")

    for profile in profiles:
        lines.append("### {file_id} - {file_name}".format(
            file_id=profile["file_id"],
            file_name=profile["file_name"],
        ))
        lines.append("")
        lines.append("| Item | Value |")
        lines.append("|---|---|")
        lines.append("| File name | `{}` |".format(profile["file_name"]))
        lines.append("| Relative path | `{}` |".format(profile["relative_path"]))
        lines.append("| Purpose | {} |".format(profile["purpose"]))
        lines.append("| Target raw table | `{}` |".format(profile["target_raw_table"]))
        lines.append("| Target clean table | `{}` |".format(profile["target_clean_table"]))
        lines.append("| File exists | {} |".format(profile["file_exists"]))
        lines.append("| File size bytes | {} |".format(profile["file_size_bytes"]))
        lines.append("| Detected delimiter | {} |".format(profile["detected_delimiter_name"]))
        lines.append("| Header count | {} |".format(profile["header_count"]))
        lines.append("| Row count | {} |".format(profile["row_count"]))
        lines.append("| Duplicate header count | {} |".format(profile["duplicate_header_count"]))
        lines.append("| Validation result | {} |".format(profile["validation_result"]))
        lines.append("| Risk level | {} |".format(profile["risk_level"]))
        lines.append("| Notes | {} |".format(profile["notes"]))
        lines.append("")
        lines.append("#### Headers")
        lines.append("")

        if profile["headers"]:
            for header in profile["headers"]:
                lines.append("- `{}`".format(header))
        else:
            lines.append("No headers detected.")

        lines.append("")

        if profile["duplicate_headers"]:
            lines.append("#### Duplicate Headers")
            lines.append("")
            for duplicate_header in profile["duplicate_headers"]:
                lines.append("- `{}`".format(duplicate_header))
            lines.append("")

    lines.append("---")
    lines.append("")
    lines.append("## Control Notes")
    lines.append("")
    lines.append("- Files must remain under `03_sample_data_masked/`.")
    lines.append("- Files must keep the `masked_` prefix.")
    lines.append("- Real source files must not be committed.")
    lines.append("- `.env` files must not be committed.")
    lines.append("- PBIX files with embedded real data must not be committed.")
    lines.append("- Database dumps must not be committed.")
    lines.append("- Amount fields are currently accepted by the user as safe, but must be reviewed again if the repository is shared externally or made public.")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## Next Action")
    lines.append("")
    lines.append("If this profile result is PASS:")
    lines.append("")
    lines.append("```text")
    lines.append("Proceed to Phase 5 - Raw Layer Build")
    lines.append("```")
    lines.append("")
    lines.append("If this profile result is NEEDS REVIEW or NEEDS REVISION:")
    lines.append("")
    lines.append("```text")
    lines.append("Fix source files or confirm exceptions before creating raw table DDL")
    lines.append("```")
    lines.append("")

    OUTPUT_FILE.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    profiles = [profile_csv(file_info) for file_info in SOURCE_FILES]

    write_markdown(profiles)

    all_pass = all(profile["validation_result"] == "PASS" for profile in profiles)

    final_validation_result = "PASS" if all_pass else "NEEDS REVIEW"
    final_risk_level = "LOW" if all_pass else "MEDIUM"

    print("")
    print("Masked source profile completed.")
    print("Output file:")
    print(str(OUTPUT_FILE))
    print("")
    print("Final validation result: {}".format(final_validation_result))
    print("Risk level: {}".format(final_risk_level))
    print("")

    for profile in profiles:
        print(
            "{file_name}: {validation_result} | Rows: {row_count} | Headers: {header_count}".format(
                file_name=profile["file_name"],
                validation_result=profile["validation_result"],
                row_count=profile["row_count"],
                header_count=profile["header_count"],
            )
        )


if __name__ == "__main__":
    main()