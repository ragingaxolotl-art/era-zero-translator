# Receipt and possession before delivery

Status: dependency review, not a canonical new meaning. Reviewed against the root
definitions and the original 37 compound invariants in `reports/foundation_inventory_audit.json`,
plus the current role specification and carrying/support definitions. No dictionary
entry, root, musical code or automatic English mapping changes here.

## Distinctions the translator must retain

Spatial arrival, physical support, practical custody, ownership, acceptance and
benefit are separate commitments. Carrying a box to a person may identify that
person's contextual location without stating that the person receives the box.
Receiving a loan need not confer ownership; owning a box need not mean physically
holding it; a box reaching a doorstep need not establish accepted receipt. These
counterexamples define the intended scope of this review rather than supplying a
universal default interpretation of the English word “deliver”.

## Existing candidates and their limits

| Candidate | Established meaning | Missing commitment / counterexample |
|---|---|---|
| MOV:110 | Completed displacement to a target position | A box arrives beside Ada while Pip retains it. No custody transfer follows. |
| MOV:210 / MOV:211 | Established / maintained positional relation | Proximity and positional tracking do not establish holding, access or ownership. |
| MAT:211 | Current physical influence on a distinct target | A fan affects a box without possessing it. |
| Physical support CMP:eef9fff8ac6618ce60927f18 | Load-bearing material influence | A shared table supports a visitor's box; support alone does not identify the custodian or owner. |
| Physical carrying CMP:7a6749aaf61cd6181e544bd6 | Conveyance through support of the same moving load | A carrier can move an owner's box without ownership changing or anyone receiving it. |
| STR:110 / STR:211 | Incorporation into a structure / qualification for incorporation | A constituent relation does not establish custody or entitlement. A loan need not incorporate its object into the borrower. |
| DAT:110 | Completed information transfer | A recipient can receive information about a box without receiving the physical box. Material qualification must not erase the information invariant. |
| CON:110 | Uptake of a communicative expression | Acknowledging a delivery message is not receipt of its object. |
| LIF:211 | Protecting, supporting, nurturing or sustaining another being | Care does not entail a possession transfer, and transfer can occur without care. |
| LOG target constraints | Formal admissibility under a specified criterion | A criterion could encode an ownership rule, but no existing root specifies that criterion or its rights. A noun label must not smuggle it in. |
| ORI target dependence | Obtaining conditional on a specified ground | Dependence alone supplies neither custody nor rights; the specified ground cannot remain unstated. |
| IR recipient role | Receiving possession or benefit rather than merely being a target | This groups distinct relations. Applying the role to a motion predicate cannot manufacture transfer, identify what changed, or choose possession over benefit. |

The remaining reviewed compounds concern artifacts, living systems, communication,
data, repair, sensory registration, hazards and approved poetic love; none has a
receipt/custody invariant. This inventory check rules out direct reuse of those
definitions as synonyms. It is not a proof that no possible existing-root graph
could define the needed relation.

## Dependency order and implementation obligations

1. Spatial carrying-to-endpoint composition now uses the reviewed arrival
   foundation in the 39-compound draft. Preserve it without any recipient
   assertion; see [destination carrying](destination_carrying.md).
2. Define practical custody separately from ownership. A proposed convention must
   specify the holder, the held object, the contextual access/control criterion,
   and exclusions. Physical touch or support alone is insufficient. Assess an
   existing-root construction before adopting a conventional additional meaning.
3. Define a transfer with explicit before/after custody and shared object identity.
   Do not require an exclusive owner, conscious recipient or willing acceptance
   unless the selected sense actually includes those commitments.
4. Build physical handover and other delivery senses on those foundations. Name
   each additional commitment, bind event identity, and version dependencies.
5. Keep ownership, entitlement, acceptance and beneficiary readings separate.
   User selection can resolve “to Ada”; it cannot substitute for implementing the
   selected meaning in the semantic graph and performance output.

Required contrasts include arrival-without-receipt, receipt-without-ownership,
support-without-custody, information-receipt-versus-object-receipt, and a change of
recipient with the same object. Test them under negation, questions, ongoing and
completed readings, and each runtime 0/1/2. Independent musical observation must
recover the distinguishing relation and participant bindings, not merely produce
different hashes. Do not count a clarification prompt as completed translation.

Current classification: arrival is an existing root plus sentence grammar;
carrying-to-endpoint now has reviewed event compounds and bounded sentence
composition; practical physical custody now has an explicit conventional foundation;
transfer and receipt remain unresolved event definitions. This review does not justify adding a 27-root family or
redefining an existing root. An explicitly reviewed conventional compound remains
an option if the additional meaning is documented and audibly represented.

## Source correction discovered during custody design

At the 39-compound revision, no custody invariant was present. The subsequent
[practical physical custody foundation](physical_custody_foundation.md) adds that
relation in the 40-compound draft; transfer and receipt remain separate. A follow-up check
found MAT:210's normal example retained an ownership claim excluded by its applied
semantic approval. The [MAT source reconciliation](mat_capacity_source_reconciliation.md)
corrects nine related examples without changing root definitions or sounds.
Its review also checks the CON domain pointer: current communicative meanings do
not supply ownership or material receipt. Do not build a custody alias from the
old example or treat the pointer as a missing definition already implemented.
