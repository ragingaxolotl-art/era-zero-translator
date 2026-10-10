# Gate 4B High-Frequency Compound Design Review

Status: **APPROVED — BOUNDED INITIAL DICTIONARY RELEASE**  
Version: **1.0.0**  
Approved entries: **28**

## Design decision

This release treats frequency as a prioritization signal, not permission to imitate English lexicalization. Every approved entry has one explicit semantic head and at least one independently canonical restriction. English labels are discovery metadata only. Reversing the head or collapsing the graph to one atom was evaluated and rejected for every entry in the scored-candidate record.

The release is intentionally conservative: it approves concrete cross-family distinctions that the present atoms support, including artifacts, bodies, messages, programs, repair domains, data networks, and formal world relations. It does not pretend that the lexicon already encodes chemical substances, nutrition, habitation, possession, friendship, or execution events.

## Approval standard

An entry was admitted only when it passed atomic-collision, head-selection, graph-connectivity, cross-family-separation, runtime-separation, everyday-usefulness, and technical-usefulness review. A common English expression was rejected or deferred when its meaning required an absent atom, a culture-specific convention, or multiple occurrence-level assertions.

## Entry summary

| Title | Head root | Components | Confidence |
|---|---|---|---|
| material artifact | CRE:010 | MAT:010 + CRE:010 | high |
| composite artifact | CRE:010 | STR:020 + CRE:010 | high |
| physical tool | CRE:010 | MAT:200 + CRE:010 | high |
| machine | CRE:010 | STR:020 + MAT:200 + CRE:010 | high |
| dormant machine | CRE:012 | STR:022 + MAT:202 + CRE:012 | high |
| material route | MOV:020 | MAT:020 + MOV:020 | high |
| living body | MAT:000 | LIF:010 + MAT:000 | high |
| dormant living body | MAT:002 | LIF:012 + MAT:002 | high |
| material biosystem | LIF:220 | MAT:020 + LIF:220 | high |
| generated living being | LIF:010 | CRE:010 + LIF:010 | high |
| living communication network | CON:021 | LIF:221 + CON:021 | high |
| message datum | DAT:000 | CON:020 + DAT:000 | high |
| addressed message | DAT:010 | CON:010 + DAT:010 | high |
| shared message collection | DAT:020 | CON:020 + DAT:020 | high |
| program definition | CRE:000 | DAT:000 + LOG:010 + CRE:000 | high |
| dormant program | CRE:002 | DAT:002 + LOG:012 + CRE:002 | high |
| shared knowledge base | DAT:020 | MIN:020 + DAT:020 | high |
| data transfer channel | DAT:210 | CON:020 + DAT:210 | high |
| synchronized data network | DAT:220 | CON:220 + DAT:220 | high |
| physical injury | WRN:000 | MAT:000 + WRN:000 | high |
| material hazard | WRN:010 | MAT:010 + WRN:010 | high |
| physical repair | REP:110 | MAT:110 + REP:110 | high |
| data repair | REP:100 | DAT:100 + REP:100 | high |
| structural repair | REP:100 | STR:100 + REP:100 | high |
| backup dataset | DAT:022 | REP:220 + DAT:022 | high |
| shared-world law | ORI:220 | LOG:020 + ORI:220 | high |
| formal ontological dependence | ORI:210 | LOG:010 + ORI:210 | high |
| directed data link | CON:210 | DAT:000 + slot:source + slot:target + CON:210 | high |

## Concepts deliberately not approved as compounds

- **person** and core motion entities remain atomic or discourse-level; duplicating them would reduce precision.
- **water**, **food**, and **shelter** remain vocabulary gaps because the necessary phase/composition, nutrition, and protection distinctions do not exist atomically.
- **home** is deferred to Gate 4C sense analysis because its English senses divide across structure, habitual location, social bond, possession, and affect.
- **run a program**, **send a message**, and **transport** require occurrence roles and belong in semantic IR rather than one lexical compound.

## Boundary

Gate 4B does not create an English concept index, etymology layer, semantic IR, grammar implementation, renderer, decoder, or translator. Labels in this packet are not yet general-English mappings. Gate 4C is next.
