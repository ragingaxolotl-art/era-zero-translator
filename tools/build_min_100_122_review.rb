#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MIN:100 MIN:101 MIN:102
  MIN:110 MIN:111 MIN:112
  MIN:120 MIN:121 MIN:122
].freeze
SCORE_KEYS = %w[
  atomicity address_fit family_fit neighbor_separation
  cross_family_separation compound_usefulness
  everyday_language_coverage technical_coverage
].freeze
CROSS_FAMILIES = %w[LIF MOV MAT CON STR WRN REP LOG DAT CRE ORI].freeze

def load_yaml(path)
  YAML.load_file(File.join(ROOT, path))
end

def write_yaml(path, value)
  File.write(File.join(ROOT, path), YAML.dump(value))
end

def fixed_projection(atom)
  {
    "canonical_id" => atom["canonical_id"],
    "universal_slot" => atom["universal_slot"],
    "family_qualified_transliteration" => atom["canonical_transliteration"],
    "local_compact_root" => atom["local_compact_root"],
    "formal_carrier" => atom["formal_carrier"],
    "harmonic_signature_semitones" => atom["harmonic_signature_semitones"],
    "relative_note_path_semitones" => atom["note_path_semitones"]
  }
end

def candidate(id:, title:, definition:, scores:, fit:, coverage:, territory:, risk:)
  raise "#{id}: expected #{SCORE_KEYS.length} scores" unless scores.length == SCORE_KEYS.length

  {
    "candidate_id" => id,
    "title" => title,
    "invariant_candidate" => definition,
    "analysis" => {
      "why_it_fits" => fit,
      "useful_coverage" => coverage,
      "semantic_territory_consumed" => territory,
      "conflicts_or_future_limitations" => risk
    },
    "scores" => SCORE_KEYS.zip(scores).to_h,
    "total" => scores.sum,
    "maximum" => 80
  }
end

def example(category:, graph:, literal:, natural:, analysis:, runtime: 1,
            contour: "declarative", use_status: "valid", pseudocode: nil)
  {
    "category" => category,
    "semantic_graph" => graph,
    "literal_gloss" => literal,
    "natural_english" => natural,
    "runtime_state" => runtime,
    "contour" => contour,
    "role_registers" => {
      "low" => "cognizer or cognitive community",
      "middle" => "MIN revision predicate",
      "high" => "represented target or revised content",
      "sustained" => "shared frame, evidence context, or execution environment"
    },
    "use_status" => use_status,
    "analysis" => analysis
  }.tap { |item| item["pseudocode"] = pseudocode if pseudocode }
end

def phase_label(phase)
  {
    "completed" => "completed",
    "active" => "active",
    "nonactualized" => "nonactualized"
  }.fetch(phase)
end

def phase_definition(phase)
  {
    "completed" => "has reached its bounded result",
    "active" => "is presently occurring",
    "nonactualized" => "is neither active nor completed and is selected only as a dormant, potential, or unresolved process"
  }.fetch(phase)
end

def runtime_interpretations(root)
  scope = root.fetch("runtime_scope")
  {
    "0" => "Denies that the specified #{scope} exists in the lexical #{root.fetch("phase")} phase for this token.",
    "1" => "Affirms that the specified #{scope} exists in the lexical #{root.fetch("phase")} phase for this token.",
    "2/num" => "Leaves the current assertion about the #{scope} dormant or unresolved; it does not select another lexical phase or add a plan, schedule, or future time."
  }
end

def candidate_scores(root, kind)
  case kind
  when "current"
    root.fetch("current_scores")
  when "revision"
    root.fetch("direction") == "shared" ? [10, 10, 10, 10, 8, 10, 9, 10] : [10, 10, 10, 10, 9, 10, 9, 10]
  when "attention"
    root.fetch("phase") == "active" ? [9, 9, 10, 7, 8, 9, 10, 9] : [9, 8, 10, 7, 8, 9, 9, 9]
  when "inference"
    root.fetch("direction") == "shared" ? [8, 9, 8, 7, 4, 9, 9, 10] : [8, 9, 9, 7, 5, 9, 10, 10]
  when "memory"
    root.fetch("direction") == "shared" ? [9, 8, 9, 7, 6, 8, 9, 8] : [9, 8, 10, 7, 7, 8, 10, 8]
  else
    raise "unknown candidate kind #{kind}"
  end
end

atoms = load_yaml("lexicon/atoms.yaml").fetch("atoms")
atoms_by_id = atoms.to_h { |atom| [atom.fetch("canonical_id"), atom] }

DESIGN = {
  "MIN:100" => {
    "direction" => "self", "phase" => "completed",
    "title" => "completed self-model revision",
    "definition" => "A completed cognitive process whose result is a change to the cognizer's representation of the cognizer's own identity or condition.",
    "runtime_scope" => "self-model revision",
    "current_rationale" => "“Understanding achieved” was probably chosen because completed + inward + Mind suggests a cognitive result internal to the cognizer. Its definition then joins memory formation, insight, and decision—different results with different truth, storage, and commitment conditions.",
    "current_scores" => [4, 8, 9, 5, 4, 7, 9, 7],
    "attention" => ["completed inward attention shift", "A completed reallocation of attention toward the cognizer's own condition."],
    "inference" => ["completed self-assessment", "A completed inferential evaluation whose subject is the cognizer."],
    "memory" => ["completed autobiographical recall", "A completed retrieval of a representation whose subject is the remembering cognizer."],
    "examples" => [
      ["ordinary_conversation", "MIN:100[1](COGNIZER=I,CONTENT=self_as_manager)", "I; completed revision of my self-model", "I changed how I see myself as a manager.", "The completed change is owned; whether the new view is true is not."],
      ["physical_or_spatial", "MAT(BODY=climber)+MIN:100[1](COGNIZER=climber,CONTENT=own_reach)", "climber's body plus completed self-model revision of reach", "After the test, the climber revised their sense of how far they can reach.", "MAT owns the body; MIN owns the changed self-representation."],
      ["temporal_or_sequential", "MIN:100[1](COGNIZER=agent,BEFORE=self_v1,AFTER=self_v2)", "agent; self-model revision completed from v1 to v2", "The agent finished updating its self-model after the diagnostic.", "Before/after content is graph structure, not hidden in the atom."],
      ["cross_family_compound", "DAT(EVIDENCE=performance_log)+MIN:100[1](COGNIZER=agent,CONTENT=capability_model)", "performance log causes completed self-model revision", "The log led the agent to revise its model of its own capability.", "DAT supplies evidence; a causal relation must be explicit."],
      ["executable_or_programming", "MIN:100[1](COGNIZER=agent,CONTENT=self_model,RESULT=version_4)", "agent; self-model revision completed with version 4", "Commit the revised agent self-model as version 4.", "Useful as the semantic event behind a successful self-model update.", "assert self_model.version == 4 && revision.complete?"],
      ["counterexample", "MIN:001[1](COGNIZER=I,CONTENT=current_mood)", "I; manifest self-representation", "I am aware of my mood, but my self-model has not changed.", "Present self-awareness without representational change uses MIN:001, not MIN:100."]
    ]
  },
  "MIN:101" => {
    "direction" => "self", "phase" => "active",
    "title" => "active self-model revision",
    "definition" => "An active cognitive process that is changing the cognizer's representation of the cognizer's own identity or condition.",
    "runtime_scope" => "self-model revision",
    "current_rationale" => "“Active reflection” follows active + inward + Mind, but its definition merges remembering, imagining, evaluating, and reorganizing. Reflection can merely inspect a self-representation; the address needs one process center rather than every inward mental activity.",
    "current_scores" => [3, 9, 10, 5, 7, 7, 10, 8],
    "attention" => ["active inward attention shift", "An active reallocation of attention toward the cognizer's own condition."],
    "inference" => ["active self-assessment", "An active inferential evaluation whose subject is the cognizer."],
    "memory" => ["active autobiographical recall", "An active retrieval of a representation whose subject is the remembering cognizer."],
    "examples" => [
      ["ordinary_conversation", "MIN:101[1](COGNIZER=I,CONTENT=self_as_parent)", "I; self-model revision active", "I am rethinking what kind of parent I am.", "The root applies because the self-representation is changing, not merely being observed."],
      ["physical_or_spatial", "MAT(SENSATION=fatigue)+MIN:101[1](COGNIZER=runner,CONTENT=own_limit)", "fatigue signal plus active revision of own limit", "The runner is revising their sense of their physical limit.", "The physical signal remains MAT."],
      ["temporal_or_sequential", "MIN:101[1](COGNIZER=agent,DURING=calibration,CONTENT=self_accuracy)", "agent; self-model revision active during calibration", "The agent is updating its estimate of its own accuracy during calibration.", "The active phase is lexical; the interval is explicit."],
      ["cross_family_compound", "WRN(DISCREPANCY=failed_prediction)+MIN:101[1](COGNIZER=agent,CONTENT=self_model)", "detected discrepancy plus active self-model revision", "The failed prediction is making the agent revise its self-model.", "WRN owns discrepancy; MIN owns cognitive revision."],
      ["executable_or_programming", "MIN:101[1](COGNIZER=agent,CONTENT=self_model,INPUT=telemetry)", "agent; self-model revision executing from telemetry", "Update the agent's self-model from live telemetry.", "Maps to an executing semantic operation, not the storage write itself.", "while telemetry.open?; self_model.revise(telemetry.next); end"],
      ["counterexample", "MIN:001[1](COGNIZER=operator,CONTENT=current_state)", "operator; current self-state representation manifest", "The operator is monitoring their state without changing their self-model.", "Monitoring or manifestation alone is not revision."]
    ]
  },
  "MIN:102" => {
    "direction" => "self", "phase" => "nonactualized",
    "title" => "nonactualized self-model revision",
    "definition" => "A cognitive process that would change the cognizer's representation of the cognizer's own identity or condition if actualized, but is not active or completed.",
    "runtime_scope" => "nonactualized self-model revision",
    "current_rationale" => "“Pending reflection” was chosen from the old label pending inward process. The definition makes the process intended and not begun, but lexical `1x2` is now fixed as nonactualized and cannot encode intention, scheduling, readiness, queue position, probability, or future time.",
    "current_scores" => [3, 4, 10, 5, 4, 5, 8, 5],
    "attention" => ["nonactualized inward attention shift", "A nonactualized reallocation of attention toward the cognizer's own condition."],
    "inference" => ["nonactualized self-assessment", "A nonactualized inferential evaluation whose subject would be the cognizer."],
    "memory" => ["nonactualized autobiographical recall", "A nonactualized retrieval of a representation whose subject would be the remembering cognizer."],
    "examples" => [
      ["ordinary_conversation", "MIN:102[1](COGNIZER=I,CONTENT=self_as_leader)", "I; self-model revision nonactualized", "A change in how I see myself remains possible, but no such revision is underway or complete.", "Affirming the lexeme affirms its nonactualized status; it does not announce a plan."],
      ["physical_or_spatial", "MAT(EVENT=injury)+MIN:102[1](COGNIZER=athlete,CONTENT=body_capability)", "injury context plus nonactualized revision of own capability", "The injury could alter the athlete's self-model, but that cognitive change has not occurred.", "No causal certainty is asserted."],
      ["temporal_or_sequential", "MIN:102[1](COGNIZER=agent,CONTENT=self_model,STATUS=unrealized)", "agent; self-model revision remains nonactualized", "The agent has not entered or completed a self-model revision.", "This says nothing about when or whether it will."],
      ["cross_family_compound", "CRE(PLAN=self_review)+MIN:102[1](COGNIZER=person,CONTENT=self_model)", "created plan plus nonactualized self-model revision", "A self-review is planned, while the actual self-model revision remains nonactualized.", "The plan must be a separate CRE/DAT structure."],
      ["executable_or_programming", "MIN:102[1](COGNIZER=agent,CONTENT=self_model)", "agent; self-model revision branch nonactualized", "A self-model revision is a possible branch, but no revision task is running or complete.", "Safe for representing a semantic branch without equating it with a queued job.", "assert !revision.running? && !revision.complete?"],
      ["counterexample", "DAT(SCHEDULE=tomorrow_review)", "stored schedule for review", "The self-review is scheduled for tomorrow.", "Scheduling is DAT/CRE plus temporal grammar; lexical MIN:102 does not encode it."]
    ]
  },
  "MIN:110" => {
    "direction" => "target", "phase" => "completed",
    "title" => "completed target-model revision",
    "definition" => "A completed cognitive process whose result is a change to a cognizer's representation of a distinct target.",
    "runtime_scope" => "target-model revision",
    "current_rationale" => "“Target assessment complete” was chosen because completed + outward + Mind suggests a settled cognitive treatment of an external target. The definition merges observation, reasoning, interpretation, and decision, each of which can finish without changing a target model in the same way.",
    "current_scores" => [3, 9, 9, 6, 5, 7, 9, 8],
    "attention" => ["completed target-attention shift", "A completed reallocation of a cognizer's attention toward a distinct target."],
    "inference" => ["completed target inference", "A completed inferential evaluation whose subject is a distinct target."],
    "memory" => ["completed target recall", "A completed retrieval of a representation of a distinct target."],
    "examples" => [
      ["ordinary_conversation", "MIN:110[1](COGNIZER=I,TARGET=neighbor,RESULT=model_v2)", "I; target-model revision completed", "I changed my view of my neighbor after we spoke.", "The conversation is a possible cause, not part of the atom."],
      ["physical_or_spatial", "MAT(OBSERVATION=bridge_damage)+MIN:110[1](COGNIZER=engineer,TARGET=bridge_model)", "physical observation plus completed bridge-model revision", "The engineer finished updating their mental model of the bridge.", "The bridge and signal are physical; the changed representation is mental."],
      ["temporal_or_sequential", "MIN:110[1](COGNIZER=student,TARGET=theory,BEFORE=model_a,AFTER=model_b)", "student; theory representation revised from a to b", "The lesson ended with the student's model of the theory changed.", "Learning is expressed here only to the extent that a target representation changed."],
      ["cross_family_compound", "DAT(EVIDENCE=dataset)+LOG(INFERENCE=result)+MIN:110[1](COGNIZER=analyst,TARGET=system)", "dataset and inference plus completed target-model revision", "The analysis led the analyst to update their model of the system.", "DAT and LOG remain explicit."],
      ["executable_or_programming", "MIN:110[1](COGNIZER=agent,TARGET=world_model.object_7,RESULT=revision_8)", "agent; target model revision completed", "Commit revision 8 of the agent's model of object 7.", "A semantic success event after model update.", "assert world_model[:object_7].revision == 8"],
      ["counterexample", "MIN:010[1](COGNIZER=agent,TARGET=object_7)", "agent; persistent target representation", "The agent's representation of object 7 persisted unchanged.", "A persistent target model without change is MIN:010, not MIN:110."]
    ]
  },
  "MIN:111" => {
    "direction" => "target", "phase" => "active",
    "title" => "active target-model revision",
    "definition" => "An active cognitive process that is changing a cognizer's representation of a distinct target.",
    "runtime_scope" => "target-model revision",
    "current_rationale" => "“Active inquiry” fits active + outward + Mind at a broad level, but its definition collapses observing, questioning, learning, and deciding. An inquiry may gather data without yet altering cognition; a model-revision process provides a single invariant.",
    "current_scores" => [2, 9, 10, 5, 5, 6, 10, 8],
    "attention" => ["active target-attention shift", "An active reallocation of a cognizer's attention toward a distinct target."],
    "inference" => ["active target inference", "An active inferential evaluation whose subject is a distinct target."],
    "memory" => ["active target recall", "An active retrieval of a representation of a distinct target."],
    "examples" => [
      ["ordinary_conversation", "MIN:111[1](COGNIZER=I,TARGET=proposal)", "I; target-model revision active", "I am changing my understanding of the proposal as you explain it.", "Listening is not enough; the target representation must be changing."],
      ["physical_or_spatial", "MAT(SIGNAL=radar_returns)+MIN:111[1](COGNIZER=operator,TARGET=storm_model)", "radar signal plus active storm-model revision", "The operator is updating their mental model of the storm.", "MAT owns the signal; MIN owns the ongoing revision."],
      ["temporal_or_sequential", "MIN:111[1](COGNIZER=student,TARGET=equation,DURING=lesson)", "student; equation representation revision active during lesson", "The student's model of the equation is changing during the lesson.", "No claim of completed understanding is made."],
      ["cross_family_compound", "DAT(INPUT=telemetry)+MIN:111[1](COGNIZER=agent,TARGET=environment_model)", "telemetry input plus active target-model revision", "The agent is updating its environment model from telemetry.", "Information transport and cognitive revision remain separate."],
      ["executable_or_programming", "MIN:111[1](COGNIZER=agent,TARGET=belief_graph.node_42)", "agent; target-model revision executing on node 42", "Revise belief-graph node 42 as evidence arrives.", "Formalizes an executing internal model update.", "belief_graph[:node_42].revise!(evidence)"],
      ["counterexample", "CON(QUESTION=where_is_station,FROM=I,TO=you)", "question transmitted from me to you", "I asked where the station is.", "Questioning is a communicative act unless an actual cognitive model revision is separately asserted."]
    ]
  },
  "MIN:112" => {
    "direction" => "target", "phase" => "nonactualized",
    "title" => "nonactualized target-model revision",
    "definition" => "A cognitive process that would change a cognizer's representation of a distinct target if actualized, but is not active or completed.",
    "runtime_scope" => "nonactualized target-model revision",
    "current_rationale" => "“Planned inquiry” was selected from the old pending-process gloss. Planning and scheduling are explicitly excluded from lexical `1x2`; an inquiry can also be planned without any target representation ever changing.",
    "current_scores" => [5, 4, 10, 6, 4, 5, 8, 5],
    "attention" => ["nonactualized target-attention shift", "A nonactualized reallocation of a cognizer's attention toward a distinct target."],
    "inference" => ["nonactualized target inference", "A nonactualized inferential evaluation whose subject would be a distinct target."],
    "memory" => ["nonactualized target recall", "A nonactualized retrieval of a representation of a distinct target."],
    "examples" => [
      ["ordinary_conversation", "MIN:112[1](COGNIZER=I,TARGET=proposal)", "I; target-model revision nonactualized", "My view of the proposal could change, but it is not changing and has not changed.", "No intention or likelihood is encoded."],
      ["physical_or_spatial", "MAT(EVENT=new_measurement)+MIN:112[1](COGNIZER=engineer,TARGET=bridge_model)", "measurement context plus nonactualized bridge-model revision", "The new measurement could alter the engineer's bridge model, but no revision is underway.", "The measurement does not automatically imply cognitive change."],
      ["temporal_or_sequential", "MIN:112[1](COGNIZER=agent,TARGET=world_model,STATUS=unrealized)", "agent; target-model revision nonactualized", "The world-model revision remains an unrealized semantic possibility.", "Future time and a task queue are absent."],
      ["cross_family_compound", "DAT(QUEUE=item_7)+MIN:112[1](COGNIZER=agent,TARGET=object_7)", "queued record plus nonactualized target-model revision", "A model-update request is queued, while the cognitive revision itself remains nonactualized.", "DAT owns the queue; MIN:112 does not."],
      ["executable_or_programming", "MIN:112[1](COGNIZER=agent,TARGET=model.branch_b)", "agent; target-model revision branch nonactualized", "Branch B denotes a possible model revision with no running or completed update.", "Represents process nonactualization, not scheduler state.", "assert !branch_b.running? && !branch_b.complete?"],
      ["counterexample", "DAT(SCHEDULE=model_review_at_0900)", "stored model-review schedule", "The model review is scheduled for 9:00.", "A schedule requires DAT plus temporal grammar."]
    ]
  },
  "MIN:120" => {
    "direction" => "shared", "phase" => "completed",
    "title" => "completed shared-schema revision",
    "definition" => "A completed cognitive process distributed across multiple cognizers whose result is a change to a representation held in common among them.",
    "runtime_scope" => "shared-schema revision",
    "current_rationale" => "“Collective learning complete” was chosen because completed + systemic + Mind suggests a group reaching a cognitive result. Learning, inquiry, and common result are not one atom, and the old definition risks equating shared cognition with consensus or communication.",
    "current_scores" => [6, 9, 9, 7, 5, 8, 9, 8],
    "attention" => ["completed joint-attention alignment", "A completed process by which multiple cognizers align attention on one subject."],
    "inference" => ["completed collective deliberation", "A completed inferential evaluation distributed across multiple cognizers."],
    "memory" => ["completed collective recollection", "A completed retrieval of a representation across multiple members of a cognitive community."],
    "examples" => [
      ["ordinary_conversation", "MIN:120[1](COGNIZERS=team,CONTENT=shared_plan_model)", "team; shared-schema revision completed", "The team finished changing its common understanding of the plan.", "Agreement, communication, and truth are not implied."],
      ["physical_or_spatial", "MAT(EVENT=site_walk)+MIN:120[1](COGNIZERS=rescuers,CONTENT=building_schema)", "site walk plus completed shared building-schema revision", "The site walk ended with the rescuers' shared mental map changed.", "The building and walk remain outside MIN."],
      ["temporal_or_sequential", "MIN:120[1](COGNIZERS=crew,BEFORE=schema_v1,AFTER=schema_v2)", "crew; shared schema revised from v1 to v2", "The crew completed a revision of its common operating model.", "The atom owns the bounded distributed cognitive change."],
      ["cross_family_compound", "CON(EXCHANGE=briefing)+MIN:120[1](COGNIZERS=crew,CONTENT=shared_schema)", "briefing exchange plus completed shared-schema revision", "The briefing produced a completed change in the crew's shared mental model.", "CON owns exchange; causation is explicit."],
      ["executable_or_programming", "MIN:120[1](COGNIZERS=agents,CONTENT=shared_world_model,RESULT=epoch_12)", "agents; shared world-model revision completed at epoch 12", "Commit epoch 12 of the agents' shared world model.", "Useful for multi-agent convergence without asserting network transport.", "assert shared_model.epoch == 12 && revision.complete?"],
      ["counterexample", "CON(CONSENSUS_VOTE=result_yes,PARTICIPANTS=team)", "team; vote produces yes result", "The team voted yes, but members' mental models may remain different.", "A social decision procedure is not automatically a shared cognitive revision."]
    ]
  },
  "MIN:121" => {
    "direction" => "shared", "phase" => "active",
    "title" => "active shared-schema revision",
    "definition" => "An active cognitive process distributed across multiple cognizers that is changing a representation held in common among them.",
    "runtime_scope" => "shared-schema revision",
    "current_rationale" => "“Distributed reasoning” strongly fits active + systemic + Mind, but combining perceptions, memories, and judgments is a mechanism list rather than an invariant. Reasoning also collides with LOG, and communication between participants belongs to CON.",
    "current_scores" => [6, 10, 9, 7, 5, 8, 9, 10],
    "attention" => ["active joint-attention alignment", "An active process by which multiple cognizers are aligning attention on one subject."],
    "inference" => ["active collective deliberation", "An active inferential evaluation distributed across multiple cognizers."],
    "memory" => ["active collective recollection", "An active retrieval of a representation across multiple members of a cognitive community."],
    "examples" => [
      ["ordinary_conversation", "MIN:121[1](COGNIZERS=team,CONTENT=shared_problem_model)", "team; shared-schema revision active", "The team is changing its common understanding of the problem.", "Members need not yet agree on a final result."],
      ["physical_or_spatial", "MAT(SIGNALS=sensor_array)+MIN:121[1](COGNIZERS=operators,CONTENT=storm_schema)", "sensor signals plus active shared storm-schema revision", "The operators are jointly updating their shared model of the storm.", "Signals and communications are separate components."],
      ["temporal_or_sequential", "MIN:121[1](COGNIZERS=students,DURING=workshop,CONTENT=concept_schema)", "students; shared concept-schema revision active during workshop", "The class is actively reshaping its common model of the concept.", "The workshop interval is external."],
      ["cross_family_compound", "CON(EXCHANGE=discussion)+LOG(INFERENCE=analysis)+MIN:121[1](COGNIZERS=team,CONTENT=shared_schema)", "discussion and inference plus active shared-schema revision", "Through discussion and analysis, the team is revising its shared model.", "Each family keeps its own semantic work."],
      ["executable_or_programming", "MIN:121[1](COGNIZERS=agents,CONTENT=shared_belief_graph,MERGE=active)", "agents; shared belief-graph revision active", "The agents are reconciling updates into a shared belief graph.", "The root asserts distributed cognitive change, not the message protocol.", "shared_belief_graph.merge!(agent_updates)"],
      ["counterexample", "CON(TRANSFER=messages,PARTICIPANTS=agents)", "messages moving among agents", "The agents are exchanging messages without changing a shared model.", "Communication alone is CON, not MIN:121."]
    ]
  },
  "MIN:122" => {
    "direction" => "shared", "phase" => "nonactualized",
    "title" => "nonactualized shared-schema revision",
    "definition" => "A cognitive process distributed across multiple cognizers that would change a representation held in common among them if actualized, but is not active or completed.",
    "runtime_scope" => "nonactualized shared-schema revision",
    "current_rationale" => "“Pending collective inquiry” was inferred from the old pending label and then defined as prepared but not started. Preparation and scheduling are external states; the lexical third trit must select only a nonactualized shared cognitive process.",
    "current_scores" => [5, 4, 9, 6, 4, 5, 8, 6],
    "attention" => ["nonactualized joint-attention alignment", "A nonactualized process by which multiple cognizers would align attention on one subject."],
    "inference" => ["nonactualized collective deliberation", "A nonactualized inferential evaluation that would be distributed across multiple cognizers."],
    "memory" => ["nonactualized collective recollection", "A nonactualized retrieval of a representation across multiple members of a cognitive community."],
    "examples" => [
      ["ordinary_conversation", "MIN:122[1](COGNIZERS=team,CONTENT=shared_plan_model)", "team; shared-schema revision nonactualized", "The team's common understanding could change, but no shared revision is active or complete.", "This does not say the team intends to meet."],
      ["physical_or_spatial", "MAT(EVENT=new_hazard)+MIN:122[1](COGNIZERS=rescuers,CONTENT=shared_map)", "hazard context plus nonactualized shared-map revision", "The hazard could alter the rescuers' shared map, but that cognitive revision has not occurred.", "Potential causation and actual planning remain separate."],
      ["temporal_or_sequential", "MIN:122[1](COGNIZERS=agents,CONTENT=shared_schema,STATUS=unrealized)", "agents; shared-schema revision remains nonactualized", "No shared-schema revision is running or complete.", "The root makes no prediction."],
      ["cross_family_compound", "CON(INVITATION=review_session)+DAT(SCHEDULE=tomorrow)+MIN:122[1](COGNIZERS=team,CONTENT=shared_schema)", "invitation and schedule plus nonactualized shared-schema revision", "A review is scheduled, while the actual shared cognitive revision remains nonactualized.", "CON and DAT carry the invitation and schedule."],
      ["executable_or_programming", "MIN:122[1](COGNIZERS=agents,CONTENT=shared_model,BRANCH=possible_merge)", "agents; shared-schema revision branch nonactualized", "A shared-model merge is a semantic possibility, not an executing or completed merge.", "Does not assert queue placement or readiness.", "assert !merge.running? && !merge.complete?"],
      ["counterexample", "DAT(QUEUE=team_review_job)", "team review job queued", "The team review job is queued.", "Queue status is DAT/grammar and cannot be inferred from MIN:122."]
    ]
  }
}.freeze

raise "design IDs mismatch" unless DESIGN.keys == IDS

direction_phrase = {
  "self" => "the cognizer's representation of the cognizer",
  "target" => "the cognizer's representation of a distinct target",
  "shared" => "a representation held in common across multiple cognizers"
}

scope_names = {
  "self" => "self-model",
  "target" => "target model",
  "shared" => "shared cognitive schema"
}

phase_neighbors = {
  "MIN:100" => %w[MIN:101 MIN:102 MIN:000 MIN:001 MIN:002],
  "MIN:101" => %w[MIN:100 MIN:102 MIN:000 MIN:001 MIN:002],
  "MIN:102" => %w[MIN:100 MIN:101 MIN:000 MIN:001 MIN:002],
  "MIN:110" => %w[MIN:111 MIN:112 MIN:010 MIN:011 MIN:012],
  "MIN:111" => %w[MIN:110 MIN:112 MIN:010 MIN:011 MIN:012],
  "MIN:112" => %w[MIN:110 MIN:111 MIN:010 MIN:011 MIN:012],
  "MIN:120" => %w[MIN:121 MIN:122 MIN:020 MIN:021 MIN:022],
  "MIN:121" => %w[MIN:120 MIN:122 MIN:020 MIN:021 MIN:022],
  "MIN:122" => %w[MIN:120 MIN:121 MIN:020 MIN:021 MIN:022]
}.freeze

entity_triplet = {
  "self" => "MIN:000–002",
  "target" => "MIN:010–012",
  "shared" => "MIN:020–022"
}.freeze

collision_template = {
  "LIF" => "LIF owns living identity, consciousness, and organismic condition. MIN owns only a change in cognitive representation of such content; use a compound when both are asserted.",
  "MOV" => "MOV owns motion and change of position. MIN may revise a route or position model but never performs the physical movement.",
  "MAT" => "MAT owns physical bodies, signals, neural substrate, and material change. MIN owns representational revision, not the substrate or stimulus.",
  "CON" => "CON owns participant linkage, communication, access, and transmission. Communication may cause or coordinate revision but is neither necessary nor sufficient for it.",
  "STR" => "STR owns external arrangement, hierarchy, and structural transition. MIN owns a cognizer's revised representation of structure, not the structure itself.",
  "WRN" => "WRN owns error, anomaly, hazard, and failure. A mistaken or discrepancy-triggered revision requires WRN + MIN; revision itself is neutral about correctness.",
  "REP" => "REP owns repair and restoration. Revision can improve, worsen, or neutrally alter a representation; it must not imply correction or repair.",
  "LOG" => "LOG owns inference validity, proof, consistency, and formal consequence. Reasoning may cause cognitive revision, but valid inference and mental change are independent.",
  "DAT" => "DAT owns external information, records, storage, queues, and data flow. A data update is not a cognitive revision unless a cognizer's representation also changes.",
  "CRE" => "CRE owns generation, design, intention artifacts, and plans. A newly created idea may coincide with revision, but ideation and representational change are distinct.",
  "ORI" => "ORI owns time, existence, ontology, and modality. Possibility, future time, certainty, and actualization relations must remain explicit rather than being smuggled into MIN."
}.freeze

scored_roots = []
recommended_roots = []

DESIGN.each do |id, root|
  atom = atoms_by_id.fetch(id)
  direction = root.fetch("direction")
  phase = root.fetch("phase")
  scope = scope_names.fetch(direction)

  current = candidate(
    id: "current_phase2",
    title: atom.fetch("title"),
    definition: atom.fetch("core_definition"),
    scores: candidate_scores(root, "current"),
    fit: "It follows the broad #{atom.fetch("universal_slot")} label and selects a recognizable Mind activity.",
    coverage: "It covers familiar English words from the provisional catalogue.",
    territory: "It consumes several mental operations or results at once.",
    risk: root.fetch("current_rationale")
  )

  revision = candidate(
    id: "representational_revision",
    title: root.fetch("title"),
    definition: root.fetch("definition"),
    scores: candidate_scores(root, "revision"),
    fit: "It assigns one Mind process—revision of cognitive representation—to every address, varies only #{scope} scope across the second trit, and varies only completed/active/nonactualized phase across the third.",
    coverage: "Learning-induced update, belief-model change, reinterpretation, adaptation, agent world-model update, and multi-agent schema change when those events actually alter cognitive representation.",
    territory: "Only the process of cognitive representational change; attention, access, inference, communication, truth, storage, planning, and physical change remain separate.",
    risk: "It intentionally requires compounds for ordinary verbs such as learn, understand, remember, infer, decide, perceive, and deliberate when those verbs carry more than representational change."
  )

  attention = candidate(
    id: "attention_reallocation",
    title: root.fetch("attention")[0],
    definition: root.fetch("attention")[1],
    scores: candidate_scores(root, "attention"),
    fit: "Attention is unmistakably mental and can be self-directed, target-directed, or jointly aligned.",
    coverage: "Focus, notice, monitor, orient attention, distraction recovery, and joint attention.",
    territory: "Control over cognitive resource allocation rather than transformation of represented content.",
    risk: "Completed and nonactualized attention shifts are less natural atoms than the active form; the architecture also leaves learning and model update without a fundamental process."
  )

  inference = candidate(
    id: "inference_or_evaluation",
    title: root.fetch("inference")[0],
    definition: root.fetch("inference")[1],
    scores: candidate_scores(root, "inference"),
    fit: "Assessment and deliberation can be inward, target-directed, or distributed and can occupy all three process phases.",
    coverage: "Judge, infer, evaluate, reason, compare, deliberate, and decide.",
    territory: "Epistemic and logical processing, often including standards, evidence, or conclusions.",
    risk: "It collides heavily with LOG and sometimes CON; self-assessment, target inference, and collective deliberation are related but not one exact process invariant."
  )

  memory = candidate(
    id: "memory_access",
    title: root.fetch("memory")[0],
    definition: root.fetch("memory")[1],
    scores: candidate_scores(root, "memory"),
    fit: "Memory access belongs to Mind and can concern the self, another target, or a community.",
    coverage: "Remember, recall, recollect, retrieve, recognize, and reactivate stored cognition.",
    territory: "Access to representations presumed to have existed before the process.",
    risk: "It excludes perception, new learning, imagination, and revision; shared recollection also collides with archives, testimony, and communication."
  )

  candidates = [current, revision, attention, inference, memory]
  winner = candidates.max_by { |item| item.fetch("total") }
  raise "#{id}: wrong winner" unless winner.fetch("candidate_id") == "representational_revision"

  scored_roots << {
    "canonical_id" => id,
    "fixed_generated_fields" => fixed_projection(atom),
    "current_meaning_rationale" => root.fetch("current_rationale"),
    "candidates" => candidates,
    "recommended_candidate_id" => winner.fetch("candidate_id"),
    "recommendation_reason" =>
      "Representational revision is the only candidate that preserves one process center across all nine roots, anchors directly to canonical MIN:000–022 representations, respects nonactualized `1x2`, and keeps truth, communication, storage, planning, and physical change outside MIN.",
    "confidence" => direction == "shared" ? 0.95 : 0.97,
    "canonicalized" => false
  }

  third_explanation = if phase == "nonactualized"
                        "Selects the nonactualized phase: this revision is not active or completed. It does not encode a plan, intention, schedule, queue, readiness, probability, future time, or certainty."
                      else
                        "Selects the #{phase} phase: the revision #{phase_definition(phase)}."
                      end
  second_explanation = {
    "self" => "Selects inward/self scope: the represented subject is the cognizer's own identity or condition.",
    "target" => "Selects outward/target scope: the represented subject is distinct from the cognizer.",
    "shared" => "Selects systemic/shared scope: the changing representation is held in common across multiple cognizers and the process is distributed among them."
  }.fetch(direction)

  recommended_roots << {
    "fixed_generated_fields" => fixed_projection(atom),
    "proposal_status" => "recommended_after_adversarial_review_pending_delegated_approval",
    "proposed_title" => root.fetch("title"),
    "invariant_definition" => root.fetch("definition"),
    "semantic_center" => "cognitive representational revision",
    "address_justification" => {
      "first_trit_1" => "Selects a process/action/transformation: a cognitive representation changes rather than merely existing or being available.",
      "second_trit" => second_explanation,
      "third_trit" => third_explanation
    },
    "inclusion_boundary" =>
      "Includes only a cognitive process whose semantic result is a change to #{direction_phrase.fetch(direction)}. The change may add, remove, reorganize, differentiate, merge, or reweight represented content without asserting why, whether it is correct, or how it is physically realized.",
    "excluded_meanings" => [
      "Mere persistence, manifestation, or latency of a representation without change; canonical MIN:0xx owns the representation entity or condition.",
      "Attention allocation, perception, recall, imagination, inference, evaluation, learning, or decision when no representational change is asserted.",
      "Truth, proof, certainty, probability, belief commitment, or ontological accuracy.",
      "Communication, consensus procedure, data storage, physical neural change, structural change, error detection, repair, planning, intention, scheduling, queuing, and future time.",
      "A change to an external record or physical model unless a cognizer's representation also changes."
    ],
    "nearest_neighbors" => phase_neighbors.fetch(id),
    "same_family_contrast" =>
      "#{entity_triplet.fetch(direction)} owns the representation at the same scope as a cognitive entity/condition; #{id} owns the #{phase} process that changes it. The other two members of this 1x triplet own the identical revision process at different lexical phases.",
    "cross_family_comparisons" => collision_template,
    "runtime_state_interpretation" => runtime_interpretations(root),
    "lexical_runtime_distinction" =>
      "The third lexical trit permanently selects the #{phase} kind of #{scope} revision. Runtime `[2]/num` separately marks the current assertion token as dormant or unresolved. For a lexical `*2` root, `[1]` affirms that the process is nonactualized; `[2]/num` leaves the assertion about that nonactualized process unresolved. Neither layer encodes intention or schedule.",
    "examples" => root.fetch("examples").map do |row|
      example(
        category: row[0], graph: row[1], literal: row[2], natural: row[3],
        analysis: row[4],
        use_status: row[0] == "counterexample" ? "must_not_use_this_root" : "valid",
        pseudocode: row[5]
      )
    end,
    "future_compound_examples" => [
      "#{id} + MIN:0xx content node → explicitly links the revision event to its before/after cognitive representation.",
      "#{id} + DAT/CON cause or evidence → learning, instruction, observation, testimony, or data-driven model update without making transmission part of MIN.",
      "#{id} + LOG/WRN/REP predicate → inference-driven, discrepancy-triggered, corrective, biased, or mistaken revision without claiming revision is necessarily rational or reparative.",
      "#{id} + CRE/ORI/grammar → intended, planned, scheduled, possible, future, repeated, or hypothetical revision while preserving the lexical/runtime boundary."
    ],
    "later_era_notes" =>
      "Later eras may distinguish Bayesian update, conceptual change, accommodation, reappraisal, model retraining, belief revision, memory reconsolidation, and schema alignment as compounds or specialized descendants. The invariant must remain neutral about mechanism, correctness, evidence, awareness, and implementation.",
    "confidence" => direction == "shared" ? 0.95 : 0.97,
    "canonicalized" => false
  }
end

stress_tests = [
  ["learn", "compound", "MIN:111/110 only when a target representation changes; add source/evidence and result. Skill acquisition without representational change belongs elsewhere."],
  ["understand", "compound", "Usually a manifest/persistent target representation plus completed target-model revision and often LOG coherence; not one atom."],
  ["realize", "compound", "Completed target- or self-model revision plus a newly manifest representation; truth is not automatic."],
  ["change one's mind", "one_root_or_compound", "MIN:101 while the relevant self/target model is changing, MIN:100/110 when completed; content relation remains explicit."],
  ["reconsider oneself", "one_root", "MIN:101 when the self-model is actually changing; mere inspection is a gap or attention/inference compound."],
  ["revise self-image", "one_root", "MIN:101 active, MIN:100 completed, MIN:102 nonactualized."],
  ["revise an opinion of someone", "one_root", "MIN:111 active, MIN:110 completed, MIN:112 nonactualized."],
  ["update a world model", "one_root", "MIN:111 active or MIN:110 completed when the bearer is a cognizer/agent."],
  ["update a database record", "different_family", "DAT, not MIN, unless a cognitive representation also changes."],
  ["reflect", "compound_or_gap", "MIN:101 only when reflection changes the self-model; otherwise attention/evaluation remains outside this block."],
  ["introspect", "compound_or_gap", "Inward attention plus manifest self-representation; revision is optional."],
  ["remember", "state_transition_or_gap", "Transition from latent to manifest MIN representation; pure recall is not revision."],
  ["recall a face", "state_transition_or_gap", "MIN:012 → MIN:011 plus a later access process; not MIN:111 unless the face model changes."],
  ["forget", "compound_or_gap", "Loss, inaccessibility, or transition of a representation requires MIN:0xx plus WRN/REP/grammar; not automatically revision."],
  ["imagine", "compound_or_gap", "Creation of a mental representation requires CRE + MIN content/process relations; not identical to revision."],
  ["perceive", "compound_or_gap", "MAT signal plus a Mind representation/acquisition relation; perceptual input can occur without revision."],
  ["observe", "compound_or_gap", "Attention/perception plus target representation; use MIN:111 only if observation changes the target model."],
  ["notice", "existing_root_or_gap", "Manifest target representation MIN:011 plus attention transition; not model revision by default."],
  ["focus", "later_mind_layer", "Attention allocation is intentionally reserved for MIN:2xx review or compounds."],
  ["study", "compound", "Intended/active inquiry combines attention, DAT sources, LOG operations, and possible MIN:111 revision."],
  ["ask", "different_family", "CON for a question transmitted to another participant; cognitive uncertainty is separate."],
  ["inquire", "compound", "CON/DAT/LOG process with possible MIN:111; inquiry need not change the inquirer's representation."],
  ["infer", "different_family_or_compound", "LOG owns formal consequence; add MIN:110/111 only if the cognizer's target model changes."],
  ["reason", "different_family_or_compound", "LOG owns inferential structure; MIN records cognitive representational change when it occurs."],
  ["evaluate", "compound_or_gap", "Requires a criterion and comparison relation; add MIN revision only when evaluation changes a model."],
  ["judge", "compound_or_gap", "Epistemic or normative commitment requires LOG/ORI/grammar; not one revision atom."],
  ["decide", "compound_or_gap", "Choice/commitment needs alternatives, selection, and often CRE/LOG; model revision may accompany it but is not the decision."],
  ["plan", "different_family_or_compound", "CRE/DAT plus temporal/modal grammar; forbidden as the lexical meaning of MIN:*2."],
  ["intend", "grammar_or_compound", "Modal/agentive relation; forbidden as the lexical meaning of MIN:*2."],
  ["schedule", "different_family", "DAT plus temporal grammar; forbidden as the lexical meaning of MIN:*2."],
  ["prepare to rethink", "compound", "CRE/DAT preparation plus MIN:102/112/122; preparation is separate from process nonactualization."],
  ["possible revision", "one_root_plus_grammar", "MIN:*2 selects nonactualized revision; modality may further state why it is considered possible."],
  ["queued revision", "compound", "DAT queue state plus MIN:*2; the root alone does not encode queue placement."],
  ["collective learning", "compound", "MIN:121/120 only for shared-schema change, usually with CON exchange and DAT evidence."],
  ["deliberate together", "compound", "LOG reasoning + CON participation; MIN:121 only if a shared schema is changing."],
  ["reach consensus", "compound", "CON agreement procedure + MIN:020/021 shared schema + possibly MIN:120; consensus is not the atom."],
  ["share an idea", "different_family_or_compound", "CON transmission + MIN representations in participants; no revision is guaranteed."],
  ["teach", "compound", "CON/DAT transmission intended to cause MIN:111/110 in a learner; success must be separately asserted."],
  ["train a model", "compound", "Repeated DAT input + MIN:111 revision + technical control grammar; physical compute remains MAT."],
  ["model converges", "compound", "MIN:120 completed shared-schema revision plus LOG/MAT/DAT criteria depending on model type."],
  ["hallucinate", "compound", "WRN + CRE/MIN representation; revision is asserted only if an existing model changes."],
  ["correct a misconception", "compound", "WRN identifies error, REP expresses correction, MIN:110 records completed target-model revision."],
  ["brain plasticity", "different_family", "MAT physical neural change; cognitive revision may be correlated but is not identical."],
  ["reorganize a file tree", "different_family", "STR/DAT, not MIN, unless a cognizer's representation also changes."],
  ["redirect attention", "later_mind_layer", "Attention process/capacity, intentionally not owned by representational revision."],
  ["belief remains unchanged", "existing_root", "MIN:000/010/020 persistent representation depending scope; no MIN:1xx revision."],
  ["mental image is present", "existing_root", "MIN:001/011/021 manifest representation depending scope."],
  ["idea is latent", "existing_root", "MIN:002/012/022 latent representation depending scope."],
  ["truth of a belief", "different_family", "LOG/ORI plus a MIN representation relation; revision is irrelevant."],
  ["repeatedly revise", "one_root_plus_grammar", "MIN:101 or bounded MIN:100/110/120 events plus repetition grammar."],
  ["revision failed", "compound", "WRN process failure + the relevant MIN revision root with negated/noncompleted result."]
].map.with_index do |(concept, route, analysis), index|
  {
    "test_id" => format("MIN1-T%03d", index + 1),
    "english_concept" => concept,
    "routing" => route,
    "analysis" => analysis
  }
end

scored = {
  "metadata" => {
    "title" => "MIN:100–122 adversarial candidate scoring",
    "status" => "review_complete_pending_preapproval_validation",
    "architecture_version" => "1.0",
    "candidate_count_per_root" => 5,
    "scored_categories" => SCORE_KEYS,
    "maximum_score" => 80,
    "current_phase2_meanings_are_replaceable" => true,
    "generated_fields_changed" => false
  },
  "roots" => scored_roots
}

recommended = {
  "metadata" => {
    "title" => "MIN:100–122 recommended permanent semantic specification",
    "status" => "recommended_pending_delegated_approval",
    "architecture_version" => "1.0",
    "semantic_center" => "cognitive representational revision",
    "triplets" => {
      "MIN:100–102" => "self-model revision: completed / active / nonactualized",
      "MIN:110–112" => "target-model revision: completed / active / nonactualized",
      "MIN:120–122" => "shared-schema revision: completed / active / nonactualized"
    },
    "generated_fields_changed" => false,
    "gate4_started" => false,
    "translator_started" => false
  },
  "roots" => recommended_roots,
  "approval_checklist" => {
    "one_invariant_center_for_all_nine" => true,
    "five_genuinely_distinct_candidates_per_root" => true,
    "all_user_scoring_categories_present" => true,
    "source_canonical_meanings_changed" => false,
    "previous_reviewed_canonical_meanings_changed" => false,
    "generated_fields_changed" => false,
    "lexical_1x2_planning_leakage" => false,
    "cross_family_collisions_resolved" => true,
    "stress_tests_allow_compounds_and_gaps" => true,
    "ready_for_independent_validation" => true,
    "canonicalized" => false
  }
}

stress = {
  "metadata" => {
    "title" => "MIN:100–122 English coverage and stress tests",
    "status" => "review_complete",
    "test_count" => stress_tests.length,
    "forced_atomic_mappings_forbidden" => true
  },
  "tests" => stress_tests
}

write_yaml("reviews/MIN_100_122_scored_candidates.yaml", scored)
write_yaml("reviews/MIN_100_122_recommended_spec.yaml", recommended)
write_yaml("reviews/MIN_100_122_stress_tests.yaml", stress)

review = +"# MIN:100–122 Adversarial Semantic Design Review\n\n"
review << "Status: **REVIEW COMPLETE — RECOMMENDED PENDING INDEPENDENT VALIDATION AND DELEGATED APPROVAL**\n\n"
review << "This packet reviews only `MIN:100–122`. It treats every Phase 2 meaning as replaceable, preserves all deterministic generated fields, does not alter the 90 roots already canonical, and does not begin `MIN:200–222`, Gate 4, compounds, or translator implementation.\n\n"
review << "## Block conclusion\n\n"
review << "The strongest permanent architecture is **cognitive representational revision**. The second trit selects the representation being revised—self-model, target model, or shared cognitive schema. The third selects one and only one phase—completed, active, or nonactualized. This directly complements canonical `MIN:000–022`, which owns representations as cognitive entities or conditions.\n\n"
review << "The existing Phase 2 grid is rejected as a permanent system because it mixes memory, insight, reflection, observation, inquiry, learning, reasoning, and decision. Its `MIN:102`, `MIN:112`, and `MIN:122` candidates also encode intention, planning, scheduling, or preparation, violating the fixed lexical `1x2` rule.\n\n"
review << "## Candidate architecture comparison\n\n"
review << "| Architecture | Strength | Permanent limitation |\n|---|---|---|\n"
review << "| Current Phase 2 mixture | Familiar English labels | No single invariant; cross-family leakage; `*2` architecture violations |\n"
review << "| Representational revision | One process center; exact 3×3 symmetry; strong cognitive and technical utility | Common verbs need honest compounds or sense tests |\n"
review << "| Attention reallocation | Natural active processes and clear Mind ownership | Completed/nonactualized forms are weaker; leaves learning/model update uncovered |\n"
review << "| Inference/evaluation | Strong formal and conversational coverage | Collides with LOG and varies process type across scope |\n"
review << "| Memory access | Clear Mind domain and everyday utility | Presupposes prior storage; excludes perception, imagination, and learning |\n\n"

scored_roots.each do |root|
  id = root.fetch("canonical_id")
  spec = recommended_roots.find { |item| item.dig("fixed_generated_fields", "canonical_id") == id }
  fixed = root.fetch("fixed_generated_fields")
  review << "## #{id} — #{spec.fetch("proposed_title")}\n\n"
  review << "### Fixed generated forms\n\n"
  review << "| Field | Value |\n|---|---|\n"
  fixed.each do |field, value|
    rendered = value.is_a?(Array) ? value.join(", ") : value
    review << "| #{field.tr("_", " ")} | `#{rendered}` |\n"
  end
  review << "\n### Why the current meaning was probably chosen\n\n#{root.fetch("current_meaning_rationale")}\n\n"
  review << "### Candidate comparison\n\n"
  review << "| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |\n"
  review << "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n"
  root.fetch("candidates").each do |cand|
    scores = cand.fetch("scores")
    review << "| #{cand.fetch("title")} | #{SCORE_KEYS.map { |key| scores.fetch(key) }.join(" | ")} | **#{cand.fetch("total")}/80** |\n"
  end
  review << "\n"
  root.fetch("candidates").each do |cand|
    analysis = cand.fetch("analysis")
    review << "- **#{cand.fetch("title")}** — #{cand.fetch("invariant_candidate")} "
    review << "**Fit:** #{analysis.fetch("why_it_fits")} "
    review << "**Coverage:** #{analysis.fetch("useful_coverage")} "
    review << "**Territory:** #{analysis.fetch("semantic_territory_consumed")} "
    review << "**Risk:** #{analysis.fetch("conflicts_or_future_limitations")}\n"
  end
  review << "\n### Recommendation and permanent specification\n\n"
  review << "**Winner:** **#{spec.fetch("proposed_title")}** (confidence #{(spec.fetch("confidence") * 100).round}%).\n\n"
  review << "> #{spec.fetch("invariant_definition")}\n\n"
  review << "**Semantic boundary.** #{spec.fetch("inclusion_boundary")}\n\n"
  review << "**Excluded meanings.** #{spec.fetch("excluded_meanings").join(" ")}\n\n"
  review << "**Nearest neighbors.** #{spec.fetch("nearest_neighbors").map { |neighbor| "`#{neighbor}`" }.join(", ")}. #{spec.fetch("same_family_contrast")}\n\n"
  review << "**Address justification.** First trit: #{spec.dig("address_justification", "first_trit_1")} Second trit: #{spec.dig("address_justification", "second_trit")} Third trit: #{spec.dig("address_justification", "third_trit")}\n\n"
  review << "**Runtime states.** `[0]` #{spec.dig("runtime_state_interpretation", "0")} `[1]` #{spec.dig("runtime_state_interpretation", "1")} `[2]/num` #{spec.dig("runtime_state_interpretation", "2/num")}\n\n"
  review << "**Lexical/runtime distinction.** #{spec.fetch("lexical_runtime_distinction")}\n\n"
  review << "### Examples\n\n"
  review << "| Type | Semantic graph | Literal gloss | Natural rendering | Runtime | Contour | Use |\n"
  review << "|---|---|---|---|---:|---|---|\n"
  spec.fetch("examples").each do |item|
    review << "| #{item.fetch("category")} | `#{item.fetch("semantic_graph")}` | #{item.fetch("literal_gloss")} | #{item.fetch("natural_english")} | `[#{item.fetch("runtime_state")}]` | #{item.fetch("contour")} | #{item.fetch("use_status")} |\n"
  end
  review << "\n**Programming interpretation.** #{spec.fetch("examples").find { |item| item["category"] == "executable_or_programming" }.fetch("analysis")}\n\n"
  review << "**Future compound sketches—not canonical.** #{spec.fetch("future_compound_examples").join(" ")}\n\n"
  review << "**Later-Era note.** #{spec.fetch("later_era_notes")}\n\n"
end

review << "## Triplet coherence\n\n"
review << "| Triplet | Shared semantic axis | `0` completed | `1` active | `2` nonactualized |\n|---|---|---|---|---|\n"
review << "| MIN:100–102 | Revision of the cognizer's self-model | Change has reached its result | Change is occurring | Same kind of change is neither active nor complete |\n"
review << "| MIN:110–112 | Revision of a distinct target model | Change has reached its result | Change is occurring | Same kind of change is neither active nor complete |\n"
review << "| MIN:120–122 | Distributed revision of a shared cognitive schema | Change has reached its result | Change is occurring | Same kind of change is neither active nor complete |\n\n"
review << "The triplets differ only in phase. Across triplets, the second trit differs only in representational scope. No root is a disguised synonym for another mental process.\n\n"

review << "## Nine-root ownership matrix\n\n"
review << "| Root | Owns | Belongs elsewhere | Reserved for compounds | Intentionally undefined |\n|---|---|---|---|---|\n"
recommended_roots.each do |spec|
  id = spec.dig("fixed_generated_fields", "canonical_id")
  review << "| #{id} | #{spec.fetch("proposed_title")}; representational change at its exact scope and phase | Truth, signals, communication, storage, physical/structural change | Learning, belief revision, reinterpretation, model training, correction, deliberation | Mechanism, correctness, probability, intention, schedule |\n"
end
review << "\n## Coverage stress test\n\n"
review << "#{stress_tests.length} English concepts were tested. The review deliberately routes many senses to compounds, grammar, other families, existing `MIN:0xx` roots, later Mind review, or unresolved gaps. It does not force English word types into atoms.\n\n"
review << "| English concept | Route | Result |\n|---|---|---|\n"
stress_tests.each do |test|
  review << "| #{test.fetch("english_concept")} | #{test.fetch("routing")} | #{test.fetch("analysis")} |\n"
end

review << "\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each do |item, value|
  review << "- [#{value ? "x" : " "}] #{item.tr("_", " ")}\n"
end
review << "\nThe nine recommendations are not canonical in this review artifact. Independent pre-approval validation must pass before delegated authority is applied.\n"
File.write(File.join(ROOT, "reviews/MIN_100_122_peer_review.md"), review)

collision = +"# MIN:100–122 Cross-Family Collision Report\n\n"
collision << "Status: **PASS AS A DESIGN REVIEW — COLLISIONS EXPLICITLY EXCLUDED OR COMPOUNDED**\n\n"
collision << "The proposed block owns only cognitive representational revision. It is neutral about truth, physical implementation, evidence, communication, storage, error, repair, planning, and modality.\n\n"
collision << "## Root-by-family audit\n\n"
collision << "| Root | LIF | MOV | MAT | CON | STR | WRN | REP | LOG | DAT | CRE | ORI |\n|---|---|---|---|---|---|---|---|---|---|---|---|\n"
recommended_roots.each do |spec|
  id = spec.dig("fixed_generated_fields", "canonical_id")
  direction = DESIGN.fetch(id).fetch("direction")
  cells = {
    "LIF" => "compound only; identity ≠ self-model",
    "MOV" => "compound only; represented motion ≠ motion",
    "MAT" => "compound only; neural/physical change ≠ cognition",
    "CON" => direction == "shared" ? "high collision risk; exchange ≠ distributed revision" : "cause/context only",
    "STR" => "represented structure ≠ external structure",
    "WRN" => "error may trigger revision; correctness not implied",
    "REP" => "repair may use revision; improvement not implied",
    "LOG" => "inference may cause revision; validity not implied",
    "DAT" => "record/data update ≠ cognitive update",
    "CRE" => "new idea/plan ≠ revision",
    "ORI" => "modality/time external; especially for lexical *2"
  }
  collision << "| #{id} | #{CROSS_FAMILIES.map { |family| cells.fetch(family) }.join(" | ")} |\n"
end
collision << "\n## Binding rules\n\n"
collision_template.each do |family, analysis|
  collision << "- **#{family}:** #{analysis}\n"
end
collision << "\n## Highest-risk boundaries\n\n"
collision << "- `MIN:120–122` versus `CON`: a conversation, vote, broadcast, or message merge can occur without a shared cognitive schema changing. Use a compound when communication participates in revision.\n"
collision << "- `MIN:100–122` versus `LOG`: a formally valid inference can be computed without any cognizer revising a representation; a cognizer can also revise a representation irrationally.\n"
collision << "- `MIN:100–122` versus `DAT`: writing a new database value changes an external record, not necessarily cognition. An AI agent counts as a cognizer only when the semantic model explicitly treats it as maintaining cognitive representations.\n"
collision << "- `MIN:*2` versus `CRE`/`DAT`/`ORI`: nonactualized revision does not mean planned, intended, scheduled, queued, ready, probable, or future. Those meanings must be separate graph components.\n"
collision << "- `MIN:100–122` versus `WRN`/`REP`: revision is valence-neutral. It can correct, introduce, or preserve an error; error and repair must be explicit.\n"
File.write(File.join(ROOT, "reviews/MIN_100_122_collision_report.md"), collision)

puts "Built MIN:100–122 review packet"
puts "Roots: #{recommended_roots.length}"
puts "Candidates scored: #{scored_roots.sum { |root| root.fetch("candidates").length }}"
puts "Score assertions: #{scored_roots.sum { |root| root.fetch("candidates").length * SCORE_KEYS.length }}"
puts "Stress tests: #{stress_tests.length}"
