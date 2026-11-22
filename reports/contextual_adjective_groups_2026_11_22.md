# Recovering related physical descriptions from music

The translator already rendered groups of physical contextual adjectives, but its independent decoder only understood one such description at a time. The new inverse recovers two through eight descriptions joined by sequence, conjunction, inclusive or, exclusive or, or a condition. For example, **The gate is wide and the board is hot** now has a verified whole-message result. The existing group music is unchanged.

Each member retains its bearer, physical dimension, local comparison standard, runtime 0/1/2, and ordered scopes. The group retains its relationship, outer scopes, and final speech act. A conditional's members are proposition contents, not two separately asserted facts. The decoder reads only the exported musical performance and the public dictionary/grammar; it receives no original sentence, source meaning graph, or expected answer.

The result heading now shows the interpreted sentence. Longer technical explanations remain available under **Meaning details**. Choice controls have explicit accessible names, and heading text wraps on narrow screens. This fixes the clipped multi-clause result observed during browser verification.

## Evidence

- The clean implementation revision `7a10e0cbcb61bd57ba08c732e8e81dbdcc9fbd9a` passes **271 regression checks**, including the new inverse tests.
- All **eight release gates** pass at that same implementation revision.
- **30 group contrasts** cover five relationships, all three runtime endings, and negation. Both melody and compact chords independently recover their meanings. Frozen hashes confirm those 30 earlier group performances are unchanged.
- Additional checks cover bearer order, time, outer negation, questions, three clauses, mixed width/temperature, and rejection of damaged boundaries, incorrect material heads, missing separators, and unsupported predicates. The width regression retains its **48 unchanged earlier adjective sounds**.
- Browser checks pass **18 layouts**, **12 independently decoded exports**, and **six explicit choices about “or”**. Compact exports contain simultaneous notes and are shorter than the corresponding melodies. The actual heading bounds fit 320-, 390-, and 768-pixel screens; explanations, stale-input clearing, and song controls work.

The [evidence directory](contextual_adjective_groups_2026_11_22/) records the tested sources and outputs. Browser checks use Chromium viewport emulation, not physical iOS/Safari. Initial browser inspection exposed missing accessible choice names and an oversized technical heading; the released implementation fixes both.

The release is deployed through PR 25 in both repositories. Each public site passes the same 18 layouts, 12 independently decoded exports and six explicit alternative choices. Lore's integrated catalog build and 251 tests also pass; live and integration records are retained with this report.

## Remaining boundaries

This inverse supports contextual physical adjectives, without nested groups or a mixture of other predicate profiles. It does not add numeric widths, degree, comparative width, figurative senses, or arbitrary English constructions. Each comparison standard is local; identical reference sounds alone do not prove identity in the outside world. Unsupported messages must still remain visibly unsupported.

This release adds no atoms, compounds, convention codes, or musical formats. The inventory remains **324 roots, 117 compounds, and 589 English senses**. General recorded-audio or speaker-to-microphone decoding has not been demonstrated by these MIDI checks. The broader translator remains unfinished.
