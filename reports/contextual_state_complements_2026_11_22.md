# Existing physical adjectives with keep, stay and remain

**Nora keeps the box cold**, **the box stays heavy**, and **the gate remains wide** now use the existing state-complement grammar. Previously that grammar explicitly excluded the contextual physical properties already supported inside noun phrases. Removing that restriction lets the ten established norms—hot/cold, heavy/light, bright/dim, rough/smooth and wide/narrow—supply the specified state of the existing keep/stay/remain meanings.

The meanings and music are reused. Stay/remain means that the specified quality continues through the relevant interval; keep adds causal maintenance. The condition's numbered bearer is the same participant as the event's bearer. A noun description stays separate: **the heavy robot kept the light box cold** preserves the robot's mass, the box's mass and the maintained temperature as three distinct attachments. No exact measurement, threshold, interval length or shared standard across different occurrences is inferred.

The encoder and inverse already support this existing property frame in the state slot. This release changes the sentence parser, not those music routines. There is no new root, compound, norm code or music marker. The root inventory, compound dictionary, English sense index, browser authority and existing pronunciations are byte-for-byte unchanged. The inventory remains 324 roots, 122 compounds and 599 English senses. See the [updated property specification](../spec/story_contextual_properties_1.0.yaml).

Physical-dimension choices remain explicit. **Light** can select the low-mass meaning; it does not silently mean illumination. A saved adjective named **cold** still offers its saved definition separately from the published temperature meaning. Pronouns preserve identity after any necessary referent choice; they do not reassert earlier descriptions or require gender.

## Evidence

Clean revision `328a3808cf2fb6b5763bc26ed85b37b2353115da` passes **279 implementation regression checks** and all **eight release gates**. The focused suite passes **131 paired message checks**, including **18 frozen earlier readings whose melody and compact-chord bytes remain identical**. It covers all ten norms with keep/stay/remain and runtime 0/1/2, inflections, ordered scope, commands, questions, conditions, before relationships, noun descriptions, references and saved-word homonyms. Seven separately constructed malformed condition scores are rejected, including incorrect bearer binding, root, runtime and added internal scope or content.

Both local sites pass **21 sentence layouts, 14 independently decoded exports, six rejected alternate readings, nine unsupported-construction checks and three keyboard disclosures** at 320/390/768-pixel Chromium viewports. Actual compact-chord downloads contain simultaneous notes and shorten these seven complete messages by **18.3–21.6%**, median **19.6%**. The score decoder receives neither the original English nor the source meaning. Lore's catalog build and **275 integration tests** pass.

Two initial test-fixture assumptions were corrected: the displayed label says “temperature,” and **Nora kept the box cold. It stayed heavy** correctly asks which participant “it” refers to. The final test explicitly checks that question and supplies the box choice; no referent-guessing behavior was added. The initial failures and corrected results are retained in [the evidence directory](contextual_state_complements_2026_11_22/).

## Remaining boundaries

This extends supported story state complements. It does not supply degree, comparisons, measurements, explicit durations, multiple maintained qualities, passive/perfect constructions or unrestricted English interpretation. Choosing an unimplemented sense leaves the message unresolved. The existing keyboard-accessible Meaning details disclosure still exposes the full explanation with Play and Add to song outside it.

These are independent MIDI and browser checks, not evidence of general microphone recovery or physical iOS/Safari behavior. Public deployment and live verification follow the local checks. The [broader completion plan](../docs/full-translator-next-steps.md) remains open.
