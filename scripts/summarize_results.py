#!/usr/bin/env python3
import json
import pathlib
import sys


FIELDS = [
    "input",
    "output",
    "other",
    "match_level",
    "coordinate_level",
    "lat",
    "lon",
    "rsdt_addr_flg",
    "prc_id",
]


def iter_records(payload):
    if isinstance(payload, list):
        return payload
    return [payload]


def normalize_record(record):
    if "query" in record or "result" in record:
        query = record.get("query", {})
        result = record.get("result", {})
        merged = {"input": query.get("input", "")}
        merged.update(result)
        if "others" in merged and "other" not in merged:
            others = merged.pop("others")
            merged["other"] = ", ".join(str(x) for x in others)
        return merged
    return record


def render_row(record):
    record = normalize_record(record)
    values = []
    for field in FIELDS:
        value = record.get(field, "")
        if isinstance(value, (dict, list)):
            value = json.dumps(value, ensure_ascii=False)
        values.append(str(value))
    return " | ".join(values)


def main():
    out_dir = pathlib.Path(sys.argv[1])
    print("| file | row | " + " | ".join(FIELDS) + " |")
    print("| --- | --- | " + " | ".join(["---"] * len(FIELDS)) + " |")
    for path in sorted(out_dir.glob("*.json")):
        payload = json.loads(path.read_text())
        for idx, record in enumerate(iter_records(payload), start=1):
            print(f"| {path.name} | {idx} | {render_row(record)} |")


if __name__ == "__main__":
    main()
