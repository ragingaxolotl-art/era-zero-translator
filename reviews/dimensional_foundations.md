# Dimensional foundations and dependency order

Decision: reuse explicit units already defined by the semantic IR before proposing
new roots. This review distinguishes a measured quantity, a dimension, a property
axis, a comparison, and a contextual adjective. They are separate requirements.

## Existing mass foundation

`spec/semantic_ir_1.0.yaml` already assigns gram and kilogram to mass. Its
measurement node supplies magnitude and unit; its quantity role binds a measure
to a lexical occurrence. MAT:010 supplies the distinct material object, with the
named object bound as bearer. For the speaker's own body, MAT:000 supplies the
focal material substrate. This is sufficient for the explicit construction
“the box has a mass of 5 kilograms.” The measurement qualifies that body's mass;
it does not describe five boxes or an event of measuring the box.

The noun label identifies the bearer. The explicit mass assertion supplies the
physical restriction; the parser does not infer that restriction from the noun's
spelling. In this construction a name denotes a material bearer, not an abstract
idea with a metaphorical mass.

The implementation normalizes grams to kilograms using decimal strings. Thus
5000 grams and 5 kilograms have the same semantic graph and music. Large decimal
values do not pass through floating-point arithmetic. Negative mass, unknown
units and group-versus-individual readings are outside this construction. Runtime
[0], [1], and [2] qualify the lexical occurrence independently of the scalar number.

This is a grammar/English-coverage repair using an existing dimension convention,
not a new compound or root. It does not establish weight as force, perceived
burden, heaviness, density, size or temperature. In particular, the familiar verb
“weighs” needs an explicit mass-versus-force sense policy before being an alias.

## Reusable dependencies before adjectives

| Layer | Existing support | Required next distinction |
|---|---|---|
| Exact quantities | Decimal magnitudes; time, length, mass, angle and information units; distinct musical frames | Bind each measure to the property actually asserted, with exact compatible-unit normalization |
| Property axis | Mass is selected by mass units in the explicit construction | Length alone does not select height, width, depth, distance along a route or displacement |
| Ratio | Numerator and denominator measures can be represented separately | A ratio relation must connect them; speed must distinguish path length per duration from displacement per duration |
| Comparison | Scalar bounds on a measured quantity now distinguish exact, greater/less, inclusive bounds and inequality | Mass comparisons now bind bearer and comparison_standard explicitly; other property axes remain unfinished |
| Contextual adjective | No universal threshold follows from a root or unit | “Heavy” needs the intended mass/burden sense, reference class and standard; “fast” needs the relevant rate |
| New dimension | Material state and energy roots remain available as general ingredients | Temperature identity and scale are not the same as energized material; thermal adjectives require this distinction first |

A length-based “big” claim also needs an interpretation: volume, extent, height or
another contextually chosen dimension. A kilogram value cannot silently become a
large/small judgment. Brightness requires a perceptual or physical intensity
sense; it must not be assigned to material energy alone. Those foundations connect
to the separate perception review.

## Root reuse boundaries

MAT:011 expresses energized material, not high temperature. MAT:111 expresses a
physical-state change, not a specified change of mass or size. MOV:121 expresses
ongoing positional change relative to a frame, not speed. LOG:111 evaluates
admissibility under a constraint, not an already-specified scalar ordering. DAT
can represent a measurement record without asserting that its content is a true
measurement of the referent. None should become an alias for these missing
relations merely because its definition is broad.

The existing unit inventory means that “no root says mass” is insufficient evidence
for a primitive gap. Conversely, having a mass unit does not prove that every
comparative adjective or property relation is already expressible. Classify the
missing step before adding vocabulary.

## Acceptance contrasts

- 5 kilograms versus 5000 grams: equal normalized meaning and sound.
- 5 kilograms versus 5 grams: distinct magnitudes after normalization.
- One body's mass versus the number of bodies: quantity assignment versus set cardinality.
- Mass versus weight force, and mass versus perceived carrying effort: distinct senses.
- Same mass on different named bearers: distinct reference binding.
- Heavier than versus lighter than: ordered comparison, not runtime-state changes.
- Hot versus energized; fast versus far: no broad-root substitution.

The explicit-mass sentence tests establish only the first implemented construction
and its scope. Mass comparison between two named or deictic bearers now has a dedicated operator
and musical frame. Temperature, contextual adjective interpretation, other
property axes and general measurement noun phrases remain unfinished. The additive comparison
profile defines a measurement node’s magnitude as a reference bound when a
comparison is present; without it, existing exact-measurement semantics remain.

## Next temperature foundation

Use an explicit thermodynamic-temperature measurement before contextual hot/cold adjectives. The [BIPM kelvin definition](https://www.bipm.org/en/si-base-units/kelvin) establishes the dimension, and the [BIPM temperature realization appendix](https://www.bipm.org/documents/20126/237262613/SI-App2-kelvin-2024-TG-Dig-revision/1444eda0-9ec1-7917-9eb7-41bc0d73e23a) states the Celsius offset from 273.15 K. This supplies a documented dimension convention; MAT:011 alone still does not supply temperature.

Implementation order: append a new unit identity without renumbering published units; bind temperature to a material bearer; normalize Celsius offsets with exact decimal arithmetic; preserve magnitude sign and runtime independently; add comparisons; only then review hot/cold with an explicit contextual standard. Temperature points and temperature differences must not share the same affine conversion rule. Spatially nonuniform objects and metaphorical temperature require separate interpretation. No thermal adjective or additional root is approved by this plan.

Before adding a unit, test the entire published unit range. The strict inverse previously enumerated codes from zero while the encoder used one through thirteen, so byte was missing and unused zero was admitted. The corrected inverse retains the existing unit sounds and now tests all thirteen units in each runtime state, plus rejection of zero and the next unassigned code. Those tests establish musical token recovery, not the semantic validity of arbitrary predicate/unit pairings.


The first temperature step is now implemented in `temperature_measurement.md`: kelvin code 14, temperature-point sentences, exact Celsius offsets and scalar bounds. The unit/runtime matrix now covers fourteen units. Entity comparisons and contextual adjective standards remain next; temperature differences still require a distinct interval conversion route.
