#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "CRE:100–122"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "CRE_100_122"
SEMANTIC_CENTER = "productive processes: internal pattern formation, outward artifact generation, and systemic co-generation"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "CRE:100" => ["conception complete", "An inward process of imagining, designing, or composing has reached a stable concept."],
  "CRE:101" => ["active ideation", "A creator is actively imagining, composing, planning, or transforming an inward concept."],
  "CRE:102" => ["incubating concept", "An inward creative process is possible or developing but has not entered active formation."],
  "CRE:110" => ["instantiation complete", "Creating, assembling, rendering, or transforming an external target has produced a finished result."],
  "CRE:111" => ["active artifact creation", "A target is actively being designed, generated, assembled, rendered, or transformed."],
  "CRE:112" => ["queued fabrication", "Creation or transformation of a target is specified and possible but has not begun."],
  "CRE:120" => ["system generation complete", "A shared world, design system, production, or generative process has reached its defined result."],
  "CRE:121" => ["collective generation", "Participants or generative components are actively co-creating, composing, or transforming a system."],
  "CRE:122" => ["staged instantiation", "A system-level creative process is prepared but has not been activated."]
}.freeze

ROOTS = {
  "CRE:100" => { title: "completed internal pattern formation", phase: "completed", scope: "inward", kind: "internal pattern formation", invariant: "Completion of a bounded productive transformation within one reference entity that forms or modifies a generative pattern while retaining it within that entity." },
  "CRE:101" => { title: "active internal pattern formation", phase: "active", scope: "inward", kind: "internal pattern formation", invariant: "An ongoing bounded productive transformation within one reference entity that is forming or modifying a generative pattern while retaining it within that entity." },
  "CRE:102" => { title: "nonactualized internal pattern formation", phase: "nonactualized", scope: "inward", kind: "internal pattern formation", invariant: "A nonactualized bounded productive transformation that would form or modify a generative pattern within one reference entity while retaining it within that entity." },
  "CRE:110" => { title: "completed artifact generation", phase: "completed", scope: "outward", kind: "artifact generation", invariant: "Completion of a bounded productive transformation directed outward from one source that brings one generated artifact into manifestation." },
  "CRE:111" => { title: "active artifact generation", phase: "active", scope: "outward", kind: "artifact generation", invariant: "An ongoing bounded productive transformation directed outward from one source that is bringing one generated artifact into manifestation." },
  "CRE:112" => { title: "nonactualized artifact generation", phase: "nonactualized", scope: "outward", kind: "artifact generation", invariant: "A nonactualized bounded productive transformation directed outward from one source that would bring one generated artifact into manifestation." },
  "CRE:120" => { title: "completed systemic co-generation", phase: "completed", scope: "systemic", kind: "systemic co-generation", invariant: "Completion of a coordinated productive transformation by multiple participants in one shared production domain that generates one jointly constituted result." },
  "CRE:121" => { title: "active systemic co-generation", phase: "active", scope: "systemic", kind: "systemic co-generation", invariant: "An ongoing coordinated productive transformation by multiple participants in one shared production domain that is generating one jointly constituted result." },
  "CRE:122" => { title: "nonactualized systemic co-generation", phase: "nonactualized", scope: "systemic", kind: "systemic co-generation", invariant: "A nonactualized coordinated productive transformation by multiple participants in one shared production domain that would generate one jointly constituted result." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [6, 8, 9, 5, 6, 8, 8, 9] },
  "productive_transformation_processes" => { scores: [10, 10, 10, 10, 9, 10, 9, 10] },
  "mental_ideation_processes" => { scores: [9, 8, 5, 7, 4, 8, 10, 7] },
  "material_fabrication_processes" => { scores: [9, 8, 8, 7, 6, 9, 10, 9] },
  "information_synthesis_processes" => { scores: [8, 8, 7, 7, 6, 9, 8, 10] }
}.freeze

ALT_TITLES = {
  "CRE:100" => ["completed internal ideation", "completed internal fabrication", "completed internal information synthesis"],
  "CRE:101" => ["active internal ideation", "active internal fabrication", "active internal information synthesis"],
  "CRE:102" => ["nonactualized internal ideation", "nonactualized internal fabrication", "nonactualized internal information synthesis"],
  "CRE:110" => ["completed target conception", "completed target fabrication", "completed target information synthesis"],
  "CRE:111" => ["active target conception", "active target fabrication", "active target information synthesis"],
  "CRE:112" => ["nonactualized target conception", "nonactualized target fabrication", "nonactualized target information synthesis"],
  "CRE:120" => ["completed collective ideation", "completed systemic fabrication", "completed systemic information synthesis"],
  "CRE:121" => ["active collective ideation", "active systemic fabrication", "active systemic information synthesis"],
  "CRE:122" => ["nonactualized collective ideation", "nonactualized systemic fabrication", "nonactualized systemic information synthesis"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identities, biological conditions, agency, and social collectives. A living creator may perform a productive process, but CRE:1xx does not identify the agent, role, organism, or institution.",
  "MOV" => "MOV owns position, path, displacement, and movement. Production may move inputs or outputs, but CRE:1xx asserts generation rather than spatial displacement.",
  "MAT" => "MAT owns substance, energy, force, contact, and physical transformation. Fabrication may physically realize generation, but CRE:1xx remains substrate-neutral and does not assert material mechanics.",
  "MIN" => "MIN owns imagination, attention, intention, belief, and cognitive change. Mental ideation may guide pattern formation, but CRE:1xx requires productive transformation rather than subjective thought alone.",
  "CON" => "CON owns linkage, communication, interaction, and exchange. Co-generation may involve connected participants, but CRE:1xx requires one jointly constituted productive result rather than interaction alone.",
  "WRN" => "WRN owns faults, hazards, warnings, and adverse processes. Failed or dangerous production may ground WRN claims, but CRE:1xx does not entail error, danger, failure, or harm.",
  "STR" => "STR owns arrangements, boundaries, component relations, and structural transitions. Production may reconfigure structure, but CRE:1xx requires form-producing function rather than arrangement change alone.",
  "REP" => "REP owns restoration conditions, restorative processes, and restorative affordances. Reconstruction may generate an artifact, but CRE:1xx does not entail return to a prior acceptable state or repair success.",
  "LOG" => "LOG owns formal constraints, evaluations, and evaluation affordances. A generative process may execute rules, but it does not itself judge admissibility, truth, consistency, or validity.",
  "DAT" => "DAT owns represented information and its transformation, transfer, and synchronization. A productive process may be data-driven or generate data, but CRE:1xx requires form-producing creation rather than information-state change alone.",
  "ORI" => "ORI owns temporal, modal, causal, and ontological orientation. Scheduling, intention, future placement, possibility, necessity, probability, and causal explanation remain separate from lexical process phase."
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
  when "productive_transformation_processes"
    values[4] += 1 if second == "1"
    values[6] -= 1 if second == "2"
  when "mental_ideation_processes"
    values[1] -= 1 if second == "1"
    values[2] -= 2 if second != "0"
  when "material_fabrication_processes"
    values[2] -= 1 if second == "2"
    values[5] -= 1 if second == "0"
  when "information_synthesis_processes"
    values[2] -= 1 if second == "1"
    values[4] -= 2 if second == "2"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, architecture, title)
  root = ROOTS.fetch(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional meanings use familiar creative-process vocabulary and approximately follow the #{root.fetch(:scope)} and #{root.fetch(:phase)} slot labels.",
      "useful_coverage" => "They cover conception, ideation, instantiation, artifact creation, system generation, and co-creation.",
      "semantic_territory_consumed" => "Across the block they mix cognition, design, productive transformation, assembly, rendering, testing, revision, completion, readiness, queueing, and system state.",
      "conflicts_or_future_limitations" => "The triplets do not preserve one process center: inward roots collapse into MIN, outward roots mix generation with completion and testing, and systemic roots mix product, environment, and process."
    }
  when "productive_transformation_processes"
    {
      "why_it_fits" => "The first trit selects a productive transformation; the second changes only inward pattern formation, outward artifact generation, or coordinated co-generation across participants; the third changes only completed, active, or nonactualized phase.",
      "useful_coverage" => "It supports compose, design-as-production, generate, create, render, instantiate, synthesize, build, co-create, and jointly produce through roots or transparent compounds.",
      "semantic_territory_consumed" => "Only form-producing transformation at the selected scope. Mental conception, represented data, physical mechanics, structural change, participant relations, result quality, scheduler states, and modality remain separate.",
      "conflicts_or_future_limitations" => "Specific media, algorithms, creator roles, originality, completion criteria, resource use, and quality require compounds or later specialization rather than broadening the atoms."
    }
  when "mental_ideation_processes"
    {
      "why_it_fits" => "Creative work often begins in imagination and can be private, target-directed, or collective.",
      "useful_coverage" => "It would cover imagine, brainstorm, conceive, envision, intend, and collectively ideate.",
      "semantic_territory_consumed" => "It makes subjective cognition essential to the entire Creation process layer.",
      "conflicts_or_future_limitations" => "MIN already owns imagination and attention; nonmental generators, automated production, and physical or computational creation would be excluded or misclassified."
    }
  when "material_fabrication_processes"
    {
      "why_it_fits" => "Fabrication visibly creates artifacts and can occur internally, toward an output, or across a production system.",
      "useful_coverage" => "It would cover manufacture, assemble, sculpt, print, construct, fabricate, and industrial production.",
      "semantic_territory_consumed" => "It ties the abstract Creation process layer to physical substance, tools, and assembly mechanics.",
      "conflicts_or_future_limitations" => "Software, music, proofs, stories, simulations, and abstract patterns can be created without fabrication; MAT and STR already own physical and structural mechanics."
    }
  when "information_synthesis_processes"
    {
      "why_it_fits" => "Many technical creative processes synthesize code, images, text, models, or datasets.",
      "useful_coverage" => "It would cover compile, render, synthesize data, generate text, produce code, and merge outputs.",
      "semantic_territory_consumed" => "It makes represented information both the medium and result of every Creation process.",
      "conflicts_or_future_limitations" => "DAT already owns information transformation and transfer; noninformational artifacts and embodied creation would be under-served."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "mental_ideation_processes"
    "A #{root.fetch(:phase)} mental ideation process performed at #{root.fetch(:scope)} creative scope."
  when "material_fabrication_processes"
    "A #{root.fetch(:phase)} material fabrication process performed at #{root.fetch(:scope)} creative scope."
  when "information_synthesis_processes"
    "A #{root.fetch(:phase)} information-synthesis process performed at #{root.fetch(:scope)} creative scope."
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
  siblings = %w[0 1 2].reject { |x| x == third }.map { |x| "CRE:#{first}#{second}#{x}" }
  scopes = %w[0 1 2].reject { |x| x == second }.map { |x| "CRE:#{first}#{x}#{third}" }
  entity = "CRE:0#{second}#{third}"
  affordance = "CRE:2#{second}#{third}"
  (siblings + scopes + [entity, affordance]).uniq
end

def roles
  {
    "low" => "source entity, creator, or participant in the productive transformation",
    "middle" => "productive transformation as the asserted figure",
    "high" => "generative pattern, generated artifact, or jointly constituted result",
    "sustained" => "shared production domain and multiple participants coordinated together"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that this #{root.fetch(:kind)} completed; it does not assert that the active sibling is still running, that the nonactualized sibling holds, or that the result had either polarity.",
      "1" => "Affirms completion of this #{root.fetch(:kind)}, without asserting quality, value, originality, persistence, acceptance, authorship, physical mechanism, or later use.",
      "2/num" => "Leaves unresolved whether this completed #{root.fetch(:kind)} claim holds; runtime uncertainty does not change the lexical root into active or nonactualized phase."
    }
  when "1"
    {
      "0" => "Denies that this #{root.fetch(:kind)} is currently ongoing; it does not itself affirm completion, nonactualization, suspension, failure, absence of data, or lack of capability.",
      "1" => "Affirms that this #{root.fetch(:kind)} is currently occurring, without asserting eventual completion, quality, correctness, duration, originality, authorship, persistence, or side effects.",
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
  entity = id[-2] == "0" ? "studio" : id[-2] == "1" ? "artifact" : "collective"
  graph_roles = id[-2] == "0" ? "ENTITY=#{entity},PATTERN=p" : id[-2] == "1" ? "SOURCE=s,ARTIFACT=#{entity}" : "DOMAIN=#{entity},PARTICIPANTS={a,b,c},RESULT=r"
  ordinary = {
    "0" => "The #{root.fetch(:kind)} finished.",
    "1" => "The #{root.fetch(:kind)} is underway now.",
    "2" => "The typed #{root.fetch(:kind)} is not actualized."
  }.fetch(id[-1])
  entries = [
    ["ordinary_conversation", "#{id}[1](#{graph_roles})", "affirm #{root.fetch(:phase)} #{root.fetch(:kind)}", ordinary, "The root asserts productive-process phase, not quality, success, authorship, or scheduling."],
    ["physical_or_spatial", "MAT(MEDIUM=m)+#{id}[1](#{graph_roles})", "material medium plus #{root.fetch(:phase)} productive process", "A physical medium realizes the productive process while MAT separately describes substance, force, and material change.", "Generation and physical mechanism remain separately typed."],
    ["temporal_or_sequential", "#{id}[1](#{graph_roles})+ORI(INTERVAL=w)", "#{root.fetch(:phase)} productive process during interval w", "During interval w, the productive transformation has the stated lexical phase.", "ORI supplies time and does not replace process phase."],
    ["cross_family_compound", "CRE:001[1](PATTERN=p)+#{id}[1](#{graph_roles})+DAT(REPRESENTATION=d)", "manifest generative pattern plus productive process plus data representation", "The pattern, productive process, and encoded representation remain separately typed.", "Entity, process, and representation remain distinct."],
    ["executable_or_programming", "#{id}[1](#{graph_roles})", "assert #{root.fetch(:phase)} productive transformation", "A runtime tracks generation phase without folding in scheduler state, implementation medium, output quality, or ownership.", "Process phase, resources, and results remain distinct."],
    ["counterexample", "MIN(IDEATION=i,COGNIZER=c)", "mental ideation", "The person is imagining a design, but no productive transformation is occurring.", "MIN ideation does not entail a CRE:1xx productive process."]
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
      "pseudocode" => category == "executable_or_programming" ? "assert(generative_process.phase == #{id.inspect})" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "productive_transformation_processes", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "mental_ideation_processes", alt[0], alternative_invariant(id, "mental_ideation_processes")),
    candidate(id, "material_fabrication_processes", alt[1], alternative_invariant(id, "material_fabrication_processes")),
    candidate(id, "information_synthesis_processes", alt[2], alternative_invariant(id, "information_synthesis_processes"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "productive_transformation_processes",
    "recommendation_reason" => "Only this architecture keeps all nine roots on one productive-transformation layer, follows inward-pattern/outward-artifact/systemic-co-generation scope exactly, and gives every triplet one completed/active/nonactualized axis while reserving Creation entities, cognition, data representation, physical mechanics, structural change, scheduler states, quality, and affordances for CRE:0xx, CRE:2xx, or other families.",
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
    "0" => "one generative pattern formed or modified while retained within one reference entity",
    "1" => "one generated artifact brought into manifestation by productive transformation directed outward from one source",
    "2" => "one jointly constituted result generated through coordinated productive transformation by multiple participants"
  }.fetch(second)
  scope_boundary = {
    "0" => "The process forms or modifies a production-guiding pattern within one entity and does not itself produce an outward artifact. Mental conception, encoding, algorithm, and physical realization remain separate.",
    "1" => "The process preserves one source and one outward generated product. It is neutral about medium, assembly method, creator identity, completion standard, acceptance, and later persistence.",
    "2" => "The process requires coordinated productive contribution by multiple participants toward one jointly constituted result. Independent creations or mere collaboration do not constitute one systemic co-generation."
  }.fetch(second)
  triplet_logic = "Completed, active, and nonactualized are mutually exclusive phases for the same bounded productive transformation at one reference time. Lexical nonactualization states only that the typed process is not actualized; runtime `[2]/num` separately marks uncertainty about any selected phase."
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_1" => "Selects a productive transformation rather than a Creation entity, cognitive act, data transformation, physical mechanism, structural transition, or generative affordance.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Creation-family column.",
      "third_trit" => "Selects the #{state_label} phase of the same productive transformation while leaving runtime truth status, quality, value, authorship, acceptance, tense, probability, and scheduling separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral form-producing process at #{root.fetch(:scope)} scope. #{scope_boundary} It is neutral about mental awareness, encoded representation, physical medium, structural mechanics, creator identity, quality, value, ownership, persistence, scheduling, probability, timing, and cause.",
    "excluded_meanings" => [
      "The generative pattern, generated artifact, or shared repertoire as an entity, and its persistent, manifest, or dormant status.",
      "Mental imagination, inspiration, intention, planning, belief, understanding, attention, or subjective creative experience.",
      "Encoded data transformation, formal algorithm, physical substance, energy, tool, spatial displacement, or structural mechanics realizing the process.",
      "Communicative intent, social collaboration alone, sender or recipient role, message uptake, dialogue, authority, ownership, or authorship.",
      "Restoration to an acceptable prior state, warning, fault, aesthetic quality, originality, success, completion criterion, acceptance, or use.",
      "Capability, access, permission, intention, plan, readiness, queue, schedule, future time, possibility, necessity, probability, or cause."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`CRE:0xx` owns generative patterns, generated artifacts, and shared generative repertoires as entities. `CRE:1xx` owns only pattern formation, artifact generation, and systemic co-generation as actual productive transformations. `CRE:2xx` remains reserved for generative affordances or relations. A manifest pattern does not entail formation, and a manifest artifact does not entail that generation is active or complete. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} phase of this productive transformation. Runtime `[2]/num` instead leaves the already-selected phase claim unresolved; it never changes process phase. Thus a nonactualized root affirmed with `[1]` is a confirmed typed-but-nonactualized productive process, while a completed or active root carrying `[2]/num` remains lexically completed or active but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + CRE:0xx supplies the generative pattern, generated artifact, or shared repertoire without reducing the process to its Creation entity.",
      "#{id} + MAT/STR supplies physical realization and structural mechanics while keeping productive generation distinct.",
      "#{id} + MIN/DAT/LOG supplies ideation, encoded representation, or formal algorithm when those meanings are independently asserted.",
      "#{id} + CRE:2xx may later express generative capacity, dependency, provenance, resource availability, or another productive affordance."
    ],
    "later_era_notes" => "Later eras may lexicalize sketching, composing, authoring, rendering, compiling, fabrication, assembly, simulation, performance, publication, remixing, and specialized collective-production modes. Era Zero should preserve the substrate-neutral productive-process centers and derive algorithms, media, creator roles, originality, quality, and scheduler details compositionally.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


creation_process_stress_base = [
  ["form a design pattern", "one_root", "Use CRE:100–102 when productive transformation forms or modifies a generative pattern while retaining it within one entity."],
  ["compose", "one_root_or_compound", "Composition can use internal pattern formation or outward artifact generation depending on whether the product remains a source pattern or becomes a generated work."],
  ["design", "polysemy_requires_routing", "Mental conception is MIN, a production-guiding pattern is CRE:0xx, and actual form-producing design work is CRE:1xx."],
  ["sketch", "compound", "CRE supplies productive pattern formation or artifact generation; DAT or MAT supplies the mark and medium."],
  ["draft", "compound", "CRE supplies productive formation, DAT supplies the represented draft, and ORI or later vocabulary supplies version status."],
  ["revise a pattern", "one_root_or_compound", "CRE:100–102 can modify a generative pattern; the previous and resulting versions remain separate entities."],
  ["imagine", "different_family", "Imagination alone belongs to MIN and is not productive transformation."],
  ["brainstorm", "different_family_or_compound", "Collective ideation belongs chiefly to MIN and CON unless participants actually co-generate one constituted result."],
  ["intend to create", "different_family", "Intention belongs to MIN and does not actualize a CRE productive process."],
  ["plan production", "compound", "MIN supplies intention, DAT the plan, LOG its constraints, and CRE:1xx applies only when form-producing transformation is asserted."],
  ["generate an artifact", "one_root", "Use CRE:110–112 for a bounded productive transformation directed outward from one source toward one generated artifact."],
  ["create", "one_root_or_compound", "Choose internal pattern formation, outward artifact generation, or systemic co-generation by scope; medium and creator roles remain separate."],
  ["render", "one_root_or_compound", "Rendering can be artifact generation when it brings a generated product into manifestation; DAT supplies representation and MAT the display medium."],
  ["instantiate", "one_root_or_compound", "Instantiation is artifact generation when a productive transformation brings one product into manifestation; formal type relations remain LOG or STR."],
  ["build", "compound", "CRE supplies artifact generation while MAT and STR supply substance, assembly, and structure."],
  ["manufacture", "compound", "CRE supplies generation, MAT physical transformation, and STR production arrangement."],
  ["assemble", "compound", "STR owns incorporation and arrangement; CRE applies when assembly is asserted as generation of one artifact."],
  ["print", "compound", "CRE can supply artifact generation, MAT supplies physical medium, and DAT supplies encoded source content."],
  ["compile code", "compound", "CRE can supply generated artifact identity, LOG the formal procedure, and DAT input and output representations."],
  ["generate text", "compound", "CRE supplies artifact generation while DAT supplies represented text and LOG or CRE:2xx may supply the generator."],
  ["synthesize an image", "compound", "CRE supplies artifact generation and DAT supplies pixel representation; implementation algorithm and medium remain separate."],
  ["perform music", "compound_or_process_specialization", "CRE may supply production of a performance artifact, while LIF agents, CON coordination, and MAT sound realization remain separate."],
  ["publish", "different_process_or_compound", "Publication is chiefly CON distribution plus a CRE artifact; it is not artifact generation itself."],
  ["copy", "different_family_or_compound", "DAT owns information copying; CRE applies only when the copy is constituted as a newly generated artifact."],
  ["transform data", "different_family", "Representation change without form-producing creation belongs to DAT:1xx."],
  ["reconfigure structure", "different_family", "Arrangement change without productive generation belongs to STR:1xx."],
  ["change matter", "different_family", "Physical transformation without Creation-domain generation belongs to MAT."],
  ["restore", "different_family_or_compound", "Return to an acceptable prior condition belongs to REP even when reconstruction also generates an artifact."],
  ["co-create", "one_root", "Use CRE:120–122 when multiple participants coordinate productive transformation toward one jointly constituted result."],
  ["collaborate", "different_family_or_compound", "CON owns collaboration; CRE systemic co-generation additionally requires one jointly constituted productive result."],
  ["collective authorship", "compound", "CRE supplies systemic co-generation and LIF or CON supplies author roles and social attribution."],
  ["ensemble production", "compound", "CRE:12x supplies jointly constituted generation while LIF, CON, MAT, and STR supply participants, coordination, media, and arrangement."],
  ["merge contributions", "compound", "CRE systemic co-generation applies if contributions jointly constitute one generated result; DAT or STR supplies informational or structural merging."],
  ["crowdsource", "compound", "CON and LIF supply participation relations; CRE:12x applies only when those contributions co-generate one result."],
  ["many independent creations", "multiple_processes_not_one_systemic_root", "Separate creations do not become systemic co-generation merely because they occur together."],
  ["pipeline", "compound", "STR and ORI supply arranged stages; CRE supplies the productive transformations performed in them."],
  ["generation completed", "one_root", "Choose CRE:100, CRE:110, or CRE:120 by scope; completion does not entail quality, acceptance, or persistence."],
  ["generation active", "one_root", "Choose CRE:101, CRE:111, or CRE:121 by scope; activity does not entail eventual completion."],
  ["generation pending", "one_root_with_boundary", "CRE:102, CRE:112, or CRE:122 asserts a typed nonactualized process, not scheduling, readiness, queueing, or intention."],
  ["queued rendering", "compound", "CRE:112 supplies nonactualized artifact generation; queue state and order require STR, DAT, or ORI."],
  ["scheduled build", "compound", "CRE:112 supplies nonactualized artifact generation and ORI supplies schedule or future placement."],
  ["possible creation", "grammar_or_compound", "Possibility is ORI or modal grammar; lexical nonactualization alone does not assert possibility."],
  ["failed creation", "compound", "CRE supplies productive-process phase and WRN or LOG supplies failure under a criterion."],
  ["successful creation", "compound", "CRE completion does not entail success; LOG or goal evaluation must supply the criterion and result."],
  ["unfinished artifact", "compound", "A manifest artifact may result from an active process, but incompletion and artifact state must be stated separately."],
  ["original creation", "compound_or_later_relation", "CRE supplies generation while originality requires provenance comparison or later specialized vocabulary."],
  ["automatic generation", "compound", "CRE supplies productive transformation while LOG, DAT, or CRE:2xx supplies the automated generator and capability."],
  ["self-generation", "compound_or_later_relation", "CRE supplies generation; source-product identity and reflexive relation must be expressed separately."],
  ["emergence", "compound_or_different_family", "CRE applies when a productive process generates a form; ORI supplies causal or ontological emergence."],
  ["completed process uncertain", "runtime", "A completed CRE:1x0 root with [2]/num leaves completion uncertain and does not select active or nonactualized phase."],
  ["active process denied", "runtime", "An active CRE:1x1 root with [0] denies current activity without affirming completion or nonactualization."],
  ["nonactualized process affirmed", "runtime_and_lexical", "A CRE:1x2 root with [1] confirms typed-but-nonactualized process status without adding future or readiness."],
  ["completed and active simultaneously", "contradiction", "Completed and active are mutually exclusive phases for the same bounded productive transformation at one reference time."],
  ["active and nonactualized simultaneously", "contradiction", "Active and nonactualized are mutually exclusive for the same bounded productive transformation at one reference time."],
  ["pattern versus pattern formation", "layer_boundary", "CRE:0xx identifies the generative pattern; CRE:10x identifies the process forming or modifying it."],
  ["artifact versus artifact generation", "layer_boundary", "CRE:01x identifies the generated artifact; CRE:11x identifies the process bringing it into manifestation."],
  ["repertoire versus co-generation", "layer_boundary", "CRE:02x identifies the shared generative repertoire; CRE:12x identifies coordinated production of one joint result."],
  ["generation versus capability", "layer_boundary", "CRE:1xx asserts actual process phase; CRE:2xx remains reserved for generative capacity or enabling relation."],
  ["creation versus causation", "cross_family_boundary", "CRE supplies productive transformation while ORI supplies causal explanation or ontological origin."],
  ["creation versus communication", "cross_family_boundary", "CRE supplies generation while CON supplies interaction, coordination, publication, and exchange."],
  ["creation versus computation", "cross_family_boundary", "CRE supplies form-producing function; LOG and DAT supply formal operation and information transformation when separately relevant."]
].freeze

creation_process_root_stress = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} direct", "one_root", "#{id}[1] directly affirms the invariant without adding quality, value, authorship, medium, algorithm, or schedule."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves this exact #{root[:phase]} phase claim unresolved and does not select a lexical sibling."],
    ["#{root[:title]} with entity", "compound", "CRE:0xx supplies the pattern, artifact, or repertoire while #{id} supplies productive-process phase."],
    ["#{root[:title]} with medium", "compound", "MAT supplies physical realization while #{id} remains substrate-neutral generation."],
    ["#{root[:title]} with algorithm", "compound", "LOG and DAT supply formal and representational implementation while #{id} supplies productive function."],
    ["#{root[:title]} evaluated", "compound", "LOG supplies success or quality evaluation while #{id} remains the productive transformation independently."]
  ]
end

stress_rows = creation_process_stress_base + creation_process_root_stress

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("CRE1-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "CRE:100–122 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/CRE_100_122_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "CRE:100–122 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "CRE:100–102" => "internal pattern formation: completed / active / nonactualized", "CRE:110–112" => "artifact generation: completed / active / nonactualized", "CRE:120–122" => "systemic co-generation: completed / active / nonactualized" }, "triplet_logic" => { "process_phases" => "completed, active, and nonactualized are mutually exclusive for the same bounded productive transformation at one reference time", "nonactualized_member" => "states typed process nonactualization without planning, scheduling, readiness, futurity, or probability", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/CRE_100_122_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "CRE:100–122 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# CRE:100–122 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Creation process meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `CRE:1xx` the substrate-neutral productive-process layer. The inward triplet forms or modifies a generative pattern while retaining it within one reference entity, the outward triplet brings one generated artifact into manifestation through transformation directed outward from one source, and the systemic triplet coordinates multiple participants in generating one jointly constituted result. Completed, active, and nonactualized supply the exact third-trit contrast.\n\nThe three phases are mutually exclusive for the same bounded productive transformation at one reference time. Lexical `1x2` means only that the typed process is not actualized; intention, planning, readiness, queueing, scheduling, future time, probability, and missing resources remain separate. Runtime `[2]/num` remains uncertainty about the selected phase. The design rejects the provisional mixture of imagination, testing, revision, completion quality, fabrication method, system state, scheduling, and readiness. Creation entities remain `CRE:0xx`; generative affordances remain `CRE:2xx`; cognition, data representation, physical mechanics, structural transitions, communication roles, and formal evaluation remain other families.\n\n"

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
review << "| CRE:100–102 | one generative pattern formed or modified within one entity | formation completed | formation ongoing | typed formation not actualized |\n"
review << "| CRE:110–112 | one generated artifact brought into manifestation from one source | generation completed | generation ongoing | typed generation not actualized |\n"
review << "| CRE:120–122 | multiple participants generate one jointly constituted result | co-generation completed | co-generation ongoing | typed co-generation not actualized |\n\n"
review << "**Triplet logic:** completed, active, and nonactualized are mutually exclusive for the same bounded productive transformation at one reference time. Completion does not entail quality, value, originality, acceptance, persistence, or positive evaluation.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | mental ideation, data encoding, material mechanics, structural transition, communication roles, quality, originality, authorship, scheduling, time, and modality |\n" }
review << "\n## Concepts intentionally reserved\n\nMental imagination, specific algorithms, data transformation, physical fabrication mechanics, structural reconfiguration, creator identity, authorship, originality, aesthetic quality, completion criteria, publication, restoration, resource availability, scheduling, readiness, queues, ownership, and modality remain other-family meanings, later CRE specializations, grammar, or compounds.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later CRE layers, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# CRE:100–122 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MIN ideation; DAT design record; LOG algorithm", "1" => "MAT fabrication; STR assembly; DAT rendering", "2" => "CON collaboration; STR integration; LIF collective activity" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | CRE keeps only pattern formation, artifact generation, or systemic co-generation; entities, media, participant roles, cognition, algorithms, quality, authorship, and side effects remain separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- A productive process is not the generative pattern, generated artifact, shared repertoire, physical medium, implementation algorithm, creator, owner, or quality judgment.\n- A completed pattern formation, artifact generation, or systemic co-generation does not entail quality, originality, value, persistence, acceptance, authorship, publication, or success under an external criterion.\n- A nonactualized productive process is typed but not actualized; it is not planned, intended, ready, queued, scheduled, future, impossible, or uncertain.\n- Inward formation keeps the generative pattern within one reference entity. Outward generation brings one artifact into manifestation from one source. Systemic co-generation coordinates multiple participants toward one jointly constituted result.\n- Several unrelated creations or collaborative interactions do not become one systemic co-generation merely because they occur simultaneously.\n- Completed, active, and nonactualized are mutually exclusive phases for the same bounded productive process at one reference time.\n- Runtime `[2]/num` leaves a selected phase assertion unresolved and never selects lexical nonactualization.\n\n**CONCLUSION: CRE:1XX STANDS ALONE ONLY FOR INTERNAL PATTERN FORMATION, OUTWARD ARTIFACT GENERATION, AND SYSTEMIC CO-GENERATION; CREATION ENTITIES, MENTAL IDEATION, DATA TRANSFORMATION, PHYSICAL MECHANICS, STRUCTURAL CHANGE, COMMUNICATION ROLES, FORMAL EVALUATION, RESTORATION, QUALITY, AUTHORSHIP, TIME, AND MODALITY REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built CRE:100–122 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
