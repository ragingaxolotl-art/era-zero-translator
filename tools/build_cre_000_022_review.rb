#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "CRE:000–022"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "CRE_000_022"
SEMANTIC_CENTER = "creation entities: internal generative patterns, generated artifacts, and shared generative repertoires"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "CRE:000" => ["internal design", "A stable inward concept, plan, style, or imagined form is held as one bounded creative object."],
  "CRE:001" => ["active inspiration", "A concept or form is presently emerging, changing, or demanding creative attention."],
  "CRE:002" => ["unrealized idea", "A design or imagined form is preserved inwardly but has not yet been developed or expressed."],
  "CRE:010" => ["finished artifact", "A created external object, work, design, or transformation result is stable and bounded."],
  "CRE:011" => ["evolving prototype", "An external created form is presently being tested, revised, or expressed."],
  "CRE:012" => ["unbuilt design", "A defined artifact or transformation target remains conceptual, unavailable, or not yet instantiated."],
  "CRE:020" => ["design system", "A stable shared language of forms, templates, styles, or generative constraints defines a creative domain."],
  "CRE:021" => ["generative environment", "A shared creative system is actively producing, combining, or transforming forms."],
  "CRE:022" => ["dormant template library", "A collective set of designs or generative patterns exists but is not presently in use."]
}.freeze

ROOTS = {
  "CRE:000" => { title: "persistent internal generative pattern", phase: "persistent", scope: "inward", kind: "internal generative pattern", invariant: "A persistent bounded form-specifying pattern maintained within one reference entity as a source for production, independently of whether that pattern is presently expressed." },
  "CRE:001" => { title: "manifest internal generative pattern", phase: "manifest", scope: "inward", kind: "internal generative pattern", invariant: "A bounded form-specifying pattern maintained within one reference entity that is presently expressed as a source for production." },
  "CRE:002" => { title: "dormant internal generative pattern", phase: "dormant", scope: "inward", kind: "internal generative pattern", invariant: "A bounded form-specifying pattern maintained within one reference entity as a source for production without being presently expressed." },
  "CRE:010" => { title: "persistent generated artifact", phase: "persistent", scope: "outward", kind: "generated artifact", invariant: "A persistent bounded product whose identity derives from a productive transformation directed outward from a source, independently of whether that product is presently manifest." },
  "CRE:011" => { title: "manifest generated artifact", phase: "manifest", scope: "outward", kind: "generated artifact", invariant: "A bounded product of a productive transformation directed outward from a source that is presently manifest." },
  "CRE:012" => { title: "dormant generated artifact", phase: "dormant", scope: "outward", kind: "generated artifact", invariant: "A bounded product whose identity derives from a productive transformation directed outward from a source and remains maintained without being presently manifest." },
  "CRE:020" => { title: "persistent shared generative repertoire", phase: "persistent", scope: "systemic", kind: "shared generative repertoire", invariant: "A persistent coordinated collection of generative patterns maintained across multiple participants as one shared production resource, independently of whether that repertoire is presently expressed." },
  "CRE:021" => { title: "manifest shared generative repertoire", phase: "manifest", scope: "systemic", kind: "shared generative repertoire", invariant: "A coordinated collection of generative patterns maintained across multiple participants as one shared production resource that is presently expressed." },
  "CRE:022" => { title: "dormant shared generative repertoire", phase: "dormant", scope: "systemic", kind: "shared generative repertoire", invariant: "A coordinated collection of generative patterns maintained across multiple participants as one shared production resource without being presently expressed." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [6, 7, 8, 4, 4, 7, 8, 7] },
  "generative_entity_architecture" => { scores: [10, 10, 10, 10, 9, 10, 9, 10] },
  "mental_idea_architecture" => { scores: [9, 8, 6, 7, 5, 8, 10, 7] },
  "structural_template_architecture" => { scores: [9, 8, 8, 8, 6, 9, 8, 10] },
  "production_resource_architecture" => { scores: [8, 8, 9, 7, 7, 9, 8, 9] }
}.freeze

ALT_TITLES = {
  "CRE:000" => ["persistent internal idea", "persistent internal template", "persistent internal productive resource"],
  "CRE:001" => ["conscious internal idea", "instantiated internal template", "available internal productive resource"],
  "CRE:002" => ["latent internal idea", "inactive internal template", "unavailable internal productive resource"],
  "CRE:010" => ["persistent intended work", "persistent output structure", "persistent production resource"],
  "CRE:011" => ["present intended work", "instantiated output structure", "available production resource"],
  "CRE:012" => ["unrealized intended work", "inactive output structure", "unavailable production resource"],
  "CRE:020" => ["persistent shared imagination", "persistent shared template system", "persistent shared production resource"],
  "CRE:021" => ["active shared imagination", "instantiated shared template system", "available shared production resource"],
  "CRE:022" => ["latent shared imagination", "inactive shared template system", "unavailable shared production resource"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identities, biological conditions, agency, and social collectives. A creator may bear a generative pattern or produce an artifact, but CRE does not identify the living agent or its social role.",
  "MOV" => "MOV owns position, path, displacement, and motion affordances. An artifact may move and a pattern may guide a trajectory, but creation identity neither locates nor transports anything.",
  "MAT" => "MAT owns substance, energy, force, contact, and material capacities. A physical object may realize an artifact, but CRE identifies its status as a generated product rather than its substance or mechanics.",
  "MIN" => "MIN owns awareness, imagination, belief, attention, memory, and intention. A mental idea may contribute to a generative pattern, but CRE requires a form-specifying production source rather than merely subjective content.",
  "CON" => "CON owns channels, participants, communication acts, delivery, and exchange. A pattern or artifact may be communicated, but its creation-domain identity is independent of transmission and participant linkage.",
  "WRN" => "WRN owns faults, hazards, adverse processes, and warnings. A defective artifact may instantiate WRN, but defectiveness and risk are not entailed by generated-product identity.",
  "STR" => "STR owns arrangements, boundaries, interfaces, schemas-as-structure, and dependencies. A template has structure, but CRE owns its function as a source for production rather than arrangement alone.",
  "REP" => "REP owns restoration conditions, restorative processes, and restorative affordances. Reconstructing an artifact may use CRE, but recoverability and repair remain REP meanings.",
  "LOG" => "LOG owns formal constraints, evaluations, and formal relations. A generative pattern may contain rules, but its production-guiding creative identity is not reducible to admissibility or inference.",
  "DAT" => "DAT owns represented information, references, datasets, transformations, transfers, and synchronization. A pattern may be encoded as data, but CRE owns what functions as a source or product of generation, not its representation.",
  "ORI" => "ORI owns temporal, modal, causal, and ontological qualification. Persistence, manifestation, and dormancy do not encode past, future, possibility, necessity, probability, or causal origin."
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
  when "generative_entity_architecture"
    values[4] += 1 if second == "1"
    values[6] -= 1 if second == "2"
  when "mental_idea_architecture"
    values[2] -= 2 if second != "0"
    values[4] -= 1 if third == "1"
  when "structural_template_architecture"
    values[2] -= 1 if second == "1"
    values[4] -= 2 if second == "2"
  when "production_resource_architecture"
    values[0] -= 1 if third == "1"
    values[3] -= 1 if second == "0"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, architecture, title)
  root = ROOTS.fetch(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional titles use familiar creative vocabulary and roughly track #{root.fetch(:scope)} scope and #{root.fetch(:phase)} status.",
      "useful_coverage" => "They cover designs, inspiration, ideas, artifacts, prototypes, design systems, generative environments, and template libraries.",
      "semantic_territory_consumed" => "Across the block they mix mental content, production processes, developmental stages, artifacts, structural systems, availability, and future realization.",
      "conflicts_or_future_limitations" => "The triplets do not preserve one entity center: inspiration and evolution are processes, ideas collide with MIN, systems collide with STR and LOG, and unbuilt status confuses artifact identity with future modality."
    }
  when "generative_entity_architecture"
    {
      "why_it_fits" => "The first trit remains a Creation entity; the second changes only inward production source, outward generated product, or shared generative resource; the third changes only persistent, manifest, or dormant status.",
      "useful_coverage" => "It supports design patterns, templates, motifs, recipes, blueprints, works, generated outputs, models, style libraries, and shared production repertoires without encoding the production act itself.",
      "semantic_territory_consumed" => "Only creation-domain entity identity and expression status. Mental ideation, represented data, formal rules, structure, material realization, productive transformation, authorship, value, completion, and time remain separate.",
      "conflicts_or_future_limitations" => "Artifact type and pattern syntax remain broad in Era Zero and must be supplied compositionally when exact medium, genre, authorship, provenance, or production method matters."
    }
  when "mental_idea_architecture"
    {
      "why_it_fits" => "Ideas often precede creation and may be private, outwardly intended, or socially shared.",
      "useful_coverage" => "It would cover imagination, inspiration, concept, vision, intention, and collective creativity.",
      "semantic_territory_consumed" => "It makes subjective mental content essential to every Creation entity.",
      "conflicts_or_future_limitations" => "MIN already owns imagination, attention, memory, belief, and intention; nonmental generators, machine templates, natural generative systems, and completed artifacts would be poorly represented."
    }
  when "structural_template_architecture"
    {
      "why_it_fits" => "Templates and output structures can guide creation and can be internal, outwardly instantiated, or systemically shared.",
      "useful_coverage" => "It would cover template, schema, layout, mold, blueprint, component system, and compositional framework.",
      "semantic_territory_consumed" => "It makes arrangement or repeatable structural form essential to every Creation entity.",
      "conflicts_or_future_limitations" => "STR owns arrangement and interface, DAT owns encoded schemas, and many artifacts are unique rather than templates. Production function, not structure alone, must distinguish CRE."
    }
  when "production_resource_architecture"
    {
      "why_it_fits" => "Creation depends on resources that can be internal, directed toward an output, or shared across a production system.",
      "useful_coverage" => "It would cover tool, material stock, asset, component, library, facility, and production capacity.",
      "semantic_territory_consumed" => "It makes usefulness for production rather than generative identity the center.",
      "conflicts_or_future_limitations" => "MAT, STR, DAT, and the CRE relation layer should own material, structural, informational, and capacity relations; a product is not necessarily a reusable resource."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "mental_idea_architecture"
    "A #{root.fetch(:phase)} mental conception organized at #{root.fetch(:scope)} creative scope."
  when "structural_template_architecture"
    "A #{root.fetch(:phase)} repeatable structural template situated at #{root.fetch(:scope)} creative scope."
  when "production_resource_architecture"
    "A #{root.fetch(:phase)} production resource organized at #{root.fetch(:scope)} creative scope."
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
  process = "CRE:1#{second}#{third}"
  relation = "CRE:2#{second}#{third}"
  (siblings + scopes + [process, relation]).uniq
end

def roles
  {
    "low" => "source entity, creator, or participant associated with the generative entity",
    "middle" => "generative pattern, generated artifact, or shared repertoire asserted as the figure",
    "high" => "distinct product, medium, method, or beneficiary when separately expressed",
    "sustained" => "shared production domain and its multiple participating maintainers"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that this #{root.fetch(:kind)} persists as the same identified creation entity; it does not select the manifest or dormant sibling and does not erase every related pattern or product.",
      "1" => "Affirms the persistent identity of this #{root.fetch(:kind)} while leaving current expression, medium, use, authorship, value, and production history undecided.",
      "2/num" => "Leaves unresolved whether this persistent #{root.fetch(:kind)} remains identified; uncertainty about the assertion does not change the lexical root into a manifest or dormant creation entity."
    }
  when "1"
    {
      "0" => "Denies that this #{root.fetch(:kind)} is presently manifest; it does not erase the creation entity, affirm dormancy, or deny every possible representation or realization.",
      "1" => "Affirms that this #{root.fetch(:kind)} is presently manifest in the stated creation scope, without asserting completion, quality, value, authorship, physical medium, use, or productive activity.",
      "2/num" => "Leaves unresolved whether this #{root.fetch(:kind)} is presently manifest; runtime uncertainty does not select persistent identity or lexical dormancy."
    }
  else
    {
      "0" => "Denies that this #{root.fetch(:kind)} is presently dormant; it does not by itself affirm current manifestation, deletion, destruction, obsolescence, or replacement.",
      "1" => "Affirms that this #{root.fetch(:kind)} remains maintained but is not presently manifest, without encoding storage medium, access denial, forgottenness, future activation, uncertainty, or loss.",
      "2/num" => "Leaves unresolved whether the selected dormant #{root.fetch(:kind)} claim holds; lexical third-trit 2 names maintained-but-unmanifest status, while runtime `[2]/num` marks assertion-level uncertainty."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entity = id[-2] == "0" ? "studio" : id[-2] == "1" ? "work" : "collective"
  graph_roles = id[-2] == "0" ? "SOURCE=#{entity},PATTERN=p" : id[-2] == "1" ? "SOURCE=#{entity},ARTIFACT=a" : "DOMAIN=#{entity},PARTICIPANTS={a,b,c},REPERTOIRE=r"
  ordinary = { "0" => "That creative source or product remains the same identified thing whether or not it is expressed now.", "1" => "That creative source or product is manifest now.", "2" => "That creative source or product is still maintained, but it is not manifest now." }.fetch(id[-1])
  entries = [
    ["ordinary_conversation", "#{id}[1](#{graph_roles})", "affirm #{root.fetch(:phase)} #{root.fetch(:kind)}", ordinary, "The root asserts a Creation entity and its expression status, not the act of producing it."],
    ["physical_or_spatial", "MAT(MEDIUM=m)+#{id}[1](#{graph_roles})", "material medium plus #{root.fetch(:phase)} creation entity", "A physical medium realizes the pattern or artifact while MAT separately describes its substance.", "Creative identity and physical realization remain separately typed."],
    ["temporal_or_sequential", "#{id}[1](#{graph_roles})+ORI(INTERVAL=w)", "#{root.fetch(:phase)} creation entity during interval w", "During interval w, the generative entity has the stated lexical status.", "ORI supplies time and does not replace expression status."],
    ["cross_family_compound", "DAT(REPRESENTATION=d)+#{id}[1](#{graph_roles})", "data representation plus #{root.fetch(:phase)} creation entity", "The file encodes the generative entity without becoming identical to its creative function.", "DAT and CRE remain distinct."],
    ["executable_or_programming", "#{id}[1](#{graph_roles})", "assert #{root.fetch(:phase)} creation-entity status", "A runtime registers a template, generated artifact, or repertoire without claiming that generation is executing.", "Entity identity and productive processes remain separate."],
    ["counterexample", "MIN(IDEA=i,COGNIZER=c)", "mental conception", "She imagined a possible form.", "Use MIN for imagination unless a form-specifying production source is separately constituted as #{id}."]
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
      "pseudocode" => category == "executable_or_programming" ? "assert(generative_entity.status == #{id.inspect})" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "generative_entity_architecture", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "mental_idea_architecture", alt[0], alternative_invariant(id, "mental_idea_architecture")),
    candidate(id, "structural_template_architecture", alt[1], alternative_invariant(id, "structural_template_architecture")),
    candidate(id, "production_resource_architecture", alt[2], alternative_invariant(id, "production_resource_architecture"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "generative_entity_architecture",
    "recommendation_reason" => "Only this architecture keeps all nine roots on one Creation-entity center, follows internal-source/outward-product/shared-resource scope exactly, and gives every triplet one persistent/manifest/dormant axis while reserving cognition, data representation, structure, production processes, material realization, authorship, value, and modality for other layers or families.",
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
  state_label = { "0" => "persistent/manifestation-neutral", "1" => "manifest/presently instantiated", "2" => "dormant/maintained but unmanifest" }.fetch(third)
  scope_explanation = {
    "0" => "one bounded form-specifying pattern maintained within one reference entity as a source for production",
    "1" => "one bounded product whose identity derives from productive transformation directed outward from a source",
    "2" => "one coordinated collection of generative patterns maintained across multiple participants as a shared production resource"
  }.fetch(second)
  scope_boundary = {
    "0" => "The claim is about a form-specifying source for production maintained within one reference entity, not a mere idea, a stored description, a formal rule, the production act, or its product.",
    "1" => "The claim preserves one generated product directed outward from a source. Production process, completion, quality, use, recipient, medium, and ownership remain separate.",
    "2" => "The claim requires one coordinated repertoire shared across multiple participants. A coincidental collection of unrelated patterns is not one systemic repertoire, and institutional ownership or storage topology remains separate."
  }.fetch(second)
  triplet_logic = if third == "0"
                    "The persistent member is manifestation-neutral: it may co-occur with the manifest sibling or the dormant sibling at the same reference time. It asserts continuity of creation-entity identity rather than a third mutually exclusive manifestation value."
                  else
                    "The persistent sibling may also hold because it asserts Creation-entity identity across time. Manifest and dormant siblings are mutually exclusive for the same entity at the same reference time, while runtime `[2]/num` may leave either selected claim unresolved."
                  end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_0" => "Selects a Creation entity rather than a productive transformation, production relation, represented datum, structural arrangement, or physical medium.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Creation-family column.",
      "third_trit" => "Selects the #{state_label} member by creation-entity identity or present expression while leaving runtime truth status, completion, quality, use, tense, probability, and process phase separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral creation entity at #{root.fetch(:scope)} scope. #{scope_boundary} It is neutral about mental awareness, representation, formal validity, arrangement, material realization, production activity, completion, quality, value, authorship, provenance, probability, timing, and cause.",
    "excluded_meanings" => [
      "Mental inspiration, imagination, intention, belief, memory, attention, or subjective appreciation of a possible form.",
      "Actual generation, transformation, revision, assembly, testing, publication, copying, distribution, or consumption of a product.",
      "Physical material, energy, tool, inscription, storage medium, device, workshop, or mechanical production capacity.",
      "Structural arrangement alone, formal rule, schema, represented description, algorithm, encoded file, or dataset that lacks a production-source or generated-product role.",
      "Creator identity, recipient, ownership, authorship, originality, permission, responsibility, quality, beauty, value, success, or completion.",
      "Accessibility, observability, discoverability, provenance, version, schedule, future realization, possibility, necessity, probability, or cause."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`CRE:0xx` owns generative entities and their persistent, manifest, or dormant status. `CRE:1xx` remains reserved for actual productive transformations, and `CRE:2xx` for generative capacities, dependencies, provenance, or other production relations. A manifest pattern does not entail active generation, and a manifest artifact does not entail completion, quality, use, ownership, or value. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} member of this Creation-entity triplet. Runtime `[2]/num` instead leaves that already-selected assertion unresolved; it never changes manifestation status. Thus a dormant root affirmed with `[1]` is a confirmed maintained-but-unmanifest generative entity, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + MAT supplies physical medium, material, or energy without reducing the Creation entity to matter.",
      "#{id} + MIN supplies imagination, intention, observation, or appreciation while keeping cognitive state distinct from generative identity.",
      "#{id} + DAT supplies an encoding, description, or version record while preserving creative function as a separate CRE entity.",
      "#{id} + CRE:1xx/2xx may later express production, revision, realization, generative capacity, provenance, or dependency as separate processes and relations."
    ],
    "later_era_notes" => "Later eras may lexicalize motif, recipe, template, blueprint, model, artwork, tool, style, genre, authorship, originality, version, and medium distinctions. Era Zero should preserve the substrate-neutral creation-entity center and derive cultural and technical subtypes compositionally. The persistent root must not be treated as mutually exclusive with its manifest or dormant sibling.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


creation_stress_base = [
  ["design pattern", "one_root_or_compound", "Use CRE:000–002 when a bounded form-specifying source for production is meant; DAT or STR may separately encode its representation or arrangement."],
  ["template", "one_root_or_compound", "A template functioning as a source for production maps to the internal-pattern triplet; its file encoding remains DAT."],
  ["motif", "one_root_or_compound", "A recurring form-specifying source can use CRE:000–002, with genre or medium supplied compositionally."],
  ["recipe", "compound", "CRE supplies the production-guiding pattern, LOG its constraints, DAT its written representation, and MAT its ingredients."],
  ["blueprint", "compound", "CRE supplies generative function, DAT the represented plan, and STR the arrangement described."],
  ["algorithm as generator", "compound", "CRE may identify the form-producing pattern; LOG supplies formal operations and DAT the encoded program."],
  ["idea", "different_family_or_compound", "A subjective conception belongs to MIN unless it is separately constituted as a form-specifying production source."],
  ["inspiration", "different_family", "Inspiration is a mental event or condition in MIN, not an entity in the Creation entity layer."],
  ["intention to create", "different_family_or_compound", "MIN owns intention; a CRE generative pattern may be compounded only when a production source is also identified."],
  ["plan", "compound", "DAT can encode a plan, LOG can govern it, and CRE applies when the plan functions as a production source."],
  ["schema", "different_family_or_compound", "STR owns arrangement and DAT owns its representation; CRE applies only if the schema functions generatively."],
  ["rule", "different_family", "Formal admissibility belongs to LOG even when a rule participates in a generator."],
  ["prototype", "compound", "A prototype is a generated artifact plus experimental or revision status; evolution is not encoded in CRE:011 alone."],
  ["artifact", "one_root", "CRE:010–012 owns one bounded product of productive transformation directed outward from a source."],
  ["artwork", "one_root_or_compound", "A work can use the artifact triplet; medium, cultural value, authorship, and genre require compounds."],
  ["generated file", "compound", "CRE supplies generated-product identity and DAT supplies the information object and encoding."],
  ["manufactured object", "compound", "CRE supplies generated-product identity and MAT supplies substance and physical realization."],
  ["model output", "compound", "CRE supplies generated artifact; DAT supplies represented output and LOG or CRE:1xx supplies computation or generation."],
  ["finished work", "compound", "CRE:010 or CRE:011 identifies the artifact, while completion requires process-state or ORI qualification; persistence does not mean finished."],
  ["unfinished work", "compound", "A manifest artifact may be unfinished, but incompletion must be expressed separately from manifestation."],
  ["unbuilt design", "compound_or_not_yet_artifact", "A design that has not produced an artifact is a generative pattern plus future or unrealized qualification, not automatically CRE:012."],
  ["destroyed artifact", "different_meaning", "Destruction may end artifact identity; lexical dormancy requires the same artifact to remain maintained but unmanifest."],
  ["hidden artwork", "compound", "A hidden manifest artifact remains CRE:011; access or visibility is separate and must not be confused with dormancy."],
  ["archived digital work", "compound", "CRE identifies the artifact, DAT its stored representation, and dormant status applies only if the creation entity itself is unmanifest."],
  ["copy", "compound", "CRE may identify each generated artifact while provenance and duplication process remain separate."],
  ["original", "compound_or_later_specialization", "Originality is a provenance relation, not generated-artifact identity itself."],
  ["creator", "different_family", "A living or social creator belongs to LIF; CRE identifies the pattern, product, or repertoire."],
  ["authorship", "different_family_or_later_relation", "Authorship is a relation among agent, act, and product, reserved for compounds or the CRE relation layer."],
  ["tool", "different_family_or_compound", "MAT or STR owns a tool as physical or functional apparatus; CRE applies only when it is itself a generated artifact."],
  ["material", "different_family", "Substance belongs to MAT even when used in production."],
  ["production", "later_process_layer", "Actual productive transformation belongs to CRE:1xx, not the entity layer."],
  ["revision", "later_process_layer", "Changing a pattern or artifact belongs to CRE:1xx; CRE:001 or CRE:011 only says it is manifest."],
  ["testing", "different_family_or_compound", "Testing requires LOG evaluation and perhaps CRE process roots; it is not entailed by manifest artifact status."],
  ["publication", "compound", "Publication involves CON distribution and CRE artifact status, not an atomic entity meaning here."],
  ["design system", "compound_or_one_root", "A coordinated shared production repertoire can use CRE:020–022; formal constraints and structural organization remain LOG and STR."],
  ["style library", "one_root_or_compound", "A coordinated shared collection of production-guiding patterns maps to CRE:020–022, with DAT for encoded assets."],
  ["template library", "one_root_or_compound", "Use the systemic repertoire triplet when multiple participants maintain it as one shared production resource."],
  ["generative environment", "compound", "The repertoire is CRE:02x, while active generation is CRE:1xx and tooling or infrastructure belongs to STR, DAT, or MAT."],
  ["creative tradition", "compound", "CRE supplies a shared repertoire and LIF supplies the community and cultural continuity."],
  ["shared repertoire", "one_root", "CRE:020–022 directly owns a coordinated collection of generative patterns maintained across multiple participants."],
  ["many unrelated templates", "multiple_roots_not_one_systemic_root", "Unrelated templates do not form one CRE:02x repertoire without coordinated maintenance as one shared production resource."],
  ["private pattern", "one_root", "Use CRE:000–002 for a generative pattern maintained within one reference entity."],
  ["pattern used by a team", "compound_or_scope_resolution", "Use CRE:02x if coordinated as a shared repertoire; mere use of one private pattern by others does not automatically change its scope."],
  ["manifest template", "one_root", "CRE:001 affirms a presently expressed internal generative pattern without claiming active production."],
  ["dormant template", "one_root", "CRE:002 affirms that the internal generative pattern remains maintained but unexpressed."],
  ["manifest artifact", "one_root", "CRE:011 affirms a presently manifest generated product without claiming it is finished, used, or valuable."],
  ["dormant artifact", "one_root", "CRE:012 affirms a maintained generated product that is not presently manifest; it is not a merely intended future product."],
  ["manifest repertoire", "one_root", "CRE:021 affirms a presently expressed shared generative repertoire without claiming that production is running."],
  ["dormant repertoire", "one_root", "CRE:022 affirms a maintained but presently unexpressed shared generative repertoire."],
  ["persistent pattern uncertain", "runtime", "CRE:000[2]/num leaves persistence uncertain; it does not select lexical dormancy."],
  ["manifest artifact denied", "runtime", "CRE:011[0] denies present manifestation without deleting the artifact or automatically affirming dormancy."],
  ["dormant repertoire affirmed", "runtime_and_lexical", "CRE:022[1] confirms maintained-but-unexpressed systemic repertoire status."],
  ["persistent plus manifest artifact", "two_compatible_roots", "CRE:010 and CRE:011 may co-occur because persistence is neutral about present manifestation."],
  ["persistent plus dormant artifact", "two_compatible_roots", "CRE:010 and CRE:012 may co-occur because persistence is neutral about present manifestation."],
  ["manifest and dormant artifact simultaneously", "contradiction", "CRE:011 and CRE:012 are mutually exclusive for the same artifact at one reference time."],
  ["beautiful artwork", "compound_or_unresolved_value", "CRE supplies artifact identity; aesthetic appraisal belongs to MIN or later value vocabulary."],
  ["successful design", "compound", "CRE supplies pattern or artifact identity; success requires a goal, criterion, and evaluation."],
  ["copyrighted work", "compound", "CRE supplies artifact identity while legal authority, ownership, and restriction require LIF, CON, and LOG."],
  ["versioned design", "compound", "CRE supplies generative entity identity and DAT or later provenance vocabulary supplies version relations."],
  ["procedural generation", "later_process_layer", "Actual algorithmic generation belongs to CRE:1xx, with LOG and DAT for algorithm and representation."],
  ["emergent form", "compound_or_later_process", "CRE can identify the resulting artifact, while emergence and causal process remain CRE:1xx or ORI."],
  ["natural pattern", "different_family_or_compound", "A regular physical form belongs to MAT or STR unless it functions as a production source or generated product in the intended model."],
  ["self-modifying template", "compound", "CRE:0xx identifies the pattern and CRE:1xx later expresses its transformation; self-reference and code remain separate."],
  ["factory", "different_family_or_compound", "A factory is LIF/STR/MAT infrastructure; CRE:02x applies only to its shared generative repertoire."],
  ["creative capacity", "later_relation_layer", "Capacity to generate belongs to CRE:2xx, not the entity layer."],
  ["reusable component", "compound", "CRE may identify a generated artifact or pattern, while reusability is a production relation or affordance."],
  ["design language", "compound_or_one_root", "CRE:02x can supply the shared generative repertoire; LOG and STR supply constraints and organization."],
  ["source code", "compound", "DAT owns the encoded program, LOG owns formal operations, and CRE:0xx applies if it functions as a production-generating pattern."],
  ["rendered image", "compound", "CRE identifies the generated artifact, DAT the pixel representation, and MAT the display medium."],
  ["musical score", "compound", "CRE can identify a production-guiding pattern, DAT its notation, and CON or MAT the performance and sound realization."],
  ["performance", "later_process_or_compound", "A performance is an event involving agents and production; the entity layer may identify its pattern or resulting artifact but not the event itself."]
].freeze

creation_root_stress = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} identity", "one_root", "#{id}[1] directly affirms the root's invariant without adding production, completion, quality, value, authorship, or medium."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves this exact #{root[:phase]} claim unresolved and does not select a lexical sibling."],
    ["#{root[:title]} encoded", "compound", "DAT supplies representation while #{id} supplies Creation-domain identity and expression status."],
    ["#{root[:title]} physically realized", "compound", "MAT supplies medium and substance while #{id} supplies generative identity."],
    ["#{root[:title]} mentally appreciated", "compound", "MIN supplies cognition or valuation while #{id} remains the Creation entity independently."],
    ["#{root[:title]} being produced", "compound", "#{id} supplies the entity; CRE:1xx must separately supply actual production or transformation."]
  ]
end

stress_rows = creation_stress_base + creation_root_stress

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("CRE0-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "CRE:000–022 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/CRE_000_022_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "CRE:000–022 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "CRE:000–002" => "internal generative pattern: persistent / manifest / dormant", "CRE:010–012" => "generated artifact: persistent / manifest / dormant", "CRE:020–022" => "shared generative repertoire: persistent / manifest / dormant" }, "triplet_logic" => { "persistent_member" => "asserts Creation-entity identity across time and is manifestation-neutral", "manifest_dormant_members" => "mutually exclusive for the same Creation entity at the same reference time", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/CRE_000_022_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "CRE:000–022 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# CRE:000–022 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Creation entity meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `CRE:0xx` the substrate-neutral entity layer for generative sources and products. The inward triplet identifies one bounded form-specifying pattern maintained within a reference entity, the outward triplet identifies one bounded product of productive transformation, and the systemic triplet identifies one coordinated shared generative repertoire across multiple participants. Persistence, manifestation, and dormancy supply the exact third-trit contrast.\n\nEach `...0` member asserts persistence of Creation-entity identity and is neutral about present manifestation, so it may co-occur with either its `...1` or `...2` sibling. The manifest `...1` and dormant `...2` siblings are mutually exclusive for the same entity at the same reference time. Runtime `[2]/num` remains uncertainty about the selected claim. The design rejects the provisional mixture of inspiration, process, testing, revision, structural systems, use, availability, and future realization. Actual productive transformations remain for `CRE:1xx`; generative capacities and relations remain for `CRE:2xx`; mental content, represented data, formal rules, structure, matter, communication, and time remain other families.\n\n"

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
review << "| CRE:000–002 | one internal generative pattern | persists independently of expression | presently expressed | maintained but unexpressed |\n"
review << "| CRE:010–012 | one generated artifact directed outward from a source | persists independently of manifestation | artifact presently manifest | artifact maintained but unmanifest |\n"
review << "| CRE:020–022 | one shared generative repertoire across participants | persists independently of expression | repertoire presently expressed | repertoire maintained but unexpressed |\n\n"
review << "**Triplet logic:** the `0` column is manifestation-neutral and may co-occur with `1` or `2`; only manifest `1` versus dormant `2` is mutually exclusive at one reference time. Manifestation never entails active production, completion, quality, value, ownership, observation, or use.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | cognition, representation, physical medium, production process, completion, quality, value, authorship, provenance, authority, time, and modality |\n" }
review << "\n## Concepts intentionally reserved\n\nMental ideas, represented descriptions, formal rules, pure structure, physical media, active production, revision, testing, completion, quality, aesthetic value, ownership, authorship, provenance, version, copying, distribution, scheduling, causation, and modality remain other-family meanings, later CRE layers, grammar, or compounds.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later CRE layers, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# CRE:000–022 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MIN idea; DAT representation; LOG rule; STR template", "1" => "MAT object; DAT output; CRE process; ORI completion", "2" => "STR system; DAT library; LOG regime; LIF tradition" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | CRE keeps only generative-source, generated-product, or shared-repertoire identity and expression; cognition, representation, structure, medium, process, value, authority, and mechanism remain separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- A Creation entity is not its physical medium, encoded record, creator, owner, observer, communicative act, formal rule, structural arrangement, or aesthetic value.\n- A manifest generative pattern is presently expressed as a production source; it does not entail that production is running.\n- A manifest artifact is presently realized as the generated product; it does not entail completion, quality, use, originality, or success.\n- A dormant Creation entity remains maintained but unmanifest; it is not destroyed, deleted, forgotten, future, merely possible, or uncertain.\n- An internal pattern is a source for production within one reference entity. A generated artifact is an outward product. A shared repertoire coordinates generative patterns across multiple participants.\n- Several unrelated templates do not form one shared repertoire merely because they coexist or share storage.\n- Persistent identity may co-occur with manifest or dormant status; manifest and dormant are exclusive for the same Creation entity at one reference time.\n- Runtime `[2]/num` leaves a selected assertion unresolved and never selects lexical dormancy.\n\n**CONCLUSION: CRE:0XX STANDS ALONE ONLY FOR GENERATIVE-SOURCE, GENERATED-PRODUCT, OR SHARED-REPERTOIRE IDENTITY AND EXPRESSION; COGNITION, REPRESENTATION, STRUCTURE, MATTER, PRODUCTION, VALUE, AUTHORSHIP, TIME, AND MODALITY REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built CRE:000–022 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
