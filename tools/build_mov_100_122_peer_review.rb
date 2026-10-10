#!/usr/bin/env ruby

require "yaml"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
REVIEW_DIR = File.join(ROOT, "reviews")
FileUtils.mkdir_p(REVIEW_DIR)

IDS = %w[MOV:100 MOV:101 MOV:102 MOV:110 MOV:111 MOV:112 MOV:120 MOV:121 MOV:122].freeze
SCORE_CATEGORIES = [
  "atomicity",
  "address_fit",
  "family_fit",
  "neighbor_separation",
  "cross_family_separation",
  "compound_usefulness",
  "everyday_language_coverage",
  "technical_coverage"
].freeze

def score(atomicity, address_fit, family_fit, neighbor_separation,
          cross_family_separation, compound_usefulness,
          everyday_language_coverage, technical_coverage)
  {
    "atomicity" => atomicity,
    "address_fit" => address_fit,
    "family_fit" => family_fit,
    "neighbor_separation" => neighbor_separation,
    "cross_family_separation" => cross_family_separation,
    "compound_usefulness" => compound_usefulness,
    "everyday_language_coverage" => everyday_language_coverage,
    "technical_coverage" => technical_coverage
  }
end

def candidate(id:, title:, definition:, direction:, scores:, note:, current: false, winner: false)
  {
    "candidate_id" => id,
    "title" => title,
    "invariant_candidate" => definition,
    "semantic_direction" => direction,
    "is_current_phase2_candidate" => current,
    "recommended_winner" => winner,
    "scores" => scores,
    "total_score" => scores.values.sum,
    "peer_review_note" => note
  }
end

atoms = YAML.load_file(File.join(ROOT, "lexicon/atoms.yaml")).fetch("atoms")
atom_by_id = atoms.to_h { |atom| [atom.fetch("canonical_id"), atom] }

reviews = {
  "MOV:100" => {
    "why_current_was_chosen" => "The second trit's source reading naturally suggests motion away from an origin, while the third trit's completed value suggests the post-departure condition. It also creates an intuitive mirror with target-arrival MOV:110.",
    "candidates" => [
      candidate(
        id: "current_departure_complete",
        title: "departure complete",
        definition: "Movement away from the source has finished and the mover is no longer occupying its starting position.",
        direction: "Source-relative displacement completed.",
        scores: score(8, 9, 10, 9, 9, 9, 9, 8),
        note: "Strong and ordinary, but the original wording mixes completion with a derived occupancy consequence. It survives if tightened to one invariant.",
        current: true,
        winner: true
      ),
      candidate(
        id: "self_relocation_complete",
        title: "self-relocation completed",
        definition: "A mover has completed changing its own position.",
        direction: "Generic self-caused displacement rather than source separation.",
        scores: score(7, 6, 9, 4, 8, 8, 9, 9),
        note: "Technically useful but too broad: it consumes arrival and route traversal and wastes the second-trit contrast."
      ),
      candidate(
        id: "inward_convergence_complete",
        title: "inward convergence completed",
        definition: "Motion toward an internal or source center has finished.",
        direction: "Centripetal motion toward the source/self.",
        scores: score(9, 7, 10, 8, 9, 7, 6, 7),
        note: "A literal reading of inward, but it competes conceptually with target approach once the source is treated as the target and has weaker everyday coverage."
      ),
      candidate(
        id: "motion_initiation_complete",
        title: "motion initiation completed",
        definition: "A mover's transition from rest into motion has finished.",
        direction: "Source as the initial state of a motion operation.",
        scores: score(8, 7, 10, 7, 8, 9, 8, 9),
        note: "Useful in control systems, but 'initial state' is a derived interpretation of source and the concept introduces rest/velocity semantics absent from the address."
      ),
      candidate(
        id: "source_detachment_complete",
        title: "source detachment completed",
        definition: "A mover's attachment to its source has ended.",
        direction: "Relational separation or release.",
        scores: score(8, 7, 6, 7, 4, 8, 8, 6),
        note: "Often accompanies departure, but attachment can end without displacement and belongs more naturally to Connection or Structure."
      )
    ],
    "spec" => {
      "canonical_title" => "completed source departure",
      "invariant_definition" => "Completion of a mover's displacement away from a specified source position.",
      "semantic_boundaries" => "Owns only the completed phase of source-relative displacement. The source must be specified or recoverable from context.",
      "excluded_meanings" => ["generic relocation", "target arrival", "detachment without displacement", "permission to leave", "movement cause or force", "ontological disappearance"],
      "nearest_neighbors" => ["MOV:101 active source departure", "MOV:102 pending source departure", "MOV:000 origin position", "MOV:001 present position"],
      "cross_family_comparisons" => {
        "MAT" => "MAT supplies the moving body, payload, force, or launch mechanics; MOV:100 supplies only completed displacement from source.",
        "MIN" => "A decision to leave or loss of attention is mental change, not departure.",
        "CON" => "Ending contact or a channel is not departure unless displacement also occurs.",
        "STR" => "Exiting a container requires a boundary compound; removal without motion is structural.",
        "DAT" => "Deleting or sending a record from storage is Data unless positions and displacement are explicitly modeled.",
        "CRE" => "A thing ceasing to be generated is not departure.",
        "ORI" => "Ceasing to exist or leaving an ontological state belongs to Origin."
      },
      "address_explanation" => "First trit 1 selects a process. Second trit 0 anchors the process at its source. Third trit 0 selects completion. 'Completed source departure' is the minimal intersection of those three constraints.",
      "runtime_states" => {
        "0" => "The claimed completed departure is false, invalidated, or unavailable as a fact.",
        "1" => "The source departure is validly complete.",
        "2" => "Whether the source departure completed is unresolved or awaiting confirmation."
      },
      "natural_language_examples" => ["The train has left the station.", "The bird is no longer at the nest; its departure is complete.", "The cursor has left the initialization position."],
      "programming_examples" => ["assert MOV:100[1] with source=MOV:000 and postcondition separation(source,mover)>0", "emit MOV:100[2] when a remote departure completion awaits acknowledgment"],
      "future_compound_examples" => ["exit a building: MOV:100 plus a later structural-boundary relation", "launch cargo: MOV:100 plus material payload and force roles", "return leg completed: MOV:100 relative to the return leg's source"],
      "era_evolution_notes" => "Later eras may lexicalize depart, exit, launch, or withdraw, but their Era Zero decomposition must preserve the source-displacement invariant."
    }
  },
  "MOV:101" => {
    "why_current_was_chosen" => "The active process at a source is most naturally interpreted as leaving. The original label 'self-departure' also tried to use the second trit's self reading while preserving a clear contrast with completed departure and readiness.",
    "candidates" => [
      candidate(
        id: "current_self_departure",
        title: "self-departure",
        definition: "An entity is actively leaving its own source or current position.",
        direction: "Ongoing source-relative displacement.",
        scores: score(9, 9, 10, 9, 9, 9, 10, 8),
        note: "The semantic center is strong, but 'own source or current position' is broader than necessary. A specified source is cleaner than the ambiguous word self.",
        current: true,
        winner: true
      ),
      candidate(
        id: "generic_self_locomotion",
        title: "active self-locomotion",
        definition: "A mover is actively changing its own position.",
        direction: "Generic self-motion.",
        scores: score(7, 7, 10, 4, 8, 10, 10, 10),
        note: "Excellent coverage but destroys the source/target/systemic partition by absorbing nearly all active Motion."
      ),
      candidate(
        id: "active_inward_convergence",
        title: "active inward convergence",
        definition: "A mover is actively moving toward an internal or source center.",
        direction: "Centripetal motion.",
        scores: score(9, 7, 10, 8, 9, 7, 7, 8),
        note: "Motion-specific and atomic, but source-as-goal duplicates target approach and makes the orientation cube less orthogonal."
      ),
      candidate(
        id: "active_motion_initiation",
        title: "active motion initiation",
        definition: "A mover is actively transitioning from rest into motion.",
        direction: "Starting or accelerating into movement.",
        scores: score(7, 7, 8, 7, 6, 8, 8, 9),
        note: "Control-system value is high, but it introduces velocity and force territory and does not cover ordinary departure after onset."
      ),
      candidate(
        id: "active_disengagement",
        title: "active disengagement",
        definition: "A mover is actively breaking its relation to a source.",
        direction: "Withdrawal or disconnection.",
        scores: score(8, 7, 5, 7, 3, 8, 8, 6),
        note: "Relation-breaking is not necessarily motion and collides heavily with Connection and Structure."
      )
    ],
    "spec" => {
      "canonical_title" => "active source departure",
      "invariant_definition" => "Ongoing displacement of a mover away from a specified source position.",
      "semantic_boundaries" => "Owns motion presently increasing separation from a source. It does not specify destination, cause, manner, speed, or social meaning.",
      "excluded_meanings" => ["generic motion without a source relation", "decision or intention to leave", "completed departure", "target approach", "disconnection without displacement", "acceleration as such"],
      "nearest_neighbors" => ["MOV:100 completed source departure", "MOV:102 pending source departure", "MOV:000 origin position", "MOV:001 present position"],
      "cross_family_comparisons" => {
        "MAT" => "Physical propulsion and force are MAT contributions; the displacement relation remains MOV.",
        "MIN" => "Thinking about leaving is not active departure.",
        "CON" => "Withdrawing from a conversation is CON unless the participant also moves.",
        "STR" => "A component can detach structurally without departing spatially.",
        "DAT" => "A read pointer leaving a buffer position uses MOV only if positions are explicitly modeled.",
        "CRE" => "Transformation away from a design state is CRE unless modeled as traversal.",
        "ORI" => "Leaving existence is ontological, not kinematic."
      },
      "address_explanation" => "First trit 1 makes this an event. Second trit 0 makes source separation the defining relation. Third trit 1 requires the event to be under way.",
      "runtime_states" => {
        "0" => "The active departure is not executing or the assertion is false.",
        "1" => "Separation from the source is currently increasing.",
        "2" => "The active departure operation is suspended, blocked, or unresolved; it remains lexically active rather than becoming MOV:102."
      },
      "natural_language_examples" => ["I'm leaving the station now.", "The rover is rolling away from its dock.", "The process is leaving its initialization state along an explicit state path."],
      "programming_examples" => ["run MOV:101[1] while separation(actor,source) is monotonically increasing", "set MOV:101[2] when the departure operation is paused after motion began"],
      "future_compound_examples" => ["withdraw from a group: MOV:101 plus Connection only if literal displacement occurs", "take off: MOV:101 plus later manner/medium semantics", "evacuate a room: MOV:101 plus a structural boundary and collective actor"],
      "era_evolution_notes" => "Later vocabulary may shorten leave, depart, retreat, take off, or pull away, but the atomic root should remain manner-neutral."
    }
  },
  "MOV:102" => {
    "why_current_was_chosen" => "The pending third trit encouraged a pre-departure reading. 'Readiness' was likely chosen because it sounds natural before motion starts and mirrors completed and active departure without requiring a precise scheduling grammar.",
    "candidates" => [
      candidate(
        id: "current_departure_readiness",
        title: "departure readiness",
        definition: "An entity is prepared to leave its source, but outward motion has not yet begun.",
        direction: "Readiness or capability before departure.",
        scores: score(6, 7, 9, 8, 7, 7, 8, 6),
        note: "The definition mixes a process with preparation/capacity. A mover may be ready without any departure operation being specified.",
        current: true
      ),
      candidate(
        id: "queued_source_departure",
        title: "pending source departure",
        definition: "A specified displacement away from a source position that has not yet begun.",
        direction: "A source-departure event in its lexical pre-onset phase.",
        scores: score(9, 10, 10, 9, 9, 9, 9, 10),
        note: "Preserves one process across the triplet and cleanly separates lexical pending phase from readiness, capacity, permission, and runtime suspension.",
        winner: true
      ),
      candidate(
        id: "waiting_at_source",
        title: "waiting at source",
        definition: "A mover remains at its source for an interval.",
        direction: "Non-motion or delay at the source.",
        scores: score(7, 5, 7, 6, 7, 6, 10, 6),
        note: "Everyday useful but waiting does not entail a future departure and is primarily timing/aspect, not a Motion process."
      ),
      candidate(
        id: "latent_self_mobility",
        title: "latent self-mobility",
        definition: "A mover has an unexpressed ability to change its own position.",
        direction: "Dormant motion capacity.",
        scores: score(8, 5, 10, 4, 8, 7, 7, 8),
        note: "Belongs to the 2xx capacity layer; placing it at a 1xx address violates the first trit."
      ),
      candidate(
        id: "intended_retreat",
        title: "intended retreat",
        definition: "A mover intends to increase distance from a source or threat.",
        direction: "Goal/intention to withdraw.",
        scores: score(7, 8, 8, 7, 6, 7, 8, 5),
        note: "Retreat adds threat and intention, colliding with Mind and Warning and narrowing ordinary departure."
      )
    ],
    "spec" => {
      "canonical_title" => "pending source departure",
      "invariant_definition" => "A specified displacement away from a source position that has not yet begun.",
      "semantic_boundaries" => "Owns a source-departure event represented before onset. The event must be specified; readiness, permission, probability, and clock time are independent.",
      "excluded_meanings" => ["mere readiness or capability", "waiting without a departure plan", "permission to leave", "active or completed motion", "dormant route", "suspended active departure"],
      "nearest_neighbors" => ["MOV:100 completed source departure", "MOV:101 active source departure", "MOV:002 retained position", "future MOV 2xx mobility capacity"],
      "cross_family_comparisons" => {
        "MAT" => "Fuel, force, and mechanical readiness are MAT conditions, not the pending event.",
        "MIN" => "Intent or decision may motivate the event but does not constitute it.",
        "CON" => "Clearance or permission is a communicative/logical relation.",
        "STR" => "A closed gate can block the event but is not its meaning.",
        "DAT" => "A scheduler record may represent the event; it is not the event.",
        "CRE" => "A planned transformation belongs to Creation, not source departure.",
        "ORI" => "Future time or possibility status must be supplied separately."
      },
      "address_explanation" => "First trit 1 demands a process, eliminating readiness as a capacity. Second trit 0 fixes source orientation. Third trit 2 fixes a specified but unbegun phase.",
      "runtime_states" => {
        "0" => "The pending departure is canceled, invalid, or unavailable.",
        "1" => "The pending departure is a valid queued operation.",
        "2" => "The pending operation itself is tentative, dormant, or awaiting confirmation."
      },
      "natural_language_examples" => ["The train is set to depart, but it has not moved.", "The drone's departure from the pad is queued.", "The job is scheduled to leave its initial stage."],
      "programming_examples" => ["enqueue MOV:102[1] with source bound and started=false", "use MOV:102[2] for a tentative departure request awaiting authorization"],
      "future_compound_examples" => ["scheduled departure: MOV:102 plus later time/scheduler semantics", "cleared for departure: MOV:102 plus permission", "launch pending: MOV:102 plus material readiness conditions"],
      "era_evolution_notes" => "Later eras may lexicalize ready, scheduled, cleared, or due, but those must not be back-projected into the atomic event."
    }
  },
  "MOV:110" => {
    "why_current_was_chosen" => "A completed target-oriented Motion process almost directly yields arrival. It mirrors source departure and aligns with the canonical destination entity roots MOV:010–012.",
    "candidates" => [
      candidate(
        id: "current_arrival_complete",
        title: "arrival complete",
        definition: "Movement to the selected destination has finished and the mover has entered or reached it.",
        direction: "Target-relative displacement completed.",
        scores: score(9, 10, 10, 9, 9, 10, 10, 10),
        note: "The best fit. The word 'entered' should be removed from the invariant because arrival need not cross a boundary.",
        current: true,
        winner: true
      ),
      candidate(
        id: "target_contact_complete",
        title: "target contact completed",
        definition: "A mover has made physical contact with a target.",
        direction: "Impact, docking, or touch.",
        scores: score(8, 9, 7, 8, 5, 8, 8, 8),
        note: "Motion-related but contact is a material/structural relation and arrival can occur without contact."
      ),
      candidate(
        id: "outward_projection_complete",
        title: "outward projection completed",
        definition: "A mover has completed motion from itself toward an external direction.",
        direction: "Emanation or outward motion from self.",
        scores: score(8, 7, 9, 7, 8, 8, 7, 8),
        note: "Uses outward but weakens the explicit target reading and overlaps source departure."
      ),
      candidate(
        id: "delivery_transfer_complete",
        title: "delivery completed",
        definition: "Something has been transferred successfully to a recipient or target.",
        direction: "Transfer of possession, data, or matter.",
        scores: score(6, 8, 5, 7, 3, 9, 10, 9),
        note: "Very useful English, but transfer success belongs to Matter, Data, or Connection; physical arrival is only one component."
      ),
      candidate(
        id: "boundary_entry_complete",
        title: "entry completed",
        definition: "A mover has crossed fully into a bounded target region.",
        direction: "Boundary crossing into a container.",
        scores: score(9, 9, 8, 8, 6, 8, 9, 8),
        note: "Atomic but too narrow and structurally loaded; arrival at a point does not require containment."
      )
    ],
    "spec" => {
      "canonical_title" => "completed target arrival",
      "invariant_definition" => "Completion of a mover's displacement to a specified target position.",
      "semantic_boundaries" => "Owns only the completed phase of target-relative displacement. Reaching the target is sufficient; entry, contact, delivery, and acceptance are separate.",
      "excluded_meanings" => ["destination entity", "near-target position", "physical impact", "message delivery", "material transfer", "entry into a container", "manifestation"],
      "nearest_neighbors" => ["MOV:111 active target approach", "MOV:112 pending target approach", "MOV:010 defined destination", "MOV:011 active destination"],
      "cross_family_comparisons" => {
        "MAT" => "A payload or impact compounds with arrival; it is not built into arrival.",
        "MIN" => "Achieving a goal mentally is not arrival unless a state-space path is explicit.",
        "CON" => "Receipt or acknowledgment is communication, not motion completion.",
        "STR" => "Entering a container adds a structural boundary relation.",
        "DAT" => "Successful data delivery is DAT/CON even if packet motion is modeled.",
        "CRE" => "Producing a target result is Creation, not arrival.",
        "ORI" => "Becoming actual is manifestation, not target displacement."
      },
      "address_explanation" => "First trit 1 selects the process, second trit 1 selects a target, and third trit 0 selects endpoint completion. Arrival is the exact Motion-specific intersection.",
      "runtime_states" => {
        "0" => "The arrival-completion claim is false or invalid.",
        "1" => "The mover has validly reached the target.",
        "2" => "Whether the mover reached the target awaits confirmation."
      },
      "natural_language_examples" => ["She has arrived at the station.", "The probe reached the dock.", "The cursor reached the final sequence position."],
      "programming_examples" => ["assert MOV:110[1] with postcondition position(actor)=target", "emit MOV:110[2] while target-arrival telemetry is unconfirmed"],
      "future_compound_examples" => ["enter a room: MOV:110 plus structural containment", "deliver cargo: MOV:110 plus material payload and transfer", "return home: MOV:110 with target bound to an earlier MOV:000"],
      "era_evolution_notes" => "Later lexical forms for arrive, reach, enter, dock, land, and deliver should retain their additional boundary, manner, or transfer components."
    }
  },
  "MOV:111" => {
    "why_current_was_chosen" => "An active target-oriented process is naturally approach: the mover is currently progressing toward a selected destination. It provides a clean active counterpart to arrival.",
    "candidates" => [
      candidate(
        id: "current_destination_approach",
        title: "destination approach",
        definition: "An entity is actively moving toward a selected destination.",
        direction: "Ongoing target-relative displacement.",
        scores: score(9, 10, 10, 9, 9, 10, 10, 10),
        note: "The strongest candidate. 'Target' is preferable to 'destination' because approach can be assessed before a final endpoint is accepted.",
        current: true,
        winner: true
      ),
      candidate(
        id: "pursuit",
        title: "active pursuit",
        definition: "A mover is actively following a moving target.",
        direction: "Sustained approach to a changing target.",
        scores: score(8, 9, 9, 6, 7, 8, 9, 7),
        note: "Useful but adds moving-target tracking and a relationship likely reserved for a compound or 2xx root."
      ),
      candidate(
        id: "outward_projection",
        title: "active outward projection",
        definition: "A mover is actively moving outward from itself.",
        direction: "Emanation rather than target approach.",
        scores: score(8, 7, 9, 7, 8, 8, 8, 8),
        note: "Fits outward, but duplicates source departure and does not require a target."
      ),
      candidate(
        id: "target_transfer",
        title: "active transfer to target",
        definition: "A resource, message, or object is actively being transferred to a target.",
        direction: "Delivery process.",
        scores: score(6, 8, 5, 7, 3, 8, 9, 9),
        note: "Bundles motion with possession, information, or communication transfer."
      ),
      candidate(
        id: "steering_guidance",
        title: "active guidance toward target",
        definition: "A mover's direction is actively being controlled toward a target.",
        direction: "Control of trajectory.",
        scores: score(7, 8, 8, 7, 5, 8, 8, 9),
        note: "Guidance can occur without displacement and adds control/agency semantics."
      )
    ],
    "spec" => {
      "canonical_title" => "active target approach",
      "invariant_definition" => "Ongoing displacement of a mover toward a specified target position.",
      "semantic_boundaries" => "Owns targetward displacement in progress. It asserts progress toward a target, not merely orientation, intention, tracking, or target availability.",
      "excluded_meanings" => ["facing a target while stationary", "pursuit relation", "planned future travel", "successful arrival", "message transmission", "goal achievement without a path"],
      "nearest_neighbors" => ["MOV:110 completed target arrival", "MOV:112 pending target approach", "MOV:010 defined destination", "MOV:011 active destination"],
      "cross_family_comparisons" => {
        "MAT" => "Force and vehicle dynamics are material contributors.",
        "MIN" => "Attention toward a subject is not spatial/sequential approach.",
        "CON" => "Contacting or messaging a participant is not approach.",
        "STR" => "Approaching a structure does not imply entry or docking.",
        "DAT" => "Data transfer is not target approach unless a route-position model is explicit.",
        "CRE" => "Progress toward a design result is metaphorical unless modeled as positions.",
        "ORI" => "Approaching actuality is ontological change, not Motion by default."
      },
      "address_explanation" => "Process + target + active yields ongoing displacement whose defining vector is targetward. No extra participant relation or transfer semantics are needed.",
      "runtime_states" => {
        "0" => "The approach is not executing or the assertion is false.",
        "1" => "The mover is currently progressing toward the target.",
        "2" => "The active approach is suspended, blocked, or unresolved after onset."
      },
      "natural_language_examples" => ["The train is approaching the platform.", "I'm heading home.", "The task cursor is progressing toward the final step."],
      "programming_examples" => ["run MOV:111[1] with invariant distance(actor,target) decreases or path-progress increases", "use MOV:111[2] for a targetward operation paused after execution began"],
      "future_compound_examples" => ["pursue a person: MOV:111 plus moving-target relation", "enter a building: MOV:111/110 plus structural boundary", "transport toward a depot: MOV:111 plus material payload roles"],
      "era_evolution_notes" => "Later words for come, approach, advance, pursue, enter, and deliver must preserve whether they add deixis, moving-target tracking, boundary crossing, or transfer."
    }
  },
  "MOV:112" => {
    "why_current_was_chosen" => "The pending third trit suggested an arrival that has not happened yet. The original definition then tried to clarify that targetward movement is intended or queued, but the title remained outcome-framed and phase-ambiguous.",
    "candidates" => [
      candidate(
        id: "current_pending_arrival",
        title: "pending arrival",
        definition: "Movement toward a destination is intended or queued, but arrival is not yet in progress.",
        direction: "An expected arrival outcome.",
        scores: score(6, 8, 10, 7, 8, 7, 8, 7),
        note: "The title can describe both a queued trip and an active trip whose arrival is still pending. It does not cleanly name the lexical pre-onset process.",
        current: true
      ),
      candidate(
        id: "queued_targetward_displacement",
        title: "pending target approach",
        definition: "A specified displacement toward a target position that has not yet begun.",
        direction: "A targetward event in its lexical pre-onset phase.",
        scores: score(9, 10, 10, 9, 9, 9, 9, 10),
        note: "Restores exact triplet parallelism and avoids defining a process through the nonoccurrence of its later result.",
        winner: true
      ),
      candidate(
        id: "unavailable_destination",
        title: "unavailable destination",
        definition: "A target is defined but cannot currently be reached.",
        direction: "Target condition rather than process.",
        scores: score(8, 6, 10, 2, 9, 6, 8, 7),
        note: "Already occupied canonically by MOV:012 and violates the process/entity boundary."
      ),
      candidate(
        id: "target_selection_intent",
        title: "targetward intention",
        definition: "An actor intends to move toward a selected target.",
        direction: "Mental commitment or goal selection.",
        scores: score(6, 7, 7, 6, 5, 8, 9, 7),
        note: "Intention can exist without a specified executable motion and collides with Mind and Logic."
      ),
      candidate(
        id: "waiting_for_entry",
        title: "waiting for entry",
        definition: "A mover remains outside a target while awaiting entry.",
        direction: "Delay at a target boundary.",
        scores: score(7, 6, 7, 7, 6, 6, 9, 6),
        note: "Adds waiting, boundary, and containment; it is not the general pending phase of targetward motion."
      )
    ],
    "spec" => {
      "canonical_title" => "pending target approach",
      "invariant_definition" => "A specified displacement toward a target position that has not yet begun.",
      "semantic_boundaries" => "Owns a targetward Motion event before onset. It requires a specified event and target, but not a schedule, intention, accessible target, or eventual success.",
      "excluded_meanings" => ["pending outcome during active travel", "unavailable destination", "mere intention or desire", "waiting at a boundary", "active approach", "arrival"],
      "nearest_neighbors" => ["MOV:110 completed target arrival", "MOV:111 active target approach", "MOV:012 pending destination", "future Motion relationship roots"],
      "cross_family_comparisons" => {
        "MAT" => "Vehicle/payload readiness is Material.",
        "MIN" => "Desire or intention toward a target is mental.",
        "CON" => "Invitation or permission to approach is communicative.",
        "STR" => "Entry clearance and boundaries are structural/logical additions.",
        "DAT" => "A queue record represents but does not equal the movement operation.",
        "CRE" => "A planned creation toward a target form is Creation.",
        "ORI" => "Future time and possibility are external to the Motion invariant."
      },
      "address_explanation" => "The first trit requires an operation, the second binds its target, and the third makes the operation lexically pre-onset. 'Pending arrival' is rejected because it describes an absent result rather than the operation.",
      "runtime_states" => {
        "0" => "The pending targetward operation is canceled or invalid.",
        "1" => "The targetward operation is validly queued and unbegun.",
        "2" => "The queued operation itself is tentative or awaiting confirmation."
      },
      "natural_language_examples" => ["The rover is queued to move to the marker.", "I'm set to head home, but I haven't started.", "The job is waiting to advance to stage three."],
      "programming_examples" => ["enqueue MOV:112[1] with target bound and started=false", "mark MOV:112[2] when a targetward request exists but is not yet confirmed"],
      "future_compound_examples" => ["scheduled approach: MOV:112 plus later time semantics", "awaiting entry: MOV:112 plus timing and structural boundary", "planned delivery trip: MOV:112 plus payload and transfer roles"],
      "era_evolution_notes" => "Later forms may distinguish due, expected, intended, scheduled, or cleared. None should alter the Era Zero event-phase distinction."
    }
  },
  "MOV:120" => {
    "why_current_was_chosen" => "The systemic second trit invited a route-wide or system-wide reading, and Motion's broad source description included transition and time. The Phase 2 definition therefore bundled transfer, circulation, and temporal transition under a generic completed system transition.",
    "candidates" => [
      candidate(
        id: "current_system_transition_complete",
        title: "system transition complete",
        definition: "A route-wide transfer, circulation step, or temporal transition has reached its defined end state.",
        direction: "Umbrella system-level transition.",
        scores: score(4, 8, 5, 6, 3, 7, 6, 8),
        note: "Not permanently atomic: it explicitly lists unrelated processes and collides with Matter, Data, Structure, Creation, Logic, and Origin.",
        current: true
      ),
      candidate(
        id: "completed_route_traversal",
        title: "completed route traversal",
        definition: "Completion of motion along a shared or system-defined route.",
        direction: "Use of an ordered Motion route as a completed process.",
        scores: score(9, 10, 10, 9, 9, 10, 9, 10),
        note: "The strongest systemic Motion interpretation. It pairs cleanly with canonical route entities without collapsing into their entity meaning.",
        winner: true
      ),
      candidate(
        id: "completed_circulation_cycle",
        title: "circulation cycle completed",
        definition: "A mover has completed one cycle around a recurring route.",
        direction: "Cyclic systemic motion.",
        scores: score(9, 9, 10, 8, 8, 8, 8, 8),
        note: "Atomic and Motion-specific but unnecessarily restricts the systemic triplet to cycles; loop/repetition can be compositional."
      ),
      candidate(
        id: "collective_relocation_complete",
        title: "collective relocation completed",
        definition: "A group of movers has completed relocating as one coordinated set.",
        direction: "Group/collective motion.",
        scores: score(8, 9, 9, 7, 7, 8, 8, 8),
        note: "Fits shared orientation, but actor plurality and coordination are participant properties, not the most general systemic Motion center."
      ),
      candidate(
        id: "network_distribution_complete",
        title: "network distribution completed",
        definition: "Items have completed distribution across a network.",
        direction: "Transport or dissemination through a system.",
        scores: score(6, 9, 6, 7, 3, 9, 8, 9),
        note: "Adds payload transfer and distribution goals, colliding with Matter, Data, and Connection."
      )
    ],
    "spec" => {
      "canonical_title" => "completed route traversal",
      "invariant_definition" => "Completion of motion along a shared or system-defined route.",
      "semantic_boundaries" => "Owns completion of an operation whose identity depends on traversal of an ordered route, not merely reaching a target. A single mover qualifies when the system-defined route is semantically central.",
      "excluded_meanings" => ["route entity", "generic system transition", "material circulation", "data synchronization", "group coordination", "isolated target arrival", "ontological or temporal change without an explicit route"],
      "nearest_neighbors" => ["MOV:121 active route traversal", "MOV:122 pending route traversal", "MOV:020 established route", "MOV:021 active flow network", "MOV:110 completed target arrival"],
      "cross_family_comparisons" => {
        "MAT" => "Material circulation or transport adds a payload/substance graph.",
        "MIN" => "Completing a thought process is Mind unless represented as explicit route positions.",
        "CON" => "Completing broadcast or negotiation is Connection.",
        "STR" => "Completing deployment or reorganization is Structure.",
        "DAT" => "Completing synchronization or replication is Data.",
        "CRE" => "Completing system generation is Creation.",
        "ORI" => "Completing an epochal or ontological transition is Origin."
      },
      "address_explanation" => "Process + systemic/shared + completed should remain Motion-specific. Traversal makes the system-defined route, rather than the target or payload, the defining relation.",
      "runtime_states" => {
        "0" => "The claimed route-traversal completion is false or invalid.",
        "1" => "The route traversal is validly complete.",
        "2" => "Completion of the route traversal awaits confirmation."
      },
      "natural_language_examples" => ["The bus completed its route.", "The robot finished the corridor run.", "The job traversed the full workflow path."],
      "programming_examples" => ["assert MOV:120[1] when all required route positions were visited in order", "use MOV:120[2] when a distributed route run reports completion but final acknowledgment is missing"],
      "future_compound_examples" => ["complete an orbit: MOV:120 plus a cyclic-route relation", "finish transporting cargo: MOV:120 plus payload/carrier roles", "complete a migration: MOV:120 plus a living collective actor"],
      "era_evolution_notes" => "Later eras may lexicalize circuit, orbit, commute, migration, pipeline completion, or tour; route topology and carried domain remain separable."
    }
  },
  "MOV:121" => {
    "why_current_was_chosen" => "Active systemic Motion strongly suggests flow. The Phase 2 definition tried to maximize coverage by allowing entities, signals, and time-indexed states to move through a shared route system.",
    "candidates" => [
      candidate(
        id: "current_system_flow",
        title: "system flow",
        definition: "Entities, signals, or time-indexed states are actively moving through a shared route system.",
        direction: "Generic flow of heterogeneous carriers.",
        scores: score(4, 9, 6, 6, 2, 7, 8, 9),
        note: "The carrier list reveals a non-atomic umbrella. Signals and state transitions belong to other families unless route traversal itself is being asserted.",
        current: true
      ),
      candidate(
        id: "active_route_traversal",
        title: "active route traversal",
        definition: "Ongoing motion along a shared or system-defined route.",
        direction: "Active use of an ordered Motion route.",
        scores: score(9, 10, 10, 9, 9, 10, 10, 10),
        note: "Highly atomic, broadly useful, and technically precise. Route identity supplies systemic orientation without importing payload semantics.",
        winner: true
      ),
      candidate(
        id: "coordinated_collective_motion",
        title: "coordinated collective motion",
        definition: "Multiple movers are actively moving as one coordinated group.",
        direction: "Synchronized group movement.",
        scores: score(8, 9, 9, 7, 6, 8, 9, 8),
        note: "Useful for convoys and flocks but builds participant plurality and coordination into the atom."
      ),
      candidate(
        id: "active_circulation",
        title: "active circulation",
        definition: "A mover or stream is actively repeating motion around a route.",
        direction: "Cyclic flow.",
        scores: score(9, 9, 10, 8, 8, 8, 9, 8),
        note: "Motion-specific and coherent, but repetition and cycle topology should remain compositional so linear routes are not excluded."
      ),
      candidate(
        id: "state_space_transition",
        title: "active state-space transition",
        definition: "A system is actively moving through an ordered sequence of states.",
        direction: "Abstract transition or workflow execution.",
        scores: score(7, 9, 7, 7, 4, 9, 6, 10),
        note: "Technically powerful, but dangerously broad; it becomes Motion only when states are explicitly represented as positions on a route."
      )
    ],
    "spec" => {
      "canonical_title" => "active route traversal",
      "invariant_definition" => "Ongoing motion along a shared or system-defined route.",
      "semantic_boundaries" => "Owns motion currently progressing through an ordered route whose identity is shared, environmental, distributed, or system-defined. It does not type the mover or payload.",
      "excluded_meanings" => ["route network entity", "generic flow of matter or information", "coordination by itself", "cyclic repetition by itself", "target approach with no route salience", "system transformation"],
      "nearest_neighbors" => ["MOV:120 completed route traversal", "MOV:122 pending route traversal", "MOV:020 established route", "MOV:021 active flow network", "MOV:111 active target approach"],
      "cross_family_comparisons" => {
        "MAT" => "Resource or fluid flow belongs to MAT; MOV:121 may add the route-traversal component.",
        "MIN" => "Reasoning through states is MIN unless explicit positions/routes are modeled.",
        "CON" => "Broadcast and participant exchange are CON.",
        "STR" => "Organizational workflow change is STR unless route traversal is separately represented.",
        "DAT" => "Data streaming, replication, and synchronization are DAT.",
        "CRE" => "Generative progression is CRE.",
        "ORI" => "Temporal or ontological unfolding is ORI unless an explicit positional route is part of the graph."
      },
      "address_explanation" => "The systemic second trit is satisfied by the route's shared/system-defined identity. The active third trit makes traversal ongoing. This is more precise than generic flow and more general than circulation.",
      "runtime_states" => {
        "0" => "The route traversal is not executing.",
        "1" => "Motion is actively progressing along the route.",
        "2" => "The active traversal is paused, blocked, or unresolved after onset; this is not MOV:122."
      },
      "natural_language_examples" => ["Traffic is moving along the highway.", "The convoy is traversing the corridor.", "The batch is progressing through the explicit pipeline path."],
      "programming_examples" => ["run MOV:121[1] with route=MOV:020 and invariant ordered_progress", "mark MOV:121[2] when a route traversal has begun but is paused at an intermediate position"],
      "future_compound_examples" => ["circulate: MOV:121 plus a cyclic route and repeated-loop contour", "move together: MOV:121 plus a collective actor and optional coordination relation", "stream data through a topology: MOV:121 plus DAT process only when route positions matter"],
      "era_evolution_notes" => "Later words may compress travel, traverse, commute, circulate, orbit, migrate, process, or stream. The atomic route relation must remain recoverable."
    }
  },
  "MOV:122" => {
    "why_current_was_chosen" => "The pending systemic slot was paired with the broad system-transition interpretation of MOV:120–121. The definition therefore treated any route-wide transfer or temporal transition as staged but unstarted.",
    "candidates" => [
      candidate(
        id: "current_pending_system_transition",
        title: "pending system transition",
        definition: "A route-wide transfer or temporal transition is staged but has not started.",
        direction: "Generic future system change.",
        scores: score(5, 9, 5, 6, 3, 7, 6, 8),
        note: "Still bundles different domains and makes Motion the default family for generic system change.",
        current: true
      ),
      candidate(
        id: "queued_route_traversal",
        title: "pending route traversal",
        definition: "Motion along a shared or system-defined route that is specified but has not yet begun.",
        direction: "A route-traversal event in its lexical pre-onset phase.",
        scores: score(9, 10, 10, 9, 9, 10, 9, 10),
        note: "Completes the route-traversal triplet with exact phase symmetry and keeps scheduling, route availability, and payload external.",
        winner: true
      ),
      candidate(
        id: "dormant_route_system",
        title: "dormant route system",
        definition: "A route system exists but is not currently operating.",
        direction: "Inactive route entity.",
        scores: score(9, 6, 10, 2, 9, 6, 8, 8),
        note: "Already canonically occupied by MOV:022 and violates the 1xx process requirement."
      ),
      candidate(
        id: "scheduled_network_flow",
        title: "scheduled network flow",
        definition: "A system-wide flow is assigned a future execution time.",
        direction: "Scheduled distributed process.",
        scores: score(6, 9, 6, 7, 4, 8, 8, 10),
        note: "Adds scheduler/time semantics and generic flow across other families."
      ),
      candidate(
        id: "suspended_systemic_motion",
        title: "suspended systemic motion",
        definition: "A system-level motion process began and is currently paused.",
        direction: "Paused active route operation.",
        scores: score(8, 6, 9, 7, 8, 8, 8, 9),
        note: "Useful, but suspension after onset is the tailored runtime [2] state of MOV:121, not a lexical pending process."
      )
    ],
    "spec" => {
      "canonical_title" => "pending route traversal",
      "invariant_definition" => "Motion along a shared or system-defined route that is specified but has not yet begun.",
      "semantic_boundaries" => "Owns a route-traversal operation represented before onset. The route may be active or inactive; schedule, authorization, delay, payload, and probability are separate.",
      "excluded_meanings" => ["dormant route entity", "paused traversal after onset", "generic scheduled task", "system transformation", "material or data flow", "timing or delay itself"],
      "nearest_neighbors" => ["MOV:120 completed route traversal", "MOV:121 active route traversal", "MOV:022 dormant route system", "MOV:020 established route", "MOV:112 pending target approach"],
      "cross_family_comparisons" => {
        "MAT" => "Staged transport adds material payload/carrier roles.",
        "MIN" => "Group intention to travel is mental/social context, not the operation.",
        "CON" => "Dispatch or authorization messages do not equal the pending traversal.",
        "STR" => "A staged deployment or reorganization is Structure.",
        "DAT" => "A queued data synchronization is Data.",
        "CRE" => "A staged generation process is Creation.",
        "ORI" => "Future system or epoch transition is Origin unless route motion is explicit."
      },
      "address_explanation" => "The address requires a process, makes an ordered shared route the systemic relation, and fixes the process before onset. Runtime suspension of an already active traversal is excluded.",
      "runtime_states" => {
        "0" => "The pending route traversal is canceled or invalid.",
        "1" => "The route traversal is validly queued and unbegun.",
        "2" => "The queued traversal itself is tentative or awaiting confirmation."
      },
      "natural_language_examples" => ["The convoy is queued to take the northern route.", "The carts are staged for the warehouse loop.", "The batch is queued to enter the pipeline path."],
      "programming_examples" => ["enqueue MOV:122[1] with route=MOV:020 and started=false", "use MOV:122[2] for a tentative route run awaiting dispatch approval"],
      "future_compound_examples" => ["scheduled route run: MOV:122 plus time/scheduler semantics", "pending migration: MOV:122 plus a living collective actor", "planned cargo circuit: MOV:122 plus payload and cyclic-route roles"],
      "era_evolution_notes" => "Later forms may distinguish scheduled, dispatched, staged, tentative, delayed, or awaiting clearance. Those are modifiers of the pending traversal, not replacements for it."
    }
  }
}.freeze

fixed_fields = IDS.to_h do |id|
  atom = atom_by_id.fetch(id)
  [
    id,
    {
      "canonical_id" => id,
      "universal_slot" => atom.fetch("universal_slot"),
      "family_qualified_transliteration" => atom.fetch("canonical_transliteration"),
      "local_compact_root" => atom.fetch("local_compact_root"),
      "formal_carrier" => atom.fetch("formal_carrier"),
      "harmonic_signature_semitones" => atom.fetch("harmonic_signature_semitones"),
      "relative_note_path_semitones" => atom.fetch("note_path_semitones")
    }
  ]
end

ownership_matrix = [
  {
    "root" => "MOV:100",
    "owns" => ["left", "departed", "completed departure from a source"],
    "belongs_elsewhere" => ["origin position → MOV:000", "current position → MOV:001", "detachment without motion → CON/STR"],
    "reserved_for_compounds" => ["exit", "launch cargo", "evacuated"],
    "intentionally_undefined" => ["cause of departure", "speed", "manner"]
  },
  {
    "root" => "MOV:101",
    "owns" => ["leaving", "departing", "moving away from a source"],
    "belongs_elsewhere" => ["decision to leave → MIN", "propulsive force → MAT", "social withdrawal → CON"],
    "reserved_for_compounds" => ["take off", "retreat from danger", "exit a container"],
    "intentionally_undefined" => ["acceleration", "direction after departure", "destination"]
  },
  {
    "root" => "MOV:102",
    "owns" => ["queued departure", "specified unbegun departure"],
    "belongs_elsewhere" => ["readiness/capacity → future capacity review", "permission → LOG/CON", "waiting → timing/aspect"],
    "reserved_for_compounds" => ["scheduled departure", "cleared departure", "delayed departure"],
    "intentionally_undefined" => ["clock time", "probability", "reason for delay"]
  },
  {
    "root" => "MOV:110",
    "owns" => ["arrived", "reached a target", "completed targetward displacement"],
    "belongs_elsewhere" => ["destination → MOV:010", "receipt → CON/DAT", "impact → MAT"],
    "reserved_for_compounds" => ["enter", "dock", "deliver", "return completed"],
    "intentionally_undefined" => ["acceptance", "contact force", "containment"]
  },
  {
    "root" => "MOV:111",
    "owns" => ["approaching", "heading toward", "moving toward a target"],
    "belongs_elsewhere" => ["active destination → MOV:011", "attention toward → MIN", "message transmission → CON/DAT"],
    "reserved_for_compounds" => ["pursue", "follow a moving target", "enter while under way", "transport toward"],
    "intentionally_undefined" => ["guidance controller", "target velocity", "arrival prediction"]
  },
  {
    "root" => "MOV:112",
    "owns" => ["queued targetward trip", "specified unbegun approach"],
    "belongs_elsewhere" => ["unreachable destination → MOV:012", "intention → MIN", "schedule → timing/LOG"],
    "reserved_for_compounds" => ["scheduled approach", "awaiting entry", "planned delivery trip"],
    "intentionally_undefined" => ["estimated arrival time", "permission", "eventual success"]
  },
  {
    "root" => "MOV:120",
    "owns" => ["completed route traversal", "finished route run", "traversed an ordered path"],
    "belongs_elsewhere" => ["route entity → MOV:020", "generic system completion → domain family", "data synchronization → DAT"],
    "reserved_for_compounds" => ["completed orbit", "completed migration", "completed transport circuit"],
    "intentionally_undefined" => ["payload", "loop count", "collective coordination"]
  },
  {
    "root" => "MOV:121",
    "owns" => ["traversing a route", "traveling along a system-defined path", "route progress"],
    "belongs_elsewhere" => ["active route network → MOV:021", "resource flow → MAT", "data stream → DAT", "broadcast → CON"],
    "reserved_for_compounds" => ["circulate", "orbit", "move together", "repeat a route", "migrate"],
    "intentionally_undefined" => ["speed", "cycle geometry", "synchronization"]
  },
  {
    "root" => "MOV:122",
    "owns" => ["queued route traversal", "specified unbegun route run"],
    "belongs_elsewhere" => ["dormant route → MOV:022", "paused active traversal → MOV:121[2]", "scheduled task → LOG/timing"],
    "reserved_for_compounds" => ["scheduled route run", "pending migration", "planned cargo circuit"],
    "intentionally_undefined" => ["dispatch time", "authorization", "delay duration"]
  }
].freeze

stress_tests = [
  ["leave", "MOV:101 while active; MOV:100 when completed", "one root selected by lexical phase", "Direct source departure."],
  ["depart", "MOV:101 / MOV:100", "one root selected by lexical phase", "Same source-relative center as leave."],
  ["go", "MOV:101, MOV:111, or MOV:121 depending source, target, or route salience", "context-selected; not one atom", "English go underspecifies orientation."],
  ["move", "context-selected Motion root or unresolved manner-neutral superordinate", "not forced", "Generic move is broader than any one orientation slot."],
  ["approach", "MOV:111", "one root", "Active target-relative displacement."],
  ["arrive", "MOV:110", "one root", "Completed target-relative displacement."],
  ["reach", "MOV:110", "one root", "Target endpoint reached; contact is not implied."],
  ["travel", "MOV:121 when route is central; MOV:111 when destination is central", "context-selected", "Travel does not always lexicalize route or target."],
  ["follow a route", "MOV:121 + MOV:020", "root plus existing entity", "Traversal process plus established route."],
  ["follow a person", "MOV:111 plus a future moving-target relation", "reserved compound / relationship gap", "Following requires persistent retargeting."],
  ["wait", "timing/aspect; a pending Motion root may coexist", "belongs elsewhere", "Waiting is duration without required displacement."],
  ["pause", "MOV:101[2], MOV:111[2], or MOV:121[2] plus duration", "runtime state plus timing", "Operation began and is suspended; not lexical pending."],
  ["stop", "active Motion root [0] plus cessation/command contour", "runtime/grammar", "Termination modifies an active process."],
  ["continue", "active Motion root [1] plus continuative aspect", "grammar", "Continuation does not change orientation."],
  ["cross", "MOV:121 plus a boundary/path relation", "reserved compound", "Crossing requires a boundary or span."],
  ["return", "MOV:111/MOV:110 with target bound to a prior MOV:000", "reserved compound/graph", "Return is target approach/arrival plus historical identity of the target."],
  ["redirect", "replace target binding, then MOV:112 or MOV:111", "operation sequence / reserved compound", "Redirection relates two motion plans or vectors."],
  ["move together", "collective actor + MOV:121; add coordination only if asserted", "reserved compound", "Togetherness belongs to actor/relationship structure."],
  ["circulate", "MOV:121 + cyclic route + repeated-loop contour", "reserved compound", "Cycle topology and repetition are independent."],
  ["repeat a route", "MOV:121 + MOV:020 + repeated-loop contour", "root plus grammar", "Repetition is not atomic route traversal."],
  ["schedule", "pending root plus later timing/LOG/DAT scheduler semantics", "belongs elsewhere / compound", "Scheduling is not Motion."],
  ["delay", "pending or suspended Motion root plus timing relation", "belongs elsewhere / unresolved timing", "Delay compares expected and actual onset/progress."],
  ["transition", "Motion only with explicit positions/route; otherwise STR, CRE, ORI, MIN, or DAT", "family-selected", "Generic change must not default to Motion."],
  ["transport", "MOV:111 or MOV:121 plus MAT payload/carrier roles", "reserved compound", "Transport combines displacement and participant roles."],
  ["deliver", "MOV:110 plus MAT/DAT/CON transfer and recipient roles", "reserved compound", "Arrival does not imply successful transfer."],
  ["transfer", "domain-specific family; add MOV only for explicit displacement", "belongs elsewhere / compound", "Possession, data, and energy transfer are not synonymous with motion."],
  ["exit", "MOV:101/MOV:100 plus STR boundary/container", "reserved compound", "Departure plus crossing out of a bounded region."],
  ["enter", "MOV:111/MOV:110 plus STR boundary/container", "reserved compound", "Target motion plus crossing into containment."],
  ["launch", "MOV:101/MOV:100 plus MAT force/vehicle roles when relevant", "one root or compound", "The displacement core is departure; mechanics are separate."],
  ["take off", "MOV:101/MOV:100 plus manner/medium", "reserved compound", "Departure survives; flight onset is additional."],
  ["migrate", "LIF collective actor + MOV:121/120 + route", "reserved compound", "Migration includes living participants and often a route."],
  ["orbit", "MOV:121 + cyclic/geometric route + repeated-loop contour", "reserved compound", "Orbital geometry is additional."],
  ["wander", "unresolved", "intentionally undefined", "No stable source, target, or system route is central."],
  ["reverse", "relation between successive motion vectors or target/source rebinding", "intentionally undefined / future compound", "Reversal is second-order over motion operations."],
  ["accelerate", "unresolved Motion/MAT boundary", "intentionally undefined", "Requires rate-of-change semantics not supplied by this block."],
  ["decelerate", "unresolved Motion/MAT boundary", "intentionally undefined", "Same rate-of-change issue as accelerate."],
  ["rotate", "unresolved Motion vocabulary gap", "intentionally undefined", "Rotation is displacement around an axis, not captured by source/target/route phase alone."],
  ["flow", "MOV:121 only when route traversal is asserted; otherwise MAT/DAT/CON", "family-selected", "Carrier-domain meaning controls."],
  ["destination", "MOV:010", "existing Motion entity", "Entity, not process."],
  ["route", "MOV:020", "existing Motion entity", "Entity, not process."],
  ["current position", "MOV:001", "existing Motion entity", "Entity, not process."],
  ["start moving", "MOV:101 at onset plus timing/aspect; not a separate atom here", "root plus grammar", "Starting is phase boundary over active departure."]
].map do |concept, mapping, classification, rationale|
  {
    "english_concept" => concept,
    "mapping" => mapping,
    "classification" => classification,
    "rationale" => rationale
  }
end.freeze

scored_yaml = {
  "metadata" => {
    "title" => "MOV:100–122 adversarial peer review — scored candidates",
    "status" => "recommendations_pending_user_approval_not_canonical",
    "scope" => IDS,
    "score_scale" => "1–10 per category; eight equally weighted categories; totals out of 80",
    "score_categories" => SCORE_CATEGORIES,
    "current_meanings_defended_by_default" => false,
    "canonicalized" => false
  },
  "roots" => IDS.map do |id|
    {
      "canonical_id" => id,
      "fixed_generated_fields" => fixed_fields.fetch(id),
      "why_current_was_probably_chosen" => reviews.fetch(id).fetch("why_current_was_chosen"),
      "candidates" => reviews.fetch(id).fetch("candidates"),
      "recommendation" => {
        "winner_candidate_id" => reviews.fetch(id).fetch("candidates").find { |item| item["recommended_winner"] }.fetch("candidate_id"),
        "canonicalization_status" => "not_canonical_pending_user_decision"
      }
    }
  end
}

recommended_yaml = {
  "metadata" => {
    "title" => "MOV:100–122 recommended permanent semantic specification",
    "status" => "peer_review_recommendation_pending_user_approval",
    "canonicalized" => false,
    "generated_fields_changed" => false,
    "reviewed_roots" => IDS
  },
  "triplet_architecture" => [
    {
      "range" => "MOV:100–102",
      "shared_axis" => "source-relative displacement",
      "phase_contrast" => "completed / ongoing / specified but unbegun"
    },
    {
      "range" => "MOV:110–112",
      "shared_axis" => "target-relative displacement",
      "phase_contrast" => "completed at target / ongoing toward target / specified but unbegun"
    },
    {
      "range" => "MOV:120–122",
      "shared_axis" => "system-route traversal",
      "phase_contrast" => "completed / ongoing / specified but unbegun"
    }
  ],
  "roots" => IDS.map do |id|
    {
      "canonical_id" => id,
      "fixed_generated_fields" => fixed_fields.fetch(id),
      "recommended_permanent_specification" => reviews.fetch(id).fetch("spec")
    }
  end,
  "authority" => {
    "recommended_titles_are_not_yet_canonical" => true,
    "explicit_user_approval_required" => true,
    "next_block_authorized" => false,
    "gate4_authorized" => false
  }
}

stress_yaml = {
  "metadata" => {
    "title" => "MOV:100–122 peer-review ownership matrix and stress tests",
    "status" => "review_evidence_not_canonical",
    "stress_test_count" => stress_tests.length,
    "canonicalized" => false
  },
  "ownership_matrix" => ownership_matrix,
  "english_motion_stress_tests" => stress_tests
}

def write_yaml(path, object)
  File.write(path, object.to_yaml(line_width: -1))
end

write_yaml(File.join(REVIEW_DIR, "MOV_100_122_scored_candidates.yaml"), scored_yaml)
write_yaml(File.join(REVIEW_DIR, "MOV_100_122_recommended_spec.yaml"), recommended_yaml)
write_yaml(File.join(REVIEW_DIR, "MOV_100_122_peer_stress_tests.yaml"), stress_yaml)

md = +"# MOV:100–122 Adversarial Semantic Peer Review\n\n"
md << "Status: **RECOMMENDATION PENDING USER APPROVAL — NOT CANONICAL**\n\n"
md << "This review treats every Phase 2 meaning as replaceable. Scores are comparative peer-review judgments, not mathematical proofs. Each of eight categories is scored 1–10 with equal weight, for a maximum of 80.\n\n"
md << "## Scoring categories\n\n"
md << "- **Atomicity:** one permanent semantic center.\n"
md << "- **Address Fit:** exact fit to process, orientation, and lexical phase.\n"
md << "- **Family Fit:** belongs in Motion more than another family.\n"
md << "- **Neighbor Separation:** remains distinct from adjacent Motion roots.\n"
md << "- **Cross-Family Separation:** avoids Matter, Mind, Connection, Structure, Data, Creation, and Origin collisions.\n"
md << "- **Compound Usefulness:** useful as a later building block.\n"
md << "- **Everyday Language Coverage:** natural ordinary-language value.\n"
md << "- **Technical Coverage:** useful in programs, mathematics, state machines, or formal graphs.\n\n"

md << "## Overall recommendation\n\n"
md << "| Root | Current Phase 2 direction | Recommended permanent title | Decision | Winning score |\n"
md << "|---|---|---|---|---:|\n"
IDS.each do |id|
  root = reviews.fetch(id)
  current = root.fetch("candidates").find { |item| item["is_current_phase2_candidate"] }
  winner = root.fetch("candidates").find { |item| item["recommended_winner"] }
  decision = current["candidate_id"] == winner["candidate_id"] ? "survives with tighter invariant" : "replace current candidate"
  md << "| #{id} | #{current["title"]} | #{root["spec"]["canonical_title"]} | #{decision} | #{winner["total_score"]}/80 |\n"
end
md << "\nThe source/target displacement framework survives. The major changes are:\n\n"
md << "- `MOV:102`: replace **departure readiness** with the event-centered **pending source departure**.\n"
md << "- `MOV:112`: replace outcome-framed **pending arrival** with **pending target approach**.\n"
md << "- `MOV:120–122`: replace generic system transition/flow with the Motion-specific **route traversal** triplet.\n\n"

IDS.each do |id|
  root = reviews.fetch(id)
  fixed = fixed_fields.fetch(id)
  winner = root.fetch("candidates").find { |item| item["recommended_winner"] }
  current = root.fetch("candidates").find { |item| item["is_current_phase2_candidate"] }
  spec = root.fetch("spec")

  md << "## #{id} — peer review\n\n"
  md << "### Fixed generated form\n\n"
  md << "| Field | Value |\n|---|---|\n"
  md << "| Universal slot | #{fixed["universal_slot"]} |\n"
  md << "| Transliteration | `#{fixed["family_qualified_transliteration"]}` |\n"
  md << "| Compact root | `#{fixed["local_compact_root"]}` |\n"
  md << "| Formal carrier | `#{fixed["formal_carrier"]}` |\n"
  md << "| Harmonic signature | `#{fixed["harmonic_signature_semitones"].inspect}` |\n"
  md << "| Relative note path | `#{fixed["relative_note_path_semitones"].inspect}` |\n\n"
  md << "### Why the current meaning was probably chosen\n\n#{root["why_current_was_chosen"]}\n\n"
  md << "### Candidate comparison\n\n"
  md << "| Candidate | Direction | Atom | Addr | Fam | Neigh | Cross | Comp | Daily | Tech | Total | Verdict |\n"
  md << "|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|\n"
  root.fetch("candidates").each do |item|
    s = item.fetch("scores")
    label = item["is_current_phase2_candidate"] ? "#{item["title"]} (current)" : item["title"]
    verdict = item["recommended_winner"] ? "WINNER — #{item["peer_review_note"]}" : item["peer_review_note"]
    md << "| #{label} | #{item["semantic_direction"]} | #{s["atomicity"]} | #{s["address_fit"]} | #{s["family_fit"]} | #{s["neighbor_separation"]} | #{s["cross_family_separation"]} | #{s["compound_usefulness"]} | #{s["everyday_language_coverage"]} | #{s["technical_coverage"]} | #{item["total_score"]}/80 | #{verdict} |\n"
  end
  md << "\n### Recommendation\n\n"
  if current["candidate_id"] == winner["candidate_id"]
    md << "The current semantic direction survives, but only with a tighter permanent specification that removes incidental consequences and ambiguous wording.\n\n"
  else
    md << "Replace the current Phase 2 candidate with **#{spec["canonical_title"]}**. The winner is more atomic and better preserves the address cube.\n\n"
  end
  md << "### Recommended permanent semantic specification\n\n"
  md << "- **Canonical title:** #{spec["canonical_title"]}\n"
  md << "- **Invariant definition:** #{spec["invariant_definition"]}\n"
  md << "- **Semantic boundaries:** #{spec["semantic_boundaries"]}\n"
  md << "- **Excluded meanings:** #{spec["excluded_meanings"].join("; ")}.\n"
  md << "- **Nearest neighboring roots:** #{spec["nearest_neighbors"].join("; ")}.\n"
  md << "- **Why this address is correct:** #{spec["address_explanation"]}\n\n"
  md << "#### Cross-family comparisons\n\n"
  spec["cross_family_comparisons"].each do |family, comparison|
    md << "- **#{family}:** #{comparison}\n"
  end
  md << "\n#### Runtime-state interpretation\n\n"
  spec["runtime_states"].each do |state, interpretation|
    label = state == "2" ? "[2]/num" : "[#{state}]"
    md << "- **#{label}:** #{interpretation}\n"
  end
  md << "\nThe lexical third trit remains part of the root's permanent meaning. Runtime `[2]/num` changes the current assertion or execution status of that already-selected lexical root; it does not change the address into its third-trit-2 sibling.\n\n"
  md << "#### Natural-language examples\n\n"
  spec["natural_language_examples"].each { |example| md << "- #{example}\n" }
  md << "\n#### Programming examples\n\n"
  spec["programming_examples"].each { |example| md << "- `#{example}`\n" }
  md << "\n#### Future compound examples — reservations only\n\n"
  spec["future_compound_examples"].each { |example| md << "- #{example}\n" }
  md << "\nThese are decomposition sketches, not approved compound entries.\n\n"
  md << "#### Notes for later Era evolution\n\n#{spec["era_evolution_notes"]}\n\n"
end

md << "## Block comparison matrix\n\n"
md << "| Root | English concepts owned | Belongs elsewhere | Reserved for compounds | Intentionally undefined |\n"
md << "|---|---|---|---|---|\n"
ownership_matrix.each do |row|
  md << "| #{row["root"]} | #{row["owns"].join("; ")} | #{row["belongs_elsewhere"].join("; ")} | #{row["reserved_for_compounds"].join("; ")} | #{row["intentionally_undefined"].join("; ")} |\n"
end

md << "\n## English Motion stress test\n\n"
md << "| Concept | Mapping | Classification | Rationale |\n"
md << "|---|---|---|---|\n"
stress_tests.each do |test|
  md << "| #{test["english_concept"]} | #{test["mapping"]} | #{test["classification"]} | #{test["rationale"]} |\n"
end

md << "\n## Final peer-review disposition\n\n"
md << "- **Recommended without semantic-direction replacement:** MOV:100, MOV:101, MOV:110, MOV:111. Their invariants and titles are tightened.\n"
md << "- **Recommended replacement of Phase 2 candidate:** MOV:102, MOV:112, MOV:120, MOV:121, MOV:122.\n"
md << "- **Unresolved roots in this block:** none. Each address has a satisfactory winner, but all nine remain provisional until explicit user approval.\n"
md << "- **Other blocks reviewed:** none.\n"
md << "- **Compounds canonized:** none.\n"
md << "- **Gate 4 begun:** no.\n"

File.write(File.join(REVIEW_DIR, "MOV_100_122_peer_review.md"), md)

puts "Built adversarial MOV:100–122 peer review."
puts "Roots: #{IDS.length}"
puts "Candidates: #{IDS.sum { |id| reviews.fetch(id).fetch("candidates").length }}"
puts "Stress tests: #{stress_tests.length}"
