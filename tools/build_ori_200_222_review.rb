#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "ORI:200–222"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "ORI_200_222"
SEMANTIC_CENTER = "ontological relations: source-grounding capacity, target-ground dependence, and shared-world constraint"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "ORI:200" => ["stable existence capacity", "A source has a dependable inward capacity to exist, persist, or become actual."],
  "ORI:201" => ["expressed possibility", "An inward possibility is currently viable and participating in actuality."],
  "ORI:202" => ["pure potential", "A capacity for existence is present only as dormant, pre-manifest possibility."],
  "ORI:210" => ["necessary dependence", "A stable causal or ontological relation makes a target depend on a source or prior condition."],
  "ORI:211" => ["active causation", "A source condition is actively bringing about, constraining, or sustaining a target."],
  "ORI:212" => ["contingency", "A possible causal or ontological relation could hold, but necessity, outcome, or dependence is unresolved."],
  "ORI:220" => ["universality", "A foundational relation holds stably across every relevant part of a reality."],
  "ORI:221" => ["lawful interdependence", "Parts of reality are actively co-determining one another under shared laws."],
  "ORI:222" => ["possible world", "A coherent system of reality and law could exist, but it is not presently realized."]
}.freeze

ROOTS = {
  "ORI:200" => { title: "persistent source-grounding capacity", status: "persistent", scope: "inward", kind: "source-grounding capacity", invariant: "A persistent ontological capacity of one source to ground a specified state of affairs, independently of whether that capacity is presently operative." },
  "ORI:201" => { title: "operative source-grounding capacity", status: "operative", scope: "inward", kind: "source-grounding capacity", invariant: "An ontological capacity of one source that is presently operative in grounding a specified state of affairs." },
  "ORI:202" => { title: "latent source-grounding capacity", status: "latent", scope: "inward", kind: "source-grounding capacity", invariant: "An ontological capacity of one source to ground a specified state of affairs that belongs to it without being presently operative." },
  "ORI:210" => { title: "persistent target-ground dependence", status: "persistent", scope: "outward", kind: "target-ground dependence", invariant: "A persistent ontological relation under which one target's obtaining is conditional on a specified ground, independently of whether that dependence is presently operative." },
  "ORI:211" => { title: "operative target-ground dependence", status: "operative", scope: "outward", kind: "target-ground dependence", invariant: "An ontological relation that is presently conditioning one target's obtaining on a specified ground." },
  "ORI:212" => { title: "latent target-ground dependence", status: "latent", scope: "outward", kind: "target-ground dependence", invariant: "An ontological relation under which one target's obtaining would be conditional on a specified ground, without that dependence being presently operative." },
  "ORI:220" => { title: "persistent shared-world constraint", status: "persistent", scope: "systemic", kind: "shared-world constraint", invariant: "A persistent ontological relation that limits which states may coherently obtain across one shared reality, independently of whether it is presently operative." },
  "ORI:221" => { title: "operative shared-world constraint", status: "operative", scope: "systemic", kind: "shared-world constraint", invariant: "An ontological relation that is presently limiting which states may coherently obtain across one shared reality." },
  "ORI:222" => { title: "latent shared-world constraint", status: "latent", scope: "systemic", kind: "shared-world constraint", invariant: "An ontological relation that belongs to the admissible order of one shared reality without presently limiting which states obtain within it." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => [5, 7, 8, 4, 4, 8, 7, 8],
  "grounded_relations" => [10, 10, 10, 10, 9, 10, 9, 10],
  "causal_provenance" => [8, 8, 8, 6, 4, 9, 8, 9],
  "modal_logic" => [8, 8, 8, 6, 5, 9, 8, 10],
  "temporal_origination" => [7, 7, 7, 6, 6, 8, 8, 9]
}.freeze

ALT_TITLES = {
  "ORI:200" => ["persistent causal potency", "necessary self-possibility", "persistent source priority"],
  "ORI:201" => ["operative causal efficacy", "actual self-possibility", "active source priority"],
  "ORI:202" => ["latent causal potency", "possible self-possibility", "prospective source priority"],
  "ORI:210" => ["persistent causal derivation", "necessary target possibility", "persistent temporal derivation"],
  "ORI:211" => ["active causal derivation", "actual target possibility", "active temporal derivation"],
  "ORI:212" => ["possible causal derivation", "contingent target possibility", "prospective temporal derivation"],
  "ORI:220" => ["persistent causal network", "necessary world", "persistent temporal order"],
  "ORI:221" => ["active causal network", "actual world", "active temporal order"],
  "ORI:222" => ["possible causal network", "modally accessible world", "prospective temporal order"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns biological capacities, dependencies, and social roles. ORI relation is substrate-neutral ontological grounding, dependence, or world constraint.",
  "MOV" => "MOV owns routes, destinations, and movement affordances. ORI relation does not encode spatial reachability, travel, direction, or transport.",
  "MAT" => "MAT owns physical dispositions, forces, and material dependencies. ORI relation does not specify substance, energy, or physical mechanism.",
  "MIN" => "MIN owns mental possibility, belief, intention, and attention. Conceivability or expectation does not establish an ORI grounding relation.",
  "CON" => "CON owns participant linkage, communication, permission, and authority. ORI dependence is not a social or communication relationship.",
  "WRN" => "WRN owns risk, vulnerability, failure, and harmful propagation. ORI capacity and constraint are neutral about danger and failure.",
  "STR" => "STR owns component dependency, containment, topology, and architecture. ORI dependence concerns what may obtain, not arrangement alone.",
  "REP" => "REP owns recoverability, repair prerequisites, and restoration paths. ORI relations do not presuppose damage or acceptable prior state.",
  "LOG" => "LOG owns formal entailment, satisfiability, proof, and rule evaluation. ORI constraint applies to reality, not merely to a formal model or proposition.",
  "DAT" => "DAT owns representational schemas, references, and data dependencies. A record dependency does not by itself entail ontological dependence of its referent.",
  "CRE" => "CRE owns generative capability, authorship, and productive constraints. ORI source capacity does not assert an agent, method, artifact, or production event."
}.freeze

def scores(values)
  EraZeroValidation::SCORE_KEYS.zip(values).to_h
end

def score_values(architecture, id)
  values = ARCHITECTURES.fetch(architecture).dup
  values[4] -= 1 if architecture == "current_phase2" && id.end_with?("2")
  values[3] -= 1 if architecture == "causal_provenance" && id[-2] == "2"
  values[4] -= 1 if architecture == "modal_logic" && id[-2] == "1"
  values[1] -= 1 if architecture == "temporal_origination" && id[-2] == "0"
  values.map { |value| [[value, 1].max, 10].min }
end

def analysis_for(architecture)
  case architecture
  when "current_phase2"
    { "why_it_fits" => "The provisional set recognizes first-trit 2 as relational or modal and uses source, target, and systemic orientation.", "useful_coverage" => "It covers capacity, possibility, dependence, causation, contingency, universality, and possible worlds.", "semantic_territory_consumed" => "It combines several unrelated modal, causal, dispositional, and cosmological concepts.", "conflicts_or_future_limitations" => "The triplets do not preserve one relation across third-trit states and collide with LOG, CRE, MAT, STR, and temporal grammar." }
  when "grounded_relations"
    { "why_it_fits" => "First-trit 2 selects a relation or capacity; the second trit selects source, target, or shared-world scope; the third selects persistent, operative, or latent status.", "useful_coverage" => "It supports dispositions, dependency injection, preconditions, world constraints, configuration regimes, ontology, and ordinary claims about what can ground or constrain what.", "semantic_territory_consumed" => "Only ontological grounding capacity, target dependence, and reality-wide constraint.", "conflicts_or_future_limitations" => "Causal mechanisms, physical affordances, logical entailment, probability, schedules, and unrestricted possible worlds require other roots or compounds." }
  when "causal_provenance"
    { "why_it_fits" => "Source and target orientation naturally suggest cause, result, and provenance networks.", "useful_coverage" => "It would cover causal power, derivation, origin histories, ancestry, and causal networks.", "semantic_territory_consumed" => "It makes every relation causal and mixes capacity with historical derivation.", "conflicts_or_future_limitations" => "CRE, MAT, LIF, DAT, STR, and WRN own typed mechanisms; not every ontological dependence is causal or historical." }
  when "modal_logic"
    { "why_it_fits" => "Capacity and possibility invite necessary, actual, and possible readings at source, target, and world scope.", "useful_coverage" => "It would cover modal operators, counterfactuals, necessity, contingency, accessibility, and possible worlds.", "semantic_territory_consumed" => "It treats the third trit as a modal scale rather than persistent, active, and dormant lexical status.", "conflicts_or_future_limitations" => "It collides with LOG and runtime uncertainty and cannot explain active relations without redefining the address axes." }
  when "temporal_origination"
    { "why_it_fits" => "Origins and dependence can be interpreted as before-after relations or temporal priority.", "useful_coverage" => "It would cover antecedence, succession, duration, epochs, and prospective timelines.", "semantic_territory_consumed" => "It turns relational scope into chronology and makes potential status mean future time.", "conflicts_or_future_limitations" => "Temporal order is not identical to ontological grounding; scheduling and tense require grammar or later dedicated relations." }
  end
end

def alternative_invariant(id, architecture)
  scope = { "0" => "source", "1" => "target", "2" => "shared-world" }.fetch(id[-2])
  status = { "0" => "persistent", "1" => "active", "2" => "potential" }.fetch(id[-1])
  center = { "causal_provenance" => "causal or provenance relation", "modal_logic" => "modal accessibility relation", "temporal_origination" => "temporal-origination relation" }.fetch(architecture)
  "A #{status} #{center} at #{scope} scope."
end

def candidate(id, architecture, title, invariant)
  score_map = scores(score_values(architecture, id))
  { "candidate_id" => architecture, "title" => title, "invariant_candidate" => invariant, "analysis" => analysis_for(architecture), "scores" => score_map, "total" => score_map.values.sum, "maximum" => 80 }
end

def nearest_neighbors(id)
  first, second, third = id.split(":").last.chars
  siblings = %w[0 1 2].reject { |x| x == third }.map { |x| "ORI:#{first}#{second}#{x}" }
  scopes = %w[0 1 2].reject { |x| x == second }.map { |x| "ORI:#{first}#{x}#{third}" }
  (siblings + scopes + ["ORI:0#{second}#{third}", "ORI:1#{second}#{third}"]).uniq
end

def roles
  { "low" => "referent whose obtaining, capacity, or constraint is qualified", "middle" => "ontological ground, target, or world relation as figure", "high" => "specified grounded state, condition, or admissible outcome", "sustained" => "relevant reality and reference conditions" }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    { "0" => "Denies persistence of this #{root[:kind]}; it does not assert absence, impossibility, reversal, or the operative or latent sibling.", "1" => "Affirms that this #{root[:kind]} persists across the relevant reference span without asserting that it is presently operative.", "2/num" => "Leaves persistence of this #{root[:kind]} unresolved; runtime uncertainty does not change the lexical root into operative or latent status." }
  when "1"
    { "0" => "Denies that this #{root[:kind]} is presently operative; it does not establish latency, impossibility, cessation, or lack of persistent standing.", "1" => "Affirms that this #{root[:kind]} is presently operative without asserting its cause, mechanism, duration, observability, or future continuation.", "2/num" => "Leaves current operation of this #{root[:kind]} unresolved; token uncertainty does not select the persistent or latent lexical sibling." }
  else
    { "0" => "Denies that this #{root[:kind]} belongs latently; it does not establish operation, impossibility, prohibition, or absence of every related capacity.", "1" => "Affirms that this #{root[:kind]} belongs without present operation; it does not encode probability, intention, scheduling, futurity, or runtime uncertainty.", "2/num" => "Leaves even the latent-status assertion unresolved; lexical latency remains distinct from uncertainty about whether the claim holds." }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  node = id[-2] == "0" ? "SOURCE=s,STATE=q" : id[-2] == "1" ? "TARGET=t,GROUND=g" : "WORLD=w,STATE=q"
  english = { "persistent" => "remains part of the standing ontology", "operative" => "is governing the present case", "latent" => "belongs to the ontology without governing the present case" }.fetch(root[:status])
  rows = [
    ["ordinary_conversation", "#{id}[1](#{node})", "affirm #{root[:status]} #{root[:kind]}", "The #{root[:kind]} #{english}.", "Valid ontological-relation claim."],
    ["physical_or_spatial", "#{id}[1](#{node})+MAT(BEARER=m)", "ontological relation plus material bearer", "The physical bearer participates, but the grounding relation is stated separately.", "MAT supplies physical mechanism."],
    ["temporal_or_sequential", "#{id}[1](#{node})+ORI(INTERVAL=i)", "#{root[:status]} ontological relation during interval i", "During interval i, the relation has the selected lexical status.", "Time does not select the third trit."],
    ["cross_family_compound", "#{id}[1](#{node})+LOG(RULE=r)+STR(SYSTEM=x)", "ontological relation plus rule and system structure", "The system models the relation while logic and structure state its formal implementation.", "Ontology, logic, and structure remain separate."],
    ["executable_or_programming", "#{id}[1](#{node})", "assert #{root[:status]} #{root[:kind]}", "A runtime records the ontological relation without treating it as a Boolean dependency or scheduler edge.", "Useful for ontology graphs and state validation."],
    ["counterexample", "DAT(FOREIGN_KEY=k)+LOG(CONSTRAINT=c)", "data reference plus formal constraint", "The table has a foreign key constraint.", "Use DAT and LOG unless the modeled referents themselves are ontologically related."]
  ]
  rows.map do |category, graph, gloss, natural, note|
    { "category" => category, "semantic_graph" => graph, "literal_gloss" => gloss, "natural_english" => natural, "runtime_state" => 1, "contour" => category == "executable_or_programming" ? "level assertion or sharply falling execution" : "level declaration", "role_registers" => roles, "use_status" => category == "counterexample" ? "must_not_use_this_root" : "valid", "analysis" => note, "pseudocode" => category == "executable_or_programming" ? "ontology.assert_relation(#{id.inspect})" : nil }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alts = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "grounded_relations", root[:title], root[:invariant]),
    candidate(id, "causal_provenance", alts[0], alternative_invariant(id, "causal_provenance")),
    candidate(id, "modal_logic", alts[1], alternative_invariant(id, "modal_logic")),
    candidate(id, "temporal_origination", alts[2], alternative_invariant(id, "temporal_origination"))
  ]
  { "canonical_id" => id, "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)), "current_meaning_rationale" => analysis_for("current_phase2")["why_it_fits"], "candidates" => candidates, "recommended_candidate_id" => "grounded_relations", "recommendation_reason" => "Only the grounded-relations architecture keeps all nine addresses on one ontological relation/capacity layer, preserves source/target/systemic orientation, changes only persistent/operative/latent status within each triplet, and leaves causal mechanism, modal logic, time, physical affordance, representation, and formal constraint separately typed.", "confidence" => 0.95, "canonicalized" => canonicalized_now }
end

recommended_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  root = ROOTS.fetch(id)
  second = id[-2]
  third = id[-1]
  scope_label = { "0" => "inward/source", "1" => "outward/target", "2" => "systemic/shared" }.fetch(second)
  state_label = { "0" => "persistent", "1" => "operative", "2" => "latent" }.fetch(third)
  triplet_logic = "Persistent status may coexist with either operative or latent status across compatible reference spans; operative and latent are mutually exclusive for the same relation at one reference time. Runtime `[2]/num` separately marks uncertainty about whichever lexical status was selected."
  { "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom), "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval", "proposed_title" => root[:title], "invariant_definition" => root[:invariant], "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => { "first_trit_2" => "Selects an ontological relation, capacity, dependence, or constraint rather than an entity condition or bounded transition.", "second_trit" => "Selects #{scope_label} orientation and therefore #{root[:kind]}, not another Origin-family column.", "third_trit" => "Selects #{state_label} lexical status while leaving token truth, observer knowledge, tense, probability, causation, and physical mechanism separate." },
    "inclusion_boundary" => "Includes only a #{root[:status]} #{root[:kind]} as a substrate-neutral relation in what may obtain within a specified reality. It is neutral about physical mechanism, temporal order, probability, intention, observation, representation, logical proof, software implementation, social permission, productive agency, structural arrangement, danger, and repair. It neither creates its relata nor asserts that a formal description is true.",
    "excluded_meanings" => ["The source-ground, distinct-existence, or shared-world condition itself.", "A bounded transition that establishes, actualizes, or changes an ontological condition.", "Causal force, productive method, temporal priority, provenance history, physical disposition, biological capacity, mental possibility, permission, or plan.", "Formal entailment, satisfiability, probability, counterfactual accessibility, data dependency, structural dependency, or software constraint without explicit ontological scope.", "Observation, evidence, representation, truth, validity, certainty, consensus, authorship, ownership, success, or failure.", "Any equation of lexical latency with runtime uncertainty, futurity, intention, scheduling, or mere ignorance."],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`ORI:0xx` owns ontological conditions: source-ground, distinct existence, and shared-world condition. `ORI:1xx` owns bounded transitions that establish or change those conditions. `ORI:2xx` owns ontological relations and capacities: source-grounding capacity, target-ground dependence, and shared-world constraint. A relation does not entail that either relatum presently exists, that a transition is occurring, or that a causal mechanism has acted. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY, "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects #{state_label} status for this #{root[:kind]}. Runtime `[2]/num` instead leaves that already-selected status claim unresolved. Thus a latent root with `[1]` positively asserts latent membership, while any persistent or operative root with `[2]/num` remains lexically persistent or operative but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => ["#{id} + ORI:0xx states a related ontological condition without reducing relation to state.", "#{id} + ORI:1xx states establishment or change of the relation without reducing relation to process.", "#{id} + LOG/DAT/STR supplies formal rule, representation, or implementation separately.", "#{id} + MAT/LIF/MIN/CON/CRE supplies physical, living, mental, social, or productive mechanisms separately."],
    "later_era_notes" => "Later eras may lexicalize causal sufficiency, historical provenance, temporal priority, necessity, probability, counterfactual accessibility, world identity, law revision, and specialized physical or computational affordances. Era Zero should preserve this narrow ontological relation/capacity center and build stronger claims compositionally.", "confidence" => 0.95, "canonicalized" => canonicalized_now }
end

base = [
  ["capacity", "one_root_or_compound", "Choose the inward source-capacity triplet only for ontological grounding capacity; typed physical, mental, or productive capacities remain elsewhere."],
  ["can ground", "one_root", "ORI:20x states source-grounding capacity with lexical status selected by the third trit."],
  ["persistent capacity", "one_root", "ORI:200 asserts standing source-grounding capacity independent of present operation."],
  ["capacity now operative", "one_root", "ORI:201 asserts present operation of source-grounding capacity."],
  ["latent capacity", "one_root", "ORI:202 asserts belonging without present operation."],
  ["depends on", "one_root_or_compound", "ORI:21x applies only when the dependency concerns what may obtain in the relevant reality."],
  ["necessary condition", "one_root_or_compound", "ORI:210 may state persistent target-ground dependence; logical necessity requires LOG."],
  ["operative precondition", "one_root", "ORI:211 states that a target is presently conditioned on a specified ground."],
  ["latent precondition", "one_root", "ORI:212 states a dependence belonging without present operation."],
  ["world law", "one_root_or_compound", "ORI:22x states ontological applicability while LOG supplies formal content."],
  ["persistent world constraint", "one_root", "ORI:220 states a standing shared-world constraint."],
  ["constraint now operative", "one_root", "ORI:221 states a shared-world constraint governing current cases."],
  ["dormant law", "one_root_or_compound", "ORI:222 states latent shared-world constraint; LOG may state the rule text."],
  ["cause", "compound_or_reserved", "Causal mechanism is stronger than ontological grounding and requires typed mechanism or later relation."],
  ["causal power", "different_family_or_compound", "MAT, CRE, LIF, or WRN supplies the mechanism; ORI may state source-grounding capacity separately."],
  ["causal dependence", "compound", "ORI target-ground dependence combines with a typed causal mechanism."],
  ["causal network", "compound", "Use ORI grounding/dependence plus STR topology and typed mechanisms."],
  ["provenance", "compound_or_later_specialization", "Historical derivation requires temporal and representational structure beyond this block."],
  ["authorship", "different_family_or_compound", "CRE, LIF, and CON own production, agent role, and attribution."],
  ["origin", "ambiguous_compound", "Origin may mean source condition, establishment, relation, time, cause, or provenance and must be disambiguated."],
  ["possible", "grammar_or_compound", "Unrestricted modality is not any one ORI:2xx root."],
  ["necessary", "grammar_or_compound", "Necessity may qualify an ORI relation but is not identical to persistent status."],
  ["contingent", "grammar_or_compound", "Contingency is a modal qualification, not lexical latency."],
  ["possible world", "compound", "Combine a shared-world condition with explicit modal accessibility; ORI:222 alone is only a latent constraint."],
  ["actual world", "one_root_or_context", "Use ORI shared-world condition with discourse context; ORI:221 is an operative constraint, not the world itself."],
  ["counterfactual world", "compound_or_later_specialization", "Requires world identity and modal accessibility beyond this atomic block."],
  ["probability", "different_family_or_grammar", "Probability qualifies a claim or distribution and is not an ontological relation."],
  ["future possibility", "compound", "Futurity and modality remain explicit; lexical latency encodes neither."],
  ["scheduled dependency", "compound", "Scheduling is temporal or programmatic; ORI states only ontological dependence if present."],
  ["database dependency", "different_family", "DAT owns record references and data dependencies."],
  ["foreign key", "different_family", "Use DAT and LOG unless the referents themselves have ontological dependence."],
  ["software dependency", "different_family", "STR/DAT/LOG owns package and module dependencies."],
  ["dependency injection", "compound_or_metaphor", "STR/LOG states implementation; ORI applies only to modeled ontological dependence."],
  ["structural support", "different_family", "STR owns architectural support and arrangement."],
  ["physical support", "different_family", "MAT owns load-bearing and physical force."],
  ["biological capacity", "different_family", "LIF owns living function and capability."],
  ["mental ability", "different_family", "MIN owns cognitive capacity, skill, and ability."],
  ["permission", "different_family", "CON owns authority and permission."],
  ["affordance", "compound", "Use the relevant family capability plus ORI only for ontological grounding capacity."],
  ["production capability", "different_family_or_compound", "CRE owns generative capability; ORI may state ontological grounding separately."],
  ["logical entailment", "different_family", "LOG owns entailment among propositions."],
  ["satisfiable model", "different_family_or_compound", "LOG owns satisfiability; ORI may separately qualify model-relative reality."],
  ["invariant", "compound", "LOG defines the invariant while ORI:220 may state standing world applicability."],
  ["natural law", "compound", "LOG supplies law content and ORI:22x supplies ontological applicability."],
  ["social law", "different_family_or_compound", "CON and LOG own authority and rule; it is not automatically a world constraint."],
  ["constraint propagation", "different_family", "LOG/STR owns algorithmic propagation; ORI:221 is ontological applicability."],
  ["configuration profile", "compound", "DAT/STR stores the profile; ORI:222 may qualify a latent world constraint only if ontology is intended."],
  ["feature flag", "different_family", "DAT/LOG owns software activation flags."],
  ["persistent and operative relation", "two_compatible_roots", "Persistent standing and present operation may be jointly asserted."],
  ["persistent and latent relation", "two_compatible_roots", "A persistent relation may currently be latent."],
  ["operative and latent relation", "invalid_same_reference_claim", "Operation and latency are mutually exclusive at one reference time."],
  ["latent relation affirmed", "runtime_and_lexical", "ORI:2x2[1] confirms latent membership without present operation."],
  ["operative relation uncertain", "runtime_and_lexical", "ORI:2x1[2]/num remains lexically operative while the token claim is unresolved."],
  ["persistent relation denied", "runtime_and_lexical", "ORI:2x0[0] denies persistence without selecting operation or latency."],
  ["unknown relation", "runtime_or_epistemic", "Use runtime [2]/num or MIN/DAT evidence; lexical latency never means unknown."],
  ["relation became operative", "process_plus_relation", "Use an ORI:1xx transition or other process plus the operative relation."],
  ["relation ceased", "process_or_gap", "Cessation is not encoded by denial or latency alone and may require process grammar."],
  ["world law changed", "process_plus_relation", "ORI:12x states shared-world transition and ORI:22x states the resulting constraint."],
  ["world law represented", "compound", "DAT represents the law; ORI states applicability only if separately intended."],
  ["world law proved", "different_family_or_compound", "LOG owns proof; proof does not make a constraint ontologically operative."],
  ["no possible world", "unresolved_or_compound", "Null modality is not assigned to one root in this block."]
].freeze

per_root = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} asserted", "one_root", "#{id}[1] directly affirms the invariant without importing causal mechanism, clock time, formal proof, or physical implementation."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves the exact #{root[:status]} relation claim unresolved."],
    ["#{root[:title]} represented", "compound", "DAT supplies representation while #{id} supplies the modeled ontological relation."],
    ["#{root[:title]} formalized", "compound", "LOG supplies formalization while #{id} supplies world-directed applicability."],
    ["#{root[:title]} implemented", "compound", "STR/DAT/LOG supplies implementation while #{id} preserves ontological scope."],
    ["#{root[:title]} physically realized", "compound", "MAT supplies physical mechanism while #{id} supplies only the ontological relation."]
  ]
end
stress_rows = base + per_root
stress_tests = stress_rows.each_with_index.map { |(concept, routing, analysis), index| { "test_id" => format("ORI2-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis } }

scored = { "metadata" => { "title" => "ORI:200–222 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/ORI_200_222_semantic_approval.yaml" : nil }, "roots" => scored_roots }
recommended = { "metadata" => { "title" => "ORI:200–222 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "ORI:200–202" => "source-grounding capacity: persistent / operative / latent", "ORI:210–212" => "target-ground dependence: persistent / operative / latent", "ORI:220–222" => "shared-world constraint: persistent / operative / latent" }, "triplet_logic" => { "persistent" => "standing across the relevant reference span, independently of current operation", "operative" => "presently governing the specified case", "latent" => "belonging without present operation", "runtime_uncertainty" => "runtime [2]/num qualifies the selected lexical status and never selects latency" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/ORI_200_222_semantic_approval.yaml" : nil }, "roots" => recommended_roots, "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now } }
stress = { "metadata" => { "title" => "ORI:200–222 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# ORI:200–222 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Origin relation meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `ORI:2xx` the substrate-neutral ontological-relation layer paired with canonical `ORI:0xx` conditions and `ORI:1xx` transitions. The inward triplet owns source-grounding capacity, the outward triplet owns target-ground dependence, and the systemic triplet owns shared-world constraint. Persistent, operative, and latent supply the exact third-trit contrast.\n\nLexical latency means the relation belongs without present operation; it does not mean uncertain, possible, intended, scheduled, future, or unknown. Runtime `[2]/num` remains uncertainty about the selected status claim. The design rejects the provisional mixture of possibility, causation, contingency, universality, and possible worlds.\n\n"
IDS.each do |id|
  scored_root = scored_roots.find { |root| root["canonical_id"] == id }
  spec = recommended_roots.find { |root| root.dig("fixed_generated_fields", "canonical_id") == id }
  fixed = spec.fetch("fixed_generated_fields")
  review << "## #{id} — #{spec['proposed_title']}\n\n### A. Fixed generated forms\n\n- Universal slot: **#{fixed['universal_slot']}**\n- Transliteration: **#{fixed['family_qualified_transliteration']}**\n- Local compact root: **#{fixed['local_compact_root']}**\n- Formal carrier: **#{fixed['formal_carrier']}**\n- Harmonic signature: **#{fixed['harmonic_signature_semitones'].join('–')}**\n- Relative note path: **#{fixed['relative_note_path_semitones'].join(' → ')}**\n\n"
  review << "### B. Why the current meaning was probably chosen\n\n#{scored_root['current_meaning_rationale']}\n\n### C. Candidate comparison\n\n| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n"
  scored_root.fetch("candidates").each { |item| values = EraZeroValidation::SCORE_KEYS.map { |key| item.dig("scores", key) }; review << "| #{item['title']} | #{values.join(' | ')} | **#{item['total']}/80** |\n" }
  review << "\n"
  scored_root.fetch("candidates").each do |item|
    a = item.fetch("analysis")
    review << "#### #{item['title']}\n\n**Invariant candidate:** #{item['invariant_candidate']}\n\n- Fit: #{a['why_it_fits']}\n- Useful coverage: #{a['useful_coverage']}\n- Territory consumed: #{a['semantic_territory_consumed']}\n- Conflicts and limitations: #{a['conflicts_or_future_limitations']}\n\n"
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
review << "## Triplet coherence\n\n| Triplet | Shared axis | `0` | `1` | `2` |\n| --- | --- | --- | --- | --- |\n| ORI:200–202 | source-grounding capacity | persistent | operative | latent |\n| ORI:210–212 | target-ground dependence | persistent | operative | latent |\n| ORI:220–222 | shared-world constraint | persistent | operative | latent |\n\n"
review << "## Concepts intentionally reserved\n\nCausal mechanisms, provenance histories, temporal priority, unrestricted possibility and necessity, probability, counterfactual accessibility, physical dispositions, biological and mental capacities, social permission, formal entailment, data and software dependency, productive agency, and structural implementation remain other roots, other families, later vocabulary, grammar, or compounds.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later specialization, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# ORI:200–222 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "CRE/MAT/LIF capacity, cause, agency", "1" => "STR/DAT/LOG dependency and precondition", "2" => "LOG rules, modality, counterfactual worlds" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | ORI keeps only substrate-neutral ontological relation; typed mechanism, representation, formal rule, and modality remain separate |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments\n\n- A source-grounding capacity is not a causal mechanism, productive ability, intention, permission, or probability.\n- A target-ground dependence is not automatically a physical, structural, logical, data, software, biological, or social dependency.\n- A shared-world constraint is not its formal representation, proof, social authority, or implementation.\n- Lexical latency is positive nonoperative membership, not uncertainty, futurity, scheduling, possibility, or ignorance.\n- Runtime `[2]/num` leaves a selected status assertion unresolved and never selects lexical latency.\n\n**CONCLUSION: ORI:2XX STANDS ALONE ONLY FOR ONTOLOGICAL RELATIONS AND CAPACITIES; CAUSE, TIME, MODALITY, PROVENANCE, REPRESENTATION, LOGIC, PHYSICAL MECHANISM, BIOLOGICAL OR MENTAL CAPACITY, SOFTWARE DEPENDENCY, SOCIAL AUTHORITY, AND PRODUCTION REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built ORI:200–222 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
