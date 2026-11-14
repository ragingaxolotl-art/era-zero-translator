# Bodily activity before running, swimming and paths

Status: author foundation review; candidate definitions, not approved vocabulary.
The current authority is 324 roots and 52 compounds. The ordinary audit still
fails “Nora runs to the gate” and “Eli swims across the river.”

## Why generic movement is insufficient

MOV:121 asserts positional change relative to an environmental frame. It does not
select self-propulsion, gait or medium. MAT:000 supplies the focal physical body,
but no motion pattern. MAT:211 supplies physical influence on a distinct target,
but no propulsion or water. MOV:221 supplies a maintained or updated positional
configuration, but no running mechanics. None is a sufficient English alias.

Running must not be defined as a universal speed threshold or a mandatory flight
phase. A primary simulation study models grounded running in birds with continuing
ground contact: [van Bijlert et al., Science Advances, 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC11423892/).
This is evidence against the flight-phase requirement, not a universal dictionary
definition or proof of an Era Zero graph.

The [NLM Swimming descriptor](https://www.ncbi.nlm.nih.gov/mesh?Cmd=DetailsSearch&Db=mesh&Term=%22Swimming%22%5BMeSH+Terms%5D)
distinguishes propulsion through water by bodily movements. Passive transport in
water therefore cannot stand in for the intended bodily swimming sense. NLM's
scope does not settle all figurative, robotic or medium-general meanings.

## Dependency decision

Use a body-local activity foundation before asserting displacement. Candidate
graph: MAT:000 qualifies MAT:101, with one actor slot bound to the same focal body.
MAT:101 supplies ongoing physical-state change localized within that bearer;
the convention must explicitly supply the coordinated bodily locomotor pattern.
The material and local-change commitments remain true during in-place activity.
Neither root alone supplies agency, gait, medium, intention or destination.

Next specialize the same activity into running gait and swimming propulsion,
with exact dependency versions and actor identity. Running is a learned gait
distinction, not a speed or airborne-state alias. Its definition must allow
grounded forms and must not require human anatomy for every use. Swimming must
distinguish activity in water from passive drifting or being carried by a boat;
equipment-assisted bodily swimming need not imply an entirely unassisted swimmer.

Only then combine activity with MOV displacement/path meanings, binding the
same participant and event. “Toward” does not assert arrival. “Across” requires
a path relative to the traversed region and must distinguish ongoing traversal
from completed crossing. “Runs to” additionally needs the habitual/narrative
aspect choice already encountered with carrying. A running or swimming activity
cannot be silently turned into a completed journey by its runtime ending.

No new 27-root family is justified here. Explicit conventional compounds can add
the manner commitment while retaining true physical ingredients. No convention
code is allocated by this review. Source-informed distinctions still require
versioned definitions, ordinary composition, binding validation, music and a
MIDI-only meaning inverse before they count as translations.

## Acceptance obligations

The companion candidate file records participant, manner, medium, path and state
contrasts. It deliberately includes in-place running, passive water transport,
reversed participants, negation and runtime independence. These are requirements,
not passing cases. Ordinary swimming is reviewed in the water sense; generalized
fluid locomotion, machine operation, flowing liquids and figurative running remain
separate senses. The two original audit failures remain open.

Implementation follow-up: [swimming foundation](swimming_foundation.md) now
encodes the body-local activity and water-propulsion specialization as conventions
20 and 21. The running branch remains unimplemented; convention 21 is swimming,
not a reserved running code. No path or arrival is inferred from this activity.
