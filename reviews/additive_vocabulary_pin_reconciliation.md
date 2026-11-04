# Additive vocabulary preservation reconciliation

The consolidated run at 45be376 reported 108/117 passing. All nine failing
checks have now been rerun successfully after reconciling their source records.
The historical failed report remains intact; this is targeted follow-up evidence,
not a claim that the entire consolidated suite has been rerun.

Six support/custody/carrying tests excluded later compounds using growing literal
lists. Recovering the historical dictionaries from Git proved that their original
35, 36, 39, 40, 41 and 42-entry sets still match the recorded migration fingerprints
and current definitions exactly. The migrations now record those IDs and their
source revisions. Tests select the historical IDs and retain the original hashes.
Missing or changed historical definitions still fail. Delivery and transfer were
introduced in one commit; the delivery baseline is that commit's dictionary with
only the delivery addition removed, verified against the original hash.

Three validators still pinned the 50-compound / 458-sense source snapshot at
9f5ffa0821730e44d84a16b6bdf23e3712db4a90. Every entry in that snapshot remains
exactly unchanged. The added two felt-condition and three swimming entries are
recorded separately in the additive-vocabulary migration. Only source fingerprint
metadata changed in the IR, renderer, controlled/general English, presentation
and product specifications. The renderer matrix now expects 165 compound/state
cases (55 compounds, three runtime states); its existing root, marker, head-state
and decode checks pass for all of them.

Validation: all six affected JavaScript tests pass, including their Ruby/MIDI
comparisons; semantic IR 14 checks, controlled English 13 and renderer/decoder 12
pass. Downstream general English 16, glyph/audio 10 and product 16 also pass.
The new migration test has 12 assertions, including altered/missing baseline
rejection. No new root or meaning was introduced during this reconciliation.

Full ordinary-English coverage, source reconciliation across all storage,
held-out listening, live UI validation and release completion remain open.
