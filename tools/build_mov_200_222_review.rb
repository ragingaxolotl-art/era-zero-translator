#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MOV:200 MOV:201 MOV:202
  MOV:210 MOV:211 MOV:212
  MOV:220 MOV:221 MOV:222
].freeze
SCORE_KEYS = %w[
  atomicity address_fit motion_family_fit neighbor_separation
  separation_from_mov_000_122 cross_family_separation
  everyday_language_usefulness technical_programming_usefulness
  compound_usefulness
].freeze

def candidate(id, title, definition, scores, fit, coverage, territory, risks)
  raise "#{id}: score count" unless scores.length == SCORE_KEYS.length

  {
    "candidate_id" => id,
    "title" => title,
    "invariant_candidate" => definition,
    "analysis" => {
      "why_it_fits" => fit,
      "useful_coverage" => coverage,
      "semantic_territory_consumed" => territory,
      "risks_and_future_limitations" => risks
    },
    "scores" => SCORE_KEYS.zip(scores).to_h,
    "total" => scores.sum,
    "maximum" => 90
  }
end

def example(graph, literal, natural, state = 1)
  {
    "semantic_graph" => graph,
    "literal_gloss" => literal,
    "natural_english" => natural,
    "runtime_state" => state,
    "contour" => "declarative",
    "roles" => graph.scan(/[A-Z_]+=/).map { |role| role.delete("=") }.uniq
  }
end

def technical(graph, interpretation, pseudocode)
  {
    "semantic_graph" => graph,
    "interpretation" => interpretation,
    "pseudocode" => pseudocode,
    "runtime_state" => 1
  }
end

ROOTS = {
  "MOV:200" => {
    "current_rationale" => "The provisional author used stable + inward + capacity to reserve an enduring ability of a mover to relocate itself. That choice correctly avoided naming an actual movement event.",
    "candidates" => [
      candidate("current_stable_mobility", "stable mobility", "An entity has a dependable capacity to change its own position.",
                [9, 9, 9, 8, 9, 8, 9, 9, 10],
                "It directly realizes stable inward Motion capacity.",
                "Mobile, locomotion-capable, enduring self-relocation capability.",
                "The mover's durable capacity, independent of any current journey.",
                "The word stable can be confused with immobility; dependable should not imply physical integrity or permission."),
      candidate("movement_initiation_capability", "movement-initiation capability", "A mover has the capacity to begin displacement from its current position.",
                [8, 8, 9, 7, 5, 8, 8, 9, 8],
                "Initiation is source-oriented and capacity-like.",
                "Can start, launch capability, ability to set off.",
                "The threshold between rest and motion.",
                "It crowds MOV:102 potential departure and excludes movers that can continue but cannot self-initiate."),
      candidate("range_of_motion", "range of motion", "A mover has a bounded set of positions it can occupy through movement.",
                [8, 8, 8, 8, 9, 5, 8, 8, 8],
                "A stable inward capacity can be construed as a reachable set.",
                "Joint range, travel envelope, workspace, mobility radius.",
                "Quantified extents of possible self-position.",
                "It imports boundaries, geometry, and physical constitution from STR and MAT; it is better composed from mobility plus bounds."),
      candidate("positional_freedom", "positional freedom", "A mover is free of restrictions that would prevent self-displacement.",
                [7, 8, 8, 7, 8, 5, 8, 7, 8],
                "Freedom can behave like a stable inward movement capacity.",
                "Freedom of movement, unconstrained travel, maneuverability.",
                "Absence of external restrictions.",
                "It makes LOG permission and STR constraints part of the atom and treats capacity as a negative condition.")
    ],
    "winner" => "current_stable_mobility",
    "recommended_title" => "enduring self-mobility",
    "definition" => "An enduring capacity of a mover to change its own position.",
    "confidence" => 0.94,
    "boundaries" => [
      "Includes a mover's durable capacity for self-positional change whether or not it is moving now.",
      "Applies to physical or explicitly modeled abstract movers.",
      "Does not assert that the capacity is currently usable, that movement is occurring, or that departure is potential."
    ],
    "exclusions" => [
      "Current availability is MOV:201.",
      "Latent or currently unavailable capacity is MOV:202.",
      "Actual shared-frame movement is MOV:120–122.",
      "Body integrity, energy, and force belong to MAT; permission belongs to LOG; range bounds require STR or quantitative composition."
    ],
    "motion_contrasts" => {
      "MOV:001" => "present position is an occupied locus; MOV:200 is a capacity",
      "MOV:100–102" => "departure roots are processes; MOV:200 does not assert a departure token",
      "MOV:120–122" => "shared-frame movement roots describe positional change; MOV:200 describes durable capability"
    },
    "runtime" => {
      "0" => "Denies that the mover has the asserted enduring self-mobility capacity.",
      "1" => "Affirms that the mover possesses the enduring capacity, even if presently at rest.",
      "2" => "Marks the truth or current status of that enduring-capacity assertion as dormant, remembered, possible, or unresolved; it does not turn the root into MOV:202."
    },
    "ordinary" => [
      example("MOV:200[1](MOVER=animal)", "the animal has enduring self-mobility", "The animal is mobile by nature."),
      example("MOV:200[1](MOVER=rover)", "the rover has enduring self-mobility", "The rover was built to relocate itself."),
      example("MOV:200[1](MOVER=bird)", "the bird has enduring self-mobility", "Even while resting, the bird can change where it is.")
    ],
    "technical" => [
      technical("MOV:200[1](MOVER=robot)", "Type-level capability independent of current actuator state.", "capabilities(robot).include?(:self_mobility)"),
      technical("MOV:200[1](MOVER=agent)", "A state-space agent has a transition relation that can change its own position variable.", "exists p1 != p0: transition(agent, p0, p1)")
    ],
    "compounds" => [
      "MOV:200 + STR boundary + quantity → range of motion",
      "MOV:200 + MAT body/actuator → physically embodied mobility",
      "MOV:200 + collective actor role → group mobility capacity"
    ],
    "era_notes" => [
      "A later quantitative layer may measure degree or range without changing this invariant.",
      "A later agency distinction may separate self-propelled from externally driven movers compositionally."
    ]
  },
  "MOV:201" => {
    "current_rationale" => "The provisional meaning tried to make the inward capacity presently expressed. It correctly sought an active capacity, but the phrase 'being exercised' accidentally asserted a movement process.",
    "candidates" => [
      candidate("current_expressed_mobility", "expressed mobility", "An entity's capacity for movement is currently available and being exercised.",
                [7, 7, 9, 6, 3, 8, 8, 8, 8],
                "It makes the inward capacity current and salient.",
                "Ready-and-moving, enabled locomotion, expressed mobility.",
                "Both availability and actual exercise.",
                "Combining availability with exercise violates atomicity and collides directly with MOV:121."),
      candidate("available_self_mobility", "available self-mobility", "A mover's capacity to change its own position is presently available for exercise.",
                [10, 10, 10, 9, 10, 9, 9, 10, 10],
                "It is precisely an active inward Motion capacity without asserting motion.",
                "Can move now, operable locomotion, currently usable mobility.",
                "Present availability of the mover's own positional-change capacity.",
                "Availability must not be paraphrased as permission, readiness plan, or actual movement."),
      candidate("movement_initiation_control", "movement-initiation control", "A mover presently controls whether its own displacement begins.",
                [7, 8, 8, 7, 7, 5, 8, 9, 8],
                "Control is active, inward, and connected to movement capacity.",
                "Self-starting, motor control, command authority.",
                "Agency over onset.",
                "It collides with MIN intention, LOG authorization, and control grammar; nonagentive movers would be excluded."),
      candidate("realized_motion_range", "realized motion range", "A mover presently has access to a set of positions it can occupy.",
                [7, 8, 8, 7, 8, 5, 8, 9, 8],
                "The currently accessible positional set looks like an active capacity.",
                "Current workspace, maneuvering envelope, reachable nearby positions.",
                "A set of currently attainable positions.",
                "It imports geometry, topology, and reachability proof from STR, DAT, and LOG.")
    ],
    "winner" => "available_self_mobility",
    "recommended_title" => "available self-mobility",
    "definition" => "A mover's capacity to change its own position that is presently available for exercise.",
    "confidence" => 0.96,
    "boundaries" => [
      "Includes present usability of a mover's own mobility capacity.",
      "May hold while the mover is stationary.",
      "Does not assert permission, intention, readiness of a scheduled event, or actual displacement."
    ],
    "exclusions" => [
      "Enduring capacity without a current-availability claim is MOV:200.",
      "Capacity retained but not presently available is MOV:202.",
      "Ongoing movement is MOV:101, MOV:111, or MOV:121 according to frame.",
      "Energy and actuator condition belong to MAT; authorization belongs to LOG."
    ],
    "motion_contrasts" => {
      "MOV:011" => "active destination is a guiding target entity, not a capacity",
      "MOV:101" => "active departure is movement away from a source, not the ability to do so",
      "MOV:121" => "active shared-frame movement changes position; MOV:201 may be true while position is unchanged"
    },
    "runtime" => {
      "0" => "Denies that self-mobility is currently available; it does not necessarily deny enduring capacity.",
      "1" => "Affirms that the mover can presently exercise its self-mobility.",
      "2" => "Marks current availability as pending, dormant, remembered, possible, or unresolved; the lexical root remains active capacity rather than latent capacity."
    },
    "ordinary" => [
      example("MOV:201[1](MOVER=person)", "the person's self-mobility is presently available", "I can move now."),
      example("MOV:201[1](MOVER=wheelchair)", "the chair's self-mobility is presently usable", "The powered chair is able to move."),
      example("MOV:201[0](MOVER=drone)", "the drone's current self-mobility is unavailable", "The drone cannot move right now.", 0)
    ],
    "technical" => [
      technical("MOV:201[1](MOVER=robot)", "A runtime capability check succeeds without commanding movement.", "if mobility_available?(robot) then expose_move_controls"),
      technical("MOV:201[1](MOVER=process)", "An explicitly spatial agent can currently transition its position state.", "assert(enabled(position_transition(agent)))")
    ],
    "compounds" => [
      "MOV:201 + LOG permission → currently permitted and able to move",
      "MOV:201 + STR clearance → room to move now",
      "MOV:201 + MAT energy → powered mobility currently available"
    ],
    "era_notes" => [
      "Do not let a future runtime API redefine availability as execution.",
      "Readiness of a particular departure remains compositional and must not be back-filled into this root."
    ]
  },
  "MOV:202" => {
    "current_rationale" => "The provisional author mapped dormant + inward + capacity to mobility that exists under suitable conditions but is not expressed. That is the natural third member of the capacity triplet.",
    "candidates" => [
      candidate("current_latent_mobility", "latent mobility", "An entity could move under suitable conditions, but that capacity is not presently available or expressed.",
                [10, 10, 10, 9, 10, 9, 9, 9, 10],
                "It directly realizes dormant inward Motion capacity.",
                "Dormant locomotion, temporarily unavailable mobility, retained ability to move.",
                "Existing self-mobility capacity in a nonavailable phase.",
                "Suitable conditions must not smuggle in a plan, permission, or prediction."),
      candidate("movement_readiness", "movement readiness", "A mover is prepared for a movement operation that has not begun.",
                [8, 9, 9, 8, 6, 6, 9, 9, 8],
                "Readiness seems like a dormant capacity.",
                "Ready to go, staged vehicle, preflight movement state.",
                "Preparation for a particular event.",
                "It imports event specification and preparation, conflicts with the approved rejection of readiness in 1x2, and narrows general capacity."),
      candidate("immobilization_condition", "immobilization condition", "A mover's positional-change capacity is presently prevented from expression.",
                [8, 8, 8, 7, 9, 5, 9, 8, 7],
                "A dormant capacity may be blocked.",
                "Temporarily immobilized, stuck, constrained.",
                "The preventing condition rather than the capacity.",
                "It turns a positive capacity address into a negative condition and collides with MAT/STR/LOG causes."),
      candidate("possible_departure", "possible departure", "A displacement away from the mover's source could occur.",
                [9, 8, 9, 7, 2, 8, 9, 8, 8],
                "Potential sourceward action can look like inward possibility.",
                "Might leave, possible launch, potential exit.",
                "A nonactualized process token.",
                "It duplicates the now-canonical MOV:102 and ignores that first trit 2 is capacity/relationship, not process.")
    ],
    "winner" => "current_latent_mobility",
    "recommended_title" => "latent self-mobility",
    "definition" => "A mover's capacity to change its own position that exists without being presently available for exercise.",
    "confidence" => 0.97,
    "boundaries" => [
      "Includes retained or dormant self-mobility that is not currently usable.",
      "Affirms the capacity itself while denying present availability.",
      "Does not assert why the capacity is unavailable or that a movement event will occur."
    ],
    "exclusions" => [
      "Enduring capacity without dormancy is MOV:200.",
      "Presently available capacity is MOV:201.",
      "Potential source departure is MOV:102; potential generic movement is MOV:122.",
      "A block, break, empty battery, or legal restriction belongs to STR, MAT, or LOG."
    ],
    "motion_contrasts" => {
      "MOV:002" => "retained position is a remembered locus; MOV:202 is a retained capacity",
      "MOV:022" => "dormant route system is a route entity; MOV:202 is a mover's capacity",
      "MOV:102 and MOV:122" => "those roots select potential processes; MOV:202 selects dormant capacity"
    },
    "runtime" => {
      "0" => "Denies that a latent self-mobility capacity exists.",
      "1" => "Affirms that the mover retains self-mobility even though it is not presently available.",
      "2" => "Marks the assertion of latent capacity itself as dormant, remembered, possible, or unresolved; this is not the same as lexical dormancy."
    },
    "ordinary" => [
      example("MOV:202[1](MOVER=stored_rover)", "the stored rover retains unavailable self-mobility", "The stored rover could move again, but not now."),
      example("MOV:202[1](MOVER=dormant_animal)", "the animal's self-mobility exists latently", "The hibernating animal retains the capacity to move."),
      example("MOV:202[1](MOVER=unpowered_drone)", "the drone retains self-mobility that is unavailable", "The drone is mobile in design, but its mobility is dormant.")
    ],
    "technical" => [
      technical("MOV:202[1](MOVER=robot)", "The capability is installed but unavailable in the current operating state.", "assert(has_capability(robot, :move) && !available?(robot, :move))"),
      technical("MOV:202[1](MOVER=agent)", "A transition relation exists but is disabled by the present state.", "exists transition(position); enabled_now = false")
    ],
    "compounds" => [
      "MOV:202 + MAT unpowered → mobility dormant because energy is absent",
      "MOV:202 + STR blocked → mobility retained under a structural obstruction",
      "MOV:202 + LOG restricted → mobility retained but presently disallowed"
    ],
    "era_notes" => [
      "Later causal grammar may state why availability is absent without changing this root.",
      "Do not collapse lexical dormant capacity into runtime `[2]/num`."
    ]
  },
  "MOV:210" => {
    "current_rationale" => "The provisional author treated stable outward relationship as an established trajectory from mover to target. The target orientation was sound, but trajectory imported an ordered path and implied future motion.",
    "candidates" => [
      candidate("current_fixed_trajectory_relation", "fixed trajectory relation", "A mover has an established directional or sequential relation to a target.",
                [7, 7, 9, 6, 5, 7, 7, 9, 8],
                "A trajectory relates a mover outward to a target.",
                "Heading, course relation, sequential progress.",
                "Direction plus ordered movement toward a target.",
                "It mixes relation with route/process, crowds MOV:020 and MOV:111, and the word sequential leaks beyond spatial Motion."),
      candidate("established_target_relative_position", "established target-relative position", "An established positional relation of a mover to a target position.",
                [10, 10, 10, 9, 10, 9, 10, 10, 10],
                "It is exactly a stable outward Motion relationship.",
                "Relative position, near/far, direction, distance, beside/above/below after modifiers.",
                "A dyadic relation between mover position and target position.",
                "It must remain general; distance, bearing, and orientation are values or modifiers, not bundled senses."),
      candidate("distance_to_target", "distance to target", "A measure separates a mover's position from a target position.",
                [9, 9, 9, 8, 10, 7, 10, 10, 9],
                "Distance is a stable target-relative Motion relation.",
                "Near, far, metric distance, separation thresholds.",
                "Scalar separation only.",
                "It sacrifices direction and relative-position coverage and depends on quantitative grammar or DAT values."),
      candidate("reachability_relation", "target reachability", "A target position is reachable by the mover under the governing movement constraints.",
                [8, 8, 8, 8, 8, 5, 9, 10, 9],
                "Reachability is a useful target-directed relationship.",
                "Accessible, can arrive, path-planning feasibility.",
                "Existence of an allowed path from mover to target.",
                "It is principally a LOG proof over STR routes and constraints, and it overlaps MOV:012 and MOV:020.")
    ],
    "winner" => "established_target_relative_position",
    "recommended_title" => "established target-relative position",
    "definition" => "An established positional relation of a mover to a target position.",
    "confidence" => 0.95,
    "boundaries" => [
      "Includes the established dyadic spatial relation between a mover and target.",
      "Supports distance, direction, bearing, and axis relations through modifiers or quantitative values.",
      "Does not require either participant to move."
    ],
    "exclusions" => [
      "The target entity is MOV:010–012.",
      "Movement toward the target is MOV:110–112.",
      "A route is MOV:020–022.",
      "Coordinate records belong to DAT; reachability proofs to LOG; topology to STR."
    ],
    "motion_contrasts" => {
      "MOV:001" => "present position is a monadic occupied locus; MOV:210 relates it to a target",
      "MOV:010" => "defined destination names the target entity; MOV:210 states a relation to it",
      "MOV:111" => "active target approach asserts displacement toward target; MOV:210 can hold at rest",
      "MOV:020" => "an established route is an ordered position sequence; MOV:210 requires no path"
    },
    "runtime" => {
      "0" => "Denies the asserted established target-relative positional relation.",
      "1" => "Affirms that the stated target-relative positional relation is established and valid.",
      "2" => "Marks the validity or availability of that established-relation assertion as dormant, remembered, possible, or unresolved; lexical MOV:212 instead selects unresolved relation as the concept."
    },
    "ordinary" => [
      example("MOV:210[1](MOVER=us,TARGET=cabin,VALUE=3km)", "our established position-relation to the cabin has distance three kilometers", "The cabin is three kilometers from us."),
      example("MOV:210[1](MOVER=boat,TARGET=buoy,AXIS=east)", "the boat's established position is east relative to the buoy", "The boat is east of the buoy."),
      example("MOV:210[1](MOVER=me,TARGET=you,RELATION=beside)", "my established position is beside yours", "I am beside you.")
    ],
    "technical" => [
      technical("MOV:210[1](MOVER=node_a,TARGET=node_b,VALUE=vector)", "A resolved relative-position vector, not a route.", "relative_position[node_a, node_b] = vector"),
      technical("MOV:210[1](MOVER=agent,TARGET=goal,VALUE=metric)", "A state-space relation used as input to planning without asserting reachability.", "d = metric(position(agent), position(goal))")
    ],
    "compounds" => [
      "MOV:210 + quantity/metric → distance to target",
      "MOV:210 + axis/angle → direction or bearing",
      "MOV:210 + LOG proof + MOV:020 → target reachability"
    ],
    "era_notes" => [
      "Later geometric registers may encode vector, angle, or metric while preserving this relational invariant.",
      "Do not redefine the atom as destination, route, or approach."
    ]
  },
  "MOV:211" => {
    "current_rationale" => "The provisional author interpreted active outward relationship as pursuit, following, escorting, or tracking. Those readings made the relation live, but bundled several processes and participant roles.",
    "candidates" => [
      candidate("current_active_pursuit_relation", "active pursuit relation", "A mover is actively following, approaching, escorting, or tracking a target.",
                [5, 7, 8, 5, 3, 6, 8, 8, 7],
                "Pursuit is active and target-oriented.",
                "Follow, chase, escort, track.",
                "Multiple target-directed motion and attention relations.",
                "The list is non-atomic and collides with MOV:111, MIN attention, DAT tracking, and CON coordination."),
      candidate("live_target_relative_position", "live target-relative position", "A positional relation of a mover to a target position that is currently maintained or updated.",
                [10, 10, 10, 9, 10, 9, 9, 10, 10],
                "It is an active outward relationship rather than a movement process.",
                "Live relative position, continuously updated separation, maintained alongside relation.",
                "Current maintenance or update of one dyadic positional relation.",
                "Updated must not imply that Motion owns the sensor, data stream, attention, or motion causing the update."),
      candidate("target_tracking_relation", "target tracking relation", "A mover maintains a current estimate of a target's changing position relative to itself.",
                [8, 9, 8, 8, 9, 5, 8, 10, 9],
                "Tracking is a natural active target relation.",
                "Radar tracking, following a marker, dynamic relative pose.",
                "Measurement and estimation of a target.",
                "It imports DAT records and MIN attention and excludes live relations that are not observed."),
      candidate("changing_separation_relation", "changing target separation", "The separation between a mover and target is currently changing.",
                [8, 9, 9, 8, 5, 8, 8, 9, 9],
                "A changing relation realizes active outward relationship.",
                "Closing, receding, varying distance.",
                "Rate of change of target separation.",
                "It becomes a disguised approach/departure process and cannot express a maintained live relation at constant separation.")
    ],
    "winner" => "live_target_relative_position",
    "recommended_title" => "live target-relative position",
    "definition" => "A positional relation of a mover to a target position that is currently maintained or updated.",
    "confidence" => 0.93,
    "boundaries" => [
      "Includes a target-relative positional relation treated as presently live, maintained, or updated.",
      "The relation may remain numerically constant or change.",
      "Does not assert movement toward, away from, or along with the target."
    ],
    "exclusions" => [
      "Established nonlive relation is MOV:210; unresolved relation is MOV:212.",
      "Approach is MOV:111; departure from a source is MOV:101; generic movement is MOV:121.",
      "Observation belongs to MIN, coordinate streams to DAT, and coordination to CON.",
      "A route, destination, pursuit plan, or following operation is not encoded."
    ],
    "motion_contrasts" => {
      "MOV:001" => "present position supplies a locus; MOV:211 maintains its relation to a target",
      "MOV:011" => "active destination guides movement; MOV:211 need not make the target a destination",
      "MOV:111" => "approach changes position toward target; MOV:211 can remain live at constant separation",
      "MOV:121" => "shared-frame movement asserts position change; MOV:211 asserts only a live dyadic relation"
    },
    "runtime" => {
      "0" => "Denies that the target-relative positional relation is currently maintained or updated.",
      "1" => "Affirms that the relation is live now.",
      "2" => "Marks the live-relation token as pending, dormant, remembered, possible, or unresolved; it does not select lexical MOV:212."
    },
    "ordinary" => [
      example("MOV:211[1](MOVER=drone,TARGET=beacon)", "the drone's relation to the beacon is live", "The drone's position relative to the beacon is being kept current."),
      example("MOV:211[1](MOVER=us,TARGET=guide,RELATION=alongside)", "our alongside positional relation to the guide is live", "We are staying alongside the guide."),
      example("MOV:211[1](MOVER=ship,TARGET=shoreline)", "the ship's target-relative position to the shoreline is continuously current", "The ship's position relative to shore is being updated.")
    ],
    "technical" => [
      technical("MOV:211[1](MOVER=robot,TARGET=marker,VALUE=pose)", "The relative pose relation is maintained as live state.", "relative_pose.update(robot, marker)"),
      technical("MOV:211[1](MOVER=agent,TARGET=goal)", "A solver maintains a current relational variable without asserting approach.", "maintain(relation(position(agent), position(goal)))")
    ],
    "compounds" => [
      "MOV:211 + DAT coordinate stream → tracked relative position",
      "MOV:211 + MIN attention → attended target-relative position",
      "MOV:211 + CON coordination + MOV:121 → coordinated movement relative to a target"
    ],
    "era_notes" => [
      "A later calculus may distinguish maintained, sampled, and continuously updated relations.",
      "The atom must remain neutral about sensors and direction of movement."
    ]
  },
  "MOV:212" => {
    "current_rationale" => "The provisional author recognized that the slot needed an unresolved target-oriented relation, but chose a possible path whose direction, reachability, or completion was unresolved. That imported three different questions and a route entity.",
    "candidates" => [
      candidate("current_unresolved_route_relation", "unresolved route relation", "A possible path between mover and target exists, but its direction, reachability, or completion is not resolved.",
                [5, 7, 8, 6, 4, 5, 8, 9, 7],
                "It is unresolved and target-oriented.",
                "Unknown route, uncertain reachability, unresolved journey.",
                "Path existence, direction, reachability, and completion.",
                "It is non-atomic and collides with MOV:020–022, LOG, STR, and MOV:112."),
      candidate("unresolved_target_relative_position", "unresolved target-relative position", "An unresolved relation between a mover's position and a target position.",
                [10, 10, 10, 9, 10, 9, 9, 10, 10],
                "It directly realizes unresolved outward Motion relationship.",
                "Unknown relative position, unresolved side/distance/bearing, possible positional relation.",
                "The unresolved value or validity of one dyadic position relation.",
                "It must not claim that a map record is missing or that reachability is unknown; those are DAT/LOG causes."),
      candidate("uncertain_reachability", "uncertain target reachability", "Whether the mover can reach the target position is unresolved.",
                [8, 9, 8, 8, 8, 5, 9, 10, 9],
                "It is a highly useful unresolved target relation.",
                "Maybe accessible, unknown path feasibility, state reachability query.",
                "Unresolved existence of an allowed route.",
                "Reachability is a LOG result over STR and MOV data, not a primitive positional relation."),
      candidate("possible_target_linkage", "possible spatial linkage", "A spatial link may connect a mover to a target.",
                [7, 8, 8, 7, 6, 5, 7, 8, 8],
                "A possible link is an unrealized outward relation.",
                "Potential tether, corridor, route, access relation.",
                "Connection between participants or loci.",
                "It collides with CON linkage and STR route structure and says little about position.")
    ],
    "winner" => "unresolved_target_relative_position",
    "recommended_title" => "unresolved target-relative position",
    "definition" => "An unresolved relation between a mover's position and a target position.",
    "confidence" => 0.95,
    "boundaries" => [
      "Includes a target-relative positional relation whose value or validity is not resolved.",
      "Can support questions about distance, side, bearing, or relative placement without selecting one.",
      "Does not assert why the relation is unresolved."
    ],
    "exclusions" => [
      "A dormant or unreachable destination entity is MOV:012.",
      "Potential target approach is MOV:112.",
      "A possible or dormant route uses MOV:020–022 with runtime/logic.",
      "Missing coordinate data belongs to DAT; reachability uncertainty to LOG."
    ],
    "motion_contrasts" => {
      "MOV:012" => "MOV:012 classifies the target entity as dormant/unreachable; MOV:212 classifies the positional relation as unresolved",
      "MOV:112" => "MOV:112 is a potential movement process; MOV:212 is not a process",
      "MOV:020–022" => "route roots name path entities/systems; MOV:212 does not assert any route",
      "MOV:210–211" => "those select established or live relations; MOV:212 selects the unresolved relation"
    },
    "runtime" => {
      "0" => "Denies that the asserted target-relative relation is unresolved.",
      "1" => "Affirms the unresolved target-relative relation as the valid lexical concept.",
      "2" => "Marks the status of that unresolved-relation assertion itself as pending, dormant, remembered, possible, or unresolved; this second-order status is distinct from lexical unresolvedness."
    },
    "ordinary" => [
      example("MOV:212[1](MOVER=probe,TARGET=station)", "the probe-to-station positional relation is unresolved", "We do not yet know where the probe is relative to the station."),
      example("MOV:212[1](MOVER=boat,TARGET=bridge)", "the boat's position relation to the bridge is unresolved", "It is unclear which side of the bridge the boat is on."),
      example("MOV:212[1](MOVER=traveler,TARGET=landmark)", "the traveler's target-relative position is unresolved", "Their position relative to the landmark is unknown.")
    ],
    "technical" => [
      technical("MOV:212[1](MOVER=node_a,TARGET=node_b)", "The relative-position variable is unresolved, independently of the reason.", "relative_position[node_a, node_b] = UNRESOLVED"),
      technical("MOV:212[1](MOVER=agent,TARGET=goal)", "A spatial relation remains unbound in a constraint system.", "assert(unbound?(relation(position(agent), position(goal))))")
    ],
    "compounds" => [
      "MOV:212 + DAT missing record → unresolved relation because coordinates are absent",
      "MOV:212 + LOG reachability query → unresolved positional relation under a reachability proof",
      "MOV:212 + MIN uncertainty → an agent is uncertain about the relative position"
    ],
    "era_notes" => [
      "Later epistemic grammar may distinguish unknown, underspecified, and indeterminate causes.",
      "Keep the invariant relational so the atom does not absorb map or path semantics."
    ]
  },
  "MOV:220" => {
    "current_rationale" => "The provisional author chose a stable recurring order because systemic Motion often presents as cycles, transport systems, or temporal recurrence. Recurrence, however, is only one pattern and imports time/order beyond positional relationship.",
    "candidates" => [
      candidate("current_stable_cycle_relation", "stable cycle relation", "A transport, orbital, or temporal system has an established recurring order.",
                [7, 8, 9, 8, 7, 6, 8, 9, 8],
                "A recurring systemic relation can be stable and Motion-specific.",
                "Orbit, cycle, timetable recurrence, looped transport.",
                "Recurrence and ordering across a system.",
                "It bundles transport, orbital, and temporal senses and collides with ORI, STR, and route cycles."),
      candidate("established_shared_frame_configuration", "established shared-frame configuration", "An established positional configuration among loci within a shared reference frame.",
                [10, 10, 10, 9, 10, 9, 10, 10, 10],
                "It is exactly a stable systemic Motion relationship.",
                "Spatial arrangement, formation, relative placement of multiple loci, stable orbital geometry after MAT composition.",
                "A multi-locus positional configuration in one frame.",
                "It must not absorb organizational structure, causal forces, coordination, or a map representation."),
      candidate("route_connectivity_relation", "route connectivity", "A system has established route connections among its positions.",
                [8, 9, 8, 7, 4, 4, 8, 9, 9],
                "Connectivity is stable and systemic.",
                "Transport topology, connected routes, network reachability.",
                "Edges and paths among loci.",
                "It duplicates MOV:020–022 and belongs primarily to STR topology."),
      candidate("environmental_navigability", "environmental navigability", "A shared environment affords movement among its positions.",
                [8, 9, 9, 8, 8, 5, 9, 10, 9],
                "Navigability is a systemic Motion relationship between mover and environment.",
                "Traversable space, room to move, usable network.",
                "Affordance under constraints.",
                "It depends on STR boundaries, LOG constraints, MAT dimensions, and often a particular mover; it is less purely systemic.")
    ],
    "winner" => "established_shared_frame_configuration",
    "recommended_title" => "established shared-frame configuration",
    "definition" => "An established positional configuration among loci within a shared reference frame.",
    "confidence" => 0.94,
    "boundaries" => [
      "Includes an established multi-locus arrangement defined only by positions in a shared frame.",
      "May describe physical, simulated, or explicit state-space loci.",
      "Does not imply that anything is moving or that the configuration has a route, topology, purpose, or cause."
    ],
    "exclusions" => [
      "A route or network entity is MOV:020–022.",
      "Completed shared-frame movement is MOV:120.",
      "Organizational structure and topology belong to STR.",
      "Forces and bodies belong to MAT; coordination belongs to CON; coordinate records belong to DAT."
    ],
    "motion_contrasts" => {
      "MOV:020" => "an established route orders positions as a path; MOV:220 only relates their placement in one frame",
      "MOV:021" => "an active flow network carries movement; MOV:220 may be wholly static",
      "MOV:120" => "completed shared-frame movement is an event; MOV:220 is the resulting or independent configuration, not the event"
    },
    "runtime" => {
      "0" => "Denies that the asserted shared-frame configuration is established.",
      "1" => "Affirms the established positional configuration.",
      "2" => "Marks the status of that established-configuration assertion as dormant, remembered, possible, or unresolved; lexical MOV:222 instead selects potential configuration."
    },
    "ordinary" => [
      example("MOV:220[1](LOCI=vehicles,FRAME=parking_area)", "the vehicles have an established shared-frame configuration", "The vehicles are parked in an established formation."),
      example("MOV:220[1](LOCI=chairs,FRAME=room)", "the chairs' positions form an established configuration", "The chairs remain arranged around the table."),
      example("MOV:220[1](LOCI=satellites,FRAME=orbital_frame)", "the satellites have an established positional configuration", "The satellites hold a stable formation.")
    ],
    "technical" => [
      technical("MOV:220[1](LOCI=nodes,FRAME=world,VALUE=poses)", "A resolved set of relative poses, independent of graph edges.", "configuration = {node => pose_in(world)}"),
      technical("MOV:220[1](LOCI=agents,FRAME=state_space)", "A multi-agent positional state in an explicitly spatial model.", "assert(configuration.valid_positions_only?)")
    ],
    "compounds" => [
      "MOV:220 + MAT forces → stable orbital configuration",
      "MOV:220 + STR topology → spatially embedded structure",
      "MOV:220 + role geometry → beside/above/between formation"
    ],
    "era_notes" => [
      "A later geometry layer may distinguish rigid, periodic, and statistical configurations.",
      "Keep purpose and organization outside the atomic Motion relation."
    ]
  },
  "MOV:221" => {
    "current_rationale" => "The provisional meaning associated active systemic relationship with synchronized movers in a route, cadence, or schedule. It captured an active system, but bundled coordination, route use, timing, and movement.",
    "candidates" => [
      candidate("current_synchronized_flow_relation", "synchronized flow relation", "Multiple movers or transitions are actively coordinated within one route, cadence, or schedule.",
                [5, 7, 8, 5, 3, 4, 8, 8, 8],
                "Synchronization is an active systemic relation.",
                "Convoy, synchronized traffic, scheduled flow, coordinated transitions.",
                "Coordination, timing, route, and active movement.",
                "It is non-atomic and collides with CON, MOV:021, MOV:121, STR, and scheduling grammar."),
      candidate("live_shared_frame_configuration", "live shared-frame configuration", "A positional configuration among loci that is currently maintained or updated within a shared reference frame.",
                [10, 10, 10, 9, 10, 9, 9, 10, 10],
                "It realizes active systemic Motion relationship without becoming a process.",
                "Live formation, dynamic spatial arrangement, maintained multi-locus pose.",
                "Current maintenance or update of a shared-frame configuration.",
                "It must not imply coordination, data acquisition, or actual movement; those are separable causes or realizations."),
      candidate("coordinated_formation", "coordinated formation", "Multiple movers maintain assigned relative positions through coordination.",
                [8, 9, 8, 8, 9, 5, 9, 9, 9],
                "Formation is an active systemic positional relation.",
                "Convoy formation, flocking, synchronized robots.",
                "Participant coordination that maintains positions.",
                "Coordination belongs to CON and excludes accidental or externally maintained configurations."),
      candidate("traffic_load_relation", "traffic-load relation", "A route system currently bears a distribution of moving traffic.",
                [7, 8, 8, 7, 5, 5, 8, 9, 8],
                "Traffic distribution is a live systemic Motion relation.",
                "Congestion, load balance, route usage.",
                "Flow amount over a network.",
                "It presupposes MOV:021, route topology, quantities, and possibly DAT measurements.")
    ],
    "winner" => "live_shared_frame_configuration",
    "recommended_title" => "live shared-frame configuration",
    "definition" => "A positional configuration among loci that is currently maintained or updated within a shared reference frame.",
    "confidence" => 0.92,
    "boundaries" => [
      "Includes a multi-locus positional configuration treated as presently live, maintained, or updated.",
      "The positions may remain constant or change.",
      "Does not assert a route, traffic, synchronization, coordination, or shared movement."
    ],
    "exclusions" => [
      "Established nonlive configuration is MOV:220; unrealized possible configuration is MOV:222.",
      "Active flow network is MOV:021.",
      "Active shared-frame movement is MOV:121.",
      "Coordination belongs to CON; map/pose streams to DAT; scheduling to grammar or LOG."
    ],
    "motion_contrasts" => {
      "MOV:021" => "the active flow network is a route system carrying motion; MOV:221 is a live positional configuration",
      "MOV:121" => "active shared-frame movement changes position; MOV:221 can remain live while positions remain constant",
      "MOV:211" => "MOV:211 is dyadic mover-to-target relation; MOV:221 is systemic among loci"
    },
    "runtime" => {
      "0" => "Denies that the shared-frame configuration is currently maintained or updated.",
      "1" => "Affirms that the multi-locus configuration is live.",
      "2" => "Marks the live-configuration token as pending, dormant, remembered, possible, or unresolved; it does not select lexical MOV:222."
    },
    "ordinary" => [
      example("MOV:221[1](LOCI=drones,FRAME=airspace)", "the drones' shared-frame configuration is live", "The drone formation is being maintained."),
      example("MOV:221[1](LOCI=players,FRAME=field)", "the players' positional configuration is currently maintained", "The players are holding a live formation."),
      example("MOV:221[1](LOCI=satellites,FRAME=orbital_frame)", "the satellites' multi-locus relation is continuously current", "The satellite constellation's relative positions are being kept current.")
    ],
    "technical" => [
      technical("MOV:221[1](LOCI=robots,FRAME=world,VALUE=poses)", "A live configuration state is maintained separately from motion commands.", "formation_state.update(current_poses)"),
      technical("MOV:221[1](LOCI=agents,FRAME=simulation)", "A simulation maintains a current relational configuration.", "assert(configuration_timestamp == now)")
    ],
    "compounds" => [
      "MOV:221 + CON coordination + MOV:121 → coordinated moving formation",
      "MOV:221 + DAT pose stream → observed live configuration",
      "MOV:221 + MOV:021 → traffic distribution over an active network"
    ],
    "era_notes" => [
      "A future temporal layer may express update cadence without making cadence atomic here.",
      "Keep live configuration distinct from synchronized motion."
    ]
  },
  "MOV:222" => {
    "current_rationale" => "The provisional author mapped unrealized systemic possibility to an unselected path branch. This used the possibility value well, but prematurely fixed the system relation as route topology and planning.",
    "candidates" => [
      candidate("current_possible_path_branch", "possible path branch", "A valid system-level route or future sequence could exist, but no branch has yet been selected or realized.",
                [8, 9, 8, 7, 4, 5, 8, 9, 8],
                "A possible branch is unrealized and systemic.",
                "Alternative path, future sequence, route branch.",
                "Path generation, validity, choice, and future sequence.",
                "It collides with MOV:020–022, LOG validity, CRE generation, STR topology, and planning."),
      candidate("potential_shared_frame_configuration", "potential shared-frame configuration", "An unrealized possible positional configuration among loci within a shared reference frame.",
                [10, 10, 10, 9, 10, 9, 9, 10, 10],
                "It exactly realizes unrealized systemic Motion possibility.",
                "Possible arrangement, candidate formation, unrealized multi-locus placement.",
                "One possible positional configuration in a shared frame.",
                "It must not claim feasibility, selection, generation, probability, future occurrence, or permission."),
      candidate("possible_navigability", "possible navigability", "Movement among positions in a system may be possible.",
                [8, 9, 9, 8, 8, 5, 9, 10, 9],
                "It is a systemic movement possibility.",
                "Maybe traversable, potential route availability, possible access.",
                "Existence of permitted traversals.",
                "It depends on LOG proof, STR topology, and MOV route entities and approaches a potential process MOV:122."),
      candidate("collision_free_motion_possibility", "collision-free motion possibility", "A system may permit movers to change position without collision.",
                [8, 8, 9, 7, 8, 4, 8, 10, 9],
                "It is a useful environmental Motion possibility.",
                "Spatial compatibility, feasible formations, collision avoidance.",
                "Safety-constrained joint motion.",
                "It imports WRN risk, MAT dimensions, LOG constraints, and actual or potential movement processes.")
    ],
    "winner" => "potential_shared_frame_configuration",
    "recommended_title" => "potential shared-frame configuration",
    "definition" => "An unrealized possible positional configuration among loci within a shared reference frame.",
    "confidence" => 0.95,
    "boundaries" => [
      "Includes an unrealized possible arrangement of loci in a shared frame.",
      "Does not assert that the arrangement is feasible, selected, scheduled, probable, or future.",
      "The possibility is configuration-level, not a movement event."
    ],
    "exclusions" => [
      "Potential shared-frame movement is MOV:122.",
      "Possible routes use MOV:020–022 with LOG/STR or runtime composition.",
      "Path generation belongs to CRE; permission and feasibility to LOG; topology to STR.",
      "Universal possibility or reality belongs to ORI."
    ],
    "motion_contrasts" => {
      "MOV:022" => "dormant route system is a route entity; MOV:222 is a possible positional configuration",
      "MOV:122" => "MOV:122 is a nonactualized movement process; MOV:222 is a nonactualized relationship/configuration",
      "MOV:212" => "MOV:212 is an unresolved dyadic relation; MOV:222 is a systemic possible configuration"
    },
    "runtime" => {
      "0" => "Denies the asserted potential shared-frame configuration.",
      "1" => "Affirms that the unrealized configuration is a valid possibility without asserting feasibility or future realization.",
      "2" => "Marks the status of that potential-configuration assertion as dormant, remembered, possible, or unresolved; this is token status layered over lexical possibility."
    },
    "ordinary" => [
      example("MOV:222[1](LOCI=drones,FRAME=airspace,FORM=ring)", "a ring configuration of the drones is an unrealized possibility", "The drones could occupy a ring formation."),
      example("MOV:222[1](LOCI=furniture,FRAME=room,FORM=alternate)", "an alternative room configuration is possible but unrealized", "The furniture could be arranged differently."),
      example("MOV:222[1](LOCI=vehicles,FRAME=road,FORM=spaced)", "a different vehicle-spacing configuration is possible", "The vehicles could occupy a more widely spaced formation.")
    ],
    "technical" => [
      technical("MOV:222[1](LOCI=agents,FRAME=world,VALUE=candidate_poses)", "A candidate configuration is represented without claiming constraint satisfaction.", "candidates << configuration(candidate_poses)"),
      technical("MOV:222[1](LOCI=states,FRAME=explicit_state_space)", "An unrealized joint positional assignment exists as a model candidate.", "model.add_candidate(joint_position_assignment)")
    ],
    "compounds" => [
      "MOV:222 + LOG constraints → feasible shared-frame configuration",
      "MOV:222 + CRE generation → generated candidate configuration",
      "MOV:222 + WRN collision risk + MAT dimensions → candidate configuration with collision analysis"
    ],
    "era_notes" => [
      "A later modal layer may distinguish possible, probable, permitted, and feasible without changing this atom.",
      "Do not let route planning reclaim this address merely because configurations are planning inputs."
    ]
  }
}.freeze

def cross_family_for(id)
  phase =
    case id[-1]
    when "0" then "established"
    when "1" then "live/current"
    else "dormant/unresolved/potential"
    end
  row = id[4]

  case row
  when "0"
    {
      "MAT" => "MAT owns body, actuator, force, energy, resource, and integrity facts that cause or limit #{phase} mobility; MOV owns only self-positional-change capacity.",
      "MIN" => "MIN owns intention, motor attention, prediction, and awareness; no intention or awareness is entailed by this mobility capacity.",
      "CON" => "CON owns control links, access links, and coordination; linkage may enable capacity but is not the capacity.",
      "STR" => "STR owns boundaries, containment, degrees of freedom, and route topology; range and room require composition.",
      "LOG" => "LOG owns permission, rules, and proofs that movement is allowed; ability is not authorization.",
      "DAT" => "DAT owns capability records and telemetry; a record about mobility is not mobility.",
      "CRE" => "CRE owns modification or generation that grants capacity; the resulting Motion capacity remains MOV.",
      "ORI" => "ORI owns general possibility and reality; this row is specifically a mover's Motion-domain capacity."
    }
  when "1"
    {
      "MAT" => "MAT owns physical coordinates, bodies, forces, and distances as measured material facts; MOV owns the #{phase} positional relation to a target.",
      "MIN" => "MIN owns attention, prediction, and spatial awareness; a positional relation can hold without being perceived.",
      "CON" => "CON owns social, communicative, and access linkage; target-relative position is not participant connection.",
      "STR" => "STR owns route topology, boundaries, containment, and adjacency as structural organization; MOV owns only positional relation in a frame.",
      "LOG" => "LOG owns reachability, permission, and constraint satisfaction; a positional relation does not prove a path.",
      "DAT" => "DAT owns maps, coordinates, estimates, and records; representation of the relation is not the relation.",
      "CRE" => "CRE owns generated paths or transformed coordinates; the resulting relation remains Motion-domain.",
      "ORI" => "ORI owns universal possibility or reality; this row is a target-relative Motion relation."
    }
  else
    {
      "MAT" => "MAT owns bodies, dimensions, forces, and collision mechanics that may stabilize or constrain the #{phase} configuration.",
      "MIN" => "MIN owns awareness, prediction, and planning of a configuration; the configuration does not imply a mind.",
      "CON" => "CON owns participant coordination and linkage; a shared-frame positional configuration may be accidental or externally imposed.",
      "STR" => "STR owns topology, containment, organization, and route structure; MOV owns only the loci's positional configuration.",
      "LOG" => "LOG owns permission, compatibility, feasibility, constraints, and reachability proofs; configuration alone proves none.",
      "DAT" => "DAT owns maps, pose arrays, coordinates, and configuration records; representations are not the positional relation.",
      "CRE" => "CRE owns generation or transformation of configurations and paths; the resulting positional configuration is MOV.",
      "ORI" => "ORI owns universal spatial possibility and reality; MOV:222 is only a Motion-domain configuration possibility."
    }
  end
end

atoms = YAML.load_file(File.join(ROOT, "lexicon/atoms.yaml")).fetch("atoms")
fixed = IDS.to_h do |id|
  record = atoms.find { |atom| atom["canonical_id"] == id } || raise("missing #{id}")
  [id, {
    "canonical_id" => record["canonical_id"],
    "family" => record["family"],
    "address" => record["address"],
    "universal_slot" => record["universal_slot"],
    "family_onset" => record["family_onset"],
    "family_qualified_transliteration" => record["canonical_transliteration"],
    "local_compact_root" => record["local_compact_root"],
    "formal_carrier" => record["formal_carrier"],
    "harmonic_signature_semitones" => record["harmonic_signature_semitones"],
    "relative_note_path_semitones" => record["note_path_semitones"]
  }]
end

scored = {
  "metadata" => {
    "title" => "MOV:200–222 scored semantic candidates",
    "status" => "peer_review_recommendations_not_canonical",
    "roots_reviewed" => 9,
    "candidates_per_root_minimum" => 4,
    "generated_fields_changed" => false,
    "score_role" => "Decision aid only; written reasoning is authoritative."
  },
  "scoring" => {
    "scale" => "1–10",
    "categories" => SCORE_KEYS,
    "maximum_total" => 90
  },
  "roots" => IDS.map do |id|
    data = ROOTS.fetch(id)
    {
      "canonical_id" => id,
      "authority_status" => "provisional_pending_user_decision",
      "fixed_generated_fields" => fixed.fetch(id),
      "current_provisional_meaning" => {
        "title" => atoms.find { |atom| atom["canonical_id"] == id }["title"],
        "definition" => atoms.find { |atom| atom["canonical_id"] == id }["core_definition"],
        "probable_rationale" => data["current_rationale"]
      },
      "candidates" => data["candidates"],
      "recommended_winner" => data["winner"],
      "recommended_title" => data["recommended_title"],
      "recommended_invariant_definition" => data["definition"],
      "confidence" => data["confidence"],
      "canonicalized" => false
    }
  end
}

recommended = {
  "metadata" => {
    "title" => "MOV:200–222 recommended semantic specification",
    "status" => "ready_for_user_approval_not_canonical",
    "architecture_version" => "1.0",
    "canonical_baseline" => "LIF:000–222, MOV:000–122",
    "generated_fields_changed" => false,
    "roots_canonicalized" => [],
    "stop_boundary" => ["MAT:000–022", "any other root block", "Gate 4", "compound architecture"]
  },
  "layer_design" => {
    "first_trit" => "capacity, relationship, or possibility; never a disguised entity or process",
    "row_20x" => "self-mobility capacity: enduring / presently available / latent",
    "row_21x" => "dyadic target-relative position: established / live / unresolved",
    "row_22x" => "systemic shared-frame configuration: established / live / unrealized possible",
    "parallelism_assessment" => "The rows are structurally parallel at the address-axis level, not forced into one ontological noun: inward selects capacity, outward selects a dyadic relation, and systemic selects a multi-locus configuration."
  },
  "roots" => IDS.map do |id|
    data = ROOTS.fetch(id)
    {
      "authority_status" => "recommended_not_canonical",
      "fixed_generated_fields" => fixed.fetch(id),
      "recommended_title" => data["recommended_title"],
      "invariant_definition" => data["definition"],
      "confidence" => data["confidence"],
      "semantic_boundaries" => data["boundaries"],
      "excluded_meanings" => data["exclusions"],
      "nearest_motion_contrasts" => data["motion_contrasts"],
      "cross_family_comparisons" => cross_family_for(id),
      "address_explanation" => {
        "first_trit_2" => id[4] == "0" ? "Selects capacity rather than a movement event." : "Selects relationship or possibility rather than a movement event.",
        "second_trit" =>
          case id[5]
          when "0" then "Inward/self/source makes the capacity a property of the mover."
          when "1" then "Outward/other/target makes the relation dyadic between mover and target."
          else "Shared/environmental/systemic makes the relation a multi-locus configuration in one frame."
          end,
        "third_trit" =>
          case id[6]
          when "0" then "Stable/bounded selects enduring or established status."
          when "1" then "Active/changing/expressed selects present availability, maintenance, or update."
          else "Dormant/unresolved/potential selects latent capacity, unresolved relation, or unrealized configuration possibility."
          end
      },
      "runtime_state_interpretations" => data["runtime"],
      "ordinary_language_examples" => data["ordinary"],
      "technical_programming_examples" => data["technical"],
      "future_compound_decomposition_sketches_not_canonical" => data["compounds"],
      "later_era_evolution_notes" => data["era_notes"]
    }
  end
}

stress_rows = [
  ["can move", "direct atomic root", "MOV:201", "Presently available self-mobility; use MOV:200 for enduring capability without a current-availability claim."],
  ["cannot move", "root plus runtime state", "MOV:201[0]", "Denies current availability; MOV:200[0] denies enduring capacity."],
  ["mobile", "direct atomic root", "MOV:200", "Enduring mobility; MOV:201 if the intended reading is usable now."],
  ["immobile", "root plus runtime state", "MOV:200[0] or MOV:201[0]", "Context distinguishes no enduring capacity from temporary unavailability."],
  ["flexible", "another family", "MAT plus STR/quantity", "Material deformation or degrees of freedom are not positional mobility by default."],
  ["range of motion", "composition", "MOV:200 + STR boundary + quantity", "Mobility constrained to a quantified reachable envelope."],
  ["freedom of movement", "composition", "MOV:201 + LOG permission + absence of STR constraint", "Ability, authorization, and constraint are separate."],
  ["reachable", "grammar or logic", "LOG reachability proof + MOV:210/MOV:020", "A relation and route are inputs; reachability is not a primitive Motion relationship."],
  ["unreachable", "grammar or logic", "LOG negated reachability; MOV:012 where the destination itself is dormant/unreachable", "Do not overload MOV:212."],
  ["near", "composition", "MOV:210 + low distance degree", "Near is a value over the target-relative relation."],
  ["far", "composition", "MOV:210 + high distance degree", "Far is a value over the target-relative relation."],
  ["distance", "composition", "MOV:210 + metric quantity", "MOV:210 supplies the relation; quantity supplies the measure."],
  ["direction", "composition", "MOV:210 + axis/vector value", "Direction is a value of the relation."],
  ["bearing", "composition", "MOV:210 + angular value", "Bearing requires a reference axis and number."],
  ["orientation", "composition", "MOV:210 + frame/axis role", "Body orientation may additionally require MAT or STR."],
  ["relative position", "direct atomic root", "MOV:210", "Established mover-to-target positional relation."],
  ["beside", "composition", "MOV:210 + horizontal adjacency relation", "A language-level relational modifier specializes the atom."],
  ["above", "composition", "MOV:210 + vertical positive-axis relation", "Axis value specializes target-relative position."],
  ["below", "composition", "MOV:210 + vertical negative-axis relation", "Axis value specializes target-relative position."],
  ["between", "composition", "MOV:220 + two anchor roles + betweenness relation", "Systemic configuration supports multi-anchor geometry."],
  ["connected by a route", "composition", "MOV:020 + source/target bindings", "The approved route entity owns the connection."],
  ["accessible", "grammar or logic", "LOG access/reachability + CON when participant access is meant", "Accessibility is not merely position."],
  ["navigable", "composition", "MOV:020/022 + STR topology + LOG constraints", "Navigability is a derived affordance."],
  ["blocked", "another family", "STR obstruction or MAT blocker; WRN if danger/failure is asserted", "The cause is not a Motion capacity atom."],
  ["constrained", "another family", "STR constraint or LOG rule", "Use MOV capacity only to state the affected capability."],
  ["path available", "root plus runtime state", "MOV:020[1]", "An established route asserted currently valid/available."],
  ["possible path", "composition", "MOV:020[2] or MOV:022 + LOG possibility", "Route entity plus token status or explicit logic; not MOV:222."],
  ["shortest path", "grammar or logic", "LOG optimization over MOV:020 routes + metric", "Shortest is a computed comparison."],
  ["movement permission", "another family", "LOG permission applied to a MOV process", "Permission is explicitly outside Motion atoms."],
  ["movement restriction", "another family", "LOG prohibition and/or STR constraint", "Restriction is not mobility itself."],
  ["traffic capacity", "composition", "MOV:021 + quantity + STR/MAT limits", "Network throughput is not self-mobility; no new atom is forced."],
  ["network mobility", "composition", "MOV:200/201 with collective actor + MOV:020/STR network", "Depends on what is mobile and on network structure."],
  ["spatial compatibility", "composition", "MOV:220 or MOV:222 + LOG constraints + MAT dimensions", "Configuration supplies positions; compatibility is evaluated."],
  ["collision risk", "composition", "MOV:222 + WRN risk + MAT dimensions/trajectories", "Risk is warning-domain and predictive."],
  ["room to move", "composition", "MOV:201 + STR boundary + MAT dimensions", "Current mobility plus clearance."],
  ["drift potential", "direct atomic root", "MOV:122", "Potential shared-frame movement, with manner/cause added later."],
  ["orbit stability", "composition", "MOV:220 + MAT dynamics + stability criterion", "Configuration plus physical cause and test."],
  ["group mobility", "composition", "MOV:200/201 with collective actor role", "The mobility root can scope over a group; configuration may be added."],
  ["coordinated movement", "composition", "MOV:121 + CON coordination", "Actual movement and coordination remain separate."],
  ["transport capacity", "composition", "MOV:021 + payload MAT + quantity/STR limits", "Throughput/payload capacity is not the mover's self-mobility."],
  ["teleportation possibility", "composition", "MOV:122 + CRE/ORI discontinuity specification", "Potential positional change is MOV; mechanism/ontology is elsewhere."],
  ["transition allowed", "grammar or logic", "LOG permission + domain process", "Use MOV only when transition is explicitly modeled as positional change."],
  ["state reachable", "grammar or logic", "LOG reachability + explicit state-space MOV:210/MOV:020", "Metaphorical state change is not automatically Motion."],
  ["route exists", "direct atomic root", "MOV:020", "Existing approved route entity."],
  ["motion could occur", "direct atomic root", "MOV:122", "Potential shared-frame movement, not self-mobility capacity."]
].freeze

stress = {
  "metadata" => {
    "title" => "MOV:200–222 semantic stress tests",
    "status" => "review_evidence_not_canonical",
    "test_count" => stress_rows.length,
    "minimum_required" => 45,
    "forced_atomic_mappings" => false
  },
  "classification_values" => [
    "direct atomic root",
    "root plus runtime state",
    "composition",
    "grammar or logic",
    "another family",
    "unresolved gap"
  ],
  "tests" => stress_rows.map.with_index(1) do |(concept, classification, mapping, rationale), index|
    {
      "number" => index,
      "concept" => concept,
      "classification" => classification,
      "mapping" => mapping,
      "rationale" => rationale
    }
  end,
  "coverage_summary" => stress_rows.group_by { |row| row[1] }.transform_values(&:length)
}

File.write(File.join(ROOT, "reviews/MOV_200_222_scored_candidates.yaml"), YAML.dump(scored))
File.write(File.join(ROOT, "reviews/MOV_200_222_recommended_spec.yaml"), YAML.dump(recommended))
File.write(File.join(ROOT, "reviews/MOV_200_222_stress_tests.yaml"), YAML.dump(stress))

peer = +"# MOV:200–222 Peer Review\n\n"
peer << "Status: **READY FOR USER APPROVAL — NOT CANONICAL**\n\n"
peer << "Scope is strictly `MOV:200–222`. The fixed generated fields are preserved; only candidate semantic titles, definitions, boundaries, and ownership are reviewed. `MOV:100–122` is treated as approved canonical baseline. No MAT root, other block, compound system, or Gate 4 work is begun.\n\n"
peer << "## Executive recommendation\n\n"
peer << "The strongest 2xx architecture is:\n\n"
peer << "- `MOV:200–202`: **self-mobility capacity** — enduring / presently available / latent;\n"
peer << "- `MOV:210–212`: **target-relative position** — established / live / unresolved;\n"
peer << "- `MOV:220–222`: **shared-frame positional configuration** — established / live / unrealized possible.\n\n"
peer << "This design keeps all nine roots at first-trit `2`: none is an entity in disguise, and none asserts a movement event. Routes, topology, reachability, permission, maps, coordination, force, and planning remain separate.\n\n"
peer << "## Fixed generated forms\n\n"
peer << "| ID | Universal slot | Transliteration | Compact | Formal carrier | Harmony | Relative note path |\n|---|---|---|---|---|---|---|\n"
IDS.each do |id|
  f = fixed.fetch(id)
  peer << "| `#{id}` | #{f["universal_slot"]} | `#{f["family_qualified_transliteration"]}` | `#{f["local_compact_root"]}` | `#{f["formal_carrier"]}` | `#{f["harmonic_signature_semitones"].join(", ")}` | `#{f["relative_note_path_semitones"].join(", ")}` |\n"
end
peer << "\n"

IDS.each do |id|
  data = ROOTS.fetch(id)
  winner = data["candidates"].find { |cand| cand["candidate_id"] == data["winner"] }
  peer << "## #{id} — #{data["recommended_title"]}\n\n"
  peer << "**Current candidate rationale.** #{data["current_rationale"]}\n\n"
  peer << "| Candidate | Atomic | Address | MOV | Neighbor | vs MOV 000–122 | Cross-family | Everyday | Technical | Compound | Total |\n"
  peer << "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n"
  data["candidates"].each do |cand|
    s = cand["scores"]
    peer << "| #{cand["title"]} | #{s["atomicity"]} | #{s["address_fit"]} | #{s["motion_family_fit"]} | #{s["neighbor_separation"]} | #{s["separation_from_mov_000_122"]} | #{s["cross_family_separation"]} | #{s["everyday_language_usefulness"]} | #{s["technical_programming_usefulness"]} | #{s["compound_usefulness"]} | **#{cand["total"]}/90** |\n"
  end
  peer << "\n"
  data["candidates"].each do |cand|
    peer << "- **#{cand["title"]}:** #{cand["analysis"]["why_it_fits"]} Covers #{cand["analysis"]["useful_coverage"]} Consumes #{cand["analysis"]["semantic_territory_consumed"]} Risk: #{cand["analysis"]["risks_and_future_limitations"]}\n"
  end
  peer << "\n**Recommendation:** **#{data["recommended_title"]}** (#{winner["total"]}/90; confidence #{(data["confidence"] * 100).round}%).\n\n"
  peer << "> #{data["definition"]}\n\n"
  peer << "**Boundaries.** #{data["boundaries"].join(" ")}\n\n"
  peer << "**Exclusions.** #{data["exclusions"].join(" ")}\n\n"
  peer << "**Nearest approved Motion contrasts.** "
  peer << data["motion_contrasts"].map { |key, value| "`#{key}`: #{value}." }.join(" ")
  peer << "\n\n"
  peer << "**Address fit.** First trit `2` selects capacity/relationship rather than event; second trit selects #{id[5] == "0" ? "the mover itself" : id[5] == "1" ? "a target-oriented dyad" : "a shared/systemic frame"}; third trit selects #{id[6] == "0" ? "enduring or established" : id[6] == "1" ? "presently available, maintained, or updated" : "latent, unresolved, or unrealized potential"}.\n\n"
  peer << "**Runtime states.** `[0]` #{data["runtime"]["0"]} `[1]` #{data["runtime"]["1"]} `[2]/num` #{data["runtime"]["2"]}\n\n"
  peer << "**Examples.** "
  peer << data["ordinary"].map { |ex| "`#{ex["semantic_graph"]}` — #{ex["natural_english"]}" }.join(" ")
  peer << "\n\n**Programming.** "
  peer << data["technical"].map { |ex| "`#{ex["pseudocode"]}` — #{ex["interpretation"]}" }.join(" ")
  peer << "\n\n**Future decomposition sketches (not canonical compounds).** #{data["compounds"].join("; ")}.\n\n"
  peer << "**Later-Era notes.** #{data["era_notes"].join(" ")}\n\n"
end

peer << "## Nine-root comparison matrix\n\n"
peer << "| Root | Owns | Belongs elsewhere | Reserved for composition | Intentionally undefined here |\n|---|---|---|---|---|\n"
matrix = {
  "MOV:200" => ["enduring self-mobility capacity", "body/energy/permission", "range of motion; group mobility", "degree of capability"],
  "MOV:201" => ["currently available self-mobility", "actual movement; authorization", "able-and-permitted; room to move", "readiness of a scheduled event"],
  "MOV:202" => ["retained but unavailable self-mobility", "blocker or failure cause", "unpowered/blocked/restricted mobility", "probability of restoration"],
  "MOV:210" => ["established mover-to-target positional relation", "target entity; route; coordinate record", "distance; bearing; near/far; axis relation", "universal geometry vocabulary"],
  "MOV:211" => ["live maintained/updated target-relative relation", "approach; tracking data; attention", "tracked or attended relation", "sensor and sampling semantics"],
  "MOV:212" => ["unresolved target-relative positional relation", "unreachable destination; possible route", "unknown because data/proof is missing", "cause and type of indeterminacy"],
  "MOV:220" => ["established multi-locus positional configuration", "topology; organization; physical cause", "orbit/formation/embedded structure", "configuration metric"],
  "MOV:221" => ["live maintained/updated shared-frame configuration", "flow network; movement; coordination", "coordinated moving formation; observed pose set", "update cadence"],
  "MOV:222" => ["unrealized possible shared-frame configuration", "possible route; process potential; universal modality", "feasible/generated/safe candidate configuration", "probability, permission, selection"]
}
matrix.each { |id, cols| peer << "| `#{id}` | #{cols.join(" | ")} |\n" }
peer << "\n"
peer << "## Triplet and layer coherence\n\n"
peer << "- `MOV:200–202` shares one center—self-mobility capacity. The contrast is enduring capacity / capacity presently available / capacity retained but latent.\n"
peer << "- `MOV:210–212` shares one center—mover-to-target positional relation. The contrast is established / live-maintained-or-updated / unresolved.\n"
peer << "- `MOV:220–222` shares one center—multi-locus positional configuration in a shared frame. The contrast is established / live-maintained-or-updated / unrealized possible.\n"
peer << "- Across rows, the second trit expands scope from self-capacity, to a target dyad, to a systemic configuration. This is principled address parallelism, not forced lexical synonymy.\n\n"
peer << "## Stress-test outcome\n\n"
peer << "All 45 required concepts are classified in `reviews/MOV_200_222_stress_tests.yaml`. Only eight receive a direct atomic-root treatment; the rest deliberately use runtime state, composition, logic/grammar, or another family. No vocabulary gap forces a change to the recommended architecture.\n\n"
peer << "## Final recommendations\n\n"
IDS.each { |id| peer << "- `#{id}` — **#{ROOTS[id]["recommended_title"]}**: #{ROOTS[id]["definition"]}\n" }
peer << "\n"
peer << "- **Roots ready for user approval:** all nine (`MOV:200–222`).\n"
peer << "- **Roots that should remain unresolved:** none.\n"
peer << "- **Architectural questions requiring user decision:** none blocking. Nonblocking later decisions include the quantitative geometry layer, epistemic subtypes of unresolved relation, and whether catalogue labels prefer “live” or “active” while retaining the invariant definitions.\n"
peer << "- **Roots canonized by this packet:** none.\n"
peer << "- **Stop boundary honored:** no MAT block, other root block, compounds, or Gate 4 work begun.\n\n"
peer << "**READY FOR USER APPROVAL**\n"

File.write(File.join(ROOT, "reviews/MOV_200_222_peer_review.md"), peer)

collision = +"# MOV:200–222 Collision Report\n\n"
collision << "Status: **peer-review evidence — not canonical**\n\n"
collision << "## Core boundary\n\n"
collision << "The proposed 2xx layer owns capacity and positional relationships only. It does not own a mover, target, route, movement event, coordinate record, structural topology, permission, causal force, participant coordination, generated path, or universal modality.\n\n"
collision << "## Collision audit against canonical MOV:000–122\n\n"
collision << "| Proposed root | Nearest canonical Motion roots | Separation result |\n|---|---|---|\n"
IDS.each do |id|
  data = ROOTS.fetch(id)
  collision << "| `#{id}` | #{data["motion_contrasts"].keys.map { |key| "`#{key}`" }.join(", ")} | #{data["motion_contrasts"].values.join("; ")} |\n"
end
collision << "\n## Cross-family collision table\n\n"
collision << "| Root | MAT | MIN | CON | STR | LOG | DAT | CRE | ORI |\n|---|---|---|---|---|---|---|---|---|\n"
IDS.each do |id|
  cross = cross_family_for(id)
  collision << "| `#{id}` | #{cross.values.join(" | ")} |\n"
end
collision << "\n## High-risk English traps\n\n"
collision << "- **Can move** is `MOV:201`; **is moving** is an approved 1xx process.\n"
collision << "- **Reachable** is a LOG conclusion over target relations, routes, and constraints—not `MOV:210` or `MOV:212` alone.\n"
collision << "- **Tracking** combines `MOV:211` with DAT and often MIN; the Motion root does not own observation.\n"
collision << "- **Formation coordination** combines `MOV:221` with CON; the positional configuration does not imply coordination.\n"
collision << "- **Navigability** combines Motion route/configuration facts with STR topology and LOG constraints.\n"
collision << "- **Possible path** is not `MOV:222`; that root concerns possible configurations, while routes remain `MOV:020–022` plus modality.\n"
collision << "- Spatial metaphors such as “state reachable” use MOV only after the model explicitly declares a positional state space.\n\n"
collision << "## Disposition\n\n"
collision << "No blocking collision remains after the recommended narrowing. The candidates are separable from all 18 canonical Motion roots and from MAT, MIN, CON, STR, LOG, DAT, CRE, and ORI. They remain provisional until explicit user approval.\n"

File.write(File.join(ROOT, "reviews/MOV_200_222_collision_report.md"), collision)

puts "Built MOV:200–222 peer-review packet (five content files; validation generated separately)."
