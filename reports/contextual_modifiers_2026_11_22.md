# Existing physical adjectives inside complete story sentences

**Nora lifted the wide board**, **the heavy robot lifted the light board**, and **Nora placed the narrow box at the wide gate** now retain the descriptions on the correct participants. This extends the supported story noun-phrase grammar using the existing ten physical norms: hot/cold, heavy/light, bright/dim, rough/smooth and wide/narrow. It adds no root, compound, dimension, norm code or musical marker.

The existing contextual-adjective frame is nested in the existing story-property frame. Its bearer refers to the same numbered participant as the enclosing argument. The score decoder validates that binding, the exact material-state head and its ending, and the absence of extra internal scope. Subjects, objects, alternatives and placement destinations retain their own descriptions. A later pronoun preserves identity without reasserting prior qualities. See the [profile specification](../spec/story_contextual_properties_1.0.yaml).

The user chooses the physical dimension in ordinary language. **Light** here means low mass relative to a local standard; it does not mean illumination. **Wide** describes physical width, not whether something can pass through an opening. A private adjective with the same label still offers the published/saved meaning choice. Choosing another meaning leaves the sentence unresolved.

## Evidence

- Clean runtime/test revision `765f4627fd45da5ec0deff86accda79b0b9392b6` passes **276 regression checks** and all **eight release gates**. Subsequent integration adds the preceding release evidence and this documentation; runtime code is unchanged.
- **105 independently decoded message variations** cover all ten norms, runtime 0/1/2, subject/object/destination binding, scope, commands, questions, clause relationships, alternatives, repeated nouns, pronouns, mixed canonical/private qualities and saved-word homonyms. Seven deliberately malformed scores are rejected, including a mismatched bearer, wrong root/runtime and added scope/content.
- **90 earlier performances** retain their hashes: 48 original contextual-adjective sounds, 30 adjective-group sounds and 12 empty/full state sounds. The established state/private-adjective regression also passes.
- Both local sites pass **21 layouts, 14 independently decoded exports, six rejected alternate readings and nine unsupported-construction checks** at 320/390/768-pixel Chromium viewports. The exported compact arrangements contain simultaneous notes and reduce complete-message duration by **15.7–21.0%**, median **18.9%**, for these seven messages.
- Lore's catalog build and **265 integration tests** pass, including separate assertions about the intended verb, scope, runtime and participant attachment. Navigation, private saves, backups and stored song arrangements remain integrated.

The first browser helper incorrectly waited for another meaning question while the asynchronous whole-sentence score was being prepared. The helper now waits for either the next real question or the ready action. The complete corrected browser runs pass; the initial timeout is retained alongside the evidence. No product behavior was relaxed to satisfy the helper. Evidence is in [the report directory](contextual_modifiers_2026_11_22/).

## Remaining boundaries

This is supported story grammar, not a universal modifier parser for every sentence profile. Degree, measurements, comparative adjectives, contextual keep/stay complements and passive/perfect constructions remain open. Unspecified before/after phases for changing full/empty descriptions remain explicit failures with guidance. Physical-dimension choices do not establish figurative meanings. No numeric threshold or equal standard across different occurrences is inferred.

These checks independently decode actual MIDI exports without the original English or source meaning. They do not establish general recorded-audio recovery, physical iOS/Safari behavior or unrestricted English translation. The broader completion plan remains open.

Subsequent implementation: the [contextual state-complement extension](contextual_state_complements_2026_11_22.md) now supports keep/stay/remain with these same ten norms. The boundaries above describe this earlier modifier release; degree, measurement, comparisons and broader sentence profiles remain open.
