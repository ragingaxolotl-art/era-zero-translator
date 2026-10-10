#!/usr/bin/env ruby

require "yaml"
require "fileutils"
require "date"

ROOT = File.expand_path("..", __dir__)
REVIEW_DIR = File.join(ROOT, "reviews")
FileUtils.mkdir_p(REVIEW_DIR)

WITHDRAWAL = "WITHDRAWN BEFORE DOWNSTREAM IMPLEMENTATION BY USER DIRECTION"
PROVISIONAL = "PROVISIONAL — PENDING DETAILED SEMANTIC REVIEW"
IDS = %w[MOV:100 MOV:101 MOV:102 MOV:110 MOV:111 MOV:112 MOV:120 MOV:121 MOV:122].freeze

atoms = YAML.load_file(File.join(ROOT, "lexicon/atoms.yaml")).fetch("atoms")
structural = atoms.select { |atom| IDS.include?(atom.fetch("canonical_id")) }
                  .to_h { |atom| [atom.fetch("canonical_id"), atom] }

designs = {
  "MOV:100" => {
    "proposed_title" => "source departure completed",
    "invariant_definition" => "Completion of a mover's displacement away from a specified source position.",
    "axis" => "source-relative displacement",
    "phase" => "completed",
    "confidence" => 0.90,
    "candidates" => [
      {
        "title" => "source departure completed",
        "definition" => "Completion of a mover's displacement away from a specified source position.",
        "fit" => "The address is a completed process oriented to a source. A completed source-relative displacement is the direct Motion-family reading.",
        "useful_coverage" => "left, departed, exited a starting point, completed takeoff from an origin",
        "territory_consumed" => "Only the completed phase of motion away from an identified source.",
        "limitations_or_conflicts" => "Requires a source relation; it does not by itself identify the destination, cause, cargo, or manner.",
        "selection" => "selected"
      },
      {
        "title" => "completed release from source",
        "definition" => "Completion of a source's release of a mover.",
        "fit" => "Release also points away from a source and can culminate in separation.",
        "useful_coverage" => "launch, release, discharge, unmoor",
        "territory_consumed" => "Source control, attachment, and permission as well as motion.",
        "limitations_or_conflicts" => "It would collide with CON disengagement, STR detachment, MAT force, and permission grammar; release can occur without displacement.",
        "selection" => "rejected"
      },
      {
        "title" => "completed self-relocation",
        "definition" => "Completion of any relocation by a mover.",
        "fit" => "Relocation is a completed Motion process and may begin from the mover's own position.",
        "useful_coverage" => "move, transfer, change position",
        "territory_consumed" => "Both source departure and target arrival.",
        "limitations_or_conflicts" => "Too broad: it erases the second-trit contrast with MOV:110 and makes the triplets non-compositional.",
        "selection" => "rejected"
      }
    ],
    "includes" => "A completed displacement whose defining relation is that the mover is now away from its specified source.",
    "excludes" => "Mere source identification, intention to leave, motion still under way, destination arrival, release without displacement, or ontological change.",
    "nearest_same_family" => "MOV:101 handles the same source departure while it is under way; MOV:000 is the source-position entity.",
    "cross_domain" => "Use a MAT compound for a material payload, CON for social/channel disengagement, STR for component removal, and ORI for change of existence.",
    "runtime" => {
      "0" => "The asserted completion does not hold, has been invalidated, or is unavailable as a fact.",
      "1" => "The departure completion is a valid current fact: the mover has left the source.",
      "2" => "Whether the departure completed is pending confirmation or intentionally left unresolved."
    },
    "third_vs_runtime" => "Lexical trit 2 is not present here: lexical trit 0 permanently makes this the completed member. MOV:100[2] therefore means a completed-departure proposition whose truth/status is unresolved, not a not-yet-begun departure.",
    "entity_contrast" => "MOV:000 names the origin; MOV:100 asserts that motion away from that origin has completed."
  },
  "MOV:101" => {
    "proposed_title" => "source departure active",
    "invariant_definition" => "Ongoing displacement of a mover away from a specified source position.",
    "axis" => "source-relative displacement",
    "phase" => "active",
    "confidence" => 0.93,
    "candidates" => [
      {
        "title" => "source departure active",
        "definition" => "Ongoing displacement of a mover away from a specified source position.",
        "fit" => "It is an active process whose defining anchor is the source.",
        "useful_coverage" => "leaving, departing, moving away, taking off",
        "territory_consumed" => "Only active source-oriented motion.",
        "limitations_or_conflicts" => "It needs an explicit or recoverable source and does not say where the mover is headed.",
        "selection" => "selected"
      },
      {
        "title" => "generic self-motion",
        "definition" => "A mover is changing its own position.",
        "fit" => "An active inward process can be read as an entity acting on its own position.",
        "useful_coverage" => "go, move, travel",
        "territory_consumed" => "Nearly every active Motion event.",
        "limitations_or_conflicts" => "It would swallow MOV:111 and MOV:121, leaving orientation and systemic triplets without clear work.",
        "selection" => "rejected"
      },
      {
        "title" => "active disengagement",
        "definition" => "A mover is actively breaking a relation to its source.",
        "fit" => "Disengagement often accompanies departure.",
        "useful_coverage" => "detach, disconnect, withdraw",
        "territory_consumed" => "Connection, structure, and social relation as well as motion.",
        "limitations_or_conflicts" => "A relation can end without spatial or sequential displacement; that belongs to CON or STR, possibly compounded with MOV.",
        "selection" => "rejected"
      }
    ],
    "includes" => "Motion presently increasing separation from a specified source, whether physical or along an explicitly modeled sequence.",
    "excludes" => "Generic activity, a decision to leave, completed departure, targetward approach, or social withdrawal without motion.",
    "nearest_same_family" => "MOV:100 handles completed departure; MOV:102 handles the specified but unbegun departure.",
    "cross_domain" => "Compound with MAT for physical cargo/body details, LIF for a living actor, CON for withdrawal from a participant, or STR for a component exiting a structure.",
    "runtime" => {
      "0" => "The active-departure operation is not executing or the assertion is false.",
      "1" => "The mover is currently increasing separation from the source.",
      "2" => "The active-departure operation is suspended, awaiting observation, or otherwise unresolved as an execution state."
    },
    "third_vs_runtime" => "Lexical trit 1 permanently selects the active phase. MOV:101[2] is still the active-departure concept placed in a pending/suspended assertion state; MOV:102 is the distinct lexical concept of a departure specified before it begins.",
    "entity_contrast" => "MOV:001 names the mover's current position; MOV:101 is the act of leaving a source position and may update MOV:001 over time."
  },
  "MOV:102" => {
    "proposed_title" => "source departure pending",
    "invariant_definition" => "A specified displacement away from a source position that has not yet begun.",
    "axis" => "source-relative displacement",
    "phase" => "pending",
    "confidence" => 0.87,
    "candidates" => [
      {
        "title" => "source departure pending",
        "definition" => "A specified displacement away from a source position that has not yet begun.",
        "fit" => "The address is a pending process oriented to a source; the operation exists lexically but has not entered execution.",
        "useful_coverage" => "set to leave, queued departure, prepared launch, upcoming exit",
        "territory_consumed" => "Only an identified source departure before onset.",
        "limitations_or_conflicts" => "Timing, permission, readiness, and probability must be supplied by grammar or compounds.",
        "selection" => "selected"
      },
      {
        "title" => "departure readiness",
        "definition" => "A mover is ready and able to leave.",
        "fit" => "Readiness commonly precedes departure and matches the pending phase.",
        "useful_coverage" => "ready to go, cleared to launch, prepared",
        "territory_consumed" => "Capacity and permission in addition to the pending event.",
        "limitations_or_conflicts" => "A mover can be ready without a departure being specified; capacity belongs in the 2xx layer and permission belongs to later grammar/logic.",
        "selection" => "rejected"
      },
      {
        "title" => "waiting at source",
        "definition" => "A mover remains at a source until departure.",
        "fit" => "Waiting often co-occurs with an unbegun departure.",
        "useful_coverage" => "wait, hold, stand by",
        "territory_consumed" => "Duration and non-motion.",
        "limitations_or_conflicts" => "Waiting is not necessarily motion and can occur without any intended departure; it should be timing/contour or a separate reviewed concept.",
        "selection" => "rejected"
      }
    ],
    "includes" => "A departure event represented as specified or queued while displacement remains unbegun.",
    "excludes" => "Readiness alone, permission, waiting duration, a dormant route, an unreachable destination, or active motion.",
    "nearest_same_family" => "MOV:101 handles execution of the departure; MOV:022 handles a dormant route system rather than a pending operation.",
    "cross_domain" => "Scheduling requires later LOG/DAT/ORI review; a living traveler may be supplied by LIF; material launch conditions require MAT.",
    "runtime" => {
      "0" => "The queued departure is canceled, invalid, or not available.",
      "1" => "A valid departure operation is queued and has not begun.",
      "2" => "The status of the queued departure itself is dormant or unresolved—for example, the plan exists but is not confirmed."
    },
    "third_vs_runtime" => "Lexical trit 2 makes pending departure the root's permanent semantic phase. MOV:102[1] says that pending operation is validly queued; MOV:102[2] says the queue/plan is itself unresolved.",
    "entity_contrast" => "MOV:002 is a retained former/source position; MOV:102 is a future operation relative to a source and does not name a position."
  },
  "MOV:110" => {
    "proposed_title" => "target arrival completed",
    "invariant_definition" => "Completion of a mover's displacement to a specified target position.",
    "axis" => "target-relative displacement",
    "phase" => "completed",
    "confidence" => 0.95,
    "candidates" => [
      {
        "title" => "target arrival completed",
        "definition" => "Completion of a mover's displacement to a specified target position.",
        "fit" => "This is the direct completed, target-oriented Motion process.",
        "useful_coverage" => "arrive, reach, enter the destination, complete delivery travel",
        "territory_consumed" => "Only the completion of targetward displacement.",
        "limitations_or_conflicts" => "It does not imply successful communication, payload transfer, acceptance, or transformation at the target.",
        "selection" => "selected"
      },
      {
        "title" => "target entry completed",
        "definition" => "A mover has crossed into a target region.",
        "fit" => "Entry is a clear completed target-oriented motion.",
        "useful_coverage" => "enter, cross a boundary, dock",
        "territory_consumed" => "Boundary crossing rather than all reaching.",
        "limitations_or_conflicts" => "Too narrow: arrival can occur at a point or endpoint without entering a container; boundary semantics should be compounded.",
        "selection" => "rejected"
      },
      {
        "title" => "outward transfer completed",
        "definition" => "Something has been transferred to a target.",
        "fit" => "Transfer ends at a target and is outward.",
        "useful_coverage" => "deliver, send, hand over",
        "territory_consumed" => "Material, data, and communication transfer.",
        "limitations_or_conflicts" => "It would invade MAT, DAT, and CON. MOV should express only the displacement component.",
        "selection" => "rejected"
      }
    ],
    "includes" => "A target-oriented displacement whose endpoint condition has been met.",
    "excludes" => "Merely naming a destination, being near it, delivery of information, acceptance by a recipient, or creation at the target.",
    "nearest_same_family" => "MOV:111 handles the approach in progress; MOV:010 names the destination entity.",
    "cross_domain" => "Transport/delivery is a compound with MAT or DAT/CON depending on what arrives; entry into a structure adds STR.",
    "runtime" => {
      "0" => "The arrival-completion assertion is false, revoked, or unavailable.",
      "1" => "The mover has validly reached the specified target.",
      "2" => "Whether the target was reached is awaiting confirmation or intentionally unresolved."
    },
    "third_vs_runtime" => "Lexical trit 0 permanently makes this completed targetward displacement. MOV:110[2] is an unresolved claim about completed arrival, not a pending journey.",
    "entity_contrast" => "MOV:010 is a defined destination even with no motion; MOV:110 asserts that the process of reaching it is complete."
  },
  "MOV:111" => {
    "proposed_title" => "target approach active",
    "invariant_definition" => "Ongoing displacement of a mover toward a specified target position.",
    "axis" => "target-relative displacement",
    "phase" => "active",
    "confidence" => 0.95,
    "candidates" => [
      {
        "title" => "target approach active",
        "definition" => "Ongoing displacement of a mover toward a specified target position.",
        "fit" => "It is the exact active, target-oriented Motion reading.",
        "useful_coverage" => "approach, head toward, advance on, travel to",
        "territory_consumed" => "Only motion currently reducing the target-relative path.",
        "limitations_or_conflicts" => "A target must be specified; intention or orientation without displacement is insufficient.",
        "selection" => "selected"
      },
      {
        "title" => "directed motion",
        "definition" => "Motion with any direction.",
        "fit" => "An outward process naturally suggests direction.",
        "useful_coverage" => "go north, move forward, steer",
        "territory_consumed" => "All vector-directed motion, even without a target.",
        "limitations_or_conflicts" => "Too broad and weakens the target axis; direction/vector may require another Motion relation or compound.",
        "selection" => "rejected"
      },
      {
        "title" => "pursuit",
        "definition" => "A mover follows a changing target.",
        "fit" => "Pursuit is active targetward motion.",
        "useful_coverage" => "follow, chase, track",
        "territory_consumed" => "Moving-target relation and continued retargeting.",
        "limitations_or_conflicts" => "Too specific; it would consume likely 2xx relationship territory and require target motion semantics.",
        "selection" => "rejected"
      }
    ],
    "includes" => "Motion presently oriented toward and progressing with respect to a specified target.",
    "excludes" => "Facing a target while stationary, intending to go later, following as a social relation, or merely having a reachable destination.",
    "nearest_same_family" => "MOV:110 handles completed arrival; MOV:112 handles the same targetward displacement before onset; MOV:011 is the active destination entity.",
    "cross_domain" => "Pursuit of a living target compounds with LIF; data transmission with DAT/CON must not collapse into MOV; force-driven travel may add MAT.",
    "runtime" => {
      "0" => "The approach is not executing or the approach assertion is false.",
      "1" => "The mover is currently progressing toward the target.",
      "2" => "The active approach is suspended, awaiting observation, or otherwise unresolved as an executing operation."
    },
    "third_vs_runtime" => "Lexical trit 1 defines the active targetward process. MOV:111[2] is the active-approach concept in a suspended/unresolved runtime state; MOV:112 is lexically pre-onset.",
    "entity_contrast" => "MOV:011 is a destination currently reachable and guiding motion; MOV:111 is the mover's targetward action."
  },
  "MOV:112" => {
    "proposed_title" => "target approach pending",
    "invariant_definition" => "A specified displacement toward a target position that has not yet begun.",
    "axis" => "target-relative displacement",
    "phase" => "pending",
    "confidence" => 0.89,
    "candidates" => [
      {
        "title" => "target approach pending",
        "definition" => "A specified displacement toward a target position that has not yet begun.",
        "fit" => "It supplies the pending phase of the targetward displacement triplet.",
        "useful_coverage" => "set to approach, queued trip to, planned arrival movement",
        "territory_consumed" => "Only a specified targetward motion before onset.",
        "limitations_or_conflicts" => "It does not itself encode schedule time, target accessibility, probability, or permission.",
        "selection" => "selected"
      },
      {
        "title" => "pending arrival",
        "definition" => "Arrival at a target has not yet happened.",
        "fit" => "Every planned targetward trip has a not-yet-completed arrival.",
        "useful_coverage" => "expected arrival, due in, not here yet",
        "territory_consumed" => "Any absence of completed arrival, including active approach and failure.",
        "limitations_or_conflicts" => "Negatively defined and phase-ambiguous: an active MOV:111 would also be a 'pending arrival.'",
        "selection" => "rejected"
      },
      {
        "title" => "unavailable destination",
        "definition" => "A target cannot yet be reached.",
        "fit" => "Unreachability can prevent a targetward process from beginning.",
        "useful_coverage" => "closed destination, blocked endpoint",
        "territory_consumed" => "Destination condition rather than process.",
        "limitations_or_conflicts" => "MOV:012 already canonically names a pending/inaccessible destination entity.",
        "selection" => "rejected"
      }
    ],
    "includes" => "A targetward displacement represented as a valid specified operation before onset.",
    "excludes" => "An inaccessible destination, an active approach, expected time of arrival, waiting duration, or target selection alone.",
    "nearest_same_family" => "MOV:111 handles execution; MOV:012 handles a destination that is defined but not currently reachable.",
    "cross_domain" => "A schedule requires later timing/LOG/DAT semantics; a living target adds LIF; material transport adds MAT.",
    "runtime" => {
      "0" => "The planned targetward motion is canceled, invalid, or unavailable.",
      "1" => "The targetward displacement is validly specified and has not begun.",
      "2" => "The planned operation itself is dormant or unresolved—for example, awaiting confirmation."
    },
    "third_vs_runtime" => "Lexical trit 2 permanently identifies the pre-onset targetward operation. MOV:112[1] validates that pending operation; MOV:112[2] makes the operation's own current status unresolved.",
    "entity_contrast" => "MOV:012 is a pending destination condition; MOV:112 is a pending movement operation toward a destination."
  },
  "MOV:120" => {
    "proposed_title" => "route traversal completed",
    "invariant_definition" => "Completion of motion along a shared or system-defined route.",
    "axis" => "system-route traversal",
    "phase" => "completed",
    "confidence" => 0.83,
    "candidates" => [
      {
        "title" => "route traversal completed",
        "definition" => "Completion of motion along a shared or system-defined route.",
        "fit" => "A completed systemic Motion process should be defined by participation in a shared route system, not by an unrelated change domain.",
        "useful_coverage" => "complete a route, finish a circuit, traverse a workflow, complete a transport run",
        "territory_consumed" => "Only completion of traversal through an ordered shared path.",
        "limitations_or_conflicts" => "The route must be system-defined or shared; isolated point-to-point arrival remains MOV:110.",
        "selection" => "selected"
      },
      {
        "title" => "system transition completed",
        "definition" => "Any system-wide transition has reached its end.",
        "fit" => "The address is a completed systemic process and Motion can metaphorically express transitions.",
        "useful_coverage" => "phase change, deployment, epoch change, workflow completion",
        "territory_consumed" => "Every domain's system-level transformation.",
        "limitations_or_conflicts" => "It invades STR, CRE, LOG, and ORI and lacks a stable Motion-specific center.",
        "selection" => "rejected"
      },
      {
        "title" => "circulation cycle completed",
        "definition" => "A circulating flow has finished one cycle.",
        "fit" => "Circulation is systemic motion and has clear completed cycles.",
        "useful_coverage" => "orbit complete, circuit complete, one loop finished",
        "territory_consumed" => "Only cyclic route motion.",
        "limitations_or_conflicts" => "Too narrow for non-cyclic shared routes; repetition/looping should be supplied by contour or a route compound.",
        "selection" => "rejected"
      }
    ],
    "includes" => "Completion of traversal whose identity depends on an established ordered route shared by a system, group, or workflow.",
    "excludes" => "The route entity itself, isolated arrival without route salience, circulation of material/data as such, or ontological/system reconfiguration.",
    "nearest_same_family" => "MOV:121 handles traversal in progress; MOV:020 names the established route; MOV:021 names a network currently carrying flow.",
    "cross_domain" => "Compound with MAT for transported resources, DAT for data moving through the route, LIF for a group, STR for infrastructure, or ORI only when an ontological event is independently asserted.",
    "runtime" => {
      "0" => "The route-traversal completion is not a valid current fact or has been invalidated.",
      "1" => "The defined route traversal has completed.",
      "2" => "Completion of the route traversal is awaiting confirmation or unresolved."
    },
    "third_vs_runtime" => "Lexical trit 0 makes route-traversal completion the permanent concept. MOV:120[2] is uncertainty about that completion; MOV:122 is a route traversal lexically specified before onset.",
    "entity_contrast" => "MOV:020 is an established route whether or not used; MOV:120 is the completed use/traversal of such a route."
  },
  "MOV:121" => {
    "proposed_title" => "route traversal active",
    "invariant_definition" => "Ongoing motion along a shared or system-defined route.",
    "axis" => "system-route traversal",
    "phase" => "active",
    "confidence" => 0.87,
    "candidates" => [
      {
        "title" => "route traversal active",
        "definition" => "Ongoing motion along a shared or system-defined route.",
        "fit" => "It is an active systemic Motion process with route membership as its organizing relation.",
        "useful_coverage" => "travel through a route, traffic in a corridor, progress through a workflow, circulate with loop contour",
        "territory_consumed" => "Only active traversal of an ordered shared path.",
        "limitations_or_conflicts" => "It does not identify what is carried, whether participants are synchronized, or whether the route is cyclic.",
        "selection" => "selected"
      },
      {
        "title" => "system flow",
        "definition" => "Entities, signals, or states move through a system.",
        "fit" => "Flow is active systemic motion.",
        "useful_coverage" => "traffic, data flow, resource circulation, process flow",
        "territory_consumed" => "Motion plus DAT, MAT, CON, and temporal state change.",
        "limitations_or_conflicts" => "The carrier/domain list is not atomic and would absorb other families' core processes.",
        "selection" => "rejected"
      },
      {
        "title" => "coordinated movement",
        "definition" => "Multiple movers move together.",
        "fit" => "Shared orientation can express collective coordination.",
        "useful_coverage" => "convoy, flocking, synchronization, march",
        "territory_consumed" => "Participant coordination and relationships.",
        "limitations_or_conflicts" => "Too narrow and likely belongs partly to MOV 2xx or CON; one mover can still traverse a system route.",
        "selection" => "rejected"
      }
    ],
    "includes" => "Motion currently progressing through an ordered path whose identity is systemic, shared, or workflow-defined.",
    "excludes" => "The active route network entity, data transfer itself, resource exchange itself, group synchronization, or generic target approach.",
    "nearest_same_family" => "MOV:120 handles completed traversal; MOV:122 handles specified unbegun traversal; MOV:021 is the active flow-network entity.",
    "cross_domain" => "Use compounds to type movers or payloads: LIF for living participants, MAT for material transport, DAT/CON for information or communication, STR for infrastructure.",
    "runtime" => {
      "0" => "The route traversal is not executing or the assertion is false.",
      "1" => "Motion is currently progressing along the shared/system route.",
      "2" => "The active traversal is suspended, blocked, or unresolved as an executing operation."
    },
    "third_vs_runtime" => "Lexical trit 1 selects active route traversal. MOV:121[2] is that active operation in a suspended/unresolved runtime condition, whereas MOV:122 is lexically a not-yet-begun traversal.",
    "entity_contrast" => "MOV:021 names a route network currently carrying flow; MOV:121 predicates traversal by a mover or cohort through a route."
  },
  "MOV:122" => {
    "proposed_title" => "route traversal pending",
    "invariant_definition" => "Motion along a shared or system-defined route that is specified but has not yet begun.",
    "axis" => "system-route traversal",
    "phase" => "pending",
    "confidence" => 0.83,
    "candidates" => [
      {
        "title" => "route traversal pending",
        "definition" => "Motion along a shared or system-defined route that is specified but has not yet begun.",
        "fit" => "It completes the systemic traversal triplet with a clear pre-onset process.",
        "useful_coverage" => "queued route run, planned circuit, staged workflow traversal, convoy awaiting start",
        "territory_consumed" => "Only a specified system-route traversal before onset.",
        "limitations_or_conflicts" => "Schedule time, delay cause, route availability, and payload type are external.",
        "selection" => "selected"
      },
      {
        "title" => "scheduled system transition",
        "definition" => "A system change is scheduled.",
        "fit" => "Scheduling and pending systemic action commonly coincide.",
        "useful_coverage" => "cron job, timetable, planned rollout, future phase",
        "territory_consumed" => "Time, logic, and all transformation domains.",
        "limitations_or_conflicts" => "Scheduling is not Motion-specific and cannot be settled before LOG/DAT/ORI and timing grammar review.",
        "selection" => "rejected"
      },
      {
        "title" => "dormant route",
        "definition" => "A route exists but is inactive.",
        "fit" => "An inactive system route is associated with pending traversal.",
        "useful_coverage" => "closed line, unused corridor, suspended service",
        "territory_consumed" => "Route entity condition.",
        "limitations_or_conflicts" => "MOV:022 already canonically names a dormant route system; the 1xx address must remain a process.",
        "selection" => "rejected"
      }
    ],
    "includes" => "A route-specific traversal operation represented as validly specified before its motion begins.",
    "excludes" => "A dormant route, a timetable itself, delay duration/cause, active traffic, or a generic system transformation.",
    "nearest_same_family" => "MOV:121 handles execution; MOV:022 handles the dormant route entity.",
    "cross_domain" => "A scheduled transport combines this root with timing/LOG and MAT payload semantics after those are reviewed; a living cohort adds LIF.",
    "runtime" => {
      "0" => "The planned route traversal is canceled, invalid, or unavailable.",
      "1" => "A valid route traversal is queued and has not begun.",
      "2" => "The queued traversal itself is dormant or unresolved, such as a tentative run awaiting authorization."
    },
    "third_vs_runtime" => "Lexical trit 2 permanently selects a not-yet-begun route traversal. MOV:122[1] validates the queue; MOV:122[2] makes the queued operation's current status unresolved.",
    "entity_contrast" => "MOV:022 is a dormant route system regardless of any operation; MOV:122 is a pending act of traversing a route that may itself be active or inactive."
  }
}.freeze

example_specs = {
  "MOV:100" => [
    ["conversation", "(traveler:x) -actor→ (e:MOV:100[1]) -source→ (home:MOV:000[1])", "traveler; source-departure-completed; home-origin", "The traveler has left home.", "[1] completion valid", "falling declaration", "low=traveler; middle=MOV:100; high=completed separation; sustained=home/source"],
    ["physical_spatial", "(drone:x) -actor→ (e:MOV:100[1]) -source→ (pad:MOV:000[1])", "drone; completed displacement away; launch pad", "The drone is clear of the launch pad.", "[1] completion valid", "falling declaration", "low=drone; middle=departure; high=clear-of-source result; sustained=pad"],
    ["temporal_sequential", "(cursor:x) -actor→ (e:MOV:100[1]) -source→ (step0:MOV:000[1])", "cursor; completed departure; initial sequence position", "The workflow has left its initialization step.", "[1] completed phase asserted", "rise-return definition", "low=cursor; middle=departure; high=post-initial result; sustained=sequence"],
    ["cross_family_compound", "(self:LIF:001[1]) -actor→ (e:MOV:100[1]) -source→ (camp:MOV:000[1])", "conscious self + completed source departure + camp origin", "I have left the camp.", "[1] on LIF actor and MOV process", "falling declaration", "low=LIF:001 actor; middle=MOV:100; high=departure result; sustained=MOV:000"],
    ["executable_programming", "assert(e:MOV:100[1]); source(e)=MOV:000; postcondition=away_from(actor(e),source(e))", "assert completed source departure with separation postcondition", "Assert that the departure operation completed.", "[1] makes the postcondition valid", "sharply falling command", "low=actor binding; middle=operation; high=postcondition; sustained=source binding"],
    ["counterexample", "(mind:x) -recalls→ (home:MIN:*[1]); MOV:100 absent", "mental recall of home; no displacement", "They remembered home; they did not leave it.", "[1] belongs on the mental predicate", "falling declaration", "low=experiencer; middle=MIN predicate; high=memory target; no MOV register"]
  ],
  "MOV:101" => [
    ["conversation", "(self:LIF:001[1]) -actor→ (e:MOV:101[1]) -source→ (here:MOV:001[1])", "conscious self; active source departure; current place", "I'm leaving now.", "[1] departure executing", "falling declaration", "low=LIF:001; middle=MOV:101; high=increasing separation; sustained=source"],
    ["physical_spatial", "(cart:x) -actor→ (e:MOV:101[1]) -source→ (dock:MOV:000[1])", "cart; moving away; dock", "The cart is rolling off the dock.", "[1] active motion", "falling declaration", "low=cart; middle=departure; high=away vector; sustained=dock"],
    ["temporal_sequential", "(token:x) -actor→ (e:MOV:101[1]) -source→ (init:MOV:000[1])", "token; active departure; initial sequence position", "The control token is leaving initialization.", "[1] sequential displacement executing", "falling declaration", "low=token; middle=MOV:101; high=next-position direction; sustained=workflow"],
    ["cross_family_compound", "(other:LIF:011[1]) -actor→ (e:MOV:101[1]) -source→ (room:MOV:000[1])", "conscious other + active departure + room source", "She is leaving the room.", "[1] actor responsive and motion active", "falling declaration", "low=LIF:011; middle=MOV:101; high=departure direction; sustained=room"],
    ["executable_programming", "run(e:MOV:101[1]); while executing: separation(actor(e),source(e)) increases", "execute active departure; separation monotonically increases", "Run the leave-source operation.", "[1] operation executing", "sharply falling command", "low=actor; middle=operation; high=invariant; sustained=source"],
    ["counterexample", "(self:LIF:001[1]) -decides→ (plan:MOV:102[1]); MOV:101[0]", "decision and queued departure; no active displacement", "I decided to leave, but I am still standing here.", "MOV:102[1], MOV:101[0]", "falling declaration", "low=decider; middle=plan; high=future departure; no active-motion register"]
  ],
  "MOV:102" => [
    ["conversation", "(bus:x) -actor→ (e:MOV:102[1]) -source→ (station:MOV:000[1])", "bus; pending source departure; station", "The bus is set to leave the station.", "[1] queued departure valid", "falling declaration", "low=bus; middle=MOV:102; high=queued onset; sustained=station"],
    ["physical_spatial", "(arm:x) -actor→ (e:MOV:102[1]) -source→ (rest:MOV:000[1])", "robot arm; specified unbegun departure; rest position", "The arm is staged to move off its rest point.", "[1] staged operation", "fall-rise possibility", "low=arm; middle=pending departure; high=future separation; sustained=rest point"],
    ["temporal_sequential", "(job:x) -actor→ (e:MOV:102[1]) -source→ (queue_head:MOV:000[1])", "job; pending departure; queue origin", "The job is queued to leave the first stage.", "[1] pre-onset operation valid", "falling declaration", "low=job; middle=MOV:102; high=next-stage onset; sustained=queue"],
    ["cross_family_compound", "(other:LIF:011[1]) -actor→ (e:MOV:102[1]) -source→ (camp:MOV:000[1])", "conscious other + pending departure + camp source", "She is scheduled to depart the camp.", "[1] validates the motion plan; schedule time remains external", "falling declaration", "low=LIF:011; middle=MOV:102; high=future onset; sustained=camp"],
    ["executable_programming", "enqueue(e:MOV:102[1]); precondition=at(actor(e),source(e)); started(e)=false", "enqueue source-departure operation; actor still at source; not started", "Queue a departure from the source.", "[1] pending operation accepted", "sharply falling command", "low=actor; middle=queue operation; high=precondition; sustained=source"],
    ["counterexample", "(traveler:x) -waits_at→ (station:MOV:001[1]); departure unspecified", "traveler remains at station; no departure event specified", "The traveler is waiting, but no trip has been planned.", "[1] on waiting predicate; MOV:102 absent", "falling declaration", "low=traveler; middle=timing/wait predicate; high=duration; sustained=station"]
  ],
  "MOV:110" => [
    ["conversation", "(other:LIF:011[1]) -actor→ (e:MOV:110[1]) -target→ (here:MOV:010[1])", "conscious other; target-arrival-completed; here as destination", "She has arrived.", "[1] arrival completion valid", "falling declaration", "low=LIF:011; middle=MOV:110; high=target reached; sustained=none"],
    ["physical_spatial", "(parcel:x) -actor→ (e:MOV:110[1]) -target→ (bay:MOV:010[1])", "parcel; completed targetward displacement; loading bay", "The parcel reached the loading bay.", "[1] endpoint condition met", "falling declaration", "low=parcel; middle=arrival; high=bay target; sustained=route"],
    ["temporal_sequential", "(cursor:x) -actor→ (e:MOV:110[1]) -target→ (final:MOV:010[1])", "cursor; arrival completed; final sequence position", "The cursor reached the final step.", "[1] sequential endpoint reached", "falling declaration", "low=cursor; middle=MOV:110; high=final step; sustained=sequence"],
    ["cross_family_compound", "(self:LIF:001[1]) -actor→ (e:MOV:110[1]) -target→ (meeting:MOV:010[1])", "conscious self + completed target arrival + meeting location", "I arrived at the meeting place.", "[1] actor and arrival valid", "falling declaration", "low=LIF:001; middle=MOV:110; high=MOV:010; sustained=context"],
    ["executable_programming", "assert(e:MOV:110[1]); target(e)=MOV:010; postcondition=at(actor(e),target(e))", "assert completed targetward motion with at-target postcondition", "Assert that the mover reached the target.", "[1] postcondition valid", "sharply falling command", "low=actor; middle=operation; high=target/postcondition; sustained=route"],
    ["counterexample", "(destination:MOV:010[1]); no motion event", "defined destination only", "The address is our destination, but nobody has arrived.", "MOV:010[1]; MOV:110[0]", "falling declaration", "high=destination entity; no low actor or middle arrival process"]
  ],
  "MOV:111" => [
    ["conversation", "(self:LIF:001[1]) -actor→ (e:MOV:111[1]) -target→ (home:MOV:011[1])", "conscious self; active target approach; reachable home", "I'm heading home.", "[1] approach executing", "falling declaration", "low=LIF:001; middle=MOV:111; high=home target; sustained=route"],
    ["physical_spatial", "(probe:x) -actor→ (e:MOV:111[1]) -target→ (dock:MOV:011[1])", "probe; ongoing targetward displacement; active dock", "The probe is approaching the dock.", "[1] distance/path-to-target decreasing", "falling declaration", "low=probe; middle=approach; high=dock; sustained=space"],
    ["temporal_sequential", "(task:x) -actor→ (e:MOV:111[1]) -target→ (deadline:MOV:011[1])", "task; active approach; target sequence point", "The task is moving toward its completion step.", "[1] sequential targetward progress", "falling declaration", "low=task; middle=MOV:111; high=completion step; sustained=timeline"],
    ["cross_family_compound", "(other:LIF:011[1]) -actor→ (e:MOV:111[1]) -target→ (self:LIF:001[1])", "conscious other + active target approach + conscious self target", "She is coming toward me.", "[1] both life nodes responsive; motion active", "falling declaration", "low=LIF:011 actor; middle=MOV:111; high=LIF:001 target; sustained=space"],
    ["executable_programming", "run(e:MOV:111[1]); target(e)=MOV:011; invariant=progress_toward(actor(e),target(e))", "execute target-approach operation under progress invariant", "Move the actor toward the target.", "[1] operation executing", "sharply falling command", "low=actor; middle=operation; high=target; sustained=path"],
    ["counterexample", "(actor:x) -faces→ (target:MOV:011[1]); position unchanged", "orientation toward target; no displacement", "The rover faces the dock but is not approaching it.", "[1] on orientation predicate; MOV:111[0]", "falling declaration", "low=rover; high=target; no middle motion process"]
  ],
  "MOV:112" => [
    ["conversation", "(self:LIF:001[1]) -actor→ (e:MOV:112[1]) -target→ (home:MOV:010[1])", "conscious self; pending target approach; home destination", "I'm set to head home.", "[1] targetward operation valid but unbegun", "fall-rise possibility", "low=LIF:001; middle=MOV:112; high=home; sustained=timing context"],
    ["physical_spatial", "(rover:x) -actor→ (e:MOV:112[1]) -target→ (marker:MOV:010[1])", "rover; specified unbegun targetward displacement; marker", "The rover is queued to move to the marker.", "[1] queue valid", "falling declaration", "low=rover; middle=pending approach; high=marker; sustained=terrain"],
    ["temporal_sequential", "(job:x) -actor→ (e:MOV:112[1]) -target→ (stage3:MOV:010[1])", "job; pending targetward movement; third sequence position", "The job is queued to advance to stage three.", "[1] sequential operation pending", "falling declaration", "low=job; middle=MOV:112; high=stage3; sustained=workflow"],
    ["cross_family_compound", "(other:LIF:011[1]) -actor→ (e:MOV:112[1]) -target→ (self:LIF:001[1])", "conscious other + pending approach + conscious target", "She plans to come to me.", "[1] motion plan valid; mental intention is separate", "falling declaration", "low=LIF:011; middle=MOV:112; high=LIF:001; sustained=context"],
    ["executable_programming", "enqueue(e:MOV:112[1]); target(e)=MOV:010; started(e)=false", "enqueue targetward displacement; target bound; execution false", "Queue movement to the target.", "[1] pending operation accepted", "sharply falling command", "low=actor binding; middle=queue; high=target binding; sustained=scheduler"],
    ["counterexample", "(target:MOV:012[1]); no movement operation", "destination defined but inaccessible; no queued approach", "The destination is closed; no trip has been scheduled.", "MOV:012[1]; MOV:112 absent", "falling declaration", "high=pending destination entity; no middle process"]
  ],
  "MOV:120" => [
    ["conversation", "(bus:x) -actor→ (e:MOV:120[1]) -route→ (line:MOV:020[1])", "bus; completed system-route traversal; established line", "The bus finished its route.", "[1] traversal completion valid", "falling declaration", "low=bus; middle=MOV:120; high=route completion; sustained=MOV:020"],
    ["physical_spatial", "(robot:x) -actor→ (e:MOV:120[1]) -route→ (corridor:MOV:020[1])", "robot; completed route traversal; corridor", "The robot completed the corridor run.", "[1] route endpoint/cycle met", "falling declaration", "low=robot; middle=traversal; high=completed run; sustained=corridor"],
    ["temporal_sequential", "(job:x) -actor→ (e:MOV:120[1]) -route→ (workflow:MOV:020[1])", "job; completed traversal; ordered workflow", "The job traversed the whole workflow.", "[1] sequence traversal complete", "falling declaration", "low=job; middle=MOV:120; high=workflow completion; sustained=workflow"],
    ["cross_family_compound", "(community:LIF:021[1]) -actor→ (e:MOV:120[1]) -route→ (evacuation:MOV:020[1])", "living community + completed shared-route traversal + evacuation route", "The community completed the evacuation route.", "[1] community active; traversal complete", "falling declaration", "low=LIF:021; middle=MOV:120; high=route completion; sustained=MOV:020"],
    ["executable_programming", "assert(e:MOV:120[1]); route(e)=MOV:020; visited_required_positions(e)=true", "assert route traversal completed and required ordered positions visited", "Assert that the route run completed.", "[1] route-completion postcondition valid", "sharply falling command", "low=mover; middle=operation; high=completion result; sustained=route"],
    ["counterexample", "(route:MOV:020[1]); traversals=0", "established route exists; no completed traversal", "The route exists, but nobody has completed it.", "MOV:020[1]; MOV:120[0]", "falling declaration", "sustained=route entity; no actor/process/result registers"]
  ],
  "MOV:121" => [
    ["conversation", "(traffic:x) -actor→ (e:MOV:121[1]) -route→ (line:MOV:021[1])", "traffic; active route traversal; live route network", "Traffic is moving along the line.", "[1] traversal active", "falling declaration", "low=traffic; middle=MOV:121; high=forward route progress; sustained=MOV:021"],
    ["physical_spatial", "(convoy:x) -actor→ (e:MOV:121[1]) -route→ (corridor:MOV:020[1])", "convoy; ongoing traversal; shared corridor", "The convoy is moving through the corridor.", "[1] route progress executing", "falling declaration", "low=convoy; middle=traversal; high=next route position; sustained=corridor"],
    ["temporal_sequential", "(batch:x) -actor→ (e:MOV:121[1]) -route→ (pipeline:MOV:020[1])", "batch; active traversal; ordered pipeline", "The batch is progressing through the pipeline.", "[1] sequence traversal active", "falling declaration", "low=batch; middle=MOV:121; high=next stage; sustained=pipeline"],
    ["cross_family_compound", "(community:LIF:021[1]) -actor→ (e:MOV:121[1]) -route→ (trail:MOV:020[1])", "living community + active shared-route traversal + established trail", "The group is moving together along the trail.", "[1] community and traversal active; togetherness comes from collective actor", "repeated-loop contour only if cyclic", "low=LIF:021; middle=MOV:121; high=route progress; sustained=MOV:020"],
    ["executable_programming", "run(e:MOV:121[1]); route(e)=MOV:020; invariant=ordered_progress(e)", "execute traversal along bound route under ordered-progress invariant", "Run the route traversal.", "[1] system-route operation executing", "sharply falling command", "low=mover set; middle=operation; high=next position; sustained=route"],
    ["counterexample", "(records:DAT:*[1]) -replicate_across→ (network:DAT:*[1]); spatial_route_unspecified", "data replication; no Motion route asserted", "The database is replicating records; that is not automatically route traversal.", "[1] on DAT process; MOV:121 absent unless a route model is added", "falling declaration", "low=data source; middle=DAT process; high=replica target; no MOV route register"]
  ],
  "MOV:122" => [
    ["conversation", "(convoy:x) -actor→ (e:MOV:122[1]) -route→ (road:MOV:020[1])", "convoy; pending route traversal; established road", "The convoy is queued to take the road.", "[1] route run valid but unbegun", "falling declaration", "low=convoy; middle=MOV:122; high=future route run; sustained=road"],
    ["physical_spatial", "(carts:x) -actor→ (e:MOV:122[1]) -route→ (loop:MOV:020[1])", "carts; pending traversal; warehouse loop", "The carts are staged for the warehouse loop.", "[1] staged route operation", "fall-rise possibility", "low=carts; middle=pending traversal; high=run onset; sustained=loop"],
    ["temporal_sequential", "(batch:x) -actor→ (e:MOV:122[1]) -route→ (pipeline:MOV:020[1])", "batch; specified unbegun traversal; ordered pipeline", "The batch is queued to enter the pipeline.", "[1] workflow traversal pending", "falling declaration", "low=batch; middle=MOV:122; high=future first stage; sustained=pipeline"],
    ["cross_family_compound", "(community:LIF:021[1]) -actor→ (e:MOV:122[1]) -route→ (migration:MOV:020[1])", "living community + pending route traversal + migration route", "The community is prepared to begin the migration route.", "[1] collective actor active; route operation pending", "fall-rise possibility", "low=LIF:021; middle=MOV:122; high=planned run; sustained=MOV:020"],
    ["executable_programming", "enqueue(e:MOV:122[1]); route(e)=MOV:020; started(e)=false", "enqueue system-route traversal; bind route; execution not started", "Queue the route run.", "[1] pending traversal accepted", "sharply falling command", "low=mover set; middle=queue; high=route binding; sustained=scheduler"],
    ["counterexample", "(route:MOV:022[1]); operation unspecified", "dormant route system; no pending traversal event", "The rail line is inactive, but no run is queued.", "MOV:022[1]; MOV:122 absent", "falling declaration", "sustained=dormant route entity; no actor/process/result registers"]
  ]
}.freeze

coverage = [
  ["leave", "one root in this block", "MOV:101 while under way; MOV:100 once completed", "English tense/aspect selects the phase; the atomic center is source-relative displacement."],
  ["depart", "one root in this block", "MOV:101 or MOV:100", "Same source-oriented triplet as leave."],
  ["go", "compound or context-selected root", "MOV:101 away from a source, MOV:111 toward a target, or MOV:121 along a system route", "English go underspecifies orientation and must not be forced into one atom."],
  ["approach", "one root in this block", "MOV:111", "Active target-relative displacement."],
  ["arrive", "one root in this block", "MOV:110", "Completed target-relative displacement."],
  ["follow", "compound or unresolved vocabulary gap", "MOV:111 toward a moving target plus a future Motion relationship/constraint", "Following includes sustained target relation and retargeting; active approach alone is not always enough."],
  ["wait", "contour/timing grammar or unresolved vocabulary gap", "A pending root may be present, but waiting itself is not MOV:102/112/122", "Waiting is duration without required displacement."],
  ["pause", "runtime state plus timing grammar", "MOV:101[2], MOV:111[2], or MOV:121[2] when an active operation is suspended", "Runtime [2] suspends/defers the active operation; lexical third-trit 2 would instead name a pre-onset process."],
  ["stop", "runtime state plus contour", "Active Motion root [0], often with sharply falling command contour", "Stopping terminates a currently active operation; exact cessation semantics may need later grammar."],
  ["continue", "runtime state plus contour/timing grammar", "Active root [1] with continuation or repeated-loop contour where appropriate", "Continuation is aspect over an active process, not a new atomic direction."],
  ["cross", "compound", "MOV:121 + MOV:020 with a boundary/route relation", "Crossing requires a boundary/path model; the route traversal supplies the Motion process."],
  ["return", "compound", "MOV:111/MOV:110 with target=MOV:000; departure history may also be referenced", "Return is targetward movement whose target is a prior origin."],
  ["redirect", "compound or operation sequence", "Bind a new MOV:010 target, then use MOV:112 or MOV:111; cancel/replace the earlier targetward operation", "Redirection changes a target relation rather than introducing a new displacement phase."],
  ["move together", "compound", "LIF:021 collective actor + MOV:121, with coordination added later if needed", "Collective actor supplies togetherness; MOV:121 supplies shared-route traversal."],
  ["circulate", "compound plus contour", "MOV:121 + MOV:020/MOV:021 + repeated-loop contour", "Looping/cycle structure is not baked into the atomic definition."],
  ["repeat a route", "compound plus contour", "MOV:121 + MOV:020 + repeated-loop contour", "Repetition modifies route traversal."],
  ["schedule", "different family or later grammar", "MOV:102/112/122 can be the scheduled operation, but scheduling belongs to future timing/LOG/DAT review", "The Motion root must not absorb calendar or scheduler semantics."],
  ["delay", "contour/timing grammar or unresolved vocabulary gap", "Pending/suspended Motion root plus duration/cause", "Delay is a relation between expected and actual onset/progress."],
  ["transition", "context-selected family", "MOV only when positions or ordered route states are explicitly modeled; STR/ORI/CRE for their own domains", "Generic change is not automatically Motion."],
  ["transport", "compound", "MOV:111 or MOV:121 + MAT payload/carrier semantics", "Transport combines displacement with a material participant relation."],
  ["exit", "compound", "MOV:101/MOV:100 + a STR boundary/container relation", "Leaving a bounded region adds structural boundary semantics."],
  ["enter", "compound", "MOV:111/MOV:110 + a STR boundary/container relation", "Target arrival alone does not encode containment."],
  ["orbit", "compound plus contour", "MOV:121 + route/cycle relation + repeated-loop contour", "Orbital geometry and repetition are not atomic here."],
  ["wander", "unresolved vocabulary gap", "No forced mapping", "Wandering lacks a stable source, target, or system-route axis and may require manner/trajectory vocabulary."],
  ["reverse", "compound or unresolved vocabulary gap", "Replace target/source bindings or apply a future direction relation", "Reversal is a relation between successive motion vectors, not one phase root."]
].map do |concept, type, expression, rationale|
  {"english_concept" => concept, "mapping_type" => type, "expression" => expression, "rationale" => rationale}
end.freeze

family_collision_text = {
  "MAT" => {
    "source" => "The Motion root stands alone for source-relative displacement. Form a compound when a material body, force, or payload matters; the Motion root must not mean force, ejection mechanics, or matter transfer.",
    "target" => "The Motion root stands alone for target-relative displacement. Form a compound for material payload/delivery; it must not mean force application or material transformation at the target.",
    "system" => "The Motion root stands alone for route traversal. Form a compound when matter or energy circulates; it must not cover resource exchange or physical transformation."
  },
  "MIN" => {
    "source" => "A physical/sequential departure may modify a mental-state graph, but a shift of attention, forgetting, or decision to leave belongs to MIN and should not be covered by MOV alone.",
    "target" => "Physical/sequential approach stands alone; attention turning toward a subject or mental goal belongs to MIN, with a compound only when both processes occur.",
    "system" => "Route traversal stands alone; progress through reasoning, learning, or attention states belongs to MIN unless those states are explicitly modeled as sequence positions."
  },
  "CON" => {
    "source" => "Leaving a participant or channel forms a compound only when spatial/sequential displacement also occurs. Withdrawal, disconnection, or release without displacement is CON, not MOV.",
    "target" => "Approaching a participant can compound with CON, but contacting, delivering a message, or establishing a bond is not target arrival.",
    "system" => "Moving through a route can carry communication as a compound; broadcast, routing of meanings, and participant synchronization remain CON."
  },
  "STR" => {
    "source" => "A component exiting a structure forms a MOV+STR compound. Detachment, reorganization, or role removal without displacement is STR.",
    "target" => "Entry into or docking with a structure compounds MOV with STR. Construction, containment, or installation is not arrival alone.",
    "system" => "Infrastructure may supply the route in a compound. Structural deployment or organizational transition is STR and must not be covered by route traversal."
  },
  "DAT" => {
    "source" => "A record can be modeled as a mover in a compound, but reading, deletion, copying, or transmission from a source is DAT rather than departure by itself.",
    "target" => "A data packet's spatial/logical arrival may compound with MOV, but write, retrieval, delivery, and assignment are DAT processes.",
    "system" => "Data may traverse a route as a compound. Replication, indexing, synchronization, and information flow are DAT and must not be absorbed by MOV."
  },
  "CRE" => {
    "source" => "Relocating a created artifact can compound with CRE; emergence, generation, or transformation from a source is CRE rather than departure.",
    "target" => "Moving toward a design target can modify a CRE graph, but instantiation or transformation of that target is CRE, not arrival.",
    "system" => "A generative workflow may be represented as a route only when ordered positions are explicit. Creation or system generation remains CRE."
  },
  "ORI" => {
    "source" => "Leaving a spatial/sequential origin stands alone; ceasing to exist, becoming, or leaving an ontological state belongs to ORI unless a Motion metaphor is explicitly modeled as a compound.",
    "target" => "Reaching a position stands alone; manifestation or transition into actuality is ORI, not target arrival.",
    "system" => "Traversal of an ordered route stands alone; epochal, temporal, cosmological, or ontological transition belongs to ORI unless positions/routes are explicitly part of the graph."
  }
}.freeze

def axis_kind(id)
  case id[4, 2]
  when "10" then "source"
  when "11" then "target"
  when "12" then "system"
  else raise "unexpected id #{id}"
  end
end

collisions = IDS.flat_map do |id|
  family_collision_text.map do |family, texts|
    text = texts.fetch(axis_kind(id))
    disposition =
      if text.include?("must not") || text.include?("should not")
        "forms compound where both domains are asserted; otherwise should not cover competing meaning"
      else
        "stands alone for Motion; forms compound where both domains are asserted"
      end
    {
      "root" => id,
      "competing_family" => family,
      "disposition" => disposition,
      "analysis" => text
    }
  end
end.freeze

review_roots = IDS.map do |id|
  atom = structural.fetch(id)
  design = designs.fetch(id)
  fixed = {
    "canonical_id" => id,
    "universal_slot" => atom.fetch("universal_slot"),
    "family_qualified_transliteration" => atom.fetch("canonical_transliteration"),
    "local_compact_root" => atom.fetch("local_compact_root"),
    "formal_carrier" => atom.fetch("formal_carrier"),
    "harmonic_signature_semitones" => atom.fetch("harmonic_signature_semitones"),
    "relative_note_path_semitones" => atom.fetch("note_path_semitones")
  }
  {
    "status" => "proposed_in_detailed_review_not_canonical",
    "fixed_generated_fields" => fixed,
    "current_phase2_candidate" => {
      "title" => atom.fetch("title"),
      "definition" => atom.fetch("core_definition"),
      "authority" => "candidate_only"
    },
    "candidate_analysis" => design.fetch("candidates"),
    "proposed_title" => design.fetch("proposed_title"),
    "invariant_definition" => design.fetch("invariant_definition"),
    "address_justification" => {
      "first_trit" => "1 = process/action/transformation: this root predicates displacement, not a position, route, capacity, or relationship.",
      "second_trit" => case axis_kind(id)
                       when "source" then "0 = inward/source: the process is defined by displacement relative to its source position."
                       when "target" then "1 = outward/target: the process is defined by displacement relative to a selected target position."
                       when "system" then "2 = systemic/shared: the process is defined by traversal of a route shared or established by a system."
                       end,
      "third_trit" => case design.fetch("phase")
                      when "completed" then "0 = completed: the defining displacement/traversal has reached its endpoint condition."
                      when "active" then "1 = active: the defining displacement/traversal is presently under way."
                      when "pending" then "2 = pending: the defining displacement/traversal is specified but has not begun."
                      end
    },
    "boundaries" => {
      "includes" => design.fetch("includes"),
      "does_not_include" => design.fetch("excludes"),
      "nearest_same_family_root" => design.fetch("nearest_same_family"),
      "cross_domain_handling" => design.fetch("cross_domain")
    },
    "existing_motion_entity_contrast" => design.fetch("entity_contrast"),
    "runtime_state_interpretations" => design.fetch("runtime"),
    "lexical_third_trit_vs_runtime_state_2" => design.fetch("third_vs_runtime"),
    "confidence" => design.fetch("confidence")
  }
end.freeze

candidates_yaml = {
  "metadata" => {
    "title" => "MOV:100–122 detailed semantic candidates",
    "status" => "proposed_for_user_review_not_canonical",
    "semantic_authority" => PROVISIONAL,
    "gate3_approval_status" => WITHDRAWAL,
    "fixed_generated_fields_must_not_change" => true,
    "root_count" => 9
  },
  "triplet_design" => [
    {
      "range" => "MOV:100–102",
      "shared_axis" => "source-relative displacement",
      "completed_active_pending_contrast" => "100 completion away from source; 101 ongoing motion away from source; 102 specified source departure before onset"
    },
    {
      "range" => "MOV:110–112",
      "shared_axis" => "target-relative displacement",
      "completed_active_pending_contrast" => "110 completion at target; 111 ongoing motion toward target; 112 specified targetward motion before onset"
    },
    {
      "range" => "MOV:120–122",
      "shared_axis" => "system-route traversal",
      "completed_active_pending_contrast" => "120 completed traversal; 121 ongoing traversal; 122 specified traversal before onset"
    }
  ],
  "roots" => review_roots,
  "approval" => {
    "canonicalized" => false,
    "requires_explicit_user_decision" => true,
    "next_packet_authorized" => false
  }
}

test_cases_yaml = {
  "metadata" => {
    "title" => "MOV:100–122 examples and coverage tests",
    "status" => "review_evidence_not_canonical",
    "example_count" => 54,
    "english_coverage_test_count" => coverage.length
  },
  "root_examples" => IDS.map do |id|
    {
      "root" => id,
      "examples" => example_specs.fetch(id).map do |category, graph, gloss, english, runtime, contour, registers|
        {
          "category" => category,
          "semantic_graph" => graph,
          "literal_gloss" => gloss,
          "natural_english" => english,
          "runtime_state" => runtime,
          "contour" => contour,
          "role_register_assignments" => registers
        }
      end
    }
  end,
  "english_motion_coverage" => coverage
}

def write_yaml(path, object)
  File.write(path, object.to_yaml(line_width: -1))
end

write_yaml(File.join(REVIEW_DIR, "MOV_100_122_candidates.yaml"), candidates_yaml)
write_yaml(File.join(REVIEW_DIR, "MOV_100_122_test_cases.yaml"), test_cases_yaml)

collision_md = +"# MOV:100–122 Cross-Family Collision Report\n\n"
collision_md << "Status: **#{PROVISIONAL}**. This report proposes boundaries; it does not canonize any Motion meaning.\n\n"
collision_md << "A pure displacement/traversal graph may use the proposed MOV root by itself. When another domain is independently asserted, form a compound. The MOV root must never consume the other family's process merely because English uses a motion metaphor.\n\n"
collision_md << "| MOV root | Competing family | Disposition | Collision analysis |\n"
collision_md << "|---|---|---|---|\n"
collisions.each do |row|
  collision_md << "| #{row["root"]} | #{row["competing_family"]} | #{row["disposition"]} | #{row["analysis"]} |\n"
end
collision_md << "\n## Findings\n\n"
collision_md << "- The source triplet is safe only when **displacement away from a source** is present; release, withdrawal, deletion, and emergence are not automatically Motion.\n"
collision_md << "- The target triplet is safe only when **displacement toward/reaching a target** is present; delivery, contact, instantiation, and manifestation remain other-family processes.\n"
collision_md << "- The systemic triplet is safe only when **ordered route traversal** is present; generic system flow or transition would collide with nearly every process family.\n"
collision_md << "- Cross-domain cases should be graphs/compounds, not broadened atomic definitions.\n"
File.write(File.join(REVIEW_DIR, "MOV_100_122_collision_report.md"), collision_md)

review_md = +"# MOV:100–122 Detailed Semantic Review\n\n"
review_md << "Status: **PROPOSED FOR USER REVIEW — NOT CANONICAL**  \n"
review_md << "Current semantic authority: **#{PROVISIONAL}**  \n"
review_md << "Gate 3 promotion: **#{WITHDRAWAL}**\n\n"
review_md << "This packet reconsiders the nine Motion process addresses from their family and trit axes. It does not preserve a Phase 2 title merely because it already existed. Generated structural fields are copied from the accepted algorithms and are not changed.\n\n"
review_md << "## Design result at a glance\n\n"
review_md << "| Root | Universal slot | Proposed title | Invariant atomic definition | Confidence |\n"
review_md << "|---|---|---|---|---:|\n"
review_roots.each do |root|
  fixed = root.fetch("fixed_generated_fields")
  review_md << "| #{fixed["canonical_id"]} | #{fixed["universal_slot"]} | #{root["proposed_title"]} | #{root["invariant_definition"]} | #{format("%.2f", root["confidence"])} |\n"
end

review_md << "\n## Triplet architecture\n\n"
review_md << "### MOV:100–102 — source-relative displacement\n\n"
review_md << "The shared axis is displacement defined by increasing separation from a source. `100` is the completed departure, `101` is that departure in progress, and `102` is the same departure specified before onset. The triplet does not encode readiness, permission, or waiting.\n\n"
review_md << "### MOV:110–112 — target-relative displacement\n\n"
review_md << "The shared axis is displacement defined by progress toward a target. `110` is completion at the target, `111` is approach in progress, and `112` is the targetward operation specified before onset. A destination entity remains `MOV:010–012`; it is not the process.\n\n"
review_md << "### MOV:120–122 — system-route traversal\n\n"
review_md << "The shared axis is motion along an ordered route that is shared or established by a system. `120` is completed traversal, `121` is traversal in progress, and `122` is traversal specified before onset. Circulation, repetition, synchronization, scheduling, data flow, material flow, and ontological transition require contour, grammar, or compounds; they are not bundled into the atom.\n\n"

review_roots.each do |root|
  fixed = root.fetch("fixed_generated_fields")
  id = fixed.fetch("canonical_id")
  review_md << "## #{id} — proposed “#{root["proposed_title"]}”\n\n"
  review_md << "Packet status: **not canonical**.\n\n"
  review_md << "### A. Address and generated forms\n\n"
  review_md << "| Field | Fixed value |\n|---|---|\n"
  review_md << "| Canonical ID | `#{id}` |\n"
  review_md << "| Universal slot | #{fixed["universal_slot"]} |\n"
  review_md << "| Family-qualified transliteration | `#{fixed["family_qualified_transliteration"]}` |\n"
  review_md << "| Local compact root | `#{fixed["local_compact_root"]}` |\n"
  review_md << "| Formal carrier | `#{fixed["formal_carrier"]}` |\n"
  review_md << "| Harmonic signature | `#{fixed["harmonic_signature_semitones"].inspect}` |\n"
  review_md << "| Relative note path | `#{fixed["relative_note_path_semitones"].inspect}` |\n\n"
  review_md << "### B. Candidate analysis\n\n"
  review_md << "The Phase 2 candidate was **#{root["current_phase2_candidate"]["title"]}** — “#{root["current_phase2_candidate"]["definition"]}” It is treated only as evidence of a prior proposal.\n\n"
  review_md << "| Candidate | Why it fits | Useful coverage | Territory consumed | Conflicts / limitations | Result |\n"
  review_md << "|---|---|---|---|---|---|\n"
  root.fetch("candidate_analysis").each do |candidate|
    review_md << "| #{candidate["title"]} | #{candidate["fit"]} | #{candidate["useful_coverage"]} | #{candidate["territory_consumed"]} | #{candidate["limitations_or_conflicts"]} | #{candidate["selection"]} |\n"
  end
  review_md << "\n### C. Invariant atomic definition\n\n"
  review_md << "**#{root["invariant_definition"]}**\n\n"
  review_md << "This definition has one center: #{designs.fetch(id).fetch("axis")}, in its #{designs.fetch(id).fetch("phase")} phase.\n\n"
  review_md << "### D. Address justification\n\n"
  root.fetch("address_justification").each do |axis, text|
    review_md << "- **#{axis.tr("_", " ")}:** #{text}\n"
  end
  review_md << "\n### E. Inclusion and exclusion boundaries\n\n"
  review_md << "- **Includes:** #{root["boundaries"]["includes"]}\n"
  review_md << "- **Does not include:** #{root["boundaries"]["does_not_include"]}\n"
  review_md << "- **Nearest same-family handling:** #{root["boundaries"]["nearest_same_family_root"]}\n"
  review_md << "- **Cross-domain handling:** #{root["boundaries"]["cross_domain_handling"]}\n\n"
  review_md << "### F–G. Triplet and existing-Motion contrast\n\n"
  review_md << "Triplet axis: **#{designs.fetch(id).fetch("axis")}**; this root is the **#{designs.fetch(id).fetch("phase")}** member. #{root["existing_motion_entity_contrast"]}\n\n"
  review_md << "### H. Cross-family collision audit\n\n"
  review_md << "Pure Motion reading: **stands alone** when literal or explicitly modeled displacement/traversal is asserted. The seven-family detailed dispositions are in `reviews/MOV_100_122_collision_report.md`.\n\n"
  collisions.select { |row| row["root"] == id }.each do |row|
    review_md << "- **#{row["competing_family"]}:** #{row["analysis"]}\n"
  end
  review_md << "\n### I. Tailored runtime-state interpretations\n\n"
  root.fetch("runtime_state_interpretations").each do |state, text|
    label = state == "2" ? "[2]/num" : "[#{state}]"
    review_md << "- **#{label}:** #{text}\n"
  end
  review_md << "\n**Lexical third trit versus runtime [2]/num:** #{root["lexical_third_trit_vs_runtime_state_2"]}\n\n"
  review_md << "### J. Examples\n\n"
  review_md << "| Type | Semantic graph | Literal gloss | Natural English | Runtime | Contour | Roles/registers |\n"
  review_md << "|---|---|---|---|---|---|---|\n"
  test_cases_yaml.fetch("root_examples").find { |item| item["root"] == id }.fetch("examples").each do |example|
    review_md << "| #{example["category"]} | `#{example["semantic_graph"]}` | #{example["literal_gloss"]} | #{example["natural_english"]} | #{example["runtime_state"]} | #{example["contour"]} | #{example["role_register_assignments"]} |\n"
  end
  review_md << "\n"
end

review_md << "## K. English Motion coverage tests\n\n"
review_md << "| English concept | Mapping classification | Proposed expression | Reason |\n"
review_md << "|---|---|---|---|\n"
coverage.each do |test|
  review_md << "| #{test["english_concept"]} | #{test["mapping_type"]} | #{test["expression"]} | #{test["rationale"]} |\n"
end

review_md << "\n## L. Packet-level analysis\n\n"
review_md << "### Nine-root contrast matrix\n\n"
review_md << "| Orientation / phase | Completed (third 0) | Active (third 1) | Pending (third 2) |\n"
review_md << "|---|---|---|---|\n"
review_md << "| Source / inward (second 0) | MOV:100 completed departure | MOV:101 departing | MOV:102 specified departure before onset |\n"
review_md << "| Target / outward (second 1) | MOV:110 arrived | MOV:111 approaching | MOV:112 specified approach before onset |\n"
review_md << "| Systemic / shared (second 2) | MOV:120 completed route traversal | MOV:121 traversing route | MOV:122 specified route traversal before onset |\n\n"
review_md << "### Triplet-coherence assessment\n\n"
review_md << "- **MOV:100–102:** high coherence. All three are one source-relative displacement operation separated only by lexical phase.\n"
review_md << "- **MOV:110–112:** high coherence. All three are one target-relative displacement operation separated only by lexical phase.\n"
review_md << "- **MOV:120–122:** good but lower-confidence coherence. Restricting the axis to system-route traversal avoids the Phase 2 collision-prone bundle of transfer, circulation, signals, and temporal transition.\n\n"
review_md << "### Cross-family collision summary\n\n"
review_md << "| Risk area | Resolution |\n|---|---|\n"
review_md << "| Physical displacement vs MAT | MOV provides displacement; MAT supplies body, force, energy, or payload in a compound. |\n"
review_md << "| Mental/attention change vs MIN | Pure mental shifts are MIN; use MOV only when a position/route model is explicit. |\n"
review_md << "| Participant transmission vs CON | Contact and message exchange are CON; movement of a participant may compound with MOV. |\n"
review_md << "| Structural transition vs STR | Reorganization is STR; exit/entry through a structure compounds STR with MOV. |\n"
review_md << "| Information flow vs DAT | Encoding/copying/transmission is DAT; route traversal by a data object may compound with MOV. |\n"
review_md << "| Transformation/generation vs CRE | Creation is CRE; relocation of a created form may compound with MOV. |\n"
review_md << "| Temporal/ontological transition vs ORI | Becoming and actuality are ORI; MOV requires explicit ordered positions or a route. |\n\n"
review_md << "### Uncovered Motion concepts\n\n"
review_md << "- scalar speed and acceleration;\n- direction/vector without a target;\n- rotation about a local axis;\n- proximity and distance relations;\n- boundary crossing as such;\n- pursuit/following a moving target;\n- wandering or pathless motion;\n- reversal/redirect as a relation between motion operations;\n- transport roles such as carrier and payload;\n- duration-based waiting, pause, and delay.\n\n"
review_md << "These are not filled here. Some may belong to MOV:200–222, compounds, or timing/contour grammar, but that later work is not authorized.\n\n"
review_md << "### Concepts intentionally reserved for compounds or grammar\n\n"
review_md << "- `return` = targetward movement with a prior origin as target;\n- `transport` = Motion process + MAT payload/carrier;\n- `enter/exit` = Motion process + STR boundary/container;\n- `circulate/orbit/repeat a route` = route traversal + route/cycle relation + repeated-loop contour;\n- `move together` = collective actor + route traversal, with coordination added if needed;\n- `schedule/delay/wait/pause/continue/stop` = Motion operation plus runtime state, timing, contour, and later grammar.\n\n"
review_md << "### Unresolved decisions\n\n"
review_md << "- Whether system-route traversal is the final best systemic axis (confidence is lower than the source and target triplets).\n"
review_md << "- Whether a single mover on public infrastructure is sufficient for the systemic/shared trit; this packet proposes yes when the route, not merely the target, defines the operation.\n"
review_md << "- Where direction, pursuit, crossing, and reversal ultimately live.\n"
review_md << "- Which exact timing/grammar mechanisms express wait, pause, continue, schedule, and delay.\n\n"
review_md << "### Proposed titles and invariant definitions\n\n"
review_roots.each do |root|
  id = root["fixed_generated_fields"]["canonical_id"]
  review_md << "- **#{id} — #{root["proposed_title"]}:** #{root["invariant_definition"]} (confidence #{format("%.2f", root["confidence"])})\n"
end
review_md << "\n### Approval checklist\n\n"
review_md << "- [x] Generated fields match the accepted algorithms.\n"
review_md << "- [x] Each root has at least two first-principles candidates.\n"
review_md << "- [x] Each proposed invariant has one semantic center.\n"
review_md << "- [x] Each triplet has a single shared axis with completed/active/pending contrast.\n"
review_md << "- [x] MOV:000–022 entity/process boundaries are explicit.\n"
review_md << "- [x] MAT, MIN, CON, STR, DAT, CRE, and ORI collisions were audited.\n"
review_md << "- [x] Runtime [0]/[1]/[2] readings are tailored per root.\n"
review_md << "- [x] At least 20 English Motion concepts were tested without forced atomization.\n"
review_md << "- [ ] User approves or revises each proposed meaning.\n"
review_md << "- [ ] User explicitly canonizes the nine roots. **Not satisfied.**\n"
review_md << "- [ ] Authorization to begin MOV:200–222. **Not granted.**\n"
review_md << "- [ ] Authorization to begin Gate 4. **Not granted.**\n\n"
review_md << "## M. Document status\n\n"
review_md << "This is the detailed companion record. The main language document receives only a concise authority and packet-status summary. Catalogue entries remain concise candidates until explicit user approval. No meaning in this packet is canonicalized by this review.\n"

File.write(File.join(REVIEW_DIR, "MOV_100_122_detailed_review.md"), review_md)

puts "Built MOV:100–122 review packet."
puts "Roots: #{review_roots.length}"
puts "Examples: #{test_cases_yaml["metadata"]["example_count"]}"
puts "Coverage tests: #{coverage.length}"
puts "Collision rows: #{collisions.length}"
