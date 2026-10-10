# MOV:100–122 Detailed Semantic Review

Status: **PROPOSED FOR USER REVIEW — NOT CANONICAL**  
Current semantic authority: **PROVISIONAL — PENDING DETAILED SEMANTIC REVIEW**  
Gate 3 promotion: **WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION**

This packet reconsiders the nine Motion process addresses from their family and trit axes. It does not preserve a Phase 2 title merely because it already existed. Generated structural fields are copied from the accepted algorithms and are not changed.

## Design result at a glance

| Root | Universal slot | Proposed title | Invariant atomic definition | Confidence |
|---|---|---|---|---:|
| MOV:100 | completed inward process | source departure completed | Completion of a mover's displacement away from a specified source position. | 0.90 |
| MOV:101 | active inward process | source departure active | Ongoing displacement of a mover away from a specified source position. | 0.93 |
| MOV:102 | pending inward process | source departure pending | A specified displacement away from a source position that has not yet begun. | 0.87 |
| MOV:110 | completed outward process | target arrival completed | Completion of a mover's displacement to a specified target position. | 0.95 |
| MOV:111 | active outward process | target approach active | Ongoing displacement of a mover toward a specified target position. | 0.95 |
| MOV:112 | pending outward process | target approach pending | A specified displacement toward a target position that has not yet begun. | 0.89 |
| MOV:120 | completed systemic process | route traversal completed | Completion of motion along a shared or system-defined route. | 0.83 |
| MOV:121 | active systemic process | route traversal active | Ongoing motion along a shared or system-defined route. | 0.87 |
| MOV:122 | pending systemic process | route traversal pending | Motion along a shared or system-defined route that is specified but has not yet begun. | 0.83 |

## Triplet architecture

### MOV:100–102 — source-relative displacement

The shared axis is displacement defined by increasing separation from a source. `100` is the completed departure, `101` is that departure in progress, and `102` is the same departure specified before onset. The triplet does not encode readiness, permission, or waiting.

### MOV:110–112 — target-relative displacement

The shared axis is displacement defined by progress toward a target. `110` is completion at the target, `111` is approach in progress, and `112` is the targetward operation specified before onset. A destination entity remains `MOV:010–012`; it is not the process.

### MOV:120–122 — system-route traversal

The shared axis is motion along an ordered route that is shared or established by a system. `120` is completed traversal, `121` is traversal in progress, and `122` is traversal specified before onset. Circulation, repetition, synchronization, scheduling, data flow, material flow, and ontological transition require contour, grammar, or compounds; they are not bundled into the atom.

## MOV:100 — proposed “source departure completed”

Packet status: **not canonical**.

### A. Address and generated forms

| Field | Fixed value |
|---|---|
| Canonical ID | `MOV:100` |
| Universal slot | completed inward process |
| Family-qualified transliteration | `gi·kam` |
| Local compact root | `kam` |
| Formal carrier | `gi-ki-ma-ma` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 2, 2]` |

### B. Candidate analysis

The Phase 2 candidate was **completed source departure** — “Completion of a mover's displacement away from a source position.” It is treated only as evidence of a prior proposal.

| Candidate | Why it fits | Useful coverage | Territory consumed | Conflicts / limitations | Result |
|---|---|---|---|---|---|
| source departure completed | The address is a completed process oriented to a source. A completed source-relative displacement is the direct Motion-family reading. | left, departed, exited a starting point, completed takeoff from an origin | Only the completed phase of motion away from an identified source. | Requires a source relation; it does not by itself identify the destination, cause, cargo, or manner. | selected |
| completed release from source | Release also points away from a source and can culminate in separation. | launch, release, discharge, unmoor | Source control, attachment, and permission as well as motion. | It would collide with CON disengagement, STR detachment, MAT force, and permission grammar; release can occur without displacement. | rejected |
| completed self-relocation | Relocation is a completed Motion process and may begin from the mover's own position. | move, transfer, change position | Both source departure and target arrival. | Too broad: it erases the second-trit contrast with MOV:110 and makes the triplets non-compositional. | rejected |

### C. Invariant atomic definition

**Completion of a mover's displacement away from a specified source position.**

This definition has one center: source-relative displacement, in its completed phase.

### D. Address justification

- **first trit:** 1 = process/action/transformation: this root predicates displacement, not a position, route, capacity, or relationship.
- **second trit:** 0 = inward/source: the process is defined by displacement relative to its source position.
- **third trit:** 0 = completed: the defining displacement/traversal has reached its endpoint condition.

### E. Inclusion and exclusion boundaries

- **Includes:** A completed displacement whose defining relation is that the mover is now away from its specified source.
- **Does not include:** Mere source identification, intention to leave, motion still under way, destination arrival, release without displacement, or ontological change.
- **Nearest same-family handling:** MOV:101 handles the same source departure while it is under way; MOV:000 is the source-position entity.
- **Cross-domain handling:** Use a MAT compound for a material payload, CON for social/channel disengagement, STR for component removal, and ORI for change of existence.

### F–G. Triplet and existing-Motion contrast

Triplet axis: **source-relative displacement**; this root is the **completed** member. MOV:000 names the origin; MOV:100 asserts that motion away from that origin has completed.

### H. Cross-family collision audit

Pure Motion reading: **stands alone** when literal or explicitly modeled displacement/traversal is asserted. The seven-family detailed dispositions are in `reviews/MOV_100_122_collision_report.md`.

- **MAT:** The Motion root stands alone for source-relative displacement. Form a compound when a material body, force, or payload matters; the Motion root must not mean force, ejection mechanics, or matter transfer.
- **MIN:** A physical/sequential departure may modify a mental-state graph, but a shift of attention, forgetting, or decision to leave belongs to MIN and should not be covered by MOV alone.
- **CON:** Leaving a participant or channel forms a compound only when spatial/sequential displacement also occurs. Withdrawal, disconnection, or release without displacement is CON, not MOV.
- **STR:** A component exiting a structure forms a MOV+STR compound. Detachment, reorganization, or role removal without displacement is STR.
- **DAT:** A record can be modeled as a mover in a compound, but reading, deletion, copying, or transmission from a source is DAT rather than departure by itself.
- **CRE:** Relocating a created artifact can compound with CRE; emergence, generation, or transformation from a source is CRE rather than departure.
- **ORI:** Leaving a spatial/sequential origin stands alone; ceasing to exist, becoming, or leaving an ontological state belongs to ORI unless a Motion metaphor is explicitly modeled as a compound.

### I. Tailored runtime-state interpretations

- **[0]:** The asserted completion does not hold, has been invalidated, or is unavailable as a fact.
- **[1]:** The departure completion is a valid current fact: the mover has left the source.
- **[2]/num:** Whether the departure completed is pending confirmation or intentionally left unresolved.

**Lexical third trit versus runtime [2]/num:** Lexical trit 2 is not present here: lexical trit 0 permanently makes this the completed member. MOV:100[2] therefore means a completed-departure proposition whose truth/status is unresolved, not a not-yet-begun departure.

### J. Examples

| Type | Semantic graph | Literal gloss | Natural English | Runtime | Contour | Roles/registers |
|---|---|---|---|---|---|---|
| conversation | `(traveler:x) -actor→ (e:MOV:100[1]) -source→ (home:MOV:000[1])` | traveler; source-departure-completed; home-origin | The traveler has left home. | [1] completion valid | falling declaration | low=traveler; middle=MOV:100; high=completed separation; sustained=home/source |
| physical_spatial | `(drone:x) -actor→ (e:MOV:100[1]) -source→ (pad:MOV:000[1])` | drone; completed displacement away; launch pad | The drone is clear of the launch pad. | [1] completion valid | falling declaration | low=drone; middle=departure; high=clear-of-source result; sustained=pad |
| temporal_sequential | `(cursor:x) -actor→ (e:MOV:100[1]) -source→ (step0:MOV:000[1])` | cursor; completed departure; initial sequence position | The workflow has left its initialization step. | [1] completed phase asserted | rise-return definition | low=cursor; middle=departure; high=post-initial result; sustained=sequence |
| cross_family_compound | `(self:LIF:001[1]) -actor→ (e:MOV:100[1]) -source→ (camp:MOV:000[1])` | conscious self + completed source departure + camp origin | I have left the camp. | [1] on LIF actor and MOV process | falling declaration | low=LIF:001 actor; middle=MOV:100; high=departure result; sustained=MOV:000 |
| executable_programming | `assert(e:MOV:100[1]); source(e)=MOV:000; postcondition=away_from(actor(e),source(e))` | assert completed source departure with separation postcondition | Assert that the departure operation completed. | [1] makes the postcondition valid | sharply falling command | low=actor binding; middle=operation; high=postcondition; sustained=source binding |
| counterexample | `(mind:x) -recalls→ (home:MIN:*[1]); MOV:100 absent` | mental recall of home; no displacement | They remembered home; they did not leave it. | [1] belongs on the mental predicate | falling declaration | low=experiencer; middle=MIN predicate; high=memory target; no MOV register |

## MOV:101 — proposed “source departure active”

Packet status: **not canonical**.

### A. Address and generated forms

| Field | Fixed value |
|---|---|
| Canonical ID | `MOV:101` |
| Universal slot | active inward process |
| Family-qualified transliteration | `gi·kak` |
| Local compact root | `kak` |
| Formal carrier | `gi-ki-ma-ki` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 2, 4]` |

### B. Candidate analysis

The Phase 2 candidate was **active source departure** — “Ongoing displacement of a mover away from a source position.” It is treated only as evidence of a prior proposal.

| Candidate | Why it fits | Useful coverage | Territory consumed | Conflicts / limitations | Result |
|---|---|---|---|---|---|
| source departure active | It is an active process whose defining anchor is the source. | leaving, departing, moving away, taking off | Only active source-oriented motion. | It needs an explicit or recoverable source and does not say where the mover is headed. | selected |
| generic self-motion | An active inward process can be read as an entity acting on its own position. | go, move, travel | Nearly every active Motion event. | It would swallow MOV:111 and MOV:121, leaving orientation and systemic triplets without clear work. | rejected |
| active disengagement | Disengagement often accompanies departure. | detach, disconnect, withdraw | Connection, structure, and social relation as well as motion. | A relation can end without spatial or sequential displacement; that belongs to CON or STR, possibly compounded with MOV. | rejected |

### C. Invariant atomic definition

**Ongoing displacement of a mover away from a specified source position.**

This definition has one center: source-relative displacement, in its active phase.

### D. Address justification

- **first trit:** 1 = process/action/transformation: this root predicates displacement, not a position, route, capacity, or relationship.
- **second trit:** 0 = inward/source: the process is defined by displacement relative to its source position.
- **third trit:** 1 = active: the defining displacement/traversal is presently under way.

### E. Inclusion and exclusion boundaries

- **Includes:** Motion presently increasing separation from a specified source, whether physical or along an explicitly modeled sequence.
- **Does not include:** Generic activity, a decision to leave, completed departure, targetward approach, or social withdrawal without motion.
- **Nearest same-family handling:** MOV:100 handles completed departure; MOV:102 handles the specified but unbegun departure.
- **Cross-domain handling:** Compound with MAT for physical cargo/body details, LIF for a living actor, CON for withdrawal from a participant, or STR for a component exiting a structure.

### F–G. Triplet and existing-Motion contrast

Triplet axis: **source-relative displacement**; this root is the **active** member. MOV:001 names the mover's current position; MOV:101 is the act of leaving a source position and may update MOV:001 over time.

### H. Cross-family collision audit

Pure Motion reading: **stands alone** when literal or explicitly modeled displacement/traversal is asserted. The seven-family detailed dispositions are in `reviews/MOV_100_122_collision_report.md`.

- **MAT:** The Motion root stands alone for source-relative displacement. Form a compound when a material body, force, or payload matters; the Motion root must not mean force, ejection mechanics, or matter transfer.
- **MIN:** A physical/sequential departure may modify a mental-state graph, but a shift of attention, forgetting, or decision to leave belongs to MIN and should not be covered by MOV alone.
- **CON:** Leaving a participant or channel forms a compound only when spatial/sequential displacement also occurs. Withdrawal, disconnection, or release without displacement is CON, not MOV.
- **STR:** A component exiting a structure forms a MOV+STR compound. Detachment, reorganization, or role removal without displacement is STR.
- **DAT:** A record can be modeled as a mover in a compound, but reading, deletion, copying, or transmission from a source is DAT rather than departure by itself.
- **CRE:** Relocating a created artifact can compound with CRE; emergence, generation, or transformation from a source is CRE rather than departure.
- **ORI:** Leaving a spatial/sequential origin stands alone; ceasing to exist, becoming, or leaving an ontological state belongs to ORI unless a Motion metaphor is explicitly modeled as a compound.

### I. Tailored runtime-state interpretations

- **[0]:** The active-departure operation is not executing or the assertion is false.
- **[1]:** The mover is currently increasing separation from the source.
- **[2]/num:** The active-departure operation is suspended, awaiting observation, or otherwise unresolved as an execution state.

**Lexical third trit versus runtime [2]/num:** Lexical trit 1 permanently selects the active phase. MOV:101[2] is still the active-departure concept placed in a pending/suspended assertion state; MOV:102 is the distinct lexical concept of a departure specified before it begins.

### J. Examples

| Type | Semantic graph | Literal gloss | Natural English | Runtime | Contour | Roles/registers |
|---|---|---|---|---|---|---|
| conversation | `(self:LIF:001[1]) -actor→ (e:MOV:101[1]) -source→ (here:MOV:001[1])` | conscious self; active source departure; current place | I'm leaving now. | [1] departure executing | falling declaration | low=LIF:001; middle=MOV:101; high=increasing separation; sustained=source |
| physical_spatial | `(cart:x) -actor→ (e:MOV:101[1]) -source→ (dock:MOV:000[1])` | cart; moving away; dock | The cart is rolling off the dock. | [1] active motion | falling declaration | low=cart; middle=departure; high=away vector; sustained=dock |
| temporal_sequential | `(token:x) -actor→ (e:MOV:101[1]) -source→ (init:MOV:000[1])` | token; active departure; initial sequence position | The control token is leaving initialization. | [1] sequential displacement executing | falling declaration | low=token; middle=MOV:101; high=next-position direction; sustained=workflow |
| cross_family_compound | `(other:LIF:011[1]) -actor→ (e:MOV:101[1]) -source→ (room:MOV:000[1])` | conscious other + active departure + room source | She is leaving the room. | [1] actor responsive and motion active | falling declaration | low=LIF:011; middle=MOV:101; high=departure direction; sustained=room |
| executable_programming | `run(e:MOV:101[1]); while executing: separation(actor(e),source(e)) increases` | execute active departure; separation monotonically increases | Run the leave-source operation. | [1] operation executing | sharply falling command | low=actor; middle=operation; high=invariant; sustained=source |
| counterexample | `(self:LIF:001[1]) -decides→ (plan:MOV:102[1]); MOV:101[0]` | decision and queued departure; no active displacement | I decided to leave, but I am still standing here. | MOV:102[1], MOV:101[0] | falling declaration | low=decider; middle=plan; high=future departure; no active-motion register |

## MOV:102 — proposed “source departure pending”

Packet status: **not canonical**.

### A. Address and generated forms

| Field | Fixed value |
|---|---|
| Canonical ID | `MOV:102` |
| Universal slot | pending inward process |
| Family-qualified transliteration | `gi·kan` |
| Local compact root | `kan` |
| Formal carrier | `gi-ki-ma-nu` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 2, 0]` |

### B. Candidate analysis

The Phase 2 candidate was **potential source departure** — “A potential displacement away from a source position that is not presently active or completed.” It is treated only as evidence of a prior proposal.

| Candidate | Why it fits | Useful coverage | Territory consumed | Conflicts / limitations | Result |
|---|---|---|---|---|---|
| source departure pending | The address is a pending process oriented to a source; the operation exists lexically but has not entered execution. | set to leave, queued departure, prepared launch, upcoming exit | Only an identified source departure before onset. | Timing, permission, readiness, and probability must be supplied by grammar or compounds. | selected |
| departure readiness | Readiness commonly precedes departure and matches the pending phase. | ready to go, cleared to launch, prepared | Capacity and permission in addition to the pending event. | A mover can be ready without a departure being specified; capacity belongs in the 2xx layer and permission belongs to later grammar/logic. | rejected |
| waiting at source | Waiting often co-occurs with an unbegun departure. | wait, hold, stand by | Duration and non-motion. | Waiting is not necessarily motion and can occur without any intended departure; it should be timing/contour or a separate reviewed concept. | rejected |

### C. Invariant atomic definition

**A specified displacement away from a source position that has not yet begun.**

This definition has one center: source-relative displacement, in its pending phase.

### D. Address justification

- **first trit:** 1 = process/action/transformation: this root predicates displacement, not a position, route, capacity, or relationship.
- **second trit:** 0 = inward/source: the process is defined by displacement relative to its source position.
- **third trit:** 2 = pending: the defining displacement/traversal is specified but has not begun.

### E. Inclusion and exclusion boundaries

- **Includes:** A departure event represented as specified or queued while displacement remains unbegun.
- **Does not include:** Readiness alone, permission, waiting duration, a dormant route, an unreachable destination, or active motion.
- **Nearest same-family handling:** MOV:101 handles execution of the departure; MOV:022 handles a dormant route system rather than a pending operation.
- **Cross-domain handling:** Scheduling requires later LOG/DAT/ORI review; a living traveler may be supplied by LIF; material launch conditions require MAT.

### F–G. Triplet and existing-Motion contrast

Triplet axis: **source-relative displacement**; this root is the **pending** member. MOV:002 is a retained former/source position; MOV:102 is a future operation relative to a source and does not name a position.

### H. Cross-family collision audit

Pure Motion reading: **stands alone** when literal or explicitly modeled displacement/traversal is asserted. The seven-family detailed dispositions are in `reviews/MOV_100_122_collision_report.md`.

- **MAT:** The Motion root stands alone for source-relative displacement. Form a compound when a material body, force, or payload matters; the Motion root must not mean force, ejection mechanics, or matter transfer.
- **MIN:** A physical/sequential departure may modify a mental-state graph, but a shift of attention, forgetting, or decision to leave belongs to MIN and should not be covered by MOV alone.
- **CON:** Leaving a participant or channel forms a compound only when spatial/sequential displacement also occurs. Withdrawal, disconnection, or release without displacement is CON, not MOV.
- **STR:** A component exiting a structure forms a MOV+STR compound. Detachment, reorganization, or role removal without displacement is STR.
- **DAT:** A record can be modeled as a mover in a compound, but reading, deletion, copying, or transmission from a source is DAT rather than departure by itself.
- **CRE:** Relocating a created artifact can compound with CRE; emergence, generation, or transformation from a source is CRE rather than departure.
- **ORI:** Leaving a spatial/sequential origin stands alone; ceasing to exist, becoming, or leaving an ontological state belongs to ORI unless a Motion metaphor is explicitly modeled as a compound.

### I. Tailored runtime-state interpretations

- **[0]:** The queued departure is canceled, invalid, or not available.
- **[1]:** A valid departure operation is queued and has not begun.
- **[2]/num:** The status of the queued departure itself is dormant or unresolved—for example, the plan exists but is not confirmed.

**Lexical third trit versus runtime [2]/num:** Lexical trit 2 makes pending departure the root's permanent semantic phase. MOV:102[1] says that pending operation is validly queued; MOV:102[2] says the queue/plan is itself unresolved.

### J. Examples

| Type | Semantic graph | Literal gloss | Natural English | Runtime | Contour | Roles/registers |
|---|---|---|---|---|---|---|
| conversation | `(bus:x) -actor→ (e:MOV:102[1]) -source→ (station:MOV:000[1])` | bus; pending source departure; station | The bus is set to leave the station. | [1] queued departure valid | falling declaration | low=bus; middle=MOV:102; high=queued onset; sustained=station |
| physical_spatial | `(arm:x) -actor→ (e:MOV:102[1]) -source→ (rest:MOV:000[1])` | robot arm; specified unbegun departure; rest position | The arm is staged to move off its rest point. | [1] staged operation | fall-rise possibility | low=arm; middle=pending departure; high=future separation; sustained=rest point |
| temporal_sequential | `(job:x) -actor→ (e:MOV:102[1]) -source→ (queue_head:MOV:000[1])` | job; pending departure; queue origin | The job is queued to leave the first stage. | [1] pre-onset operation valid | falling declaration | low=job; middle=MOV:102; high=next-stage onset; sustained=queue |
| cross_family_compound | `(other:LIF:011[1]) -actor→ (e:MOV:102[1]) -source→ (camp:MOV:000[1])` | conscious other + pending departure + camp source | She is scheduled to depart the camp. | [1] validates the motion plan; schedule time remains external | falling declaration | low=LIF:011; middle=MOV:102; high=future onset; sustained=camp |
| executable_programming | `enqueue(e:MOV:102[1]); precondition=at(actor(e),source(e)); started(e)=false` | enqueue source-departure operation; actor still at source; not started | Queue a departure from the source. | [1] pending operation accepted | sharply falling command | low=actor; middle=queue operation; high=precondition; sustained=source |
| counterexample | `(traveler:x) -waits_at→ (station:MOV:001[1]); departure unspecified` | traveler remains at station; no departure event specified | The traveler is waiting, but no trip has been planned. | [1] on waiting predicate; MOV:102 absent | falling declaration | low=traveler; middle=timing/wait predicate; high=duration; sustained=station |

## MOV:110 — proposed “target arrival completed”

Packet status: **not canonical**.

### A. Address and generated forms

| Field | Fixed value |
|---|---|
| Canonical ID | `MOV:110` |
| Universal slot | completed outward process |
| Family-qualified transliteration | `gi·kom` |
| Local compact root | `kom` |
| Formal carrier | `gi-ki-ki-ma` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 4, 4]` |

### B. Candidate analysis

The Phase 2 candidate was **completed target arrival** — “Completion of a mover's displacement to a target position.” It is treated only as evidence of a prior proposal.

| Candidate | Why it fits | Useful coverage | Territory consumed | Conflicts / limitations | Result |
|---|---|---|---|---|---|
| target arrival completed | This is the direct completed, target-oriented Motion process. | arrive, reach, enter the destination, complete delivery travel | Only the completion of targetward displacement. | It does not imply successful communication, payload transfer, acceptance, or transformation at the target. | selected |
| target entry completed | Entry is a clear completed target-oriented motion. | enter, cross a boundary, dock | Boundary crossing rather than all reaching. | Too narrow: arrival can occur at a point or endpoint without entering a container; boundary semantics should be compounded. | rejected |
| outward transfer completed | Transfer ends at a target and is outward. | deliver, send, hand over | Material, data, and communication transfer. | It would invade MAT, DAT, and CON. MOV should express only the displacement component. | rejected |

### C. Invariant atomic definition

**Completion of a mover's displacement to a specified target position.**

This definition has one center: target-relative displacement, in its completed phase.

### D. Address justification

- **first trit:** 1 = process/action/transformation: this root predicates displacement, not a position, route, capacity, or relationship.
- **second trit:** 1 = outward/target: the process is defined by displacement relative to a selected target position.
- **third trit:** 0 = completed: the defining displacement/traversal has reached its endpoint condition.

### E. Inclusion and exclusion boundaries

- **Includes:** A target-oriented displacement whose endpoint condition has been met.
- **Does not include:** Merely naming a destination, being near it, delivery of information, acceptance by a recipient, or creation at the target.
- **Nearest same-family handling:** MOV:111 handles the approach in progress; MOV:010 names the destination entity.
- **Cross-domain handling:** Transport/delivery is a compound with MAT or DAT/CON depending on what arrives; entry into a structure adds STR.

### F–G. Triplet and existing-Motion contrast

Triplet axis: **target-relative displacement**; this root is the **completed** member. MOV:010 is a defined destination even with no motion; MOV:110 asserts that the process of reaching it is complete.

### H. Cross-family collision audit

Pure Motion reading: **stands alone** when literal or explicitly modeled displacement/traversal is asserted. The seven-family detailed dispositions are in `reviews/MOV_100_122_collision_report.md`.

- **MAT:** The Motion root stands alone for target-relative displacement. Form a compound for material payload/delivery; it must not mean force application or material transformation at the target.
- **MIN:** Physical/sequential approach stands alone; attention turning toward a subject or mental goal belongs to MIN, with a compound only when both processes occur.
- **CON:** Approaching a participant can compound with CON, but contacting, delivering a message, or establishing a bond is not target arrival.
- **STR:** Entry into or docking with a structure compounds MOV with STR. Construction, containment, or installation is not arrival alone.
- **DAT:** A data packet's spatial/logical arrival may compound with MOV, but write, retrieval, delivery, and assignment are DAT processes.
- **CRE:** Moving toward a design target can modify a CRE graph, but instantiation or transformation of that target is CRE, not arrival.
- **ORI:** Reaching a position stands alone; manifestation or transition into actuality is ORI, not target arrival.

### I. Tailored runtime-state interpretations

- **[0]:** The arrival-completion assertion is false, revoked, or unavailable.
- **[1]:** The mover has validly reached the specified target.
- **[2]/num:** Whether the target was reached is awaiting confirmation or intentionally unresolved.

**Lexical third trit versus runtime [2]/num:** Lexical trit 0 permanently makes this completed targetward displacement. MOV:110[2] is an unresolved claim about completed arrival, not a pending journey.

### J. Examples

| Type | Semantic graph | Literal gloss | Natural English | Runtime | Contour | Roles/registers |
|---|---|---|---|---|---|---|
| conversation | `(other:LIF:011[1]) -actor→ (e:MOV:110[1]) -target→ (here:MOV:010[1])` | conscious other; target-arrival-completed; here as destination | She has arrived. | [1] arrival completion valid | falling declaration | low=LIF:011; middle=MOV:110; high=target reached; sustained=none |
| physical_spatial | `(parcel:x) -actor→ (e:MOV:110[1]) -target→ (bay:MOV:010[1])` | parcel; completed targetward displacement; loading bay | The parcel reached the loading bay. | [1] endpoint condition met | falling declaration | low=parcel; middle=arrival; high=bay target; sustained=route |
| temporal_sequential | `(cursor:x) -actor→ (e:MOV:110[1]) -target→ (final:MOV:010[1])` | cursor; arrival completed; final sequence position | The cursor reached the final step. | [1] sequential endpoint reached | falling declaration | low=cursor; middle=MOV:110; high=final step; sustained=sequence |
| cross_family_compound | `(self:LIF:001[1]) -actor→ (e:MOV:110[1]) -target→ (meeting:MOV:010[1])` | conscious self + completed target arrival + meeting location | I arrived at the meeting place. | [1] actor and arrival valid | falling declaration | low=LIF:001; middle=MOV:110; high=MOV:010; sustained=context |
| executable_programming | `assert(e:MOV:110[1]); target(e)=MOV:010; postcondition=at(actor(e),target(e))` | assert completed targetward motion with at-target postcondition | Assert that the mover reached the target. | [1] postcondition valid | sharply falling command | low=actor; middle=operation; high=target/postcondition; sustained=route |
| counterexample | `(destination:MOV:010[1]); no motion event` | defined destination only | The address is our destination, but nobody has arrived. | MOV:010[1]; MOV:110[0] | falling declaration | high=destination entity; no low actor or middle arrival process |

## MOV:111 — proposed “target approach active”

Packet status: **not canonical**.

### A. Address and generated forms

| Field | Fixed value |
|---|---|
| Canonical ID | `MOV:111` |
| Universal slot | active outward process |
| Family-qualified transliteration | `gi·kok` |
| Local compact root | `kok` |
| Formal carrier | `gi-ki-ki-ki` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 4, 6]` |

### B. Candidate analysis

The Phase 2 candidate was **active target approach** — “Ongoing displacement of a mover toward a target position.” It is treated only as evidence of a prior proposal.

| Candidate | Why it fits | Useful coverage | Territory consumed | Conflicts / limitations | Result |
|---|---|---|---|---|---|
| target approach active | It is the exact active, target-oriented Motion reading. | approach, head toward, advance on, travel to | Only motion currently reducing the target-relative path. | A target must be specified; intention or orientation without displacement is insufficient. | selected |
| directed motion | An outward process naturally suggests direction. | go north, move forward, steer | All vector-directed motion, even without a target. | Too broad and weakens the target axis; direction/vector may require another Motion relation or compound. | rejected |
| pursuit | Pursuit is active targetward motion. | follow, chase, track | Moving-target relation and continued retargeting. | Too specific; it would consume likely 2xx relationship territory and require target motion semantics. | rejected |

### C. Invariant atomic definition

**Ongoing displacement of a mover toward a specified target position.**

This definition has one center: target-relative displacement, in its active phase.

### D. Address justification

- **first trit:** 1 = process/action/transformation: this root predicates displacement, not a position, route, capacity, or relationship.
- **second trit:** 1 = outward/target: the process is defined by displacement relative to a selected target position.
- **third trit:** 1 = active: the defining displacement/traversal is presently under way.

### E. Inclusion and exclusion boundaries

- **Includes:** Motion presently oriented toward and progressing with respect to a specified target.
- **Does not include:** Facing a target while stationary, intending to go later, following as a social relation, or merely having a reachable destination.
- **Nearest same-family handling:** MOV:110 handles completed arrival; MOV:112 handles the same targetward displacement before onset; MOV:011 is the active destination entity.
- **Cross-domain handling:** Pursuit of a living target compounds with LIF; data transmission with DAT/CON must not collapse into MOV; force-driven travel may add MAT.

### F–G. Triplet and existing-Motion contrast

Triplet axis: **target-relative displacement**; this root is the **active** member. MOV:011 is a destination currently reachable and guiding motion; MOV:111 is the mover's targetward action.

### H. Cross-family collision audit

Pure Motion reading: **stands alone** when literal or explicitly modeled displacement/traversal is asserted. The seven-family detailed dispositions are in `reviews/MOV_100_122_collision_report.md`.

- **MAT:** The Motion root stands alone for target-relative displacement. Form a compound for material payload/delivery; it must not mean force application or material transformation at the target.
- **MIN:** Physical/sequential approach stands alone; attention turning toward a subject or mental goal belongs to MIN, with a compound only when both processes occur.
- **CON:** Approaching a participant can compound with CON, but contacting, delivering a message, or establishing a bond is not target arrival.
- **STR:** Entry into or docking with a structure compounds MOV with STR. Construction, containment, or installation is not arrival alone.
- **DAT:** A data packet's spatial/logical arrival may compound with MOV, but write, retrieval, delivery, and assignment are DAT processes.
- **CRE:** Moving toward a design target can modify a CRE graph, but instantiation or transformation of that target is CRE, not arrival.
- **ORI:** Reaching a position stands alone; manifestation or transition into actuality is ORI, not target arrival.

### I. Tailored runtime-state interpretations

- **[0]:** The approach is not executing or the approach assertion is false.
- **[1]:** The mover is currently progressing toward the target.
- **[2]/num:** The active approach is suspended, awaiting observation, or otherwise unresolved as an executing operation.

**Lexical third trit versus runtime [2]/num:** Lexical trit 1 defines the active targetward process. MOV:111[2] is the active-approach concept in a suspended/unresolved runtime state; MOV:112 is lexically pre-onset.

### J. Examples

| Type | Semantic graph | Literal gloss | Natural English | Runtime | Contour | Roles/registers |
|---|---|---|---|---|---|---|
| conversation | `(self:LIF:001[1]) -actor→ (e:MOV:111[1]) -target→ (home:MOV:011[1])` | conscious self; active target approach; reachable home | I'm heading home. | [1] approach executing | falling declaration | low=LIF:001; middle=MOV:111; high=home target; sustained=route |
| physical_spatial | `(probe:x) -actor→ (e:MOV:111[1]) -target→ (dock:MOV:011[1])` | probe; ongoing targetward displacement; active dock | The probe is approaching the dock. | [1] distance/path-to-target decreasing | falling declaration | low=probe; middle=approach; high=dock; sustained=space |
| temporal_sequential | `(task:x) -actor→ (e:MOV:111[1]) -target→ (deadline:MOV:011[1])` | task; active approach; target sequence point | The task is moving toward its completion step. | [1] sequential targetward progress | falling declaration | low=task; middle=MOV:111; high=completion step; sustained=timeline |
| cross_family_compound | `(other:LIF:011[1]) -actor→ (e:MOV:111[1]) -target→ (self:LIF:001[1])` | conscious other + active target approach + conscious self target | She is coming toward me. | [1] both life nodes responsive; motion active | falling declaration | low=LIF:011 actor; middle=MOV:111; high=LIF:001 target; sustained=space |
| executable_programming | `run(e:MOV:111[1]); target(e)=MOV:011; invariant=progress_toward(actor(e),target(e))` | execute target-approach operation under progress invariant | Move the actor toward the target. | [1] operation executing | sharply falling command | low=actor; middle=operation; high=target; sustained=path |
| counterexample | `(actor:x) -faces→ (target:MOV:011[1]); position unchanged` | orientation toward target; no displacement | The rover faces the dock but is not approaching it. | [1] on orientation predicate; MOV:111[0] | falling declaration | low=rover; high=target; no middle motion process |

## MOV:112 — proposed “target approach pending”

Packet status: **not canonical**.

### A. Address and generated forms

| Field | Fixed value |
|---|---|
| Canonical ID | `MOV:112` |
| Universal slot | pending outward process |
| Family-qualified transliteration | `gi·kon` |
| Local compact root | `kon` |
| Formal carrier | `gi-ki-ki-nu` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 4, 2]` |

### B. Candidate analysis

The Phase 2 candidate was **potential target approach** — “A potential displacement toward a target position that is not presently active or completed.” It is treated only as evidence of a prior proposal.

| Candidate | Why it fits | Useful coverage | Territory consumed | Conflicts / limitations | Result |
|---|---|---|---|---|---|
| target approach pending | It supplies the pending phase of the targetward displacement triplet. | set to approach, queued trip to, planned arrival movement | Only a specified targetward motion before onset. | It does not itself encode schedule time, target accessibility, probability, or permission. | selected |
| pending arrival | Every planned targetward trip has a not-yet-completed arrival. | expected arrival, due in, not here yet | Any absence of completed arrival, including active approach and failure. | Negatively defined and phase-ambiguous: an active MOV:111 would also be a 'pending arrival.' | rejected |
| unavailable destination | Unreachability can prevent a targetward process from beginning. | closed destination, blocked endpoint | Destination condition rather than process. | MOV:012 already canonically names a pending/inaccessible destination entity. | rejected |

### C. Invariant atomic definition

**A specified displacement toward a target position that has not yet begun.**

This definition has one center: target-relative displacement, in its pending phase.

### D. Address justification

- **first trit:** 1 = process/action/transformation: this root predicates displacement, not a position, route, capacity, or relationship.
- **second trit:** 1 = outward/target: the process is defined by displacement relative to a selected target position.
- **third trit:** 2 = pending: the defining displacement/traversal is specified but has not begun.

### E. Inclusion and exclusion boundaries

- **Includes:** A targetward displacement represented as a valid specified operation before onset.
- **Does not include:** An inaccessible destination, an active approach, expected time of arrival, waiting duration, or target selection alone.
- **Nearest same-family handling:** MOV:111 handles execution; MOV:012 handles a destination that is defined but not currently reachable.
- **Cross-domain handling:** A schedule requires later timing/LOG/DAT semantics; a living target adds LIF; material transport adds MAT.

### F–G. Triplet and existing-Motion contrast

Triplet axis: **target-relative displacement**; this root is the **pending** member. MOV:012 is a pending destination condition; MOV:112 is a pending movement operation toward a destination.

### H. Cross-family collision audit

Pure Motion reading: **stands alone** when literal or explicitly modeled displacement/traversal is asserted. The seven-family detailed dispositions are in `reviews/MOV_100_122_collision_report.md`.

- **MAT:** The Motion root stands alone for target-relative displacement. Form a compound for material payload/delivery; it must not mean force application or material transformation at the target.
- **MIN:** Physical/sequential approach stands alone; attention turning toward a subject or mental goal belongs to MIN, with a compound only when both processes occur.
- **CON:** Approaching a participant can compound with CON, but contacting, delivering a message, or establishing a bond is not target arrival.
- **STR:** Entry into or docking with a structure compounds MOV with STR. Construction, containment, or installation is not arrival alone.
- **DAT:** A data packet's spatial/logical arrival may compound with MOV, but write, retrieval, delivery, and assignment are DAT processes.
- **CRE:** Moving toward a design target can modify a CRE graph, but instantiation or transformation of that target is CRE, not arrival.
- **ORI:** Reaching a position stands alone; manifestation or transition into actuality is ORI, not target arrival.

### I. Tailored runtime-state interpretations

- **[0]:** The planned targetward motion is canceled, invalid, or unavailable.
- **[1]:** The targetward displacement is validly specified and has not begun.
- **[2]/num:** The planned operation itself is dormant or unresolved—for example, awaiting confirmation.

**Lexical third trit versus runtime [2]/num:** Lexical trit 2 permanently identifies the pre-onset targetward operation. MOV:112[1] validates that pending operation; MOV:112[2] makes the operation's own current status unresolved.

### J. Examples

| Type | Semantic graph | Literal gloss | Natural English | Runtime | Contour | Roles/registers |
|---|---|---|---|---|---|---|
| conversation | `(self:LIF:001[1]) -actor→ (e:MOV:112[1]) -target→ (home:MOV:010[1])` | conscious self; pending target approach; home destination | I'm set to head home. | [1] targetward operation valid but unbegun | fall-rise possibility | low=LIF:001; middle=MOV:112; high=home; sustained=timing context |
| physical_spatial | `(rover:x) -actor→ (e:MOV:112[1]) -target→ (marker:MOV:010[1])` | rover; specified unbegun targetward displacement; marker | The rover is queued to move to the marker. | [1] queue valid | falling declaration | low=rover; middle=pending approach; high=marker; sustained=terrain |
| temporal_sequential | `(job:x) -actor→ (e:MOV:112[1]) -target→ (stage3:MOV:010[1])` | job; pending targetward movement; third sequence position | The job is queued to advance to stage three. | [1] sequential operation pending | falling declaration | low=job; middle=MOV:112; high=stage3; sustained=workflow |
| cross_family_compound | `(other:LIF:011[1]) -actor→ (e:MOV:112[1]) -target→ (self:LIF:001[1])` | conscious other + pending approach + conscious target | She plans to come to me. | [1] motion plan valid; mental intention is separate | falling declaration | low=LIF:011; middle=MOV:112; high=LIF:001; sustained=context |
| executable_programming | `enqueue(e:MOV:112[1]); target(e)=MOV:010; started(e)=false` | enqueue targetward displacement; target bound; execution false | Queue movement to the target. | [1] pending operation accepted | sharply falling command | low=actor binding; middle=queue; high=target binding; sustained=scheduler |
| counterexample | `(target:MOV:012[1]); no movement operation` | destination defined but inaccessible; no queued approach | The destination is closed; no trip has been scheduled. | MOV:012[1]; MOV:112 absent | falling declaration | high=pending destination entity; no middle process |

## MOV:120 — proposed “route traversal completed”

Packet status: **not canonical**.

### A. Address and generated forms

| Field | Fixed value |
|---|---|
| Canonical ID | `MOV:120` |
| Universal slot | completed systemic process |
| Family-qualified transliteration | `gi·kim` |
| Local compact root | `kim` |
| Formal carrier | `gi-ki-nu-ma` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 0, 0]` |

### B. Candidate analysis

The Phase 2 candidate was **completed shared-frame movement** — “Completion of a mover's change of position relative to a shared or environmental reference frame.” It is treated only as evidence of a prior proposal.

| Candidate | Why it fits | Useful coverage | Territory consumed | Conflicts / limitations | Result |
|---|---|---|---|---|---|
| route traversal completed | A completed systemic Motion process should be defined by participation in a shared route system, not by an unrelated change domain. | complete a route, finish a circuit, traverse a workflow, complete a transport run | Only completion of traversal through an ordered shared path. | The route must be system-defined or shared; isolated point-to-point arrival remains MOV:110. | selected |
| system transition completed | The address is a completed systemic process and Motion can metaphorically express transitions. | phase change, deployment, epoch change, workflow completion | Every domain's system-level transformation. | It invades STR, CRE, LOG, and ORI and lacks a stable Motion-specific center. | rejected |
| circulation cycle completed | Circulation is systemic motion and has clear completed cycles. | orbit complete, circuit complete, one loop finished | Only cyclic route motion. | Too narrow for non-cyclic shared routes; repetition/looping should be supplied by contour or a route compound. | rejected |

### C. Invariant atomic definition

**Completion of motion along a shared or system-defined route.**

This definition has one center: system-route traversal, in its completed phase.

### D. Address justification

- **first trit:** 1 = process/action/transformation: this root predicates displacement, not a position, route, capacity, or relationship.
- **second trit:** 2 = systemic/shared: the process is defined by traversal of a route shared or established by a system.
- **third trit:** 0 = completed: the defining displacement/traversal has reached its endpoint condition.

### E. Inclusion and exclusion boundaries

- **Includes:** Completion of traversal whose identity depends on an established ordered route shared by a system, group, or workflow.
- **Does not include:** The route entity itself, isolated arrival without route salience, circulation of material/data as such, or ontological/system reconfiguration.
- **Nearest same-family handling:** MOV:121 handles traversal in progress; MOV:020 names the established route; MOV:021 names a network currently carrying flow.
- **Cross-domain handling:** Compound with MAT for transported resources, DAT for data moving through the route, LIF for a group, STR for infrastructure, or ORI only when an ontological event is independently asserted.

### F–G. Triplet and existing-Motion contrast

Triplet axis: **system-route traversal**; this root is the **completed** member. MOV:020 is an established route whether or not used; MOV:120 is the completed use/traversal of such a route.

### H. Cross-family collision audit

Pure Motion reading: **stands alone** when literal or explicitly modeled displacement/traversal is asserted. The seven-family detailed dispositions are in `reviews/MOV_100_122_collision_report.md`.

- **MAT:** The Motion root stands alone for route traversal. Form a compound when matter or energy circulates; it must not cover resource exchange or physical transformation.
- **MIN:** Route traversal stands alone; progress through reasoning, learning, or attention states belongs to MIN unless those states are explicitly modeled as sequence positions.
- **CON:** Moving through a route can carry communication as a compound; broadcast, routing of meanings, and participant synchronization remain CON.
- **STR:** Infrastructure may supply the route in a compound. Structural deployment or organizational transition is STR and must not be covered by route traversal.
- **DAT:** Data may traverse a route as a compound. Replication, indexing, synchronization, and information flow are DAT and must not be absorbed by MOV.
- **CRE:** A generative workflow may be represented as a route only when ordered positions are explicit. Creation or system generation remains CRE.
- **ORI:** Traversal of an ordered route stands alone; epochal, temporal, cosmological, or ontological transition belongs to ORI unless positions/routes are explicitly part of the graph.

### I. Tailored runtime-state interpretations

- **[0]:** The route-traversal completion is not a valid current fact or has been invalidated.
- **[1]:** The defined route traversal has completed.
- **[2]/num:** Completion of the route traversal is awaiting confirmation or unresolved.

**Lexical third trit versus runtime [2]/num:** Lexical trit 0 makes route-traversal completion the permanent concept. MOV:120[2] is uncertainty about that completion; MOV:122 is a route traversal lexically specified before onset.

### J. Examples

| Type | Semantic graph | Literal gloss | Natural English | Runtime | Contour | Roles/registers |
|---|---|---|---|---|---|---|
| conversation | `(bus:x) -actor→ (e:MOV:120[1]) -route→ (line:MOV:020[1])` | bus; completed system-route traversal; established line | The bus finished its route. | [1] traversal completion valid | falling declaration | low=bus; middle=MOV:120; high=route completion; sustained=MOV:020 |
| physical_spatial | `(robot:x) -actor→ (e:MOV:120[1]) -route→ (corridor:MOV:020[1])` | robot; completed route traversal; corridor | The robot completed the corridor run. | [1] route endpoint/cycle met | falling declaration | low=robot; middle=traversal; high=completed run; sustained=corridor |
| temporal_sequential | `(job:x) -actor→ (e:MOV:120[1]) -route→ (workflow:MOV:020[1])` | job; completed traversal; ordered workflow | The job traversed the whole workflow. | [1] sequence traversal complete | falling declaration | low=job; middle=MOV:120; high=workflow completion; sustained=workflow |
| cross_family_compound | `(community:LIF:021[1]) -actor→ (e:MOV:120[1]) -route→ (evacuation:MOV:020[1])` | living community + completed shared-route traversal + evacuation route | The community completed the evacuation route. | [1] community active; traversal complete | falling declaration | low=LIF:021; middle=MOV:120; high=route completion; sustained=MOV:020 |
| executable_programming | `assert(e:MOV:120[1]); route(e)=MOV:020; visited_required_positions(e)=true` | assert route traversal completed and required ordered positions visited | Assert that the route run completed. | [1] route-completion postcondition valid | sharply falling command | low=mover; middle=operation; high=completion result; sustained=route |
| counterexample | `(route:MOV:020[1]); traversals=0` | established route exists; no completed traversal | The route exists, but nobody has completed it. | MOV:020[1]; MOV:120[0] | falling declaration | sustained=route entity; no actor/process/result registers |

## MOV:121 — proposed “route traversal active”

Packet status: **not canonical**.

### A. Address and generated forms

| Field | Fixed value |
|---|---|
| Canonical ID | `MOV:121` |
| Universal slot | active systemic process |
| Family-qualified transliteration | `gi·kik` |
| Local compact root | `kik` |
| Formal carrier | `gi-ki-nu-ki` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 0, 2]` |

### B. Candidate analysis

The Phase 2 candidate was **active shared-frame movement** — “Ongoing change of a mover's position relative to a shared or environmental reference frame.” It is treated only as evidence of a prior proposal.

| Candidate | Why it fits | Useful coverage | Territory consumed | Conflicts / limitations | Result |
|---|---|---|---|---|---|
| route traversal active | It is an active systemic Motion process with route membership as its organizing relation. | travel through a route, traffic in a corridor, progress through a workflow, circulate with loop contour | Only active traversal of an ordered shared path. | It does not identify what is carried, whether participants are synchronized, or whether the route is cyclic. | selected |
| system flow | Flow is active systemic motion. | traffic, data flow, resource circulation, process flow | Motion plus DAT, MAT, CON, and temporal state change. | The carrier/domain list is not atomic and would absorb other families' core processes. | rejected |
| coordinated movement | Shared orientation can express collective coordination. | convoy, flocking, synchronization, march | Participant coordination and relationships. | Too narrow and likely belongs partly to MOV 2xx or CON; one mover can still traverse a system route. | rejected |

### C. Invariant atomic definition

**Ongoing motion along a shared or system-defined route.**

This definition has one center: system-route traversal, in its active phase.

### D. Address justification

- **first trit:** 1 = process/action/transformation: this root predicates displacement, not a position, route, capacity, or relationship.
- **second trit:** 2 = systemic/shared: the process is defined by traversal of a route shared or established by a system.
- **third trit:** 1 = active: the defining displacement/traversal is presently under way.

### E. Inclusion and exclusion boundaries

- **Includes:** Motion currently progressing through an ordered path whose identity is systemic, shared, or workflow-defined.
- **Does not include:** The active route network entity, data transfer itself, resource exchange itself, group synchronization, or generic target approach.
- **Nearest same-family handling:** MOV:120 handles completed traversal; MOV:122 handles specified unbegun traversal; MOV:021 is the active flow-network entity.
- **Cross-domain handling:** Use compounds to type movers or payloads: LIF for living participants, MAT for material transport, DAT/CON for information or communication, STR for infrastructure.

### F–G. Triplet and existing-Motion contrast

Triplet axis: **system-route traversal**; this root is the **active** member. MOV:021 names a route network currently carrying flow; MOV:121 predicates traversal by a mover or cohort through a route.

### H. Cross-family collision audit

Pure Motion reading: **stands alone** when literal or explicitly modeled displacement/traversal is asserted. The seven-family detailed dispositions are in `reviews/MOV_100_122_collision_report.md`.

- **MAT:** The Motion root stands alone for route traversal. Form a compound when matter or energy circulates; it must not cover resource exchange or physical transformation.
- **MIN:** Route traversal stands alone; progress through reasoning, learning, or attention states belongs to MIN unless those states are explicitly modeled as sequence positions.
- **CON:** Moving through a route can carry communication as a compound; broadcast, routing of meanings, and participant synchronization remain CON.
- **STR:** Infrastructure may supply the route in a compound. Structural deployment or organizational transition is STR and must not be covered by route traversal.
- **DAT:** Data may traverse a route as a compound. Replication, indexing, synchronization, and information flow are DAT and must not be absorbed by MOV.
- **CRE:** A generative workflow may be represented as a route only when ordered positions are explicit. Creation or system generation remains CRE.
- **ORI:** Traversal of an ordered route stands alone; epochal, temporal, cosmological, or ontological transition belongs to ORI unless positions/routes are explicitly part of the graph.

### I. Tailored runtime-state interpretations

- **[0]:** The route traversal is not executing or the assertion is false.
- **[1]:** Motion is currently progressing along the shared/system route.
- **[2]/num:** The active traversal is suspended, blocked, or unresolved as an executing operation.

**Lexical third trit versus runtime [2]/num:** Lexical trit 1 selects active route traversal. MOV:121[2] is that active operation in a suspended/unresolved runtime condition, whereas MOV:122 is lexically a not-yet-begun traversal.

### J. Examples

| Type | Semantic graph | Literal gloss | Natural English | Runtime | Contour | Roles/registers |
|---|---|---|---|---|---|---|
| conversation | `(traffic:x) -actor→ (e:MOV:121[1]) -route→ (line:MOV:021[1])` | traffic; active route traversal; live route network | Traffic is moving along the line. | [1] traversal active | falling declaration | low=traffic; middle=MOV:121; high=forward route progress; sustained=MOV:021 |
| physical_spatial | `(convoy:x) -actor→ (e:MOV:121[1]) -route→ (corridor:MOV:020[1])` | convoy; ongoing traversal; shared corridor | The convoy is moving through the corridor. | [1] route progress executing | falling declaration | low=convoy; middle=traversal; high=next route position; sustained=corridor |
| temporal_sequential | `(batch:x) -actor→ (e:MOV:121[1]) -route→ (pipeline:MOV:020[1])` | batch; active traversal; ordered pipeline | The batch is progressing through the pipeline. | [1] sequence traversal active | falling declaration | low=batch; middle=MOV:121; high=next stage; sustained=pipeline |
| cross_family_compound | `(community:LIF:021[1]) -actor→ (e:MOV:121[1]) -route→ (trail:MOV:020[1])` | living community + active shared-route traversal + established trail | The group is moving together along the trail. | [1] community and traversal active; togetherness comes from collective actor | repeated-loop contour only if cyclic | low=LIF:021; middle=MOV:121; high=route progress; sustained=MOV:020 |
| executable_programming | `run(e:MOV:121[1]); route(e)=MOV:020; invariant=ordered_progress(e)` | execute traversal along bound route under ordered-progress invariant | Run the route traversal. | [1] system-route operation executing | sharply falling command | low=mover set; middle=operation; high=next position; sustained=route |
| counterexample | `(records:DAT:*[1]) -replicate_across→ (network:DAT:*[1]); spatial_route_unspecified` | data replication; no Motion route asserted | The database is replicating records; that is not automatically route traversal. | [1] on DAT process; MOV:121 absent unless a route model is added | falling declaration | low=data source; middle=DAT process; high=replica target; no MOV route register |

## MOV:122 — proposed “route traversal pending”

Packet status: **not canonical**.

### A. Address and generated forms

| Field | Fixed value |
|---|---|
| Canonical ID | `MOV:122` |
| Universal slot | pending systemic process |
| Family-qualified transliteration | `gi·kin` |
| Local compact root | `kin` |
| Formal carrier | `gi-ki-nu-nu` |
| Harmonic signature | `[0, 2, 7]` |
| Relative note path | `[0, 2, 0, -2]` |

### B. Candidate analysis

The Phase 2 candidate was **potential shared-frame movement** — “A potential change of a mover's position relative to a shared or environmental reference frame that is not presently active or completed.” It is treated only as evidence of a prior proposal.

| Candidate | Why it fits | Useful coverage | Territory consumed | Conflicts / limitations | Result |
|---|---|---|---|---|---|
| route traversal pending | It completes the systemic traversal triplet with a clear pre-onset process. | queued route run, planned circuit, staged workflow traversal, convoy awaiting start | Only a specified system-route traversal before onset. | Schedule time, delay cause, route availability, and payload type are external. | selected |
| scheduled system transition | Scheduling and pending systemic action commonly coincide. | cron job, timetable, planned rollout, future phase | Time, logic, and all transformation domains. | Scheduling is not Motion-specific and cannot be settled before LOG/DAT/ORI and timing grammar review. | rejected |
| dormant route | An inactive system route is associated with pending traversal. | closed line, unused corridor, suspended service | Route entity condition. | MOV:022 already canonically names a dormant route system; the 1xx address must remain a process. | rejected |

### C. Invariant atomic definition

**Motion along a shared or system-defined route that is specified but has not yet begun.**

This definition has one center: system-route traversal, in its pending phase.

### D. Address justification

- **first trit:** 1 = process/action/transformation: this root predicates displacement, not a position, route, capacity, or relationship.
- **second trit:** 2 = systemic/shared: the process is defined by traversal of a route shared or established by a system.
- **third trit:** 2 = pending: the defining displacement/traversal is specified but has not begun.

### E. Inclusion and exclusion boundaries

- **Includes:** A route-specific traversal operation represented as validly specified before its motion begins.
- **Does not include:** A dormant route, a timetable itself, delay duration/cause, active traffic, or a generic system transformation.
- **Nearest same-family handling:** MOV:121 handles execution; MOV:022 handles the dormant route entity.
- **Cross-domain handling:** A scheduled transport combines this root with timing/LOG and MAT payload semantics after those are reviewed; a living cohort adds LIF.

### F–G. Triplet and existing-Motion contrast

Triplet axis: **system-route traversal**; this root is the **pending** member. MOV:022 is a dormant route system regardless of any operation; MOV:122 is a pending act of traversing a route that may itself be active or inactive.

### H. Cross-family collision audit

Pure Motion reading: **stands alone** when literal or explicitly modeled displacement/traversal is asserted. The seven-family detailed dispositions are in `reviews/MOV_100_122_collision_report.md`.

- **MAT:** The Motion root stands alone for route traversal. Form a compound when matter or energy circulates; it must not cover resource exchange or physical transformation.
- **MIN:** Route traversal stands alone; progress through reasoning, learning, or attention states belongs to MIN unless those states are explicitly modeled as sequence positions.
- **CON:** Moving through a route can carry communication as a compound; broadcast, routing of meanings, and participant synchronization remain CON.
- **STR:** Infrastructure may supply the route in a compound. Structural deployment or organizational transition is STR and must not be covered by route traversal.
- **DAT:** Data may traverse a route as a compound. Replication, indexing, synchronization, and information flow are DAT and must not be absorbed by MOV.
- **CRE:** A generative workflow may be represented as a route only when ordered positions are explicit. Creation or system generation remains CRE.
- **ORI:** Traversal of an ordered route stands alone; epochal, temporal, cosmological, or ontological transition belongs to ORI unless positions/routes are explicitly part of the graph.

### I. Tailored runtime-state interpretations

- **[0]:** The planned route traversal is canceled, invalid, or unavailable.
- **[1]:** A valid route traversal is queued and has not begun.
- **[2]/num:** The queued traversal itself is dormant or unresolved, such as a tentative run awaiting authorization.

**Lexical third trit versus runtime [2]/num:** Lexical trit 2 permanently selects a not-yet-begun route traversal. MOV:122[1] validates the queue; MOV:122[2] makes the queued operation's current status unresolved.

### J. Examples

| Type | Semantic graph | Literal gloss | Natural English | Runtime | Contour | Roles/registers |
|---|---|---|---|---|---|---|
| conversation | `(convoy:x) -actor→ (e:MOV:122[1]) -route→ (road:MOV:020[1])` | convoy; pending route traversal; established road | The convoy is queued to take the road. | [1] route run valid but unbegun | falling declaration | low=convoy; middle=MOV:122; high=future route run; sustained=road |
| physical_spatial | `(carts:x) -actor→ (e:MOV:122[1]) -route→ (loop:MOV:020[1])` | carts; pending traversal; warehouse loop | The carts are staged for the warehouse loop. | [1] staged route operation | fall-rise possibility | low=carts; middle=pending traversal; high=run onset; sustained=loop |
| temporal_sequential | `(batch:x) -actor→ (e:MOV:122[1]) -route→ (pipeline:MOV:020[1])` | batch; specified unbegun traversal; ordered pipeline | The batch is queued to enter the pipeline. | [1] workflow traversal pending | falling declaration | low=batch; middle=MOV:122; high=future first stage; sustained=pipeline |
| cross_family_compound | `(community:LIF:021[1]) -actor→ (e:MOV:122[1]) -route→ (migration:MOV:020[1])` | living community + pending route traversal + migration route | The community is prepared to begin the migration route. | [1] collective actor active; route operation pending | fall-rise possibility | low=LIF:021; middle=MOV:122; high=planned run; sustained=MOV:020 |
| executable_programming | `enqueue(e:MOV:122[1]); route(e)=MOV:020; started(e)=false` | enqueue system-route traversal; bind route; execution not started | Queue the route run. | [1] pending traversal accepted | sharply falling command | low=mover set; middle=queue; high=route binding; sustained=scheduler |
| counterexample | `(route:MOV:022[1]); operation unspecified` | dormant route system; no pending traversal event | The rail line is inactive, but no run is queued. | MOV:022[1]; MOV:122 absent | falling declaration | sustained=dormant route entity; no actor/process/result registers |

## K. English Motion coverage tests

| English concept | Mapping classification | Proposed expression | Reason |
|---|---|---|---|
| leave | one root in this block | MOV:101 while under way; MOV:100 once completed | English tense/aspect selects the phase; the atomic center is source-relative displacement. |
| depart | one root in this block | MOV:101 or MOV:100 | Same source-oriented triplet as leave. |
| go | compound or context-selected root | MOV:101 away from a source, MOV:111 toward a target, or MOV:121 along a system route | English go underspecifies orientation and must not be forced into one atom. |
| approach | one root in this block | MOV:111 | Active target-relative displacement. |
| arrive | one root in this block | MOV:110 | Completed target-relative displacement. |
| follow | compound or unresolved vocabulary gap | MOV:111 toward a moving target plus a future Motion relationship/constraint | Following includes sustained target relation and retargeting; active approach alone is not always enough. |
| wait | contour/timing grammar or unresolved vocabulary gap | A pending root may be present, but waiting itself is not MOV:102/112/122 | Waiting is duration without required displacement. |
| pause | runtime state plus timing grammar | MOV:101[2], MOV:111[2], or MOV:121[2] when an active operation is suspended | Runtime [2] suspends/defers the active operation; lexical third-trit 2 would instead name a pre-onset process. |
| stop | runtime state plus contour | Active Motion root [0], often with sharply falling command contour | Stopping terminates a currently active operation; exact cessation semantics may need later grammar. |
| continue | runtime state plus contour/timing grammar | Active root [1] with continuation or repeated-loop contour where appropriate | Continuation is aspect over an active process, not a new atomic direction. |
| cross | compound | MOV:121 + MOV:020 with a boundary/route relation | Crossing requires a boundary/path model; the route traversal supplies the Motion process. |
| return | compound | MOV:111/MOV:110 with target=MOV:000; departure history may also be referenced | Return is targetward movement whose target is a prior origin. |
| redirect | compound or operation sequence | Bind a new MOV:010 target, then use MOV:112 or MOV:111; cancel/replace the earlier targetward operation | Redirection changes a target relation rather than introducing a new displacement phase. |
| move together | compound | LIF:021 collective actor + MOV:121, with coordination added later if needed | Collective actor supplies togetherness; MOV:121 supplies shared-route traversal. |
| circulate | compound plus contour | MOV:121 + MOV:020/MOV:021 + repeated-loop contour | Looping/cycle structure is not baked into the atomic definition. |
| repeat a route | compound plus contour | MOV:121 + MOV:020 + repeated-loop contour | Repetition modifies route traversal. |
| schedule | different family or later grammar | MOV:102/112/122 can be the scheduled operation, but scheduling belongs to future timing/LOG/DAT review | The Motion root must not absorb calendar or scheduler semantics. |
| delay | contour/timing grammar or unresolved vocabulary gap | Pending/suspended Motion root plus duration/cause | Delay is a relation between expected and actual onset/progress. |
| transition | context-selected family | MOV only when positions or ordered route states are explicitly modeled; STR/ORI/CRE for their own domains | Generic change is not automatically Motion. |
| transport | compound | MOV:111 or MOV:121 + MAT payload/carrier semantics | Transport combines displacement with a material participant relation. |
| exit | compound | MOV:101/MOV:100 + a STR boundary/container relation | Leaving a bounded region adds structural boundary semantics. |
| enter | compound | MOV:111/MOV:110 + a STR boundary/container relation | Target arrival alone does not encode containment. |
| orbit | compound plus contour | MOV:121 + route/cycle relation + repeated-loop contour | Orbital geometry and repetition are not atomic here. |
| wander | unresolved vocabulary gap | No forced mapping | Wandering lacks a stable source, target, or system-route axis and may require manner/trajectory vocabulary. |
| reverse | compound or unresolved vocabulary gap | Replace target/source bindings or apply a future direction relation | Reversal is a relation between successive motion vectors, not one phase root. |

## L. Packet-level analysis

### Nine-root contrast matrix

| Orientation / phase | Completed (third 0) | Active (third 1) | Pending (third 2) |
|---|---|---|---|
| Source / inward (second 0) | MOV:100 completed departure | MOV:101 departing | MOV:102 specified departure before onset |
| Target / outward (second 1) | MOV:110 arrived | MOV:111 approaching | MOV:112 specified approach before onset |
| Systemic / shared (second 2) | MOV:120 completed route traversal | MOV:121 traversing route | MOV:122 specified route traversal before onset |

### Triplet-coherence assessment

- **MOV:100–102:** high coherence. All three are one source-relative displacement operation separated only by lexical phase.
- **MOV:110–112:** high coherence. All three are one target-relative displacement operation separated only by lexical phase.
- **MOV:120–122:** good but lower-confidence coherence. Restricting the axis to system-route traversal avoids the Phase 2 collision-prone bundle of transfer, circulation, signals, and temporal transition.

### Cross-family collision summary

| Risk area | Resolution |
|---|---|
| Physical displacement vs MAT | MOV provides displacement; MAT supplies body, force, energy, or payload in a compound. |
| Mental/attention change vs MIN | Pure mental shifts are MIN; use MOV only when a position/route model is explicit. |
| Participant transmission vs CON | Contact and message exchange are CON; movement of a participant may compound with MOV. |
| Structural transition vs STR | Reorganization is STR; exit/entry through a structure compounds STR with MOV. |
| Information flow vs DAT | Encoding/copying/transmission is DAT; route traversal by a data object may compound with MOV. |
| Transformation/generation vs CRE | Creation is CRE; relocation of a created form may compound with MOV. |
| Temporal/ontological transition vs ORI | Becoming and actuality are ORI; MOV requires explicit ordered positions or a route. |

### Uncovered Motion concepts

- scalar speed and acceleration;
- direction/vector without a target;
- rotation about a local axis;
- proximity and distance relations;
- boundary crossing as such;
- pursuit/following a moving target;
- wandering or pathless motion;
- reversal/redirect as a relation between motion operations;
- transport roles such as carrier and payload;
- duration-based waiting, pause, and delay.

These are not filled here. Some may belong to MOV:200–222, compounds, or timing/contour grammar, but that later work is not authorized.

### Concepts intentionally reserved for compounds or grammar

- `return` = targetward movement with a prior origin as target;
- `transport` = Motion process + MAT payload/carrier;
- `enter/exit` = Motion process + STR boundary/container;
- `circulate/orbit/repeat a route` = route traversal + route/cycle relation + repeated-loop contour;
- `move together` = collective actor + route traversal, with coordination added if needed;
- `schedule/delay/wait/pause/continue/stop` = Motion operation plus runtime state, timing, contour, and later grammar.

### Unresolved decisions

- Whether system-route traversal is the final best systemic axis (confidence is lower than the source and target triplets).
- Whether a single mover on public infrastructure is sufficient for the systemic/shared trit; this packet proposes yes when the route, not merely the target, defines the operation.
- Where direction, pursuit, crossing, and reversal ultimately live.
- Which exact timing/grammar mechanisms express wait, pause, continue, schedule, and delay.

### Proposed titles and invariant definitions

- **MOV:100 — source departure completed:** Completion of a mover's displacement away from a specified source position. (confidence 0.90)
- **MOV:101 — source departure active:** Ongoing displacement of a mover away from a specified source position. (confidence 0.93)
- **MOV:102 — source departure pending:** A specified displacement away from a source position that has not yet begun. (confidence 0.87)
- **MOV:110 — target arrival completed:** Completion of a mover's displacement to a specified target position. (confidence 0.95)
- **MOV:111 — target approach active:** Ongoing displacement of a mover toward a specified target position. (confidence 0.95)
- **MOV:112 — target approach pending:** A specified displacement toward a target position that has not yet begun. (confidence 0.89)
- **MOV:120 — route traversal completed:** Completion of motion along a shared or system-defined route. (confidence 0.83)
- **MOV:121 — route traversal active:** Ongoing motion along a shared or system-defined route. (confidence 0.87)
- **MOV:122 — route traversal pending:** Motion along a shared or system-defined route that is specified but has not yet begun. (confidence 0.83)

### Approval checklist

- [x] Generated fields match the accepted algorithms.
- [x] Each root has at least two first-principles candidates.
- [x] Each proposed invariant has one semantic center.
- [x] Each triplet has a single shared axis with completed/active/pending contrast.
- [x] MOV:000–022 entity/process boundaries are explicit.
- [x] MAT, MIN, CON, STR, DAT, CRE, and ORI collisions were audited.
- [x] Runtime [0]/[1]/[2] readings are tailored per root.
- [x] At least 20 English Motion concepts were tested without forced atomization.
- [ ] User approves or revises each proposed meaning.
- [ ] User explicitly canonizes the nine roots. **Not satisfied.**
- [ ] Authorization to begin MOV:200–222. **Not granted.**
- [ ] Authorization to begin Gate 4. **Not granted.**

## M. Document status

This is the detailed companion record. The main language document receives only a concise authority and packet-status summary. Catalogue entries remain concise candidates until explicit user approval. No meaning in this packet is canonicalized by this review.
