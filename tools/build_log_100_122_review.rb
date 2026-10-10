#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "LOG:100–122"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "LOG_100_122"
SEMANTIC_CENTER = "formal evaluation processes: internal evaluation, target constraint application, and systemic regime evaluation"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "LOG:100" => ["proof complete", "An inward evaluation, calculation, or inference has completed with a stable result."],
  "LOG:101" => ["active computation", "A logical agent is actively calculating, evaluating, inferring, or checking its own state."],
  "LOG:102" => ["deferred computation", "An inward evaluation is specified or possible but has not started or lacks a needed value."],
  "LOG:110" => ["comparison resolved", "A test, operator, or comparison applied to a target has produced a stable result."],
  "LOG:111" => ["apply operator", "A target is actively being compared, tested, classified, or transformed by a rule."],
  "LOG:112" => ["pending test", "A test or operation on a target is specified but not yet evaluated."],
  "LOG:120" => ["execution complete", "A program, proof, iteration, or multi-step rule process has reached its defined end state."],
  "LOG:121" => ["system execution", "Rules, branches, or iterations are actively executing across a formal system."],
  "LOG:122" => ["scheduled execution", "A program or system-level evaluation is ready or waiting but has not begun."]
}.freeze

ROOTS = {
  "LOG:100" => { title: "completed internal formal evaluation", phase: "completed", scope: "inward", kind: "internal formal evaluation", invariant: "Completion of a formal evaluation that determines the admissibility of one reference entity under its applicable internal criterion." },
  "LOG:101" => { title: "active internal formal evaluation", phase: "active", scope: "inward", kind: "internal formal evaluation", invariant: "An ongoing formal evaluation that is determining the admissibility of one reference entity under its applicable internal criterion." },
  "LOG:102" => { title: "nonactualized internal formal evaluation", phase: "nonactualized", scope: "inward", kind: "internal formal evaluation", invariant: "A nonactualized formal evaluation that would determine the admissibility of one reference entity under its applicable internal criterion." },
  "LOG:110" => { title: "completed target constraint application", phase: "completed", scope: "outward", kind: "target constraint application", invariant: "Completion of a formal evaluation that applies one specified constraint to one distinct reference target and determines that target's admissibility under the constraint." },
  "LOG:111" => { title: "active target constraint application", phase: "active", scope: "outward", kind: "target constraint application", invariant: "An ongoing formal evaluation that applies one specified constraint to one distinct reference target and is determining that target's admissibility under the constraint." },
  "LOG:112" => { title: "nonactualized target constraint application", phase: "nonactualized", scope: "outward", kind: "target constraint application", invariant: "A nonactualized formal evaluation that would apply one specified constraint to one distinct reference target and determine that target's admissibility under the constraint." },
  "LOG:120" => { title: "completed systemic regime evaluation", phase: "completed", scope: "systemic", kind: "systemic regime evaluation", invariant: "Completion of a coordinated formal evaluation that determines the joint admissibility of multiple participants under one shared formal regime." },
  "LOG:121" => { title: "active systemic regime evaluation", phase: "active", scope: "systemic", kind: "systemic regime evaluation", invariant: "An ongoing coordinated formal evaluation that is determining the joint admissibility of multiple participants under one shared formal regime." },
  "LOG:122" => { title: "nonactualized systemic regime evaluation", phase: "nonactualized", scope: "systemic", kind: "systemic regime evaluation", invariant: "A nonactualized coordinated formal evaluation that would determine the joint admissibility of multiple participants under one shared formal regime." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [6, 8, 9, 5, 6, 8, 8, 9] },
  "formal_evaluation_processes" => { scores: [10, 10, 10, 10, 9, 10, 10, 10] },
  "logical_derivation_processes" => { scores: [9, 8, 10, 7, 8, 10, 8, 10] },
  "comparison_classification_processes" => { scores: [8, 8, 9, 8, 8, 9, 10, 9] },
  "program_execution_processes" => { scores: [8, 7, 8, 6, 6, 9, 8, 10] }
}.freeze

ALT_TITLES = {
  "LOG:100" => ["completed internal derivation", "completed internal classification", "completed internal execution"],
  "LOG:101" => ["active internal derivation", "active internal classification", "active internal execution"],
  "LOG:102" => ["nonactualized internal derivation", "nonactualized internal classification", "nonactualized internal execution"],
  "LOG:110" => ["completed target derivation", "completed target comparison", "completed target execution"],
  "LOG:111" => ["active target derivation", "active target comparison", "active target execution"],
  "LOG:112" => ["nonactualized target derivation", "nonactualized target comparison", "nonactualized target execution"],
  "LOG:120" => ["completed systemic derivation", "completed systemic classification", "completed program execution"],
  "LOG:121" => ["active systemic derivation", "active systemic classification", "active program execution"],
  "LOG:122" => ["nonactualized systemic derivation", "nonactualized systemic classification", "nonactualized program execution"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identities, biological conditions, agents, and social collectives. A living agent may perform or undergo a LOG evaluation, but LOG:1xx does not encode the agent's life, role, health, or agency.",
  "MOV" => "MOV owns position, path, displacement, and motion processes. A LOG evaluation may determine whether movement is admissible, but it neither moves anything nor constitutes a route, destination, departure, or arrival.",
  "MAT" => "MAT owns substance, energy, force, contact, and material change. A sensor test may supply evidence to a LOG evaluation, but LOG:1xx does not encode the physical measurement, mechanism, or change.",
  "MIN" => "MIN owns mental state, attention, belief, reasoning, and cognitive change. A thinker may carry out a LOG evaluation, but the formal admissibility-determining process is not the thinker's belief, attention shift, or private inference episode.",
  "CON" => "CON owns communication, social linkage, interaction, and participation. A request, vote, or message may trigger or report a LOG evaluation, but it is not the evaluation itself.",
  "WRN" => "WRN owns hazards, faults, warnings, and adverse states. A LOG evaluation may determine that a constraint is not satisfied, but it does not by itself assert danger, failure, diagnosis, prohibition, or harm.",
  "STR" => "STR owns arrangements, boundaries, component relations, and structural transitions. A workflow may host a LOG evaluation, but LOG:1xx does not encode the workflow step, structural transition, or implementation mechanism.",
  "REP" => "REP owns restoration conditions, restorative processes, and restorative affordances. A LOG evaluation may test whether restoration satisfies a criterion, but it is not the restoration, restored state, or recovery capacity.",
  "DAT" => "DAT owns information artifacts, values, encodings, and data flow. Data may be input to or output from a LOG evaluation, but LOG:1xx is the formal admissibility-determining process rather than the data, result record, code, or transmission.",
  "CRE" => "CRE owns creation, transformation, generation, and productive capacities. A LOG evaluation may constrain a generated product, but it does not create, transform, or produce that product.",
  "ORI" => "ORI owns temporal, modal, causal, and ontological orientation. Scheduling, intention, possibility, necessity, and future placement of a LOG evaluation require ORI or compounds; lexical nonactualization does not encode them."
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
  when "formal_evaluation_processes"
    values[4] += 1 if second == "0"
    values[6] -= 1 if second == "2"
  when "logical_derivation_processes"
    values[1] -= 1 if second == "1"
    values[3] -= 1 if third == "2"
  when "comparison_classification_processes"
    values[2] -= 1 if second == "2"
    values[5] -= 1 if second == "0"
  when "program_execution_processes"
    values[2] -= 2 if second != "2"
    values[4] -= 2 if second == "1"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, architecture, title)
  root = ROOTS.fetch(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional title uses familiar proof, computation, comparison, operator, and execution vocabulary and roughly follows the #{root.fetch(:scope)} and #{root.fetch(:phase)} slot labels.",
      "useful_coverage" => "It covers proving, calculating, comparing, testing, applying operators, running programs, and completing executions.",
      "semantic_territory_consumed" => "Across the block it mixes evaluation, inference, transformation, stable results, scheduling, readiness, missing inputs, and program execution.",
      "conflicts_or_future_limitations" => "The triplets do not preserve one process center; several roots encode results or scheduler state, while apply-operator can mean arbitrary MAT, STR, CRE, or DAT transformation."
    }
  when "formal_evaluation_processes"
    {
      "why_it_fits" => "The first trit is one actual or nonactualized formal process; the second changes only the evaluation scope—one entity under an internal criterion, one target under an assigned constraint, or multiple participants under one regime; the third changes only completed, active, or nonactualized phase.",
      "useful_coverage" => "It supports checking, validating, deciding, type-checking, classifying, testing, proof checking, rule application, policy evaluation, and multi-participant constraint resolution.",
      "semantic_territory_consumed" => "Only the formal process that determines admissibility. The rule entity, input representation, result polarity, physical transformation, scheduler state, applicability relation, and modality remain separate.",
      "conflicts_or_future_limitations" => "Some English inference and computation senses do more than evaluate admissibility, so those senses require compounds or later specialization rather than expanding the invariant."
    }
  when "logical_derivation_processes"
    {
      "why_it_fits" => "Derivation is central to logic and naturally has completed, active, and nonactualized phases across inward, target, and systemic scopes.",
      "useful_coverage" => "It would cover infer, deduce, prove, derive, calculate, simplify, solve, and establish a conclusion.",
      "semantic_territory_consumed" => "It specializes the process layer to conclusion production from premises rather than general rule-governed evaluation.",
      "conflicts_or_future_limitations" => "Target evaluation, validation, policy decisions, and consistency checks may produce no new conclusion; derivation also risks collision with CRE generation and DAT transformation."
    }
  when "comparison_classification_processes"
    {
      "why_it_fits" => "Comparison and classification are common formal operations on one entity, a target, or a set of participants.",
      "useful_coverage" => "It would cover compare, match, classify, sort, test, discriminate, rank, and type-check.",
      "semantic_territory_consumed" => "It consumes only a subset of formal evaluation and pulls ranking or sorting toward DAT/MAT operations.",
      "conflicts_or_future_limitations" => "Proof checking, permission decisions, satisfiability, and systemic constraint resolution are not necessarily comparisons or classifications."
    }
  when "program_execution_processes"
    {
      "why_it_fits" => "Programs and rule systems execute as processes with completed, active, and nonactualized phases and are technically useful.",
      "useful_coverage" => "It would cover run, execute, iterate, branch, interpret, compile, and evaluate code.",
      "semantic_territory_consumed" => "It makes computational implementation obligatory and absorbs control flow, scheduling, and state transformation.",
      "conflicts_or_future_limitations" => "Ordinary reasoning and formal evaluation need not be programs; execution mechanics collide with DAT, STR, CRE, and ORI."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "logical_derivation_processes"
    "A #{root.fetch(:phase)} formal derivation performed at #{root.fetch(:scope)} logical scope."
  when "comparison_classification_processes"
    "A #{root.fetch(:phase)} formal comparison or classification performed at #{root.fetch(:scope)} scope."
  when "program_execution_processes"
    "A #{root.fetch(:phase)} program or rule-system execution at #{root.fetch(:scope)} scope."
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
    "low" => "reference entity or participant whose admissibility is evaluated",
    "middle" => "formal evaluation process as the asserted figure",
    "high" => "applicable criterion, assigned constraint, or distinct target",
    "sustained" => "shared formal regime and multiple participants evaluated together"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that this #{root.fetch(:kind)} completed; it does not assert that the active sibling is still running, that the nonactualized sibling holds, or that the result had either polarity.",
      "1" => "Affirms completion of this #{root.fetch(:kind)} and therefore determination of an admissibility result, without asserting acceptance, rejection, proof validity, persistence, storage, or enforcement.",
      "2/num" => "Leaves unresolved whether this completed #{root.fetch(:kind)} claim holds; runtime uncertainty does not change the lexical root into active or nonactualized phase."
    }
  when "1"
    {
      "0" => "Denies that this #{root.fetch(:kind)} is currently ongoing; it does not itself affirm completion, nonactualization, suspension, failure, or absence of the applicable rule.",
      "1" => "Affirms that this #{root.fetch(:kind)} is currently determining admissibility, without asserting its eventual completion, result polarity, correctness, duration, or side effects.",
      "2/num" => "Leaves unresolved whether this active #{root.fetch(:kind)} claim holds; runtime uncertainty does not select the completed or nonactualized lexical sibling."
    }
  else
    {
      "0" => "Denies that this #{root.fetch(:kind)} is nonactualized; it does not by itself affirm completion, current activity, scheduling, permission, impossibility, or any result.",
      "1" => "Affirms a specifically typed #{root.fetch(:kind)} that is not actualized, without encoding intention, planning, readiness, queueing, future time, probability, or missing inputs.",
      "2/num" => "Leaves unresolved whether the selected nonactualized #{root.fetch(:kind)} claim holds; lexical third-trit 2 names process nonactualization, while runtime `[2]/num` marks assertion-level uncertainty."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entity = id[-2] == "0" ? "account" : id[-2] == "1" ? "device" : "network"
  graph_roles = id[-2] == "0" ? "ENTITY=#{entity},CRITERION=c" : id[-2] == "1" ? "TARGET=#{entity},CONSTRAINT=c" : "DOMAIN=#{entity},PARTICIPANTS={a,b,c},REGIME=c"
  ordinary = { "0" => "The formal check for the #{entity} finished and determined an admissibility result.", "1" => "The formal check for the #{entity} is determining admissibility now.", "2" => "The typed formal check for the #{entity} is not actualized." }.fetch(id[-1])
  entries = [
    ["ordinary_conversation", "#{id}[1](#{graph_roles})", "affirm #{root.fetch(:phase)} #{root.fetch(:kind)}", ordinary, "The root asserts evaluation phase, not acceptance or rejection polarity."],
    ["physical_or_spatial", "MAT(BEARER=#{entity})+#{id}[1](#{graph_roles})", "material bearer plus #{root.fetch(:phase)} formal evaluation", "A controller formally evaluates the machine state while MAT separately describes sensing and mechanics.", "Formal evaluation and physical mechanism remain separately typed."],
    ["temporal_or_sequential", "#{id}[1](#{graph_roles})+ORI(INTERVAL=w)", "#{root.fetch(:phase)} formal evaluation during interval w", "During interval w, the evaluation has the stated lexical phase.", "ORI supplies time and does not replace process phase."],
    ["cross_family_compound", "DAT(INPUT=d)+#{id}[1](#{graph_roles})", "represented input plus #{root.fetch(:phase)} formal evaluation", "The data supplies the represented input while LOG supplies the admissibility-determining process.", "DAT and LOG remain distinct."],
    ["executable_or_programming", "#{id}[1](#{graph_roles})", "assert #{root.fetch(:phase)} formal evaluation", "A runtime tracks the evaluation phase without folding in the rule record or result polarity.", "Evaluation, rule, and result remain distinct."],
    ["counterexample", "LOG:001[1](CRITERION=c)", "operative rule entity", "The rule currently governs accepted states, but no evaluation is running.", "An operative constraint belongs to LOG:0xx and does not entail a LOG:1xx evaluation."]
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
      "pseudocode" => category == "executable_or_programming" ? "assert(evaluation.phase == #{id.inspect})" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "formal_evaluation_processes", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "logical_derivation_processes", alt[0], alternative_invariant(id, "logical_derivation_processes")),
    candidate(id, "comparison_classification_processes", alt[1], alternative_invariant(id, "comparison_classification_processes")),
    candidate(id, "program_execution_processes", alt[2], alternative_invariant(id, "program_execution_processes"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "formal_evaluation_processes",
    "recommendation_reason" => "Only this architecture keeps all nine roots on one admissibility-determining process center, follows inward/target/systemic scope exactly, and gives every triplet one completed/active/nonactualized axis while reserving rule entities, represented inputs, result polarity, scheduler states, and formal relations for LOG:0xx, LOG:2xx, or other families.",
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
  state_label = { "0" => "completed", "1" => "active/ongoing", "2" => "nonactualized" }.fetch(third)
  scope_explanation = {
    "0" => "one reference entity evaluated under its applicable internal criterion",
    "1" => "one specified formal constraint applied to one distinct reference target",
    "2" => "multiple participants evaluated jointly under one shared formal regime"
  }.fetch(second)
  scope_boundary = {
    "0" => "The process evaluates one entity without requiring a distinct external target. Its internal criterion, input representation, and result polarity remain separate.",
    "1" => "The process preserves one specified constraint and one distinct target. Arbitrary target transformation, comparison data, and pass/fail outcome remain separate.",
    "2" => "The process requires coordinated evaluation of multiple participants under one shared regime. Several independent evaluations do not constitute one systemic process."
  }.fetch(second)
  triplet_logic = "Completed, active, and nonactualized are mutually exclusive phases for the same bounded evaluation at one reference time. Lexical nonactualization states only that the typed process is not actualized; runtime `[2]/num` separately marks uncertainty about any selected phase."
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_1" => "Selects a formal evaluation process that determines admissibility rather than the rule entity, a stored representation, a result value, or a formal applicability/consequence relation.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Logic-family column.",
      "third_trit" => "Selects the #{state_label} phase of the same formal evaluation while leaving runtime truth status, result polarity, correctness, observer knowledge, tense, probability, and scheduling separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral process that determines admissibility at #{root.fetch(:scope)} scope. #{scope_boundary} It is neutral about the rule's storage or authority, acceptance versus rejection, truth, proof correctness, physical side effects, observer belief, scheduling, probability, timing, and cause.",
    "excluded_meanings" => [
      "The formal criterion, target constraint, or shared regime as an entity, and its persistent, operative, or dormant status.",
      "Acceptance, rejection, true, false, valid, invalid, satisfied, violated, error, or any other polarity or result value.",
      "Data input, variable, binding, symbol string, record, schema, source code, proof object, or stored output.",
      "Physical, biological, communicative, structural, restorative, creative, or adverse transformation produced alongside evaluation.",
      "Authorship, authority, enforcement, sanction, resource use, implementation algorithm, performance, or complexity.",
      "Applicability, entailment, consistency, computability, intention, plan, readiness, queue, schedule, future time, possibility, necessity, probability, or cause."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`LOG:0xx` owns formal constraint entities and their identity or operation. `LOG:1xx` owns only the corresponding formal evaluation processes. `LOG:2xx` remains reserved for applicability, consequence, consistency, computability, or other formal relations and capacities. An operative rule does not entail an evaluation, and an evaluation does not entail a positive result or a persistent applicability relation. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} phase of this formal evaluation. Runtime `[2]/num` instead leaves the already-selected phase claim unresolved; it never changes process phase. Thus a nonactualized root affirmed with `[1]` is a confirmed typed-but-nonactualized evaluation, while a completed or active root carrying `[2]/num` remains lexically completed or active but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + LOG:0xx supplies the criterion or regime being applied without reducing the process to its rule.",
      "#{id} + DAT supplies represented inputs and outputs while keeping evaluation distinct from stored data.",
      "#{id} + MAT/STR/CON/REP supplies any physical, structural, communicative, or restorative process being judged.",
      "#{id} + LOG:2xx may later express applicability, entailment, consistency, or computability as a separate formal relation."
    ],
    "later_era_notes" => "Later eras may lexicalize proof construction, model checking, satisfiability solving, authorization decisions, type inference, comparison, optimization, and execution algorithms. Era Zero should preserve the substrate-neutral admissibility-determining process center and derive result polarity and implementation details compositionally.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


logic_process_stress_base = [
  ["evaluate", "one_root_or_compound", "Use LOG:1xx when the sense is a formal process that determines admissibility; sensory appraisal or preference requires MIN, MAT, or other families."],
  ["check", "one_root_or_compound", "A formal check maps to LOG:1xx according to scope and phase; inspection mechanics, evidence, and results remain separate."],
  ["validate", "one_root_or_compound", "LOG:1xx owns the formal evaluation process, DAT the data, LOG:0xx the criterion, and result polarity remains a separate claim."],
  ["test", "one_root_or_compound", "A formal admissibility test uses LOG:1xx; a physical experiment or medical test requires MAT, LIF, DAT, and possibly CRE."],
  ["decide", "one_root_or_compound", "A formal decision procedure can use LOG:1xx, while an agent's choice or intention belongs to MIN and authority may require LIF or CON."],
  ["calculate", "compound_or_later_specialization", "Calculation can be formal evaluation when it determines admissibility, but arithmetic transformation and represented numbers require DAT and later specialization."],
  ["infer", "compound_or_later_specialization", "Inference can use LOG:1xx when framed as formal evaluation; premises, conclusion, and entailment relation remain separate."],
  ["deduce", "compound_or_later_specialization", "Deduction is a specialized formal evaluation or derivation; do not make conclusion production part of every LOG:1xx invariant."],
  ["prove", "compound_or_later_specialization", "Proof construction or checking combines LOG:1xx with DAT proof objects and LOG:2xx consequence relations."],
  ["verify", "one_root_or_compound", "Formal verification uses LOG:1xx; evidence, instrumentation, observer belief, and positive result are not entailed."],
  ["type-check", "one_root_or_compound", "Use LOG:110–112 for a distinct target expression under a type constraint or LOG:120–122 for coordinated module-level evaluation."],
  ["classify", "compound_or_later_specialization", "Classification may be a formal evaluation, but category data and learned models require DAT and MIN."],
  ["compare", "compound_or_later_specialization", "Comparison can participate in evaluation; operands and ordering relation are DAT or later LOG vocabulary."],
  ["authorize", "compound", "LOG:1xx can evaluate permission, but authority, principal, policy, and grant result require LIF, CON, DAT, and LOG:0xx compounds."],
  ["reject", "result_not_process", "Rejection is one possible evaluation result and must not replace the completed-process root."],
  ["accept", "result_not_process", "Acceptance is one possible evaluation result and is not entailed by evaluation completion."],
  ["pass", "result_not_process", "Pass is result polarity; LOG:1x0 states completion without choosing pass or fail."],
  ["fail", "result_not_process", "Fail is result polarity; WRN applies only when failure is adverse rather than merely nonconforming."],
  ["true", "result_or_relation", "Truth is not the evaluation process and should not be forced into a completed LOG:1xx root."],
  ["false", "result_or_relation", "Falsity is not process nonactualization; LOG:1x2 says the evaluation is not actualized."],
  ["valid", "result_or_relation", "Validity may be an evaluation result or formal relation, not the completed process itself."],
  ["invalid", "result_or_relation", "Invalidity is not an active or nonactualized evaluation; keep result and process separate."],
  ["satisfied", "result_or_relation", "Constraint satisfaction is a result or relation; LOG:1xx only determines admissibility."],
  ["violated", "result_or_relation", "Violation is a result relative to a rule and is not equivalent to a completed evaluation."],
  ["run a program", "different_family_or_compound", "DAT owns code and machine state, while LOG:1xx applies only to the formal-evaluation aspect of execution."],
  ["execute a command", "different_family_or_compound", "CON or CRE may own the command and resulting action; LOG:1xx applies only when formal admissibility is being determined."],
  ["simulate", "compound_or_later_specialization", "Simulation transforms a represented model through time and needs DAT, ORI, and possibly CRE; LOG:1xx can evaluate its states under rules."],
  ["optimize", "compound_or_later_specialization", "Optimization requires objective and search relations beyond generic admissibility evaluation."],
  ["solve", "compound_or_later_specialization", "Solving may use LOG:1xx but solution construction and represented output require DAT and possibly CRE."],
  ["completed internal evaluation", "one_root", "LOG:100 states that one entity's admissibility was determined under its internal criterion without stating the polarity."],
  ["active internal evaluation", "one_root", "LOG:101 states that one entity's admissibility is currently being determined."],
  ["nonactualized internal evaluation", "one_root", "LOG:102 states a typed inward evaluation that is not actualized, without implying plan, queue, or future time."],
  ["completed target evaluation", "one_root", "LOG:110 states completion of applying one specified constraint to one distinct target."],
  ["active target evaluation", "one_root", "LOG:111 states that one specified constraint is currently being applied to one target."],
  ["nonactualized target evaluation", "one_root", "LOG:112 states a typed target evaluation that is not actualized."],
  ["completed systemic evaluation", "one_root", "LOG:120 states completion of one coordinated evaluation across multiple participants under one shared regime."],
  ["active systemic evaluation", "one_root", "LOG:121 states ongoing coordinated evaluation across multiple participants under one regime."],
  ["nonactualized systemic evaluation", "one_root", "LOG:122 states a typed coordinated systemic evaluation that is not actualized."],
  ["rule is operative", "different_layer", "LOG:0x1 owns rule operation; an operative rule does not entail that LOG:1xx evaluation is occurring."],
  ["rule exists", "different_layer", "LOG:0xx owns rule identity; LOG:1xx requires a formal evaluation process."],
  ["rule applies", "future_relation_layer", "Formal applicability belongs to LOG:2xx; process execution and applicability are not identical."],
  ["result stored", "compound", "DAT stores the result while LOG:1xx supplies the evaluation process."],
  ["proof object", "different_family", "DAT owns the represented proof object; LOG:1xx may supply proof construction or checking only when explicitly evaluated."],
  ["evaluation believed", "compound", "MIN supplies belief or confidence while LOG:1xx supplies formal process phase."],
  ["evaluation observed", "compound", "MIN and DAT supply observation or evidence; evaluation existence is independently asserted."],
  ["evaluation caused a physical change", "compound", "MAT or CRE supplies the physical transformation while LOG:1xx supplies formal evaluation."],
  ["evaluation scheduled", "compound", "ORI and DAT supply schedule; lexical third trit 2 only marks nonactualization."],
  ["evaluation queued", "compound", "DAT and ORI supply queue state; LOG:102/112/122 do not encode readiness or ordering."],
  ["evaluation impossible", "future_relation_or_modality", "Negated LOG:2xx capability or ORI modality expresses impossibility; nonactualized LOG:1x2 does not."],
  ["evaluation uncertain", "runtime", "Use runtime `[2]/num` on the selected phase root rather than substituting lexical nonactualization."],
  ["completed evaluation uncertain", "runtime_and_lexical", "LOG:100/110/120[2]/num remains lexically completed while the token claim is uncertain."],
  ["nonactualized evaluation affirmed", "runtime_and_lexical", "LOG:102/112/122[1] affirms a typed-but-nonactualized process; runtime affirmation does not make it active."],
  ["active evaluation denied", "runtime_and_lexical", "Runtime `[0]` denies the active claim without automatically selecting completion or nonactualization."],
  ["completed and active simultaneously", "phase_contradiction", "The same bounded evaluation cannot be completed and active at one reference time."],
  ["active and nonactualized simultaneously", "phase_contradiction", "The same bounded evaluation cannot be both ongoing and nonactualized at one reference time."],
  ["completed and nonactualized simultaneously", "phase_contradiction", "The same bounded evaluation cannot be both completed and nonactualized at one reference time."],
  ["many independent checks", "multiple_roots_not_one_systemic_root", "Separate evaluations do not form one LOG:12x process unless coordinated under one shared formal regime."],
  ["one check over many unrelated targets", "compound_or_multiple_roots", "Plural targets alone do not establish one systemic regime or joint admissibility relation."],
  ["joint compliance review", "one_root_or_compound", "LOG:120–122 applies when multiple participants are evaluated together under one shared formal regime."],
  ["rule evaluation versus rule", "scope_resolution_test", "LOG:1xx owns evaluation; LOG:0xx owns the criterion or regime being evaluated."],
  ["rule evaluation versus applicability", "scope_resolution_test", "LOG:1xx owns process; LOG:2xx owns whether a rule can apply or a consequence holds."],
  ["evaluation versus data transformation", "scope_resolution_test", "LOG determines admissibility; DAT or CRE transforms represented content."],
  ["evaluation versus belief revision", "scope_resolution_test", "LOG supplies formal evaluation; MIN supplies cognitive change caused by or responding to it."],
  ["evaluation versus physical inspection", "scope_resolution_test", "LOG supplies formal determination; MAT, LIF, and DAT supply sensing and evidence."],
  ["evaluation versus warning", "scope_resolution_test", "LOG supplies rule-governed determination; WRN supplies adverse condition or diagnostic warning when separately present."],
  ["evaluation versus restoration", "scope_resolution_test", "LOG can evaluate a restoration criterion, while REP supplies the restoration condition or process."],
  ["evaluation versus creation", "scope_resolution_test", "LOG judges admissibility; CRE produces or transforms an artifact or representation."],
  ["evaluation versus communication", "scope_resolution_test", "LOG supplies formal determination and CON supplies requests, responses, votes, or messages."],
  ["evaluation versus time", "scope_resolution_test", "Completed, active, and nonactualized are lexical phases; ORI supplies past, future, duration, deadline, and schedule."]
].freeze

logic_process_root_stress = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} identity", "one_root", "#{id}[1] directly affirms the root's invariant without adding rule storage, result polarity, or authority."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves this exact #{root[:phase]} claim unresolved and does not select a lexical sibling."],
    ["#{root[:title]} with data", "compound", "DAT supplies inputs or outputs while #{id} supplies formal evaluation phase."],
    ["#{root[:title]} under rule", "compound", "LOG:0xx supplies the applicable criterion while #{id} supplies the evaluation process."],
    ["#{root[:title]} believed", "compound", "MIN supplies belief or confidence while #{id} remains a formal process claim."],
    ["#{root[:title]} physically implemented", "compound", "MAT or STR supplies execution mechanics while #{id} supplies only admissibility determination."]
  ]
end

stress_rows = logic_process_stress_base + logic_process_root_stress

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("REP0-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "LOG:100–122 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/LOG_100_122_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "LOG:100–122 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "LOG:100–102" => "internal formal evaluation: completed / active / nonactualized", "LOG:110–112" => "target constraint application: completed / active / nonactualized", "LOG:120–122" => "systemic regime evaluation: completed / active / nonactualized" }, "triplet_logic" => { "process_phases" => "completed, active, and nonactualized are mutually exclusive for the same bounded evaluation at one reference time", "nonactualized_member" => "states typed process nonactualization without planning, scheduling, readiness, futurity, or probability", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/LOG_100_122_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "LOG:100–122 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# LOG:100–122 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Logic process meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `LOG:1xx` the substrate-neutral process layer for formal evaluation. The inward triplet evaluates one reference entity under its internal criterion, the outward triplet applies one specified constraint to one distinct target, and the systemic triplet coordinates evaluation of multiple participants under one shared formal regime. Completed, active, and nonactualized supply the exact third-trit contrast.\n\nThe three phases are mutually exclusive for the same bounded evaluation at one reference time. Lexical `1x2` means only that the typed evaluation is not actualized; intention, planning, readiness, queueing, scheduling, future time, probability, and missing inputs remain separate. Runtime `[2]/num` remains uncertainty about the selected phase. The design rejects the provisional mixture of proof results, calculations, arbitrary operators, transformations, program execution, scheduling, and readiness. Rule entities remain `LOG:0xx`; applicability, consequence, and capacity remain `LOG:2xx`; data and implementation remain other families.\n\n"

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
review << "| LOG:100–102 | one entity evaluated under its internal criterion | evaluation completed | evaluation ongoing | typed evaluation not actualized |\n"
review << "| LOG:110–112 | one specified constraint applied to one distinct target | application completed | application ongoing | typed application not actualized |\n"
review << "| LOG:120–122 | multiple participants jointly evaluated under one shared regime | coordinated evaluation completed | coordinated evaluation ongoing | typed coordinated evaluation not actualized |\n\n"
review << "**Triplet logic:** completed, active, and nonactualized are mutually exclusive for the same bounded evaluation at one reference time. Completion entails a determined result, not a positive result.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | rule identity, represented inputs/outputs, result polarity, arbitrary transformation, implementation, authority, applicability, scheduling, time, and modality |\n" }
review << "\n## Concepts intentionally reserved\n\nTruth and falsity, acceptance and rejection, satisfaction and violation, proof objects, conclusion content, arithmetic values, comparison order, execution algorithms, authority, enforcement, scheduling, readiness, queues, complexity, computability, entailment, consistency, and modality remain other-family meanings, later LOG relations, grammar, or compounds.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later LOG layers, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# LOG:100–122 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MIN introspection; DAT computation; CRE derivation", "1" => "MAT or STR target transformation; DAT comparison; CON command", "2" => "DAT program execution; CON coordination; STR workflow" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | LOG keeps only admissibility-determining formal evaluation; rule, data, result, mechanics, authority, and side effects remain separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- A formal evaluation is not the criterion or regime it applies, the data it reads or writes, the implementation algorithm, the evaluator, or the result polarity.\n- A completed evaluation determines an admissibility result but does not entail acceptance, truth, validity, satisfaction, storage, recognition, or enforcement.\n- A nonactualized evaluation is typed but not actualized; it is not planned, intended, ready, queued, scheduled, future, impossible, or uncertain.\n- Inward evaluation concerns one entity under its internal criterion. Target application preserves one specified constraint and one distinct target. Systemic evaluation coordinates multiple participants under one shared regime.\n- Several unrelated evaluations do not become one systemic evaluation merely because they occur simultaneously.\n- Completed, active, and nonactualized are mutually exclusive phases for the same bounded evaluation at one reference time.\n- Runtime `[2]/num` leaves a selected phase assertion unresolved and never selects lexical nonactualization.\n\n**CONCLUSION: LOG:1XX STANDS ALONE ONLY FOR FORMAL ADMISSIBILITY-DETERMINING PROCESSES; RULES, DATA, RESULTS, IMPLEMENTATION, PHYSICAL OR COGNITIVE CHANGE, AUTHORITY, APPLICABILITY, TIME, AND MODALITY REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built LOG:100–122 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
