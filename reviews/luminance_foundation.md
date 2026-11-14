# Luminance before bright/dim adjectives

The inventory already supports material bearers, exact measures and comparison
roles. Reuse MAT:010 (or focal MAT:000), rather than inventing a root for brightness
or equating it with energized material. Photometric luminance is a distinct
measurable property, in candela per square metre. Luminous intensity in candela,
illuminance in lux and perceived brightness are different quantities or senses.

Primary sources: [BIPM photometry principles](https://www.bipm.org/documents/20126/41749107/Principles%2Bgoverning%2Bphotometry/8365350c-bf72-3cf2-bf03-324bf5c01b62)
and [BIPM candela definition](https://www.bipm.org/en/si-base-units/candela).
Luminance is directional and surface-dependent; the explicit construction refers
to the contextually specified surface/viewing direction. It does not choose an
observer's subjective brightness, reference class or adjective threshold.

Append measurement unit code 15 (`candela_per_square_meter`) and property comparison
code 3 (`luminance`). Existing codes retain their sounds. Values normalize exactly
as decimal strings without floating-point conversion. Negative values and other
photometric units are rejected by the English construction. Runtime endings retain
their independent meanings; they do not encode brightness levels.

The dependency order is explicit measurement, ordered comparison, then contextual
bright/dim readings with a selected physical sense and supplied threshold. Broad
perceived brightness, glare, color, illuminance and metaphorical brightness remain
separate requirements. No new root or compound is introduced by this unit route.

Implemented evidence: 48 exact-measure/comparison cases preserve role direction,
runtime and reference-renderer/MIDI parity. A MIDI-only material-measure inverse
recovers the bearer, unit, magnitude/bound, negation, time and modality without the
source sentence or IR. Bright/dim now asks for the physical-luminance sense and a
nonnegative contextual threshold; it supplies no default cutoff. Fifteen adjective
cases and actual choice-panel handlers verify missing/invalid thresholds, changed
input, questions and temporal/modal scope. The 40-phrase authored diagnostic now
has 24 checked compositions, 10 uncomposed cases and 6 requiring interpretation;
clarification is not counted as a completed translation. Existing mass and thermal
standard tests pass, and the full strict inverse covers 5,429 performances.
