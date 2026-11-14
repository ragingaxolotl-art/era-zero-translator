# Explicit scoped slots in controlled text

The local controlled compiler now accepts exact JSON-array paths into a compound's
versioned expansion. This prevents two different nested `source` roles from being
silently merged. Ordinary sentence composition already supplies these bindings;
the extension makes the same meaning available through controlled input.

```text
ASSERT "completed transfer of physical custody" [1]
 SLOT ["q-prior","s-source"] "identified other" [0]
 SLOT ["q-prior","s-target"] "distinct material object" [2]
 SLOT ["h","q-custody","s-source"] "continuous self" [1]
 SLOT ["h","q-custody","s-target"] REF ["q-prior","s-target"].
```

The first holder, object and second holder remain distinct entity occurrences.
The backward REF binds the second object slot to the exact earlier object, with
its independent runtime 2. It does not infer identity from repeated labels.
JSON arrays preserve local IDs as individual components rather than splitting
on punctuation. Paths contain 1–64 nonempty strings and must exist in the exact
expanded definition. Each slot must be bound once; all same/distinct constraints
must hold. Missing, duplicate, unknown, forward and inconsistent bindings return
structured errors without partial IR. SLOT and ROLE cannot be mixed in this
simple template; existing unambiguous ROLE syntax is unchanged.

The exhaustive controlled-label validator now supplies explicit paths for slotted
compounds, with one synthetic argument per declared identity class. It still
compiles and round-trips every allowed label; the nested entries are not exempted.
The renderer and dictionary musical-identity audits likewise use scoped identity
classes instead of assuming a role name uniquely selects a participant.

`tests/controlled_scoped_slot_test.mjs` exercises transfer and delivery through
assertion, question and command, with outer states 0/1/2 and independently stated
participant states. All 18 performances match browser rendering and MIDI-only
semantic projections. Twelve invalid constructions are rejected. This is local
controlled-text support and browser rendering parity, not a claim that the
browser's controlled text parser supports arbitrary nested SLOT input.
