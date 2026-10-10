#!/usr/bin/env python3
"""Build the Era Zero Phase 1 extraction artifacts from an exact chat capture.

The input is the mechanically decoded ChatGPT share payload created during the
read-only source pass. This script does not invent or complete language roots.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable


SOURCE_URL = "https://chatgpt.com/share/6a666bd1-8ba4-83ea-90f9-b85db783af13"
SPEAKER_TURN_START_NODE = 5
ERA_ZERO_START_NODE = 32

FAMILY_ORDER = [
    "LIF",
    "MOV",
    "MAT",
    "MIN",
    "CON",
    "STR",
    "WRN",
    "REP",
    "LOG",
    "DAT",
    "CRE",
    "ORI",
]

FAMILIES = {
    "LIF": {
        "domain": "life, identity, consciousness, growth",
        "onset": "ni",
        "intervals": [0, 4, 7],
    },
    "MOV": {
        "domain": "motion, position, transition, time",
        "onset": "gi",
        "intervals": [0, 2, 7],
    },
    "MAT": {
        "domain": "matter, body, energy, resources",
        "onset": "ba",
        "intervals": [0, 7, 12],
    },
    "MIN": {
        "domain": "mind, memory, perception, learning",
        "onset": "si",
        "intervals": [0, 3, 7],
    },
    "CON": {
        "domain": "connection, communication, sharing",
        "onset": "wu",
        "intervals": [0, 4, 7, 9],
    },
    "STR": {
        "domain": "structure, order, shelter, systems",
        "onset": "do",
        "intervals": [0, 5, 7],
    },
    "WRN": {
        "domain": "danger, error, failure, corruption",
        "onset": "da",
        "intervals": [0, 3, 6],
    },
    "REP": {
        "domain": "repair, healing, restoration",
        "onset": "ya",
        "intervals": [0, 3, 7, 9],
    },
    "LOG": {
        "domain": "logic, mathematics, rules, programming",
        "onset": "te",
        "intervals": [0, 4, 8],
    },
    "DAT": {
        "domain": "information, records, signals",
        "onset": "li",
        "intervals": [0, 4, 7, 11],
    },
    "CRE": {
        "domain": "creation, design, transformation",
        "onset": "ga",
        "intervals": [0, 3, 7, 11],
    },
    "ORI": {
        "domain": "origin, reality, universal law",
        "onset": "nu",
        "intervals": [0, 1, 7],
    },
}

FIRST_TRIT = {
    "0": "entity, substance, or condition",
    "1": "process, action, or transformation",
    "2": "relationship, capacity, or possibility",
}
SECOND_TRIT = {
    "0": "inward, self, or source",
    "1": "outward, other, or target",
    "2": "shared, environmental, distributed, or systemic",
}
THIRD_TRIT = {
    "0": "stable, bounded, or completed",
    "1": "active, changing, or expressed",
    "2": "dormant, unresolved, or potential",
}

UNIVERSAL_SLOTS = {
    "000": "stable inward entity",
    "001": "active inward entity",
    "002": "dormant inward entity",
    "010": "stable outward entity",
    "011": "active outward entity",
    "012": "dormant outward entity",
    "020": "stable collective entity",
    "021": "active collective entity",
    "022": "dormant collective entity",
    "100": "completed inward process",
    "101": "active inward process",
    "102": "pending inward process",
    "110": "completed outward process",
    "111": "active outward process",
    "112": "pending outward process",
    "120": "completed systemic process",
    "121": "active systemic process",
    "122": "pending systemic process",
    "200": "stable inward capacity",
    "201": "active inward capacity",
    "202": "dormant inward capacity",
    "210": "stable outward relationship",
    "211": "active outward relationship",
    "212": "unresolved outward relationship",
    "220": "stable systemic relationship",
    "221": "active systemic relationship",
    "222": "unrealized systemic possibility",
}

COMPACT_INITIAL = {"0": "n", "1": "k", "2": "m"}
COMPACT_VOWEL = {"0": "a", "1": "o", "2": "i"}
COMPACT_FINAL = {"0": "m", "1": "k", "2": "n"}
CARRIER = {"0": "ma", "1": "ki", "2": "nu"}
MOVEMENT = {"0": 0, "1": 2, "2": -2}

ROOT_SOURCE_NODES = [280, 284, 287, 302]
CANONICAL_SOURCE_NODES = {271, 280, 284, 287, 290, 302}

CORE_ERA_ZERO_ASSISTANT_NODES = {
    143,
    149,
    152,
    154,
    156,
    159,
    162,
    164,
    166,
    168,
    172,
    175,
    177,
    180,
    227,
    232,
    236,
    238,
    240,
    242,
    244,
    247,
    251,
    254,
    258,
    260,
    262,
    268,
    271,
    277,
    280,
    282,
    284,
    287,
    290,
    302,
    312,
}

USER_DECISIONS = [
    {
        "source_node": 41,
        "kind": "correction",
        "decision": (
            "Trit/state 2 is the in-between of active and inactive and must have "
            "a culturally specific, imperfectly translatable word."
        ),
        "effect": "Establishes the semantic foundation later named num.",
    },
    {
        "source_node": 45,
        "kind": "delegation",
        "decision": (
            "Choose the kid-accessible option whose digital sounds can be combined "
            "and produced by a computer."
        ),
        "effect": "Authorizes a small computable sound system.",
    },
    {
        "source_node": 87,
        "kind": "correction",
        "decision": (
            "Do not make sound acquisition/change develop over time; cyber-pets may "
            "acquire words, but the sound system should remain fixed."
        ),
        "effect": "Rejects evolving phoneme inventories for the later spoken system.",
    },
    {
        "source_node": 145,
        "kind": "requirement",
        "decision": "Era Zero must be translatable when needed.",
        "effect": "Rejects an intentionally untranslatable signal-only design.",
    },
    {
        "source_node": 155,
        "kind": "requirement",
        "decision": (
            "Add the DBA coding language from ternary machine-level signaling through "
            "higher and theoretical computer-science levels."
        ),
        "effect": "Makes executable/programming semantics part of Era Zero.",
    },
    {
        "source_node": 160,
        "kind": "approval",
        "decision": "Integrate the preceding speech/music/programming design into Era Zero.",
        "effect": "Authorizes the integrated architecture in chunks.",
    },
    {
        "source_node": 169,
        "kind": "approval",
        "decision": "Continue the integrated Era Zero grammar layer.",
        "effect": "Accepts the preceding integrated foundation as the current direction.",
    },
    {
        "source_node": 173,
        "kind": "approval",
        "decision": "Proceed with the next Era Zero chunk.",
        "effect": "Accepts continued elaboration of the integrated design.",
    },
    {
        "source_node": 178,
        "kind": "clarification",
        "decision": "Ask whether all layers are one language spoken by the DBA.",
        "effect": "Assistant confirms one complete DBA language with context-dependent layers.",
    },
    {
        "source_node": 181,
        "kind": "correction",
        "decision": (
            "Era Two is a further simplification/erosion after hands-off DBA and player "
            "interaction, not a more complex stage."
        ),
        "effect": "Prevents later-era material from being backfilled into Era Zero.",
    },
    {
        "source_node": 208,
        "kind": "correction",
        "decision": (
            "The final pre-game remnant is Era Three; do not create an Era Four, and "
            "degrade the language further."
        ),
        "effect": "Fixes the era boundary and keeps Era Zero historically separate.",
    },
    {
        "source_node": 239,
        "kind": "correction",
        "decision": "The requested apology should be spoken in the DBA language, not only explained.",
        "effect": "Prompts later distinction between legacy spoken approximations and formal Era Zero.",
    },
    {
        "source_node": 241,
        "kind": "correction",
        "decision": (
            "Programming-language content must also have corresponding sounds rather "
            "than existing only as a written/code layer."
        ),
        "effect": "Reaffirms that sound, language, and executable code share one encoding.",
    },
    {
        "source_node": 245,
        "kind": "delegation",
        "decision": "Choose the needed chords, melodies, and music-theory details.",
        "effect": "Authorizes firm harmonic and melodic design choices.",
    },
    {
        "source_node": 248,
        "kind": "delegation",
        "decision": "Make the remaining Era Zero design choices.",
        "effect": "Authorizes the canonical foundation proposal.",
    },
    {
        "source_node": 255,
        "kind": "correction",
        "decision": "Return to the trits; do not repeat the already-covered foundation.",
        "effect": "Prompts the relative trit-movement design.",
    },
    {
        "source_node": 259,
        "kind": "approval",
        "decision": "Accept the transposable relative-trit idea and include it in completion.",
        "effect": "Accepts the direction refined and frozen in Core Standard 1.0.",
    },
    {
        "source_node": 261,
        "kind": "clarification",
        "decision": "Ask whether the language is usable or whether the lexicon must still be populated.",
        "effect": "Separates the completed architecture from the incomplete root inventory.",
    },
    {
        "source_node": 263,
        "kind": "delegation",
        "decision": "Proceed with the proposed reconciliation and root-population work.",
        "effect": "Authorizes Core Standard 1.0 and the atomic-root workflow.",
    },
    {
        "source_node": 272,
        "kind": "instruction",
        "decision": "Start the first remaining nine-root chunk.",
        "effect": "Begins permanent Life-family root population.",
    },
    {
        "source_node": 281,
        "kind": "approval",
        "decision": "Proceed from Life entities to Life processes.",
        "effect": "Accepts Chunk 1A and authorizes Chunk 1B.",
    },
    {
        "source_node": 285,
        "kind": "approval",
        "decision": "Proceed from Life processes to Life capacities/relationships.",
        "effect": "Accepts Chunk 1B and authorizes Chunk 1C.",
    },
    {
        "source_node": 288,
        "kind": "approval",
        "decision": "Acknowledge the completed Life family.",
        "effect": "Supports the following explicit statement that Life is complete and fixed.",
    },
    {
        "source_node": 292,
        "kind": "approval",
        "decision": "Proceed with Motion Chunk 2A.",
        "effect": "Authorizes MOV:000–022, later declared fixed in the chunk itself.",
    },
    {
        "source_node": 303,
        "kind": "requirement",
        "decision": (
            "Treat the full chat as the most up-to-date Era Zero source, finish and "
            "compile the language first, and defer the English translator."
        ),
        "effect": "Defines the extraction-first handoff and translator gate.",
    },
]


def all_addresses() -> list[str]:
    return [f"{a}{b}{c}" for a in "012" for b in "012" for c in "012"]


def compact_root(address: str) -> str:
    return (
        COMPACT_INITIAL[address[0]]
        + COMPACT_VOWEL[address[1]]
        + COMPACT_FINAL[address[2]]
    )


def local_carrier(address: str) -> str:
    return "-".join(CARRIER[t] for t in address)


def note_path(address: str) -> list[int]:
    path = [0]
    current = 0
    for trit in address:
        current += MOVEMENT[trit]
        path.append(current)
    return path


def jsonl_write(path: Path, rows: Iterable[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=False, sort_keys=False) + "\n")


def yaml_scalar(value: Any) -> str:
    if value is None:
        return "null"
    if value is True:
        return "true"
    if value is False:
        return "false"
    if isinstance(value, (int, float)):
        return str(value)
    return json.dumps(str(value), ensure_ascii=False)


def yaml_dump(value: Any, indent: int = 0) -> str:
    prefix = " " * indent
    if isinstance(value, dict):
        if not value:
            return "{}"
        lines: list[str] = []
        for key, item in value.items():
            safe_key = key if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_-]*", str(key)) else yaml_scalar(key)
            if isinstance(item, (dict, list)) and item:
                lines.append(f"{prefix}{safe_key}:")
                lines.append(yaml_dump(item, indent + 2))
            elif isinstance(item, (dict, list)):
                lines.append(f"{prefix}{safe_key}: {yaml_dump(item, 0)}")
            else:
                lines.append(f"{prefix}{safe_key}: {yaml_scalar(item)}")
        return "\n".join(lines)
    if isinstance(value, list):
        if not value:
            return "[]"
        lines = []
        for item in value:
            if isinstance(item, dict) and item:
                first_key = next(iter(item))
                first_value = item[first_key]
                safe_key = (
                    first_key
                    if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_-]*", str(first_key))
                    else yaml_scalar(first_key)
                )
                if isinstance(first_value, (dict, list)) and first_value:
                    lines.append(f"{prefix}- {safe_key}:")
                    lines.append(yaml_dump(first_value, indent + 4))
                else:
                    lines.append(f"{prefix}- {safe_key}: {yaml_scalar(first_value)}")
                rest = dict(list(item.items())[1:])
                if rest:
                    rest_text = yaml_dump(rest, indent + 2)
                    lines.append(rest_text)
            elif isinstance(item, (dict, list)):
                lines.append(f"{prefix}-")
                lines.append(yaml_dump(item, indent + 2))
            else:
                lines.append(f"{prefix}- {yaml_scalar(item)}")
        return "\n".join(lines)
    return f"{prefix}{yaml_scalar(value)}"


def yaml_write(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("---\n" + yaml_dump(value) + "\n", encoding="utf-8")


def node_map(nodes: list[dict[str, Any]]) -> dict[int, dict[str, Any]]:
    return {int(node["source_index"]): node for node in nodes}


def visible_speaker_nodes(nodes: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [
        node
        for node in nodes
        if int(node["source_index"]) >= SPEAKER_TURN_START_NODE
        and not node.get("hidden")
        and node.get("role") in {"user", "assistant"}
        and node.get("content_type") == "text"
    ]


def coalesce_speaker_turns(nodes: list[dict[str, Any]]) -> list[dict[str, Any]]:
    turns: list[dict[str, Any]] = []
    for node in visible_speaker_nodes(nodes):
        role = node["role"]
        continue_assistant_turn = (
            role == "assistant"
            and turns
            and turns[-1]["speaker"] == "assistant"
            and not turns[-1].get("_closed", False)
        )
        if continue_assistant_turn:
            turns[-1]["text"] += "\n\n" + node["text"]
            turns[-1]["source_node_indices"].append(node["source_index"])
            turns[-1]["message_ids"].append(node["id"])
            if node.get("create_time") is not None:
                turns[-1]["timestamps"].append(node["create_time"])
            turns[-1]["_closed"] = node.get("end_turn") is True
        else:
            turns.append(
                {
                    "turn_index": len(turns) + 1,
                    "speaker": role,
                    "source_node_indices": [node["source_index"]],
                    "message_ids": [node["id"]],
                    "timestamps": (
                        [node["create_time"]] if node.get("create_time") is not None else []
                    ),
                    "text": node["text"],
                    "source_url": SOURCE_URL,
                    "_closed": node.get("end_turn") is True,
                }
            )
    for turn in turns:
        turn.pop("_closed", None)
    return turns


def render_original_markdown(turns: list[dict[str, Any]], source_hash: str) -> str:
    lines = [
        "# Era Zero Conversation Source",
        "",
        f"- Source: {SOURCE_URL}",
        f"- Decoded source SHA-256: `{source_hash}`",
        "- Scope: the complete visible user/assistant conversation from the shared page; Era Zero begins at decoded source node 32.",
        "- Ordering: exact order of the decoded `linear_conversation` source.",
        "",
    ]
    for turn in turns:
        nodes = ", ".join(str(i) for i in turn["source_node_indices"])
        lines.extend(
            [
                f"## Turn {turn['turn_index']:03d} — {turn['speaker']}",
                "",
                f"Source node(s): `{nodes}`",
                "",
                turn["text"],
                "",
            ]
        )
    return "\n".join(lines)


ROOT_HEADER_RE = re.compile(r"^## `(?P<family>LIF|MOV):(?P<address>[012]{3})` — (?P<title>.+)$", re.M)


def section_after_label(section: str, labels: list[str]) -> str | None:
    for label in labels:
        pattern = re.compile(
            rf"\*\*{re.escape(label)}:\*\*\s*\n+\s*>\s*(.+?)(?=\n\n|\n###|\n\*\*|\Z)",
            re.S,
        )
        match = pattern.search(section)
        if match:
            return re.sub(r"\s+", " ", match.group(1)).strip()
    return None


def inline_field(section: str, labels: list[str]) -> str | None:
    for label in labels:
        match = re.search(rf"\*\*{re.escape(label)}:\*\*\s*`?([^`\n]+)`?", section)
        if match:
            return match.group(1).strip()
    return None


def bullet_list_after(section: str, lead_patterns: list[str]) -> list[str]:
    for lead in lead_patterns:
        match = re.search(rf"{lead}\s*\n(?P<body>(?:\s*-\s+.+\n?)+)", section, re.I)
        if match:
            return [
                re.sub(r"\s+", " ", line.strip()[2:]).strip()
                for line in match.group("body").splitlines()
                if line.strip().startswith("- ")
            ]
    return []


def parse_roots(nodes_by_index: dict[int, dict[str, Any]]) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for source_index in ROOT_SOURCE_NODES:
        node = nodes_by_index[source_index]
        text = node["text"]
        matches = list(ROOT_HEADER_RE.finditer(text))
        for position, match in enumerate(matches):
            start = match.start()
            end = matches[position + 1].start() if position + 1 < len(matches) else len(text)
            section = text[start:end].strip()
            section = re.split(
                r"\n# (?:The completed|Completed|The complete|Completed Life)",
                section,
                maxsplit=1,
            )[0].strip()
            family = match.group("family")
            address = match.group("address")
            local = inline_field(section, ["Local compact root", "Compact root"])
            full_carrier = inline_field(section, ["Full carrier"])
            canonical_transliteration = inline_field(section, ["Canonical transliteration"])
            expected_local = compact_root(address)
            if local is None:
                local = expected_local
            if canonical_transliteration is None:
                canonical_transliteration = f"{FAMILIES[family]['onset']}·{local}"
            if full_carrier is None:
                full_carrier = (
                    f"{FAMILIES[family]['onset']}-"
                    + "-".join(CARRIER[t] for t in address)
                )
            core = section_after_label(section, ["Core meaning", "Meaning"])
            if core is None:
                raise ValueError(f"Could not parse core meaning for {family}:{address}")
            translations = bullet_list_after(
                section,
                [
                    r"Possible translations include:",
                    r"Depending on context, it can mean:",
                    r"It may mean:",
                    r"This may refer to:",
                    r"Examples include:",
                ],
            )
            melody_match = re.search(
                r"### C-reference melody\s*\n+```[^\n]*\n(?P<body>.*?)\n```",
                section,
                re.S,
            )
            example_blocks = [
                example.strip()
                for example in re.findall(
                    r"(?ms)^### (?:Example|Example command|Example question).*?(?=^### |^## |\Z)",
                    section,
                )
            ]
            distinction_statements = []
            for paragraph in re.split(r"\n\s*\n", section):
                normalized = re.sub(r"\s+", " ", paragraph).strip()
                if re.search(
                    r"\b(?:does not|do not|not merely|not simply|unlike|distinction|deeper than|more than)\b",
                    normalized,
                    re.I,
                ):
                    distinction_statements.append(normalized)
            record = {
                "family": family,
                "address": address,
                "canonical_id": f"{family}:{address}",
                "title": match.group("title").strip(),
                "family_onset": FAMILIES[family]["onset"],
                "harmonic_signature_semitones": FAMILIES[family]["intervals"],
                "universal_slot": UNIVERSAL_SLOTS[address],
                "local_compact_root": local,
                "canonical_transliteration": canonical_transliteration,
                "formal_carrier": full_carrier,
                "core_definition": core,
                "translation_candidates": translations,
                "distinctions_and_exclusions": distinction_statements,
                "source_c_reference_melody": (
                    melody_match.group("body").strip() if melody_match else None
                ),
                "source_examples_markdown": example_blocks,
                "note_path_semitones": note_path(address),
                "status": "canonical",
                "source": {
                    "source_node_index": source_index,
                    "message_id": node["id"],
                    "source_url": SOURCE_URL,
                    "section_heading": match.group(0),
                },
                "_source_record_markdown": section,
            }
            records.append(record)
    records.sort(key=lambda row: (FAMILY_ORDER.index(row["family"]), int(row["address"], 3)))
    return records


def public_root_records(roots: list[dict[str, Any]]) -> list[dict[str, Any]]:
    public: list[dict[str, Any]] = []
    for root in roots:
        item = {key: value for key, value in root.items() if not key.startswith("_")}
        item["source"]["verbatim_record_file"] = "lexicon/completed_atoms_source.md"
        item["source"]["verbatim_record_anchor"] = root["canonical_id"].lower().replace(":", "")
        public.append(item)
    return public


def completed_atoms_source_markdown(roots: list[dict[str, Any]], source_hash: str) -> str:
    lines = [
        "# Completed Era Zero Atomic Records — Verbatim Source Sections",
        "",
        f"- Source: {SOURCE_URL}",
        f"- Decoded source SHA-256: `{source_hash}`",
        "- Policy: the record sections below are copied verbatim from the fixed Life and Motion source turns.",
        "",
    ]
    for root in roots:
        lines.extend(
            [
                f'<a id="{root["canonical_id"].lower().replace(":", "")}"></a>',
                "",
                root["_source_record_markdown"],
                "",
                "---",
                "",
            ]
        )
    return "\n".join(lines)


def split_claim_units(text: str) -> list[dict[str, str]]:
    text = re.sub(r"^:::writing\{[^\n]+\}\s*", "", text)
    text = re.sub(r"\n:::\s*$", "", text)
    lines = text.splitlines()
    units: list[dict[str, str]] = []
    headings: list[str] = []
    paragraph: list[str] = []
    code: list[str] = []
    in_code = False

    def flush_paragraph() -> None:
        nonlocal paragraph
        if paragraph:
            claim = re.sub(r"\s+", " ", " ".join(paragraph)).strip()
            if claim:
                units.append({"section": " > ".join(headings), "claim": claim})
            paragraph = []

    def flush_code() -> None:
        nonlocal code
        if code:
            claim = "Formal notation:\n" + "\n".join(code).strip()
            if claim.strip() != "Formal notation:":
                units.append({"section": " > ".join(headings), "claim": claim})
            code = []

    for raw in lines:
        line = raw.rstrip()
        if line.strip().startswith("```"):
            if in_code:
                flush_code()
                in_code = False
            else:
                flush_paragraph()
                in_code = True
            continue
        if in_code:
            code.append(line)
            continue
        heading_match = re.match(r"^(#{1,6})\s+(.+)$", line.strip())
        if heading_match:
            flush_paragraph()
            level = len(heading_match.group(1))
            headings = headings[: level - 1] + [heading_match.group(2).strip()]
            continue
        stripped = line.strip()
        if not stripped:
            flush_paragraph()
            continue
        if re.fullmatch(r"\|?[\s:|-]+\|?", stripped):
            continue
        if stripped.startswith("|") and stripped.endswith("|"):
            flush_paragraph()
            cells = [cell.strip() for cell in stripped.strip("|").split("|")]
            units.append(
                {
                    "section": " > ".join(headings),
                    "claim": "Table row: " + " | ".join(cells),
                }
            )
            continue
        if re.match(r"^(?:[-*]|\d+\.)\s+", stripped):
            flush_paragraph()
            units.append(
                {
                    "section": " > ".join(headings),
                    "claim": re.sub(r"^(?:[-*]|\d+\.)\s+", "", stripped),
                }
            )
            continue
        if stripped.startswith(">"):
            flush_paragraph()
            units.append(
                {
                    "section": " > ".join(headings),
                    "claim": stripped.lstrip("> ").strip(),
                }
            )
            continue
        paragraph.append(stripped)
    flush_paragraph()
    flush_code()
    return units


def topic_for(claim: str, section: str) -> str:
    haystack = (section + " " + claim).lower()
    topics = [
        ("completed_root", r"\b(?:lif|mov):[012]{3}\b"),
        ("trit_encoding", r"\btrit|ternary|two semitone|current pitch"),
        ("compact_root", r"compact|transliteration|carrier syllable|full carrier"),
        ("harmonic_family", r"chord famil|harmonic|interval pattern|opening harmony"),
        ("runtime_state", r"runtime state|state ending|\bnum\b|inactive|active-state"),
        ("grammar_contour", r"contour|declaration|question|command|conditional|await"),
        ("timing_register", r"rhythm|register|overlap|timing|pulse|voice"),
        ("writing_system", r"glyph|writing system|outer frame|central path"),
        ("programming", r"program|execut|code|compiler|logic|software|function"),
        ("era_boundary", r"era one|era two|era three|later era|descend"),
        ("lexicon_scope", r"324|twenty-seven|lexicon|root inventory|periodic table"),
        ("translation", r"translation|translatable|english|gloss"),
    ]
    for topic, pattern in topics:
        if re.search(pattern, haystack):
            return topic
    return "architecture"


def next_user_after(nodes: list[dict[str, Any]], source_index: int) -> dict[str, Any] | None:
    for node in nodes:
        if (
            int(node["source_index"]) > source_index
            and node.get("role") == "user"
            and not node.get("hidden")
            and node.get("content_type") == "text"
        ):
            return node
    return None


def response_class(text: str) -> str:
    normalized = text.strip().lower()
    if normalized.startswith(("no", "but ", "i thought", "finally")):
        return "correction_or_redirect"
    if normalized in {"yes", "b", "c", "d", "e", "f", "ok", "do it", "do it please"}:
        return "accepted_or_continued"
    if "do it" in normalized or "continue" in normalized or "make the choices" in normalized:
        return "accepted_or_delegated"
    return "follow_up"


def build_source_ledger(nodes: list[dict[str, Any]]) -> list[dict[str, Any]]:
    ledger: list[dict[str, Any]] = []
    claim_counter = 1

    for node in nodes:
        source_index = int(node["source_index"])
        if (
            node.get("role") != "assistant"
            or node.get("content_type") != "text"
            or node.get("hidden")
            or source_index not in CORE_ERA_ZERO_ASSISTANT_NODES
        ):
            continue
        next_user = next_user_after(nodes, source_index)
        for unit_index, unit in enumerate(split_claim_units(node["text"]), start=1):
            claim = unit["claim"].strip()
            if not claim or claim == "This code was redacted.":
                continue
            if source_index in CANONICAL_SOURCE_NODES:
                status = "canonical_source_statement"
            elif source_index == 254:
                status = "canonical_draft_with_later_amendments"
            elif source_index in {258, 260, 262}:
                status = "accepted_design_direction"
            elif source_index < 254:
                status = "candidate_or_legacy"
            else:
                status = "handoff_or_summary"
            ledger.append(
                {
                    "claim_id": f"EZ-CLAIM-{claim_counter:04d}",
                    "turn_source_node": source_index,
                    "message_id": node["id"],
                    "speaker": "assistant",
                    "unit_index": unit_index,
                    "section": unit["section"] or None,
                    "topic": topic_for(claim, unit["section"]),
                    "claim": claim,
                    "status": status,
                    "user_response": (
                        {
                            "source_node": next_user["source_index"],
                            "classification": response_class(next_user["text"]),
                            "text": next_user["text"],
                        }
                        if next_user
                        else None
                    ),
                    "supersedes": [],
                    "source_url": SOURCE_URL,
                }
            )
            claim_counter += 1

    nodes_by_index = node_map(nodes)
    for decision in USER_DECISIONS:
        node = nodes_by_index[decision["source_node"]]
        ledger.append(
            {
                "claim_id": f"EZ-CLAIM-{claim_counter:04d}",
                "turn_source_node": decision["source_node"],
                "message_id": node["id"],
                "speaker": "user",
                "unit_index": 1,
                "section": "Explicit user decision",
                "topic": "user_decision",
                "claim": decision["decision"],
                "status": decision["kind"],
                "user_response": None,
                "supersedes": [],
                "notes": decision["effect"],
                "source_text": node["text"],
                "source_url": SOURCE_URL,
            }
        )
        claim_counter += 1

    ledger.sort(key=lambda row: (row["turn_source_node"], row["unit_index"], row["claim_id"]))
    for claim_counter, row in enumerate(ledger, start=1):
        row["claim_id"] = f"EZ-CLAIM-{claim_counter:04d}"
    return ledger


def manual_canonical_claims(
    nodes_by_index: dict[int, dict[str, Any]], roots: list[dict[str, Any]]
) -> list[dict[str, Any]]:
    claims: list[dict[str, Any]] = []

    def add(topic: str, claim: str, source_nodes: list[int], notes: str | None = None) -> None:
        entry = {
            "canonical_claim_id": f"EZ-CANON-{len(claims) + 1:04d}",
            "topic": topic,
            "claim": claim,
            "source_nodes": source_nodes,
            "source_message_ids": [nodes_by_index[i]["id"] for i in source_nodes],
            "status": "canonical",
        }
        if notes:
            entry["notes"] = notes
        claims.append(entry)

    add(
        "architecture",
        (
            "Era Zero is one integrated DBA language in which a unit combines harmonic "
            "family, trit address, grammatical contour, timing/role information, and "
            "runtime state; the same structure can be interpreted as speech, music, or code."
        ),
        [180, 254, 271],
    )
    add(
        "harmonic_families",
        "There are twelve semantic harmonic families, recognized by relative interval signatures rather than fixed absolute keys.",
        [271],
    )
    for family in FAMILY_ORDER:
        data = FAMILIES[family]
        add(
            "harmonic_family",
            (
                f"{family} has domain '{data['domain']}', vocal onset "
                f"'{data['onset']}', and relative harmonic signature "
                f"{'–'.join(str(x) for x in data['intervals'])}."
            ),
            [271],
        )
    add(
        "trit_encoding",
        "Trit 0 repeats the current pitch; trit 1 rises one DBA step; trit 2 falls one DBA step.",
        [271],
    )
    add(
        "trit_encoding",
        "One DBA step is two semitones, so trit movements are 0, +2, and -2 semitones.",
        [271],
    )
    add(
        "note_path",
        "A note path contains the starting pitch followed by one relative movement for each trit.",
        [271, 280],
    )
    add(
        "address_cube",
        "Every normal atomic root has exactly three trits and occupies one of 27 universal positions in its family.",
        [271],
    )
    for trit, meaning in FIRST_TRIT.items():
        add("address_cube", f"First address trit {trit} means {meaning}.", [271])
    for trit, meaning in SECOND_TRIT.items():
        add("address_cube", f"Second address trit {trit} means {meaning}.", [271])
    for trit, meaning in THIRD_TRIT.items():
        add("address_cube", f"Third address trit {trit} means {meaning}.", [271])
    add(
        "inventory",
        "The atomic inventory is 12 families × 27 addresses = 324 predictable roots.",
        [271],
    )
    add(
        "carrier",
        "Formal carrier syllables are 0=ma, 1=ki, and 2=nu, preceded by the family onset.",
        [271, 280],
    )
    add(
        "compact_root",
        (
            "The local compact-root algorithm maps the first trit to n/k/m, the second "
            "to a/o/i, and the third to m/k/n."
        ),
        [280],
    )
    add(
        "transliteration",
        (
            "The local compact root repeats at the same address in every family; canonical "
            "human transliteration prefixes the family onset with a middle dot, while the "
            "harmonic opening distinguishes the family in performance."
        ),
        [302],
    )
    add(
        "runtime_state",
        (
            "Runtime state is separate from the third semantic address trit: state 0 is "
            "inactive/false/ended/inaccessible; state 1 is active/valid/expressed; state 2 "
            "is num—pending, remembered, dormant, or unresolved."
        ),
        [271],
    )
    add(
        "runtime_state",
        (
            "State 0 descends one semitone and stops sharply; state 1 returns firmly to "
            "the phrase starting pitch; state 2 rises a perfect fifth and sustains."
        ),
        [271],
    )
    contour_rows = [
        ("level", "declaration", "assert or assign"),
        ("rising", "question", "query or evaluate"),
        ("sharply falling", "command", "execute"),
        ("rise then return", "definition", "declare a function or type"),
        ("fall then rise", "possibility", "conditional branch"),
        ("repeated loop", "repetition or habit", "iterate"),
        ("unresolved ending", "dependency", "await"),
        ("overlapping phrases", "simultaneity", "parallel execution"),
    ]
    for contour, linguistic, programming in contour_rows:
        add(
            "grammar_contour",
            f"{contour} contour marks {linguistic} and functions programmatically as {programming}.",
            [271],
        )
    register_rows = [
        ("low", "actor, source, or cause"),
        ("middle", "process or relationship"),
        ("high", "target, result, or destination"),
        ("sustained background pitch", "environment or persistent condition"),
    ]
    for register, role in register_rows:
        add("register", f"{register} register marks {role}.", [271])
    timing_rows = [
        ("no gap", "modifier relationship"),
        ("short gap", "argument relationship"),
        ("medium gap", "next instruction"),
        ("long gap", "completed statement"),
        ("overlap", "simultaneous processes"),
        ("repeated pulse", "recursion or repeated action"),
    ]
    for timing, meaning in timing_rows:
        add("timing", f"{timing} marks {meaning}.", [254, 271])
    add(
        "writing_system",
        (
            "A generated written unit encodes the family with its outer frame, trit path "
            "with a central line, grammatical role by vertical position, contour by line "
            "direction, timing by spacing, simultaneity by parallel paths, and runtime "
            "state with a tail."
        ),
        [271],
    )
    add(
        "writing_system",
        "Written trit movements are 0=straight, 1=upward angle, and 2=downward angle.",
        [271],
    )
    add(
        "era_boundary",
        "Era Zero atomic roots remain separate from Era One, Era Two, and Era Three descendant vocabulary.",
        [181, 208, 271],
    )
    add(
        "completion",
        "All 27 Life-family roots LIF:000–222 are complete and fixed.",
        [287, 290],
    )
    add(
        "completion",
        "Motion entity/condition roots MOV:000–022 are complete and fixed as Motion Family Chunk 2A.",
        [302],
    )
    add(
        "completion",
        "Exactly 36 of 324 atomic roots are complete; 288 roots remain in 32 nine-root chunks.",
        [287, 302, 312],
    )
    add(
        "workflow",
        "The remaining roots must be populated and approved before building a broad English translator.",
        [262, 303, 312],
    )
    for root in roots:
        add(
            "completed_root",
            (
                f"{root['canonical_id']} has canonical transliteration "
                f"{root['canonical_transliteration']} and means: {root['core_definition']}"
            ),
            [root["source"]["source_node_index"]],
        )
    return claims


def superseded_claims(nodes_by_index: dict[int, dict[str, Any]]) -> list[dict[str, Any]]:
    rows = [
        {
            "superseded_id": "EZ-SUP-0001",
            "topic": "harmonic_families",
            "earlier_claim": "Families are permanently tied to fixed home chords/keys such as LIF=C major and MOV=G major.",
            "source_nodes": [254],
            "superseded_by": "EZ Core 1.0 uses transposable relative interval signatures; C examples are references only.",
            "replacement_source_nodes": [258, 271],
        },
        {
            "superseded_id": "EZ-SUP-0002",
            "topic": "trit_encoding",
            "earlier_claim": "Trits 0, 1, and 2 are directly realized as a chord's root, third, and fifth.",
            "source_nodes": [254],
            "superseded_by": "Trits are relative movements: stay, rise two semitones, fall two semitones.",
            "replacement_source_nodes": [258, 271],
        },
        {
            "superseded_id": "EZ-SUP-0003",
            "topic": "trit_encoding",
            "earlier_claim": "One trit step is an unspecified scale step.",
            "source_nodes": [258, 260],
            "superseded_by": "One DBA step is exactly two semitones.",
            "replacement_source_nodes": [271],
        },
        {
            "superseded_id": "EZ-SUP-0004",
            "topic": "lexicon",
            "earlier_claim": "Life roots use unrelated forms such as mi, yu, nima, nimu, mir, nir, and num-lif.",
            "source_nodes": [254],
            "superseded_by": "Life compact roots are generated by the universal three-trit compact-root algorithm.",
            "replacement_source_nodes": [280, 284, 287],
        },
        {
            "superseded_id": "EZ-SUP-0005",
            "topic": "lexicon",
            "earlier_claim": "Motion roots use unrelated forms such as gan, gin, kim, gam, gat, gir, and gun.",
            "source_nodes": [254],
            "superseded_by": "Motion roots use the same local address root as every family, qualified as gi·root.",
            "replacement_source_nodes": [302],
        },
        {
            "superseded_id": "EZ-SUP-0006",
            "topic": "transliteration",
            "earlier_claim": "The compact root by itself is sufficient as the ordinary written root.",
            "source_nodes": [280],
            "superseded_by": "Canonical human transliteration includes the family onset and middle dot.",
            "replacement_source_nodes": [302],
            "notes": "The local root remains valid in harmonic performance and as an explicit local-root field.",
        },
        {
            "superseded_id": "EZ-SUP-0007",
            "topic": "runtime_state",
            "earlier_claim": "State 0 descends one scale step before stopping.",
            "source_nodes": [254],
            "superseded_by": "State 0 descends exactly one semitone and stops sharply.",
            "replacement_source_nodes": [271],
        },
        {
            "superseded_id": "EZ-SUP-0008",
            "topic": "examples",
            "earlier_claim": "Tak mi, wi dak. Yamir wi: da-1 is a canonical Era Zero apology.",
            "source_nodes": [254],
            "superseded_by": "Its roots come from the superseded arbitrary vocabulary and cannot be a canonical regression phrase under the fixed compact-root algorithm.",
            "replacement_source_nodes": [271, 280, 302],
        },
        {
            "superseded_id": "EZ-SUP-0009",
            "topic": "examples",
            "earlier_claim": "Yu da. Mi yu wu. Nim num. and Mi-am dak tan... are direct Era Zero forms.",
            "source_nodes": [227, 232, 236, 240],
            "superseded_by": "Later source identifies these as later-era/placeholder approximations, not the final engineered Era Zero encoding.",
            "replacement_source_nodes": [242, 244, 254, 271],
        },
        {
            "superseded_id": "EZ-SUP-0010",
            "topic": "pronunciation",
            "earlier_claim": "Early placeholder syllables can be assigned independently to semantic roots.",
            "source_nodes": [149, 154, 164, 168],
            "superseded_by": "Formal carriers and compact roots are generated algorithmically from family and address.",
            "replacement_source_nodes": [271, 280, 302],
        },
    ]
    for row in rows:
        row["source_message_ids"] = [nodes_by_index[i]["id"] for i in row["source_nodes"]]
        row["replacement_message_ids"] = [
            nodes_by_index[i]["id"] for i in row["replacement_source_nodes"]
        ]
        row["status"] = "superseded"
    return rows


def unresolved_issues(nodes_by_index: dict[int, dict[str, Any]]) -> list[dict[str, Any]]:
    issues = [
        {
            "issue_id": "EZ-UNRES-0001",
            "topic": "origin_num_lexeme",
            "question": (
                "Is num an Era Zero Origin-family atomic lexeme at a specific address, "
                "only the runtime-state name, or both?"
            ),
            "evidence": [
                "Source 254 assigns num to ORI:002 and num-or to ORI:222.",
                "Core 1.0 fixes the ORI onset as nu and the universal compact algorithm would produce nu·nan for ORI:002 and nu·min for ORI:222.",
                "Core 1.0 independently preserves num as runtime state 2.",
            ],
            "source_nodes": [254, 271, 280, 302],
            "blocking": False,
            "resolution": "Do not populate ORI or assign a canonical Era Zero num lexeme in Phase 1.",
        },
        {
            "issue_id": "EZ-UNRES-0002",
            "topic": "historical_contractions",
            "question": (
                "Which contractions (for example nim, mi, yu, da, wu, and num) were "
                "already conventional in Era Zero rather than only later descendants?"
            ),
            "evidence": [
                "Several earlier drafts use these as direct Era Zero words.",
                "Later canonical text explains many as possible historical contractions or fossils.",
                "No approved contraction table exists.",
            ],
            "source_nodes": [254, 271, 280],
            "blocking": False,
            "resolution": "Keep contractions historical/provisional; use canonical generated forms.",
        },
        {
            "issue_id": "EZ-UNRES-0003",
            "topic": "cyber_pet_compound",
            "question": "Is LIF:010 + CRE:020 + DAT:210 the canonical compound for cyber-pet?",
            "evidence": [
                "Core 1.0 proposes this decomposition approximately.",
                "CRE:020 and DAT:210 are not yet populated, so their final meanings are not fixed.",
            ],
            "source_nodes": [271],
            "blocking": False,
            "resolution": "Keep the compound provisional until CRE and DAT are populated.",
        },
        {
            "issue_id": "EZ-UNRES-0004",
            "topic": "negation",
            "question": "Is the semitone-displacement negation rule part of the final standard?",
            "evidence": [
                "The canonical-foundation draft at source 254 defines it.",
                "Core Standard 1.0 at source 271 omits it from the final contour table.",
            ],
            "source_nodes": [254, 271],
            "blocking": False,
            "resolution": "Treat as a candidate, not a Phase 1 canonical rule.",
        },
        {
            "issue_id": "EZ-UNRES-0005",
            "topic": "rhythm_harmony_dynamics",
            "question": (
                "Are pulse counts, voice counts, loudness-to-scope mappings, dotted "
                "conditionals, and accent interrupts canonical?"
            ),
            "evidence": [
                "Source 260 proposes these as final-specification ideas.",
                "Core Standard 1.0 retains contour, register, and some timing rules but does not reaffirm every quantitative mapping.",
            ],
            "source_nodes": [260, 271],
            "blocking": False,
            "resolution": "Keep only the reaffirmed contour/register/timing rules canonical.",
        },
        {
            "issue_id": "EZ-UNRES-0006",
            "topic": "long_addresses",
            "question": (
                "How are four-, five-, and six-trit specialized concepts allocated "
                "without colliding with the three-trit atomic cube?"
            ),
            "evidence": [
                "Sources 254, 258, and 271 allow expandable longer addresses.",
                "No allocation, namespace, or approval algorithm is fixed.",
            ],
            "source_nodes": [254, 258, 271],
            "blocking": False,
            "resolution": "Limit Phase 1 canonical inventory to the 324 three-trit atoms.",
        },
        {
            "issue_id": "EZ-UNRES-0007",
            "topic": "formal_syntax",
            "question": "What is the frozen AST/IR and formal executable syntax?",
            "evidence": [
                "Earlier documents propose multiple programming layers and examples.",
                "Core Standard 1.0 fixes performance semantics but does not freeze a full grammar schema.",
            ],
            "source_nodes": [159, 164, 168, 172, 177, 271],
            "blocking": False,
            "resolution": "Defer formal compiler syntax and English translation beyond Phase 1.",
        },
        {
            "issue_id": "EZ-UNRES-0008",
            "topic": "glyph_shapes",
            "question": "What exact visual family frames, role coordinates, spacing units, and state tails are used?",
            "evidence": [
                "Core 1.0 fixes the information each glyph must encode.",
                "No approved visual glyph sheet or geometry exists.",
            ],
            "source_nodes": [271],
            "blocking": False,
            "resolution": "Preserve only the abstract writing-system rules in the draft spec.",
        },
        {
            "issue_id": "EZ-UNRES-0009",
            "topic": "motion_post_approval",
            "question": "Was MOV:000–022 explicitly approved after presentation?",
            "evidence": [
                "The user authorized the chunk immediately before it.",
                "The chunk itself declares the nine roots fixed.",
                "The next user asks for a Codex handoff rather than issuing a correction.",
                "The current Phase 1 request explicitly calls these completed records.",
            ],
            "source_nodes": [292, 302, 303],
            "blocking": False,
            "resolution": "Treat the records as completed/canonical, while documenting the approval sequence.",
        },
    ]
    for issue in issues:
        issue["source_message_ids"] = [
            nodes_by_index[i]["id"] for i in issue["source_nodes"]
        ]
        issue["status"] = "open"
    return issues


def canonical_spec(
    source_hash: str, roots: list[dict[str, Any]], canonical_claims_data: list[dict[str, Any]]
) -> dict[str, Any]:
    families = []
    for code in FAMILY_ORDER:
        data = FAMILIES[code]
        families.append(
            {
                "code": code,
                "domain": data["domain"],
                "onset": data["onset"],
                "relative_harmonic_signature_semitones": data["intervals"],
            }
        )
    slots = [{"address": address, "meaning": UNIVERSAL_SLOTS[address]} for address in all_addresses()]
    return {
        "metadata": {
            "title": "Era Zero Draft Canonical Specification",
            "phase": 1,
            "status": "draft_for_user_review",
            "source_url": SOURCE_URL,
            "source_sha256": source_hash,
            "rule": "Only source-supported rules are included; unresolved items are excluded.",
        },
        "precedence": [
            "explicit user correction",
            "latest assistant specification explicitly accepted or continued by the user",
            "later canonical/fixed/complete statement",
            "unresolved when precedence cannot be established",
        ],
        "architecture": {
            "principle": "The music is the code; written forms are transcriptions of the same semantic structure.",
            "unit_layers": [
                "harmonic family",
                "three-trit atomic address",
                "grammatical contour",
                "timing and vocal-register roles",
                "runtime state ending",
            ],
        },
        "families": families,
        "atomic_address": {
            "length_trits": 3,
            "positions_per_family": 27,
            "total_positions": 324,
            "first_trit": FIRST_TRIT,
            "second_trit": SECOND_TRIT,
            "third_trit": THIRD_TRIT,
            "universal_slots": slots,
        },
        "melodic_encoding": {
            "relative": True,
            "dba_step_semitones": 2,
            "movement_semitones": MOVEMENT,
            "path_rule": "Include the starting pitch, then apply one movement per trit.",
            "examples": {
                "000": [0, 0, 0, 0],
                "012": [0, 0, 2, 0],
                "111": [0, 2, 4, 6],
                "222": [0, -2, -4, -6],
            },
        },
        "vocal_encoding": {
            "formal_trit_carriers": CARRIER,
            "compact_local_root": {
                "first_trit_initial": COMPACT_INITIAL,
                "second_trit_vowel": COMPACT_VOWEL,
                "third_trit_final": COMPACT_FINAL,
            },
            "canonical_human_transliteration": "family onset + middle dot + local compact root",
            "formal_carrier": "family onset + one carrier syllable per trit",
        },
        "runtime_states": {
            "separate_from_third_address_trit": True,
            "states": {
                "0": {
                    "meaning": "inactive, false, ended, unavailable, or inaccessible",
                    "ending": "descend one semitone and stop sharply",
                },
                "1": {
                    "meaning": "active, valid, expressed, or executing",
                    "ending": "return firmly to the phrase starting pitch",
                },
                "2": {
                    "name": "num",
                    "meaning": "dormant, pending, remembered, possible, or unresolved",
                    "ending": "rise a perfect fifth and sustain",
                },
            },
        },
        "grammar": {
            "contours": [
                {"contour": "level", "language": "declaration", "programming": "assert/assign"},
                {"contour": "rising", "language": "question", "programming": "query/evaluate"},
                {"contour": "sharply falling", "language": "command", "programming": "execute"},
                {
                    "contour": "rise then return",
                    "language": "definition",
                    "programming": "declare function/type",
                },
                {
                    "contour": "fall then rise",
                    "language": "possibility",
                    "programming": "conditional branch",
                },
                {
                    "contour": "repeated loop",
                    "language": "repetition or habit",
                    "programming": "iterate",
                },
                {
                    "contour": "unresolved ending",
                    "language": "dependency",
                    "programming": "await",
                },
                {
                    "contour": "overlapping phrases",
                    "language": "simultaneity",
                    "programming": "parallel execution",
                },
            ],
            "register_roles": {
                "low": "actor, source, or cause",
                "middle": "process or relationship",
                "high": "target, result, or destination",
                "sustained_background": "environment or persistent condition",
            },
            "timing": {
                "no_gap": "modifier relationship",
                "short_gap": "argument relationship",
                "medium_gap": "next instruction",
                "long_gap": "completed statement",
                "overlap": "simultaneous processes",
                "repeated_pulse": "recursion or repeated action",
            },
        },
        "writing_system": {
            "status": "abstract_encoding_only",
            "outer_frame": "family or harmonic domain",
            "central_path": "trit movements",
            "vertical_position": "grammatical role/register",
            "line_contour": "sentence function",
            "spacing": "timing and argument boundaries",
            "parallel_paths": "simultaneous voices",
            "tail": "runtime state",
            "trit_marks": {"0": "straight", "1": "angle upward", "2": "angle downward"},
        },
        "lexicon": {
            "completed_count": len(roots),
            "remaining_count": 324 - len(roots),
            "completed_atoms": roots,
            "unresolved_or_unpopulated_atoms_are_not_canonical": True,
        },
        "canonical_claim_ids": [
            claim["canonical_claim_id"] for claim in canonical_claims_data
        ],
        "excluded_from_phase_1": [
            "missing atomic-root invention",
            "unapproved conventional contractions",
            "broad English translator",
            "full compiler AST and parser",
            "finished visual glyph geometry",
        ],
    }


def gap_chunks(roots: list[dict[str, Any]]) -> list[dict[str, Any]]:
    complete = {root["canonical_id"] for root in roots}
    chunks: list[dict[str, Any]] = []
    domain_labels = {
        ("MOV", "1"): "movement processes",
        ("MOV", "2"): "movement capacities and relationships",
        ("MAT", "0"): "matter entities and conditions",
        ("MAT", "1"): "material processes",
        ("MAT", "2"): "material capacities and relationships",
        ("MIN", "0"): "mental entities and conditions",
        ("MIN", "1"): "cognitive processes",
        ("MIN", "2"): "mental capacities and relationships",
        ("CON", "0"): "communication and connection entities",
        ("CON", "1"): "communication processes",
        ("CON", "2"): "bonds, channels, and network capacities",
        ("STR", "0"): "structures, shelters, and organized systems",
        ("STR", "1"): "construction and organizational processes",
        ("STR", "2"): "structural capacities and system relationships",
        ("WRN", "0"): "danger, error, and corruption conditions",
        ("WRN", "1"): "detection, warning, isolation, and failure processes",
        ("WRN", "2"): "risk, vulnerability, and unresolved threats",
        ("REP", "0"): "repair states, healed conditions, and restoration targets",
        ("REP", "1"): "inspection, repair, healing, and restoration processes",
        ("REP", "2"): "recoverability, resilience, and maintenance relationships",
        ("LOG", "0"): "rules, values, proofs, operators, and logical objects",
        ("LOG", "1"): "evaluation, inference, comparison, branching, and execution",
        ("LOG", "2"): "validity, computability, constraints, and formal possibility",
        ("DAT", "0"): "records, symbols, messages, and stored information",
        ("DAT", "1"): "encoding, reading, writing, copying, transmitting, and retrieving",
        ("DAT", "2"): "access, fidelity, reference, linkage, and recoverable information",
        ("CRE", "0"): "designs, templates, created forms, and unrealized artifacts",
        ("CRE", "1"): "designing, generating, assembling, transforming, and instantiating",
        ("CRE", "2"): "creatability, authorship, design relations, and possibility space",
        ("ORI", "0"): "first causes, foundational states, and laws of reality",
        ("ORI", "1"): "emergence, manifestation, continuity, and ontological transition",
        ("ORI", "2"): "possibility, necessity, universality, and pre-manifest existence",
    }
    for family in FAMILY_ORDER:
        for layer in "012":
            ids = [
                f"{family}:{layer}{second}{third}"
                for second in "012"
                for third in "012"
                if f"{family}:{layer}{second}{third}" not in complete
            ]
            if ids:
                chunks.append(
                    {
                        "chunk_number": len(chunks) + 1,
                        "family": family,
                        "layer": int(layer),
                        "range": f"{family}:{layer}00–{layer}22",
                        "description": domain_labels[(family, layer)],
                        "root_ids": ids,
                        "status": "unpopulated",
                    }
                )
    return chunks


def conflict_report_text(
    superseded: list[dict[str, Any]], unresolved: list[dict[str, Any]]
) -> str:
    lines = [
        "# Era Zero Conflict Report",
        "",
        "## Precedence used",
        "",
        "1. Explicit user correction.",
        "2. Latest assistant specification accepted or continued by the user.",
        "3. Later statements explicitly marked canonical, fixed, complete, or 1.0.",
        "4. Unresolved when the source does not determine precedence.",
        "",
        "## Resolved conflicts",
        "",
        "| ID | Topic | Earlier claim | Resolution |",
        "|---|---|---|---|",
    ]
    for row in superseded:
        earlier = row["earlier_claim"].replace("|", "\\|")
        resolution = row["superseded_by"].replace("|", "\\|")
        lines.append(
            f"| `{row['superseded_id']}` | {row['topic']} | {earlier} | {resolution} |"
        )
    lines.extend(
        [
            "",
            "## Open issues",
            "",
            "| ID | Topic | Question | Phase 1 treatment |",
            "|---|---|---|---|",
        ]
    )
    for row in unresolved:
        question = row["question"].replace("|", "\\|")
        treatment = row["resolution"].replace("|", "\\|")
        lines.append(
            f"| `{row['issue_id']}` | {row['topic']} | {question} | {treatment} |"
        )
    lines.extend(
        [
            "",
            "## Canonical precedence chain",
            "",
            "- Source node 254 calls itself a canonical foundation, but its fixed-key harmonies, chord-tone trits, and arbitrary roots are later amended.",
            "- Source nodes 258–263 move to relative trit motion and receive user approval/delegation.",
            "- Source node 271 explicitly declares **Era Zero Core Standard 1.0** and says conflicting earlier drafts are superseded.",
            "- Source nodes 280, 284, and 287 populate the Life roots with the generated compact-root algorithm.",
            "- Source node 290 declares the Life family complete and fixed after the user's acknowledgement.",
            "- Source node 302 clarifies family-qualified human transliteration and fixes MOV:000–022.",
            "",
            "No unresolved issue was silently resolved, and no missing root was populated.",
        ]
    )
    return "\n".join(lines) + "\n"


def gap_report_text(chunks: list[dict[str, Any]]) -> str:
    lines = [
        "# Era Zero Atomic-Root Gap Report",
        "",
        "- Total atomic roots: **324**",
        "- Completed: **36** (`LIF:000–222` and `MOV:000–022`)",
        "- Remaining: **288**",
        "- Remaining nine-root chunks: **32**",
        "",
        "No missing root has been named or assigned a meaning.",
        "",
        "## Remaining chunks and exact root IDs",
        "",
    ]
    for chunk in chunks:
        lines.extend(
            [
                f"### {chunk['chunk_number']:02d}. `{chunk['range']}` — {chunk['description']}",
                "",
                ", ".join(f"`{root_id}`" for root_id in chunk["root_ids"]),
                "",
            ]
        )
    return "\n".join(lines)


def extraction_report_text(
    turns: list[dict[str, Any]],
    ledger: list[dict[str, Any]],
    canonical: list[dict[str, Any]],
    superseded: list[dict[str, Any]],
    unresolved: list[dict[str, Any]],
    roots: list[dict[str, Any]],
    chunks: list[dict[str, Any]],
    source_hash: str,
) -> str:
    users = sum(1 for turn in turns if turn["speaker"] == "user")
    assistants = sum(1 for turn in turns if turn["speaker"] == "assistant")
    root_counts = defaultdict(int)
    for root in roots:
        root_counts[root["family"]] += 1
    lines = [
        "# Era Zero Phase 1 Extraction Report",
        "",
        "## Source integrity",
        "",
        f"- Source URL: {SOURCE_URL}",
        f"- Decoded full conversation SHA-256: `{source_hash}`",
        "- Decoded conversation graph: **313 nodes**.",
        f"- Coalesced visible full-conversation speaker turns: **{len(turns)}** ({users} user, {assistants} assistant).",
        "- Era Zero language work begins at decoded source node **32**; the preceding Chinese-writing exchange is preserved but excluded from the Era Zero claim ledger.",
        "- Source was read and captured before language artifacts were generated.",
        "",
        "## Extraction totals",
        "",
        f"- Source-ledger claim/event records: **{len(ledger)}**",
        f"- Curated canonical claims: **{len(canonical)}**",
        f"- Resolved superseded conflicts: **{len(superseded)}**",
        f"- Open issues retained without guessing: **{len(unresolved)}**",
        f"- Completed atomic roots extracted unchanged in meaning: **{len(roots)}**",
        f"  - Life: **{root_counts['LIF']}**",
        f"  - Motion: **{root_counts['MOV']}**",
        f"- Remaining roots: **{sum(len(chunk['root_ids']) for chunk in chunks)}** in **{len(chunks)}** chunks.",
        "",
        "## Main canonical findings",
        "",
        "- The latest trit algorithm is relative movement: `0=0`, `1=+2`, `2=-2` semitones.",
        "- Harmonic families are transposable relative interval signatures.",
        "- Atomic addresses are three trits with a universal 3×3×3 semantic cube.",
        "- Formal carriers use `ma/ki/nu`; compact roots are generated as initial+vowel+final.",
        "- Canonical human transliteration includes the family onset (`ni·nam`, `gi·nam`).",
        "- The third semantic trit and final runtime state are distinct.",
        "- Life has 27 fixed roots; Motion Chunk 2A has nine fixed roots.",
        "",
        "## Validation",
        "",
        "- The companion validator checks 23 address, compact-root, carrier, note-path, uniqueness, and completed-record invariants.",
        "- Current result: **23 passed, 0 failed**. See `reports/validation_report.md`.",
        "",
        "## Important unresolved items",
        "",
        "- The lexical status/address of `num` in the Origin family is not safely resolvable under the later compact-root algorithm.",
        "- Historical contractions and the proposed cyber-pet compound remain provisional.",
        "- Detailed pulse-count, voice-count, dynamics, negation, long-address allocation, formal AST, and glyph geometry are not fully frozen.",
        "",
        "## Phase gate",
        "",
        "Phase 1 stops here. No missing roots were filled and no English translator was built.",
        "",
        "Review `conflict_report.md`, `unresolved_issues.yaml`, the 36 completed atom records, and the validation report before authorizing Phase 2.",
    ]
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("capture", type=Path, help="Decoded chat capture JSON")
    parser.add_argument("--workspace", type=Path, default=Path.cwd())
    args = parser.parse_args()

    capture = json.loads(args.capture.read_text(encoding="utf-8"))
    nodes = capture["nodes"]
    source_hash = capture.get("full_source_sha256") or hashlib.sha256(
        json.dumps(nodes, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    ).hexdigest()
    workspace = args.workspace.resolve()
    nodes_by_index = node_map(nodes)

    turns = coalesce_speaker_turns(nodes)
    roots = parse_roots(nodes_by_index)
    roots_public = public_root_records(roots)
    ledger = build_source_ledger(nodes)
    canonical = manual_canonical_claims(nodes_by_index, roots_public)
    superseded = superseded_claims(nodes_by_index)
    unresolved = unresolved_issues(nodes_by_index)
    chunks = gap_chunks(roots_public)
    spec = canonical_spec(source_hash, roots_public, canonical)

    sources_dir = workspace / "sources"
    extraction_dir = workspace / "extraction"
    spec_dir = workspace / "spec"
    lexicon_dir = workspace / "lexicon"
    reports_dir = workspace / "reports"
    for directory in [sources_dir, extraction_dir, spec_dir, lexicon_dir, reports_dir]:
        directory.mkdir(parents=True, exist_ok=True)

    (sources_dir / "era_zero_chat_original.md").write_text(
        render_original_markdown(turns, source_hash), encoding="utf-8"
    )
    jsonl_write(sources_dir / "era_zero_chat_turns.jsonl", turns)
    jsonl_write(extraction_dir / "source_ledger.jsonl", ledger)
    yaml_write(
        extraction_dir / "user_decisions.yaml",
        {
            "metadata": {"source_url": SOURCE_URL, "count": len(USER_DECISIONS)},
            "decisions": USER_DECISIONS,
        },
    )
    yaml_write(
        extraction_dir / "canonical_claims.yaml",
        {
            "metadata": {
                "status": "draft_for_user_review",
                "source_url": SOURCE_URL,
                "source_sha256": source_hash,
                "count": len(canonical),
            },
            "claims": canonical,
        },
    )
    yaml_write(
        extraction_dir / "superseded_claims.yaml",
        {"metadata": {"count": len(superseded)}, "claims": superseded},
    )
    yaml_write(
        extraction_dir / "unresolved_issues.yaml",
        {"metadata": {"count": len(unresolved)}, "issues": unresolved},
    )
    (extraction_dir / "conflict_report.md").write_text(
        conflict_report_text(superseded, unresolved), encoding="utf-8"
    )
    yaml_write(spec_dir / "canonical_spec.yaml", spec)
    yaml_write(
        lexicon_dir / "completed_atoms.yaml",
        {
            "metadata": {
                "status": "canonical_extraction",
                "count": len(roots_public),
                "source_url": SOURCE_URL,
                "meaning_policy": "Core definitions are extracted from the fixed Life and Motion source sections.",
            },
            "atoms": roots_public,
        },
    )
    (lexicon_dir / "completed_atoms_source.md").write_text(
        completed_atoms_source_markdown(roots, source_hash), encoding="utf-8"
    )
    yaml_write(
        reports_dir / "atomic_root_gaps.yaml",
        {
            "metadata": {
                "total": 324,
                "completed": len(roots_public),
                "remaining": 324 - len(roots_public),
                "remaining_chunks": len(chunks),
            },
            "chunks": chunks,
        },
    )
    (reports_dir / "gap_report.md").write_text(
        gap_report_text(chunks), encoding="utf-8"
    )
    (reports_dir / "extraction_report.md").write_text(
        extraction_report_text(
            turns,
            ledger,
            canonical,
            superseded,
            unresolved,
            roots_public,
            chunks,
            source_hash,
        ),
        encoding="utf-8",
    )

    manifest = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source_url": SOURCE_URL,
        "source_sha256": source_hash,
        "files": [
            "sources/era_zero_chat_original.md",
            "sources/era_zero_chat_turns.jsonl",
            "extraction/source_ledger.jsonl",
            "extraction/user_decisions.yaml",
            "extraction/canonical_claims.yaml",
            "extraction/superseded_claims.yaml",
            "extraction/unresolved_issues.yaml",
            "extraction/conflict_report.md",
            "spec/canonical_spec.yaml",
            "lexicon/completed_atoms.yaml",
            "lexicon/completed_atoms_source.md",
            "reports/atomic_root_gaps.yaml",
            "reports/gap_report.md",
            "reports/extraction_report.md",
            "reports/validation_report.md",
        ],
    }
    (workspace / "phase1_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    print(
        json.dumps(
            {
                "turns": len(turns),
                "ledger_records": len(ledger),
                "canonical_claims": len(canonical),
                "roots": len(roots_public),
                "remaining_roots": sum(len(chunk["root_ids"]) for chunk in chunks),
                "remaining_chunks": len(chunks),
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
