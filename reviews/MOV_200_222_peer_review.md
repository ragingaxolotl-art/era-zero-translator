# MOV:200–222 Peer Review

Status: **READY FOR USER APPROVAL — NOT CANONICAL**

Scope is strictly `MOV:200–222`. The fixed generated fields are preserved; only candidate semantic titles, definitions, boundaries, and ownership are reviewed. `MOV:100–122` is treated as approved canonical baseline. No MAT root, other block, compound system, or Gate 4 work is begun.

## Executive recommendation

The strongest 2xx architecture is:

- `MOV:200–202`: **self-mobility capacity** — enduring / presently available / latent;
- `MOV:210–212`: **target-relative position** — established / live / unresolved;
- `MOV:220–222`: **shared-frame positional configuration** — established / live / unrealized possible.

This design keeps all nine roots at first-trit `2`: none is an entity in disguise, and none asserts a movement event. Routes, topology, reachability, permission, maps, coordination, force, and planning remain separate.

## Fixed generated forms

| ID | Universal slot | Transliteration | Compact | Formal carrier | Harmony | Relative note path |
|---|---|---|---|---|---|---|
| `MOV:200` | stable inward capacity | `gi·mam` | `mam` | `gi-nu-ma-ma` | `0, 2, 7` | `0, -2, -2, -2` |
| `MOV:201` | active inward capacity | `gi·mak` | `mak` | `gi-nu-ma-ki` | `0, 2, 7` | `0, -2, -2, 0` |
| `MOV:202` | dormant inward capacity | `gi·man` | `man` | `gi-nu-ma-nu` | `0, 2, 7` | `0, -2, -2, -4` |
| `MOV:210` | stable outward relationship | `gi·mom` | `mom` | `gi-nu-ki-ma` | `0, 2, 7` | `0, -2, 0, 0` |
| `MOV:211` | active outward relationship | `gi·mok` | `mok` | `gi-nu-ki-ki` | `0, 2, 7` | `0, -2, 0, 2` |
| `MOV:212` | unresolved outward relationship | `gi·mon` | `mon` | `gi-nu-ki-nu` | `0, 2, 7` | `0, -2, 0, -2` |
| `MOV:220` | stable systemic relationship | `gi·mim` | `mim` | `gi-nu-nu-ma` | `0, 2, 7` | `0, -2, -4, -4` |
| `MOV:221` | active systemic relationship | `gi·mik` | `mik` | `gi-nu-nu-ki` | `0, 2, 7` | `0, -2, -4, -2` |
| `MOV:222` | unrealized systemic possibility | `gi·min` | `min` | `gi-nu-nu-nu` | `0, 2, 7` | `0, -2, -4, -6` |

## MOV:200 — enduring self-mobility

**Current candidate rationale.** The provisional author used stable + inward + capacity to reserve an enduring ability of a mover to relocate itself. That choice correctly avoided naming an actual movement event.

| Candidate | Atomic | Address | MOV | Neighbor | vs MOV 000–122 | Cross-family | Everyday | Technical | Compound | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| stable mobility | 9 | 9 | 9 | 8 | 9 | 8 | 9 | 9 | 10 | **80/90** |
| movement-initiation capability | 8 | 8 | 9 | 7 | 5 | 8 | 8 | 9 | 8 | **70/90** |
| range of motion | 8 | 8 | 8 | 8 | 9 | 5 | 8 | 8 | 8 | **70/90** |
| positional freedom | 7 | 8 | 8 | 7 | 8 | 5 | 8 | 7 | 8 | **66/90** |

- **stable mobility:** It directly realizes stable inward Motion capacity. Covers Mobile, locomotion-capable, enduring self-relocation capability. Consumes The mover's durable capacity, independent of any current journey. Risk: The word stable can be confused with immobility; dependable should not imply physical integrity or permission.
- **movement-initiation capability:** Initiation is source-oriented and capacity-like. Covers Can start, launch capability, ability to set off. Consumes The threshold between rest and motion. Risk: It crowds MOV:102 potential departure and excludes movers that can continue but cannot self-initiate.
- **range of motion:** A stable inward capacity can be construed as a reachable set. Covers Joint range, travel envelope, workspace, mobility radius. Consumes Quantified extents of possible self-position. Risk: It imports boundaries, geometry, and physical constitution from STR and MAT; it is better composed from mobility plus bounds.
- **positional freedom:** Freedom can behave like a stable inward movement capacity. Covers Freedom of movement, unconstrained travel, maneuverability. Consumes Absence of external restrictions. Risk: It makes LOG permission and STR constraints part of the atom and treats capacity as a negative condition.

**Recommendation:** **enduring self-mobility** (80/90; confidence 94%).

> An enduring capacity of a mover to change its own position.

**Boundaries.** Includes a mover's durable capacity for self-positional change whether or not it is moving now. Applies to physical or explicitly modeled abstract movers. Does not assert that the capacity is currently usable, that movement is occurring, or that departure is potential.

**Exclusions.** Current availability is MOV:201. Latent or currently unavailable capacity is MOV:202. Actual shared-frame movement is MOV:120–122. Body integrity, energy, and force belong to MAT; permission belongs to LOG; range bounds require STR or quantitative composition.

**Nearest approved Motion contrasts.** `MOV:001`: present position is an occupied locus; MOV:200 is a capacity. `MOV:100–102`: departure roots are processes; MOV:200 does not assert a departure token. `MOV:120–122`: shared-frame movement roots describe positional change; MOV:200 describes durable capability.

**Address fit.** First trit `2` selects capacity/relationship rather than event; second trit selects the mover itself; third trit selects enduring or established.

**Runtime states.** `[0]` Denies that the mover has the asserted enduring self-mobility capacity. `[1]` Affirms that the mover possesses the enduring capacity, even if presently at rest. `[2]/num` Marks the truth or current status of that enduring-capacity assertion as dormant, remembered, possible, or unresolved; it does not turn the root into MOV:202.

**Examples.** `MOV:200[1](MOVER=animal)` — The animal is mobile by nature. `MOV:200[1](MOVER=rover)` — The rover was built to relocate itself. `MOV:200[1](MOVER=bird)` — Even while resting, the bird can change where it is.

**Programming.** `capabilities(robot).include?(:self_mobility)` — Type-level capability independent of current actuator state. `exists p1 != p0: transition(agent, p0, p1)` — A state-space agent has a transition relation that can change its own position variable.

**Future decomposition sketches (not canonical compounds).** MOV:200 + STR boundary + quantity → range of motion; MOV:200 + MAT body/actuator → physically embodied mobility; MOV:200 + collective actor role → group mobility capacity.

**Later-Era notes.** A later quantitative layer may measure degree or range without changing this invariant. A later agency distinction may separate self-propelled from externally driven movers compositionally.

## MOV:201 — available self-mobility

**Current candidate rationale.** The provisional meaning tried to make the inward capacity presently expressed. It correctly sought an active capacity, but the phrase 'being exercised' accidentally asserted a movement process.

| Candidate | Atomic | Address | MOV | Neighbor | vs MOV 000–122 | Cross-family | Everyday | Technical | Compound | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| expressed mobility | 7 | 7 | 9 | 6 | 3 | 8 | 8 | 8 | 8 | **64/90** |
| available self-mobility | 10 | 10 | 10 | 9 | 10 | 9 | 9 | 10 | 10 | **87/90** |
| movement-initiation control | 7 | 8 | 8 | 7 | 7 | 5 | 8 | 9 | 8 | **67/90** |
| realized motion range | 7 | 8 | 8 | 7 | 8 | 5 | 8 | 9 | 8 | **68/90** |

- **expressed mobility:** It makes the inward capacity current and salient. Covers Ready-and-moving, enabled locomotion, expressed mobility. Consumes Both availability and actual exercise. Risk: Combining availability with exercise violates atomicity and collides directly with MOV:121.
- **available self-mobility:** It is precisely an active inward Motion capacity without asserting motion. Covers Can move now, operable locomotion, currently usable mobility. Consumes Present availability of the mover's own positional-change capacity. Risk: Availability must not be paraphrased as permission, readiness plan, or actual movement.
- **movement-initiation control:** Control is active, inward, and connected to movement capacity. Covers Self-starting, motor control, command authority. Consumes Agency over onset. Risk: It collides with MIN intention, LOG authorization, and control grammar; nonagentive movers would be excluded.
- **realized motion range:** The currently accessible positional set looks like an active capacity. Covers Current workspace, maneuvering envelope, reachable nearby positions. Consumes A set of currently attainable positions. Risk: It imports geometry, topology, and reachability proof from STR, DAT, and LOG.

**Recommendation:** **available self-mobility** (87/90; confidence 96%).

> A mover's capacity to change its own position that is presently available for exercise.

**Boundaries.** Includes present usability of a mover's own mobility capacity. May hold while the mover is stationary. Does not assert permission, intention, readiness of a scheduled event, or actual displacement.

**Exclusions.** Enduring capacity without a current-availability claim is MOV:200. Capacity retained but not presently available is MOV:202. Ongoing movement is MOV:101, MOV:111, or MOV:121 according to frame. Energy and actuator condition belong to MAT; authorization belongs to LOG.

**Nearest approved Motion contrasts.** `MOV:011`: active destination is a guiding target entity, not a capacity. `MOV:101`: active departure is movement away from a source, not the ability to do so. `MOV:121`: active shared-frame movement changes position; MOV:201 may be true while position is unchanged.

**Address fit.** First trit `2` selects capacity/relationship rather than event; second trit selects the mover itself; third trit selects presently available, maintained, or updated.

**Runtime states.** `[0]` Denies that self-mobility is currently available; it does not necessarily deny enduring capacity. `[1]` Affirms that the mover can presently exercise its self-mobility. `[2]/num` Marks current availability as pending, dormant, remembered, possible, or unresolved; the lexical root remains active capacity rather than latent capacity.

**Examples.** `MOV:201[1](MOVER=person)` — I can move now. `MOV:201[1](MOVER=wheelchair)` — The powered chair is able to move. `MOV:201[0](MOVER=drone)` — The drone cannot move right now.

**Programming.** `if mobility_available?(robot) then expose_move_controls` — A runtime capability check succeeds without commanding movement. `assert(enabled(position_transition(agent)))` — An explicitly spatial agent can currently transition its position state.

**Future decomposition sketches (not canonical compounds).** MOV:201 + LOG permission → currently permitted and able to move; MOV:201 + STR clearance → room to move now; MOV:201 + MAT energy → powered mobility currently available.

**Later-Era notes.** Do not let a future runtime API redefine availability as execution. Readiness of a particular departure remains compositional and must not be back-filled into this root.

## MOV:202 — latent self-mobility

**Current candidate rationale.** The provisional author mapped dormant + inward + capacity to mobility that exists under suitable conditions but is not expressed. That is the natural third member of the capacity triplet.

| Candidate | Atomic | Address | MOV | Neighbor | vs MOV 000–122 | Cross-family | Everyday | Technical | Compound | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| latent mobility | 10 | 10 | 10 | 9 | 10 | 9 | 9 | 9 | 10 | **86/90** |
| movement readiness | 8 | 9 | 9 | 8 | 6 | 6 | 9 | 9 | 8 | **72/90** |
| immobilization condition | 8 | 8 | 8 | 7 | 9 | 5 | 9 | 8 | 7 | **69/90** |
| possible departure | 9 | 8 | 9 | 7 | 2 | 8 | 9 | 8 | 8 | **68/90** |

- **latent mobility:** It directly realizes dormant inward Motion capacity. Covers Dormant locomotion, temporarily unavailable mobility, retained ability to move. Consumes Existing self-mobility capacity in a nonavailable phase. Risk: Suitable conditions must not smuggle in a plan, permission, or prediction.
- **movement readiness:** Readiness seems like a dormant capacity. Covers Ready to go, staged vehicle, preflight movement state. Consumes Preparation for a particular event. Risk: It imports event specification and preparation, conflicts with the approved rejection of readiness in 1x2, and narrows general capacity.
- **immobilization condition:** A dormant capacity may be blocked. Covers Temporarily immobilized, stuck, constrained. Consumes The preventing condition rather than the capacity. Risk: It turns a positive capacity address into a negative condition and collides with MAT/STR/LOG causes.
- **possible departure:** Potential sourceward action can look like inward possibility. Covers Might leave, possible launch, potential exit. Consumes A nonactualized process token. Risk: It duplicates the now-canonical MOV:102 and ignores that first trit 2 is capacity/relationship, not process.

**Recommendation:** **latent self-mobility** (86/90; confidence 97%).

> A mover's capacity to change its own position that exists without being presently available for exercise.

**Boundaries.** Includes retained or dormant self-mobility that is not currently usable. Affirms the capacity itself while denying present availability. Does not assert why the capacity is unavailable or that a movement event will occur.

**Exclusions.** Enduring capacity without dormancy is MOV:200. Presently available capacity is MOV:201. Potential source departure is MOV:102; potential generic movement is MOV:122. A block, break, empty battery, or legal restriction belongs to STR, MAT, or LOG.

**Nearest approved Motion contrasts.** `MOV:002`: retained position is a remembered locus; MOV:202 is a retained capacity. `MOV:022`: dormant route system is a route entity; MOV:202 is a mover's capacity. `MOV:102 and MOV:122`: those roots select potential processes; MOV:202 selects dormant capacity.

**Address fit.** First trit `2` selects capacity/relationship rather than event; second trit selects the mover itself; third trit selects latent, unresolved, or unrealized potential.

**Runtime states.** `[0]` Denies that a latent self-mobility capacity exists. `[1]` Affirms that the mover retains self-mobility even though it is not presently available. `[2]/num` Marks the assertion of latent capacity itself as dormant, remembered, possible, or unresolved; this is not the same as lexical dormancy.

**Examples.** `MOV:202[1](MOVER=stored_rover)` — The stored rover could move again, but not now. `MOV:202[1](MOVER=dormant_animal)` — The hibernating animal retains the capacity to move. `MOV:202[1](MOVER=unpowered_drone)` — The drone is mobile in design, but its mobility is dormant.

**Programming.** `assert(has_capability(robot, :move) && !available?(robot, :move))` — The capability is installed but unavailable in the current operating state. `exists transition(position); enabled_now = false` — A transition relation exists but is disabled by the present state.

**Future decomposition sketches (not canonical compounds).** MOV:202 + MAT unpowered → mobility dormant because energy is absent; MOV:202 + STR blocked → mobility retained under a structural obstruction; MOV:202 + LOG restricted → mobility retained but presently disallowed.

**Later-Era notes.** Later causal grammar may state why availability is absent without changing this root. Do not collapse lexical dormant capacity into runtime `[2]/num`.

## MOV:210 — established target-relative position

**Current candidate rationale.** The provisional author treated stable outward relationship as an established trajectory from mover to target. The target orientation was sound, but trajectory imported an ordered path and implied future motion.

| Candidate | Atomic | Address | MOV | Neighbor | vs MOV 000–122 | Cross-family | Everyday | Technical | Compound | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| fixed trajectory relation | 7 | 7 | 9 | 6 | 5 | 7 | 7 | 9 | 8 | **65/90** |
| established target-relative position | 10 | 10 | 10 | 9 | 10 | 9 | 10 | 10 | 10 | **88/90** |
| distance to target | 9 | 9 | 9 | 8 | 10 | 7 | 10 | 10 | 9 | **81/90** |
| target reachability | 8 | 8 | 8 | 8 | 8 | 5 | 9 | 10 | 9 | **73/90** |

- **fixed trajectory relation:** A trajectory relates a mover outward to a target. Covers Heading, course relation, sequential progress. Consumes Direction plus ordered movement toward a target. Risk: It mixes relation with route/process, crowds MOV:020 and MOV:111, and the word sequential leaks beyond spatial Motion.
- **established target-relative position:** It is exactly a stable outward Motion relationship. Covers Relative position, near/far, direction, distance, beside/above/below after modifiers. Consumes A dyadic relation between mover position and target position. Risk: It must remain general; distance, bearing, and orientation are values or modifiers, not bundled senses.
- **distance to target:** Distance is a stable target-relative Motion relation. Covers Near, far, metric distance, separation thresholds. Consumes Scalar separation only. Risk: It sacrifices direction and relative-position coverage and depends on quantitative grammar or DAT values.
- **target reachability:** Reachability is a useful target-directed relationship. Covers Accessible, can arrive, path-planning feasibility. Consumes Existence of an allowed path from mover to target. Risk: It is principally a LOG proof over STR routes and constraints, and it overlaps MOV:012 and MOV:020.

**Recommendation:** **established target-relative position** (88/90; confidence 95%).

> An established positional relation of a mover to a target position.

**Boundaries.** Includes the established dyadic spatial relation between a mover and target. Supports distance, direction, bearing, and axis relations through modifiers or quantitative values. Does not require either participant to move.

**Exclusions.** The target entity is MOV:010–012. Movement toward the target is MOV:110–112. A route is MOV:020–022. Coordinate records belong to DAT; reachability proofs to LOG; topology to STR.

**Nearest approved Motion contrasts.** `MOV:001`: present position is a monadic occupied locus; MOV:210 relates it to a target. `MOV:010`: defined destination names the target entity; MOV:210 states a relation to it. `MOV:111`: active target approach asserts displacement toward target; MOV:210 can hold at rest. `MOV:020`: an established route is an ordered position sequence; MOV:210 requires no path.

**Address fit.** First trit `2` selects capacity/relationship rather than event; second trit selects a target-oriented dyad; third trit selects enduring or established.

**Runtime states.** `[0]` Denies the asserted established target-relative positional relation. `[1]` Affirms that the stated target-relative positional relation is established and valid. `[2]/num` Marks the validity or availability of that established-relation assertion as dormant, remembered, possible, or unresolved; lexical MOV:212 instead selects unresolved relation as the concept.

**Examples.** `MOV:210[1](MOVER=us,TARGET=cabin,VALUE=3km)` — The cabin is three kilometers from us. `MOV:210[1](MOVER=boat,TARGET=buoy,AXIS=east)` — The boat is east of the buoy. `MOV:210[1](MOVER=me,TARGET=you,RELATION=beside)` — I am beside you.

**Programming.** `relative_position[node_a, node_b] = vector` — A resolved relative-position vector, not a route. `d = metric(position(agent), position(goal))` — A state-space relation used as input to planning without asserting reachability.

**Future decomposition sketches (not canonical compounds).** MOV:210 + quantity/metric → distance to target; MOV:210 + axis/angle → direction or bearing; MOV:210 + LOG proof + MOV:020 → target reachability.

**Later-Era notes.** Later geometric registers may encode vector, angle, or metric while preserving this relational invariant. Do not redefine the atom as destination, route, or approach.

## MOV:211 — live target-relative position

**Current candidate rationale.** The provisional author interpreted active outward relationship as pursuit, following, escorting, or tracking. Those readings made the relation live, but bundled several processes and participant roles.

| Candidate | Atomic | Address | MOV | Neighbor | vs MOV 000–122 | Cross-family | Everyday | Technical | Compound | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| active pursuit relation | 5 | 7 | 8 | 5 | 3 | 6 | 8 | 8 | 7 | **57/90** |
| live target-relative position | 10 | 10 | 10 | 9 | 10 | 9 | 9 | 10 | 10 | **87/90** |
| target tracking relation | 8 | 9 | 8 | 8 | 9 | 5 | 8 | 10 | 9 | **74/90** |
| changing target separation | 8 | 9 | 9 | 8 | 5 | 8 | 8 | 9 | 9 | **73/90** |

- **active pursuit relation:** Pursuit is active and target-oriented. Covers Follow, chase, escort, track. Consumes Multiple target-directed motion and attention relations. Risk: The list is non-atomic and collides with MOV:111, MIN attention, DAT tracking, and CON coordination.
- **live target-relative position:** It is an active outward relationship rather than a movement process. Covers Live relative position, continuously updated separation, maintained alongside relation. Consumes Current maintenance or update of one dyadic positional relation. Risk: Updated must not imply that Motion owns the sensor, data stream, attention, or motion causing the update.
- **target tracking relation:** Tracking is a natural active target relation. Covers Radar tracking, following a marker, dynamic relative pose. Consumes Measurement and estimation of a target. Risk: It imports DAT records and MIN attention and excludes live relations that are not observed.
- **changing target separation:** A changing relation realizes active outward relationship. Covers Closing, receding, varying distance. Consumes Rate of change of target separation. Risk: It becomes a disguised approach/departure process and cannot express a maintained live relation at constant separation.

**Recommendation:** **live target-relative position** (87/90; confidence 93%).

> A positional relation of a mover to a target position that is currently maintained or updated.

**Boundaries.** Includes a target-relative positional relation treated as presently live, maintained, or updated. The relation may remain numerically constant or change. Does not assert movement toward, away from, or along with the target.

**Exclusions.** Established nonlive relation is MOV:210; unresolved relation is MOV:212. Approach is MOV:111; departure from a source is MOV:101; generic movement is MOV:121. Observation belongs to MIN, coordinate streams to DAT, and coordination to CON. A route, destination, pursuit plan, or following operation is not encoded.

**Nearest approved Motion contrasts.** `MOV:001`: present position supplies a locus; MOV:211 maintains its relation to a target. `MOV:011`: active destination guides movement; MOV:211 need not make the target a destination. `MOV:111`: approach changes position toward target; MOV:211 can remain live at constant separation. `MOV:121`: shared-frame movement asserts position change; MOV:211 asserts only a live dyadic relation.

**Address fit.** First trit `2` selects capacity/relationship rather than event; second trit selects a target-oriented dyad; third trit selects presently available, maintained, or updated.

**Runtime states.** `[0]` Denies that the target-relative positional relation is currently maintained or updated. `[1]` Affirms that the relation is live now. `[2]/num` Marks the live-relation token as pending, dormant, remembered, possible, or unresolved; it does not select lexical MOV:212.

**Examples.** `MOV:211[1](MOVER=drone,TARGET=beacon)` — The drone's position relative to the beacon is being kept current. `MOV:211[1](MOVER=us,TARGET=guide,RELATION=alongside)` — We are staying alongside the guide. `MOV:211[1](MOVER=ship,TARGET=shoreline)` — The ship's position relative to shore is being updated.

**Programming.** `relative_pose.update(robot, marker)` — The relative pose relation is maintained as live state. `maintain(relation(position(agent), position(goal)))` — A solver maintains a current relational variable without asserting approach.

**Future decomposition sketches (not canonical compounds).** MOV:211 + DAT coordinate stream → tracked relative position; MOV:211 + MIN attention → attended target-relative position; MOV:211 + CON coordination + MOV:121 → coordinated movement relative to a target.

**Later-Era notes.** A later calculus may distinguish maintained, sampled, and continuously updated relations. The atom must remain neutral about sensors and direction of movement.

## MOV:212 — unresolved target-relative position

**Current candidate rationale.** The provisional author recognized that the slot needed an unresolved target-oriented relation, but chose a possible path whose direction, reachability, or completion was unresolved. That imported three different questions and a route entity.

| Candidate | Atomic | Address | MOV | Neighbor | vs MOV 000–122 | Cross-family | Everyday | Technical | Compound | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| unresolved route relation | 5 | 7 | 8 | 6 | 4 | 5 | 8 | 9 | 7 | **59/90** |
| unresolved target-relative position | 10 | 10 | 10 | 9 | 10 | 9 | 9 | 10 | 10 | **87/90** |
| uncertain target reachability | 8 | 9 | 8 | 8 | 8 | 5 | 9 | 10 | 9 | **74/90** |
| possible spatial linkage | 7 | 8 | 8 | 7 | 6 | 5 | 7 | 8 | 8 | **64/90** |

- **unresolved route relation:** It is unresolved and target-oriented. Covers Unknown route, uncertain reachability, unresolved journey. Consumes Path existence, direction, reachability, and completion. Risk: It is non-atomic and collides with MOV:020–022, LOG, STR, and MOV:112.
- **unresolved target-relative position:** It directly realizes unresolved outward Motion relationship. Covers Unknown relative position, unresolved side/distance/bearing, possible positional relation. Consumes The unresolved value or validity of one dyadic position relation. Risk: It must not claim that a map record is missing or that reachability is unknown; those are DAT/LOG causes.
- **uncertain target reachability:** It is a highly useful unresolved target relation. Covers Maybe accessible, unknown path feasibility, state reachability query. Consumes Unresolved existence of an allowed route. Risk: Reachability is a LOG result over STR and MOV data, not a primitive positional relation.
- **possible spatial linkage:** A possible link is an unrealized outward relation. Covers Potential tether, corridor, route, access relation. Consumes Connection between participants or loci. Risk: It collides with CON linkage and STR route structure and says little about position.

**Recommendation:** **unresolved target-relative position** (87/90; confidence 95%).

> An unresolved relation between a mover's position and a target position.

**Boundaries.** Includes a target-relative positional relation whose value or validity is not resolved. Can support questions about distance, side, bearing, or relative placement without selecting one. Does not assert why the relation is unresolved.

**Exclusions.** A dormant or unreachable destination entity is MOV:012. Potential target approach is MOV:112. A possible or dormant route uses MOV:020–022 with runtime/logic. Missing coordinate data belongs to DAT; reachability uncertainty to LOG.

**Nearest approved Motion contrasts.** `MOV:012`: MOV:012 classifies the target entity as dormant/unreachable; MOV:212 classifies the positional relation as unresolved. `MOV:112`: MOV:112 is a potential movement process; MOV:212 is not a process. `MOV:020–022`: route roots name path entities/systems; MOV:212 does not assert any route. `MOV:210–211`: those select established or live relations; MOV:212 selects the unresolved relation.

**Address fit.** First trit `2` selects capacity/relationship rather than event; second trit selects a target-oriented dyad; third trit selects latent, unresolved, or unrealized potential.

**Runtime states.** `[0]` Denies that the asserted target-relative relation is unresolved. `[1]` Affirms the unresolved target-relative relation as the valid lexical concept. `[2]/num` Marks the status of that unresolved-relation assertion itself as pending, dormant, remembered, possible, or unresolved; this second-order status is distinct from lexical unresolvedness.

**Examples.** `MOV:212[1](MOVER=probe,TARGET=station)` — We do not yet know where the probe is relative to the station. `MOV:212[1](MOVER=boat,TARGET=bridge)` — It is unclear which side of the bridge the boat is on. `MOV:212[1](MOVER=traveler,TARGET=landmark)` — Their position relative to the landmark is unknown.

**Programming.** `relative_position[node_a, node_b] = UNRESOLVED` — The relative-position variable is unresolved, independently of the reason. `assert(unbound?(relation(position(agent), position(goal))))` — A spatial relation remains unbound in a constraint system.

**Future decomposition sketches (not canonical compounds).** MOV:212 + DAT missing record → unresolved relation because coordinates are absent; MOV:212 + LOG reachability query → unresolved positional relation under a reachability proof; MOV:212 + MIN uncertainty → an agent is uncertain about the relative position.

**Later-Era notes.** Later epistemic grammar may distinguish unknown, underspecified, and indeterminate causes. Keep the invariant relational so the atom does not absorb map or path semantics.

## MOV:220 — established shared-frame configuration

**Current candidate rationale.** The provisional author chose a stable recurring order because systemic Motion often presents as cycles, transport systems, or temporal recurrence. Recurrence, however, is only one pattern and imports time/order beyond positional relationship.

| Candidate | Atomic | Address | MOV | Neighbor | vs MOV 000–122 | Cross-family | Everyday | Technical | Compound | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| stable cycle relation | 7 | 8 | 9 | 8 | 7 | 6 | 8 | 9 | 8 | **70/90** |
| established shared-frame configuration | 10 | 10 | 10 | 9 | 10 | 9 | 10 | 10 | 10 | **88/90** |
| route connectivity | 8 | 9 | 8 | 7 | 4 | 4 | 8 | 9 | 9 | **66/90** |
| environmental navigability | 8 | 9 | 9 | 8 | 8 | 5 | 9 | 10 | 9 | **75/90** |

- **stable cycle relation:** A recurring systemic relation can be stable and Motion-specific. Covers Orbit, cycle, timetable recurrence, looped transport. Consumes Recurrence and ordering across a system. Risk: It bundles transport, orbital, and temporal senses and collides with ORI, STR, and route cycles.
- **established shared-frame configuration:** It is exactly a stable systemic Motion relationship. Covers Spatial arrangement, formation, relative placement of multiple loci, stable orbital geometry after MAT composition. Consumes A multi-locus positional configuration in one frame. Risk: It must not absorb organizational structure, causal forces, coordination, or a map representation.
- **route connectivity:** Connectivity is stable and systemic. Covers Transport topology, connected routes, network reachability. Consumes Edges and paths among loci. Risk: It duplicates MOV:020–022 and belongs primarily to STR topology.
- **environmental navigability:** Navigability is a systemic Motion relationship between mover and environment. Covers Traversable space, room to move, usable network. Consumes Affordance under constraints. Risk: It depends on STR boundaries, LOG constraints, MAT dimensions, and often a particular mover; it is less purely systemic.

**Recommendation:** **established shared-frame configuration** (88/90; confidence 94%).

> An established positional configuration among loci within a shared reference frame.

**Boundaries.** Includes an established multi-locus arrangement defined only by positions in a shared frame. May describe physical, simulated, or explicit state-space loci. Does not imply that anything is moving or that the configuration has a route, topology, purpose, or cause.

**Exclusions.** A route or network entity is MOV:020–022. Completed shared-frame movement is MOV:120. Organizational structure and topology belong to STR. Forces and bodies belong to MAT; coordination belongs to CON; coordinate records belong to DAT.

**Nearest approved Motion contrasts.** `MOV:020`: an established route orders positions as a path; MOV:220 only relates their placement in one frame. `MOV:021`: an active flow network carries movement; MOV:220 may be wholly static. `MOV:120`: completed shared-frame movement is an event; MOV:220 is the resulting or independent configuration, not the event.

**Address fit.** First trit `2` selects capacity/relationship rather than event; second trit selects a shared/systemic frame; third trit selects enduring or established.

**Runtime states.** `[0]` Denies that the asserted shared-frame configuration is established. `[1]` Affirms the established positional configuration. `[2]/num` Marks the status of that established-configuration assertion as dormant, remembered, possible, or unresolved; lexical MOV:222 instead selects potential configuration.

**Examples.** `MOV:220[1](LOCI=vehicles,FRAME=parking_area)` — The vehicles are parked in an established formation. `MOV:220[1](LOCI=chairs,FRAME=room)` — The chairs remain arranged around the table. `MOV:220[1](LOCI=satellites,FRAME=orbital_frame)` — The satellites hold a stable formation.

**Programming.** `configuration = {node => pose_in(world)}` — A resolved set of relative poses, independent of graph edges. `assert(configuration.valid_positions_only?)` — A multi-agent positional state in an explicitly spatial model.

**Future decomposition sketches (not canonical compounds).** MOV:220 + MAT forces → stable orbital configuration; MOV:220 + STR topology → spatially embedded structure; MOV:220 + role geometry → beside/above/between formation.

**Later-Era notes.** A later geometry layer may distinguish rigid, periodic, and statistical configurations. Keep purpose and organization outside the atomic Motion relation.

## MOV:221 — live shared-frame configuration

**Current candidate rationale.** The provisional meaning associated active systemic relationship with synchronized movers in a route, cadence, or schedule. It captured an active system, but bundled coordination, route use, timing, and movement.

| Candidate | Atomic | Address | MOV | Neighbor | vs MOV 000–122 | Cross-family | Everyday | Technical | Compound | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| synchronized flow relation | 5 | 7 | 8 | 5 | 3 | 4 | 8 | 8 | 8 | **56/90** |
| live shared-frame configuration | 10 | 10 | 10 | 9 | 10 | 9 | 9 | 10 | 10 | **87/90** |
| coordinated formation | 8 | 9 | 8 | 8 | 9 | 5 | 9 | 9 | 9 | **74/90** |
| traffic-load relation | 7 | 8 | 8 | 7 | 5 | 5 | 8 | 9 | 8 | **65/90** |

- **synchronized flow relation:** Synchronization is an active systemic relation. Covers Convoy, synchronized traffic, scheduled flow, coordinated transitions. Consumes Coordination, timing, route, and active movement. Risk: It is non-atomic and collides with CON, MOV:021, MOV:121, STR, and scheduling grammar.
- **live shared-frame configuration:** It realizes active systemic Motion relationship without becoming a process. Covers Live formation, dynamic spatial arrangement, maintained multi-locus pose. Consumes Current maintenance or update of a shared-frame configuration. Risk: It must not imply coordination, data acquisition, or actual movement; those are separable causes or realizations.
- **coordinated formation:** Formation is an active systemic positional relation. Covers Convoy formation, flocking, synchronized robots. Consumes Participant coordination that maintains positions. Risk: Coordination belongs to CON and excludes accidental or externally maintained configurations.
- **traffic-load relation:** Traffic distribution is a live systemic Motion relation. Covers Congestion, load balance, route usage. Consumes Flow amount over a network. Risk: It presupposes MOV:021, route topology, quantities, and possibly DAT measurements.

**Recommendation:** **live shared-frame configuration** (87/90; confidence 92%).

> A positional configuration among loci that is currently maintained or updated within a shared reference frame.

**Boundaries.** Includes a multi-locus positional configuration treated as presently live, maintained, or updated. The positions may remain constant or change. Does not assert a route, traffic, synchronization, coordination, or shared movement.

**Exclusions.** Established nonlive configuration is MOV:220; unrealized possible configuration is MOV:222. Active flow network is MOV:021. Active shared-frame movement is MOV:121. Coordination belongs to CON; map/pose streams to DAT; scheduling to grammar or LOG.

**Nearest approved Motion contrasts.** `MOV:021`: the active flow network is a route system carrying motion; MOV:221 is a live positional configuration. `MOV:121`: active shared-frame movement changes position; MOV:221 can remain live while positions remain constant. `MOV:211`: MOV:211 is dyadic mover-to-target relation; MOV:221 is systemic among loci.

**Address fit.** First trit `2` selects capacity/relationship rather than event; second trit selects a shared/systemic frame; third trit selects presently available, maintained, or updated.

**Runtime states.** `[0]` Denies that the shared-frame configuration is currently maintained or updated. `[1]` Affirms that the multi-locus configuration is live. `[2]/num` Marks the live-configuration token as pending, dormant, remembered, possible, or unresolved; it does not select lexical MOV:222.

**Examples.** `MOV:221[1](LOCI=drones,FRAME=airspace)` — The drone formation is being maintained. `MOV:221[1](LOCI=players,FRAME=field)` — The players are holding a live formation. `MOV:221[1](LOCI=satellites,FRAME=orbital_frame)` — The satellite constellation's relative positions are being kept current.

**Programming.** `formation_state.update(current_poses)` — A live configuration state is maintained separately from motion commands. `assert(configuration_timestamp == now)` — A simulation maintains a current relational configuration.

**Future decomposition sketches (not canonical compounds).** MOV:221 + CON coordination + MOV:121 → coordinated moving formation; MOV:221 + DAT pose stream → observed live configuration; MOV:221 + MOV:021 → traffic distribution over an active network.

**Later-Era notes.** A future temporal layer may express update cadence without making cadence atomic here. Keep live configuration distinct from synchronized motion.

## MOV:222 — potential shared-frame configuration

**Current candidate rationale.** The provisional author mapped unrealized systemic possibility to an unselected path branch. This used the possibility value well, but prematurely fixed the system relation as route topology and planning.

| Candidate | Atomic | Address | MOV | Neighbor | vs MOV 000–122 | Cross-family | Everyday | Technical | Compound | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| possible path branch | 8 | 9 | 8 | 7 | 4 | 5 | 8 | 9 | 8 | **66/90** |
| potential shared-frame configuration | 10 | 10 | 10 | 9 | 10 | 9 | 9 | 10 | 10 | **87/90** |
| possible navigability | 8 | 9 | 9 | 8 | 8 | 5 | 9 | 10 | 9 | **75/90** |
| collision-free motion possibility | 8 | 8 | 9 | 7 | 8 | 4 | 8 | 10 | 9 | **71/90** |

- **possible path branch:** A possible branch is unrealized and systemic. Covers Alternative path, future sequence, route branch. Consumes Path generation, validity, choice, and future sequence. Risk: It collides with MOV:020–022, LOG validity, CRE generation, STR topology, and planning.
- **potential shared-frame configuration:** It exactly realizes unrealized systemic Motion possibility. Covers Possible arrangement, candidate formation, unrealized multi-locus placement. Consumes One possible positional configuration in a shared frame. Risk: It must not claim feasibility, selection, generation, probability, future occurrence, or permission.
- **possible navigability:** It is a systemic movement possibility. Covers Maybe traversable, potential route availability, possible access. Consumes Existence of permitted traversals. Risk: It depends on LOG proof, STR topology, and MOV route entities and approaches a potential process MOV:122.
- **collision-free motion possibility:** It is a useful environmental Motion possibility. Covers Spatial compatibility, feasible formations, collision avoidance. Consumes Safety-constrained joint motion. Risk: It imports WRN risk, MAT dimensions, LOG constraints, and actual or potential movement processes.

**Recommendation:** **potential shared-frame configuration** (87/90; confidence 95%).

> An unrealized possible positional configuration among loci within a shared reference frame.

**Boundaries.** Includes an unrealized possible arrangement of loci in a shared frame. Does not assert that the arrangement is feasible, selected, scheduled, probable, or future. The possibility is configuration-level, not a movement event.

**Exclusions.** Potential shared-frame movement is MOV:122. Possible routes use MOV:020–022 with LOG/STR or runtime composition. Path generation belongs to CRE; permission and feasibility to LOG; topology to STR. Universal possibility or reality belongs to ORI.

**Nearest approved Motion contrasts.** `MOV:022`: dormant route system is a route entity; MOV:222 is a possible positional configuration. `MOV:122`: MOV:122 is a nonactualized movement process; MOV:222 is a nonactualized relationship/configuration. `MOV:212`: MOV:212 is an unresolved dyadic relation; MOV:222 is a systemic possible configuration.

**Address fit.** First trit `2` selects capacity/relationship rather than event; second trit selects a shared/systemic frame; third trit selects latent, unresolved, or unrealized potential.

**Runtime states.** `[0]` Denies the asserted potential shared-frame configuration. `[1]` Affirms that the unrealized configuration is a valid possibility without asserting feasibility or future realization. `[2]/num` Marks the status of that potential-configuration assertion as dormant, remembered, possible, or unresolved; this is token status layered over lexical possibility.

**Examples.** `MOV:222[1](LOCI=drones,FRAME=airspace,FORM=ring)` — The drones could occupy a ring formation. `MOV:222[1](LOCI=furniture,FRAME=room,FORM=alternate)` — The furniture could be arranged differently. `MOV:222[1](LOCI=vehicles,FRAME=road,FORM=spaced)` — The vehicles could occupy a more widely spaced formation.

**Programming.** `candidates << configuration(candidate_poses)` — A candidate configuration is represented without claiming constraint satisfaction. `model.add_candidate(joint_position_assignment)` — An unrealized joint positional assignment exists as a model candidate.

**Future decomposition sketches (not canonical compounds).** MOV:222 + LOG constraints → feasible shared-frame configuration; MOV:222 + CRE generation → generated candidate configuration; MOV:222 + WRN collision risk + MAT dimensions → candidate configuration with collision analysis.

**Later-Era notes.** A later modal layer may distinguish possible, probable, permitted, and feasible without changing this atom. Do not let route planning reclaim this address merely because configurations are planning inputs.

## Nine-root comparison matrix

| Root | Owns | Belongs elsewhere | Reserved for composition | Intentionally undefined here |
|---|---|---|---|---|
| `MOV:200` | enduring self-mobility capacity | body/energy/permission | range of motion; group mobility | degree of capability |
| `MOV:201` | currently available self-mobility | actual movement; authorization | able-and-permitted; room to move | readiness of a scheduled event |
| `MOV:202` | retained but unavailable self-mobility | blocker or failure cause | unpowered/blocked/restricted mobility | probability of restoration |
| `MOV:210` | established mover-to-target positional relation | target entity; route; coordinate record | distance; bearing; near/far; axis relation | universal geometry vocabulary |
| `MOV:211` | live maintained/updated target-relative relation | approach; tracking data; attention | tracked or attended relation | sensor and sampling semantics |
| `MOV:212` | unresolved target-relative positional relation | unreachable destination; possible route | unknown because data/proof is missing | cause and type of indeterminacy |
| `MOV:220` | established multi-locus positional configuration | topology; organization; physical cause | orbit/formation/embedded structure | configuration metric |
| `MOV:221` | live maintained/updated shared-frame configuration | flow network; movement; coordination | coordinated moving formation; observed pose set | update cadence |
| `MOV:222` | unrealized possible shared-frame configuration | possible route; process potential; universal modality | feasible/generated/safe candidate configuration | probability, permission, selection |

## Triplet and layer coherence

- `MOV:200–202` shares one center—self-mobility capacity. The contrast is enduring capacity / capacity presently available / capacity retained but latent.
- `MOV:210–212` shares one center—mover-to-target positional relation. The contrast is established / live-maintained-or-updated / unresolved.
- `MOV:220–222` shares one center—multi-locus positional configuration in a shared frame. The contrast is established / live-maintained-or-updated / unrealized possible.
- Across rows, the second trit expands scope from self-capacity, to a target dyad, to a systemic configuration. This is principled address parallelism, not forced lexical synonymy.

## Stress-test outcome

All 45 required concepts are classified in `reviews/MOV_200_222_stress_tests.yaml`. Only eight receive a direct atomic-root treatment; the rest deliberately use runtime state, composition, logic/grammar, or another family. No vocabulary gap forces a change to the recommended architecture.

## Final recommendations

- `MOV:200` — **enduring self-mobility**: An enduring capacity of a mover to change its own position.
- `MOV:201` — **available self-mobility**: A mover's capacity to change its own position that is presently available for exercise.
- `MOV:202` — **latent self-mobility**: A mover's capacity to change its own position that exists without being presently available for exercise.
- `MOV:210` — **established target-relative position**: An established positional relation of a mover to a target position.
- `MOV:211` — **live target-relative position**: A positional relation of a mover to a target position that is currently maintained or updated.
- `MOV:212` — **unresolved target-relative position**: An unresolved relation between a mover's position and a target position.
- `MOV:220` — **established shared-frame configuration**: An established positional configuration among loci within a shared reference frame.
- `MOV:221` — **live shared-frame configuration**: A positional configuration among loci that is currently maintained or updated within a shared reference frame.
- `MOV:222` — **potential shared-frame configuration**: An unrealized possible positional configuration among loci within a shared reference frame.

- **Roots ready for user approval:** all nine (`MOV:200–222`).
- **Roots that should remain unresolved:** none.
- **Architectural questions requiring user decision:** none blocking. Nonblocking later decisions include the quantitative geometry layer, epistemic subtypes of unresolved relation, and whether catalogue labels prefer “live” or “active” while retaining the invariant definitions.
- **Roots canonized by this packet:** none.
- **Stop boundary honored:** no MAT block, other root block, compounds, or Gate 4 work begun.

**READY FOR USER APPROVAL**
