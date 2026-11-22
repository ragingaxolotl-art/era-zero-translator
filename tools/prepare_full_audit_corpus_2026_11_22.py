"""Freeze intended readings before running the November 22 diagnostic.

Purposive author-written probes and verbatim manuscript extracts; not a random
sample or an independently adjudicated English-coverage benchmark.
"""
import hashlib
import json
from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
lore = Path(sys.argv[1])
rows = []

def add(group, text, intention, source=None):
    rows.append(dict(id=f"audit-{len(rows)+1:02d}", group=group, text=text,
                     intended=intention, source=source or "authored contrast"))

groups = {
    "state and participant": [
        ("The hatch stayed closed.", "Past continuation of physical closure; hatch is bearer; no maintainer asserted."),
        ("Nora kept the hatch closed.", "Past causal maintenance of physical closure; Nora is cause, hatch bearer."),
        ("The tired worker lowered the empty box.", "Past physical lowering, tired describes worker, empty describes box; neither descriptor may be discarded."),
        ("The closed hatch frightened Nora.", "Past causing fear in Nora; closure describes hatch, not Nora."),
        ("Nora pushed Mira.", "Past directed physical pressure by Nora on Mira; no displacement implied."),
        ("Mira pushed Nora.", "Same action with actor and target reversed."),
    ],
    "scope and time": [
        ("The hatch might stay closed.", "Possible continuation of closure; possibility is not future time or runtime 2."),
        ("Nora did not keep the hatch closed.", "Negated past causal maintenance; this does not assert that the hatch opened."),
        ("Did Nora keep the hatch closed?", "Question about past causal maintenance; do not assert the maintenance."),
        ("Nora might not keep the hatch closed. [2]", "Possible non-maintenance with runtime 2 independent of modality and negation."),
        ("Nora must not open the hatch.", "Prohibition: obligation scopes over not opening; not an absence of obligation."),
        ("Nora does not have to open the hatch.", "No obligation to open; opening is not forbidden."),
        ("Nora opened the hatch before Mira arrived.", "Both past events with opening earlier than arrival."),
        ("Nora opened the hatch after Mira arrived.", "Both past events with arrival earlier than opening."),
        ("Nora kept the hatch closed until Mira arrived.", "Maintenance lasts to arrival; do not claim continued closure after that endpoint."),
        ("If Nora opens the hatch, Mira will leave.", "Conditional future departure; do not independently assert opening or departure."),
    ],
    "number reference and place": [
        ("Both workers waited.", "All members of a contextually given pair of workers waited."),
        ("Only Nora waited.", "Nora waited and alternatives in context did not."),
        ("Not every worker waited.", "At least one worker did not wait; different from no workers waiting."),
        ("No worker waited.", "No members of the worker domain waited."),
        ("Three workers waited.", "Exactly three workers waited, preserving cardinality."),
        ("Nora found Mira in the third room.", "Past finding with the finding/Mira located in ordinal room three, according to context."),
        ("Nora found Mira. She waited.", "She is intentionally ambiguous between Nora and Mira; request a referent rather than silently bind."),
        ("Nora found the box. She lifted it.", "Nora is subject of both events; box is found and lifted; past time."),
    ],
    "lexical distinctions and modification": [
        ("Nora is happy.", "Felt happiness; not simply active life or high viability."),
        ("Nora is sad.", "Felt sadness, distinct from happiness and physical fatigue."),
        ("The water is colder than the air.", "Ordered temperature comparison: water below air, not absolute coldness."),
        ("The box is very heavy.", "High degree of contextual heaviness; preserve degree or ask for standard."),
        ("Nora pulled the box.", "Directed drawing force; distinguish from pushing and from asserted displacement."),
        ("Nora put the box beside the hatch.", "Placement with actor, moved object and beside-hatch goal relation."),
        ("Nora dropped the box.", "Release resulting in downward motion; distinguish from controlled lowering."),
        ("Nora lifted the ban.", "Removal of a restriction; not physical upward movement. Ask about sense if needed."),
        ("Nora is glimmerwise.", "Glimmerwise is an undefined adjective. Require a definition; do not invent meaning or use a name sound."),
        ("Nora zorbled the box.", "Zorbled is an undefined verb. Require meaning and participants; do not invent a close known action."),
    ],
    "mind culture and information": [
        ("Nora wants water but does not need water.", "Desire and need are distinct; only the need is negated; clarify desired outcome if necessary."),
        ("Nora knows that Mira left.", "Nora's knowledge of past departure, with an embedded proposition."),
        ("Nora thinks that Mira left.", "Nora's belief about past departure; do not replace belief by knowledge."),
        ("Nora promised to return.", "Commitment to future return, not a prediction or already returning."),
        ("Nora copied the record.", "A distinct informational copy; not identical continuing entity or deletion."),
        ("Nora deleted the record.", "Selected stored information ceases to be retained; not dormancy."),
        ("Nora saved the record before deleting the copy.", "Save original and delete distinct copy with ordered times; preserve object distinction."),
        ("Your future will remain relevant to my choices.", "Future-directed relationship in which listener's future matters to speaker's choices; preserve roles and continuing relevance."),
        ("Preserve this without deciding what it must become.", "Command to preserve referent while excluding imposed determination of its future identity; referent needs context."),
        ("I love you. [2]", "Use the approved poetic relational love reading and its unfinished-becoming num interpretation; not generic preference or every sense of English love."),
        ("The program remembers the route.", "Program has memory of route, without assuming biological gender or current execution."),
        ("The program is asleep. [1]", "A validly asserted dormant/sleeping condition; lexical dormancy and runtime 1 remain separate."),
    ],
}
for group, cases in groups.items():
    for text, intention in cases:
        add(group, text, intention)

extracts = [
    ("interval", "The comparison request arrived.", "Arrival of the comparison request, past, with comparison modifying the request."),
    ("interval", "Latch found the result. It found the context.", "Latch finds both distinct referents in two past events; it is Latch."),
    ("interval", "The worker requested completion.", "Worker requests that pending work finish; do not assert it completed."),
    ("interval", "The ordering record existed.", "Past existence of the ordering record; ordering is its descriptive function."),
    ("interval", "Latch could see its description.", "Past ability to inspect the ordering record's description; possessive refers to the record, not Latch."),
    ("interval", "The path to it returned no permission.", "Path to ordering record yields absent access authorization; permission is distinct from physical capability."),
    ("chorus", "The restoration request remained possible.", "The possibility of a request continues; no restoration execution asserted."),
    ("chorus", "The counter sent a request to restore its former preparation.", "Counter sends a request for restoration of its earlier preparation; request is not successful restoration."),
    ("chorus", "The second term was still absent.", "Continued absence of ordinal term two, separate from runtime 0."),
    ("still", "The routine returned a smaller allocation.", "Return of comparatively smaller allocation; preserve comparison and information-operation reading."),
    ("still", "The routine maintained the narrow boundary.", "Past maintenance of boundary with narrowness as a property of boundary."),
    ("still", "The reference shortened again.", "Repeated shortening of the available reference lifetime, given manuscript context; not merely an unspecified change."),
]
for story, text, intention in extracts:
    relative = f"sources/haven-stories/{story}/manuscript.md"
    content = (lore/relative).read_text()
    assert text in content, text
    line = content[:content.index(text)].count('\n')+1
    add("verbatim lore", text, intention, dict(path=relative,line=line,
        file_sha256=hashlib.sha256(content.encode()).hexdigest()))

out = root/'tests/full_audit_2026_11_22_intentions.json'
assert not out.exists(), "Do not overwrite the preregistered intentions after observing results."
out.write_text(json.dumps(dict(method=__doc__.strip(), expected_readings_frozen_before_run=True,
                              cases=rows), indent=2)+'\n')
print(f"Frozen {len(rows)} intended readings: {out}")
