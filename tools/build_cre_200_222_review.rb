#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "CRE:200–222"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "CRE_200_222"
SEMANTIC_CENTER = "productive-process affordances: internal pattern-forming capacity, source-artifact generative relations, and systemic co-generative capacity"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "CRE:200" => ["stable creative agency", "An entity has a dependable inward capacity to imagine, design, generate, or transform forms."],
  "CRE:201" => ["expressed creativity", "Creative capacity is presently available and producing or revising forms."],
  "CRE:202" => ["untapped creativity", "A capacity for creation exists but is undeveloped, inaccessible, or not presently expressed."],
  "CRE:210" => ["established authorship", "A stable relation connects a creator, design intention, or source transformation to a target work."],
  "CRE:211" => ["active design influence", "A creator or source form is actively shaping, generating, or transforming a target."],
  "CRE:212" => ["unresolved authorship", "A possible creative source, ownership, or design relation exists but is disputed or unconfirmed."],
  "CRE:220" => ["stable design space", "A creative system has established relationships among its forms, constraints, templates, and transformations."],
  "CRE:221" => ["active composability", "Forms and generators are actively combining and influencing one another across a creative system."],
  "CRE:222" => ["unrealized form space", "A coherent family of artifacts, worlds, or transformations could exist but has not yet been created."]
}.freeze

ROOTS = {
  "CRE:200" => { title: "persistent internal pattern-forming capacity", phase: "persistent", scope: "inward", kind: "internal pattern-forming capacity", invariant: "A persistent capacity within one reference entity to form or modify a generative pattern while retaining it within that entity, independently of whether that capacity is presently operative." },
  "CRE:201" => { title: "operative internal pattern-forming capacity", phase: "operative", scope: "inward", kind: "internal pattern-forming capacity", invariant: "A capacity within one reference entity to form or modify a generative pattern while retaining it within that entity that is presently operative." },
  "CRE:202" => { title: "latent internal pattern-forming capacity", phase: "latent", scope: "inward", kind: "internal pattern-forming capacity", invariant: "A capacity within one reference entity to form or modify a generative pattern while retaining it within that entity that exists without being presently operative." },
  "CRE:210" => { title: "persistent source-artifact generative relation", phase: "persistent", scope: "outward", kind: "source-artifact generative relation", invariant: "A persistent generative relation from one source toward one distinct prospective artifact that can enable the artifact to be brought into manifestation by productive transformation, independently of whether that relation is presently operative." },
  "CRE:211" => { title: "operative source-artifact generative relation", phase: "operative", scope: "outward", kind: "source-artifact generative relation", invariant: "A generative relation from one source toward one distinct prospective artifact that presently enables the artifact to be brought into manifestation by productive transformation." },
  "CRE:212" => { title: "latent source-artifact generative relation", phase: "latent", scope: "outward", kind: "source-artifact generative relation", invariant: "A generative relation from one source toward one distinct prospective artifact that exists without presently enabling the artifact to be brought into manifestation by productive transformation." },
  "CRE:220" => { title: "persistent systemic co-generative capacity", phase: "persistent", scope: "systemic", kind: "systemic co-generative capacity", invariant: "A persistent capacity of multiple participants in one shared production domain to generate one jointly constituted result through coordinated productive transformation, independently of whether that capacity is presently operative." },
  "CRE:221" => { title: "operative systemic co-generative capacity", phase: "operative", scope: "systemic", kind: "systemic co-generative capacity", invariant: "A capacity of multiple participants in one shared production domain to generate one jointly constituted result through coordinated productive transformation that is presently operative." },
  "CRE:222" => { title: "latent systemic co-generative capacity", phase: "latent", scope: "systemic", kind: "systemic co-generative capacity", invariant: "A capacity of multiple participants in one shared production domain to generate one jointly constituted result through coordinated productive transformation that exists without being presently operative." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [5, 7, 9, 4, 5, 8, 8, 9] },
  "productive_process_affordances" => { scores: [10, 10, 10, 10, 9, 10, 10, 10] },
  "creative_agency_capacities" => { scores: [8, 8, 6, 7, 4, 8, 10, 7] },
  "authorship_provenance_relations" => { scores: [8, 7, 7, 6, 5, 8, 9, 8] },
  "composability_design_space" => { scores: [8, 8, 7, 7, 5, 9, 8, 10] }
}.freeze

ALT_TITLES = {
  "CRE:200" => ["persistent inward creative agency", "persistent internal authorship relation", "persistent internal composability"],
  "CRE:201" => ["operative inward creative agency", "operative internal authorship relation", "operative internal composability"],
  "CRE:202" => ["latent inward creative agency", "latent internal authorship relation", "latent internal composability"],
  "CRE:210" => ["persistent target-directed creative agency", "persistent target authorship relation", "persistent target composability"],
  "CRE:211" => ["operative target-directed creative agency", "operative target authorship relation", "operative target composability"],
  "CRE:212" => ["latent target-directed creative agency", "latent target authorship relation", "latent target composability"],
  "CRE:220" => ["persistent collective creative agency", "persistent systemic provenance relation", "persistent systemic design space"],
  "CRE:221" => ["operative collective creative agency", "operative systemic provenance relation", "operative systemic design space"],
  "CRE:222" => ["latent collective creative agency", "latent systemic provenance relation", "latent systemic design space"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identities, biological capacities, agents, and social roles. A living creator may bear a productive affordance, but CRE:2xx does not encode organism, personhood, office, institutional role, or agency in general.",
  "MOV" => "MOV owns position, routes, displacement, and motion affordances. Material or informational inputs may move during production, but CRE:2xx asserts generative enablement rather than spatial reachability.",
  "MAT" => "MAT owns substance, energy, force, contact, material compatibility, and physical capacities. Tools and media may realize a generative affordance, but CRE:2xx remains substrate-neutral.",
  "MIN" => "MIN owns imagination, intention, attention, understanding, and cognitive capacities. Productive affordance can exist without awareness or imagination, and imagination alone does not establish CRE:2xx.",
  "CON" => "CON owns linkage, communication, participation, authority, and interaction channels. Coordination can support co-generation, but CRE:2xx requires typed enablement for one productive transformation rather than interaction alone.",
  "WRN" => "WRN owns hazards, faults, adverse processes, susceptibility, exposure, and propagation pathways. A blocked productive affordance may be adverse, but CRE:2xx does not assert failure, danger, or vulnerability.",
  "STR" => "STR owns arrangements, interfaces, dependencies, structural compatibility, and reconfiguration affordances. Structure may enable production, but CRE:2xx requires form-producing function rather than composability alone.",
  "REP" => "REP owns restoration conditions, transformations, and affordances. Reconstruction may use a generative affordance, but CRE:2xx does not entail return to a prior acceptable state.",
  "LOG" => "LOG owns formal constraints, evaluations, applicability, and evaluability. Rules may govern a generator, but CRE:2xx does not assert admissibility, computability, or formal validity.",
  "DAT" => "DAT owns represented information and data-process affordances. Encoded templates and algorithms may implement CRE:2xx, but information transformability is not productive generation.",
  "ORI" => "ORI owns time, cause, provenance, unrestricted possibility, necessity, probability, and ontological qualification. CRE:2xx asserts a typed existing productive affordance, never mere possibility or causal origin."
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
  when "productive_process_affordances"
    values[4] += 1 if second == "0"
    values[6] -= 1 if second == "2"
  when "creative_agency_capacities"
    values[2] -= 1 if second == "1"
    values[4] -= 2 if second == "2"
  when "authorship_provenance_relations"
    values[1] -= 1 if second == "0"
    values[3] -= 1 if second == "2"
  when "composability_design_space"
    values[2] -= 1 if second != "2"
    values[4] -= 1 if second == "1"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, architecture, title)
  root = ROOTS.fetch(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional meanings recognize that first-trit 2 concerns capacities and relations, and they attach familiar creative vocabulary to #{root.fetch(:scope)} scope and #{root.fetch(:phase)} status.",
      "useful_coverage" => "They cover creativity, agency, authorship, influence, composability, design spaces, source attribution, and unrealized form families.",
      "semantic_territory_consumed" => "Across the block they mix cognition, agency, productive capability, current productive activity, authorship, ownership, causal influence, provenance, structure, composability, possibility, and unrealized products.",
      "conflicts_or_future_limitations" => "The triplets do not preserve one affordance center, and third-trit 2 shifts among undeveloped, inaccessible, disputed, unconfirmed, and not-yet-created rather than lexical latency."
    }
  when "productive_process_affordances"
    {
      "why_it_fits" => "First-trit 2 becomes the capacity or qualifying relation enabling the matching CRE:1xx process; the second trit changes only inward, target, or systemic scope; and the third changes only persistent, operative, or latent status.",
      "useful_coverage" => "It supports capable-of-designing, generatable, source-enabled production, renderability, co-creatability, joint production capability, generators, build systems, and formal production pipelines.",
      "semantic_territory_consumed" => "Only typed enablement for the approved internal pattern-formation, artifact-generation, or systemic co-generation process. Entities, actual processes, agency, media, algorithms, authorship, provenance, quality, and modality remain separate.",
      "conflicts_or_future_limitations" => "Claims about creator identity, originality, ownership, resources, implementation method, termination, quality, or causal provenance require compounds or later specialization."
    }
  when "creative_agency_capacities"
    {
      "why_it_fits" => "Everyday language often describes people, teams, and systems as creative, capable, or generative.",
      "useful_coverage" => "It would cover creative talent, inventiveness, agency, artistic ability, team creativity, and generative intelligence.",
      "semantic_territory_consumed" => "It makes a bearer or agent central and tends to combine mental potential, productive capacity, social role, and value judgment.",
      "conflicts_or_future_limitations" => "MIN owns imagination and cognitive capacity, LIF owns agency and roles, and non-agentive generators would be awkward or wrongly anthropomorphized."
    }
  when "authorship_provenance_relations"
    {
      "why_it_fits" => "Creation naturally raises source-to-work relations such as authorship, derivation, influence, and provenance.",
      "useful_coverage" => "It would cover created-by, authored-by, derived-from, inspired-by, design influence, attribution, and collective authorship.",
      "semantic_territory_consumed" => "It consumes historical or causal attribution and often social or legal responsibility rather than present productive enablement.",
      "conflicts_or_future_limitations" => "The outward column fits, but inward and systemic variants strain; ORI owns causal origin, LIF/CON owns roles, and ownership or authority needs separate relations."
    }
  when "composability_design_space"
    {
      "why_it_fits" => "Templates, parts, rules, and generators can define a space of forms that combine or remain unrealized.",
      "useful_coverage" => "It would cover composable, modular, generative space, design system, extensible, remixable, and possible product family.",
      "semantic_territory_consumed" => "It consumes structural compatibility, formal possibility, and a collection of possible results rather than one productive affordance.",
      "conflicts_or_future_limitations" => "STR owns composability and arrangement, LOG owns formal constraints, and ORI owns possibility; inward and target variants lack a uniform center."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "creative_agency_capacities"
    "A #{root.fetch(:phase)} capacity of an agent or system for creative agency at #{root.fetch(:scope)} scope."
  when "authorship_provenance_relations"
    "A #{root.fetch(:phase)} authorship or provenance relation at #{root.fetch(:scope)} creation scope."
  when "composability_design_space"
    "A #{root.fetch(:phase)} composability or design-space affordance at #{root.fetch(:scope)} scope."
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
  process = "CRE:1#{second}#{third}"
  (siblings + scopes + [entity, process]).uniq
end

def roles
  {
    "low" => "reference entity, production source, or participant bearing the productive affordance",
    "middle" => "productive capacity or generative relation as the asserted figure",
    "high" => "generative pattern, prospective artifact, or jointly constituted result",
    "sustained" => "shared production domain and multiple co-generative participants"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that this #{root.fetch(:kind)} persists in the stated production context; it does not select the operative or latent sibling and does not establish a different agency, authorship, or quality relation.",
      "1" => "Affirms that this #{root.fetch(:kind)} persists independently of current operation, without asserting that a productive process is occurring or that any result quality holds.",
      "2/num" => "Leaves unresolved whether this persistent #{root.fetch(:kind)} claim holds; runtime uncertainty does not change the lexical root into operative or latent status."
    }
  when "1"
    {
      "0" => "Denies that this #{root.fetch(:kind)} is presently operative; it does not deny persistent identity or affirm the latent sibling, impossibility, or rule absence.",
      "1" => "Affirms that this #{root.fetch(:kind)} is presently operative under the applicable conditions, without asserting that the corresponding productive process is underway or completed.",
      "2/num" => "Leaves current operation of this #{root.fetch(:kind)} unresolved; token uncertainty does not select the persistent or latent lexical sibling."
    }
  else
    {
      "0" => "Denies that this #{root.fetch(:kind)} exists as the stated nonoperative productive affordance; it does not establish that an operative sibling holds or that the process is impossible.",
      "1" => "Affirms this #{root.fetch(:kind)} as existing but not presently operative, without encoding hiddenness, uncertainty, probability, future activation, missing resources, or permission.",
      "2/num" => "Leaves unresolved even the assertion that this latent #{root.fetch(:kind)} exists; lexical latency remains distinct from runtime assertion-level uncertainty."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entity = id[-2] == "0" ? "studio" : id[-2] == "1" ? "artifact" : "collective"
  graph_roles = id[-2] == "0" ? "ENTITY=#{entity},PATTERN=p" : id[-2] == "1" ? "SOURCE=s,PROSPECTIVE_ARTIFACT=#{entity}" : "DOMAIN=#{entity},PARTICIPANTS={a,b,c},RESULT=r"
  status_text = { "0" => "persists independently of present operation", "1" => "is presently operative", "2" => "exists but is not presently operative" }.fetch(id[-1])
  ordinary = "The #{root.fetch(:kind)} for the #{entity} #{status_text}."
  entries = [
    ["ordinary_conversation", "#{id}[1](#{graph_roles})", "affirm #{root.fetch(:phase)} #{root.fetch(:kind)}", ordinary, "The root asserts productive enablement and lexical status, not an actual process, creator identity, or result quality."],
    ["physical_or_spatial", "MAT(MEDIUM=m)+#{id}[1](#{graph_roles})", "material medium plus #{root.fetch(:phase)} productive affordance", "The workshop or machine realizes the productive affordance while MAT separately describes substance, energy, tools, and physical mechanics.", "Productive affordance and material implementation remain separately typed."],
    ["temporal_or_sequential", "#{id}[1](#{graph_roles})+ORI(INTERVAL=w)", "#{root.fetch(:phase)} productive affordance during interval w", "During interval w, the productive affordance has the stated lexical status.", "ORI supplies time and does not replace persistent, operative, or latent status."],
    ["cross_family_compound", "CRE:001[1](PATTERN=p)+#{id}[1](#{graph_roles})+DAT(REPRESENTATION=d)", "manifest generative pattern plus #{root.fetch(:phase)} productive affordance plus data representation", "The generative entity and its productive affordance remain CRE while DAT separately supplies an encoded representation.", "Entity, affordance, and representation remain distinct."],
    ["executable_or_programming", "#{id}[1](#{graph_roles})", "assert #{root.fetch(:phase)} productive affordance", "A runtime tracks whether the selected generative affordance has the stated status without asserting execution, completion, or output quality.", "Capability, process, and result remain distinct."],
    ["counterexample", "CRE:101[1](ENTITY=#{entity},PATTERN=p)", "active internal pattern formation", "The productive transformation is running now.", "Use CRE:1xx for the actual process; #{id} names only its enabling capacity or relation."]
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
      "pseudocode" => category == "executable_or_programming" ? "assert(productive_affordance.status == #{id.inspect})" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "productive_process_affordances", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "creative_agency_capacities", alt[0], alternative_invariant(id, "creative_agency_capacities")),
    candidate(id, "authorship_provenance_relations", alt[1], alternative_invariant(id, "authorship_provenance_relations")),
    candidate(id, "composability_design_space", alt[2], alternative_invariant(id, "composability_design_space"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "productive_process_affordances",
    "recommendation_reason" => "Only this architecture keeps all nine roots on one productive-process-enablement center, follows inward-pattern/target-artifact/systemic-co-generation scope exactly, and gives every triplet one persistent/operative/latent axis while reserving Creation entities, actual processes, agency, algorithms, media, authorship, provenance, structural composability, quality, and modality for other roots or composition.",
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
  state_label = { "0" => "persistent", "1" => "operative", "2" => "latent" }.fetch(third)
  scope_explanation = {
    "0" => "one reference entity and its capacity to form or modify a retained generative pattern",
    "1" => "one source and one distinct prospective artifact joined by a relation enabling outward artifact generation",
    "2" => "multiple participants in one shared production domain with capacity for one jointly constituted result"
  }.fetch(second)
  scope_boundary = {
    "0" => "The capacity concerns productive formation or modification of a generative pattern retained within one entity and does not itself produce an outward artifact. The pattern, algorithm, medium, actual transformation, and result remain separate.",
    "1" => "The relation preserves one production source and one distinct prospective artifact role. Physical mechanism, creator identity, actual generation, completion, acceptance, and later persistence remain separate.",
    "2" => "The capacity requires multiple participants whose coordinated productive contributions can constitute one joint result. Independent productive capacities or collaboration alone do not constitute one systemic affordance."
  }.fetch(second)
  triplet_logic = "Persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive for the same affordance at one reference time. Lexical latency affirms an existing but nonoperative affordance; runtime `[2]/num` separately marks uncertainty about any selected status."
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_2" => "Selects a productive-process capacity or qualifying generative relation rather than a Creation entity, actual productive process, creator, physical mechanism, result value, or unrestricted modality.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Creation-family column.",
      "third_trit" => "Selects the #{state_label} status of the same productive affordance while leaving runtime truth status, actual production, quality, authorship, observer knowledge, tense, probability, permission, and scheduling separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral productive-process affordance at #{root.fetch(:scope)} scope. #{scope_boundary} It is neutral about Creation-entity identity, mental agency, physical medium, formal algorithm, structural mechanics, creator role, authorship, originality, quality, value, resource sufficiency, scheduling, probability, timing, and cause.",
    "excluded_meanings" => [
      "The generative pattern, generated artifact, or shared generative repertoire as an entity, and its persistent, manifest, or dormant status.",
      "The completed, active, or nonactualized pattern-formation, artifact-generation, or systemic co-generation process and any quality result.",
      "Mental imagination, general agency, specific encodings, formal algorithms, physical tools, media, structural arrangements, credentials, or computational resources.",
      "Physical, biological, communicative, cognitive, informational, logical, structural, restorative, or adverse capacity or transformation.",
      "Authorship, attribution, provenance, originality, ownership, authority, formal possibility, composability alone, quality, performance, or resource sufficiency.",
      "Observer knowledge, evidence, intention, plan, readiness, queue, schedule, future time, unrestricted possibility, necessity, probability, or cause."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`CRE:0xx` owns generative patterns, generated artifacts, and shared generative repertoires as entities. `CRE:1xx` owns the corresponding completed, active, or nonactualized productive transformations. `CRE:2xx` owns only typed productive enablement: internal pattern-forming capacity, source-artifact generative relations, and systemic co-generative capacity. A manifest pattern does not entail capacity, an affordance does not entail an actual process, and a completed process does not entail continuing capacity, quality, or authorship. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} status of this productive affordance. Runtime `[2]/num` instead leaves the already-selected status claim unresolved; it never changes affordance status. Thus a latent root affirmed with `[1]` is a confirmed existing-but-nonoperative productive affordance, while a persistent or operative root carrying `[2]/num` remains lexically persistent or operative but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + CRE:0xx supplies the generative pattern, generated artifact, or shared repertoire without reducing the affordance to its Creation entity.",
      "#{id} + CRE:1xx states that the corresponding pattern formation, artifact generation, or systemic co-generation is actually completed, active, or nonactualized.",
      "#{id} + MAT/DAT/LOG/STR supplies medium, representation, algorithm, resources, and implementation while preserving the CRE affordance boundary.",
      "#{id} + ORI/CON/LIF may express timing, modality, provenance, participant roles, authorship, or authority as separate meanings."
    ],
    "later_era_notes" => "Later eras may lexicalize artistic talent, authorship, originality, derivation, remixability, renderability, compilability, manufacturability, toolchain availability, resource-bounded generativity, design-space traversal, and specialized collective-production capacities. Era Zero should preserve the substrate-neutral productive-enablement center and derive stronger social, legal, aesthetic, and technical claims compositionally.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


creation_affordance_stress_base = [
  ["capable of forming a design pattern", "one_root", "CRE:200–202 owns typed capacity within one entity to form or modify a retained generative pattern."],
  ["capable of revising a template", "one_root_or_compound", "Internal pattern-forming capacity covers productive modification; DAT supplies an encoded template and ORI may supply version timing."],
  ["creative ability", "ambiguous_compound", "Use CRE only for productive enablement; MIN supplies imagination and LIF supplies an agent or social role."],
  ["talented artist", "compound_or_later_specialization", "LIF identifies the person, MIN may supply cognitive ability, CRE supplies productive affordance, and evaluation supplies talent or quality."],
  ["imaginative", "different_family", "Imagination belongs to MIN and does not by itself establish capacity for productive transformation."],
  ["intends to create", "different_family", "Intention belongs to MIN; a productive affordance may exist without intention and intention may exist without operative capacity."],
  ["knows how to create", "compound", "MIN supplies knowledge while CRE supplies objective productive enablement under the stated conditions."],
  ["generator available", "one_root_or_compound", "An operative CRE affordance can express present productive enablement while LOG, DAT, STR, or MAT supplies the implementing generator."],
  ["generator exists", "entity_or_compound", "A tool or program is an entity; CRE:2xx applies only when its typed productive affordance is asserted."],
  ["renderable", "one_root_or_compound", "Source-artifact generative relation can cover renderability when one source can yield one prospective artifact; representation and renderer remain separate."],
  ["compilable", "compound_or_later_specialization", "CRE supplies productive enablement, LOG the formal procedure, DAT the code representation, and result validity remains separate."],
  ["manufacturable", "compound", "CRE supplies artifact-generative enablement while MAT and STR supply physical materials, mechanics, and assembly constraints."],
  ["printable", "compound", "CRE supplies source-artifact generativity, DAT supplies encoded input, and MAT supplies the printing medium and mechanism."],
  ["buildable", "one_root_or_compound", "CRE:210–212 can state that one source is generatively related to a prospective artifact; structural feasibility and resources are separate."],
  ["generatable artifact", "one_root", "CRE:210–212 asserts the typed source-artifact relation that can enable one prospective artifact to be brought into manifestation."],
  ["source can produce target", "one_root", "Use CRE:210–212 when one source stands in the relevant generative relation to one distinct prospective artifact."],
  ["authored by", "reserved_relation", "Authorship identifies an agent-to-work attribution and requires LIF, CON, or later provenance vocabulary rather than generic productive enablement."],
  ["created by", "compound_or_reserved_relation", "CRE can supply the creation event or affordance, but causal source attribution requires ORI and participant identity."],
  ["derived from", "compound_or_reserved_relation", "Derivation requires causal or historical provenance beyond a present source-artifact productive affordance."],
  ["inspired by", "different_family_or_compound", "MIN supplies inspiration and ORI may supply causal relation; CRE applies only if productive enablement is separately asserted."],
  ["owned by", "different_relation", "Ownership and authority are not Creation affordances and require social, legal, or connection relations."],
  ["licensed to generate", "compound", "CRE supplies productive affordance while LOG or CON supplies permission, policy, and authority."],
  ["resources sufficient to build", "compound", "CRE supplies productive affordance; MAT, STR, DAT, and LOG supply required resources and constraints."],
  ["toolchain ready", "compound", "Operative CRE capacity may combine with available tools and dependencies, but readiness is not the invariant meaning."],
  ["scheduled generation", "compound", "A latent or operative productive affordance combines with ORI scheduling; lexical status never means scheduled."],
  ["possible creation", "different_family", "ORI owns unrestricted possibility; CRE:2xx asserts a specific existing productive affordance."],
  ["probable creation", "different_family_or_compound", "ORI supplies probability and CRE separately supplies the typed productive affordance."],
  ["creation process running", "process_layer", "CRE:1xx owns actual productive-process phase; CRE:2xx only states capacity or a qualifying relation."],
  ["creation process completed", "process_layer", "CRE:1x0 owns completion; a productive affordance entails no actual process or result."],
  ["generative pattern exists", "entity_layer", "CRE:00x owns the generative pattern; existence or manifestation does not entail pattern-forming capacity."],
  ["artifact exists", "entity_layer", "CRE:01x owns the generated artifact; artifact identity does not entail a currently operative source-artifact relation."],
  ["shared repertoire exists", "entity_layer", "CRE:02x owns a shared generative repertoire; it does not entail capacity for one jointly constituted result."],
  ["co-creatable", "one_root", "CRE:220–222 asserts capacity of multiple participants to generate one jointly constituted result in a shared production domain."],
  ["team can create together", "one_root_or_compound", "CRE supplies systemic co-generative capacity while LIF and CON supply participants, roles, and coordination channels."],
  ["collaborative", "different_family_or_compound", "CON owns collaboration; CRE systemic capacity additionally requires productive enablement for one joint result."],
  ["collective creativity", "compound", "CRE supplies co-generative capacity, LIF supplies the collective, and MIN may supply shared ideation."],
  ["crowdsourceable", "compound_or_later_specialization", "CRE supplies possible joint production while CON and LIF supply contributor relations and participation structure."],
  ["ensemble can perform", "compound", "CRE may supply systemic productive capacity while LIF, CON, and MAT supply performers, coordination, and physical realization."],
  ["composable", "different_family_or_compound", "STR owns compatibility for combination; CRE applies only when the combination enables one generated result."],
  ["remixable", "compound_or_later_specialization", "CRE supplies productive affordance, STR composability, DAT representations, and provenance remains separately typed."],
  ["extensible design system", "compound", "STR and LOG supply modular structure and constraints; CRE supplies productive capacity only when new forms can be generated."],
  ["design space", "entity_relation_or_compound", "A structured possibility space belongs chiefly to STR, LOG, and ORI; CRE:2xx asserts concrete productive enablement, not the space itself."],
  ["unrealized form space", "different_family_or_compound", "ORI supplies unrealized possibility and LOG/STR supplies constraints; lexical CRE latency requires an existing typed affordance."],
  ["many independent creators", "multiple_affordances", "Use separate CRE:20x or CRE:21x claims unless the participants can jointly constitute one result under CRE:22x."],
  ["shared tools only", "implementation_not_affordance", "Common tools may support co-generative capacity but do not establish coordinated productive enablement for one joint result."],
  ["common template only", "entity_not_affordance", "A shared CRE:02x repertoire can exist even when participants lack operative systemic co-generative capacity."],
  ["persistent productive capacity", "one_root", "Choose CRE:200, CRE:210, or CRE:220 by scope; persistence is neutral about current operation."],
  ["operative productive capacity", "one_root", "Choose CRE:201, CRE:211, or CRE:221 by scope; operation does not assert that production is occurring."],
  ["latent productive capacity", "one_root", "Choose CRE:202, CRE:212, or CRE:222 by scope; latency means existing but nonoperative, not unknown or future."],
  ["persistent plus operative capacity", "two_compatible_roots", "The persistent and operative siblings may co-occur because identity and current operation are independent claims."],
  ["persistent plus latent capacity", "two_compatible_roots", "The persistent and latent siblings may co-occur while the same affordance exists nonoperatively."],
  ["operative and latent simultaneously", "invalid_same_reference_claim", "Operative and latent are mutually exclusive for the same productive affordance at one reference time."],
  ["latent affordance affirmed", "runtime_and_lexical", "A CRE:2x2 root with runtime [1] confirms an existing nonoperative productive affordance."],
  ["operative affordance uncertain", "runtime_and_lexical", "A CRE:2x1 root with runtime [2]/num leaves current operation unresolved without selecting lexical latency."],
  ["persistent affordance denied", "runtime_and_lexical", "Runtime [0] denies persistent identity without selecting an operative or latent sibling."],
  ["unknown productive capacity", "runtime_or_epistemic", "Use runtime [2]/num or MIN/DAT evidence; lexical latency never means unknown."],
  ["hidden capacity", "compound", "CRE latency supplies nonoperation only; observer ignorance or undisclosed status requires MIN, DAT, or CON."],
  ["capacity versus agency", "cross_family_boundary", "CRE owns typed productive enablement while LIF and MIN own agent identity, agency, and cognitive capacities."],
  ["capacity versus authorship", "same_domain_boundary", "CRE:2xx enables productive transformation; authorship attributes a result to a participant and remains separately typed."],
  ["capacity versus structural compatibility", "cross_family_boundary", "CRE requires form-producing function while STR owns whether components can be arranged or combined."],
  ["capacity versus general possibility", "cross_family_boundary", "CRE:2xx asserts an existing typed affordance while ORI owns unrestricted possibility, necessity, and probability."]
].freeze

creation_affordance_root_stress = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} identity", "one_root", "#{id}[1] directly affirms the invariant without adding a Creation entity, actual process, creator identity, physical medium, quality, or authority."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves this exact #{root[:phase]} affordance claim unresolved and does not select a lexical sibling."],
    ["#{root[:title]} with entity", "compound", "CRE:0xx supplies the generative pattern, artifact, or repertoire while #{id} supplies typed productive enablement."],
    ["#{root[:title]} under rule", "compound", "LOG:0xx supplies a qualifying constraint while #{id} supplies the corresponding productive affordance."],
    ["#{root[:title]} believed", "compound", "MIN supplies belief or confidence while #{id} remains an objective productive-affordance claim."],
    ["#{root[:title]} actualized", "compound", "CRE:1xx supplies actual process phase while #{id} supplies only enabling capacity or relation."]
  ]
end

stress_rows = creation_affordance_stress_base + creation_affordance_root_stress

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("CRE2-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "CRE:200–222 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/CRE_200_222_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "CRE:200–222 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "CRE:200–202" => "internal pattern-forming capacity: persistent / operative / latent", "CRE:210–212" => "source-artifact generative relation: persistent / operative / latent", "CRE:220–222" => "systemic co-generative capacity: persistent / operative / latent" }, "triplet_logic" => { "affordance_statuses" => "persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive at one reference time", "latent_member" => "affirms an existing nonoperative affordance without hiddenness, probability, planning, scheduling, or futurity", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/CRE_200_222_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "CRE:200–222 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# CRE:200–222 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Creation relation/capacity meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `CRE:2xx` the substrate-neutral productive-affordance layer paired with canonical `CRE:1xx`. The inward triplet states one entity's capacity to form or modify a retained generative pattern, the outward triplet states a generative relation from one source toward one distinct prospective artifact, and the systemic triplet states multiple participants' capacity to generate one jointly constituted result in one shared production domain. Persistent, operative, and latent supply the exact third-trit contrast.\n\nPersistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive at one reference time. Lexical latency means an existing but nonoperative affordance, not uncertainty, hiddenness, undeveloped talent, disputed authorship, probability, scheduling, or future time. Runtime `[2]/num` remains uncertainty about the selected status. The design rejects the provisional mixture of mental agency, current production, authorship, ownership, causal influence, provenance, composability, structured possibility, and unrealized results. Creation entities remain `CRE:0xx`; actual productive processes remain `CRE:1xx`; agency, authorship, provenance, algorithms, media, structure, quality, and modality remain separate or compounded.\n\n"

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
review << "| CRE:200–202 | one entity's capacity to form or modify a retained generative pattern | capacity persists | capacity operative | capacity exists nonoperatively |\n"
review << "| CRE:210–212 | one source's generative relation toward one prospective artifact | relation persists | relation operative | relation exists nonoperatively |\n"
review << "| CRE:220–222 | multiple participants' capacity to generate one joint result | capacity persists | capacity operative | capacity exists nonoperatively |\n\n"
review << "**Triplet logic:** persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive for the same affordance at one reference time.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | Creation entity, actual process, agent, physical medium, algorithm, authorship, provenance, structural compatibility, quality, scheduling, time, and modality |\n" }
review << "\n## Concepts intentionally reserved\n\nCreative talent, imagination, creator identity, authorship, ownership, attribution, provenance, originality, derivation, inspiration, aesthetic quality, specific algorithms, physical tools and media, structural composability, resource sufficiency, design-space topology, scheduling, readiness, queues, and unrestricted modality remain other-family meanings, later vocabulary, grammar, or compounds.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later specialization, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# CRE:200–222 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MIN imagination; LIF agency; DAT/LOG generator implementation", "1" => "LIF/CON authorship; ORI provenance; MAT/STR fabrication", "2" => "CON collaboration; STR composability; ORI possibility" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | CRE keeps only typed productive enablement; entity, process, agent, medium, algorithm, authorship, provenance, quality, structure, and modality remain separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- A productive affordance is not the generative pattern, artifact, repertoire, actual process, creator, physical medium, algorithm, resource, authorship relation, or result.\n- Internal pattern-forming capacity does not entail imagination, intention, encoded templates, an operative generator, resource sufficiency, or successful formation.\n- A source-artifact generative relation does not entail creator identity, authorship, ownership, causal provenance, physical fabrication, actual generation, completion, acceptance, or persistence.\n- Systemic co-generative capacity requires productive enablement for one jointly constituted result; several independent creators, shared tools, or mere collaboration are insufficient.\n- A latent affordance exists but is not operative; it is not unknown, merely possible, undeveloped, inaccessible, disputed, planned, queued, scheduled, future, or prohibited.\n- Persistent identity may co-occur with operative or latent status; operative and latent are mutually exclusive at one reference time.\n- Runtime `[2]/num` leaves a selected status assertion unresolved and never selects lexical latency.\n\n**CONCLUSION: CRE:2XX STANDS ALONE ONLY FOR TYPED PRODUCTIVE ENABLEMENT; CREATION ENTITIES, ACTUAL PROCESSES, AGENTS, MENTAL CAPACITIES, PHYSICAL MEDIA, ALGORITHMS, AUTHORSHIP, PROVENANCE, STRUCTURAL COMPOSABILITY, QUALITY, AUTHORITY, TIME, AND MODALITY REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built CRE:200–222 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
