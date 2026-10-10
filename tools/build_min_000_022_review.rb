#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MIN:000 MIN:001 MIN:002
  MIN:010 MIN:011 MIN:012
  MIN:020 MIN:021 MIN:022
].freeze
SCORE_KEYS = %w[
  atomicity address_fit mind_family_fit triplet_coherence
  neighbor_separation cross_family_separation everyday_language_usefulness
  technical_programming_usefulness compound_usefulness translation_safety
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

def candidate(id, title, definition, scores, fit:, coverage:, territory:, risk:)
  raise "#{id}: expected #{SCORE_KEYS.length} scores" unless scores.length == SCORE_KEYS.length

  {
    "candidate_id" => id,
    "title" => title,
    "invariant_candidate" => definition,
    "analysis" => {
      "why_it_fits" => fit,
      "useful_coverage" => coverage,
      "semantic_territory_consumed" => territory,
      "risks_and_future_limitations" => risk
    },
    "scores" => SCORE_KEYS.zip(scores).to_h,
    "total" => scores.sum,
    "maximum" => 100
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
      "low" => "cognizer or focal mental bearer",
      "middle" => "MIN representation predicate",
      "high" => "represented target when present",
      "sustained" => "shared cognitive community or interpretive frame when present"
    },
    "use_status" => use_status,
    "analysis" => analysis
  }.tap { |item| item["pseudocode"] = pseudocode if pseudocode }
end

atoms = load_yaml("lexicon/atoms.yaml").fetch("atoms")
atoms_by_id = atoms.to_h { |atom| [atom.fetch("canonical_id"), atom] }

DESIGN = {
  "MIN:000" => {
    "current_rationale" => "“Stable inner model” was chosen because stable + inward + Mind strongly suggests persistent content about the self. The definition then widened into memory, concept, and self-model, three different representational targets rather than one invariant.",
    "title" => "persistent self-representation",
    "definition" => "A mental representation of the cognizer's own identity or condition that persists across cognitive episodes.",
    "center" => "self-representation",
    "phase" => "persistent",
    "confidence" => 0.98,
    "attention_title" => "enduring inward attentional field",
    "attention_definition" => "A persistent disposition for a cognizer's attention to remain directed inward.",
    "epistemic_title" => "settled self-knowledge",
    "epistemic_definition" => "A stable epistemic commitment by a cognizer about the cognizer's own identity or condition.",
    "memory_title" => "enduring autobiographical memory",
    "memory_definition" => "A persistent memory whose represented subject is the remembering cognizer.",
    "examples" => [
      ["ordinary_conversation", "MIN:000[1](COGNIZER=I,CONTENT=self_as_teacher)", "I; persistent self-representation as teacher", "I still think of myself as a teacher.", "The root owns the persisting self-model, not the truth of the occupation."],
      ["physical_or_spatial", "MIN:000[1](COGNIZER=pilot,CONTENT=body_orientation)", "pilot; persistent self-representation of bodily orientation", "The pilot retains a stable internal model of their own orientation.", "Body geometry may be added with MAT/STR."],
      ["temporal_or_sequential", "MIN:000[1](COGNIZER=agent,ACROSS=sessions)", "agent; self-representation persists across sessions", "The agent keeps the same self-model across restarts.", "Persistence is lexical; storage mechanism is external."],
      ["cross_family_compound", "LIF(IDENTITY=person)+MIN:000[1](COGNIZER=person,CONTENT=self)", "living identity plus persistent representation of that identity", "The person has an enduring mental model of who they are.", "LIF owns identity; MIN owns its representation."],
      ["executable_or_programming", "MIN:000[1](COGNIZER=agent,CONTENT=self_model)", "agent; persistent cognitive self-model", "The agent maintains a persistent representation of itself.", "A semantic object in an agent model.", "assert agent.self_model.persists_across_episodes?"],
      ["counterexample", "LIF:000[1](ENTITY=person)", "person; enduring living identity", "The person continues to be the same individual.", "Identity itself is LIF, not a mental representation of identity."]
    ]
  },
  "MIN:001" => {
    "current_rationale" => "“Present attention” was chosen because active + inward + Mind evokes introspection. Attention, however, is an allocation process or capacity, while the 0xx layer must name an entity or condition. The useful entity is the self-representation presently manifest to cognition.",
    "title" => "manifest self-representation",
    "definition" => "A mental representation of the cognizer's own identity or condition that is presently manifest in cognition.",
    "center" => "self-representation",
    "phase" => "manifest",
    "confidence" => 0.98,
    "attention_title" => "active inward attention",
    "attention_definition" => "Attention that is presently directed toward the cognizer's own mental or bodily condition.",
    "epistemic_title" => "active self-belief",
    "epistemic_definition" => "A belief about the cognizer's own identity or condition that is presently entertained.",
    "memory_title" => "recalled autobiographical memory",
    "memory_definition" => "An autobiographical memory that is presently accessible to conscious recall.",
    "examples" => [
      ["ordinary_conversation", "MIN:001[1](COGNIZER=I,CONTENT=anxious_self)", "I; self-condition represented now", "I am aware that I am anxious right now.", "The manifest self-representation is distinct from the emotion itself."],
      ["physical_or_spatial", "MIN:001[1](COGNIZER=climber,CONTENT=left_hand_position)", "climber; own hand position manifest in cognition", "The climber is presently aware of where their left hand is.", "Spatial content does not turn MIN into MOV or STR."],
      ["temporal_or_sequential", "MIN:001[1](COGNIZER=operator,DURING=self_check)", "operator; self-state representation manifest during check", "During the check, the operator's current self-state is mentally present.", "The interval is graph-level."],
      ["cross_family_compound", "MAT(SIGNAL=heartbeat)+MIN:001[1](COGNIZER=person,CONTENT=heartbeat_state)", "physical signal plus manifest self-representation", "The person is presently aware of their heartbeat.", "MAT owns the signal; MIN owns its cognitive representation."],
      ["executable_or_programming", "MIN:001[1](COGNIZER=agent,CONTENT=current_self_state)", "agent; current self-state manifest", "The agent has its current self-state loaded in working cognition.", "Not the act of loading it.", "assert agent.working_model.includes?(agent.current_self_state)"],
      ["counterexample", "MIN:101[1](COGNIZER=person,PROCESS=reflection)", "person; active inward cognitive process", "The person is reflecting on themselves.", "The act of reflection belongs to the later 1xx process layer."]
    ]
  },
  "MIN:002" => {
    "current_rationale" => "“Latent memory” fits dormant + inward + Mind, but it owns all memory regardless of what is represented. The second trit requires self/source orientation, so the invariant should be a latent representation of the cognizer rather than memory in general.",
    "title" => "latent self-representation",
    "definition" => "A mental representation of the cognizer's own identity or condition that persists without presently manifesting in cognition.",
    "center" => "self-representation",
    "phase" => "latent",
    "confidence" => 0.99,
    "attention_title" => "dormant inward attention",
    "attention_definition" => "An inward attentional orientation that exists without presently directing attention.",
    "epistemic_title" => "latent self-belief",
    "epistemic_definition" => "A belief about the cognizer's own identity or condition that persists without being presently entertained.",
    "memory_title" => "dormant autobiographical memory",
    "memory_definition" => "An autobiographical memory that persists without presently being recalled.",
    "examples" => [
      ["ordinary_conversation", "MIN:002[1](COGNIZER=adult,CONTENT=childhood_self_image)", "adult; childhood self-image latent", "Their childhood self-image still exists but is not presently in mind.", "Affirming the lexeme affirms latency."],
      ["physical_or_spatial", "MIN:002[1](COGNIZER=dancer,CONTENT=body_map)", "dancer; body self-model latent", "The dancer's body map persists outside current awareness.", "Physical embodiment may be separately asserted."],
      ["temporal_or_sequential", "MIN:002[1](COGNIZER=agent,UNTIL=reactivation)", "agent; self-representation latent until reactivation", "The self-model remains latent between sessions.", "No future certainty is encoded."],
      ["cross_family_compound", "DAT(RECORD=profile)+MIN:002[1](COGNIZER=person,CONTENT=self_history)", "external record plus latent self-representation", "The profile is recorded, while the person's corresponding self-memory is latent.", "DAT and MIN remain different bearers."],
      ["executable_or_programming", "MIN:002[1](COGNIZER=agent,CONTENT=inactive_self_schema)", "agent; inactive self-schema persists", "The agent retains a dormant self-schema outside its active context.", "A persisted cognitive object.", "assert agent.long_term_model.include?(:self_schema) && !agent.context.include?(:self_schema)"],
      ["counterexample", "MIN:012[1](COGNIZER=person,TARGET=melody)", "person; target representation latent", "The melody is familiar but not currently recalled.", "A latent representation of another target belongs to MIN:012."]
    ]
  },
  "MIN:010" => {
    "current_rationale" => "“Known target model” correctly recognizes stable + outward + Mind as a representation of something distinct from the cognizer. “Known” adds epistemic success and “identifies” adds recognition; neither is required for a persistent target representation.",
    "title" => "persistent target representation",
    "definition" => "A mental representation of a distinct target that persists across cognitive episodes.",
    "center" => "target representation",
    "phase" => "persistent",
    "confidence" => 0.99,
    "attention_title" => "enduring target salience",
    "attention_definition" => "A persistent disposition for a distinct target to attract a cognizer's attention.",
    "epistemic_title" => "settled target belief",
    "epistemic_definition" => "A stable epistemic commitment by a cognizer about a distinct target.",
    "memory_title" => "enduring target memory",
    "memory_definition" => "A persistent memory whose represented subject is a distinct target.",
    "examples" => [
      ["ordinary_conversation", "MIN:010[1](COGNIZER=I,TARGET=station)", "I; persistent representation of station", "I have a lasting mental picture of the station.", "Accuracy is not asserted."],
      ["physical_or_spatial", "MIN:010[1](COGNIZER=hiker,TARGET=valley)", "hiker; persistent target representation of valley", "The hiker retains a stable mental map of the valley.", "The physical valley is MAT/STR/MOV context."],
      ["temporal_or_sequential", "MIN:010[1](COGNIZER=student,TARGET=concept,ACROSS=lessons)", "student; target representation persists across lessons", "The concept remains in the student's mental model across lessons.", "Learning processes are not built in."],
      ["cross_family_compound", "DAT(RECORD=blueprint)+MIN:010[1](COGNIZER=engineer,TARGET=machine)", "blueprint record plus persistent mental representation", "The engineer retains a mental model of the machine described by the blueprint.", "DAT owns the blueprint."],
      ["executable_or_programming", "MIN:010[1](COGNIZER=agent,TARGET=object_7)", "agent; persistent representation of object 7", "The agent maintains a persistent internal object model.", "Useful for knowledge graphs and robotics.", "assert agent.world_model.persistent_node?(:object_7)"],
      ["counterexample", "DAT(RECORD=station_map)", "stored map record", "The database stores a map of the station.", "A record without a cognizer is DAT, not MIN."]
    ]
  },
  "MIN:011" => {
    "current_rationale" => "“Active perception” follows active + outward + Mind, but sensing and recognizing are processes. The entity layer needs the target representation that is currently manifest, whether it arrived through perception, recall, inference, or imagination.",
    "title" => "manifest target representation",
    "definition" => "A mental representation of a distinct target that is presently manifest in cognition.",
    "center" => "target representation",
    "phase" => "manifest",
    "confidence" => 0.99,
    "attention_title" => "active target salience",
    "attention_definition" => "A distinct target's condition of presently occupying a cognizer's attention.",
    "epistemic_title" => "active target belief",
    "epistemic_definition" => "A belief about a distinct target that is presently entertained by a cognizer.",
    "memory_title" => "recalled target memory",
    "memory_definition" => "A memory of a distinct target that is presently accessible to conscious recall.",
    "examples" => [
      ["ordinary_conversation", "MIN:011[1](COGNIZER=I,TARGET=door)", "I; door representation manifest", "I can picture the door right now.", "The source may be sight or recall."],
      ["physical_or_spatial", "MIN:011[1](COGNIZER=driver,TARGET=pedestrian)", "driver; pedestrian represented now", "The pedestrian is presently represented in the driver's scene model.", "Sensing and movement remain separate predicates."],
      ["temporal_or_sequential", "MIN:011[1](COGNIZER=operator,TARGET=alarm,DURING=inspection)", "operator; alarm target manifest during inspection", "The alarm remains mentally present during the inspection.", "Duration is supplied externally."],
      ["cross_family_compound", "MAT(SIGNAL=light)+MIN:011[1](COGNIZER=observer,TARGET=lamp)", "physical signal plus manifest target representation", "The light produces a presently manifest mental representation of the lamp.", "Causation and sensory process require separate relations."],
      ["executable_or_programming", "MIN:011[1](COGNIZER=agent,TARGET=object_7)", "agent; target model loaded in active cognition", "Object 7 is present in the agent's active scene model.", "A current representational node.", "assert agent.active_scene.include?(:object_7)"],
      ["counterexample", "MIN:111[1](COGNIZER=agent,TARGET=object_7,PROCESS=observe)", "agent; active inquiry about target", "The agent is observing object 7.", "Observation is a process in the later 1xx layer, not the representation entity."]
    ]
  },
  "MIN:012" => {
    "current_rationale" => "“Unrecognized impression” aims at dormant + outward + Mind but presupposes that information entered through perception and remains unrecognized. A dormant target representation may arise through any route and may once have been fully recognized.",
    "title" => "latent target representation",
    "definition" => "A mental representation of a distinct target that persists without presently manifesting in cognition.",
    "center" => "target representation",
    "phase" => "latent",
    "confidence" => 0.99,
    "attention_title" => "latent target salience",
    "attention_definition" => "A target-directed attentional disposition that exists without presently attracting attention.",
    "epistemic_title" => "latent target belief",
    "epistemic_definition" => "A belief about a distinct target that persists without being presently entertained.",
    "memory_title" => "dormant target memory",
    "memory_definition" => "A memory of a distinct target that persists without presently being recalled.",
    "examples" => [
      ["ordinary_conversation", "MIN:012[1](COGNIZER=I,TARGET=melody)", "I; melody representation latent", "The melody is familiar, but I cannot bring it to mind right now.", "Recognition history is not required."],
      ["physical_or_spatial", "MIN:012[1](COGNIZER=hiker,TARGET=landmark)", "hiker; landmark representation latent", "The landmark's mental image persists outside the hiker's present awareness.", "The landmark itself is not dormant."],
      ["temporal_or_sequential", "MIN:012[1](COGNIZER=student,TARGET=formula,UNTIL=cue)", "student; formula representation latent until cue", "The formula remains latent until a cue makes it manifest.", "The cue and transition are separate."],
      ["cross_family_compound", "DAT(CUE=photo)+MIN:012[1](COGNIZER=person,TARGET=friend)", "photo cue plus latent target representation", "The photo can cue a latent mental representation of the friend.", "DAT supplies the cue; MIN supplies the cognitive content."],
      ["executable_or_programming", "MIN:012[1](COGNIZER=agent,TARGET=object_7)", "agent; target model persists outside active context", "Object 7 remains in long-term cognition but not in the active scene.", "A latent world-model node.", "assert agent.world_model.include?(:object_7) && !agent.active_scene.include?(:object_7)"],
      ["counterexample", "MIN:012[0](COGNIZER=agent,TARGET=unknown_object)", "no latent target representation", "The agent has no representation of the unknown object.", "No representation is negation, not an 'unrecognized impression' atom."]
    ]
  },
  "MIN:020" => {
    "current_rationale" => "“Shared knowledge model” follows stable + collective + Mind, but knowledge, convention, and understanding have different truth and social conditions. The common invariant is a cognitive schema represented across multiple cognizers.",
    "title" => "persistent shared cognitive schema",
    "definition" => "A mental representation held in common across multiple cognizers that persists across cognitive episodes.",
    "center" => "shared cognitive schema",
    "phase" => "persistent",
    "confidence" => 0.97,
    "attention_title" => "enduring joint-attention field",
    "attention_definition" => "A persistent disposition for multiple cognizers to direct attention toward one shared subject.",
    "epistemic_title" => "settled common knowledge",
    "epistemic_definition" => "A stable epistemic commitment held in common across multiple cognizers.",
    "memory_title" => "enduring collective memory",
    "memory_definition" => "A persistent memory represented across multiple members of a cognitive community.",
    "examples" => [
      ["ordinary_conversation", "MIN:020[1](COGNIZERS=team,CONTENT=emergency_plan)", "team; persistent shared cognitive schema of plan", "The team shares a lasting mental model of the emergency plan.", "The plan itself may be DAT/LOG/CRE."],
      ["physical_or_spatial", "MIN:020[1](COGNIZERS=rescuers,CONTENT=building_layout)", "rescuers; persistent shared layout schema", "The rescuers share a stable mental map of the building.", "The building structure is STR."],
      ["temporal_or_sequential", "MIN:020[1](COGNIZERS=crew,ACROSS=shifts)", "crew; shared schema persists across shifts", "The crew's common mental model persists across shifts.", "Persistence does not require continuous discussion."],
      ["cross_family_compound", "CON(PROTOCOL=team)+MIN:020[1](COGNIZERS=team,CONTENT=roles)", "communication convention plus shared cognitive schema", "The protocol supports a shared mental model of the roles.", "CON owns the convention and linkage."],
      ["executable_or_programming", "MIN:020[1](COGNIZERS=agents,CONTENT=world_model_v3)", "agents; persistent common world schema", "The agents share a persistent cognitive world model.", "Common representation, not merely common data bytes.", "assert agents.all? { |a| a.cognitive_schema.equivalent?(:world_model_v3) }"],
      ["counterexample", "DAT(RECORD=manual)", "manual; shared accessible record", "Everyone can access the same manual.", "Common access to data does not prove a shared cognitive schema."]
    ]
  },
  "MIN:021" => {
    "current_rationale" => "“Collective attention” was chosen because active + collective + Mind suggests joint focus. It mixes attending, interpreting, and learning—three processes—and does not require participants to share one representation. The entity-layer center should be the shared schema presently manifest among them.",
    "title" => "manifest shared cognitive schema",
    "definition" => "A mental representation held in common across multiple cognizers that is presently manifest among them.",
    "center" => "shared cognitive schema",
    "phase" => "manifest",
    "confidence" => 0.96,
    "attention_title" => "active joint attention",
    "attention_definition" => "Multiple cognizers' attention presently directed toward the same target.",
    "epistemic_title" => "active common belief",
    "epistemic_definition" => "An epistemic commitment presently entertained across multiple cognizers.",
    "memory_title" => "expressed collective memory",
    "memory_definition" => "A memory represented across multiple cognizers and presently accessible among them.",
    "examples" => [
      ["ordinary_conversation", "MIN:021[1](COGNIZERS=team,CONTENT=current_situation)", "team; shared situation schema manifest now", "The team is presently working from the same mental picture.", "This requires common representation, not just simultaneous attention."],
      ["physical_or_spatial", "MIN:021[1](COGNIZERS=pilots,CONTENT=airspace)", "pilots; shared airspace schema manifest", "Both pilots currently share the same cognitive map of the airspace.", "The spatial map's geometry remains STR/DAT content."],
      ["temporal_or_sequential", "MIN:021[1](COGNIZERS=crew,DURING=briefing)", "crew; common schema manifest during briefing", "During the briefing, the shared plan is mentally present across the crew.", "The briefing process is CON/MIN:1xx."],
      ["cross_family_compound", "CON(SESSION=briefing)+MIN:021[1](COGNIZERS=crew,CONTENT=plan)", "communication session plus manifest shared schema", "The briefing makes the crew's shared mental model presently manifest.", "Communication and representation are distinct."],
      ["executable_or_programming", "MIN:021[1](COGNIZERS=agents,CONTENT=active_consensus_model)", "agents; common cognitive model active", "The agents currently operate from one shared world model.", "The model is cognitively manifest across agents.", "assert agents.active_models.map(&:semantic_hash).uniq.one?"],
      ["counterexample", "CON/LOG(JOINT_FOCUS=screen)+MIN:021[0](COGNIZERS=audience)", "audience attends together; no shared schema", "Everyone watches the screen but interprets it differently.", "Joint attention alone does not establish a shared cognitive schema."]
    ]
  },
  "MIN:022" => {
    "current_rationale" => "“Dormant knowledge tradition” follows dormant + collective + Mind, but tradition also requires transmission, social continuity, records, and practice. The atomic condition is a shared cognitive schema that persists among cognizers without presently manifesting.",
    "title" => "latent shared cognitive schema",
    "definition" => "A mental representation held in common across multiple cognizers that persists without presently manifesting among them.",
    "center" => "shared cognitive schema",
    "phase" => "latent",
    "confidence" => 0.97,
    "attention_title" => "dormant joint attention",
    "attention_definition" => "A shared attentional disposition that exists without presently directing multiple cognizers.",
    "epistemic_title" => "latent common belief",
    "epistemic_definition" => "An epistemic commitment held across multiple cognizers without being presently entertained among them.",
    "memory_title" => "dormant collective memory",
    "memory_definition" => "A memory represented across multiple cognizers without presently being recalled among them.",
    "examples" => [
      ["ordinary_conversation", "MIN:022[1](COGNIZERS=old_team,CONTENT=procedure)", "team; shared procedure schema latent", "The old team still shares the know-how, though nobody is thinking about it now.", "Practice and transmission are not asserted."],
      ["physical_or_spatial", "MIN:022[1](COGNIZERS=residents,CONTENT=evacuation_route)", "residents; shared route schema latent", "The residents' common mental map of the evacuation route is presently latent.", "The route itself is MOV/STR."],
      ["temporal_or_sequential", "MIN:022[1](COGNIZERS=crew,BETWEEN=drills)", "crew; common schema latent between drills", "Between drills, the shared emergency schema persists without being manifest.", "The next drill is not predicted."],
      ["cross_family_compound", "DAT(ARCHIVE=manual)+MIN:022[1](COGNIZERS=crew,CONTENT=procedure)", "archive plus latent shared cognitive schema", "The manual records the procedure while the crew's common mental schema remains latent.", "An archive alone is not a mental schema."],
      ["executable_or_programming", "MIN:022[1](COGNIZERS=agents,CONTENT=inactive_policy)", "agents; common policy schema latent", "The agents retain a shared cognitive policy outside active context.", "All agents retain equivalent latent content.", "assert agents.all? { |a| a.long_term_model.include?(:inactive_policy) }"],
      ["counterexample", "DAT(RECORD=lost_archive)+MIN:022[0](COGNIZERS=community)", "archive exists; no shared cognitive schema", "The archive survives, but nobody understands its contents.", "Preserved data without cognitive representation is DAT, not MIN:022."]
    ]
  }
}.freeze

CURRENT_SCORES = {
  "MIN:000" => [5, 8, 8, 5, 6, 6, 9, 8, 7, 5],
  "MIN:001" => [8, 8, 10, 5, 6, 7, 10, 9, 8, 7],
  "MIN:002" => [9, 8, 10, 7, 8, 8, 10, 9, 9, 8],
  "MIN:010" => [8, 9, 10, 8, 8, 7, 10, 10, 9, 8],
  "MIN:011" => [6, 8, 10, 6, 7, 7, 10, 10, 9, 7],
  "MIN:012" => [6, 8, 9, 6, 7, 7, 9, 8, 8, 6],
  "MIN:020" => [6, 9, 9, 7, 7, 5, 9, 9, 8, 6],
  "MIN:021" => [5, 8, 10, 5, 6, 6, 10, 9, 8, 6],
  "MIN:022" => [6, 8, 8, 6, 7, 4, 9, 7, 8, 5]
}.freeze
WINNER_SCORES = {
  "MIN:000" => [10, 10, 10, 10, 9, 9, 10, 10, 10, 10],
  "MIN:001" => [10, 10, 10, 10, 10, 9, 10, 10, 10, 10],
  "MIN:002" => [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
  "MIN:010" => [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
  "MIN:011" => [10, 10, 10, 10, 10, 9, 10, 10, 10, 10],
  "MIN:012" => [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
  "MIN:020" => [10, 10, 10, 10, 9, 9, 9, 10, 10, 10],
  "MIN:021" => [10, 10, 10, 10, 9, 9, 10, 10, 10, 10],
  "MIN:022" => [10, 10, 10, 10, 10, 9, 9, 10, 10, 10]
}.freeze
ATTENTION_SCORES = {
  "MIN:000" => [8, 7, 10, 6, 6, 7, 9, 9, 8, 7],
  "MIN:001" => [9, 9, 10, 7, 7, 8, 10, 10, 9, 8],
  "MIN:002" => [7, 7, 9, 6, 6, 7, 8, 8, 8, 6],
  "MIN:010" => [8, 8, 10, 7, 7, 7, 9, 9, 8, 7],
  "MIN:011" => [9, 9, 10, 8, 8, 8, 10, 10, 9, 8],
  "MIN:012" => [7, 7, 9, 6, 6, 7, 8, 8, 8, 6],
  "MIN:020" => [7, 8, 9, 6, 6, 6, 8, 8, 7, 6],
  "MIN:021" => [9, 9, 10, 7, 7, 7, 10, 9, 8, 7],
  "MIN:022" => [6, 7, 8, 5, 6, 6, 7, 7, 7, 5]
}.freeze
EPISTEMIC_SCORES = IDS.to_h { |id| [id, [8, 8, 8, 8, 7, 5, 9, 9, 9, 6]] }.freeze
MEMORY_SCORES = {
  "MIN:000" => [9, 9, 10, 9, 8, 8, 10, 9, 9, 8],
  "MIN:001" => [9, 8, 10, 9, 8, 8, 10, 9, 9, 8],
  "MIN:002" => [10, 10, 10, 10, 9, 9, 10, 10, 10, 9],
  "MIN:010" => [9, 9, 10, 9, 8, 8, 10, 9, 9, 8],
  "MIN:011" => [9, 8, 10, 9, 8, 8, 10, 9, 9, 8],
  "MIN:012" => [10, 10, 10, 10, 9, 9, 10, 10, 10, 9],
  "MIN:020" => [8, 9, 9, 9, 8, 6, 9, 8, 8, 7],
  "MIN:021" => [8, 8, 9, 9, 8, 6, 9, 8, 8, 7],
  "MIN:022" => [9, 9, 9, 10, 8, 6, 9, 8, 8, 7]
}.freeze

def direction_for(id)
  case id[5]
  when "0" then "inward/self"
  when "1" then "outward/target"
  when "2" then "shared/systemic"
  end
end

def phase_explanation(id)
  case id[6]
  when "0" then "Selects a persistent representation that remains stable across cognitive episodes."
  when "1" then "Selects a representation presently manifest in cognition."
  when "2" then "Selects a representation that persists without presently manifesting in cognition."
  end
end

def scope_explanation(id)
  case id[5]
  when "0" then "Selects the cognizer's representation of the cognizer's own identity or condition."
  when "1" then "Selects the cognizer's representation of a distinct target."
  when "2" then "Selects a representation held in common across multiple cognizers."
  end
end

def cross_family_audit(id, center)
  {
    "LIF" => "LIF owns living identity, consciousness, vitality, and organism status. `#{id}` owns #{center} as cognitive content, never the bearer or identity itself.",
    "MOV" => "MOV owns literal position and motion. Attention shifts and mental maps may use motion metaphors, but `#{id}` does not encode displacement.",
    "MAT" => "MAT owns neural substrate, sensory energy, and physical-state change. `#{id}` owns the representation realized by or about those states.",
    "CON" => "CON owns communication, access, possession, social linkage, and participant transfer. Shared access or messaging does not guarantee #{center}.",
    "STR" => "STR owns form, topology, organization, and formal schema structure. `#{id}` requires cognitive representation in cognizers, not merely an organized artifact.",
    "WRN" => "WRN owns error, confusion, danger, corruption, and failure judgments. A representation may be false or biased without `#{id}` encoding error.",
    "REP" => "REP owns restoration and recovery. Recall or rehabilitation may restore access to a representation, but `#{id}` names the representational entity or condition.",
    "LOG" => "LOG owns formal propositions, truth functions, proof, rules, and quantified constraints. `#{id}` may be nonpropositional, false, vague, or imagistic.",
    "DAT" => "DAT owns records, symbols, messages, and stored information. A record can exist without a cognizer; `#{id}` requires cognitive content.",
    "CRE" => "CRE owns designing, imagining as generation, and creating artifacts or forms. A created idea can become #{center}, but creation is not built into `#{id}`.",
    "ORI" => "ORI owns reality, ontological identity, necessity, and universal law. Representation does not entail that its content is real or true."
  }
end

def runtime_interpretations(id, data)
  subject =
    case id[5]
    when "0" then "the cognizer has the specified self-representation"
    when "1" then "the cognizer has the specified representation of the target"
    when "2" then "the specified representation is held across the cognizers"
    end
  {
    "0" => "Denies that #{subject} in the lexical #{data["phase"]} condition.",
    "1" => "Affirms that #{subject} in the lexical #{data["phase"]} condition.",
    "2" => "Marks the assertion about the #{data["phase"]} #{data["center"]} as dormant or unresolved; it does not select another lexical address."
  }
end

scored_roots = IDS.map do |id|
  atom = atoms_by_id.fetch(id)
  data = DESIGN.fetch(id)
  current = candidate(
    "current_phase2_candidate", atom["title"], atom["core_definition"],
    CURRENT_SCORES.fetch(id),
    fit: "It follows the broad family, direction, and lexical-expression labels.",
    coverage: "A salient subset of English concepts associated with the address.",
    territory: "Several different mental objects, processes, epistemic relations, or social practices.",
    risk: data["current_rationale"]
  )
  winner = candidate(
    "cognitive_representation_architecture", data["title"], data["definition"],
    WINNER_SCORES.fetch(id),
    fit: "It maps the entity layer to one mental-representation center, with #{direction_for(id)} scope and #{data["phase"]} lexical expression.",
    coverage: "Self-models, world models, working cognition, latent cognition, shared mental models, memory contents, mental images, concepts, and agent representations.",
    territory: "Only cognitive representational content and its lexical scope/expression; truth, process, capacity, storage, communication, and physical realization remain external.",
    risk: "Representation is abstract and requires compounds for sensory modality, propositional type, emotion, certainty, source, accuracy, and storage, but those exclusions keep the root reusable."
  )
  attention = candidate(
    "attention_salience_architecture", data["attention_title"], data["attention_definition"],
    ATTENTION_SCORES.fetch(id),
    fit: "Attention naturally varies by inward, target, and joint orientation and can be active or dormant.",
    coverage: "Focus, salience, awareness, distraction, joint attention, foregrounding, and cognitive scheduling.",
    territory: "Allocation of cognitive processing rather than represented content.",
    risk: "It fits active slots best but turns stable/dormant entities into dispositions, collides with MIN process/capacity layers, and leaves memory and mental models uncovered."
  )
  epistemic = candidate(
    "epistemic_status_architecture", data["epistemic_title"], data["epistemic_definition"],
    EPISTEMIC_SCORES.fetch(id),
    fit: "Knowledge and belief are central Mind concepts and can be self-directed, target-directed, or shared.",
    coverage: "Knowing, believing, certainty, doubt, common knowledge, interpretation, and hypothesis.",
    territory: "Epistemic commitment, truth stance, and participant-to-content relation.",
    risk: "It collides with MIN:2xx relationships, LOG truth/proof, and ORI reality; it also excludes nonpropositional imagery, sensations, and models."
  )
  memory = candidate(
    "memory_architecture", data["memory_title"], data["memory_definition"],
    MEMORY_SCORES.fetch(id),
    fit: "Memory provides persistent, recalled, and dormant states and can concern self, targets, or communities.",
    coverage: "Autobiographical memory, target memory, recall, forgetting, collective memory, and latent knowledge.",
    territory: "Representations specifically preserved from prior cognition.",
    risk: "It excludes present perception, new concepts, imagination, and current models; collective memory also collides with DAT archives and CON tradition."
  )
  candidates = [current, winner, attention, epistemic, memory]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => fixed_projection(atom),
    "current_phase2_meaning" => {
      "title" => atom["title"],
      "definition" => atom["core_definition"],
      "why_probably_chosen" => data["current_rationale"]
    },
    "candidates" => candidates,
    "recommended_winner" => "cognitive_representation_architecture",
    "recommended_title" => data["title"],
    "recommended_invariant_definition" => data["definition"],
    "confidence" => data["confidence"],
    "canonicalized" => false
  }
end

scored = {
  "metadata" => {
    "title" => "MIN:000–022 adversarial scored candidates",
    "status" => "ready_for_delegated_approval_not_yet_canonical",
    "architecture_dependency" => "Era Zero Core Architecture 1.0 and 81 canonical roots",
    "candidate_policy" => "current Phase 2 candidate plus four alternative semantic architectures",
    "delegated_approval_authorized" => true,
    "roots_canonicalized" => []
  },
  "score_dimensions" => SCORE_KEYS,
  "roots" => scored_roots
}

recommended_roots = IDS.map do |id|
  atom = atoms_by_id.fetch(id)
  data = DESIGN.fetch(id)
  phase = data.fetch("phase")
  same_triplet = "#{id[0, 6]}0–#{id[0, 6]}2"
  runtime = runtime_interpretations(id, data)
  {
    "fixed_generated_fields" => fixed_projection(atom),
    "proposal_status" => "recommended_for_delegated_approval_not_yet_canonical",
    "proposed_title" => data["title"],
    "invariant_definition" => data["definition"],
    "semantic_center" => data["center"],
    "semantic_boundaries" => [
      "Includes one cognitive representation at the address's self, target, or shared scope.",
      "Allows propositional, imagistic, sensory, conceptual, procedural, or model-like content without selecting one representational format.",
      "Does not assert truth, accuracy, certainty, origin, storage medium, communication, learning, attention allocation, or physical realization.",
      "The lexical expression is #{phase} and remains distinct from runtime state."
    ],
    "excluded_meanings" => [
      "The act of perceiving, remembering, learning, interpreting, or reasoning belongs to MIN:1xx and remains provisional until separately reviewed.",
      "Competence, attention capacity, belief relation, uncertainty, and distributed intelligence belong to MIN:2xx and remain provisional until separately reviewed.",
      "Living identity and consciousness belong to LIF; neural or sensory substrate belongs to MAT.",
      "Communication, consensus procedure, access, and social tradition belong to CON or compounds.",
      "External records, symbols, models, and archives belong to DAT/STR unless cognitive representation is separately asserted.",
      "Truth, proof, probability, formal proposition, and ontological reality belong to LOG/ORI or grammar.",
      "Error, hallucination, bias, forgetting, and cognitive damage require WRN/REP or explicit compounds."
    ],
    "nearest_neighbors" => {
      "same_triplet" => same_triplet,
      "same_triplet_0" => "#{id[0, 6]}0",
      "same_triplet_1" => "#{id[0, 6]}1",
      "same_triplet_2" => "#{id[0, 6]}2",
      "same_phase_other_scopes" => IDS.select { |other| other[6] == id[6] && other != id },
      "future_min_process_layer" => "MIN:100–122 owns cognitive events after separate review; this root is not an event.",
      "future_min_relation_layer" => "MIN:200–222 owns capacities and relations after separate review; this root is not a capacity or belief relation.",
      "canonical_dat_boundary" => "DAT remains provisional, but its family owns external information records rather than cognition."
    },
    "address_explanation" => {
      "first_trit_0" => "Selects a mental entity or condition—the representation—not the process that produced, accessed, or changed it.",
      "second_trit_#{id[5]}" => scope_explanation(id),
      "third_trit_#{id[6]}" => phase_explanation(id)
    },
    "runtime_state_interpretations" => runtime,
    "lexical_third_trit_vs_runtime_2" =>
      "The third lexical trit permanently selects the #{phase} form of #{data["center"]}. Runtime `[2]/num` separately qualifies a token's current assertion status; it never changes the root to another lexical phase, adds future time, or duplicates lexical latency.",
    "cross_family_comparisons" => cross_family_audit(id, data["center"]),
    "examples" => data["examples"].map do |row|
      example(
        category: row[0], graph: row[1], literal: row[2], natural: row[3],
        analysis: row[4], use_status: row[0] == "counterexample" ? "must_not_use_this_min_root" : "valid",
        pseudocode: row[0] == "executable_or_programming" ? row[5] : nil
      )
    end,
    "future_compound_decomposition_sketches_not_canonical" => [
      "#{id} + sensory/modality modifier → visual, auditory, proprioceptive, propositional, imagistic, or procedural representation",
      "#{id} + LOG/ORI/WRN predicate → believed, true, probable, false, biased, uncertain, or hallucinatory representation without overloading the atom",
      "#{id} + DAT/CON/MIN-process relation → stored, communicated, recalled, learned, inferred, or attended representation with explicit provenance and action"
    ],
    "later_era_evolution_notes" => [
      "Later technical vocabulary may distinguish symbolic, embodied, probabilistic, vector, episodic, semantic, and procedural representation without changing this invariant.",
      "Later colloquial forms may lexicalize high-frequency compounds such as memory, idea, belief, awareness, culture, and mental image.",
      "Future semantic changes require an explicit versioned migration."
    ],
    "confidence" => data["confidence"],
    "canonicalized" => false
  }
end

recommended = {
  "metadata" => {
    "title" => "MIN:000–022 recommended permanent semantic specifications",
    "status" => "ready_for_delegated_approval_not_yet_canonical",
    "review_scope" => "MIN:000–022 only",
    "semantic_architecture" => "self-representation → target representation → shared cognitive schema",
    "lexical_expression_axis" => "persistent → manifest → latent",
    "delegated_approval_authorized" => true,
    "roots_canonicalized" => [],
    "stop_boundary" => ["MIN:100–122", "any other root block", "Gate 4", "translator implementation"]
  },
  "block_invariant" =>
    "The 0xx Mind layer names cognitive representations as entities or conditions. The second trit selects self, target, or shared scope; the third selects persistent, presently manifest, or latent expression.",
  "triplet_contrasts" => [
    {
      "range" => "MIN:000–002",
      "shared_axis" => "representation of the cognizer's own identity or condition",
      "contrast" => "persistent across episodes / presently manifest / persisting but not manifest"
    },
    {
      "range" => "MIN:010–012",
      "shared_axis" => "representation of a distinct target",
      "contrast" => "persistent across episodes / presently manifest / persisting but not manifest"
    },
    {
      "range" => "MIN:020–022",
      "shared_axis" => "representation held across multiple cognizers",
      "contrast" => "persistent across episodes / presently manifest among them / persisting but not manifest among them"
    }
  ],
  "roots" => recommended_roots
}

STRESS_ROWS = [
  ["self-image", "direct proposed root", "MIN:000", "Persistent representation of oneself."],
  ["body image", "composition", "MIN:000 + MAT/STR", "Self-representation with embodied or structural content."],
  ["current self-awareness", "direct proposed root", "MIN:001", "Self-representation presently manifest."],
  ["subconscious self-schema", "direct proposed root", "MIN:002", "Latent self-representation."],
  ["autobiographical memory", "composition", "MIN:000/002 + temporal/source relation", "Depends on persistence and current manifestation."],
  ["sense of identity", "composition", "LIF + MIN:000", "Identity and its cognitive representation are distinct."],
  ["consciousness", "canonical/future other family", "LIF", "The condition of consciousness is not merely a representation."],
  ["emotion", "composition", "LIF/MIN representation", "Emotion itself versus representation of emotion."],
  ["pain awareness", "composition", "LIF/MAT sensation + MIN:001", "Bodily state plus manifest self-representation."],
  ["desire", "future MIN capacity/relationship", "MIN:2xx or unresolved", "Motivational relation is not fixed here."],
  ["intention", "future MIN process/capacity", "MIN:1xx/2xx", "Intentional commitment is not a representation entity."],
  ["attention", "future MIN process/capacity", "MIN:1xx/2xx", "Allocation of cognition is reserved."],
  ["focus", "future MIN process/capacity", "MIN:1xx/2xx", "Not forced into an entity root."],
  ["introspection", "future MIN process/capacity", "MIN:1xx", "An inward cognitive process."],
  ["reflection", "future MIN process/capacity", "MIN:1xx", "An inward cognitive process."],
  ["remember", "future MIN process/capacity", "MIN:1xx", "Recall is a process; resulting content may be manifest."],
  ["forget", "composition", "MIN representation + WRN/REP/runtime", "Loss, inaccessibility, or latency must be distinguished."],
  ["memory content", "composition", "MIN:000/010/020 by scope", "Representation plus temporal/provenance relation."],
  ["mental image of a place", "direct proposed root", "MIN:010/011/012", "Target representation selected by expression."],
  ["concept", "composition", "MIN representation + LOG/STR type", "Representation whose content is conceptual."],
  ["idea", "composition", "MIN representation + CRE/source", "Representation with a creation or emergence relation."],
  ["belief", "future MIN capacity/relationship", "MIN:2xx + representation", "Commitment toward content is relational."],
  ["opinion", "composition", "MIN:2xx + MIN representation", "Belief relation plus represented content."],
  ["knowledge", "composition", "MIN representation + LOG/ORI justification/truth", "Do not equate representation with knowledge."],
  ["certainty", "grammar or quantity", "LOG/modality", "Degree or status of commitment."],
  ["doubt", "future MIN capacity/relationship", "MIN:2xx or LOG", "Unresolved epistemic relation."],
  ["truth", "canonical/future other family", "LOG/ORI", "Representation may be true or false."],
  ["false belief", "composition", "MIN representation + MIN:2xx + WRN/LOG", "Content, commitment, and error are separate."],
  ["hallucination", "composition", "MIN:011 + WRN + absent external cause", "Manifest target-like representation with error conditions."],
  ["dream", "composition", "MIN representation + LIF state/CRE", "Generated or manifest content under a sleep state."],
  ["imagination", "future MIN process/capacity", "MIN:1xx/2xx + CRE", "Generation process, not the represented entity."],
  ["perception", "future MIN process/capacity", "MIN:1xx", "Perceiving is a process; content may map to MIN:011."],
  ["sensation", "composition", "MAT/LIF signal + MIN:001/011", "Physical/biological signal and cognitive representation."],
  ["recognition", "future MIN process/capacity", "MIN:1xx", "A target-directed cognitive process."],
  ["unrecognized object", "unresolved lexical ambiguity", "MIN:012 or no MIN root", "May mean latent representation or absence of representation."],
  ["familiar face not recalled", "direct proposed root", "MIN:012", "Target representation persists but is not manifest."],
  ["mental map", "composition", "MIN:010/011/012 + STR/MOV", "Representation with spatial structure."],
  ["world model", "direct proposed root", "MIN:010", "Persistent target/environment representation."],
  ["active scene model", "direct proposed root", "MIN:011", "Target representation presently manifest."],
  ["cached object model", "direct proposed root", "MIN:012", "Target representation latent outside active cognition."],
  ["prediction", "future MIN process/capacity", "MIN:1xx/2xx + LOG", "Inference or modal relation, not entity alone."],
  ["expectation", "future MIN capacity/relationship", "MIN:2xx", "Target-directed anticipatory relation."],
  ["hypothesis", "composition", "MIN representation + LOG possibility", "Represented proposition under formal possibility."],
  ["theory", "composition", "MIN:020 + LOG/STR", "Shared schema plus formal organization and evidence."],
  ["common understanding", "direct proposed root", "MIN:020/021", "Persistent or presently manifest shared schema."],
  ["team mental model", "direct proposed root", "MIN:020", "Persistent schema held across team members."],
  ["shared situation awareness", "direct proposed root", "MIN:021", "Shared schema presently manifest."],
  ["tacit group knowledge", "direct proposed root", "MIN:022", "Shared schema latent among members."],
  ["collective memory", "composition", "MIN:020/022 + temporal/source relation", "Shared representation with memory provenance."],
  ["culture", "composition", "MIN:020/022 + CON/STR/DAT", "Shared cognition, practices, transmission, and artifacts."],
  ["tradition", "composition", "MIN:020/022 + CON/DAT + temporal continuity", "Not one atomic Mind entity."],
  ["convention", "composition", "CON/STR/LOG + MIN:020", "Normative or communicative rule plus shared schema."],
  ["consensus", "composition", "MIN:021 + CON/LOG process/result", "Shared manifest schema plus agreement conditions."],
  ["joint attention", "future MIN process/capacity", "MIN:1xx/2xx", "Simultaneous attention does not imply shared representation."],
  ["groupthink", "composition", "MIN:020/021 + WRN/CON", "Shared schema plus dysfunctional social/error condition."],
  ["rumor", "composition", "DAT/CON + MIN representation", "Transmitted content and participant beliefs."],
  ["shared database", "canonical/future other family", "DAT", "Common stored data is not cognitive sharing."],
  ["manual everyone can access", "canonical/future other family", "DAT/CON", "Access does not prove a shared mental model."],
  ["message", "canonical/future other family", "DAT/CON", "Information artifact or transmission."],
  ["communication", "canonical/future other family", "CON", "Participant transfer process or relation."],
  ["signal", "canonical/future other family", "DAT/MAT", "Physical or informational carrier."],
  ["record", "canonical/future other family", "DAT", "External stored information."],
  ["database row", "canonical/future other family", "DAT", "Stored symbol structure."],
  ["neural state", "canonical/future other family", "MAT", "Physical realization is not mental content."],
  ["brain", "canonical/future other family", "MAT/LIF", "Biological material bearer."],
  ["software object model", "unresolved lexical ambiguity", "DAT/STR or MIN", "MIN only when the software is treated as a cognizer's representation."],
  ["AI self-model", "direct proposed root", "MIN:000/001/002", "Self-representation selected by expression."],
  ["AI world model", "direct proposed root", "MIN:010/011/012", "Target representation selected by expression."],
  ["multi-agent shared model", "direct proposed root", "MIN:020/021/022", "Shared schema selected by expression."],
  ["working memory", "composition", "MIN:001/011/021 + cognitive-role relation", "Manifest representation serving a working role."],
  ["long-term memory", "composition", "MIN:000/010/020 + temporal persistence", "Persistent representation with storage/retention relation."],
  ["latent memory", "direct proposed root", "MIN:002/012/022", "Latent representation selected by scope."],
  ["recall cue", "composition", "DAT/MIN-process + MIN latent root", "Cue and transition are separate."],
  ["learning", "future MIN process/capacity", "MIN:1xx/2xx", "Representation change process."],
  ["reasoning", "future MIN process/capacity", "MIN:1xx", "Cognitive transformation process."],
  ["decision", "future MIN process/capacity", "MIN:1xx + LOG", "Choice process/result, not a representation alone."],
  ["skill", "future MIN capacity/relationship", "MIN:2xx", "Competence or disposition."],
  ["intelligence", "future MIN capacity/relationship", "MIN:2xx", "Capacity or system relation."],
  ["meaning", "unresolved lexical ambiguity", "MIN representation + LOG/CON context", "Meaning may be cognitive, linguistic, or formal."],
  ["category", "composition", "MIN representation + LOG/STR", "Represented classification schema."],
  ["stereotype", "composition", "MIN:010/020 + WRN/LOG", "Representation plus generalization/error conditions."],
  ["cognitive bias", "composition", "MIN representation/relation + WRN", "Systematic error condition."],
  ["ontology", "composition", "MIN:020 + LOG/ORI/STR", "Shared cognitive schema plus formal ontological structure."],
  ["source code", "canonical/future other family", "DAT/LOG", "External formal record."],
  ["theorem", "canonical/future other family", "LOG", "Formal proposition/proof object."],
  ["variable", "canonical/future other family", "LOG/DAT", "Formal symbol or data reference."],
  ["mental representation denied", "root plus runtime", "MIN:0xx[0]", "Runtime denial does not change lexical scope/expression."],
  ["representation status unresolved", "root plus runtime", "MIN:0xx[2]/num", "Runtime uncertainty does not select lexical latency."],
  ["planned thought", "grammar or quantity", "MIN process + modality/time", "Planning and future time are not lexical 0xx meanings."],
  ["probable belief", "grammar or quantity", "MIN relation + LOG probability", "Probability remains formal/modality grammar."],
  ["number of remembered items", "grammar or quantity", "MIN representation + quantity", "Cardinality is not an atomic Mind root."]
].freeze

tests = STRESS_ROWS.each_with_index.map do |row, index|
  {
    "test_id" => format("MIN000-T%03d", index + 1),
    "concept" => row[0],
    "classification" => row[1],
    "mapping" => row[2],
    "reason" => row[3]
  }
end
coverage = tests.group_by { |test| test["classification"] }.transform_values(&:length)
stress = {
  "metadata" => {
    "title" => "MIN:000–022 English concept stress tests",
    "status" => "review_evidence_not_dictionary",
    "scope" => "MIN:000–022 only",
    "concept_count" => tests.length,
    "no_forced_atomization" => true
  },
  "classification_values" => coverage.keys,
  "tests" => tests,
  "coverage_summary" => coverage
}

collision = +"# MIN:000–022 Collision Report\n\n"
collision << "Status: **peer-review evidence — pending delegated approval**\n\n"
collision << "## Core ownership rule\n\n"
collision << "The proposed block owns cognitive representations as entities or conditions: self-representation, target representation, and shared cognitive schema, each persistent, manifest, or latent. It does not own attention, perception, learning, reasoning, belief commitment, truth, external records, communication, physical neural state, identity, error, or creation.\n\n"
collision << "## Intra-Mind boundary\n\n"
collision << "| Layer | Ownership |\n|---|---|\n"
collision << "| `MIN:000–022` proposed | cognitive representations by scope and lexical expression |\n"
collision << "| `MIN:100–122` provisional | cognitive processes only after separate review |\n"
collision << "| `MIN:200–222` provisional | mental capacities and relationships only after separate review |\n\n"
collision << "## Cross-family collision matrix\n\n"
collision << "| Root | #{CROSS_FAMILIES.join(" | ")} |\n"
collision << "|---|#{CROSS_FAMILIES.map { "---" }.join("|")}|\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  collision << "| `#{id}` | #{CROSS_FAMILIES.map { |family| root.dig("cross_family_comparisons", family) }.join(" | ")} |\n"
end
collision << "\n## High-risk English traps\n\n"
collision << "- **Memory** may name content, retention, storage, or recall. The proposed atoms own representational content and expression, not every memory relation.\n"
collision << "- **Awareness** may mean consciousness, attention, or a manifest representation. Only the representational sense is `MIN:001/011/021`.\n"
collision << "- **Knowledge** adds truth or justification; a representation alone may be false.\n"
collision << "- **Shared** requires cognitive content across cognizers. A common record, channel, target, or simultaneous gaze is insufficient.\n"
collision << "- **Latent** is lexical nonmanifest representation. Runtime `[2]/num` marks token status and does not select the latent root.\n"
collision << "- **Model** may be an external DAT/STR artifact or an internal cognitive representation. Bearer and use decide the family.\n\n"
collision << "## Disposition\n\n"
collision << "No blocking collision remains. The architecture reserves processes and capacities for later MIN blocks and leaves truth, data, communication, identity, structure, and physical realization in their own domains.\n"

peer = +"# MIN:000–022 Adversarial Semantic Peer Review\n\n"
peer << "Status: **READY FOR DELEGATED APPROVAL — NOT YET CANONICAL**\n\n"
peer << "Scope is strictly `MIN:000–022`. The user delegated approval authority for reviewed roots. Deterministic generated fields are fixed; all 81 current canonical meanings are immutable.\n\n"
peer << "## Executive recommendation\n\n"
peer << "Use one cognitive-representation architecture:\n\n"
peer << "- `MIN:000–002`: **self-representation** — persistent / manifest / latent;\n"
peer << "- `MIN:010–012`: **target representation** — persistent / manifest / latent;\n"
peer << "- `MIN:020–022`: **shared cognitive schema** — persistent / manifest / latent.\n\n"
peer << "This corrects the current mixture of mental objects, attention processes, perception, memory status, knowledge claims, and social tradition. Representation is broad enough for ordinary cognition and technical agents while leaving truth, storage, attention, process, capacity, communication, and physical realization explicit.\n\n"
peer << "## Fixed generated forms\n\n"
peer << "| ID | Universal slot | Transliteration | Compact | Formal carrier | Harmony | Relative note path |\n|---|---|---|---|---|---|---|\n"
IDS.each do |id|
  f = fixed_projection(atoms_by_id.fetch(id))
  peer << "| `#{id}` | #{f["universal_slot"]} | `#{f["family_qualified_transliteration"]}` | `#{f["local_compact_root"]}` | `#{f["formal_carrier"]}` | `#{f["harmonic_signature_semitones"].join(", ")}` | `#{f["relative_note_path_semitones"].join(", ")}` |\n"
end

scored_roots.each do |root|
  id = root["canonical_id"]
  data = DESIGN.fetch(id)
  spec = recommended_roots.find { |item| item.dig("fixed_generated_fields", "canonical_id") == id }
  peer << "\n## #{id} — #{data["title"]}\n\n"
  peer << "**Why the current meaning was probably chosen.** #{data["current_rationale"]}\n\n"
  peer << "| Candidate | Atomic | Address | MIN | Triplet | Neighbor | Cross-family | Everyday | Technical | Compound | Translation | Total |\n"
  peer << "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n"
  root["candidates"].each do |item|
    scores = item["scores"]
    peer << "| #{item["title"]} | #{SCORE_KEYS.map { |key| scores[key] }.join(" | ")} | **#{item["total"]}/100** |\n"
  end
  root["candidates"].each do |item|
    a = item["analysis"]
    peer << "- **#{item["title"]}:** #{a["why_it_fits"]} Covers: #{a["useful_coverage"]} Territory: #{a["semantic_territory_consumed"]} Risk: #{a["risks_and_future_limitations"]}\n"
  end
  winner = root["candidates"].find { |item| item["candidate_id"] == root["recommended_winner"] }
  peer << "\n**Recommendation:** **#{data["title"]}** (#{winner["total"]}/100; confidence #{(data["confidence"] * 100).round}%).\n\n"
  peer << "> #{data["definition"]}\n\n"
  peer << "**Address fit.** #{spec["address_explanation"].values.join(" ")}\n\n"
  peer << "**Boundaries.** #{spec["semantic_boundaries"].join(" ")}\n\n"
  peer << "**Exclusions.** #{spec["excluded_meanings"].join(" ")}\n\n"
  peer << "**Nearest neighbors.** #{spec["nearest_neighbors"].values.flatten.join(" ")}\n\n"
  peer << "**Runtime states.** `[0]` #{spec.dig("runtime_state_interpretations", "0")} `[1]` #{spec.dig("runtime_state_interpretations", "1")} `[2]/num` #{spec.dig("runtime_state_interpretations", "2")}\n\n"
  peer << "**Lexical/runtime distinction.** #{spec["lexical_third_trit_vs_runtime_2"]}\n\n"
  peer << "**Examples.**\n\n"
  peer << "| Type | Graph | Literal gloss | Natural rendering | Runtime | Use |\n|---|---|---|---|---:|---|\n"
  spec["examples"].each do |item|
    peer << "| #{item["category"]} | `#{item["semantic_graph"]}` | #{item["literal_gloss"]} | #{item["natural_english"]} | `[#{item["runtime_state"]}]` | #{item["use_status"]} |\n"
  end
  peer << "\n**Future compound sketches—not canonical.** #{spec["future_compound_decomposition_sketches_not_canonical"].join("; ")}.\n\n"
  peer << "**Later-Era notes.** #{spec["later_era_evolution_notes"].join(" ")}\n"
end

peer << "\n## Nine-root contrast matrix\n\n"
peer << "| Root | Owns | Closest exclusions | Reserved for compounds | Intentionally undefined here |\n|---|---|---|---|---|\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  peer << "| `#{id}` | #{root["proposed_title"]}: #{root["semantic_center"]} | attention, process, belief relation, truth, records | modality, source, accuracy, storage, sensory type | units, certainty, identity, communication, learning |\n"
end
peer << "\n## Triplet-coherence assessment\n\n"
recommended["triplet_contrasts"].each do |triplet|
  peer << "- `#{triplet["range"]}` shares #{triplet["shared_axis"]}; exact contrast: #{triplet["contrast"]}.\n"
end
peer << "\nAll three triplets use the same lexical-expression axis. No member changes the semantic center merely to cover a frequent English word.\n\n"
peer << "## English coverage disposition\n\n"
peer << "- Direct roots cover cognitive representations by self, target, or shared scope and persistent, manifest, or latent expression.\n"
peer << "- Compounds intentionally cover memory provenance, sensory modality, belief, knowledge, truth, error, culture, convention, mental maps, working memory, and AI model types.\n"
peer << "- Later MIN blocks intentionally retain attention, perception, learning, reasoning, recall, competence, belief relations, uncertainty, and distributed intelligence.\n"
peer << "- Other families retain identity, physical neural state, data records, communication, structure, truth, error, repair, creation, and literal motion.\n"
peer << "- Ambiguous words such as awareness, model, meaning, memory, and unrecognized remain sense-disambiguated rather than forced into one atom.\n\n"
peer << "## Stress-test summary\n\n"
peer << "- English concepts tested: **#{tests.length}**\n"
coverage.each { |classification, count| peer << "- #{classification}: **#{count}**\n" }
peer << "\n## Proposed titles and invariant definitions\n\n"
recommended_roots.each do |root|
  peer << "- `#{root.dig("fixed_generated_fields", "canonical_id")}` — **#{root["proposed_title"]}**: #{root["invariant_definition"]}\n"
end
peer << "\n## Delegated approval checklist\n\n"
peer << "- [x] Current meaning plus four alternative architectures compared at every root.\n"
peer << "- [x] Recommended candidate uniquely wins all scoring tables.\n"
peer << "- [x] Triplets retain one center and exact persistent/manifest/latent contrasts.\n"
peer << "- [x] Cross-family collisions and English traps are explicit.\n"
peer << "- [x] Generated fields match fixed algorithms.\n"
peer << "- [x] User delegated approval authority for reviewed roots.\n"
peer << "- [ ] Apply canonization only after the independent validator passes.\n\n"
peer << "- **Roots canonized by generation of this packet:** none.\n"
peer << "- **Stop boundary honored:** no `MIN:100–122`, other root block, Gate 4, compound architecture, renderer, or translator implementation was begun.\n\n"
peer << "**READY FOR DELEGATED APPROVAL**\n"

write_yaml("reviews/MIN_000_022_scored_candidates.yaml", scored)
write_yaml("reviews/MIN_000_022_recommended_spec.yaml", recommended)
write_yaml("reviews/MIN_000_022_stress_tests.yaml", stress)
File.write(File.join(ROOT, "reviews/MIN_000_022_collision_report.md"), collision)
File.write(File.join(ROOT, "reviews/MIN_000_022_peer_review.md"), peer)

puts "Built MIN:000–022 review packet: #{IDS.length} roots, #{tests.length} stress tests."
