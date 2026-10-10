#!/usr/bin/env python3
"""Validate Phase 1 Era Zero algorithms and extracted completed roots."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


FAMILY_ONSETS = {
    "LIF": "ni",
    "MOV": "gi",
    "MAT": "ba",
    "MIN": "si",
    "CON": "wu",
    "STR": "do",
    "WRN": "da",
    "REP": "ya",
    "LOG": "te",
    "DAT": "li",
    "CRE": "ga",
    "ORI": "nu",
}
FAMILY_INTERVALS = {
    "LIF": [0, 4, 7],
    "MOV": [0, 2, 7],
    "MAT": [0, 7, 12],
    "MIN": [0, 3, 7],
    "CON": [0, 4, 7, 9],
    "STR": [0, 5, 7],
    "WRN": [0, 3, 6],
    "REP": [0, 3, 7, 9],
    "LOG": [0, 4, 8],
    "DAT": [0, 4, 7, 11],
    "CRE": [0, 3, 7, 11],
    "ORI": [0, 1, 7],
}
INITIAL = {"0": "n", "1": "k", "2": "m"}
VOWEL = {"0": "a", "1": "o", "2": "i"}
FINAL = {"0": "m", "1": "k", "2": "n"}
CARRIER = {"0": "ma", "1": "ki", "2": "nu"}
MOVEMENT = {"0": 0, "1": 2, "2": -2}


def compact(address: str) -> str:
    return INITIAL[address[0]] + VOWEL[address[1]] + FINAL[address[2]]


def path(address: str) -> list[int]:
    result = [0]
    current = 0
    for trit in address:
        current += MOVEMENT[trit]
        result.append(current)
    return result


def carrier(address: str) -> str:
    return "-".join(CARRIER[t] for t in address)


def parse_simple_yaml_atoms(path_value: Path) -> list[dict[str, Any]]:
    """Read our YAML 1.2 output by converting its atoms block mechanically.

    The builder always emits JSON-quoted scalar values. Rather than depend on
    PyYAML, validation uses the canonical JSONL-like source of the atom list
    embedded in the generated file with a small purpose-built parser.
    """
    text = path_value.read_text(encoding="utf-8")
    atoms: list[dict[str, Any]] = []
    blocks = re.split(r"(?m)^  - family: ", text)
    for block in blocks[1:]:
        lines = block.splitlines()
        family = json.loads(lines[0].strip())
        record: dict[str, Any] = {"family": family}
        current_list_key: str | None = None
        for line in lines[1:]:
            list_header = re.match(r"^    ([A-Za-z_][A-Za-z0-9_-]*):$", line)
            if list_header:
                current_list_key = list_header.group(1)
                record[current_list_key] = []
                continue
            list_item = re.match(r"^      - (.+)$", line)
            if list_item and current_list_key:
                raw_item = list_item.group(1)
                if raw_item.startswith('"'):
                    value: Any = json.loads(raw_item)
                elif re.fullmatch(r"-?\d+(?:\.\d+)?", raw_item):
                    value = float(raw_item) if "." in raw_item else int(raw_item)
                else:
                    value = raw_item
                record[current_list_key].append(value)
                continue
            match = re.match(r"^    ([A-Za-z_][A-Za-z0-9_-]*): (.+)$", line)
            if not match:
                continue
            current_list_key = None
            key, raw = match.groups()
            if raw.startswith('"'):
                record[key] = json.loads(raw)
            elif raw in {"true", "false"}:
                record[key] = raw == "true"
            elif raw.startswith("[") and raw.endswith("]"):
                record[key] = json.loads(raw)
            elif re.fullmatch(r"-?\d+(?:\.\d+)?", raw):
                record[key] = float(raw) if "." in raw else int(raw)
        atoms.append(record)
    return atoms


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--workspace", type=Path, default=Path.cwd())
    args = parser.parse_args()
    workspace = args.workspace.resolve()
    atoms_path = workspace / "lexicon" / "completed_atoms.yaml"
    atoms = parse_simple_yaml_atoms(atoms_path)

    checks: list[tuple[str, bool, str]] = []

    addresses = [f"{a}{b}{c}" for a in "012" for b in "012" for c in "012"]
    checks.append(("27 universal addresses", len(addresses) == 27, f"count={len(addresses)}"))
    checks.append(("unique universal addresses", len(set(addresses)) == 27, "no duplicates"))

    expected_examples = {
        "000": ("nam", "ma-ma-ma", [0, 0, 0, 0]),
        "012": ("non", "ma-ki-nu", [0, 0, 2, 0]),
        "111": ("kok", "ki-ki-ki", [0, 2, 4, 6]),
        "222": ("min", "nu-nu-nu", [0, -2, -4, -6]),
    }
    for address, (expected_root, expected_carrier, expected_path) in expected_examples.items():
        checks.append(
            (
                f"{address} compact root",
                compact(address) == expected_root,
                f"{compact(address)} == {expected_root}",
            )
        )
        checks.append(
            (
                f"{address} local carrier",
                carrier(address) == expected_carrier,
                f"{carrier(address)} == {expected_carrier}",
            )
        )
        checks.append(
            (
                f"{address} note path",
                path(address) == expected_path,
                f"{path(address)} == {expected_path}",
            )
        )

    generated_roots = {address: compact(address) for address in addresses}
    generated_carriers = {address: carrier(address) for address in addresses}
    generated_paths = {address: path(address) for address in addresses}
    checks.append(
        (
            "all compact roots unique within a family",
            len(set(generated_roots.values())) == 27,
            "27 generated local roots",
        )
    )
    checks.append(
        (
            "all carriers unique within a family",
            len(set(generated_carriers.values())) == 27,
            "27 generated local carriers",
        )
    )
    checks.append(
        (
            "all note paths unique within a family",
            len({tuple(value) for value in generated_paths.values()}) == 27,
            "27 generated paths",
        )
    )

    full_representations = {
        (
            family,
            address,
            FAMILY_ONSETS[family],
            tuple(FAMILY_INTERVALS[family]),
            compact(address),
        )
        for family in FAMILY_ONSETS
        for address in addresses
    }
    checks.append(
        (
            "family-qualified representations unique",
            len(full_representations) == 324,
            f"count={len(full_representations)}",
        )
    )

    checks.append(("36 completed atoms extracted", len(atoms) == 36, f"count={len(atoms)}"))
    ids = [record.get("canonical_id") for record in atoms]
    checks.append(("completed atom IDs unique", len(set(ids)) == len(ids), "no duplicate IDs"))
    lif_count = sum(1 for record in atoms if record.get("family") == "LIF")
    mov_count = sum(1 for record in atoms if record.get("family") == "MOV")
    checks.append(("LIF record count", lif_count == 27, f"count={lif_count}"))
    checks.append(("MOV record count", mov_count == 9, f"count={mov_count}"))

    atom_errors: list[str] = []
    for record in atoms:
        family = record.get("family")
        address = record.get("address")
        if family not in FAMILY_ONSETS or address not in addresses:
            atom_errors.append(f"invalid family/address in {record}")
            continue
        expected_local = compact(address)
        expected_transliteration = f"{FAMILY_ONSETS[family]}·{expected_local}"
        expected_full_carrier = f"{FAMILY_ONSETS[family]}-{carrier(address)}"
        if record.get("local_compact_root") != expected_local:
            atom_errors.append(
                f"{family}:{address} compact={record.get('local_compact_root')} expected={expected_local}"
            )
        if record.get("canonical_transliteration") != expected_transliteration:
            atom_errors.append(
                f"{family}:{address} transliteration={record.get('canonical_transliteration')} "
                f"expected={expected_transliteration}"
            )
        if record.get("formal_carrier") != expected_full_carrier:
            atom_errors.append(
                f"{family}:{address} carrier={record.get('formal_carrier')} "
                f"expected={expected_full_carrier}"
            )
        if record.get("note_path_semitones") != path(address):
            atom_errors.append(
                f"{family}:{address} path={record.get('note_path_semitones')} "
                f"expected={path(address)}"
            )
    checks.append(
        (
            "completed atoms follow latest algorithms",
            not atom_errors,
            "all 36 records valid" if not atom_errors else "; ".join(atom_errors),
        )
    )

    passed = sum(1 for _, ok, _ in checks if ok)
    failed = len(checks) - passed
    report_lines = [
        "# Era Zero Phase 1 Validation Report",
        "",
        f"- Checks: **{len(checks)}**",
        f"- Passed: **{passed}**",
        f"- Failed: **{failed}**",
        "",
        "| Check | Result | Evidence |",
        "|---|---|---|",
    ]
    for name, ok, evidence in checks:
        report_lines.append(
            f"| {name} | {'PASS' if ok else 'FAIL'} | {evidence.replace('|', '\\|')} |"
        )
    report_lines.extend(
        [
            "",
            "## Algorithms proven",
            "",
            "- Addresses enumerate all 27 three-trit combinations exactly once.",
            "- Compact roots use first-trit initial + second-trit vowel + third-trit final.",
            "- Formal carriers use the family onset followed by `ma`, `ki`, or `nu` for each trit.",
            "- Note paths include the start and apply `0`, `+2`, or `-2` semitones per trit.",
            "- Family/address representations remain unique through family code, onset, and harmonic signature.",
            "- Every extracted Life and Motion record matches these latest accepted algorithms.",
        ]
    )
    reports_dir = workspace / "reports"
    reports_dir.mkdir(parents=True, exist_ok=True)
    (reports_dir / "validation_report.md").write_text(
        "\n".join(report_lines) + "\n", encoding="utf-8"
    )
    print(json.dumps({"checks": len(checks), "passed": passed, "failed": failed}, indent=2))
    if failed:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
