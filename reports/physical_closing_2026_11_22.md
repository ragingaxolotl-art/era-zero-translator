# Physical closing, caused closing and clearer passage results

**The gate was closed**, **the gate closed**, and **Nora closed the gate** now retain three distinct meanings: the existing state, the transition into that state, and a cause bringing about that transition. Close/closes/closed/closing and shut/shuts/shut/shutting work through reusable story grammar rather than a dictionary entry for each sentence.

The dependency order is deliberate. The transition `CMP:9a954f78879ed70ce262bdc5` (convention 88) reuses the exact earlier closed state and actualization. Caused closing `CMP:3019a12938289fa9f3a23237` (convention 89) reuses that complete transition and causal contribution. The same physical closure is bound throughout; a cause must be distinct from its bearer. Neither meaning implies locking, sealing, security, intention, a hand or a lasting result. Progressive aspect does not assert a completed endpoint. See the [author review](../reviews/physical_closing_2026_11_22.md) and [definition batch](../lexicon/physical_closing_batch_2026_11_22.json). This review is not independent linguistic validation or separate user approval of each definition.

The existing closed-state sounds remain unchanged. The inventory is now 324 roots, 122 compounds and 599 English senses. No root or musical framing convention is replaced.

## Ordinary sentence behavior

- **We need to close the gate** preserves necessity; **Nora might not shut the gate** preserves the ordered uncertainty and negation scopes.
- **We shut the gate** asks whether this is present or past. Explicit tense, questions and commands use their expressed time. Runtime 0/1/2 stays independent of tense and aspect.
- **Nora closed the wide gate** retains the physical width on the correct participant after a focused dimension choice. Established private descriptions remain supported.
- **The gate was open before Nora closed it** preserves both events, their order and the shared gate. **Nora closed the open gate** still needs its before/after phase made explicit; the translator explains that boundary instead of selecting a phase.
- A window, file, meeting or other ambiguous label requires a physical-closure interpretation. Choosing another meaning leaves the sentence unresolved. This does not add software, business or figurative closing.

Story passage results now show the original sentence and a collapsed, keyboard-accessible **Meaning details** explanation. Readiness, Play and Add to song remain outside the disclosure. This presentation change does not alter the interpreted graph or music.

## Verification

The clean core revision `becf3069e34798bd0a2d8a48ee424d11d1d7c0e4` passes **278 implementation regression checks**. The subsequent presentation revision `5fbadc00c9f7e85dc95e3beb6ba11c8943be32a9` passes all **eight release gates**. The small disclosure change is verified separately in the browser; it was not part of the earlier clean core regression run. Lore's catalog build and **270 integration tests** pass, including the final disclosure implementation.

The focused suite covers **131 independently decoded melody/chord message pairs**, all three runtime states, state/event and caused/uncaused contrasts, supported roles and scopes, questions, commands, pronouns, conditions, private descriptions and deliberate invalid-score cases. It preserves **715 earlier dictionary and sense records** and **12 frozen closed-state performances**. Decoder checks reject missing or aliased roles, corrupt nested sounds and unsupported phase attachment.

The initial registration check found that the two new compounds lacked canonical controlled-label discovery routes. Running the additive compound-release rebuild supplied those routes while preserving the prior records; the corrected Pages check passes 13,000 assertions with 6,255 canonical variants. The initial failure and corrected evidence are retained. A browser helper also initially required `cause=Nora` without the spaces present in the displayed explanation; the corrected helper accepts whitespace while still checking Nora's exact role and the width interpretation.

Both local sites pass **27 sentence layouts, 18 independently decoded exports, nine rejected alternate readings, 12 unsupported-construction checks and three keyboard disclosure checks** at 320/390/768-pixel Chromium viewports. Enter opens Meaning details and Space closes it, with the cause and physical-width explanation retained and the actions outside the disclosure. For the nine exported messages, compact chords contain simultaneous notes and shorten the full message by **19.7–24.0%**, median **21.9%**.

Local browser evidence is recorded in [the evidence directory](physical_closing_2026_11_22/); public deployment and checks are a subsequent release step. The preceding modifier release's public checks are also retained in its [primary](contextual_modifiers_2026_11_22/live-primary.json) and [Lore](contextual_modifiers_2026_11_22/live-lore.json) reports. These tests inspect actual exported MIDI without supplying the original English or source meaning to the decoder. They do not establish general recorded-audio recovery, physical iOS/Safari behavior or unrestricted English coverage.

## Still open

Passive/perfect event grammar, instruments and other complements, additional changing-state phases, software and figurative senses, and broader ordinary-English constructions remain open. The existing standalone closed-state interpretation does not become an implied passive event. Future work should reuse these meanings where they fit and leave unsupported readings explicit. The [completion plan](../docs/full-translator-next-steps.md) remains open.
