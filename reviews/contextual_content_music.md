# Contextual content musical prerequisite (draft)

The translator needs to distinguish a named entity from content associated with
that entity before admitting broader cognitive predicates. This draft provides
four standalone musical selectors, not translations of complete cognitive sentences:

- `topic`: the entity about which information is sought; no question or answer supplied.
- `communicated_content`: contextually selected meaning conveyed by the anchor;
  no communication event or truth asserted by this selector.
- `reasons`: contextual explanatory reasons concerning the anchor's conduct or state;
  no particular explanation invented.
- `perspective`: contextual experiences or standpoint associated with the anchor;
  no empathy or grasp asserted.

Open/close paths are `[0,-34,code,0]` and `[0,34,code,0]`, with codes 0–3 in
that order. Existing name, nominal-reference, and discourse-reference sounds are
preserved. A neutral final contour terminates this standalone stream; the wrapper
explicitly carries no assertion commitment. No root or canonical compound is added.

The inverse reads MIDI and the shared atom dictionary, without source English or
expected IR. It requires exactly one selector containing one middle-register named,
definite, proximal, distal, speaker, or addressee reference. Counted references,
classes, lexical predicates, extra content, mismatched closures, and direct-question
termination are rejected. The standard decoder rejects these draft frames by default.

Validation: 72 selector/reference/anchor combinations at anchors 48, 60, 72;
all 24 kind/reference combinations have distinct MIDI at each anchor. Frame
collision checks include ordinary, quantified, polar-content, and acquisition
inventories. These are structural musical tests, not listening judgments.

The `EZCONTEXTUAL-CONTENT-1` document now validates exact fields, full encoded
name data, reference mode and identity, local contextual resolution, and no
assertion commitment. Its content digest covers that entire contract. The reference
constructor accepts named/quoted labels, supported definite/this/that nominals,
and I/me/you; unresolved pronouns, counts and unsupported modifiers are rejected.
Twenty-eight document-to-MIDI cases pass, with rehashed corruption counterexamples.
Documents render through the existing lexical reference renderer.

Remaining: Ruby parity, cognitive binding contracts, English interpretation choices, UI integration,
and listening checks. Selection is local-context-dependent and does not identify
which of several messages/reasons/perspectives is intended. Names recover phonemes,
not external identities. Existing polar-answer knowledge remains polar-only.
