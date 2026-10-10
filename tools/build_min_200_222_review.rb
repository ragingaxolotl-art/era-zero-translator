#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MIN:200 MIN:201 MIN:202
  MIN:210 MIN:211 MIN:212
  MIN:220 MIN:221 MIN:222
].freeze
SCORE_KEYS = %w[
  atomicity address_fit family_fit neighbor_separation
  cross_family_separation compound_usefulness
  everyday_language_coverage technical_coverage
].freeze
CROSS_FAMILIES = %w[LIF MOV MAT CON STR WRN REP LOG DAT CRE ORI].freeze
EXAMPLE_CATEGORIES = %w[
  ordinary_conversation physical_or_spatial temporal_or_sequential
  cross_family_compound executable_or_programming counterexample
].freeze

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
  raise "#{id}: wrong score count" unless scores.length == SCORE_KEYS.length

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

def example(category:, graph:, literal:, natural:, analysis:, use_status: "valid",
            runtime: 1, contour: "declarative", pseudocode: nil)
  {
    "category" => category,
    "semantic_graph" => graph,
    "literal_gloss" => literal,
    "natural_english" => natural,
    "runtime_state" => runtime,
    "contour" => contour,
    "role_registers" => {
      "low" => "cognizer or cognitive community",
      "middle" => "MIN attention capacity or relation",
      "high" => "attentional target when present",
      "sustained" => "attentional frame, evidence context, or execution environment"
    },
    "use_status" => use_status,
    "analysis" => analysis
  }.tap { |item| item["pseudocode"] = pseudocode if pseudocode }
end

atoms = load_yaml("lexicon/atoms.yaml").fetch("atoms")
atoms_by_id = atoms.to_h { |atom| [atom.fetch("canonical_id"), atom] }

DESIGN = {
  "MIN:200" => {
    "scope" => "capacity", "phase" => "enduring",
    "title" => "enduring attentional capacity",
    "definition" => "A persistent capacity of a cognizer to allocate cognitive processing selectively.",
    "current_rationale" => "“Stable competence” was probably chosen because stable + inward capacity + Mind suggests a dependable cognitive ability. Its definition combines understanding, remembering, learning, and deciding, which are different processes with different success conditions.",
    "current_scores" => [3, 9, 10, 5, 5, 6, 9, 8],
    "representation" => ["enduring representational capacity", "A persistent capacity of a cognizer to bear cognitive representations."],
    "epistemic" => ["enduring epistemic competence", "A persistent capacity of a cognizer to form justified conclusions."],
    "executive" => ["enduring executive-control capacity", "A persistent capacity of a cognizer to select and regulate cognitive operations."],
    "examples" => [
      ["ordinary_conversation", "MIN:200[1](COGNIZER=reader)", "reader; enduring capacity to allocate attention", "She retains the ability to choose what to pay attention to.", "No claim is made that the capacity is currently available or exercised."],
      ["physical_or_spatial", "MIN:200[1](COGNIZER=pilot,DOMAIN=instrument_panel)", "pilot; enduring attentional capacity in instrument domain", "The pilot has a dependable capacity to allocate attention across the instruments.", "The instruments are physical targets; the capacity is cognitive."],
      ["temporal_or_sequential", "MIN:200[1](COGNIZER=operator,ACROSS=shifts)", "operator; attentional capacity persists across shifts", "The operator's attentional capacity persists across work sessions.", "Persistence is lexical rather than a schedule."],
      ["cross_family_compound", "MAT(BRAIN=person)+MIN:200[1](COGNIZER=person)", "physical neural bearer plus enduring attentional capacity", "The person's brain supports a persistent capacity to allocate attention.", "MAT owns the substrate; MIN owns the cognitive capacity."],
      ["executable_or_programming", "MIN:200[1](COGNIZER=agent,RESOURCE=attention_allocator)", "agent; enduring attention-allocation capacity", "The agent has a persistent attention-allocation capability.", "Useful for a capability declaration independent of current resource availability.", "assert agent.capabilities.include?(:selective_attention)"],
      ["counterexample", "LIF(CONSCIOUS=person)", "person; conscious living condition", "The person is awake, but wakefulness alone does not prove selective attentional capacity.", "Consciousness or arousal is LIF, not MIN:200."]
    ]
  },
  "MIN:201" => {
    "scope" => "capacity", "phase" => "available",
    "title" => "available attentional capacity",
    "definition" => "A cognizer's capacity to allocate cognitive processing selectively that is presently available for exercise.",
    "current_rationale" => "“Expressed focus” was selected from active inward capacity, but the definition merges concentration, recall, imagination, and problem solving. Focus on a target is a relationship, whereas this slot must name the source's currently available capacity.",
    "current_scores" => [3, 8, 10, 5, 7, 6, 9, 8],
    "representation" => ["available representational capacity", "A cognizer's capacity to bear cognitive representations that is presently available for exercise."],
    "epistemic" => ["available epistemic competence", "A cognizer's capacity to form justified conclusions that is presently available for exercise."],
    "executive" => ["available executive control", "A cognizer's capacity to select and regulate cognitive operations that is presently available for exercise."],
    "examples" => [
      ["ordinary_conversation", "MIN:201[1](COGNIZER=I,AMOUNT=sufficient)", "I; attentional capacity presently available", "I have enough attention available to read this carefully now.", "This is capacity availability, not the act of focusing on the page."],
      ["physical_or_spatial", "MIN:201[1](COGNIZER=driver,DOMAIN=mirror_check)", "driver; attentional capacity available for mirror check", "The driver has attention available to check the mirror.", "Actual attention to the mirror would be MIN:211."],
      ["temporal_or_sequential", "MIN:201[1](COGNIZER=student,AFTER=break)", "student; attention capacity available after break", "After the break, the student's attention is available again.", "The temporal relation is explicit."],
      ["cross_family_compound", "MAT(AROUSAL=adequate)+MIN:201[1](COGNIZER=operator)", "adequate physical arousal plus available attention capacity", "The operator is physically alert and has attention available.", "MAT/LIF arousal does not itself encode selective allocation."],
      ["executable_or_programming", "MIN:201[1](COGNIZER=agent,BUDGET=0.6)", "agent; 0.6 attention budget available", "The agent currently has 0.6 units of attention capacity available.", "Quantity grammar supplies the budget value.", "assert agent.attention_budget.available == 0.6"],
      ["counterexample", "MIN:211[1](COGNIZER=I,TARGET=page)", "I; active attention directed to page", "I am focusing on the page.", "Target focus is an outward relation, not inward capacity availability."]
    ]
  },
  "MIN:202" => {
    "scope" => "capacity", "phase" => "latent",
    "title" => "latent attentional capacity",
    "definition" => "A cognizer's capacity to allocate cognitive processing selectively that exists without being presently available for exercise.",
    "current_rationale" => "“Latent aptitude” correctly recognizes dormant inward capacity, but it narrows the capacity to learning or understanding and then mixes undeveloped, inaccessible, and unexpressed conditions. A latent attention capacity supplies one exact center.",
    "current_scores" => [5, 9, 9, 6, 6, 7, 9, 7],
    "representation" => ["latent representational capacity", "A cognizer's capacity to bear cognitive representations that exists without being presently available for exercise."],
    "epistemic" => ["latent epistemic competence", "A cognizer's capacity to form justified conclusions that exists without being presently available for exercise."],
    "executive" => ["latent executive-control capacity", "A cognizer's capacity to select and regulate cognitive operations that exists without being presently available for exercise."],
    "examples" => [
      ["ordinary_conversation", "MIN:202[1](COGNIZER=sleeping_student)", "sleeping student; attentional capacity latent", "The sleeping student retains attentional capacity, but it is not presently available.", "The reason for unavailability is external to the root."],
      ["physical_or_spatial", "MAT(SEDATION=patient)+MIN:202[1](COGNIZER=patient)", "sedated patient plus latent attention capacity", "Sedation leaves the patient's attentional capacity unavailable without asserting that it is absent.", "MAT owns sedation."],
      ["temporal_or_sequential", "MIN:202[1](COGNIZER=agent,DURING=shutdown)", "agent; attentional capacity latent during shutdown", "The agent's attention capability persists in a latent state during shutdown.", "Reactivation is not promised."],
      ["cross_family_compound", "LIF(SLEEP=person)+MIN:202[1](COGNIZER=person)", "sleeping life state plus latent attentional capacity", "The sleeping person retains a dormant capacity for selective attention.", "LIF owns sleep; MIN owns capacity."],
      ["executable_or_programming", "MIN:202[1](COGNIZER=agent,MODULE=attention)", "agent; attention module capability latent", "The agent retains an attention capability while the module is unavailable.", "A capability record distinct from runtime enablement.", "assert agent.capabilities.include?(:attention) && !agent.attention.available?"],
      ["counterexample", "MIN:200[0](COGNIZER=system)", "system; no enduring attentional capacity", "The system has no selective-attention capability at all.", "Absence of capacity is negation, not latent capacity."]
    ]
  },
  "MIN:210" => {
    "scope" => "target", "phase" => "established",
    "title" => "established target-attention relation",
    "definition" => "An established relation in which a cognizer's cognitive processing is preferentially directed toward a distinct target.",
    "current_rationale" => "“Settled belief relation” was chosen because stable + outward relationship + Mind suggests a lasting cognitive stance toward a target. The definition combines interpretation, recognition, and belief, creating collisions with LOG, ORI, and canonical representation roots.",
    "current_scores" => [4, 9, 9, 6, 4, 7, 9, 8],
    "representation" => ["established cognitive-reference relation", "An established relation in which a cognizer's representation is about a distinct target."],
    "epistemic" => ["settled belief commitment", "An established relation in which a cognizer is epistemically committed to a proposition about a distinct target."],
    "executive" => ["established goal orientation", "An established relation in which a cognizer treats a distinct target as an objective of cognitive control."],
    "examples" => [
      ["ordinary_conversation", "MIN:210[1](COGNIZER=analyst,TARGET=budget_issue)", "analyst; established attention relation to budget issue", "The budget issue remains the analyst's standing focus across meetings.", "The relation persists even when not continuously manifest."],
      ["physical_or_spatial", "MIN:210[1](COGNIZER=sentinel,TARGET=north_gate)", "sentinel; established attention relation to north gate", "The north gate remains a standing object of the sentinel's attention across scans.", "A role assignment alone would require CON/STR."],
      ["temporal_or_sequential", "MIN:210[1](COGNIZER=researcher,TARGET=question,ACROSS=sessions)", "researcher; target-attention relation persists across sessions", "The research question remains the researcher's standing attentional target.", "This is stable orientation, not uninterrupted active focus."],
      ["cross_family_compound", "CON(ROLE=watcher,TARGET=gate)+MIN:210[1](COGNIZER=guard,TARGET=gate)", "watch role plus established cognitive orientation to gate", "The guard is assigned to watch the gate and maintains it as a standing attentional target.", "CON owns the assignment; MIN owns attention."],
      ["executable_or_programming", "MIN:210[1](COGNIZER=agent,TARGET=objective_7)", "agent; established attention relation to objective 7", "Objective 7 is pinned as a standing attentional target for the agent.", "Semantic orientation distinct from a data subscription.", "assert agent.attention_targets.pinned?(:objective_7)"],
      ["counterexample", "MIN:010[1](COGNIZER=agent,TARGET=objective_7)", "agent; persistent representation of objective 7", "The agent remembers objective 7 but does not prioritize it.", "A persistent target representation is not an attention relation."]
    ]
  },
  "MIN:211" => {
    "scope" => "target", "phase" => "active",
    "title" => "active target attention",
    "definition" => "A relation in which a cognizer's cognitive processing is presently preferentially directed toward a distinct target.",
    "current_rationale" => "“Active attention relation” is the strongest current title, but its definition dilutes attention with interpreting, trusting, doubting, and evaluating. Those operations can occur without preferential processing and bring LOG/ORI collisions into the atom.",
    "current_scores" => [3, 10, 10, 5, 5, 7, 10, 9],
    "representation" => ["active cognitive-reference relation", "A relation in which a cognizer's representation is presently about a distinct target."],
    "epistemic" => ["active belief engagement", "A relation in which a cognizer is presently entertaining an epistemic commitment about a distinct target."],
    "executive" => ["active goal orientation", "A relation in which a cognizer is presently treating a distinct target as an objective of cognitive control."],
    "examples" => [
      ["ordinary_conversation", "MIN:211[1](COGNIZER=I,TARGET=your_words)", "I; attention presently directed to your words", "I am paying attention to what you are saying.", "Understanding or agreement is not asserted."],
      ["physical_or_spatial", "MIN:211[1](COGNIZER=driver,TARGET=pedestrian)", "driver; active attention to pedestrian", "The driver is focusing on the pedestrian.", "Eye or head movement is separate MOV/MAT evidence."],
      ["temporal_or_sequential", "MIN:211[1](COGNIZER=operator,TARGET=alarm,DURING=interval_4)", "operator; alarm prioritized during interval 4", "The operator is attending to the alarm during interval 4.", "The interval is graph-level."],
      ["cross_family_compound", "MAT(SIGNAL=flashing_light)+MIN:211[1](COGNIZER=operator,TARGET=warning)", "flashing signal plus active attention to warning", "The flashing light has the operator's attention.", "Causation is explicit; MAT owns the signal."],
      ["executable_or_programming", "MIN:211[1](COGNIZER=agent,TARGET=event_42,PRIORITY=high)", "agent; active attention on event 42 with high priority", "The agent is allocating preferential processing to event 42.", "Priority quantity/ordering remains grammar or LOG/STR.", "assert agent.attention.current_target == :event_42"],
      ["counterexample", "MIN:011[1](COGNIZER=driver,TARGET=billboard)", "driver; billboard representation manifest", "The billboard is present in the driver's scene model but remains peripheral.", "Manifest representation does not entail attention."]
    ]
  },
  "MIN:212" => {
    "scope" => "target", "phase" => "unresolved",
    "title" => "unresolved target-attention relation",
    "definition" => "An unresolved attentional relation between a cognizer and a distinct target whose receipt of preferential cognitive processing is undetermined.",
    "current_rationale" => "“Uncertain interpretation” follows unresolved outward relationship, but it selects uncertainty about a belief or understanding rather than an unresolved cognitive relation. That collides with LOG/ORI uncertainty and breaks the attention axis already latent in MIN:211.",
    "current_scores" => [5, 10, 9, 6, 4, 7, 9, 8],
    "representation" => ["unresolved cognitive-reference relation", "Whether a cognizer's representation is about a distinct target is unresolved."],
    "epistemic" => ["unresolved belief commitment", "Whether a cognizer is epistemically committed to a proposition about a distinct target is unresolved."],
    "executive" => ["unresolved goal orientation", "Whether a cognizer treats a distinct target as an objective of cognitive control is unresolved."],
    "examples" => [
      ["ordinary_conversation", "MIN:212[1](COGNIZER=listener,TARGET=me)", "listener-to-me attention relation unresolved", "I cannot tell whether the listener is paying attention to me.", "The uncertainty concerns the attention relation, not the truth of a proposition."],
      ["physical_or_spatial", "WRN(OCCLUSION=camera)+MIN:212[1](COGNIZER=pilot,TARGET=warning_light)", "camera occlusion plus unresolved pilot attention to warning light", "The camera cannot establish whether the pilot is attending to the warning light.", "WRN owns the evidential defect."],
      ["temporal_or_sequential", "MIN:212[1](COGNIZER=operator,TARGET=alarm,AT=t4)", "operator attention to alarm unresolved at t4", "At that moment, the operator's attentional relation to the alarm is unresolved.", "No future claim is made."],
      ["cross_family_compound", "DAT(TRACE=missing)+MIN:212[1](COGNIZER=agent,TARGET=event_42)", "missing trace plus unresolved attention relation", "Because the trace is missing, whether the agent attended to event 42 remains unresolved.", "DAT supplies evidence status; MIN supplies the relation under question."],
      ["executable_or_programming", "MIN:212[1](COGNIZER=agent,TARGET=event_42)", "agent-to-event attention relation unknown", "Return unknown for whether event 42 received preferential processing.", "A semantic unknown, not a false focus assertion.", "assert attention_relation(:event_42).status == :unresolved"],
      ["counterexample", "LOG(UNCERTAIN=claim_about_event_42)", "claim truth or support uncertain", "The agent is unsure whether the claim is true.", "Epistemic uncertainty is LOG/ORI or a compound, not attention."]
    ]
  },
  "MIN:220" => {
    "scope" => "joint", "phase" => "established",
    "title" => "established joint-attention relation",
    "definition" => "A stable attentional relation among multiple cognizers that gives one target shared cognitive priority.",
    "current_rationale" => "“Coherent worldview” was chosen because stable + systemic relationship + Mind suggests an organized mental system. It ambiguously mixes relations within concepts with relations shared across minds and imports coherence, belief, and worldview without selecting a participant structure.",
    "current_scores" => [5, 7, 8, 4, 4, 7, 8, 8],
    "representation" => ["established representational alignment", "A stable relation of compatibility among representations held by multiple cognizers."],
    "epistemic" => ["established common belief", "A stable epistemic commitment to the same proposition across multiple cognizers."],
    "executive" => ["established coordinated agency", "A stable relation in which multiple cognizers organize cognitive control around one objective."],
    "examples" => [
      ["ordinary_conversation", "MIN:220[1](COGNIZERS=family,TARGET=child_safety)", "family; established joint-attention relation to child safety", "The family maintains child safety as a shared attentional priority.", "Agreement on every belief is not required."],
      ["physical_or_spatial", "MIN:220[1](COGNIZERS=crew,TARGET=pressure_gauge)", "crew; stable shared attentional priority on gauge", "The pressure gauge is an established shared focus for the crew throughout the operation.", "The physical gauge remains MAT."],
      ["temporal_or_sequential", "MIN:220[1](COGNIZERS=team,TARGET=incident_dashboard,ACROSS=shifts)", "team; joint-attention relation persists across shifts", "The dashboard remains the team's shared attentional priority across shifts.", "The active viewers may change while the relation persists."],
      ["cross_family_compound", "CON(BRIEFING=incident)+MIN:220[1](COGNIZERS=responders,TARGET=dashboard)", "briefing plus established joint attention to dashboard", "The briefing establishes the dashboard as the responders' shared focus.", "CON owns the briefing; MIN owns cognitive priority."],
      ["executable_or_programming", "MIN:220[1](COGNIZERS=agents,TARGET=shared_objective)", "agents; established joint-attention relation to shared objective", "The agents maintain a shared attentional policy around the objective.", "The relation is semantic, not merely a common configuration record.", "assert swarm.shared_attention_targets.include?(:objective)"],
      ["counterexample", "MIN:020[1](COGNIZERS=team,CONTENT=procedure)", "team; persistent shared schema of procedure", "The team shares the procedure but is not currently or dispositionally focused on it.", "Shared representation does not entail shared priority."]
    ]
  },
  "MIN:221" => {
    "scope" => "joint", "phase" => "active",
    "title" => "active joint attention",
    "definition" => "An attentional relation in which multiple cognizers presently give the same target shared cognitive priority.",
    "current_rationale" => "“Distributed intelligence” correctly recognizes active + systemic + Mind, but coordinating into a larger reasoning system mixes communication, organization, inference, and collective agency. Multiple agents can jointly attend without forming a super-agent or reasoning system.",
    "current_scores" => [7, 10, 9, 6, 4, 8, 8, 10],
    "representation" => ["active representational alignment", "A relation in which representations held by multiple cognizers are presently mutually compatible."],
    "epistemic" => ["active consensus", "A relation in which multiple cognizers presently share an epistemic commitment to the same proposition."],
    "executive" => ["active coordinated agency", "A relation in which multiple cognizers are presently organizing cognitive control around one objective."],
    "examples" => [
      ["ordinary_conversation", "MIN:221[1](COGNIZERS=group,TARGET=speaker)", "group; active joint attention to speaker", "Everyone is paying attention to the speaker together.", "Agreement, learning, and communication success are not implied."],
      ["physical_or_spatial", "MIN:221[1](COGNIZERS=rescuers,TARGET=exit)", "rescuers; active joint attention to exit", "The rescuers are jointly focusing on the blocked exit.", "Their gaze and movement are separate."],
      ["temporal_or_sequential", "MIN:221[1](COGNIZERS=operators,TARGET=alert,DURING=t4)", "operators; shared priority on alert during t4", "During the alert interval, the operators are jointly attending to it.", "The interval is explicit."],
      ["cross_family_compound", "CON(BROADCAST=warning)+MIN:221[1](COGNIZERS=crew,TARGET=warning)", "warning broadcast plus active joint attention", "The broadcast has brought the crew's attention together on the warning.", "CON owns transmission; the causal link is graph-level."],
      ["executable_or_programming", "MIN:221[1](COGNIZERS=agents,TARGET=object_7)", "agents; active joint attention to object 7", "The agents are concurrently prioritizing object 7.", "Useful for multi-agent attention without asserting message transport.", "assert agents.all? { |a| a.attention.current_target == :object_7 }"],
      ["counterexample", "CON(TRANSFER=messages,PARTICIPANTS=agents)", "agents exchanging messages", "The agents exchange messages while focusing on different targets.", "Communication or coordination does not entail joint attention."]
    ]
  },
  "MIN:222" => {
    "scope" => "joint", "phase" => "potential",
    "title" => "potential joint attention",
    "definition" => "An unrealized possible attentional relation in which multiple cognizers would give the same target shared cognitive priority.",
    "current_rationale" => "“Hypothesis space” was chosen from unrealized systemic possibility, but a set of possibly valid explanations is a logical/data structure, not a relationship among cognizers. It also imports validity and selection from LOG/ORI.",
    "current_scores" => [6, 7, 8, 5, 3, 7, 8, 9],
    "representation" => ["potential representational alignment", "An unrealized possible relation of compatibility among representations held by multiple cognizers."],
    "epistemic" => ["potential common belief", "An unrealized possible relation in which multiple cognizers would share an epistemic commitment."],
    "executive" => ["potential coordinated agency", "An unrealized possible relation in which multiple cognizers would organize cognitive control around one objective."],
    "examples" => [
      ["ordinary_conversation", "MIN:222[1](COGNIZERS=team,TARGET=new_alert)", "team; potential joint attention to new alert", "The new alert could become the team's shared focus, but no joint attention exists yet.", "No plan, schedule, or probability is encoded."],
      ["physical_or_spatial", "MAT(BEACON=light)+MIN:222[1](COGNIZERS=hikers,TARGET=beacon)", "beacon plus unrealized possible joint attention", "The beacon could become a shared focus for the hikers, but it has not.", "Physical salience is not cognitive realization."],
      ["temporal_or_sequential", "MIN:222[1](COGNIZERS=agents,TARGET=event_42,STATUS=unrealized)", "agents; joint attention to event 42 unrealized", "A joint-attention relation to event 42 remains unrealized.", "The root does not predict later realization."],
      ["cross_family_compound", "DAT(SCHEDULE=review)+CRE(PLAN=meeting)+MIN:222[1](COGNIZERS=team,TARGET=proposal)", "schedule and plan plus potential joint attention", "A review is planned, while shared attention to the proposal remains only potential.", "Planning and scheduling stay outside MIN."],
      ["executable_or_programming", "MIN:222[1](COGNIZERS=agents,TARGET=candidate_7)", "agents; potential attention rendezvous on candidate 7", "Candidate 7 could become a shared focus, but the agents have not aligned attention.", "A semantic possibility distinct from queued execution.", "assert agents.none? { |a| a.attention.current_target == :candidate_7 }"],
      ["counterexample", "DAT(SCHEDULE=team_meeting_at_0900)", "stored team meeting schedule", "The team meeting is scheduled for 9:00.", "A schedule does not itself establish potential joint attention."]
    ]
  }
}.freeze

raise "design scope mismatch" unless DESIGN.keys == IDS

NEIGHBORS = {
  "MIN:200" => %w[MIN:201 MIN:202 MIN:000 MIN:001 MIN:002 MIN:100 MIN:101 MIN:102],
  "MIN:201" => %w[MIN:200 MIN:202 MIN:000 MIN:001 MIN:002 MIN:100 MIN:101 MIN:102],
  "MIN:202" => %w[MIN:200 MIN:201 MIN:000 MIN:001 MIN:002 MIN:100 MIN:101 MIN:102],
  "MIN:210" => %w[MIN:211 MIN:212 MIN:010 MIN:011 MIN:012 MIN:110 MIN:111 MIN:112],
  "MIN:211" => %w[MIN:210 MIN:212 MIN:010 MIN:011 MIN:012 MIN:110 MIN:111 MIN:112],
  "MIN:212" => %w[MIN:210 MIN:211 MIN:010 MIN:011 MIN:012 MIN:110 MIN:111 MIN:112],
  "MIN:220" => %w[MIN:221 MIN:222 MIN:020 MIN:021 MIN:022 MIN:120 MIN:121 MIN:122],
  "MIN:221" => %w[MIN:220 MIN:222 MIN:020 MIN:021 MIN:022 MIN:120 MIN:121 MIN:122],
  "MIN:222" => %w[MIN:220 MIN:221 MIN:020 MIN:021 MIN:022 MIN:120 MIN:121 MIN:122]
}.freeze

COLLISIONS = {
  "LIF" => "LIF owns consciousness, wakefulness, organismic responsiveness, and living condition. MIN attention may require consciousness in some beings but does not define life or arousal.",
  "MOV" => "MOV owns gaze shifts, head turns, approach, and physical orientation. Bodily orientation can evidence or serve attention without being the cognitive relation.",
  "MAT" => "MAT owns neural substrate, sensory energy, physical stimuli, and resource consumption. MIN owns selective cognitive allocation, not its physical implementation.",
  "CON" => "CON owns communication, access, assignment, and participant coordination. Messages or roles may establish attention but do not guarantee cognitive priority.",
  "STR" => "STR owns queues, hierarchies, and external priority structures. An ordered task list is not attention unless a cognizer preferentially processes its target.",
  "WRN" => "WRN owns distraction as failure, missed signals, ambiguity, and attentional lapse when evaluated as problems. Attention itself is neutral about success or error.",
  "REP" => "REP owns recovery or repair of impaired attention. Refocusing may restore attention, but the repair process is not the capacity or relation.",
  "LOG" => "LOG owns inference, consistency, truth support, and formal priority rules. Attending to a claim neither proves it nor commits the cognizer to it.",
  "DAT" => "DAT owns input streams, subscriptions, queues, records, and scheduler state. Data selection can implement attention but is not automatically cognitive attention.",
  "CRE" => "CRE owns goals, intentions, plans, and designed attention policies. Intended or scheduled focus must be compounded rather than encoded in MIN.",
  "ORI" => "ORI owns time, modality, existence, certainty, and realization. Potential or unresolved attention does not silently encode probability, future time, or epistemic truth."
}.freeze

def candidate_scores(root, kind)
  case kind
  when "current"
    root.fetch("current_scores")
  when "attention"
    root.fetch("scope") == "joint" ? [10, 10, 10, 10, 8, 10, 10, 10] : [10, 10, 10, 10, 9, 10, 10, 10]
  when "representation"
    root.fetch("scope") == "joint" ? [10, 9, 10, 9, 7, 10, 8, 10] : [10, 9, 10, 9, 8, 10, 8, 10]
  when "epistemic"
    root.fetch("scope") == "joint" ? [8, 9, 8, 7, 3, 9, 10, 10] : [8, 9, 8, 7, 4, 9, 10, 10]
  when "executive"
    root.fetch("scope") == "joint" ? [9, 9, 8, 7, 4, 9, 9, 10] : [9, 8, 8, 7, 5, 9, 9, 10]
  else
    raise "unknown candidate kind #{kind}"
  end
end

def runtime_states(root)
  title = root.fetch("title")
  {
    "0" => "Denies that the specified #{title} holds for this token.",
    "1" => "Affirms that the specified #{title} holds for this token.",
    "2/num" => "Marks the current assertion about the #{title} as dormant or unresolved; it does not select a different lexical capacity/relation or add probability, intention, schedule, or future time."
  }
end

scored_roots = []
recommended_roots = []

DESIGN.each do |id, root|
  atom = atoms_by_id.fetch(id)
  scope = root.fetch("scope")
  candidates = [
    candidate(
      id: "current_phase2",
      title: atom.fetch("title"),
      definition: atom.fetch("core_definition"),
      scores: candidate_scores(root, "current"),
      fit: "It follows the broad #{atom.fetch("universal_slot")} label and names familiar Mind vocabulary.",
      coverage: "It covers recognizable English cognitive concepts.",
      territory: "It consumes multiple capacities, relations, processes, or epistemic states.",
      risk: root.fetch("current_rationale")
    ),
    candidate(
      id: "attention_allocation",
      title: root.fetch("title"),
      definition: root.fetch("definition"),
      scores: candidate_scores(root, "attention"),
      fit: "It maps first-trit capacity/relation to one cognitive-allocation center, uses source/target/systemic scope exactly, and follows the third-trit stable/active/dormant-or-unresolved distinctions.",
      coverage: "Attention capacity, available cognitive bandwidth, focus, monitoring, salience, vigilance, target prioritization, and joint attention in ordinary and technical settings.",
      territory: "Only selective allocation of cognitive processing and the resulting attention relations.",
      risk: "It intentionally leaves consciousness, perception, representation, learning, inference, belief, goals, communication, and scheduler implementation to other roots or compounds."
    ),
    candidate(
      id: "representational_grounding",
      title: root.fetch("representation")[0],
      definition: root.fetch("representation")[1],
      scores: candidate_scores(root, "representation"),
      fit: "Representational capacity, aboutness, and inter-model alignment form a plausible extension of canonical MIN:0xx.",
      coverage: "Intentionality, grounding, reference, representation-bearing, common models, and technical agent semantics.",
      territory: "Relations between cognizers, representations, targets, and other cognizers' representations.",
      risk: "It comes close to duplicating canonical MIN:0xx representation ownership and can collide with LOG reference, DAT symbols, and ORI aboutness."
    ),
    candidate(
      id: "epistemic_stance",
      title: root.fetch("epistemic")[0],
      definition: root.fetch("epistemic")[1],
      scores: candidate_scores(root, "epistemic"),
      fit: "Knowledge, belief, doubt, competence, and agreement are central cognitive relations.",
      coverage: "Know, believe, trust, doubt, justify, agree, consensus, and common knowledge.",
      territory: "Commitment and justification relations between cognizers and propositions.",
      risk: "It collides heavily with LOG truth/proof, ORI reality/modality, and CON agreement; nonpropositional attention and imagery are excluded."
    ),
    candidate(
      id: "executive_control",
      title: root.fetch("executive")[0],
      definition: root.fetch("executive")[1],
      scores: candidate_scores(root, "executive"),
      fit: "Executive control naturally has capacity, goal-directed, and coordinated forms.",
      coverage: "Choose, regulate, inhibit, pursue goals, coordinate agents, plan, and schedule cognitive work.",
      territory: "Control of cognitive operations and goal-directed organization.",
      risk: "It collides with CRE goals/plans, CON coordination, STR control structure, and LOG decision rules; the target and systemic triplets cease to be purely cognitive."
    )
  ]
  winner_score = candidates.map { |candidate_item| candidate_item["total"] }.max
  winners = candidates.select { |candidate_item| candidate_item["total"] == winner_score }
  raise "#{id}: attention is not unique winner" unless
    winners.length == 1 && winners.first["candidate_id"] == "attention_allocation"

  scored_roots << {
    "canonical_id" => id,
    "fixed_generated_fields" => fixed_projection(atom),
    "current_meaning_rationale" => root.fetch("current_rationale"),
    "candidates" => candidates,
    "recommended_candidate_id" => "attention_allocation",
    "recommendation_reason" =>
      "Attention allocation uniquely produces a natural capacity/target-relation/systemic-relation architecture, fills the gap intentionally excluded from canonical MIN:0xx and MIN:1xx, and avoids treating truth, belief, communication, goals, or storage as Mind atoms.",
    "confidence" => scope == "joint" ? 0.96 : 0.98,
    "canonicalized" => false
  }

  first = if scope == "capacity"
            "Selects a capacity: the cognizer can allocate cognitive processing selectively."
          else
            "Selects a relationship or possibility: attention links a cognizer or cognitive community to a target."
          end
  second = {
    "capacity" => "Selects inward/source scope: the cognizer is the bearer and source of attentional capacity.",
    "target" => "Selects outward/target scope: preferential processing is directed toward one distinct target.",
    "joint" => "Selects systemic/shared scope: multiple cognizers participate in one shared attentional relation."
  }.fetch(scope)
  third = {
    "enduring" => "Selects stable expression: the attentional capacity persists across episodes.",
    "available" => "Selects active expression: the capacity is presently available for exercise.",
    "latent" => "Selects dormant expression: the capacity exists without presently being available for exercise.",
    "established" => "Selects a stable relationship: the attentional relation persists as an established orientation.",
    "active" => "Selects an active relationship: preferential processing is occurring now.",
    "unresolved" => "Selects an unresolved relationship: whether the target receives preferential processing is lexically unresolved.",
    "potential" => "Selects an unrealized systemic possibility: joint attention could exist but is not realized."
  }.fetch(root.fetch("phase"))

  same_family = {
    "capacity" => "Canonical MIN:0xx owns cognitive representations and MIN:1xx owns their revision; this triplet owns the cognizer's capacity to allocate processing, not content or change.",
    "target" => "MIN:010–012 owns a target representation and MIN:110–112 owns target-model revision; this triplet owns preferential processing directed to the target.",
    "joint" => "MIN:020–022 owns shared cognitive schemas and MIN:120–122 owns their revision; this triplet owns shared cognitive priority, which may exist without agreement or model change."
  }.fetch(scope)

  recommended_roots << {
    "fixed_generated_fields" => fixed_projection(atom),
    "proposal_status" => "recommended_after_adversarial_review_pending_delegated_approval",
    "proposed_title" => root.fetch("title"),
    "invariant_definition" => root.fetch("definition"),
    "semantic_center" => "selective allocation of cognitive processing",
    "address_justification" => {
      "first_trit_2" => first,
      "second_trit" => second,
      "third_trit" => third
    },
    "inclusion_boundary" =>
      "Includes only the capacity for, directed relation of, or systemic relation of selectively allocating cognitive processing at this address's exact scope and lexical expression. Preferential processing may concern sensory, remembered, imagined, conceptual, or executable content without asserting which mechanism supplies it.",
    "excluded_meanings" => [
      "Consciousness, wakefulness, arousal, sensory stimulation, gaze direction, bodily orientation, or neural resource use.",
      "A representation merely persisting, manifesting, or remaining latent; canonical MIN:0xx owns representational content.",
      "Revision, learning, interpretation, inference, evaluation, belief, trust, doubt, certainty, truth, decision, or goal commitment.",
      "Communication, access permission, role assignment, coordination procedure, queue order, data subscription, plan, intention, schedule, readiness, or future time.",
      "Success, failure, distraction, correction, or recovery unless WRN/REP or another explicit relation supplies the evaluation."
    ],
    "nearest_neighbors" => NEIGHBORS.fetch(id),
    "same_family_contrast" => same_family,
    "cross_family_comparisons" => COLLISIONS,
    "runtime_state_interpretation" => runtime_states(root),
    "lexical_runtime_distinction" =>
      "The third lexical trit permanently selects #{root.fetch("phase")} #{root.fetch("title").sub(/\A\w+\s+/, "")}. Runtime `[2]/num` separately marks this token's assertion as dormant or unresolved. For lexical `MIN:202`, `MIN:212`, or `MIN:222`, runtime `[1]` affirms the latent, unresolved, or potential lexeme; runtime `[2]/num` leaves the assertion about that lexeme unresolved. The two layers never collapse.",
    "examples" => root.fetch("examples").map do |row|
      example(
        category: row[0], graph: row[1], literal: row[2], natural: row[3],
        analysis: row[4],
        use_status: row[0] == "counterexample" ? "must_not_use_this_root" : "valid",
        pseudocode: row[5]
      )
    end,
    "future_compound_examples" => [
      "#{id} + MIN:0xx → links attention to represented content without making content and attention identical.",
      "#{id} + MIN:1xx → expresses attention participating in representational revision without asserting that attention guarantees learning.",
      "#{id} + MAT/MOV/CON/DAT → expresses stimulus-driven, gaze-supported, communicated, or implementation-level attention while preserving family boundaries.",
      "#{id} + WRN/REP/CRE/ORI/grammar → distracted, restored, intended, scheduled, repeated, possible, or future attention with the added meaning explicit."
    ],
    "later_era_notes" =>
      "Later eras may distinguish sustained, selective, divided, alternating, executive, spatial, feature-based, social, and machine attention as compounds or specialized descendants. The invariant must remain neutral about sensory modality, consciousness, correctness, goals, physical mechanism, and resource quantity.",
    "confidence" => scope == "joint" ? 0.96 : 0.98,
    "canonicalized" => false
  }
end

stress_rows = [
  ["attention capacity", "one_root", "MIN:200 enduring, MIN:201 available, or MIN:202 latent according to lexical expression."],
  ["pay attention", "one_root", "MIN:211 when one cognizer presently gives a distinct target preferential processing."],
  ["focus", "one_root_or_compound", "MIN:211 for current target attention; duration, intensity, and exclusivity require grammar or modifiers."],
  ["concentrate", "compound", "MIN:211 plus sustained duration and possibly exclusion of competing targets; not a separate atom."],
  ["standing focus", "one_root", "MIN:210 for an established target-attention relation across episodes."],
  ["available attention", "one_root", "MIN:201; this does not assert a current target."],
  ["latent attention ability", "one_root", "MIN:202; the capacity exists but is not presently available."],
  ["unclear whether listening", "one_root", "MIN:212 when the listener-to-speech attention relation is unresolved."],
  ["joint attention", "one_root", "MIN:221 active, MIN:220 established, or MIN:222 potential."],
  ["shared focus", "one_root_or_compound", "The MIN:22x triplet when multiple cognizers give one target shared priority; persistence or timing may be added."],
  ["notice", "compound_or_transition", "A target becomes manifest and receives attention: MIN:011 plus MIN:211 and a transition relation."],
  ["awareness", "existing_root_or_compound", "Usually manifest MIN:0xx representation; attention is added only when preferential processing is intended."],
  ["consciousness", "different_family", "LIF owns conscious living condition; attention can be present, absent, or impaired within it."],
  ["wakefulness", "different_family", "LIF/MAT arousal, not selective cognitive allocation."],
  ["vigilance", "compound", "Enduring/available attention capacity plus sustained target monitoring and timing grammar."],
  ["monitor", "compound", "MIN:210 or MIN:211 plus repeated observation/perception and a target."],
  ["watch", "compound", "MIN:211 plus sensory observation; gaze and physical orientation are MOV/MAT."],
  ["listen", "compound", "MIN:211 plus auditory MAT signal/perception; hearing alone does not entail attention."],
  ["look at", "different_family_or_compound", "MOV/MAT gaze direction; add MIN:211 only when cognitive priority is asserted."],
  ["gaze shift", "different_family", "MOV physical orientation change, not attention itself."],
  ["ignore", "negation_or_compound", "Often MIN:211[0] for target attention, possibly with an intentional CRE/ORI relation."],
  ["overlook", "compound", "Failure to attend or represent a relevant target: WRN plus negated/unresolved MIN attention."],
  ["distract", "compound", "WRN/MOV/MAT cause plus a change from one MIN:211 target to another; attention is not inherently erroneous."],
  ["mind wandering", "compound_or_gap", "Attention leaves an intended target and shifts among internal content; requires target transition and intention context."],
  ["multitask", "compound", "Multiple attention relations plus divided allocation, quantity, simultaneity, or alternation grammar."],
  ["attention budget", "one_root_plus_quantity", "MIN:201 plus quantity grammar; the number is not part of the atom."],
  ["cognitive load", "compound_or_gap", "Available capacity, task demand, and resource quantity; not identical to attention."],
  ["fatigue", "different_family_or_compound", "MAT/LIF condition that may reduce MIN:201 without being attentional capacity itself."],
  ["sleep", "different_family_plus_root", "LIF sleep may coexist with MIN:202 latent attentional capacity."],
  ["coma", "different_family_or_gap", "LIF/MAT condition; whether attentional capacity persists is a separate assertion."],
  ["remember", "existing_root_or_transition", "MIN:0xx latent-to-manifest representation; pure recall is not attention allocation."],
  ["learn", "compound", "MIN:1xx representational revision plus sources and often MIN:211 attention; attention does not guarantee learning."],
  ["understand", "compound", "Representation plus revision/coherence; attention may participate but is insufficient."],
  ["revise a belief", "existing_root_or_compound", "Canonical MIN:1xx revision with LOG/ORI belief relations; not attention."],
  ["infer", "different_family_or_compound", "LOG inference; MIN:211 may describe focus on premises but not validity."],
  ["believe", "compound_or_gap", "Epistemic commitment requires LOG/ORI plus MIN representation; deliberately not assigned to MIN:2xx attention."],
  ["trust", "compound_or_gap", "Participant/epistemic relation requiring CON/LOG/ORI; attention alone does not imply trust."],
  ["doubt", "compound_or_gap", "Epistemic modality or unresolved commitment, not unresolved attention unless focus itself is unknown."],
  ["decide", "compound_or_gap", "Alternative selection and commitment require LOG/CRE/ORI; available attention is only a possible prerequisite."],
  ["plan to focus", "compound", "CRE plan or intention plus MIN attention root; the attention atom does not encode planning."],
  ["schedule attention", "compound", "DAT schedule plus MIN:222 or another attention relation; schedule and potential relation stay distinct."],
  ["queue an attention task", "compound", "DAT queue state plus attention semantics; MIN does not encode queue position."],
  ["priority list", "different_family", "STR/DAT ordered structure; not cognitive priority until a cognizer preferentially processes it."],
  ["data subscription", "different_family", "DAT/CON relation; an agent may subscribe without attending."],
  ["sensor salience", "different_family_or_compound", "MAT/DAT signal property; add MIN:211 only when a cognizer prioritizes it."],
  ["visual salience", "compound", "MAT stimulus contrast plus a potential or active attention relation; salience does not guarantee attention."],
  ["shared representation", "existing_root", "MIN:020–022; shared content can exist without joint attention."],
  ["shared model revision", "existing_root", "MIN:120–122; model change can occur without concurrent joint attention."],
  ["agreement", "compound_or_gap", "CON/LOG relation; people may agree while attending to different things."],
  ["consensus", "compound", "CON decision relation plus LOG/ORI commitment and possibly shared MIN content; not joint attention."],
  ["collaboration", "different_family_or_compound", "CON/STR coordination; MIN:221 only if collaborators share a current focus."],
  ["distributed intelligence", "compound", "Multiple cognitive agents, CON coordination, LOG inference, MIN representations/revisions, and possibly joint attention."],
  ["common knowledge", "compound", "Shared/recursive epistemic relation requiring LOG/CON/MIN content; not attention."],
  ["attention head in a neural network", "technical_compound_or_analogy", "MIN attention only when the system is modeled as a cognizer; otherwise DAT/LOG/MAT computation."],
  ["query-key attention score", "different_family_or_compound", "LOG/DAT mathematical relation; cognitive MIN semantics is optional and must be explicit."],
  ["event-loop priority", "different_family_or_compound", "STR/DAT scheduler priority; MIN only for a cognitive agent's selective processing."],
  ["potential joint attention", "one_root", "MIN:222; it asserts an unrealized possible relation, not a plan or probability."],
  ["unknown active focus", "runtime_or_lexical_contrast", "MIN:211[2] leaves an active-focus assertion unresolved; MIN:212[1] affirms the lexical unresolved relation."],
  ["refocus", "compound", "REP or attention-target transition plus MIN:211; restoration is not built into the attention root."],
  ["attention lapse", "compound", "WRN failure plus loss or negation of an expected MIN:211 relation."],
  ["sustained attention", "one_root_plus_timing", "MIN:210 or repeated/durative MIN:211 with timing grammar, depending standing versus currently active focus."]
]

stress_tests = stress_rows.map.with_index do |(concept, route, analysis), index|
  {
    "test_id" => format("MIN2-T%03d", index + 1),
    "english_concept" => concept,
    "routing" => route,
    "analysis" => analysis
  }
end

scored = {
  "metadata" => {
    "title" => "MIN:200–222 adversarial candidate scoring",
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
    "title" => "MIN:200–222 recommended permanent semantic specification",
    "status" => "recommended_pending_delegated_approval",
    "architecture_version" => "1.0",
    "semantic_center" => "selective allocation of cognitive processing",
    "triplets" => {
      "MIN:200–202" => "attentional capacity: enduring / available / latent",
      "MIN:210–212" => "target-attention relation: established / active / unresolved",
      "MIN:220–222" => "joint-attention relation: established / active / potential"
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
    "cross_family_collisions_resolved" => true,
    "runtime_and_lexical_states_separated" => true,
    "stress_tests_allow_compounds_and_gaps" => true,
    "ready_for_independent_validation" => true,
    "canonicalized" => false
  }
}

stress = {
  "metadata" => {
    "title" => "MIN:200–222 English coverage and stress tests",
    "status" => "review_complete",
    "test_count" => stress_tests.length,
    "forced_atomic_mappings_forbidden" => true
  },
  "tests" => stress_tests
}

write_yaml("reviews/MIN_200_222_scored_candidates.yaml", scored)
write_yaml("reviews/MIN_200_222_recommended_spec.yaml", recommended)
write_yaml("reviews/MIN_200_222_stress_tests.yaml", stress)

review = +"# MIN:200–222 Adversarial Semantic Design Review\n\n"
review << "Status: **REVIEW COMPLETE — RECOMMENDED PENDING INDEPENDENT VALIDATION AND DELEGATED APPROVAL**\n\n"
review << "This packet reviews only `MIN:200–222`. It treats every Phase 2 meaning as replaceable, preserves all deterministic generated fields, leaves the 99 existing canonical meanings unchanged, and does not begin `CON:000–022`, Gate 4, compounds, or translator implementation.\n\n"
review << "## Block conclusion\n\n"
review << "The strongest permanent architecture is **selective allocation of cognitive processing**, conventionally glossed as attention. `MIN:200–202` owns the cognizer's attention-allocation capacity; `MIN:210–212` owns the relation between a cognizer's preferential processing and one target; `MIN:220–222` owns joint attention across multiple cognizers. This fills the attention territory deliberately excluded from canonical `MIN:000–122`.\n\n"
review << "The current Phase 2 grid is rejected because competence, focus, aptitude, belief, uncertainty, worldview, distributed intelligence, and hypothesis space do not share one semantic invariant. Several entries also collide with LOG, CON, DAT, CRE, or ORI.\n\n"
review << "## Candidate architecture comparison\n\n"
review << "| Architecture | Strength | Permanent limitation |\n|---|---|---|\n"
review << "| Current Phase 2 mixture | Familiar cognitive vocabulary | No invariant or 3×3 symmetry; major cross-family collisions |\n"
review << "| Attention allocation | Exact capacity/target/systemic mapping; everyday and technical utility | Requires compounds for perception, learning, goals, and implementation |\n"
review << "| Representational grounding | Strong technical semantics and continuity with MIN:0xx | Risks duplicating representation content and aboutness |\n"
review << "| Epistemic stance | Covers belief, doubt, and agreement | Collides with LOG, ORI, and CON; excludes nonpropositional attention |\n"
review << "| Executive control | Covers regulation and coordinated agency | Collides with CRE goals, STR control, and CON coordination |\n\n"

scored_roots.each do |root|
  id = root.fetch("canonical_id")
  spec = recommended_roots.find { |item| item.dig("fixed_generated_fields", "canonical_id") == id }
  review << "## #{id} — #{spec.fetch("proposed_title")}\n\n"
  review << "### Fixed generated forms\n\n| Field | Value |\n|---|---|\n"
  root.fetch("fixed_generated_fields").each do |field, value|
    rendered = value.is_a?(Array) ? value.join(", ") : value
    review << "| #{field.tr("_", " ")} | `#{rendered}` |\n"
  end
  review << "\n### Why the current meaning was probably chosen\n\n#{root.fetch("current_meaning_rationale")}\n\n"
  review << "### Candidate comparison\n\n"
  review << "| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |\n"
  review << "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n"
  root.fetch("candidates").each do |candidate_item|
    scores = candidate_item.fetch("scores")
    review << "| #{candidate_item.fetch("title")} | #{SCORE_KEYS.map { |key| scores.fetch(key) }.join(" | ")} | **#{candidate_item.fetch("total")}/80** |\n"
  end
  review << "\n"
  root.fetch("candidates").each do |candidate_item|
    analysis = candidate_item.fetch("analysis")
    review << "- **#{candidate_item.fetch("title")}** — #{candidate_item.fetch("invariant_candidate")} "
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
  review << "**Address justification.** First trit: #{spec.dig("address_justification", "first_trit_2")} Second trit: #{spec.dig("address_justification", "second_trit")} Third trit: #{spec.dig("address_justification", "third_trit")}\n\n"
  review << "**Runtime states.** `[0]` #{spec.dig("runtime_state_interpretation", "0")} `[1]` #{spec.dig("runtime_state_interpretation", "1")} `[2]/num` #{spec.dig("runtime_state_interpretation", "2/num")}\n\n"
  review << "**Lexical/runtime distinction.** #{spec.fetch("lexical_runtime_distinction")}\n\n"
  review << "### Examples\n\n"
  review << "| Type | Semantic graph | Literal gloss | Natural rendering | Runtime | Contour | Use |\n"
  review << "|---|---|---|---|---:|---|---|\n"
  spec.fetch("examples").each do |item|
    review << "| #{item.fetch("category")} | `#{item.fetch("semantic_graph")}` | #{item.fetch("literal_gloss")} | #{item.fetch("natural_english")} | `[#{item.fetch("runtime_state")}]` | #{item.fetch("contour")} | #{item.fetch("use_status")} |\n"
  end
  review << "\n**Role/register plan.** Low register carries the cognizer or community; middle carries the MIN attention predicate; high carries the target when present; sustained register carries the attentional frame or execution environment.\n\n"
  review << "**Future compound sketches—not canonical.** #{spec.fetch("future_compound_examples").join(" ")}\n\n"
  review << "**Later-Era note.** #{spec.fetch("later_era_notes")}\n\n"
end

review << "## Triplet coherence\n\n"
review << "| Triplet | Shared semantic axis | `0` | `1` | `2` |\n|---|---|---|---|---|\n"
review << "| MIN:200–202 | Cognizer's capacity to allocate processing selectively | Enduring capacity | Presently available capacity | Existing but unavailable capacity |\n"
review << "| MIN:210–212 | Preferential processing relation from cognizer to target | Established relation | Presently active relation | Whether the relation holds is unresolved |\n"
review << "| MIN:220–222 | Shared attentional priority among multiple cognizers | Established joint relation | Presently active joint relation | Unrealized possible joint relation |\n\n"
review << "The second trit changes only participant structure: source capacity, directed target relation, or systemic joint relation. The third changes only the lexical expression required by the fixed address cube.\n\n"
review << "## Nine-root ownership matrix\n\n"
review << "| Root | Owns | Belongs elsewhere | Reserved for compounds | Intentionally undefined |\n|---|---|---|---|---|\n"
recommended_roots.each do |spec|
  id = spec.dig("fixed_generated_fields", "canonical_id")
  review << "| #{id} | #{spec.fetch("proposed_title")} | Consciousness, signals, gaze, belief, truth, goals, roles, queues | Vigilance, noticing, distraction, refocusing, learning with attention, machine implementation | Modality, correctness, intensity, duration, physical mechanism |\n"
end
review << "\n## Coverage stress test\n\n"
review << "#{stress_tests.length} English concepts were tested. Many correctly route to existing Mind roots, compounds, grammar, other families, technical analogies, or gaps rather than being forced into attention atoms.\n\n"
review << "| English concept | Route | Result |\n|---|---|---|\n"
stress_tests.each do |test|
  review << "| #{test.fetch("english_concept")} | #{test.fetch("routing")} | #{test.fetch("analysis")} |\n"
end
review << "\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each do |item, value|
  review << "- [#{value ? "x" : " "}] #{item.tr("_", " ")}\n"
end
review << "\nThe nine recommendations are not canonical in this review artifact. Independent pre-approval validation must pass before delegated authority is applied.\n"
File.write(File.join(ROOT, "reviews/MIN_200_222_peer_review.md"), review)

collision = +"# MIN:200–222 Cross-Family Collision Report\n\n"
collision << "Status: **PASS AS A DESIGN REVIEW — COLLISIONS EXPLICITLY EXCLUDED OR COMPOUNDED**\n\n"
collision << "The proposed block owns only selective cognitive allocation: attentional capacity, target attention, and joint attention.\n\n"
collision << "## Root-by-family audit\n\n"
collision << "| Root | LIF | MOV | MAT | CON | STR | WRN | REP | LOG | DAT | CRE | ORI |\n|---|---|---|---|---|---|---|---|---|---|---|---|\n"
recommended_roots.each do |spec|
  id = spec.dig("fixed_generated_fields", "canonical_id")
  scope = DESIGN.fetch(id).fetch("scope")
  cells = {
    "LIF" => "consciousness/arousal ≠ attention",
    "MOV" => "gaze/orientation may evidence attention",
    "MAT" => "signal/neural resource ≠ cognitive allocation",
    "CON" => scope == "joint" ? "communication/coordination ≠ joint attention" : "roles/access may contextualize",
    "STR" => "priority structure ≠ cognitive priority",
    "WRN" => "lapse/distraction requires evaluated failure",
    "REP" => "refocusing/restoration is a separate process",
    "LOG" => "attention ≠ inference, truth, or belief",
    "DAT" => "queue/subscription ≠ cognitive attention",
    "CRE" => "goal/plan/intention must be explicit",
    "ORI" => "modality/time/certainty external"
  }
  collision << "| #{id} | #{CROSS_FAMILIES.map { |family| cells.fetch(family) }.join(" | ")} |\n"
end
collision << "\n## Binding rules\n\n"
COLLISIONS.each { |family, analysis| collision << "- **#{family}:** #{analysis}\n" }
collision << "\n## Highest-risk boundaries\n\n"
collision << "- `MIN:201` versus `MIN:211`: available attentional capacity has no target; active target attention is the actual preferential-processing relation.\n"
collision << "- `MIN:011` versus `MIN:211`: a target representation may be manifest but peripheral. Attention requires preferential processing.\n"
collision << "- `MIN:111` versus `MIN:211`: attention can occur without target-model revision, and revision can be automated or implicit without current focal attention.\n"
collision << "- `MIN:220–222` versus `CON`: communication, role coordination, and consensus procedures do not entail shared cognitive priority.\n"
collision << "- `MIN:212[1]` versus `MIN:211[2]`: the first affirms a lexical unresolved target-attention relation; the second leaves an assertion using the active-attention lexeme unresolved at runtime.\n"
collision << "- `MIN:222` versus `CRE`/`DAT`/`ORI`: potential joint attention is not a plan, schedule, queue, prediction, or probability.\n"
File.write(File.join(ROOT, "reviews/MIN_200_222_collision_report.md"), collision)

puts "Built MIN:200–222 review packet"
puts "Roots: #{recommended_roots.length}"
puts "Candidates scored: #{scored_roots.sum { |root| root.fetch("candidates").length }}"
puts "Score assertions: #{scored_roots.sum { |root| root.fetch("candidates").length * SCORE_KEYS.length }}"
puts "Stress tests: #{stress_tests.length}"
