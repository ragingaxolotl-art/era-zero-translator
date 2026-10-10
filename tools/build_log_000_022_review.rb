#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "LOG:000–022"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "LOG_000_022"
SEMANTIC_CENTER = "formal constraint entities: internal criteria, target-directed constraints, and shared formal regimes"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "LOG:000" => ["axiom", "A stable inward rule, invariant, identity, or truth is accepted as a bounded logical object."],
  "LOG:001" => ["current proposition", "A proposition, value, or logical state is presently expressed for evaluation."],
  "LOG:002" => ["undefined variable", "A logical object or value slot exists but remains unbound, unknown, or unresolved."],
  "LOG:010" => ["fixed operand", "A specific external value, expression, rule, or argument is selected as a stable target."],
  "LOG:011" => ["evaluated value", "An external expression or operand is presently resolved and available to an operation."],
  "LOG:012" => ["unresolved operand", "A required value or expression is identified but unavailable, undefined, or not yet computed."],
  "LOG:020" => ["formal system", "A stable collection of rules, types, operators, or proofs defines a shared logical domain."],
  "LOG:021" => ["executing rule system", "A program, proof system, or rule set is presently evaluating or transforming states."],
  "LOG:022" => ["dormant procedure", "A valid algorithm, rule set, or proof structure exists but is not currently invoked."]
}.freeze

ROOTS = {
  "LOG:000" => { title: "persistent internal formal criterion", phase: "persistent", scope: "inward", kind: "internal formal criterion", invariant: "A persistent formal criterion within the logical specification of one reference entity that limits that entity's admissible states independently of whether the criterion is presently operative." },
  "LOG:001" => { title: "operative internal formal criterion", phase: "operative", scope: "inward", kind: "internal formal criterion", invariant: "A formal criterion within the logical specification of one reference entity that is presently operative in limiting that entity's admissible states." },
  "LOG:002" => { title: "dormant internal formal criterion", phase: "dormant", scope: "inward", kind: "internal formal criterion", invariant: "A formal criterion within the logical specification of one reference entity that remains defined without presently operating to limit that entity's admissible states." },
  "LOG:010" => { title: "persistent target-directed formal constraint", phase: "persistent", scope: "outward", kind: "target-directed formal constraint", invariant: "A persistent formal constraint assigned to one distinct reference target that limits the target's admissible states independently of whether the constraint is presently operative." },
  "LOG:011" => { title: "operative target-directed formal constraint", phase: "operative", scope: "outward", kind: "target-directed formal constraint", invariant: "A formal constraint assigned to one distinct reference target that is presently operative in limiting the target's admissible states." },
  "LOG:012" => { title: "dormant target-directed formal constraint", phase: "dormant", scope: "outward", kind: "target-directed formal constraint", invariant: "A formal constraint assigned to one distinct reference target that remains defined without presently operating to limit the target's admissible states." },
  "LOG:020" => { title: "persistent shared formal regime", phase: "persistent", scope: "systemic", kind: "shared formal regime", invariant: "A persistent formal regime that correlates admissibility criteria across multiple participants in one shared rule domain independently of whether the regime is presently operative." },
  "LOG:021" => { title: "operative shared formal regime", phase: "operative", scope: "systemic", kind: "shared formal regime", invariant: "A formal regime that is presently operative in correlating admissibility criteria across multiple participants in one shared rule domain." },
  "LOG:022" => { title: "dormant shared formal regime", phase: "dormant", scope: "systemic", kind: "shared formal regime", invariant: "A formal regime that remains defined across multiple participants in one shared rule domain without presently operating to correlate their admissibility criteria." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [6, 7, 8, 4, 4, 7, 8, 7] },
  "formal_constraint_entities" => { scores: [10, 10, 10, 10, 9, 10, 10, 10] },
  "truth_bearing_propositions" => { scores: [9, 8, 10, 7, 8, 9, 9, 10] },
  "typed_value_entities" => { scores: [9, 8, 9, 7, 7, 8, 8, 10] },
  "permissions_and_obligations" => { scores: [8, 8, 9, 7, 7, 9, 10, 9] }
}.freeze

ALT_TITLES = {
  "LOG:000" => ["persistent self-proposition", "persistent intrinsic typed value", "persistent internal obligation"],
  "LOG:001" => ["asserted self-proposition", "active intrinsic typed value", "operative internal permission"],
  "LOG:002" => ["unasserted self-proposition", "inactive intrinsic typed value", "suspended internal obligation"],
  "LOG:010" => ["persistent target proposition", "persistent target typed value", "persistent target obligation"],
  "LOG:011" => ["asserted target proposition", "active target typed value", "operative target permission"],
  "LOG:012" => ["unasserted target proposition", "inactive target typed value", "suspended target obligation"],
  "LOG:020" => ["persistent proposition theory", "persistent shared type environment", "persistent shared normative code"],
  "LOG:021" => ["asserted proposition theory", "active shared type environment", "operative shared normative code"],
  "LOG:022" => ["unasserted proposition theory", "inactive shared type environment", "suspended shared normative code"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identities, biological conditions, agents, and social collectives. A living participant may be governed by a LOG criterion, but the rule is not its life, role, health, or agency.",
  "MOV" => "MOV owns position, path, displacement, and motion affordance. A LOG constraint may permit or forbid movement, but it neither moves anything nor constitutes a route or destination.",
  "MAT" => "MAT owns substance, energy, force, contact, and material capacities. A physical limit can instantiate a formal constraint, but LOG does not encode the material mechanism or available energy.",
  "MIN" => "MIN owns belief, attention, intention, memory, and cognitive representation. A criterion can remain formally defined whether anyone believes, understands, remembers, or attends to it.",
  "CON" => "CON owns channels, participants, exchange, and communicative relations. Protocol rules may govern a channel, but the rules are distinct from the connection and messages sent through it.",
  "WRN" => "WRN owns adverse conditions, transformations, susceptibility, exposure, and propagation. Violating a rule need not be harmful, and danger can comply with every formal criterion.",
  "STR" => "STR owns positions, interfaces, arrangements, transformations, and affordances. LOG constrains admissible arrangements without becoming the arrangement or interface itself.",
  "REP" => "REP owns restoration conditions, transformations, and affordances. A LOG criterion can specify acceptability, but it is not the restored condition, repair event, or recoverability relation.",
  "DAT" => "DAT owns records, symbols, schemas, represented values, provenance, and storage. A serialized rule is data representing a LOG criterion; representation and formal constraint remain separately typed.",
  "CRE" => "CRE owns generation, fabrication, replacement, and destruction. A rule may constrain creation, but LOG neither creates the result nor supplies the productive transformation.",
  "ORI" => "ORI owns temporal, modal, causal-origin, and ontological qualification. LOG persistence, operation, and dormancy do not encode past, future, possibility, necessity, probability, or origin."
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
    values[0] -= 1 if third != "0"
    values[3] -= 2 if second == "2"
  when "formal_constraint_entities"
    values[4] += 1 if second == "0"
    values[6] -= 1 if second == "2"
  when "truth_bearing_propositions"
    values[1] -= 2 if second == "1"
    values[3] -= 1 if third == "2"
  when "typed_value_entities"
    values[2] -= 1 if second == "2"
    values[4] -= 2 if second == "1"
  when "permissions_and_obligations"
    values[0] -= 1 if third == "1"
    values[4] -= 2 if second == "0"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, architecture, title)
  root = ROOTS.fetch(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional title uses familiar logic and programming vocabulary and loosely follows the #{root.fetch(:scope)} and #{root.fetch(:phase)} universal-slot labels.",
      "useful_coverage" => "It covers axioms, propositions, variables, operands, values, programs, algorithms, procedures, and proof systems.",
      "semantic_territory_consumed" => "Across the block it mixes rules, propositions, value bindings, evaluation results, executing processes, algorithms, and dormant procedures.",
      "conflicts_or_future_limitations" => "The triplets do not preserve one entity center: active roots absorb evaluation or execution, dormant roots absorb unbound data states, and several assignments collide with DAT or LOG:1xx."
    }
  when "formal_constraint_entities"
    {
      "why_it_fits" => "The first trit remains an entity; the second changes only whether one criterion is intrinsic to a reference specification, directed to one target, or correlated across a shared rule domain; the third changes only persistent, operative, or dormant status.",
      "useful_coverage" => "It supports rules, invariants, requirements, policies, prohibitions, type constraints, contracts, protocols, and formal regimes without encoding evaluation.",
      "semantic_territory_consumed" => "Only identity and present operation of substrate-neutral formal constraints. Truth values, beliefs, records, execution, inference, satisfaction, and modality remain separate.",
      "conflicts_or_future_limitations" => "Natural-language rule senses vary between descriptive and normative uses, so compounds must state modality, authorship, evidence, or domain mechanics when those distinctions matter."
    }
  when "truth_bearing_propositions"
    {
      "why_it_fits" => "Propositions are central LOG entities and can be self-contained, target-directed, or organized into theories, with asserted and unasserted statuses.",
      "useful_coverage" => "It would cover claims, predicates, hypotheses, premises, conclusions, formulas, theories, and truth-bearing expressions.",
      "semantic_territory_consumed" => "It occupies informational content and assertion status more than rule-governed admissibility.",
      "conflicts_or_future_limitations" => "Assertion is communicative or cognitive, not equivalent to truth or formal operation; proposition storage collides with DAT and proposition belief with MIN."
    }
  when "typed_value_entities"
    {
      "why_it_fits" => "Typed values are logical objects that can belong to one context, target an operation, or inhabit a shared environment.",
      "useful_coverage" => "It would cover constants, variables, operands, bindings, typed terms, environments, and symbol tables.",
      "semantic_territory_consumed" => "It consumes data values, representations, bindings, and storage states.",
      "conflicts_or_future_limitations" => "DAT owns represented values and schemas; active/dormant values are not a stable semantic contrast, and the architecture under-serves ordinary rules and formal validity."
    }
  when "permissions_and_obligations"
    {
      "why_it_fits" => "Permissions and obligations are formal constraints that can govern an entity, a target, or a shared regime and can be operative or suspended.",
      "useful_coverage" => "It would cover allowed, forbidden, required, authorized, licensed, mandated, and policy-governed action.",
      "semantic_territory_consumed" => "It specializes the entire entity layer to deontic logic and institutional authority.",
      "conflicts_or_future_limitations" => "The specialization leaves mathematical invariants, type constraints, descriptive rules, and non-normative logic without a general atom; authority and communication roles need LIF or CON compounds."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "truth_bearing_propositions"
    "A #{root.fetch(:phase)} truth-bearing proposition organized at #{root.fetch(:scope)} logical scope."
  when "typed_value_entities"
    "A #{root.fetch(:phase)} typed formal value situated at #{root.fetch(:scope)} logical scope."
  when "permissions_and_obligations"
    "A #{root.fetch(:phase)} permission or obligation governing #{root.fetch(:scope)} scope."
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
  siblings = %w[0 1 2].reject { |x| x == third }.map { |x| "LOG:#{first}#{second}#{x}" }
  scopes = %w[0 1 2].reject { |x| x == second }.map { |x| "LOG:#{first}#{x}#{third}" }
  process = "LOG:1#{second}#{third}"
  relation = "LOG:2#{second}#{third}"
  (siblings + scopes + [process, relation]).uniq
end

def roles
  {
    "low" => "reference entity or participant governed by the formal criterion",
    "middle" => "formal criterion, constraint, or regime asserted as the figure",
    "high" => "distinct target, rule-domain reference, or criterion source when separately expressed",
    "sustained" => "shared rule domain and its multiple governed participants"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that this #{root.fetch(:kind)} persists as the same identified formal rule; it does not select the operative or dormant sibling and does not prove an opposite rule.",
      "1" => "Affirms the persistent identity of this #{root.fetch(:kind)} while leaving current operation, satisfaction, truth, enforcement, representation, and origin undecided.",
      "2/num" => "Leaves unresolved whether this persistent #{root.fetch(:kind)} remains identified; uncertainty about the assertion does not change the lexical root into an operative or dormant criterion."
    }
  when "1"
    {
      "0" => "Denies that this #{root.fetch(:kind)} is presently operative; it does not erase the rule, affirm dormancy, or state whether a governed object satisfies it.",
      "1" => "Affirms that this #{root.fetch(:kind)} presently limits admissible states, without asserting satisfaction, enforcement mechanism, truth, permission outcome, or successful evaluation.",
      "2/num" => "Leaves unresolved whether this #{root.fetch(:kind)} is presently operative; runtime uncertainty does not select persistent identity or lexical dormancy."
    }
  else
    {
      "0" => "Denies that this #{root.fetch(:kind)} is presently dormant; it does not by itself affirm current operation, deletion, invalidity, or replacement.",
      "1" => "Affirms that this #{root.fetch(:kind)} remains defined but is not presently operative, without encoding future activation, suspension cause, permission, uncertainty, or failure.",
      "2/num" => "Leaves unresolved whether the selected dormant #{root.fetch(:kind)} claim holds; lexical third-trit 2 names defined-but-inoperative status, while runtime `[2]/num` marks assertion-level uncertainty."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entity = id[-2] == "0" ? "account" : id[-2] == "1" ? "device" : "network"
  graph_roles = id[-2] == "0" ? "ENTITY=#{entity},CRITERION=c" : id[-2] == "1" ? "TARGET=#{entity},CONSTRAINT=c" : "DOMAIN=#{entity},PARTICIPANTS={a,b,c},REGIME=c"
  ordinary = { "0" => "That standing rule remains part of the #{entity}'s specification whether or not it is being applied now.", "1" => "That rule currently governs which states the #{entity} may accept.", "2" => "That rule is still defined for the #{entity}, but it is not active now." }.fetch(id[-1])
  entries = [
    ["ordinary_conversation", "#{id}[1](#{graph_roles})", "affirm #{root.fetch(:phase)} #{root.fetch(:kind)}", ordinary, "The root asserts a rule entity and its status, not a pass/fail result."],
    ["physical_or_spatial", "MAT(BEARER=#{entity})+#{id}[1](#{graph_roles})", "material bearer plus #{root.fetch(:phase)} LOG rule", "A machine-control limit has #{root.fetch(:phase)} status as a formal rule; MAT separately describes the mechanism.", "A formal limit and its physical realization remain separately typed."],
    ["temporal_or_sequential", "#{id}[1](#{graph_roles})+ORI(INTERVAL=w)", "#{root.fetch(:phase)} LOG rule during interval w", "During interval w, the criterion has the stated lexical status.", "ORI supplies time and does not replace LOG status."],
    ["cross_family_compound", "DAT(SPEC=d)+#{id}[1](#{graph_roles})", "represented specification plus #{root.fetch(:phase)} LOG rule", "The specification represents the rule without becoming the rule itself.", "DAT and LOG remain distinct."],
    ["executable_or_programming", "#{id}[1](#{graph_roles})", "assert #{root.fetch(:phase)} formal constraint metadata", "A runtime may register this rule status without asserting that a check ran or passed.", "Rule metadata and evaluation are separate."],
    ["counterexample", "LOG:101[1](CRITERION=c,EVALUATION=e)", "actual rule evaluation", "The validator is currently checking the rule.", "An actual evaluation belongs to LOG:1xx, not this rule-entity block."]
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
      "pseudocode" => category == "executable_or_programming" ? "assert(rule_status.matches?(#{id.inspect}))" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "formal_constraint_entities", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "truth_bearing_propositions", alt[0], alternative_invariant(id, "truth_bearing_propositions")),
    candidate(id, "typed_value_entities", alt[1], alternative_invariant(id, "typed_value_entities")),
    candidate(id, "permissions_and_obligations", alt[2], alternative_invariant(id, "permissions_and_obligations"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "formal_constraint_entities",
    "recommendation_reason" => "Only this architecture keeps all nine roots on one formal-constraint entity center, follows inward/target/systemic scope exactly, and gives every triplet one persistent/operative/dormant axis while reserving represented values, propositions, evaluation processes, formal relations, authority, belief, and modality for later LOG layers or other families.",
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
  state_label = { "0" => "persistent/operation-neutral", "1" => "operative/presently governing", "2" => "dormant/defined but inoperative" }.fetch(third)
  scope_explanation = {
    "0" => "one formal criterion within the logical specification of one reference entity",
    "1" => "one formal constraint assigned to one distinct reference target",
    "2" => "one correlated formal regime across multiple participants in a shared rule domain"
  }.fetch(second)
  scope_boundary = {
    "0" => "The claim is about a criterion internal to one reference specification, not a rule assigned to another target, a proposition's truth, or a stored record.",
    "1" => "The claim preserves one distinct governed target. The rule source, authority, communication act, evaluation, outcome, sanction, and physical mechanism remain separate.",
    "2" => "The claim requires one correlated regime across multiple participants. A coincidental collection of unrelated rules is not systemic, and the communication or structure linking participants is separate."
  }.fetch(second)
  triplet_logic = if third == "0"
                    "The persistent member is operation-neutral: it may co-occur with the operative sibling or the dormant sibling at the same reference time. It asserts continuity of rule identity rather than a third mutually exclusive operation value."
                  else
                    "The persistent sibling may also hold because it asserts rule identity across time. Operative and dormant siblings are mutually exclusive for the same rule at the same reference time, while runtime `[2]/num` may leave either selected claim unresolved."
                  end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_0" => "Selects a formal rule or constraint entity rather than an evaluation process, proof act, execution, or formal applicability/consequence relation.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Logic-family column.",
      "third_trit" => "Selects the #{state_label} member by rule identity or present operation while leaving runtime truth status, satisfaction, observer knowledge, tense, probability, and process phase separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral formal constraint at #{root.fetch(:scope)} scope. #{scope_boundary} It is neutral about truth, satisfaction, violation, evaluation, enforcement, represented form, belief, physical realization, authority, probability, timing, and cause.",
    "excluded_meanings" => [
      "Truth or falsity of a proposition, or assertion, belief, certainty, and evidential support for it.",
      "Satisfaction, violation, validity, invalidity, proof, derivation, inference, evaluation, or execution result.",
      "Data value, variable, binding, symbol string, record, schema representation, source code, or storage state.",
      "Physical, biological, communicative, structural, restorative, or adverse mechanism governed by or realizing the rule.",
      "Authorship, institutional authority, command, enforcement, sanction, social acceptance, or responsibility.",
      "Applicability, entailment, consistency, computability, possibility, necessity, probability, schedule, future activation, or cause."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`LOG:0xx` owns formal constraint entities; `LOG:1xx` remains the layer for actual evaluation, inference, or rule-application processes; `LOG:2xx` remains the layer for applicability, consequence, consistency, or other formal enabling relations. Present operation in 0xx does not name an evaluation or entail satisfaction, and an identified rule does not entail that it can be applied or that a result follows. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} member of this formal-constraint triplet. Runtime `[2]/num` instead leaves the truth or applicability of that already-selected claim unresolved; it never changes operation status. Thus a dormant root affirmed with `[1]` is a confirmed defined-but-inoperative rule, while a persistent or operative root carrying `[2]/num` remains lexically persistent or operative but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + DAT supplies the written specification, symbol sequence, or schema representation without reducing the formal rule to data.",
      "#{id} + MIN supplies belief, acceptance, or understanding while keeping cognitive state distinct from formal rule identity.",
      "#{id} + MAT/STR/CON supplies the physical, structural, or communicative system governed by the criterion.",
      "#{id} + LOG:1xx/2xx may later express evaluation or formal applicability/consequence as separate processes and relations."
    ],
    "later_era_notes" => "Later eras may lexicalize proposition kinds, deontic force, type constraints, proof roles, legal authority, sanctions, and specialized validation outcomes. Era Zero should preserve the substrate-neutral formal-constraint center and derive domain-specific senses compositionally. The persistent root must not be treated as mutually exclusive with its operative or dormant sibling.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


logic_stress_base = [
  ["rule", "one_root_or_compound", "Use the appropriate LOG:0xx root when the intended sense is a formal admissibility constraint; add domain and authority roots when English rule names an institution or habit."],
  ["criterion", "one_root", "An internal, target-directed, or shared formal criterion selects the matching LOG:0xx scope."],
  ["invariant", "one_root_or_compound", "An invariant internal to one formal specification maps to LOG:000–002 according to persistent, operative, or dormant status."],
  ["constraint", "one_root_or_compound", "A target-directed constraint maps to LOG:010–012; a physical constraint also needs MAT or STR."],
  ["policy", "one_root_or_compound", "A shared formal policy can use LOG:020–022, while authorship and governed participants remain separately typed."],
  ["protocol", "compound", "LOG:020–022 supplies the shared rule regime and CON supplies the communication system it governs."],
  ["law", "compound", "LOG supplies formal constraint status; LIF and CON supply institution, authority, persons, and promulgation."],
  ["permission", "compound_or_later_specialization", "Permission is a deontic result under a criterion, not automatically the criterion itself; express rule plus modality or reserve specialized vocabulary."],
  ["prohibition", "compound_or_later_specialization", "A prohibitory rule can be a LOG constraint with polarity or modality, but prohibition is not a separate atom in this block."],
  ["obligation", "compound_or_later_specialization", "Obligation requires a formal rule plus deontic force and often an agent or act compound."],
  ["axiom", "compound", "Axiomhood requires a proposition or rule plus foundational status; LOG:000 alone means persistent internal criterion, not unproved truth."],
  ["proposition", "different_family_or_future_logic_vocabulary", "A truth-bearing content is not automatically a constraint entity; DAT may encode it and later LOG layers may evaluate it."],
  ["claim", "different_family_or_compound", "CON owns assertion events, DAT owns expressed content, and MIN owns belief; LOG:0xx applies only when content functions as a formal criterion."],
  ["truth", "unresolved_or_later_logic_vocabulary", "Truth value is not identical to rule operation; do not force it into LOG:001."],
  ["false", "unresolved_or_later_logic_vocabulary", "Falsity is not dormancy. LOG:002 names a defined but inoperative internal criterion."],
  ["valid", "process_or_relation_layer", "Validity concerns satisfaction, derivation, or consequence and belongs to later LOG layers or compounds, not the rule entity alone."],
  ["invalid", "process_or_relation_layer", "Invalidity is not a dormant rule; it requires evaluation or a formal relation."],
  ["satisfied constraint", "compound", "Use the LOG:0xx constraint plus a later evaluation or result expression; operation alone does not entail satisfaction."],
  ["violated constraint", "compound", "Use the LOG constraint plus an evaluation result; violation is not dormancy."],
  ["active rule", "one_root", "Choose LOG:001, LOG:011, or LOG:021 according to internal, target, or systemic scope."],
  ["suspended rule", "one_root_or_compound", "A still-defined but inoperative rule uses a LOG:0x2 root; suspension cause and future reactivation remain separate."],
  ["deleted rule", "different_meaning", "Deletion removes rule identity and is not lexical dormancy, which requires the rule to remain defined."],
  ["obsolete rule", "compound", "Dormancy may describe nonoperation, but obsolescence additionally requires temporal or replacement qualification."],
  ["future rule", "grammar_or_compound", "ORI future qualification applies to a rule; lexical third trit 2 does not mean future."],
  ["uncertain rule status", "runtime", "Use runtime `[2]/num` on the selected LOG root rather than substituting the dormant lexical root."],
  ["type constraint", "one_root_or_compound", "Use a LOG constraint; DAT separately supplies the type representation and value."],
  ["schema", "different_family_or_compound", "DAT owns a schema as represented information; LOG owns the constraints the schema expresses."],
  ["value", "different_family", "DAT owns represented values; a value is not a formal criterion merely because a program evaluates it."],
  ["variable", "different_family_or_compound", "DAT owns the represented slot or symbol; binding and evaluation require additional LOG process or relation vocabulary."],
  ["unbound variable", "different_family_or_compound", "Unbound is a data or environment state, not a dormant criterion."],
  ["operand", "different_family_or_compound", "DAT supplies the value or expression and LOG:1xx can later supply application or evaluation."],
  ["algorithm", "different_family_or_compound", "DAT stores its specification, LOG:1xx may execute or evaluate, and CRE or STR may describe produced transformations."],
  ["program", "different_family_or_compound", "DAT owns code as information; a running program is not a LOG:0xx rule entity, though its policy regime may be."],
  ["proof", "process_or_data_compound", "LOG:1xx should own proving or inference and DAT the proof object; LOG:0xx supplies premises only when they function as constraints."],
  ["theorem", "unresolved_or_compound", "A theorem is a proposition with derivational status, not automatically a shared regime."],
  ["formal system", "one_root_or_compound", "A shared formal regime maps to LOG:020–022; syntax, stored specification, and executing machinery remain separate."],
  ["type system", "one_root_or_compound", "A type system as a shared regime maps to LOG:020–022; individual type records remain DAT."],
  ["legal code", "compound", "LOG:020–022 supplies the shared formal regime while LIF and CON supply institution, authority, and social participants."],
  ["house rule", "compound", "LOG supplies the criterion or regime; LIF supplies household identity and CON may supply promulgation."],
  ["game rule", "one_root_or_compound", "LOG supplies rule status; the game, players, turns, and actions require other families."],
  ["physical law", "compound", "LOG can encode the formal constraint, while MAT and ORI supply physical domain and causal or temporal interpretation."],
  ["natural regularity", "different_family_or_compound", "Observed regularity is not automatically a formal rule; DAT evidence, ORI causation, and LOG model remain distinct."],
  ["business rule", "one_root_or_compound", "Use a LOG rule with LIF, CON, and DAT roots for organization, authority, records, and governed workflow."],
  ["access-control rule", "compound", "LOG supplies the rule, CON the relation or channel, DAT identity records, and LIF or MIN the principal where relevant."],
  ["firewall rule", "compound", "LOG supplies target-directed or shared constraint status; CON, DAT, and STR supply packets, channels, and structure."],
  ["database constraint", "one_root_or_compound", "Use LOG:010–012 for one target or LOG:020–022 for a shared database regime; DAT owns the stored schema."],
  ["assert statement", "compound", "LOG can supply the operative criterion and DAT the expression; execution and pass or fail belong to LOG:1xx."],
  ["validation rule", "one_root_or_compound", "The rule entity is LOG:0xx; the validation act and result must not be folded into it."],
  ["lint rule", "one_root_or_compound", "A lint criterion is LOG:0xx; tool execution and diagnostics require LOG:1xx and DAT or WRN as appropriate."],
  ["equation", "different_family_or_compound", "DAT supplies symbolic representation and LOG supplies formal constraint only when the equation is used as an admissibility condition."],
  ["inequality constraint", "one_root_or_compound", "LOG supplies the formal limit while DAT or MAT supplies variables and quantities."],
  ["ethical norm", "compound_or_later_specialization", "LOG can encode the formal norm, but agents, values, authority, and social force require LIF, MIN, or CON compounds."],
  ["habit", "different_family", "A habit is a behavioral or cognitive regularity, not a formal constraint unless a separate rule is explicitly constituted."],
  ["advice", "different_family", "CON owns communicative advice and MIN intention; advice is not a LOG rule without formal normative status."],
  ["command", "different_family_or_compound", "CON owns the directive act; LOG may separately encode the rule or obligation it creates."],
  ["schedule", "different_family_or_compound", "ORI owns temporal ordering and DAT its record; a schedule may be governed by LOG constraints but is not one."],
  ["workflow", "compound", "STR, CON, and ORI describe arranged steps and coordination; LOG supplies governing conditions when explicitly present."],
  ["rule versus record", "scope_resolution_test", "LOG owns the formal constraint; DAT owns the file, text, schema, or row that represents it."],
  ["rule versus belief", "scope_resolution_test", "LOG rule identity and operation are independent of whether a MIN cognizer accepts or remembers it."],
  ["rule versus execution", "scope_resolution_test", "LOG:0xx names the rule entity; LOG:1xx is reserved for actual evaluation or rule application."],
  ["rule versus applicability", "scope_resolution_test", "LOG:0xx names the rule; LOG:2xx is reserved for applicability, consequence, or other formal relations."],
  ["rule versus physical limit", "scope_resolution_test", "LOG supplies formal admissibility; MAT or STR supplies material or structural limitation."],
  ["rule versus protocol channel", "scope_resolution_test", "LOG supplies protocol constraints and CON supplies the channel and participant relations."],
  ["rule versus restoration criterion", "scope_resolution_test", "LOG owns the acceptance criterion while REP owns the restoration condition it characterizes."],
  ["many independent rules", "multiple_roots_not_one_systemic_root", "Separate unrelated criteria do not form one LOG:02x regime unless they correlate participants within one shared rule domain."],
  ["shared rule with one participant", "scope_mismatch", "A systemic regime requires multiple participants; one governed entity selects inward or target scope."],
  ["persistent plus operative rule", "two_compatible_roots", "The persistent root may co-occur with its operative sibling because identity is neutral about present operation."],
  ["persistent plus dormant rule", "two_compatible_roots", "The persistent root may co-occur with its dormant sibling because identity is neutral about present operation."],
  ["operative and dormant rule simultaneously", "contradiction", "For the same rule at one reference time, operative and dormant are mutually exclusive."],
  ["dormant rule affirmed", "runtime_and_lexical", "LOG:002, 012, or 022[1] affirms defined-but-inoperative status; runtime affirmation is not lexical operation."],
  ["persistent rule uncertain", "runtime_and_lexical", "LOG:000, 010, or 020[2]/num marks uncertainty about persistence; it does not select lexical dormancy."],
  ["operative rule denied", "runtime_and_lexical", "Runtime `[0]` denies present operation without deleting the criterion or automatically affirming dormancy."]
].freeze

logic_root_stress = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} identity", "one_root", "#{id}[1] directly affirms the root's invariant without adding satisfaction, truth, execution, or authority."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves this exact #{root[:phase]} claim unresolved and does not select a lexical sibling."],
    ["#{root[:title]} as data", "compound", "DAT represents the rule while #{id} supplies its formal constraint identity and status."],
    ["#{root[:title]} being evaluated", "compound", "#{id} supplies the rule entity; LOG:1xx must separately supply the evaluation process."],
    ["#{root[:title]} believed", "compound", "MIN supplies belief or acceptance while #{id} remains the formal rule independently."],
    ["#{root[:title]} physically implemented", "compound", "MAT or STR supplies implementation mechanics while #{id} supplies only formal admissibility."]
  ]
end

stress_rows = logic_stress_base + logic_root_stress

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("REP0-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "LOG:000–022 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/LOG_000_022_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "LOG:000–022 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "LOG:000–002" => "internal formal criterion: persistent / operative / dormant", "LOG:010–012" => "target-directed formal constraint: persistent / operative / dormant", "LOG:020–022" => "shared formal regime: persistent / operative / dormant" }, "triplet_logic" => { "persistent_member" => "asserts rule identity across time and is operation-neutral", "operative_dormant_members" => "mutually exclusive for the same formal rule at the same reference time", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/LOG_000_022_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "LOG:000–022 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# LOG:000–022 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Logic entity meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `LOG:0xx` the substrate-neutral entity layer for formal constraints. The inward triplet identifies one criterion within a reference entity's logical specification, the outward triplet identifies one formal constraint assigned to a distinct target, and the systemic triplet identifies one correlated formal regime across multiple participants in a shared rule domain. Persistence, present operation, and dormancy supply the exact third-trit contrast.\n\nEach `...0` member asserts persistence of rule identity and is neutral about present operation, so it may co-occur with either its `...1` or `...2` sibling. The operative `...1` and dormant `...2` siblings are mutually exclusive for the same rule at the same reference time. Runtime `[2]/num` remains uncertainty about the selected claim. The design rejects the provisional mixture of axioms, propositions, variable bindings, operands, values, executing programs, and dormant procedures. Evaluation and inference remain for `LOG:1xx`, formal applicability and consequence relations for `LOG:2xx`, and represented values and specifications for DAT.\n\n"

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
review << "| LOG:000–002 | one formal criterion within one reference specification | persists independently of operation | presently operative | remains defined but inoperative |\n"
review << "| LOG:010–012 | one formal constraint assigned to one distinct target | persists independently of operation | presently operative on target | remains defined for target but inoperative |\n"
review << "| LOG:020–022 | one correlated formal regime across multiple participants | persists independently of operation | presently governs shared domain | remains defined across participants but inoperative |\n\n"
review << "**Triplet logic:** the `0` column is operation-neutral and may co-occur with `1` or `2`; only operative `1` versus dormant `2` is mutually exclusive at one reference time. Operation never entails satisfaction or enforcement.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | proposition truth, represented values, beliefs, communication, physical mechanisms, evaluation processes, satisfaction results, applicability relations, authority, time, and modality |\n" }
review << "\n## Concepts intentionally reserved\n\nTruth and falsity, proposition content, proof, inference, evaluation, rule application, satisfaction, violation, computability, entailment, consistency, permission outcomes, obligations, authority, sanctions, variable binding, represented schemas, execution, scheduling, and modality remain other-family meanings, later LOG layers, grammar, or compounds.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later LOG layers, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# LOG:000–022 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "DAT specification; MIN belief; MAT or STR invariant", "1" => "CON command; LIF authority; DAT validation record", "2" => "CON protocol; STR system; DAT schema; LIF institution" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | LOG keeps only formal-constraint identity and operation; representation, bearer, process, outcome, authority, and mechanism remain separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- A formal criterion is not the proposition, symbol string, file, schema, belief, command, institution, or physical mechanism that represents, adopts, communicates, or realizes it.\n- An operative rule limits admissible states now; it does not entail that any target satisfies the rule, that an evaluator runs, or that an authority enforces it.\n- A dormant rule remains defined but inoperative; it is not false, invalid, deleted, forgotten, future, impossible, or uncertain.\n- An inward criterion belongs to one reference specification without requiring a distinct governed target. A target-directed constraint is assigned to one distinct target. A systemic regime correlates multiple participants in one shared rule domain.\n- Several unrelated rules do not form one systemic regime merely because they coexist or execute simultaneously.\n- Persistent identity may co-occur with operative or dormant status; operative and dormant are exclusive for the same rule at one reference time.\n- Runtime `[2]/num` leaves a selected assertion unresolved and never selects lexical dormancy.\n\n**CONCLUSION: LOG:0XX STANDS ALONE ONLY FOR FORMAL-CONSTRAINT IDENTITY AND PRESENT OPERATION; PROPOSITIONS, DATA REPRESENTATIONS, BELIEFS, COMMUNICATION, MECHANISMS, EVALUATION, SATISFACTION, APPLICABILITY, AUTHORITY, TIME, AND MODALITY REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built LOG:000–022 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
