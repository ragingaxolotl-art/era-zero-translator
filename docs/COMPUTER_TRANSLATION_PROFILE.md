# Computer and Software Translation Profile

Status: implemented surface profile; canonical semantic authority unchanged.

This profile adds conservative English handling for common file and software
dialogue. It does not create roots or redefine approved atoms.

## Directly playable mappings

| English context | Era Zero route | Preserved meaning |
|---|---|---|
| file / files | `DAT:000` | persistent bounded information object |
| folder / directory | `STR:020` | persistent composite arrangement |
| inside a folder | `STR:001` | occupied internal structural position |
| need / require | `ORI:211` | operative dependence |
| migrate / need to migrate | `DAT:112` | pending target data transfer |
| migrating / being migrated | `DAT:111` | active target data transfer |
| migrated | `DAT:110` | completed target data transfer |

Migration is generalized. These roots do not by themselves claim schema
conversion, verification, cutover, source deletion, or synchronization among
multiple peers. Those details require additional clause structure or compounds.

## Recognized structural meanings

`use` is recognized as an instrumental relation. The action and purpose must be
known before it can be rendered truthfully. “I used the file” therefore does not
silently become “I executed,” “I read,” or “I changed the file.”

`delete`, `deleting`, and `deleted` are recognized as requested, active, and
completed deletion operations. They intentionally do not point to a canonical
root. The current language has no atom whose invariant means removal of retained
information. In particular:

- a deleted file is not a dormant `DAT:002` datum;
- deletion is not `STR:101` internal reconfiguration;
- deletion does not satisfy `DAT:100–102`, which require transformed
  information rather than its removal.

The translator shows these as structural routes instead of falling back to
phonemic noun sounds or inventing a false translation.

## Tested phrases

- “I used the file.”
- “Delete the file.”
- “The files are being deleted.”
- “The files were deleted.”
- “We need to migrate.”
- “The files are migrating.”
- “We migrated the files.”

The three migration phrases must select `DAT:112`, `DAT:111`, and `DAT:110`
respectively. Deletion and generic use must remain structural and must never
auto-resolve to an unrelated atom.
