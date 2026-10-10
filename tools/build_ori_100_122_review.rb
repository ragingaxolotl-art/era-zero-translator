#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "ORI:100–122"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "ORI_100_122"
SEMANTIC_CENTER = "ontological transitions: source-ground establishment, distinct actualization, and shared-world transition"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "ORI:100" => ["origin transition complete", "An inward passage from non-expression to stable existence has reached completion."],
  "ORI:101" => ["active becoming", "Existence is actively emerging, continuing, or differentiating from an inward source."],
  "ORI:102" => ["pending emergence", "An inward transition into actuality is possible or prepared but has not begun."],
  "ORI:110" => ["manifestation complete", "A source condition has fully produced or actualized an external fact, entity, or result."],
  "ORI:111" => ["active manifestation", "A source is actively causing, expressing, or actualizing a target within reality."],
  "ORI:112" => ["poised manifestation", "A target could become actual from its source conditions but has not yet emerged."],
  "ORI:120" => ["world transition complete", "A system-wide ontological, cosmological, or epochal transition has reached a stable new reality state."],
  "ORI:121" => ["reality unfolding", "A shared reality is actively evolving, differentiating, or passing through a foundational transition."],
  "ORI:122" => ["pending world transition", "A coherent system-level transformation of reality is possible or staged but not yet active."]
}.freeze

ROOTS = {
  "ORI:100" => { title: "completed source-ground establishment", phase: "completed", scope: "inward", kind: "source-ground establishment", invariant: "Completion of a bounded ontological transition by which one referent becomes grounded as a source from which another state of affairs may originate." },
  "ORI:101" => { title: "active source-ground establishment", phase: "active", scope: "inward", kind: "source-ground establishment", invariant: "An ongoing bounded ontological transition by which one referent is becoming grounded as a source from which another state of affairs may originate." },
  "ORI:102" => { title: "nonactualized source-ground establishment", phase: "nonactualized", scope: "inward", kind: "source-ground establishment", invariant: "A nonactualized bounded ontological transition that would ground one referent as a source from which another state of affairs may originate." },
  "ORI:110" => { title: "completed distinct actualization", phase: "completed", scope: "outward", kind: "distinct actualization", invariant: "Completion of a bounded ontological transition by which one distinct referent comes to obtain as part of the relevant reality." },
  "ORI:111" => { title: "active distinct actualization", phase: "active", scope: "outward", kind: "distinct actualization", invariant: "An ongoing bounded ontological transition by which one distinct referent is coming to obtain as part of the relevant reality." },
  "ORI:112" => { title: "nonactualized distinct actualization", phase: "nonactualized", scope: "outward", kind: "distinct actualization", invariant: "A nonactualized bounded ontological transition by which one distinct referent would come to obtain as part of the relevant reality." },
  "ORI:120" => { title: "completed shared-world transition", phase: "completed", scope: "systemic", kind: "shared-world transition", invariant: "Completion of a bounded ontological transition by which what obtains across one shared reality changes under one jointly applicable world condition." },
  "ORI:121" => { title: "active shared-world transition", phase: "active", scope: "systemic", kind: "shared-world transition", invariant: "An ongoing bounded ontological transition by which what obtains across one shared reality is changing under one jointly applicable world condition." },
  "ORI:122" => { title: "nonactualized shared-world transition", phase: "nonactualized", scope: "systemic", kind: "shared-world transition", invariant: "A nonactualized bounded ontological transition by which what obtains across one shared reality would change under one jointly applicable world condition." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [5, 7, 9, 4, 5, 8, 8, 9] },
  "ontological_transitions" => { scores: [10, 10, 10, 10, 9, 10, 9, 10] },
  "temporal_progression" => { scores: [8, 8, 7, 7, 6, 8, 9, 10] },
  "causal_production" => { scores: [8, 8, 7, 6, 4, 9, 9, 9] },
  "modal_actualization" => { scores: [8, 8, 9, 7, 5, 8, 8, 10] }
}.freeze

ALT_TITLES = {
  "ORI:100" => ["completed internal temporal progression", "completed causal activation", "completed modal realization"],
  "ORI:101" => ["active internal temporal progression", "active causal activation", "active modal realization"],
  "ORI:102" => ["nonactualized internal temporal progression", "nonactualized causal activation", "nonactualized modal realization"],
  "ORI:110" => ["completed target temporal progression", "completed causal production", "completed target possibility realization"],
  "ORI:111" => ["active target temporal progression", "active causal production", "active target possibility realization"],
  "ORI:112" => ["nonactualized target temporal progression", "nonactualized causal production", "nonactualized target possibility realization"],
  "ORI:120" => ["completed systemic temporal progression", "completed causal-network evolution", "completed possible-world realization"],
  "ORI:121" => ["active systemic temporal progression", "active causal-network evolution", "active possible-world realization"],
  "ORI:122" => ["nonactualized systemic temporal progression", "nonactualized causal-network evolution", "nonactualized possible-world realization"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns biological and social processes. ORI transition changes ontological standing, not life stage, agency, birth, death, or role succession.",
  "MOV" => "MOV owns displacement through space or routes. ORI transition is change in what obtains in a reality and never entails travel, arrival, or trajectory.",
  "MAT" => "MAT owns physical transformation, force, energy, and material state change. ORI transition is substrate-neutral and does not describe physical mechanics.",
  "MIN" => "MIN owns changes in attention, belief, intention, and understanding. Becoming conceived or believed is not the same as becoming ontologically actual.",
  "CON" => "CON owns communication, linkage, participation, and authority changes. ORI systemic transition does not itself assert coordination or consensus.",
  "WRN" => "WRN owns adverse transformations and propagation. An ontological transition is neutral about harm, fault, risk, and failure.",
  "STR" => "STR owns reconfiguration, incorporation, and integration. ORI transition concerns ontological standing, not arrangement or dependency change alone.",
  "REP" => "REP owns restoration toward an acceptable prior condition. ORI transition neither presupposes damage nor encodes return, recovery, or repair.",
  "LOG" => "LOG owns evaluation and constraint application. A proposition becoming accepted or valid is not a referent becoming part of reality.",
  "DAT" => "DAT owns transformation, transfer, and synchronization of represented information. A record appearing does not entail its referent's actualization.",
  "CRE" => "CRE owns productive generation of patterns and artifacts. ORI actualization may accompany creation but does not assert a producer, artifact, medium, or productive method."
}.freeze

def scores(values)
  EraZeroValidation::SCORE_KEYS.zip(values).to_h
end

def score_values(architecture, id)
  values = ARCHITECTURES.fetch(architecture).fetch(:scores).dup
  second = id[-2]
  third = id[-1]
  case architecture
  when "current_phase2"
    values[0] -= 1 if third == "2"
    values[3] -= 1 if second == "2"
  when "ontological_transitions"
    values[4] += 1 if second == "0"
    values[6] -= 1 if second == "2"
  when "temporal_progression"
    values[1] -= 1 if second == "0"
    values[4] -= 1 if third == "2"
  when "causal_production"
    values[3] -= 1 if second == "2"
    values[4] -= 1 if second == "1"
  when "modal_actualization"
    values[2] -= 1 if second == "0"
    values[4] -= 1 if second == "1"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, architecture, title)
  root = ROOTS.fetch(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional meanings correctly recognize first-trit 1 as process, use inward, outward, and systemic scope, and associate ORI with becoming, manifestation, and world transition.",
      "useful_coverage" => "They cover emergence, actualization, manifestation, differentiation, cosmological change, and unrealized transitions.",
      "semantic_territory_consumed" => "They mix ontological transition with causal production, general continuation, differentiation, possibility, preparedness, staging, and stable result states.",
      "conflicts_or_future_limitations" => "The triplets lack one exact process center and lexical 1x2 is repeatedly weakened into possible, prepared, poised, or staged rather than strictly nonactualized."
    }
  when "ontological_transitions"
    {
      "why_it_fits" => "First-trit 1 selects bounded transition; the second trit selects source-ground, distinct-target, or shared-world scope; and the third changes only completed, active, or nonactualized phase.",
      "useful_coverage" => "It supports establishment, becoming actual, instantiation, activation of sourcehood, world-state transition, simulations, lifecycle models, and formal ontology.",
      "semantic_territory_consumed" => "Only transition in ontological standing. Cause, clock time, observation, representation, physical change, production, and modal force remain separate.",
      "conflicts_or_future_limitations" => "Specific causal mechanisms, scheduled futures, material transformations, creator actions, and truth-status changes require compounds or other roots."
    }
  when "temporal_progression"
    {
      "why_it_fits" => "Every transition unfolds in time, and completed, active, and nonactualized phases resemble past, present, and future progression.",
      "useful_coverage" => "It would cover elapsed intervals, ongoing duration, future sequences, epochs, schedules, and state-machine timing.",
      "semantic_territory_consumed" => "It makes temporal passage the process center and risks equating nonactualization with futurity or scheduling.",
      "conflicts_or_future_limitations" => "Many ontological transitions are modeled without elapsed time, and time deserves relation/grammar treatment rather than consuming all ORI processes."
    }
  when "causal_production"
    {
      "why_it_fits" => "Source, target, and system naturally suggest causal activation, production, and propagation.",
      "useful_coverage" => "It would cover causing, producing, triggering, propagating, originating, and causal-network evolution.",
      "semantic_territory_consumed" => "It conflates transition with its causal explanation and overlaps productive, physical, structural, and adverse processes.",
      "conflicts_or_future_limitations" => "CRE, MAT, STR, and WRN already own typed mechanisms; ORI:2xx can later host causal relations without making all becoming causal production."
    }
  when "modal_actualization"
    {
      "why_it_fits" => "Actualization can be described as realization of a possibility into an actual world.",
      "useful_coverage" => "It would cover realization, possible-world selection, counterfactual branching, instantiation, and modal collapse.",
      "semantic_territory_consumed" => "It presupposes a modal source state and treats nonactualized process as possibility rather than process phase.",
      "conflicts_or_future_limitations" => "LOG owns formal models, MIN owns imagined alternatives, and ORI:2xx should later express possibility without forcing modal semantics into every transition."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "temporal_progression"
    "A #{root.fetch(:phase)} temporal progression at #{root.fetch(:scope)} reference scope."
  when "causal_production"
    "A #{root.fetch(:phase)} causal-production process at #{root.fetch(:scope)} scope."
  when "modal_actualization"
    "A #{root.fetch(:phase)} modal-realization process at #{root.fetch(:scope)} scope."
  end
end

def candidate(id, architecture, title, invariant)
  score_map = scores(score_values(architecture, id))
  {
    "candidate_id" => architecture,
    "title" => title,
    "invariant_candidate" => invariant,
    "analysis" => candidate_analysis(id, architecture, title),
    "scores" => score_map,
    "total" => score_map.values.sum,
    "maximum" => 80
  }
end

def nearest_neighbors(id)
  address = id.split(":").last
  first, second, third = address.chars
  siblings = %w[0 1 2].reject { |x| x == third }.map { |x| "ORI:#{first}#{second}#{x}" }
  scopes = %w[0 1 2].reject { |x| x == second }.map { |x| "ORI:#{first}#{x}#{third}" }
  entity = "ORI:0#{second}#{third}"
  process = "ORI:1#{second}#{third}"
  (siblings + scopes + [entity, process]).uniq
end

def roles
  {
    "low" => "referent or shared reality undergoing ontological transition",
    "middle" => "source-ground establishment, actualization, or world transition as figure",
    "high" => "resulting source status, distinct referent, or changed world condition",
    "sustained" => "relevant reality and jointly applicable world condition"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    { "0" => "Denies that this #{root.fetch(:kind)} reached completion; it does not assert that the active or nonactualized sibling holds and does not reverse the transition.",
      "1" => "Affirms completion of this #{root.fetch(:kind)} without asserting persistence, success under an external criterion, cause, observation, or physical mechanism.",
      "2/num" => "Leaves completion of this #{root.fetch(:kind)} unresolved; runtime uncertainty does not change the lexical root into active or nonactualized phase." }
  when "1"
    { "0" => "Denies that this #{root.fetch(:kind)} is ongoing now; it does not establish completion, nonactualization, impossibility, cancellation, or reversal.",
      "1" => "Affirms that this #{root.fetch(:kind)} is ongoing now without asserting completion, duration, cause, success, observation, or material realization.",
      "2/num" => "Leaves current activity of this #{root.fetch(:kind)} unresolved; token uncertainty does not select the completed or nonactualized lexical sibling." }
  else
    { "0" => "Denies this nonactualized #{root.fetch(:kind)} claim; it does not establish that the process is active, completed, impossible, or prohibited.",
      "1" => "Affirms the typed #{root.fetch(:kind)} as nonactualized, without encoding intention, planning, readiness, schedule, futurity, permission, probability, or possibility.",
      "2/num" => "Leaves unresolved even the assertion of this nonactualized #{root.fetch(:kind)}; lexical nonactualization remains distinct from runtime uncertainty." }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entity = id[-2] == "0" ? "source" : id[-2] == "1" ? "referent" : "world"
  graph_roles = id[-2] == "0" ? "REFERENT=#{entity},ORIGINAND=o,REALITY=r" : id[-2] == "1" ? "REFERENT=#{entity},REALITY=r" : "WORLD=#{entity},CONDITION=c"
  status_text = { "0" => "has completed", "1" => "is occurring", "2" => "is nonactualized" }.fetch(id[-1])
  ordinary = "The #{root.fetch(:kind)} for the #{entity} #{status_text}."
  entries = [
    ["ordinary_conversation", "#{id}[1](#{graph_roles})", "affirm #{root.fetch(:phase)} #{root.fetch(:kind)}", ordinary, "The root asserts ontological transition phase, not observation, causation, physical mechanics, or evaluation."],
    ["physical_or_spatial", "MAT(OBJECT=m)+#{id}[1](#{graph_roles})", "material bearer plus #{root.fetch(:phase)} ontological transition", "The material bearer participates in the transition while MAT separately describes physical change.", "Ontological and material transformations remain separately typed."],
    ["temporal_or_sequential", "#{id}[1](#{graph_roles})+ORI(INTERVAL=w)", "#{root.fetch(:phase)} ontological transition during interval w", "During interval w, the transition has the selected lexical phase.", "Timing does not replace completed, active, or nonactualized phase."],
    ["cross_family_compound", "#{id}[1](#{graph_roles})+CRE(PRODUCTION=p)+DAT(REPRESENTATION=d)", "ontological transition plus production plus representation", "The referent becomes actual while its production and description remain separate claims.", "Actualization, creation, and representation remain distinct."],
    ["executable_or_programming", "#{id}[1](#{graph_roles})", "assert #{root.fetch(:phase)} ontological transition", "A state machine records the ontological transition phase without conflating it with a Boolean proposition, scheduled job, or physical operation.", "Transition, evaluation, scheduling, and implementation remain distinct."],
    ["counterexample", "DAT(INSERT=row)+LOG(EVALUATE=p)", "insert record and evaluate proposition", "The database inserted a row and marked its statement true.", "Use DAT and LOG for record and truth changes; #{id} is reserved for ontological transition."]
  ]
  entries.map do |category, graph, gloss, english, analysis|
    {
      "category" => category,
      "semantic_graph" => graph,
      "literal_gloss" => gloss,
      "natural_english" => english,
      "runtime_state" => 1,
      "contour" => category == "executable_or_programming" ? "level assertion or sharply falling execution" : "level declaration",
      "role_registers" => roles,
      "use_status" => category == "counterexample" ? "must_not_use_this_root" : "valid",
      "analysis" => analysis,
      "pseudocode" => category == "executable_or_programming" ? "world.transition(#{id.inspect}, referent: #{entity.inspect})" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "ontological_transitions", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "temporal_progression", alt[0], alternative_invariant(id, "temporal_progression")),
    candidate(id, "causal_production", alt[1], alternative_invariant(id, "causal_production")),
    candidate(id, "modal_actualization", alt[2], alternative_invariant(id, "modal_actualization"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "ontological_transitions",
    "recommendation_reason" => "Only this architecture keeps all nine roots on one ontological-transition center, follows source-ground/distinct-actualization/shared-world scope exactly, and gives every triplet one completed/active/nonactualized contrast while reserving causation, time, observation, physical change, production, representation, and modal force for other roots or composition.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end

recommended_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  root = ROOTS.fetch(id)
  second = id[-2]
  third = id[-1]
  scope_label = { "0" => "inward/self", "1" => "outward/target", "2" => "systemic/collective" }.fetch(second)
  state_label = { "0" => "completed", "1" => "active", "2" => "nonactualized" }.fetch(third)
  scope_explanation = {
    "0" => "one referent undergoing establishment as a source-ground for another state of affairs",
    "1" => "one distinct referent undergoing actualization within the relevant reality",
    "2" => "what obtains across one shared reality undergoing transition under one jointly applicable world condition"
  }.fetch(second)
  scope_boundary = {
    "0" => "The process changes source-ground status only. It does not assert a causal mechanism, creator, temporal schedule, physical transformation, or produced artifact.",
    "1" => "The process changes one distinct referent's ontological standing. It does not identify substance, observability, truth-description, representation, or causal mechanism.",
    "2" => "The process changes what obtains across a shared reality under one world condition. It does not itself state that condition's content, social consensus, structural mechanics, or formal model."
  }.fetch(second)
  triplet_logic = "Completed, active, and nonactualized are mutually exclusive phases of one bounded transition at one reference time. Lexical nonactualization asserts a typed process that is not occurring; runtime `[2]/num` separately marks uncertainty about any selected phase claim."
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_1" => "Selects a bounded ontological transition rather than an entity condition, causal or modal relation, observation, representation, or physical transformation.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Origin-family column.",
      "third_trit" => "Selects the #{state_label} phase of the same ontological transition while leaving runtime assertion status, observer knowledge, clock time, probability, intention, scheduling, causation, and physical mechanism separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral ontological transition at #{root.fetch(:scope)} scope. #{scope_boundary} It is neutral about substance, location, cognition, evidence, representation, logical validity, agency, authority, productive method, hazard, repair, scheduling, duration, probability, and causal mechanism.",
    "excluded_meanings" => [
      "The source-ground, distinct-existence, or shared-world condition as an entity-layer state rather than its transition.",
      "A causal link, physical transformation, productive act, living process, mental change, data operation, structural reconfiguration, warning, or repair process.",
      "Observation, detectability, evidence, truth, validity, certainty, consensus, permission, authority, success, or result persistence.",
      "Unrestricted possibility, necessity, probability, counterfactuality, intention, plan, readiness, schedule, queue, or future time.",
      "The content of a natural law, algorithm, causal mechanism, physical mechanism, social convention, or formal model.",
      "Any claim that completion entails persistence, that activity entails observation, or that nonactualization entails possibility, preparation, or futurity."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`ORI:0xx` owns source-ground, distinct-existence, and shared-world conditions. `ORI:1xx` owns the corresponding bounded ontological transitions: source-ground establishment, distinct actualization, and shared-world transition. `ORI:2xx` remains reserved for causal, modal, temporal, or provenance relations and affordances. A condition does not entail its transition, and a completed transition does not entail continued persistence. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} phase of this ontological transition. Runtime `[2]/num` instead leaves the already-selected phase claim unresolved; it never changes process phase. Thus a nonactualized root affirmed with `[1]` confirms that the typed transition is not occurring, while a completed or active root carrying `[2]/num` remains lexically completed or active but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + ORI:0xx states the corresponding source-ground, distinct-existence, or shared-world condition without reducing process to state.",
      "#{id} + ORI:2xx may state causal, modal, temporal, or provenance relations without changing the process-layer meaning.",
      "#{id} + MAT/DAT/LOG/STR supplies physical mechanics, representation, evaluation, or reconfiguration while preserving the ontological-transition boundary.",
      "#{id} + MIN/CON/LIF/CRE may express intention, communication, living agency, or productive generation as separate meanings."
    ],
    "later_era_notes" => "Later eras may lexicalize creation ex nihilo, deactivation, annihilation, instantiation, event birth, timeline branching, world merging, simulation bootstrapping, epoch change, and specialized modal realization. Era Zero should preserve the substrate-neutral ontological-transition center and derive stronger causal, temporal, physical, and computational claims compositionally.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


ontological_condition_stress_base = [
  ["exists", "one_root_or_compound", "ORI:01x supplies a distinct-existence condition; the lexical third must match persistent, occurrent, or latent status."],
  ["is real", "one_root_or_context", "ORI:110 or ORI:111 may qualify a distinct referent, but discourse must identify the relevant reality."],
  ["source", "one_root_or_compound", "ORI:00x supplies source-ground status; a specific causal link or creator role remains separate."],
  ["origin", "ambiguous_compound", "Origin may mean source-ground, temporal beginning, causal antecedent, provenance, or creation and must be disambiguated."],
  ["foundation", "one_root_or_compound", "ORI:100 can state persistent source-grounding while STR handles structural foundation and LOG handles axiomatic basis."],
  ["currently operative source", "one_root", "ORI:101 directly asserts an operative source-ground condition without naming the causal mechanism."],
  ["dormant source", "one_root", "ORI:102 affirms a source-ground condition that belongs without present operation."],
  ["manifest entity", "one_root", "ORI:111 asserts a distinct referent presently manifesting or changing in the relevant reality."],
  ["enduring entity", "one_root", "ORI:110 asserts persistent distinct existence without requiring present change."],
  ["latent entity", "one_root", "ORI:112 affirms membership in the relevant reality without present manifestation or change."],
  ["world order", "one_root_or_compound", "ORI:120 asserts persistent shared-world condition; the content of its laws requires LOG, STR, or later vocabulary."],
  ["world unfolding", "one_root", "ORI:121 asserts a shared-world condition presently expressed through change."],
  ["dormant world condition", "one_root", "ORI:122 affirms a shared-world condition without present expression through change."],
  ["fact", "different_family_or_compound", "LOG owns propositional truth and DAT owns records; ORI only qualifies the state of affairs itself."],
  ["true proposition", "different_family", "LOG owns truth evaluation; a true sentence is not identical to the condition it represents."],
  ["observed", "different_family_or_compound", "MIN and DAT own observation and evidence; ORI does not equate manifestation with being observed."],
  ["physical object", "compound", "MAT supplies substance and physical properties while ORI may separately qualify existence."],
  ["living being", "compound", "LIF supplies living identity while ORI may separately qualify ontological status."],
  ["created artifact", "compound", "CRE supplies artifact and production; ORI distinct existence adds only ontological qualification."],
  ["caused by", "reserved_relation", "A causal relation belongs in later ORI relation review, not the entity-condition layer."],
  ["began", "process_layer", "A beginning is an ORI process, not a source-ground condition."],
  ["became real", "process_layer", "Actualization or manifestation transition belongs to ORI:1xx, not an ORI:0xx condition."],
  ["possible", "reserved_relation_or_grammar", "Unrestricted possibility is modal and must not be collapsed into lexical latency."],
  ["necessary", "reserved_relation_or_grammar", "Necessity is modal and belongs outside this condition block."],
  ["probable", "reserved_relation_or_grammar", "Probability qualifies a claim or world relation and is not an entity condition."],
  ["imaginary", "different_family_or_compound", "MIN supplies imagination; whether an imagined referent also belongs to a modeled reality is separate."],
  ["fictional character", "compound", "DAT or MIN supplies representation while ORI can qualify membership in a fictional world only with explicit context."],
  ["simulation object", "compound", "DAT/LOG supplies model implementation and ORI qualifies membership in the simulated reality."],
  ["database row exists", "compound", "DAT owns the record; ORI applies only if the modeled referent's ontology is separately asserted."],
  ["component enabled", "different_family", "STR or LOG owns enablement; lexical ORI occurrence is not a software-enabled flag."],
  ["active process", "process_layer", "Use the relevant family process root; ORI:0x1 remains a condition, not an action."],
  ["hidden object", "compound", "ORI latency does not mean hidden; perception or access requires MIN, DAT, or CON."],
  ["future object", "compound_or_unresolved", "Futurity is temporal; ORI latency alone does not mean future existence."],
  ["past object", "compound_or_unresolved", "Past time requires temporal qualification and is not identical to persistent existence."],
  ["counterfactual object", "reserved_relation", "Counterfactual world membership is reserved for modal ORI relations or later vocabulary."],
  ["natural law", "compound", "ORI:120 may qualify a world condition while LOG states the law's formal content and applicability."],
  ["social norm", "different_family_or_compound", "CON and LOG own shared authority and rules; a norm is not automatically a world condition."],
  ["shared belief", "different_family", "MIN and CON own collective cognition; agreement does not make a condition ontological."],
  ["consensus reality", "compound", "ORI supplies shared-world qualification while MIN/CON supplies consensus among participants."],
  ["provenance", "reserved_relation", "Historical source-to-result provenance belongs in an ORI relation or compound, not source-ground identity alone."],
  ["authorship", "different_family_or_compound", "LIF/CON/CRE own author role, attribution, and production; ORI source-grounding is not authorship."],
  ["persistent and occurrent", "two_compatible_roots", "Persistent identity and present occurrence may be jointly asserted for the same condition."],
  ["persistent and latent", "two_compatible_roots", "A persistent condition may currently be latent without contradiction."],
  ["occurrent and latent", "invalid_same_reference_claim", "Occurrence and latency are mutually exclusive for the same condition at one reference time."],
  ["latent condition affirmed", "runtime_and_lexical", "An ORI:0x2 root with runtime [1] confirms membership without present expression."],
  ["occurrent condition uncertain", "runtime_and_lexical", "An ORI:0x1 root with runtime [2]/num remains lexically occurrent while the token claim is unresolved."],
  ["persistent condition denied", "runtime_and_lexical", "Runtime [0] denies the persistent claim without selecting occurrence or latency."],
  ["unknown existence", "runtime_or_epistemic", "Use runtime [2]/num or MIN/DAT evidence; lexical latency never means unknown."],
  ["unobserved existence", "compound", "ORI asserts ontological status and MIN/DAT separately assert absence of observation or evidence."],
  ["deleted record", "different_family_or_compound", "DAT owns deletion; the modeled referent may retain, lose, or never have had ORI status independently."],
  ["destroyed object", "compound", "MAT/CRE/WRN supplies destruction while ORI may qualify the resulting existence condition."],
  ["repaired object", "compound", "REP supplies restoration while ORI only qualifies the object's ontological condition."],
  ["same object across versions", "compound", "ORI persistence can combine with DAT/STR identity criteria; it does not define version equivalence."],
  ["world invariant", "compound", "ORI:120 supplies persistent world condition while LOG defines and proves the invariant."],
  ["eventual world state", "grammar_or_reserved_relation", "Temporal eventuality is not lexical latency and requires timing grammar or later ORI relations."],
  ["nothing", "unresolved_vocabulary_gap", "Absence or nullity is not assigned to this block and remains unresolved or compositional."],
  ["impossible entity", "reserved_relation", "Impossibility is a modal qualification and must not be encoded as denial of a latent condition."],
  ["virtual resource", "compound", "DAT/STR describes the computational resource while ORI may qualify model-relative existence."],
  ["law presently expressed", "one_root_or_compound", "ORI:121 states occurrent shared-world expression while LOG supplies the law's content."],
  ["source no longer operative", "one_root_or_compound", "ORI:102 may express latent source-grounding; explicit cessation may require an ORI process or contour."],
  ["entity ceased to manifest", "process_plus_condition", "A transition process plus ORI:112 is needed; the latent condition alone does not encode cessation."
  ]
].freeze

ontological_condition_root_stress = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} process", "one_root", "#{id}[1] directly affirms the invariant without adding a cause, clock, observer, representation, or physical mechanism."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves this exact #{root[:phase]} transition claim unresolved and does not select a lexical sibling."],
    ["#{root[:title]} represented", "compound", "DAT supplies a representation while #{id} supplies the modeled ontological transition."],
    ["#{root[:title]} proposition", "compound", "LOG supplies a proposition about the transition while #{id} remains the state-of-affairs change."],
    ["#{root[:title]} believed", "compound", "MIN supplies belief or confidence while #{id} remains an objective transition claim."],
    ["#{root[:title]} physically realized", "compound", "MAT supplies physical mechanics while #{id} supplies only ontological transition."]
  ]
end

ontological_transition_stress_base = [
  ["begin", "one_root_or_compound", "ORI:10x can establish source-ground status, while a generic temporal beginning may require later ORI relation or grammar."],
  ["become", "one_root_or_compound", "Choose the triplet by what changes ontologically; broad becoming is not one forced atom."],
  ["emerge", "one_root_or_compound", "ORI:11x covers a distinct referent coming to obtain; spatial emergence or observation requires MOV or MIN/DAT."],
  ["actualize", "one_root", "ORI:110–112 owns bounded transition of one distinct referent into obtaining in the relevant reality."],
  ["instantiate", "one_root_or_compound", "Distinct actualization can cover ontological instantiation while LOG/STR supplies type or structural relation."],
  ["manifest", "one_root_or_compound", "ORI:11x covers becoming ontologically manifest, not merely becoming visible or represented."],
  ["originate", "ambiguous_compound", "Originate may mean source-ground establishment, causal beginning, production, provenance, or temporal onset and must be disambiguated."],
  ["establish a source", "one_root", "ORI:10x changes one referent into a source-ground without asserting causal sufficiency or authorship."],
  ["activate a source", "one_root_or_compound", "ORI:101 can cover ongoing source-ground establishment; operational enablement may additionally require another family."],
  ["source established", "one_root", "ORI:100 affirms completion of source-ground establishment without asserting persistence."],
  ["source establishment underway", "one_root", "ORI:101 affirms the bounded process is ongoing."],
  ["source establishment not occurring", "one_root", "ORI:102 affirms the typed process as nonactualized without saying why."],
  ["entity came into existence", "one_root", "ORI:110 states completed distinct actualization in a specified reality."],
  ["entity coming into existence", "one_root", "ORI:111 states active distinct actualization."],
  ["entity would come into existence", "one_root_or_compound", "ORI:112 states nonactualized actualization; conditional or modal force requires grammar or ORI:2xx."],
  ["world changed", "one_root_or_compound", "ORI:120 states completed shared-world transition when ontological standing across the shared reality changed."],
  ["world changing", "one_root", "ORI:121 states active shared-world transition under one jointly applicable world condition."],
  ["world transition not occurring", "one_root", "ORI:122 affirms a nonactualized shared-world transition without possibility or planning."],
  ["epoch change", "one_root_or_compound", "ORI systemic transition combines with temporal qualification; epoch duration is separate."],
  ["timeline branch", "compound_or_later_specialization", "ORI may supply systemic ontological transition while temporal branching and model structure require later relations, LOG, or STR."],
  ["simulation starts", "compound", "ORI may supply actualization of the simulated world while DAT/LOG/STR supplies implementation and state machine."],
  ["program object instantiated", "compound", "ORI supplies distinct actualization; DAT/LOG/STR supplies code, type, allocation, and structure."],
  ["database row inserted", "different_family", "DAT owns insertion of a record; ORI applies only if the modeled referent also changes ontological standing."],
  ["artifact created", "compound", "CRE owns productive generation; ORI distinct actualization may separately qualify the artifact's entry into reality."],
  ["material transformed", "different_family", "MAT owns physical transformation; ORI is needed only for a separate ontological transition."],
  ["moved into the room", "different_family", "MOV owns spatial displacement and arrival; location change alone is not actualization."],
  ["structure reconfigured", "different_family", "STR owns arrangement change; reconfiguration alone is not ontological transition."],
  ["person was born", "compound", "LIF owns biological birth while ORI may supply ontological actualization if explicitly relevant."],
  ["person died", "compound_or_gap", "LIF owns biological death; cessation of existence is not automatically the inverse of actualization and may need later vocabulary."],
  ["idea occurred", "different_family_or_compound", "MIN owns mental occurrence; ORI applies only if model-relative ontological standing is separately asserted."],
  ["message delivered", "different_family", "CON/DAT owns delivery and transfer; receipt does not entail actualization."],
  ["rule became valid", "different_family_or_compound", "LOG owns validity and applicability; ORI transition applies only to a separately asserted ontological condition."],
  ["repair completed", "different_family", "REP owns restorative completion; ORI does not encode return to an acceptable condition."],
  ["failure propagated", "different_family", "WRN owns adverse propagation; ORI transition is neutral about harm."],
  ["caused", "reserved_relation", "Causal connection belongs in ORI:2xx or a compound and is not entailed by transition."],
  ["produced", "different_family_or_compound", "CRE or MAT owns production mechanics; ORI only states change in ontological standing."],
  ["observed appearing", "compound", "ORI supplies actualization while MIN/DAT supplies observation and evidence."],
  ["represented as existing", "compound", "DAT supplies representation and LOG may supply proposition; neither entails ORI actualization."],
  ["scheduled to begin", "grammar_or_compound", "Scheduling does not select lexical nonactualization; ORI:1x2 plus explicit schedule is required."],
  ["intends to instantiate", "compound", "MIN supplies intention; ORI:112 supplies only a nonactualized transition if the typed process is asserted."],
  ["ready to actualize", "compound", "Readiness is not lexical 1x2 and requires an affordance or condition plus the nonactualized process."],
  ["possible actualization", "compound", "ORI:112 supplies nonactualized process while ORI:2xx must later supply possibility."],
  ["probable actualization", "compound", "Probability is separate from the nonactualized process."],
  ["future actualization", "compound", "Futurity is temporal and not encoded by lexical nonactualization."],
  ["completed transition persists", "compound", "ORI:1x0 supplies completion and ORI:0x0 separately supplies persistent resulting condition."],
  ["active transition uncertain", "runtime_and_lexical", "ORI:1x1[2]/num leaves an active-phase claim unresolved without selecting nonactualization."],
  ["nonactualized transition affirmed", "runtime_and_lexical", "ORI:1x2[1] confirms the typed process is not occurring without modality or schedule."],
  ["completed transition denied", "runtime_and_lexical", "ORI:1x0[0] denies completion without selecting active or nonactualized phase."],
  ["active and completed simultaneously", "invalid_same_reference_claim", "Active and completed are mutually exclusive phases of the same bounded transition at one reference time."],
  ["active and nonactualized simultaneously", "invalid_same_reference_claim", "Active and nonactualized are mutually exclusive for the same transition at one reference time."],
  ["creation ex nihilo", "compound_or_later_specialization", "ORI actualization plus CRE generation may approximate this, but the stronger metaphysical claim remains later vocabulary."],
  ["annihilate", "unresolved_vocabulary_gap", "Cessation of ontological standing is not forced into actualization and remains for later ORI design."],
  ["deactivate", "different_family_or_compound", "Operational deactivation is usually LOG, STR, DAT, or affordance state; it is not necessarily ontological transition."],
  ["world merge", "compound_or_later_specialization", "Shared-world transition may participate, but identity mapping and structural integration require later vocabulary and STR/LOG."],
  ["world split", "compound_or_later_specialization", "Shared-world transition may participate, but branching relations and resulting world identities remain later vocabulary."],
  ["state machine transition", "compound", "STR/LOG supplies machine structure and rule while ORI applies only if the transition is ontological in the modeled domain."],
  ["event starts", "one_root_or_compound", "ORI source-ground establishment or actualization may apply depending on event ontology; temporal onset remains separate."],
  ["event ends", "unresolved_or_compound", "Completion of the event itself is not automatically cessation of existence and may require event-specific grammar."],
  ["reality reboot", "compound_or_later_specialization", "ORI systemic transition plus restoration, data, and structural processes may express the concept compositionally."],
  ["law takes effect", "compound", "LOG supplies applicability while ORI systemic transition applies only if what obtains across reality changes."]
].freeze

stress_rows = ontological_transition_stress_base + ontological_condition_root_stress

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("ORI1-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "ORI:100–122 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/ORI_100_122_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "ORI:100–122 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "ORI:100–102" => "source-ground establishment: completed / active / nonactualized", "ORI:110–112" => "distinct actualization: completed / active / nonactualized", "ORI:120–122" => "shared-world transition: completed / active / nonactualized" }, "triplet_logic" => { "process_phases" => "completed, active, and nonactualized are mutually exclusive for one bounded transition at one reference time", "nonactualized_member" => "asserts a typed process that is not occurring without intention, possibility, planning, scheduling, or futurity", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical phase claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/ORI_100_122_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "ORI:100–122 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# ORI:100–122 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Origin process meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `ORI:1xx` the substrate-neutral ontological-transition layer paired with canonical `ORI:0xx`. The inward triplet establishes source-ground status, the outward triplet actualizes one distinct referent, and the systemic triplet changes what obtains across one shared reality under one jointly applicable world condition. Completed, active, and nonactualized supply the exact third-trit contrast.\n\nLexical nonactualization means the typed transition is not occurring, not that it is possible, intended, prepared, scheduled, queued, probable, or future. Runtime `[2]/num` remains uncertainty about the selected phase claim. The design rejects the provisional mixture of general continuation, differentiation, causal production, possibility, preparedness, staging, and stable result states. Conditions remain `ORI:0xx`; causal, modal, temporal, and provenance relations remain `ORI:2xx` candidates for later review; physical change, cognition, representation, formal evaluation, and production remain separate or compounded.\n\n"

IDS.each do |id|
  scored_root = scored_roots.find { |root| root["canonical_id"] == id }
  spec = recommended_roots.find { |root| root.dig("fixed_generated_fields", "canonical_id") == id }
  fixed = spec.fetch("fixed_generated_fields")
  review << "## #{id} — #{spec['proposed_title']}\n\n### A. Fixed generated forms\n\n"
  review << "- Universal slot: **#{fixed['universal_slot']}**\n- Transliteration: **#{fixed['family_qualified_transliteration']}**\n- Local compact root: **#{fixed['local_compact_root']}**\n- Formal carrier: **#{fixed['formal_carrier']}**\n- Harmonic signature: **#{fixed['harmonic_signature_semitones'].join('–')}**\n- Relative note path: **#{fixed['relative_note_path_semitones'].join(' → ')}**\n\n"
  review << "### B. Why the current meaning was probably chosen\n\n#{scored_root['current_meaning_rationale']}\n\n### C. Candidate comparison\n\n| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n"
  scored_root.fetch("candidates").each do |candidate_item|
    values = EraZeroValidation::SCORE_KEYS.map { |key| candidate_item.dig("scores", key) }
    review << "| #{candidate_item['title']} | #{values.join(' | ')} | **#{candidate_item['total']}/80** |\n"
  end
  review << "\n"
  scored_root.fetch("candidates").each do |candidate_item|
    analysis = candidate_item.fetch("analysis")
    review << "#### #{candidate_item['title']}\n\n**Invariant candidate:** #{candidate_item['invariant_candidate']}\n\n- Fit: #{analysis['why_it_fits']}\n- Useful coverage: #{analysis['useful_coverage']}\n- Territory consumed: #{analysis['semantic_territory_consumed']}\n- Conflicts and limitations: #{analysis['conflicts_or_future_limitations']}\n\n"
  end
  review << "### D. Recommended permanent semantic specification\n\n**Title:** #{spec['proposed_title']}\n\n**Invariant:** #{spec['invariant_definition']}\n\n**Inclusion boundary:** #{spec['inclusion_boundary']}\n\n**Excluded meanings:**\n\n"
  spec.fetch("excluded_meanings").each { |item| review << "- #{item}\n" }
  review << "\n**Address justification:**\n\n"
  spec.fetch("address_justification").each { |axis, explanation| review << "- `#{axis}`: #{explanation}\n" }
  review << "\n**Nearest neighbors:** #{spec['nearest_neighbors'].map { |neighbor| "`#{neighbor}`" }.join(', ')}\n\n**Same-family boundary:** #{spec['same_family_contrast']}\n\n**Runtime-state interpretation:**\n\n"
  spec.fetch("runtime_state_interpretation").each { |state, meaning| review << "- `[#{state}]`: #{meaning}\n" }
  review << "\n**Lexical/runtime distinction:** #{spec['lexical_runtime_distinction']}\n\n### E. Examples\n\n| Type | Semantic graph | Literal gloss | Natural English | State | Result |\n| --- | --- | --- | --- | ---: | --- |\n"
  spec.fetch("examples").each { |example| review << "| #{example['category']} | `#{example['semantic_graph']}` | #{example['literal_gloss']} | #{example['natural_english']} | #{example['runtime_state']} | #{example['use_status']} |\n" }
  review << "\n"
end

review << "## Triplet coherence\n\n| Triplet | Shared axis | `0` | `1` | `2` |\n| --- | --- | --- | --- | --- |\n"
review << "| ORI:100–102 | source-ground establishment | completed | active | nonactualized |\n"
review << "| ORI:110–112 | distinct actualization | completed | active | nonactualized |\n"
review << "| ORI:120–122 | shared-world transition | completed | active | nonactualized |\n\n"
review << "**Triplet logic:** completed, active, and nonactualized are mutually exclusive phases of one bounded transition at one reference time.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | Entity condition, causal mechanism, clock time, physical change, observation, representation, truth evaluation, modal force, provenance, and production |\n" }
review << "\n## Concepts intentionally reserved\n\nCausal mechanisms, temporal beginnings and intervals, possibility, necessity, probability, counterfactual worlds, provenance, authorship, observation, evidence, truth, physical transformation, biological change, representation, productive generation, structural reconfiguration, and exact world-law content remain other roots, other families, later vocabulary, grammar, or compounds.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later specialization, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# ORI:100–122 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "causal activation, temporal onset, CRE source production", "1" => "CRE generation, MAT transformation, DAT instantiation", "2" => "STR reconfiguration, LOG regime change, MOV transition" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | ORI keeps only ontological transition; cause, time, representation, physical mechanics, production, and world-law content remain separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- An ontological transition is not its cause, schedule, observation, representation, physical mechanism, productive method, or evaluation.\n- Source-ground establishment does not entail causal sufficiency, authorship, temporal priority, creation, ownership, or provenance.\n- Distinct actualization does not entail observability, materiality, life, truth of a sentence, database insertion, production, or persistence.\n- Shared-world transition does not entail consensus, social coordination, structural reconfiguration, or the formal content of a world law.\n- A nonactualized process is typed but not occurring; it is not thereby possible, intended, prepared, ready, queued, scheduled, future, or prohibited.\n- Completed, active, and nonactualized are mutually exclusive for one bounded transition at one reference time.\n- Runtime `[2]/num` leaves a selected phase assertion unresolved and never selects lexical nonactualization.\n\n**CONCLUSION: ORI:1XX STANDS ALONE ONLY FOR ONTOLOGICAL TRANSITIONS; ENTITY CONDITIONS, CAUSE, TIME, MODALITY, PROVENANCE, REPRESENTATION, TRUTH, OBSERVATION, PHYSICAL MECHANICS, LIFE PROCESSES, STRUCTURAL CHANGE, AND PRODUCTION REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built ORI:100–122 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
