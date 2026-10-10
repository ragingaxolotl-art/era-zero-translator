# MOV:100–122 Adversarial Semantic Peer Review

Status: **RECOMMENDATION PENDING USER APPROVAL — NOT CANONICAL**

This review treats every Phase 2 meaning as replaceable. Scores are comparative peer-review judgments, not mathematical proofs. Each of eight categories is scored 1–10 with equal weight, for a maximum of 80.

## Scoring categories

- **Atomicity:** one permanent semantic center.
- **Address Fit:** exact fit to process, orientation, and lexical phase.
- **Family Fit:** belongs in Motion more than another family.
- **Neighbor Separation:** remains distinct from adjacent Motion roots.
- **Cross-Family Separation:** avoids Matter, Mind, Connection, Structure, Data, Creation, and Origin collisions.
- **Compound Usefulness:** useful as a later building block.
- **Everyday Language Coverage:** natural ordinary-language value.
- **Technical Coverage:** useful in programs, mathematics, state machines, or formal graphs.

## Overall recommendation

| Root | Current Phase 2 direction | Recommended permanent title | Decision | Winning score |
|---|---|---|---|---:|
| MOV:100 | departure complete | completed source departure | survives with tighter invariant | 71/80 |
| MOV:101 | self-departure | active source departure | survives with tighter invariant | 73/80 |
| MOV:102 | departure readiness | pending source departure | replace current candidate | 75/80 |
| MOV:110 | arrival complete | completed target arrival | survives with tighter invariant | 77/80 |
| MOV:111 | destination approach | active target approach | survives with tighter invariant | 77/80 |
| MOV:112 | pending arrival | pending target approach | replace current candidate | 75/80 |
| MOV:120 | system transition complete | completed route traversal | replace current candidate | 76/80 |
| MOV:121 | system flow | active route traversal | replace current candidate | 77/80 |
| MOV:122 | pending system transition | pending route traversal | replace current candidate | 76/80 |

The source/target displacement framework survives. The major changes are:

- `MOV:102`: replace **departure readiness** with the event-centered **pending source departure**.
- `MOV:112`: replace outcome-framed **pending arrival** with **pending target approach**.
- `MOV:120–122`: replace generic system transition/flow with the Motion-specific **route traversal** triplet.

## MOV:100 — peer review

### Fixed generated form

| Field | Value |
|---|---|
| Universal slot | completed inward process |
| Transliteration | `gi·kam` |
| Compact root | `kam` |
| Formal carrier | `gi-ki-ma-ma` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 2, 2]` |

### Why the current meaning was probably chosen

The second trit's source reading naturally suggests motion away from an origin, while the third trit's completed value suggests the post-departure condition. It also creates an intuitive mirror with target-arrival MOV:110.

### Candidate comparison

| Candidate | Direction | Atom | Addr | Fam | Neigh | Cross | Comp | Daily | Tech | Total | Verdict |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| departure complete (current) | Source-relative displacement completed. | 8 | 9 | 10 | 9 | 9 | 9 | 9 | 8 | 71/80 | WINNER — Strong and ordinary, but the original wording mixes completion with a derived occupancy consequence. It survives if tightened to one invariant. |
| self-relocation completed | Generic self-caused displacement rather than source separation. | 7 | 6 | 9 | 4 | 8 | 8 | 9 | 9 | 60/80 | Technically useful but too broad: it consumes arrival and route traversal and wastes the second-trit contrast. |
| inward convergence completed | Centripetal motion toward the source/self. | 9 | 7 | 10 | 8 | 9 | 7 | 6 | 7 | 63/80 | A literal reading of inward, but it competes conceptually with target approach once the source is treated as the target and has weaker everyday coverage. |
| motion initiation completed | Source as the initial state of a motion operation. | 8 | 7 | 10 | 7 | 8 | 9 | 8 | 9 | 66/80 | Useful in control systems, but 'initial state' is a derived interpretation of source and the concept introduces rest/velocity semantics absent from the address. |
| source detachment completed | Relational separation or release. | 8 | 7 | 6 | 7 | 4 | 8 | 8 | 6 | 54/80 | Often accompanies departure, but attachment can end without displacement and belongs more naturally to Connection or Structure. |

### Recommendation

The current semantic direction survives, but only with a tighter permanent specification that removes incidental consequences and ambiguous wording.

### Recommended permanent semantic specification

- **Canonical title:** completed source departure
- **Invariant definition:** Completion of a mover's displacement away from a specified source position.
- **Semantic boundaries:** Owns only the completed phase of source-relative displacement. The source must be specified or recoverable from context.
- **Excluded meanings:** generic relocation; target arrival; detachment without displacement; permission to leave; movement cause or force; ontological disappearance.
- **Nearest neighboring roots:** MOV:101 active source departure; MOV:102 pending source departure; MOV:000 origin position; MOV:001 present position.
- **Why this address is correct:** First trit 1 selects a process. Second trit 0 anchors the process at its source. Third trit 0 selects completion. 'Completed source departure' is the minimal intersection of those three constraints.

#### Cross-family comparisons

- **MAT:** MAT supplies the moving body, payload, force, or launch mechanics; MOV:100 supplies only completed displacement from source.
- **MIN:** A decision to leave or loss of attention is mental change, not departure.
- **CON:** Ending contact or a channel is not departure unless displacement also occurs.
- **STR:** Exiting a container requires a boundary compound; removal without motion is structural.
- **DAT:** Deleting or sending a record from storage is Data unless positions and displacement are explicitly modeled.
- **CRE:** A thing ceasing to be generated is not departure.
- **ORI:** Ceasing to exist or leaving an ontological state belongs to Origin.

#### Runtime-state interpretation

- **[0]:** The claimed completed departure is false, invalidated, or unavailable as a fact.
- **[1]:** The source departure is validly complete.
- **[2]/num:** Whether the source departure completed is unresolved or awaiting confirmation.

The lexical third trit remains part of the root's permanent meaning. Runtime `[2]/num` changes the current assertion or execution status of that already-selected lexical root; it does not change the address into its third-trit-2 sibling.

#### Natural-language examples

- The train has left the station.
- The bird is no longer at the nest; its departure is complete.
- The cursor has left the initialization position.

#### Programming examples

- `assert MOV:100[1] with source=MOV:000 and postcondition separation(source,mover)>0`
- `emit MOV:100[2] when a remote departure completion awaits acknowledgment`

#### Future compound examples — reservations only

- exit a building: MOV:100 plus a later structural-boundary relation
- launch cargo: MOV:100 plus material payload and force roles
- return leg completed: MOV:100 relative to the return leg's source

These are decomposition sketches, not approved compound entries.

#### Notes for later Era evolution

Later eras may lexicalize depart, exit, launch, or withdraw, but their Era Zero decomposition must preserve the source-displacement invariant.

## MOV:101 — peer review

### Fixed generated form

| Field | Value |
|---|---|
| Universal slot | active inward process |
| Transliteration | `gi·kak` |
| Compact root | `kak` |
| Formal carrier | `gi-ki-ma-ki` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 2, 4]` |

### Why the current meaning was probably chosen

The active process at a source is most naturally interpreted as leaving. The original label 'self-departure' also tried to use the second trit's self reading while preserving a clear contrast with completed departure and readiness.

### Candidate comparison

| Candidate | Direction | Atom | Addr | Fam | Neigh | Cross | Comp | Daily | Tech | Total | Verdict |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| self-departure (current) | Ongoing source-relative displacement. | 9 | 9 | 10 | 9 | 9 | 9 | 10 | 8 | 73/80 | WINNER — The semantic center is strong, but 'own source or current position' is broader than necessary. A specified source is cleaner than the ambiguous word self. |
| active self-locomotion | Generic self-motion. | 7 | 7 | 10 | 4 | 8 | 10 | 10 | 10 | 66/80 | Excellent coverage but destroys the source/target/systemic partition by absorbing nearly all active Motion. |
| active inward convergence | Centripetal motion. | 9 | 7 | 10 | 8 | 9 | 7 | 7 | 8 | 65/80 | Motion-specific and atomic, but source-as-goal duplicates target approach and makes the orientation cube less orthogonal. |
| active motion initiation | Starting or accelerating into movement. | 7 | 7 | 8 | 7 | 6 | 8 | 8 | 9 | 60/80 | Control-system value is high, but it introduces velocity and force territory and does not cover ordinary departure after onset. |
| active disengagement | Withdrawal or disconnection. | 8 | 7 | 5 | 7 | 3 | 8 | 8 | 6 | 52/80 | Relation-breaking is not necessarily motion and collides heavily with Connection and Structure. |

### Recommendation

The current semantic direction survives, but only with a tighter permanent specification that removes incidental consequences and ambiguous wording.

### Recommended permanent semantic specification

- **Canonical title:** active source departure
- **Invariant definition:** Ongoing displacement of a mover away from a specified source position.
- **Semantic boundaries:** Owns motion presently increasing separation from a source. It does not specify destination, cause, manner, speed, or social meaning.
- **Excluded meanings:** generic motion without a source relation; decision or intention to leave; completed departure; target approach; disconnection without displacement; acceleration as such.
- **Nearest neighboring roots:** MOV:100 completed source departure; MOV:102 pending source departure; MOV:000 origin position; MOV:001 present position.
- **Why this address is correct:** First trit 1 makes this an event. Second trit 0 makes source separation the defining relation. Third trit 1 requires the event to be under way.

#### Cross-family comparisons

- **MAT:** Physical propulsion and force are MAT contributions; the displacement relation remains MOV.
- **MIN:** Thinking about leaving is not active departure.
- **CON:** Withdrawing from a conversation is CON unless the participant also moves.
- **STR:** A component can detach structurally without departing spatially.
- **DAT:** A read pointer leaving a buffer position uses MOV only if positions are explicitly modeled.
- **CRE:** Transformation away from a design state is CRE unless modeled as traversal.
- **ORI:** Leaving existence is ontological, not kinematic.

#### Runtime-state interpretation

- **[0]:** The active departure is not executing or the assertion is false.
- **[1]:** Separation from the source is currently increasing.
- **[2]/num:** The active departure operation is suspended, blocked, or unresolved; it remains lexically active rather than becoming MOV:102.

The lexical third trit remains part of the root's permanent meaning. Runtime `[2]/num` changes the current assertion or execution status of that already-selected lexical root; it does not change the address into its third-trit-2 sibling.

#### Natural-language examples

- I'm leaving the station now.
- The rover is rolling away from its dock.
- The process is leaving its initialization state along an explicit state path.

#### Programming examples

- `run MOV:101[1] while separation(actor,source) is monotonically increasing`
- `set MOV:101[2] when the departure operation is paused after motion began`

#### Future compound examples — reservations only

- withdraw from a group: MOV:101 plus Connection only if literal displacement occurs
- take off: MOV:101 plus later manner/medium semantics
- evacuate a room: MOV:101 plus a structural boundary and collective actor

These are decomposition sketches, not approved compound entries.

#### Notes for later Era evolution

Later vocabulary may shorten leave, depart, retreat, take off, or pull away, but the atomic root should remain manner-neutral.

## MOV:102 — peer review

### Fixed generated form

| Field | Value |
|---|---|
| Universal slot | pending inward process |
| Transliteration | `gi·kan` |
| Compact root | `kan` |
| Formal carrier | `gi-ki-ma-nu` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 2, 0]` |

### Why the current meaning was probably chosen

The pending third trit encouraged a pre-departure reading. 'Readiness' was likely chosen because it sounds natural before motion starts and mirrors completed and active departure without requiring a precise scheduling grammar.

### Candidate comparison

| Candidate | Direction | Atom | Addr | Fam | Neigh | Cross | Comp | Daily | Tech | Total | Verdict |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| departure readiness (current) | Readiness or capability before departure. | 6 | 7 | 9 | 8 | 7 | 7 | 8 | 6 | 58/80 | The definition mixes a process with preparation/capacity. A mover may be ready without any departure operation being specified. |
| pending source departure | A source-departure event in its lexical pre-onset phase. | 9 | 10 | 10 | 9 | 9 | 9 | 9 | 10 | 75/80 | WINNER — Preserves one process across the triplet and cleanly separates lexical pending phase from readiness, capacity, permission, and runtime suspension. |
| waiting at source | Non-motion or delay at the source. | 7 | 5 | 7 | 6 | 7 | 6 | 10 | 6 | 54/80 | Everyday useful but waiting does not entail a future departure and is primarily timing/aspect, not a Motion process. |
| latent self-mobility | Dormant motion capacity. | 8 | 5 | 10 | 4 | 8 | 7 | 7 | 8 | 57/80 | Belongs to the 2xx capacity layer; placing it at a 1xx address violates the first trit. |
| intended retreat | Goal/intention to withdraw. | 7 | 8 | 8 | 7 | 6 | 7 | 8 | 5 | 56/80 | Retreat adds threat and intention, colliding with Mind and Warning and narrowing ordinary departure. |

### Recommendation

Replace the current Phase 2 candidate with **pending source departure**. The winner is more atomic and better preserves the address cube.

### Recommended permanent semantic specification

- **Canonical title:** pending source departure
- **Invariant definition:** A specified displacement away from a source position that has not yet begun.
- **Semantic boundaries:** Owns a source-departure event represented before onset. The event must be specified; readiness, permission, probability, and clock time are independent.
- **Excluded meanings:** mere readiness or capability; waiting without a departure plan; permission to leave; active or completed motion; dormant route; suspended active departure.
- **Nearest neighboring roots:** MOV:100 completed source departure; MOV:101 active source departure; MOV:002 retained position; future MOV 2xx mobility capacity.
- **Why this address is correct:** First trit 1 demands a process, eliminating readiness as a capacity. Second trit 0 fixes source orientation. Third trit 2 fixes a specified but unbegun phase.

#### Cross-family comparisons

- **MAT:** Fuel, force, and mechanical readiness are MAT conditions, not the pending event.
- **MIN:** Intent or decision may motivate the event but does not constitute it.
- **CON:** Clearance or permission is a communicative/logical relation.
- **STR:** A closed gate can block the event but is not its meaning.
- **DAT:** A scheduler record may represent the event; it is not the event.
- **CRE:** A planned transformation belongs to Creation, not source departure.
- **ORI:** Future time or possibility status must be supplied separately.

#### Runtime-state interpretation

- **[0]:** The pending departure is canceled, invalid, or unavailable.
- **[1]:** The pending departure is a valid queued operation.
- **[2]/num:** The pending operation itself is tentative, dormant, or awaiting confirmation.

The lexical third trit remains part of the root's permanent meaning. Runtime `[2]/num` changes the current assertion or execution status of that already-selected lexical root; it does not change the address into its third-trit-2 sibling.

#### Natural-language examples

- The train is set to depart, but it has not moved.
- The drone's departure from the pad is queued.
- The job is scheduled to leave its initial stage.

#### Programming examples

- `enqueue MOV:102[1] with source bound and started=false`
- `use MOV:102[2] for a tentative departure request awaiting authorization`

#### Future compound examples — reservations only

- scheduled departure: MOV:102 plus later time/scheduler semantics
- cleared for departure: MOV:102 plus permission
- launch pending: MOV:102 plus material readiness conditions

These are decomposition sketches, not approved compound entries.

#### Notes for later Era evolution

Later eras may lexicalize ready, scheduled, cleared, or due, but those must not be back-projected into the atomic event.

## MOV:110 — peer review

### Fixed generated form

| Field | Value |
|---|---|
| Universal slot | completed outward process |
| Transliteration | `gi·kom` |
| Compact root | `kom` |
| Formal carrier | `gi-ki-ki-ma` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 4, 4]` |

### Why the current meaning was probably chosen

A completed target-oriented Motion process almost directly yields arrival. It mirrors source departure and aligns with the canonical destination entity roots MOV:010–012.

### Candidate comparison

| Candidate | Direction | Atom | Addr | Fam | Neigh | Cross | Comp | Daily | Tech | Total | Verdict |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| arrival complete (current) | Target-relative displacement completed. | 9 | 10 | 10 | 9 | 9 | 10 | 10 | 10 | 77/80 | WINNER — The best fit. The word 'entered' should be removed from the invariant because arrival need not cross a boundary. |
| target contact completed | Impact, docking, or touch. | 8 | 9 | 7 | 8 | 5 | 8 | 8 | 8 | 61/80 | Motion-related but contact is a material/structural relation and arrival can occur without contact. |
| outward projection completed | Emanation or outward motion from self. | 8 | 7 | 9 | 7 | 8 | 8 | 7 | 8 | 62/80 | Uses outward but weakens the explicit target reading and overlaps source departure. |
| delivery completed | Transfer of possession, data, or matter. | 6 | 8 | 5 | 7 | 3 | 9 | 10 | 9 | 57/80 | Very useful English, but transfer success belongs to Matter, Data, or Connection; physical arrival is only one component. |
| entry completed | Boundary crossing into a container. | 9 | 9 | 8 | 8 | 6 | 8 | 9 | 8 | 65/80 | Atomic but too narrow and structurally loaded; arrival at a point does not require containment. |

### Recommendation

The current semantic direction survives, but only with a tighter permanent specification that removes incidental consequences and ambiguous wording.

### Recommended permanent semantic specification

- **Canonical title:** completed target arrival
- **Invariant definition:** Completion of a mover's displacement to a specified target position.
- **Semantic boundaries:** Owns only the completed phase of target-relative displacement. Reaching the target is sufficient; entry, contact, delivery, and acceptance are separate.
- **Excluded meanings:** destination entity; near-target position; physical impact; message delivery; material transfer; entry into a container; manifestation.
- **Nearest neighboring roots:** MOV:111 active target approach; MOV:112 pending target approach; MOV:010 defined destination; MOV:011 active destination.
- **Why this address is correct:** First trit 1 selects the process, second trit 1 selects a target, and third trit 0 selects endpoint completion. Arrival is the exact Motion-specific intersection.

#### Cross-family comparisons

- **MAT:** A payload or impact compounds with arrival; it is not built into arrival.
- **MIN:** Achieving a goal mentally is not arrival unless a state-space path is explicit.
- **CON:** Receipt or acknowledgment is communication, not motion completion.
- **STR:** Entering a container adds a structural boundary relation.
- **DAT:** Successful data delivery is DAT/CON even if packet motion is modeled.
- **CRE:** Producing a target result is Creation, not arrival.
- **ORI:** Becoming actual is manifestation, not target displacement.

#### Runtime-state interpretation

- **[0]:** The arrival-completion claim is false or invalid.
- **[1]:** The mover has validly reached the target.
- **[2]/num:** Whether the mover reached the target awaits confirmation.

The lexical third trit remains part of the root's permanent meaning. Runtime `[2]/num` changes the current assertion or execution status of that already-selected lexical root; it does not change the address into its third-trit-2 sibling.

#### Natural-language examples

- She has arrived at the station.
- The probe reached the dock.
- The cursor reached the final sequence position.

#### Programming examples

- `assert MOV:110[1] with postcondition position(actor)=target`
- `emit MOV:110[2] while target-arrival telemetry is unconfirmed`

#### Future compound examples — reservations only

- enter a room: MOV:110 plus structural containment
- deliver cargo: MOV:110 plus material payload and transfer
- return home: MOV:110 with target bound to an earlier MOV:000

These are decomposition sketches, not approved compound entries.

#### Notes for later Era evolution

Later lexical forms for arrive, reach, enter, dock, land, and deliver should retain their additional boundary, manner, or transfer components.

## MOV:111 — peer review

### Fixed generated form

| Field | Value |
|---|---|
| Universal slot | active outward process |
| Transliteration | `gi·kok` |
| Compact root | `kok` |
| Formal carrier | `gi-ki-ki-ki` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 4, 6]` |

### Why the current meaning was probably chosen

An active target-oriented process is naturally approach: the mover is currently progressing toward a selected destination. It provides a clean active counterpart to arrival.

### Candidate comparison

| Candidate | Direction | Atom | Addr | Fam | Neigh | Cross | Comp | Daily | Tech | Total | Verdict |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| destination approach (current) | Ongoing target-relative displacement. | 9 | 10 | 10 | 9 | 9 | 10 | 10 | 10 | 77/80 | WINNER — The strongest candidate. 'Target' is preferable to 'destination' because approach can be assessed before a final endpoint is accepted. |
| active pursuit | Sustained approach to a changing target. | 8 | 9 | 9 | 6 | 7 | 8 | 9 | 7 | 63/80 | Useful but adds moving-target tracking and a relationship likely reserved for a compound or 2xx root. |
| active outward projection | Emanation rather than target approach. | 8 | 7 | 9 | 7 | 8 | 8 | 8 | 8 | 63/80 | Fits outward, but duplicates source departure and does not require a target. |
| active transfer to target | Delivery process. | 6 | 8 | 5 | 7 | 3 | 8 | 9 | 9 | 55/80 | Bundles motion with possession, information, or communication transfer. |
| active guidance toward target | Control of trajectory. | 7 | 8 | 8 | 7 | 5 | 8 | 8 | 9 | 60/80 | Guidance can occur without displacement and adds control/agency semantics. |

### Recommendation

The current semantic direction survives, but only with a tighter permanent specification that removes incidental consequences and ambiguous wording.

### Recommended permanent semantic specification

- **Canonical title:** active target approach
- **Invariant definition:** Ongoing displacement of a mover toward a specified target position.
- **Semantic boundaries:** Owns targetward displacement in progress. It asserts progress toward a target, not merely orientation, intention, tracking, or target availability.
- **Excluded meanings:** facing a target while stationary; pursuit relation; planned future travel; successful arrival; message transmission; goal achievement without a path.
- **Nearest neighboring roots:** MOV:110 completed target arrival; MOV:112 pending target approach; MOV:010 defined destination; MOV:011 active destination.
- **Why this address is correct:** Process + target + active yields ongoing displacement whose defining vector is targetward. No extra participant relation or transfer semantics are needed.

#### Cross-family comparisons

- **MAT:** Force and vehicle dynamics are material contributors.
- **MIN:** Attention toward a subject is not spatial/sequential approach.
- **CON:** Contacting or messaging a participant is not approach.
- **STR:** Approaching a structure does not imply entry or docking.
- **DAT:** Data transfer is not target approach unless a route-position model is explicit.
- **CRE:** Progress toward a design result is metaphorical unless modeled as positions.
- **ORI:** Approaching actuality is ontological change, not Motion by default.

#### Runtime-state interpretation

- **[0]:** The approach is not executing or the assertion is false.
- **[1]:** The mover is currently progressing toward the target.
- **[2]/num:** The active approach is suspended, blocked, or unresolved after onset.

The lexical third trit remains part of the root's permanent meaning. Runtime `[2]/num` changes the current assertion or execution status of that already-selected lexical root; it does not change the address into its third-trit-2 sibling.

#### Natural-language examples

- The train is approaching the platform.
- I'm heading home.
- The task cursor is progressing toward the final step.

#### Programming examples

- `run MOV:111[1] with invariant distance(actor,target) decreases or path-progress increases`
- `use MOV:111[2] for a targetward operation paused after execution began`

#### Future compound examples — reservations only

- pursue a person: MOV:111 plus moving-target relation
- enter a building: MOV:111/110 plus structural boundary
- transport toward a depot: MOV:111 plus material payload roles

These are decomposition sketches, not approved compound entries.

#### Notes for later Era evolution

Later words for come, approach, advance, pursue, enter, and deliver must preserve whether they add deixis, moving-target tracking, boundary crossing, or transfer.

## MOV:112 — peer review

### Fixed generated form

| Field | Value |
|---|---|
| Universal slot | pending outward process |
| Transliteration | `gi·kon` |
| Compact root | `kon` |
| Formal carrier | `gi-ki-ki-nu` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 4, 2]` |

### Why the current meaning was probably chosen

The pending third trit suggested an arrival that has not happened yet. The original definition then tried to clarify that targetward movement is intended or queued, but the title remained outcome-framed and phase-ambiguous.

### Candidate comparison

| Candidate | Direction | Atom | Addr | Fam | Neigh | Cross | Comp | Daily | Tech | Total | Verdict |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| pending arrival (current) | An expected arrival outcome. | 6 | 8 | 10 | 7 | 8 | 7 | 8 | 7 | 61/80 | The title can describe both a queued trip and an active trip whose arrival is still pending. It does not cleanly name the lexical pre-onset process. |
| pending target approach | A targetward event in its lexical pre-onset phase. | 9 | 10 | 10 | 9 | 9 | 9 | 9 | 10 | 75/80 | WINNER — Restores exact triplet parallelism and avoids defining a process through the nonoccurrence of its later result. |
| unavailable destination | Target condition rather than process. | 8 | 6 | 10 | 2 | 9 | 6 | 8 | 7 | 56/80 | Already occupied canonically by MOV:012 and violates the process/entity boundary. |
| targetward intention | Mental commitment or goal selection. | 6 | 7 | 7 | 6 | 5 | 8 | 9 | 7 | 55/80 | Intention can exist without a specified executable motion and collides with Mind and Logic. |
| waiting for entry | Delay at a target boundary. | 7 | 6 | 7 | 7 | 6 | 6 | 9 | 6 | 54/80 | Adds waiting, boundary, and containment; it is not the general pending phase of targetward motion. |

### Recommendation

Replace the current Phase 2 candidate with **pending target approach**. The winner is more atomic and better preserves the address cube.

### Recommended permanent semantic specification

- **Canonical title:** pending target approach
- **Invariant definition:** A specified displacement toward a target position that has not yet begun.
- **Semantic boundaries:** Owns a targetward Motion event before onset. It requires a specified event and target, but not a schedule, intention, accessible target, or eventual success.
- **Excluded meanings:** pending outcome during active travel; unavailable destination; mere intention or desire; waiting at a boundary; active approach; arrival.
- **Nearest neighboring roots:** MOV:110 completed target arrival; MOV:111 active target approach; MOV:012 pending destination; future Motion relationship roots.
- **Why this address is correct:** The first trit requires an operation, the second binds its target, and the third makes the operation lexically pre-onset. 'Pending arrival' is rejected because it describes an absent result rather than the operation.

#### Cross-family comparisons

- **MAT:** Vehicle/payload readiness is Material.
- **MIN:** Desire or intention toward a target is mental.
- **CON:** Invitation or permission to approach is communicative.
- **STR:** Entry clearance and boundaries are structural/logical additions.
- **DAT:** A queue record represents but does not equal the movement operation.
- **CRE:** A planned creation toward a target form is Creation.
- **ORI:** Future time and possibility are external to the Motion invariant.

#### Runtime-state interpretation

- **[0]:** The pending targetward operation is canceled or invalid.
- **[1]:** The targetward operation is validly queued and unbegun.
- **[2]/num:** The queued operation itself is tentative or awaiting confirmation.

The lexical third trit remains part of the root's permanent meaning. Runtime `[2]/num` changes the current assertion or execution status of that already-selected lexical root; it does not change the address into its third-trit-2 sibling.

#### Natural-language examples

- The rover is queued to move to the marker.
- I'm set to head home, but I haven't started.
- The job is waiting to advance to stage three.

#### Programming examples

- `enqueue MOV:112[1] with target bound and started=false`
- `mark MOV:112[2] when a targetward request exists but is not yet confirmed`

#### Future compound examples — reservations only

- scheduled approach: MOV:112 plus later time semantics
- awaiting entry: MOV:112 plus timing and structural boundary
- planned delivery trip: MOV:112 plus payload and transfer roles

These are decomposition sketches, not approved compound entries.

#### Notes for later Era evolution

Later forms may distinguish due, expected, intended, scheduled, or cleared. None should alter the Era Zero event-phase distinction.

## MOV:120 — peer review

### Fixed generated form

| Field | Value |
|---|---|
| Universal slot | completed systemic process |
| Transliteration | `gi·kim` |
| Compact root | `kim` |
| Formal carrier | `gi-ki-nu-ma` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 0, 0]` |

### Why the current meaning was probably chosen

The systemic second trit invited a route-wide or system-wide reading, and Motion's broad source description included transition and time. The Phase 2 definition therefore bundled transfer, circulation, and temporal transition under a generic completed system transition.

### Candidate comparison

| Candidate | Direction | Atom | Addr | Fam | Neigh | Cross | Comp | Daily | Tech | Total | Verdict |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| system transition complete (current) | Umbrella system-level transition. | 4 | 8 | 5 | 6 | 3 | 7 | 6 | 8 | 47/80 | Not permanently atomic: it explicitly lists unrelated processes and collides with Matter, Data, Structure, Creation, Logic, and Origin. |
| completed route traversal | Use of an ordered Motion route as a completed process. | 9 | 10 | 10 | 9 | 9 | 10 | 9 | 10 | 76/80 | WINNER — The strongest systemic Motion interpretation. It pairs cleanly with canonical route entities without collapsing into their entity meaning. |
| circulation cycle completed | Cyclic systemic motion. | 9 | 9 | 10 | 8 | 8 | 8 | 8 | 8 | 68/80 | Atomic and Motion-specific but unnecessarily restricts the systemic triplet to cycles; loop/repetition can be compositional. |
| collective relocation completed | Group/collective motion. | 8 | 9 | 9 | 7 | 7 | 8 | 8 | 8 | 64/80 | Fits shared orientation, but actor plurality and coordination are participant properties, not the most general systemic Motion center. |
| network distribution completed | Transport or dissemination through a system. | 6 | 9 | 6 | 7 | 3 | 9 | 8 | 9 | 57/80 | Adds payload transfer and distribution goals, colliding with Matter, Data, and Connection. |

### Recommendation

Replace the current Phase 2 candidate with **completed route traversal**. The winner is more atomic and better preserves the address cube.

### Recommended permanent semantic specification

- **Canonical title:** completed route traversal
- **Invariant definition:** Completion of motion along a shared or system-defined route.
- **Semantic boundaries:** Owns completion of an operation whose identity depends on traversal of an ordered route, not merely reaching a target. A single mover qualifies when the system-defined route is semantically central.
- **Excluded meanings:** route entity; generic system transition; material circulation; data synchronization; group coordination; isolated target arrival; ontological or temporal change without an explicit route.
- **Nearest neighboring roots:** MOV:121 active route traversal; MOV:122 pending route traversal; MOV:020 established route; MOV:021 active flow network; MOV:110 completed target arrival.
- **Why this address is correct:** Process + systemic/shared + completed should remain Motion-specific. Traversal makes the system-defined route, rather than the target or payload, the defining relation.

#### Cross-family comparisons

- **MAT:** Material circulation or transport adds a payload/substance graph.
- **MIN:** Completing a thought process is Mind unless represented as explicit route positions.
- **CON:** Completing broadcast or negotiation is Connection.
- **STR:** Completing deployment or reorganization is Structure.
- **DAT:** Completing synchronization or replication is Data.
- **CRE:** Completing system generation is Creation.
- **ORI:** Completing an epochal or ontological transition is Origin.

#### Runtime-state interpretation

- **[0]:** The claimed route-traversal completion is false or invalid.
- **[1]:** The route traversal is validly complete.
- **[2]/num:** Completion of the route traversal awaits confirmation.

The lexical third trit remains part of the root's permanent meaning. Runtime `[2]/num` changes the current assertion or execution status of that already-selected lexical root; it does not change the address into its third-trit-2 sibling.

#### Natural-language examples

- The bus completed its route.
- The robot finished the corridor run.
- The job traversed the full workflow path.

#### Programming examples

- `assert MOV:120[1] when all required route positions were visited in order`
- `use MOV:120[2] when a distributed route run reports completion but final acknowledgment is missing`

#### Future compound examples — reservations only

- complete an orbit: MOV:120 plus a cyclic-route relation
- finish transporting cargo: MOV:120 plus payload/carrier roles
- complete a migration: MOV:120 plus a living collective actor

These are decomposition sketches, not approved compound entries.

#### Notes for later Era evolution

Later eras may lexicalize circuit, orbit, commute, migration, pipeline completion, or tour; route topology and carried domain remain separable.

## MOV:121 — peer review

### Fixed generated form

| Field | Value |
|---|---|
| Universal slot | active systemic process |
| Transliteration | `gi·kik` |
| Compact root | `kik` |
| Formal carrier | `gi-ki-nu-ki` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 0, 2]` |

### Why the current meaning was probably chosen

Active systemic Motion strongly suggests flow. The Phase 2 definition tried to maximize coverage by allowing entities, signals, and time-indexed states to move through a shared route system.

### Candidate comparison

| Candidate | Direction | Atom | Addr | Fam | Neigh | Cross | Comp | Daily | Tech | Total | Verdict |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| system flow (current) | Generic flow of heterogeneous carriers. | 4 | 9 | 6 | 6 | 2 | 7 | 8 | 9 | 51/80 | The carrier list reveals a non-atomic umbrella. Signals and state transitions belong to other families unless route traversal itself is being asserted. |
| active route traversal | Active use of an ordered Motion route. | 9 | 10 | 10 | 9 | 9 | 10 | 10 | 10 | 77/80 | WINNER — Highly atomic, broadly useful, and technically precise. Route identity supplies systemic orientation without importing payload semantics. |
| coordinated collective motion | Synchronized group movement. | 8 | 9 | 9 | 7 | 6 | 8 | 9 | 8 | 64/80 | Useful for convoys and flocks but builds participant plurality and coordination into the atom. |
| active circulation | Cyclic flow. | 9 | 9 | 10 | 8 | 8 | 8 | 9 | 8 | 69/80 | Motion-specific and coherent, but repetition and cycle topology should remain compositional so linear routes are not excluded. |
| active state-space transition | Abstract transition or workflow execution. | 7 | 9 | 7 | 7 | 4 | 9 | 6 | 10 | 59/80 | Technically powerful, but dangerously broad; it becomes Motion only when states are explicitly represented as positions on a route. |

### Recommendation

Replace the current Phase 2 candidate with **active route traversal**. The winner is more atomic and better preserves the address cube.

### Recommended permanent semantic specification

- **Canonical title:** active route traversal
- **Invariant definition:** Ongoing motion along a shared or system-defined route.
- **Semantic boundaries:** Owns motion currently progressing through an ordered route whose identity is shared, environmental, distributed, or system-defined. It does not type the mover or payload.
- **Excluded meanings:** route network entity; generic flow of matter or information; coordination by itself; cyclic repetition by itself; target approach with no route salience; system transformation.
- **Nearest neighboring roots:** MOV:120 completed route traversal; MOV:122 pending route traversal; MOV:020 established route; MOV:021 active flow network; MOV:111 active target approach.
- **Why this address is correct:** The systemic second trit is satisfied by the route's shared/system-defined identity. The active third trit makes traversal ongoing. This is more precise than generic flow and more general than circulation.

#### Cross-family comparisons

- **MAT:** Resource or fluid flow belongs to MAT; MOV:121 may add the route-traversal component.
- **MIN:** Reasoning through states is MIN unless explicit positions/routes are modeled.
- **CON:** Broadcast and participant exchange are CON.
- **STR:** Organizational workflow change is STR unless route traversal is separately represented.
- **DAT:** Data streaming, replication, and synchronization are DAT.
- **CRE:** Generative progression is CRE.
- **ORI:** Temporal or ontological unfolding is ORI unless an explicit positional route is part of the graph.

#### Runtime-state interpretation

- **[0]:** The route traversal is not executing.
- **[1]:** Motion is actively progressing along the route.
- **[2]/num:** The active traversal is paused, blocked, or unresolved after onset; this is not MOV:122.

The lexical third trit remains part of the root's permanent meaning. Runtime `[2]/num` changes the current assertion or execution status of that already-selected lexical root; it does not change the address into its third-trit-2 sibling.

#### Natural-language examples

- Traffic is moving along the highway.
- The convoy is traversing the corridor.
- The batch is progressing through the explicit pipeline path.

#### Programming examples

- `run MOV:121[1] with route=MOV:020 and invariant ordered_progress`
- `mark MOV:121[2] when a route traversal has begun but is paused at an intermediate position`

#### Future compound examples — reservations only

- circulate: MOV:121 plus a cyclic route and repeated-loop contour
- move together: MOV:121 plus a collective actor and optional coordination relation
- stream data through a topology: MOV:121 plus DAT process only when route positions matter

These are decomposition sketches, not approved compound entries.

#### Notes for later Era evolution

Later words may compress travel, traverse, commute, circulate, orbit, migrate, process, or stream. The atomic route relation must remain recoverable.

## MOV:122 — peer review

### Fixed generated form

| Field | Value |
|---|---|
| Universal slot | pending systemic process |
| Transliteration | `gi·kin` |
| Compact root | `kin` |
| Formal carrier | `gi-ki-nu-nu` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 0, -2]` |

### Why the current meaning was probably chosen

The pending systemic slot was paired with the broad system-transition interpretation of MOV:120–121. The definition therefore treated any route-wide transfer or temporal transition as staged but unstarted.

### Candidate comparison

| Candidate | Direction | Atom | Addr | Fam | Neigh | Cross | Comp | Daily | Tech | Total | Verdict |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| pending system transition (current) | Generic future system change. | 5 | 9 | 5 | 6 | 3 | 7 | 6 | 8 | 49/80 | Still bundles different domains and makes Motion the default family for generic system change. |
| pending route traversal | A route-traversal event in its lexical pre-onset phase. | 9 | 10 | 10 | 9 | 9 | 10 | 9 | 10 | 76/80 | WINNER — Completes the route-traversal triplet with exact phase symmetry and keeps scheduling, route availability, and payload external. |
| dormant route system | Inactive route entity. | 9 | 6 | 10 | 2 | 9 | 6 | 8 | 8 | 58/80 | Already canonically occupied by MOV:022 and violates the 1xx process requirement. |
| scheduled network flow | Scheduled distributed process. | 6 | 9 | 6 | 7 | 4 | 8 | 8 | 10 | 58/80 | Adds scheduler/time semantics and generic flow across other families. |
| suspended systemic motion | Paused active route operation. | 8 | 6 | 9 | 7 | 8 | 8 | 8 | 9 | 63/80 | Useful, but suspension after onset is the tailored runtime [2] state of MOV:121, not a lexical pending process. |

### Recommendation

Replace the current Phase 2 candidate with **pending route traversal**. The winner is more atomic and better preserves the address cube.

### Recommended permanent semantic specification

- **Canonical title:** pending route traversal
- **Invariant definition:** Motion along a shared or system-defined route that is specified but has not yet begun.
- **Semantic boundaries:** Owns a route-traversal operation represented before onset. The route may be active or inactive; schedule, authorization, delay, payload, and probability are separate.
- **Excluded meanings:** dormant route entity; paused traversal after onset; generic scheduled task; system transformation; material or data flow; timing or delay itself.
- **Nearest neighboring roots:** MOV:120 completed route traversal; MOV:121 active route traversal; MOV:022 dormant route system; MOV:020 established route; MOV:112 pending target approach.
- **Why this address is correct:** The address requires a process, makes an ordered shared route the systemic relation, and fixes the process before onset. Runtime suspension of an already active traversal is excluded.

#### Cross-family comparisons

- **MAT:** Staged transport adds material payload/carrier roles.
- **MIN:** Group intention to travel is mental/social context, not the operation.
- **CON:** Dispatch or authorization messages do not equal the pending traversal.
- **STR:** A staged deployment or reorganization is Structure.
- **DAT:** A queued data synchronization is Data.
- **CRE:** A staged generation process is Creation.
- **ORI:** Future system or epoch transition is Origin unless route motion is explicit.

#### Runtime-state interpretation

- **[0]:** The pending route traversal is canceled or invalid.
- **[1]:** The route traversal is validly queued and unbegun.
- **[2]/num:** The queued traversal itself is tentative or awaiting confirmation.

The lexical third trit remains part of the root's permanent meaning. Runtime `[2]/num` changes the current assertion or execution status of that already-selected lexical root; it does not change the address into its third-trit-2 sibling.

#### Natural-language examples

- The convoy is queued to take the northern route.
- The carts are staged for the warehouse loop.
- The batch is queued to enter the pipeline path.

#### Programming examples

- `enqueue MOV:122[1] with route=MOV:020 and started=false`
- `use MOV:122[2] for a tentative route run awaiting dispatch approval`

#### Future compound examples — reservations only

- scheduled route run: MOV:122 plus time/scheduler semantics
- pending migration: MOV:122 plus a living collective actor
- planned cargo circuit: MOV:122 plus payload and cyclic-route roles

These are decomposition sketches, not approved compound entries.

#### Notes for later Era evolution

Later forms may distinguish scheduled, dispatched, staged, tentative, delayed, or awaiting clearance. Those are modifiers of the pending traversal, not replacements for it.

## Block comparison matrix

| Root | English concepts owned | Belongs elsewhere | Reserved for compounds | Intentionally undefined |
|---|---|---|---|---|
| MOV:100 | left; departed; completed departure from a source | origin position → MOV:000; current position → MOV:001; detachment without motion → CON/STR | exit; launch cargo; evacuated | cause of departure; speed; manner |
| MOV:101 | leaving; departing; moving away from a source | decision to leave → MIN; propulsive force → MAT; social withdrawal → CON | take off; retreat from danger; exit a container | acceleration; direction after departure; destination |
| MOV:102 | queued departure; specified unbegun departure | readiness/capacity → future capacity review; permission → LOG/CON; waiting → timing/aspect | scheduled departure; cleared departure; delayed departure | clock time; probability; reason for delay |
| MOV:110 | arrived; reached a target; completed targetward displacement | destination → MOV:010; receipt → CON/DAT; impact → MAT | enter; dock; deliver; return completed | acceptance; contact force; containment |
| MOV:111 | approaching; heading toward; moving toward a target | active destination → MOV:011; attention toward → MIN; message transmission → CON/DAT | pursue; follow a moving target; enter while under way; transport toward | guidance controller; target velocity; arrival prediction |
| MOV:112 | queued targetward trip; specified unbegun approach | unreachable destination → MOV:012; intention → MIN; schedule → timing/LOG | scheduled approach; awaiting entry; planned delivery trip | estimated arrival time; permission; eventual success |
| MOV:120 | completed route traversal; finished route run; traversed an ordered path | route entity → MOV:020; generic system completion → domain family; data synchronization → DAT | completed orbit; completed migration; completed transport circuit | payload; loop count; collective coordination |
| MOV:121 | traversing a route; traveling along a system-defined path; route progress | active route network → MOV:021; resource flow → MAT; data stream → DAT; broadcast → CON | circulate; orbit; move together; repeat a route; migrate | speed; cycle geometry; synchronization |
| MOV:122 | queued route traversal; specified unbegun route run | dormant route → MOV:022; paused active traversal → MOV:121[2]; scheduled task → LOG/timing | scheduled route run; pending migration; planned cargo circuit | dispatch time; authorization; delay duration |

## English Motion stress test

| Concept | Mapping | Classification | Rationale |
|---|---|---|---|
| leave | MOV:101 while active; MOV:100 when completed | one root selected by lexical phase | Direct source departure. |
| depart | MOV:101 / MOV:100 | one root selected by lexical phase | Same source-relative center as leave. |
| go | MOV:101, MOV:111, or MOV:121 depending source, target, or route salience | context-selected; not one atom | English go underspecifies orientation. |
| move | context-selected Motion root or unresolved manner-neutral superordinate | not forced | Generic move is broader than any one orientation slot. |
| approach | MOV:111 | one root | Active target-relative displacement. |
| arrive | MOV:110 | one root | Completed target-relative displacement. |
| reach | MOV:110 | one root | Target endpoint reached; contact is not implied. |
| travel | MOV:121 when route is central; MOV:111 when destination is central | context-selected | Travel does not always lexicalize route or target. |
| follow a route | MOV:121 + MOV:020 | root plus existing entity | Traversal process plus established route. |
| follow a person | MOV:111 plus a future moving-target relation | reserved compound / relationship gap | Following requires persistent retargeting. |
| wait | timing/aspect; a pending Motion root may coexist | belongs elsewhere | Waiting is duration without required displacement. |
| pause | MOV:101[2], MOV:111[2], or MOV:121[2] plus duration | runtime state plus timing | Operation began and is suspended; not lexical pending. |
| stop | active Motion root [0] plus cessation/command contour | runtime/grammar | Termination modifies an active process. |
| continue | active Motion root [1] plus continuative aspect | grammar | Continuation does not change orientation. |
| cross | MOV:121 plus a boundary/path relation | reserved compound | Crossing requires a boundary or span. |
| return | MOV:111/MOV:110 with target bound to a prior MOV:000 | reserved compound/graph | Return is target approach/arrival plus historical identity of the target. |
| redirect | replace target binding, then MOV:112 or MOV:111 | operation sequence / reserved compound | Redirection relates two motion plans or vectors. |
| move together | collective actor + MOV:121; add coordination only if asserted | reserved compound | Togetherness belongs to actor/relationship structure. |
| circulate | MOV:121 + cyclic route + repeated-loop contour | reserved compound | Cycle topology and repetition are independent. |
| repeat a route | MOV:121 + MOV:020 + repeated-loop contour | root plus grammar | Repetition is not atomic route traversal. |
| schedule | pending root plus later timing/LOG/DAT scheduler semantics | belongs elsewhere / compound | Scheduling is not Motion. |
| delay | pending or suspended Motion root plus timing relation | belongs elsewhere / unresolved timing | Delay compares expected and actual onset/progress. |
| transition | Motion only with explicit positions/route; otherwise STR, CRE, ORI, MIN, or DAT | family-selected | Generic change must not default to Motion. |
| transport | MOV:111 or MOV:121 plus MAT payload/carrier roles | reserved compound | Transport combines displacement and participant roles. |
| deliver | MOV:110 plus MAT/DAT/CON transfer and recipient roles | reserved compound | Arrival does not imply successful transfer. |
| transfer | domain-specific family; add MOV only for explicit displacement | belongs elsewhere / compound | Possession, data, and energy transfer are not synonymous with motion. |
| exit | MOV:101/MOV:100 plus STR boundary/container | reserved compound | Departure plus crossing out of a bounded region. |
| enter | MOV:111/MOV:110 plus STR boundary/container | reserved compound | Target motion plus crossing into containment. |
| launch | MOV:101/MOV:100 plus MAT force/vehicle roles when relevant | one root or compound | The displacement core is departure; mechanics are separate. |
| take off | MOV:101/MOV:100 plus manner/medium | reserved compound | Departure survives; flight onset is additional. |
| migrate | LIF collective actor + MOV:121/120 + route | reserved compound | Migration includes living participants and often a route. |
| orbit | MOV:121 + cyclic/geometric route + repeated-loop contour | reserved compound | Orbital geometry is additional. |
| wander | unresolved | intentionally undefined | No stable source, target, or system route is central. |
| reverse | relation between successive motion vectors or target/source rebinding | intentionally undefined / future compound | Reversal is second-order over motion operations. |
| accelerate | unresolved Motion/MAT boundary | intentionally undefined | Requires rate-of-change semantics not supplied by this block. |
| decelerate | unresolved Motion/MAT boundary | intentionally undefined | Same rate-of-change issue as accelerate. |
| rotate | unresolved Motion vocabulary gap | intentionally undefined | Rotation is displacement around an axis, not captured by source/target/route phase alone. |
| flow | MOV:121 only when route traversal is asserted; otherwise MAT/DAT/CON | family-selected | Carrier-domain meaning controls. |
| destination | MOV:010 | existing Motion entity | Entity, not process. |
| route | MOV:020 | existing Motion entity | Entity, not process. |
| current position | MOV:001 | existing Motion entity | Entity, not process. |
| start moving | MOV:101 at onset plus timing/aspect; not a separate atom here | root plus grammar | Starting is phase boundary over active departure. |

## Final peer-review disposition

- **Recommended without semantic-direction replacement:** MOV:100, MOV:101, MOV:110, MOV:111. Their invariants and titles are tightened.
- **Recommended replacement of Phase 2 candidate:** MOV:102, MOV:112, MOV:120, MOV:121, MOV:122.
- **Unresolved roots in this block:** none. Each address has a satisfactory winner, but all nine remain provisional until explicit user approval.
- **Other blocks reviewed:** none.
- **Compounds canonized:** none.
- **Gate 4 begun:** no.
