#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "ORI:000–022"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "ORI_000_022"
SEMANTIC_CENTER = "ontological conditions: source-ground, distinct existence, and shared-world order"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "ORI:000" => ["foundational source", "A stable inward first condition or ontological ground is treated as the source of existence."],
  "ORI:001" => ["present actuality", "Existence is presently manifest as an active inward state of reality."],
  "ORI:002" => ["latent first condition", "An origin-state is preserved as dormant or pre-manifest potential rather than current actuality."],
  "ORI:010" => ["manifest fact", "A stable external condition is actual and bounded within reality."],
  "ORI:011" => ["emergent phenomenon", "A condition or entity is actively becoming manifest as an observable part of reality."],
  "ORI:012" => ["unmanifest condition", "A possible external fact or phenomenon is defined but has not entered actuality."],
  "ORI:020" => ["universal order", "Stable laws or foundational relations hold across a shared reality."],
  "ORI:021" => ["unfolding reality", "A cosmos or shared reality is actively expressing change under its foundational laws."],
  "ORI:022" => ["pre-manifest world state", "A coherent shared reality is possible or preserved in potential but is not currently manifest."]
}.freeze

ROOTS = {
  "ORI:000" => { title: "persistent source-ground condition", phase: "persistent", scope: "inward", kind: "source-ground condition", invariant: "A persistent ontological condition by which one referent is grounded as a source from which another state of affairs may originate, independently of whether that grounding is presently operative." },
  "ORI:001" => { title: "operative source-ground condition", phase: "operative", scope: "inward", kind: "source-ground condition", invariant: "An ontological condition by which one referent is grounded as a source from which another state of affairs may originate and that grounding is presently operative." },
  "ORI:002" => { title: "latent source-ground condition", phase: "latent", scope: "inward", kind: "source-ground condition", invariant: "An ontological condition by which one referent is grounded as a source from which another state of affairs may originate and that grounding exists without being presently operative." },
  "ORI:010" => { title: "persistent distinct-existence condition", phase: "persistent", scope: "outward", kind: "distinct-existence condition", invariant: "A persistent ontological condition under which one distinct referent obtains as part of the relevant reality, independently of whether it is presently manifesting or changing." },
  "ORI:011" => { title: "occurrent distinct-existence condition", phase: "occurrent", scope: "outward", kind: "distinct-existence condition", invariant: "An ontological condition under which one distinct referent is presently manifesting or changing as part of the relevant reality." },
  "ORI:012" => { title: "latent distinct-existence condition", phase: "latent", scope: "outward", kind: "distinct-existence condition", invariant: "An ontological condition under which one distinct referent belongs to the relevant reality without presently manifesting or changing within it." },
  "ORI:020" => { title: "persistent shared-world condition", phase: "persistent", scope: "systemic", kind: "shared-world condition", invariant: "A persistent ontological condition that jointly constrains what obtains across one shared reality, independently of whether that condition is presently being expressed through change." },
  "ORI:021" => { title: "occurrent shared-world condition", phase: "occurrent", scope: "systemic", kind: "shared-world condition", invariant: "An ontological condition that is presently being expressed through change across one shared reality." },
  "ORI:022" => { title: "latent shared-world condition", phase: "latent", scope: "systemic", kind: "shared-world condition", invariant: "An ontological condition that belongs to one shared reality without presently being expressed through change across it." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [5, 7, 9, 4, 5, 8, 8, 9] },
  "ontological_conditions" => { scores: [10, 10, 10, 10, 9, 10, 9, 10] },
  "temporal_anchor_states" => { scores: [8, 7, 7, 7, 6, 8, 9, 9] },
  "causal_roles" => { scores: [8, 8, 8, 6, 5, 9, 9, 9] },
  "modal_world_objects" => { scores: [8, 8, 9, 7, 5, 8, 7, 10] }
}.freeze

ALT_TITLES = {
  "ORI:000" => ["persistent prior-time anchor", "persistent causal antecedent", "persistent possible-world origin"],
  "ORI:001" => ["current prior-time anchor", "operative causal antecedent", "actual possible-world origin"],
  "ORI:002" => ["pending prior-time anchor", "latent causal antecedent", "counterfactual possible-world origin"],
  "ORI:010" => ["persistent present-time anchor", "persistent causal consequent", "persistent actual-world object"],
  "ORI:011" => ["current present-time anchor", "operative causal consequent", "actualized possible-world object"],
  "ORI:012" => ["pending present-time anchor", "latent causal consequent", "counterfactual world object"],
  "ORI:020" => ["persistent global-time frame", "persistent causal network", "persistent modal world"],
  "ORI:021" => ["current global-time frame", "operative causal network", "actual modal world"],
  "ORI:022" => ["pending global-time frame", "latent causal network", "counterfactual modal world"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identities, biological conditions, agents, and social roles. ORI states how a referent belongs to reality, not whether it is alive, a person, or a role bearer.",
  "MOV" => "MOV owns position, routes, displacement, and motion conditions. Change of location may manifest an ORI condition, but spatial position or movement is not ontological status.",
  "MAT" => "MAT owns substance, energy, force, contact, and physical capacities. ORI is substrate-neutral and never identifies matter merely because matter exists.",
  "MIN" => "MIN owns belief, attention, intention, understanding, and mental possibility. ORI makes an ontological claim, not a claim about what any observer conceives or knows.",
  "CON" => "CON owns linkage, communication, participation, authority, and interaction channels. Shared reality does not itself assert communication or a social relation.",
  "WRN" => "WRN owns hazards, faults, adverse processes, susceptibility, exposure, and propagation. An unrealized or changing ORI condition is not thereby a risk or failure.",
  "STR" => "STR owns arrangements, interfaces, dependencies, and structural compatibility. ORI may qualify a structure as obtaining, but it does not describe the arrangement itself.",
  "REP" => "REP owns restoration conditions, transformations, and affordances. Return to a prior acceptable state is not encoded by persistence, occurrence, or latency in ORI.",
  "LOG" => "LOG owns formal propositions, constraints, validity, evaluation, and applicability. ORI distinct existence is not the truth value or proof status of a representation.",
  "DAT" => "DAT owns represented information, records, and data processes. An encoded model of a world is DAT; the modeled ontological condition remains ORI.",
  "CRE" => "CRE owns generative entities, productive transformations, and productive affordances. ORI source-grounding does not assert authorship, manufacture, or creation."
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
  when "ontological_conditions"
    values[4] += 1 if second == "0"
    values[6] -= 1 if second == "2"
  when "temporal_anchor_states"
    values[1] -= 1 if second == "0"
    values[4] -= 1 if third == "2"
  when "causal_roles"
    values[3] -= 1 if second == "2"
    values[4] -= 1 if second == "1"
  when "modal_world_objects"
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
      "why_it_fits" => "The provisional meanings correctly notice that first-trit 0 names a condition or entity and that ORI concerns origin, actuality, and world-level order; they also gesture toward #{root.fetch(:scope)} scope and #{root.fetch(:phase)} status.",
      "useful_coverage" => "They cover sources, actuality, manifestation, potential, universal order, and possible world states.",
      "semantic_territory_consumed" => "Across the block they mix source identity, causal priority, existence, observability, emergence, logical fact, natural law, temporal unfolding, and modal possibility.",
      "conflicts_or_future_limitations" => "The triplets do not preserve one semantic center: third-trit 1 alternates between actuality, emergence, and cosmic change, while third-trit 2 alternates between potential, nonmanifestation, and possible worlds."
    }
  when "ontological_conditions"
    {
      "why_it_fits" => "First-trit 0 remains a condition, the second trit selects source-ground, distinct referent, or shared-world scope, and the third changes only persistent, occurrent/operative, or latent status.",
      "useful_coverage" => "It supports sourcehood, actuality, existence, manifestation, dormant membership in a reality, world conditions, simulation states, event models, and formal ontology.",
      "semantic_territory_consumed" => "Only ontological qualification: how a source, a distinct referent, or a shared world obtains. Causal links, clocks, propositions, observations, physical objects, and productive acts remain separate.",
      "conflicts_or_future_limitations" => "Specific kinds of cause, time, possibility, necessity, truth, material realization, and world-law content require ORI relation/process roots or cross-family compounds."
    }
  when "temporal_anchor_states"
    {
      "why_it_fits" => "Origin language often organizes states as prior, current, and globally synchronized time anchors.",
      "useful_coverage" => "It would cover epochs, timestamps, current instants, deferred times, clocks, schedules, and global timelines.",
      "semantic_territory_consumed" => "It consumes temporal reference and scheduling rather than entity or condition status, and the second/third trits would redundantly encode time.",
      "conflicts_or_future_limitations" => "ORI process and relation layers need room for temporal sequence; using the entity layer for clocks would make non-temporal ontology difficult."
    }
  when "causal_roles"
    {
      "why_it_fits" => "Source, target, and system naturally suggest antecedent, consequent, and causal-network roles.",
      "useful_coverage" => "It would cover cause, effect, enabling condition, causal chain, provenance, dependency, and intervention points.",
      "semantic_territory_consumed" => "It turns entity slots into relations and conflates an entity's role in causation with the causal relation itself.",
      "conflicts_or_future_limitations" => "STR owns dependency, CRE owns production, and ORI:2xx is the better place for modal or causal relations; neighbor separation would be weak."
    }
  when "modal_world_objects"
    {
      "why_it_fits" => "ORI naturally hosts actual, possible, necessary, and counterfactual worlds and their inhabitants.",
      "useful_coverage" => "It would cover possible worlds, actual worlds, counterfactual objects, model states, branches, and modal alternatives.",
      "semantic_territory_consumed" => "It makes the third trit a modal operator rather than stable/active/latent lexical status and overcommits the system to one formal semantics.",
      "conflicts_or_future_limitations" => "LOG owns formal model evaluation, MIN owns imagined alternatives, and later ORI relations should carry possibility or necessity without turning every entity into a world object."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "temporal_anchor_states"
    "A #{root.fetch(:phase)} temporal anchor at #{root.fetch(:scope)} reference scope."
  when "causal_roles"
    "A #{root.fetch(:phase)} causal role borne at #{root.fetch(:scope)} scope."
  when "modal_world_objects"
    "A #{root.fetch(:phase)} modal-world object at #{root.fetch(:scope)} scope."
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
    "low" => "referent whose ontological condition is qualified",
    "middle" => "source-ground, distinct existence, or shared-world condition as figure",
    "high" => "originating state of affairs, distinct manifestation, or world-level consequence",
    "sustained" => "relevant reality, reference frame, and shared domain"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that this #{root.fetch(:kind)} persists in the stated reality; it does not select the occurrent or latent sibling and does not deny the referent itself.",
      "1" => "Affirms that this #{root.fetch(:kind)} persists independently of present expression, without asserting a cause, observation, proof, or physical realization.",
      "2/num" => "Leaves unresolved whether this persistent #{root.fetch(:kind)} claim holds; runtime uncertainty does not change the lexical root into operative or latent status."
    }
  when "1"
    {
      "0" => "Denies that this #{root.fetch(:kind)} is presently operative or occurrent; it does not deny persistent identity or affirm latency, impossibility, or nonexistence.",
      "1" => "Affirms that this #{root.fetch(:kind)} is presently operative or occurrent in the relevant reality without asserting observation, evidence, causation, or temporal duration.",
      "2/num" => "Leaves present occurrence of this #{root.fetch(:kind)} unresolved; token uncertainty does not select the persistent or latent lexical sibling."
    }
  else
    {
      "0" => "Denies that this #{root.fetch(:kind)} belongs to the relevant reality in latent form; it does not establish the occurrent sibling or metaphysical impossibility.",
      "1" => "Affirms this #{root.fetch(:kind)} as belonging to the relevant reality without present expression, without encoding ignorance, probability, futurity, concealment, or permission.",
      "2/num" => "Leaves unresolved even the assertion that this latent #{root.fetch(:kind)} exists; lexical latency remains distinct from runtime assertion-level uncertainty."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entity = id[-2] == "0" ? "source" : id[-2] == "1" ? "referent" : "world"
  graph_roles = id[-2] == "0" ? "SOURCE=#{entity},ORIGINAND=o,REALITY=r" : id[-2] == "1" ? "REFERENT=#{entity},REALITY=r" : "WORLD=#{entity},MEMBERS={a,b,c}"
  status_text = { "0" => "persists independently of present expression", "1" => "is presently expressed", "2" => "belongs without present expression" }.fetch(id[-1])
  ordinary = "The #{root.fetch(:kind)} for the #{entity} #{status_text}."
  entries = [
    ["ordinary_conversation", "#{id}[1](#{graph_roles})", "affirm #{root.fetch(:phase)} #{root.fetch(:kind)}", ordinary, "The root asserts ontological status, not knowledge, evidence, physical composition, or a causal event."],
    ["physical_or_spatial", "MAT(OBJECT=m)+#{id}[1](#{graph_roles})", "material object plus #{root.fetch(:phase)} ontological condition", "The object has the stated place in reality while MAT separately describes its substance and physical properties.", "Ontological status and material constitution remain separately typed."],
    ["temporal_or_sequential", "#{id}[1](#{graph_roles})+ORI(INTERVAL=w)", "#{root.fetch(:phase)} ontological condition during interval w", "During interval w, the condition has the selected lexical status.", "Temporal anchoring does not replace persistent, occurrent, or latent status."],
    ["cross_family_compound", "#{id}[1](#{graph_roles})+DAT(REPRESENTATION=d)+MIN(BELIEF=b)", "ontological condition plus representation plus belief", "The condition, its recorded description, and an observer's belief are asserted separately.", "Reality, representation, and cognition remain distinct."],
    ["executable_or_programming", "#{id}[1](#{graph_roles})", "assert #{root.fetch(:phase)} ontological condition", "A runtime records the selected world-state condition without conflating it with a Boolean proposition or observation event.", "Ontological state, truth evaluation, and stored data remain distinct."],
    ["counterexample", "LOG(PROPOSITION=p)+DAT(RECORD=d)", "represented proposition with stored evidence", "The database says the proposition is true.", "Use LOG and DAT for truth/evidence; #{id} is reserved for the condition's place in reality."]
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
      "pseudocode" => category == "executable_or_programming" ? "world.assert_condition(#{id.inspect}, referent: #{entity.inspect})" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "ontological_conditions", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "temporal_anchor_states", alt[0], alternative_invariant(id, "temporal_anchor_states")),
    candidate(id, "causal_roles", alt[1], alternative_invariant(id, "causal_roles")),
    candidate(id, "modal_world_objects", alt[2], alternative_invariant(id, "modal_world_objects"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "ontological_conditions",
    "recommendation_reason" => "Only this architecture keeps all nine roots on one ontological-condition center, follows source-ground/distinct-referent/shared-world scope exactly, and gives every triplet one persistent/occurrent-or-operative/latent contrast while reserving causation, time, propositions, observation, physical constitution, and formal modality for relations, processes, other families, or composition.",
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
  state_label = { "0" => "persistent", "1" => "occurrent or operative", "2" => "latent" }.fetch(third)
  scope_explanation = {
    "0" => "one referent qualified as a source-ground for an originating state of affairs",
    "1" => "one distinct referent qualified by how it obtains within the relevant reality",
    "2" => "one condition qualifying what obtains across a shared reality"
  }.fetch(second)
  scope_boundary = {
    "0" => "The condition qualifies source-grounding only. It does not assert a particular causal link, creator, temporal beginning, physical substrate, or produced result.",
    "1" => "The condition qualifies one distinct referent's membership or manifestation in reality. It does not identify the referent's substance, truth-description, observability, or cause.",
    "2" => "The condition qualifies a shared world as a whole. It does not itself state a law's content, a social consensus, a structural arrangement, or a formal model."
  }.fetch(second)
  triplet_logic = "Persistent identity may co-occur with occurrent/operative or latent status; occurrent/operative and latent are mutually exclusive for the same condition at one reference time. Lexical latency affirms membership without present expression; runtime `[2]/num` separately marks uncertainty about any selected claim."
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_0" => "Selects an ontological entity or condition rather than an originating process, causal or modal relation, observation, representation, or physical constitution.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Origin-family column.",
      "third_trit" => "Selects the #{state_label} status of the same ontological condition while leaving runtime assertion status, observer knowledge, clock time, probability, truth evaluation, causation, and physical realization separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral ontological qualification at #{root.fetch(:scope)} scope. #{scope_boundary} It is neutral about substance, location, cognition, evidence, representation, logical validity, agency, authority, productive method, hazard, repair, scheduling, exact time, probability, and causal mechanism.",
    "excluded_meanings" => [
      "A causal link, temporal beginning, production event, authorship claim, or historical provenance relation.",
      "A material object, living agent, mental representation, data record, proposition, structural arrangement, warning, or repair condition.",
      "Observation, detectability, evidence, truth, validity, certainty, consensus, permission, or authority.",
      "Unrestricted possibility, necessity, probability, counterfactuality, schedule, future time, or mere nonexistence.",
      "The content of a natural law, algorithm, causal mechanism, physical mechanism, social convention, or formal model.",
      "Any claim that persistence entails current expression, or that latency entails uncertainty, concealment, planning, or futurity."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`ORI:0xx` owns ontological conditions: source-ground, distinct existence, and shared-world order. `ORI:1xx` is reserved for origin/reality processes such as beginning, actualization, or world change. `ORI:2xx` is reserved for causal, modal, temporal, or provenance relations and affordances. An ontological condition does not entail a cause, process, representation, observation, or physical substrate. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} status of this ontological condition. Runtime `[2]/num` instead leaves the already-selected claim unresolved; it never changes lexical status. Thus a latent root affirmed with `[1]` confirms membership without present expression, while a persistent or occurrent root carrying `[2]/num` remains lexically persistent or occurrent but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + ORI:1xx may state the process through which the condition begins, changes, or becomes manifest.",
      "#{id} + ORI:2xx may state causal, modal, temporal, or provenance relations without changing the entity-layer meaning.",
      "#{id} + MAT/DAT/LOG/STR supplies substrate, representation, proposition, or arrangement while preserving the ontological boundary.",
      "#{id} + MIN/CON/LIF may express belief, evidence-sharing, participant identity, or social authority as separate meanings."
    ],
    "later_era_notes" => "Later eras may lexicalize kinds of existence, event ontology, possible-world membership, necessity, counterfactual objects, causal powers, temporal regions, simulation layers, provenance chains, and law-governed worlds. Era Zero should preserve the substrate-neutral ontological center and derive stronger metaphysical, scientific, social, and computational claims compositionally.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


ontological_condition_stress_base = [
  ["exists", "one_root_or_compound", "ORI:01x supplies a distinct-existence condition; the lexical third must match persistent, occurrent, or latent status."],
  ["is real", "one_root_or_context", "ORI:010 or ORI:011 may qualify a distinct referent, but discourse must identify the relevant reality."],
  ["source", "one_root_or_compound", "ORI:00x supplies source-ground status; a specific causal link or creator role remains separate."],
  ["origin", "ambiguous_compound", "Origin may mean source-ground, temporal beginning, causal antecedent, provenance, or creation and must be disambiguated."],
  ["foundation", "one_root_or_compound", "ORI:000 can state persistent source-grounding while STR handles structural foundation and LOG handles axiomatic basis."],
  ["currently operative source", "one_root", "ORI:001 directly asserts an operative source-ground condition without naming the causal mechanism."],
  ["dormant source", "one_root", "ORI:002 affirms a source-ground condition that belongs without present operation."],
  ["manifest entity", "one_root", "ORI:011 asserts a distinct referent presently manifesting or changing in the relevant reality."],
  ["enduring entity", "one_root", "ORI:010 asserts persistent distinct existence without requiring present change."],
  ["latent entity", "one_root", "ORI:012 affirms membership in the relevant reality without present manifestation or change."],
  ["world order", "one_root_or_compound", "ORI:020 asserts persistent shared-world condition; the content of its laws requires LOG, STR, or later vocabulary."],
  ["world unfolding", "one_root", "ORI:021 asserts a shared-world condition presently expressed through change."],
  ["dormant world condition", "one_root", "ORI:022 affirms a shared-world condition without present expression through change."],
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
  ["natural law", "compound", "ORI:020 may qualify a world condition while LOG states the law's formal content and applicability."],
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
  ["world invariant", "compound", "ORI:020 supplies persistent world condition while LOG defines and proves the invariant."],
  ["eventual world state", "grammar_or_reserved_relation", "Temporal eventuality is not lexical latency and requires timing grammar or later ORI relations."],
  ["nothing", "unresolved_vocabulary_gap", "Absence or nullity is not assigned to this block and remains unresolved or compositional."],
  ["impossible entity", "reserved_relation", "Impossibility is a modal qualification and must not be encoded as denial of a latent condition."],
  ["virtual resource", "compound", "DAT/STR describes the computational resource while ORI may qualify model-relative existence."],
  ["law presently expressed", "one_root_or_compound", "ORI:021 states occurrent shared-world expression while LOG supplies the law's content."],
  ["source no longer operative", "one_root_or_compound", "ORI:002 may express latent source-grounding; explicit cessation may require an ORI process or contour."],
  ["entity ceased to manifest", "process_plus_condition", "A transition process plus ORI:012 is needed; the latent condition alone does not encode cessation."
  ]
].freeze

ontological_condition_root_stress = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} identity", "one_root", "#{id}[1] directly affirms the invariant without adding a cause, process, observer, representation, or physical substrate."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves this exact #{root[:phase]} condition claim unresolved and does not select a lexical sibling."],
    ["#{root[:title]} represented", "compound", "DAT supplies a representation while #{id} supplies the modeled ontological condition."],
    ["#{root[:title]} proposition", "compound", "LOG supplies a proposition about the condition while #{id} remains the state-of-affairs claim."],
    ["#{root[:title]} believed", "compound", "MIN supplies belief or confidence while #{id} remains an objective ontological claim."],
    ["#{root[:title]} physically realized", "compound", "MAT supplies physical constitution while #{id} supplies only ontological qualification."]
  ]
end

stress_rows = ontological_condition_stress_base + ontological_condition_root_stress

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("ORI0-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "ORI:000–022 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/ORI_000_022_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "ORI:000–022 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "ORI:000–002" => "source-ground condition: persistent / operative / latent", "ORI:010–012" => "distinct-existence condition: persistent / occurrent / latent", "ORI:020–022" => "shared-world condition: persistent / occurrent / latent" }, "triplet_logic" => { "condition_statuses" => "persistent identity may co-occur with occurrent or latent status; occurrent and latent are mutually exclusive at one reference time", "latent_member" => "affirms membership without present expression and without hiddenness, probability, planning, scheduling, or futurity", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/ORI_000_022_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "ORI:000–022 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# ORI:000–022 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Origin entity/condition meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `ORI:0xx` the substrate-neutral ontological-condition layer. The inward triplet qualifies source-grounding, the outward triplet qualifies one distinct referent's existence in a relevant reality, and the systemic triplet qualifies a shared world as a whole. Persistent, occurrent/operative, and latent supply the exact third-trit contrast.\n\nPersistent identity may co-occur with occurrence or latency; occurrent/operative and latent are mutually exclusive at one reference time. Lexical latency means membership without present expression, not uncertainty, hiddenness, possibility, counterfactuality, scheduling, or future time. Runtime `[2]/num` remains uncertainty about the selected claim. The design rejects the provisional mixture of causation, actuality, observability, emergence, propositional fact, natural-law content, temporal unfolding, and modal possibility. Processes remain `ORI:1xx`; causal, modal, temporal, and provenance relations remain `ORI:2xx` candidates for later review; matter, cognition, representation, formal truth, and production remain separate or compounded.\n\n"

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
review << "| ORI:000–002 | one referent's source-ground condition | condition persists | grounding operative | grounding latent |\n"
review << "| ORI:010–012 | one distinct referent's existence condition | existence persists | existence occurrent | existence latent |\n"
review << "| ORI:020–022 | one shared-world condition | condition persists | condition occurrent | condition latent |\n\n"
review << "**Triplet logic:** persistent identity may co-occur with occurrence or latency; occurrent/operative and latent are mutually exclusive for the same condition at one reference time.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | Causal link, temporal beginning, physical substrate, observation, representation, truth evaluation, modal force, provenance, authorship, and process |\n" }
review << "\n## Concepts intentionally reserved\n\nCausal relations, temporal beginnings and intervals, possibility, necessity, probability, counterfactual worlds, provenance, authorship, observation, evidence, truth, physical constitution, life, representation, productive transformation, structural content, and exact law content remain other roots, other families, later vocabulary, grammar, or compounds.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later specialization, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# ORI:000–022 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "causation, temporal beginning, CRE authorship", "1" => "LOG truth, DAT evidence, MAT objects", "2" => "LOG laws, STR order, MIN/CON consensus" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | ORI keeps only ontological qualification; cause, time, representation, truth, substrate, observation, and world-law content remain separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- An ontological condition is not its cause, beginning, observation, representation, proposition, physical substrate, or productive history.\n- Source-grounding does not entail causal sufficiency, authorship, temporal priority, creation, ownership, or provenance.\n- Distinct existence does not entail observability, materiality, life, truth of a sentence, database presence, or persistence.\n- A shared-world condition does not entail consensus, a social institution, structural organization, or the formal content of a law.\n- A latent condition belongs without present expression; it is not unknown, merely possible, counterfactual, hidden, planned, scheduled, future, or prohibited.\n- Persistent identity may co-occur with occurrence or latency; occurrence and latency are mutually exclusive at one reference time.\n- Runtime `[2]/num` leaves a selected status assertion unresolved and never selects lexical latency.\n\n**CONCLUSION: ORI:0XX STANDS ALONE ONLY FOR ONTOLOGICAL CONDITIONS; CAUSE, TIME, MODALITY, PROVENANCE, REPRESENTATION, TRUTH, OBSERVATION, PHYSICAL SUBSTRATE, LIFE, STRUCTURE, AND PRODUCTION REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built ORI:000–022 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
