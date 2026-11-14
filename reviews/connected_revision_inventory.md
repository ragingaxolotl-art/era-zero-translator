# Connected source revision inventory

All 21 revisions currently exposed by the Drive connector for **DBA ERA 0
Language** were fetched as text. Initial parallel reads hit HTTP 429; subsequent
sequential reads recovered the remaining revisions. The local capture directory
is `/private/tmp/dba-source-revisions`. Raw author/contact metadata and unrelated
search hits are not included in the repository report. Full document snapshots
remain local; the report stores normalized-content hashes and revision metadata.

`tools/audit_connected_revision_snapshots.py` produces
`reports/connected_revision_inventory.json` from those captures. It records the
normalization used, visible revision IDs, first observed approval/withdrawal
markers and definition correspondence against the current 324-root inventory.

The early complete-catalogue assertion and its later withdrawal coexist in the
compiled document. The withdrawal first appears in visible revision 11; selective
MOV:100–122 approval appears in revision 13; the delegated 81-root update appears
in revision 18. These are first observations in the available snapshots, not proof
of original authorship or exact decision times. Later revisions continue the
selective approvals, compound architecture and product/release notes. Historical
stop boundaries describe historical states; they do not replace current user
instructions to complete the translator.

Current definition comparison with revision 68:

- 287 definitions occur after whitespace normalization.
- 28 more occur after straight/curly apostrophe normalization.
- Nine MOV:200–222 definitions are absent verbatim. Google records this packet's
  approval by reference in the 81-root update. Each current definition matches
  both the repository recommendation and applied approval migration exactly.

Thus the initial 37 wording mismatches do not establish 37 semantic conflicts.
Text presence alone is also insufficient to prove authority: the document retains
superseded material. The report separates verbatim/typographic correspondence from
the nine approvals verified by reference. No root definition was changed.

Fresh bounded Drive searches for DBA and Era Zero found the known language file
and related project documents. The Pages search found the existing audit at
sequence 11, along with unrelated results; it is not an enumeration of private
ChatGPT conversations. These searches do not prove the absence of additional files.

The compiled snapshots repeat the original 313-node/129-visible-turn source claim
and historical hash. They do not supply a recovered original turn ledger with an
independently verified matching hash. That missing source, broader cross-storage
reconciliation and all translator completion gates remain open. This audit closes
the previously sampled revision-read gap for this one document only.
