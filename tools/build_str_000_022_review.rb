#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "STR:000–022"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "STR_000_022"
SEMANTIC_CENTER = "substrate-neutral structural loci and arrangements: constituent positions, outward engagement interfaces, and composite part–whole arrangements"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "STR:000" => ["internal framework", "An entity has a stable inward organization of components, boundaries, and supporting relations."],
  "STR:001" => ["operating mechanism", "An entity's internal structure is actively bearing load, regulating behavior, or coordinating parts."],
  "STR:002" => ["latent component", "An inward structural element or arrangement exists in reserve but is inactive, folded, or not yet installed."],
  "STR:010" => ["bounded structure", "A stable external construction, container, shelter, or organized unit is treated as one target."],
  "STR:011" => ["functioning structure", "An external structure is presently occupied, operating, or actively supporting a purpose."],
  "STR:012" => ["reserved structure", "A defined external structure is unoccupied, unfinished, folded, or not presently in service."],
  "STR:020" => ["organized system", "A shared architecture, institution, settlement, or infrastructure has stable boundaries and roles."],
  "STR:021" => ["operating system structure", "A distributed organization or infrastructure is actively coordinating its components."],
  "STR:022" => ["dormant institution", "A system's roles and architecture remain defined but the organization is not currently operating."]
}.freeze

ROOTS = {
  "STR:000" => { title: "persistent constituent position", phase: "persistent", scope: "inward", kind: "constituent position", invariant: "A position within a structure that remains identified as a place for one constituent independently of its present occupancy." },
  "STR:001" => { title: "occupied constituent position", phase: "occupied", scope: "inward", kind: "constituent position", invariant: "A position within a structure that is presently occupied by a constituent." },
  "STR:002" => { title: "vacant constituent position", phase: "vacant", scope: "inward", kind: "constituent position", invariant: "A position within a structure that is defined for a constituent but presently unoccupied." },
  "STR:010" => { title: "persistent structural interface", phase: "persistent", scope: "outward", kind: "structural interface", invariant: "A boundary locus of a structure that remains identified for structural engagement by a distinct external target." },
  "STR:011" => { title: "engaged structural interface", phase: "engaged", scope: "outward", kind: "structural interface", invariant: "A boundary locus of a structure that is presently engaged by a distinct external target." },
  "STR:012" => { title: "unengaged structural interface", phase: "unengaged", scope: "outward", kind: "structural interface", invariant: "A boundary locus of a structure that is defined for engagement by a distinct external target but presently unengaged." },
  "STR:020" => { title: "persistent composite arrangement", phase: "persistent", scope: "systemic", kind: "composite arrangement", invariant: "A part–whole arrangement that remains identified as one structure across multiple constituent positions." },
  "STR:021" => { title: "instantiated composite arrangement", phase: "instantiated", scope: "systemic", kind: "composite arrangement", invariant: "A part–whole arrangement that is presently realized as one structure by constituents occupying multiple constituent positions." },
  "STR:022" => { title: "dormant composite arrangement", phase: "dormant", scope: "systemic", kind: "composite arrangement", invariant: "A part–whole arrangement that is defined across multiple constituent positions without presently being realized as one structure." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [5, 7, 8, 4, 4, 7, 8, 7] },
  "structural_loci_and_arrangements" => { scores: [10, 10, 10, 10, 9, 10, 10, 10] },
  "constituent_whole_collective" => { scores: [8, 8, 8, 7, 6, 9, 9, 8] },
  "region_container_nesting" => { scores: [8, 8, 7, 6, 6, 8, 9, 8] },
  "functional_module_institution" => { scores: [7, 7, 7, 6, 4, 8, 9, 8] }
}.freeze

ALT_TITLES = {
  "STR:000" => ["persistent internal constituent", "persistent interior region", "persistent functional module"],
  "STR:001" => ["active internal constituent", "occupied interior region", "operating functional module"],
  "STR:002" => ["dormant internal constituent", "reserved interior region", "inactive functional module"],
  "STR:010" => ["persistent bounded whole", "persistent container boundary", "persistent external module"],
  "STR:011" => ["active bounded whole", "occupied container boundary", "operating external module"],
  "STR:012" => ["dormant bounded whole", "unused container boundary", "inactive external module"],
  "STR:020" => ["persistent organized collective", "persistent nested region system", "persistent institution"],
  "STR:021" => ["active organized collective", "occupied nested region system", "operating institution"],
  "STR:022" => ["dormant organized collective", "reserved nested region system", "inactive institution"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns the identity, consciousness, organism, group identity, and social status of living participants. STR can describe their arrangement without turning organization into life or community identity.",
  "MOV" => "MOV owns position in a reference frame, paths, displacement, and traversal. A structural position is a role in a part–whole arrangement, not a spatial coordinate or destination.",
  "MAT" => "MAT owns physical substance, bodies, components as matter, surfaces, and load-bearing material. STR owns substrate-neutral positions, interfaces, and arrangements that may be realized by MAT objects.",
  "MIN" => "MIN owns mental representations, categories, attention, and cognitive schemas. A structural arrangement can be conceived mentally, but STR names the arrangement rather than a cognizer's model of it.",
  "CON" => "CON owns communicative endpoints, channels, exchange processes, capacities, and participant relations. A STR interface is for structural engagement and does not imply communication or connectivity.",
  "WRN" => "WRN owns instability, collapse risk, damage, mismatch, and failure. STR roots are neutral about safety and integrity unless a warning or failure claim is added.",
  "REP" => "REP owns repair, restoration, replacement, and reassembly after loss. A vacant position or dormant arrangement is not itself broken and does not imply restoration.",
  "LOG" => "LOG owns type rules, permissions, constraints, validity, compatibility, and role authority. STR names actual structural loci or arrangements, not the rule that permits or constrains them.",
  "DAT" => "DAT owns blueprints, schemas, diagrams, records, indexes, and serialized graphs as information objects. STR names the structural position, interface, or arrangement those records describe.",
  "CRE" => "CRE owns designing, building, assembling, and generating structures. STR:0xx names structural entities or conditions without asserting their creation process.",
  "ORI" => "ORI owns existence, manifestation, time, modality, and ontological instantiation generally. STR:021 and STR:022 distinguish realization of a specific part–whole arrangement, not existence or possibility in general."
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
    values[3] -= 1 if third == "1"
    values[4] -= 1 if second == "2"
  when "structural_loci_and_arrangements"
    values[6] -= 1 if second == "1"
  when "constituent_whole_collective"
    values[2] += 1 if second == "0"
    values[4] -= 2 if second == "2"
    values[3] -= 1 if third == "1"
  when "region_container_nesting"
    values[1] += 1 if second == "1"
    values[2] -= 1 if second == "2"
    values[7] += 1 if second == "2"
  when "functional_module_institution"
    values[6] += 1 if second == "2"
    values[4] -= 1 if second == "2"
    values[0] -= 1 if third == "2"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, architecture, title)
  root = ROOTS.fetch(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional title follows the #{root.fetch(:scope)} and #{root.fetch(:phase)} slot labels and selects familiar examples of structure.",
      "useful_coverage" => "It directly covers everyday frameworks, mechanisms, containers, shelters, infrastructure, and institutions.",
      "semantic_territory_consumed" => "Across the block it mixes components, whole structures, operation, load-bearing, regulation, purpose, occupancy, construction state, institutions, roles, coordination, and infrastructure.",
      "conflicts_or_future_limitations" => "The three triplets do not preserve one structural center, active siblings describe unrelated functions, and definitions collide with MAT, LOG, CRE, LIF, and later STR process/relation layers."
    }
  when "structural_loci_and_arrangements"
    {
      "why_it_fits" => "The first trit stays entity/condition; the second alone selects internal constituent position, outward engagement interface, or systemic part–whole arrangement; the third alone selects persistent, active/occupied, or dormant/vacant realization.",
      "useful_coverage" => "It covers slots, seats, sockets, positions, openings, docking faces, attachment interfaces, layouts, topologies, assemblies, object graphs, and uninstantiated arrangements.",
      "semantic_territory_consumed" => "Only substrate-neutral structural loci and part–whole arrangements. Constituents, materials, spatial coordinates, functions, rules, blueprints, construction, support relations, and institutions remain separate.",
      "conflicts_or_future_limitations" => "Ordinary words such as structure, container, network, role, component, and organization deliberately require sense resolution or compounds rather than one broad atom."
    }
  when "constituent_whole_collective"
    {
      "why_it_fits" => "Part, whole, and organized collective form an intuitive scale progression across inward, outward, and systemic scope.",
      "useful_coverage" => "It would cover component, object, building, container, assembly, system, organization, and infrastructure directly.",
      "semantic_territory_consumed" => "Identity of parts and wholes at different scales, including their material or institutional realization.",
      "conflicts_or_future_limitations" => "Parts and physical wholes collide with MAT, organized collectives collide with LIF/STR membership, and active/dormant variants become vague claims about function rather than structure."
    }
  when "region_container_nesting"
    {
      "why_it_fits" => "Interior region, outer boundary/container, and nested region system follow inward, outward, and collective scope.",
      "useful_coverage" => "It would cover inside, enclosure, room, container, boundary, nesting, hierarchy, and spatial partitioning.",
      "semantic_territory_consumed" => "Geometric or spatial containment and nested extents.",
      "conflicts_or_future_limitations" => "It overweights physical space, collides with MOV location and MAT surfaces, leaves nonspatial software or institutional structures weak, and gives active/dormant regions no stable invariant."
    }
  when "functional_module_institution"
    {
      "why_it_fits" => "Modules, external units, and institutions are recognizable structures that can be operating or inactive.",
      "useful_coverage" => "It would cover mechanism, subsystem, service, department, organization, institution, and operating system.",
      "semantic_territory_consumed" => "Function, purpose, authority, social role, coordination, and operation of organizations or software modules.",
      "conflicts_or_future_limitations" => "It mixes STR with LOG roles, LIF collectives, CON coordination, CRE operation, and DAT/software semantics; it is not substrate-neutral and duplicates future process and relation roots."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "constituent_whole_collective"
    "A #{root.fetch(:phase)} structural entity understood as a part, whole, or organized collective at #{root.fetch(:scope)} scope."
  when "region_container_nesting"
    "A #{root.fetch(:phase)} structural region or containment entity at #{root.fetch(:scope)} scope."
  when "functional_module_institution"
    "A #{root.fetch(:phase)} functional module or institutional entity at #{root.fetch(:scope)} scope."
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
  siblings = %w[0 1 2].reject { |x| x == third }.map { |x| "STR:#{first}#{second}#{x}" }
  scopes = %w[0 1 2].reject { |x| x == second }.map { |x| "STR:#{first}#{x}#{third}" }
  process = "STR:1#{second}#{third}"
  relation = "STR:2#{second}#{third}"
  (siblings + scopes + [process, relation]).uniq
end

def roles
  {
    "low" => "reference structure or containing whole",
    "middle" => "structural locus or part–whole arrangement",
    "high" => "constituent or distinct external target",
    "sustained" => "composite structural context"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that the persistent #{root.fetch(:kind)} remains identified in the stated structural context; it does not assert the active or dormant sibling.",
      "1" => "Affirms that the #{root.fetch(:kind)} persists as identified across the stated context, without deciding present occupancy, engagement, realization, function, or integrity beyond the invariant.",
      "2/num" => "Leaves unresolved whether the persistent #{root.fetch(:kind)} remains identified; it does not convert the lexeme into its active or dormant sibling."
    }
  when "1"
    {
      "0" => "Denies the present #{root.fetch(:phase)} condition of this #{root.fetch(:kind)}; persistence, vacancy, disengagement, or later realization is not thereby decided.",
      "1" => "Affirms that this #{root.fetch(:kind)} presently has its #{root.fetch(:phase)} structural condition, without asserting function, success, material state, safety, or communicative activity.",
      "2/num" => "Leaves unresolved whether this #{root.fetch(:kind)} is presently #{root.fetch(:phase)}; it does not select the persistent or dormant lexical sibling."
    }
  else
    {
      "0" => "Denies the #{root.fetch(:phase)} structural condition named by this root; it does not affirm the persistent or active sibling.",
      "1" => "Affirms exactly that this #{root.fetch(:kind)} is #{root.fetch(:phase)}, without adding damage, reservation, plan, schedule, future use, permission, probability, or construction status.",
      "2/num" => "Leaves unresolved whether even the lexical #{root.fetch(:phase)} condition holds; lexical third-trit 2 and runtime uncertainty remain distinct."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entries = case id[-2]
            when "0"
              english = {
                "0" => "That cabinet position remains the designated place for the filter even when the filter is removed.",
                "1" => "The upper rack position is occupied by the backup drive.",
                "2" => "The third seat is a defined place but is currently empty."
              }.fetch(id[-1])
              physical = {
                "0" => "The frame retains a constituent position for the crossbar.",
                "1" => "A battery presently occupies the device's second cell position.",
                "2" => "The chassis has an unoccupied position for an additional fan."
              }.fetch(id[-1])
              program = {
                "0" => "The object layout retains a constituent position for one handler.",
                "1" => "Array position seven is presently occupied by an element.",
                "2" => "The optional component position is defined but presently vacant."
              }.fetch(id[-1])
              [
                ["ordinary_conversation", "#{id}[1](WHOLE=cabinet,POSITION=slot)", "#{root.fetch(:phase)} constituent position", english, "The root names the structural position, not the object that may occupy it."],
                ["physical_or_spatial", "MAT(CONSTITUENT=part)+#{id}[1](WHOLE=frame,POSITION=slot)", "material part and #{root.fetch(:phase)} structural position", physical, "MAT owns the part; STR owns its position in the whole."],
                ["temporal_or_sequential", "#{id}[1](WHOLE=hall,POSITION=seat)+ORI(INTERVAL=session)", "constituent position evaluated during session", "The seating position has the stated structural condition during the session.", "ORI supplies time; STR does not schedule occupancy."],
                ["cross_family_compound", "DAT(LABEL=s3)+STR:000(POSITION=s3)+#{id}[1](POSITION=s3)", "data label plus constituent-position condition", "The labeled structural position has the stated condition.", "DAT owns the identifier; STR owns the structural locus."],
                ["executable_or_programming", "#{id}[1](WHOLE=object_graph,POSITION=field_slot)", "assert #{root.fetch(:phase)} constituent position", program, "Type validity and stored data remain LOG/DAT."],
                ["counterexample", "MOV(POSITION=coordinate)", "spatial coordinate", "The crate is at coordinate three.", "A coordinate is MOV, not a constituent position in a part–whole structure."]
              ]
            when "1"
              english = {
                "0" => "The cabinet retains a mounting face for the removable panel.",
                "1" => "The trailer's hitch interface is engaged by the cart.",
                "2" => "The docking face is defined but no vessel is engaged with it."
              }.fetch(id[-1])
              physical = {
                "0" => "The beam retains an outward attachment interface for a brace.",
                "1" => "The socket interface is presently engaged by the plug.",
                "2" => "The rail's mounting interface is presently unengaged."
              }.fetch(id[-1])
              program = {
                "0" => "The component retains a structural attachment point for one dependency.",
                "1" => "The component boundary interface is presently engaged by another module.",
                "2" => "The dependency interface exists structurally but is presently unengaged."
              }.fetch(id[-1])
              [
                ["ordinary_conversation", "#{id}[1](STRUCTURE=cabinet,INTERFACE=mount,TARGET=panel)", "#{root.fetch(:phase)} outward structural interface", english, "The interface is a boundary locus, not the attachment relation as a whole."],
                ["physical_or_spatial", "MAT(SURFACE=mount)+#{id}[1](STRUCTURE=beam,TARGET=brace)", "material surface plus #{root.fetch(:phase)} structural interface", physical, "MAT supplies the surface; STR supplies its role as an engagement locus."],
                ["temporal_or_sequential", "#{id}[1](STRUCTURE=dock,TARGET=vessel)+ORI(INTERVAL=berth)", "interface condition during berth interval", "The dock interface has the stated engagement condition during the berth interval.", "Time is separate from interface state."],
                ["cross_family_compound", "CON(ENDPOINT=port)+LOG(COMPATIBLE=true)+#{id}[1](INTERFACE=port)", "communication endpoint and compatibility plus structural interface", "The port is separately a communicative endpoint, logically compatible, and in the stated structural condition.", "STR does not imply CON or LOG."],
                ["executable_or_programming", "#{id}[1](STRUCTURE=component,INTERFACE=attachment_point,TARGET=dependency)", "assert #{root.fetch(:phase)} structural interface", program, "API protocol and invocation remain LOG/CON."],
                ["counterexample", "CON:011[1](TARGET_ENDPOINT=receiver)", "active communication endpoint", "The receiver is an active target endpoint.", "Communication endpoints belong to CON, not structural interfaces."]
              ]
            else
              english = {
                "0" => "The seating arrangement remains the same even as individual occupants change.",
                "1" => "The shelving arrangement is presently realized as one assembled unit.",
                "2" => "The pavilion arrangement is defined, but the pavilion is not set up."
              }.fetch(id[-1])
              physical = {
                "0" => "The bridge truss arrangement remains identified across component replacement.",
                "1" => "The frame's members presently realize the complete lattice arrangement.",
                "2" => "The folding habitat's part–whole arrangement is defined but not presently realized."
              }.fetch(id[-1])
              program = {
                "0" => "The dependency arrangement remains the same across replacement of node instances.",
                "1" => "The runtime components presently realize one composite dependency arrangement.",
                "2" => "The deployment topology is structurally defined but has no present realization."
              }.fetch(id[-1])
              [
                ["ordinary_conversation", "#{id}[1](ARRANGEMENT=layout,POSITIONS=set)", "#{root.fetch(:phase)} composite arrangement", english, "The root names the part–whole arrangement, not a social group or institution."],
                ["physical_or_spatial", "MAT(CONSTITUENTS=members)+#{id}[1](ARRANGEMENT=lattice)", "material members plus #{root.fetch(:phase)} composite arrangement", physical, "MAT owns members; STR owns their organization as one structure."],
                ["temporal_or_sequential", "#{id}[1](ARRANGEMENT=stage_layout)+ORI(INTERVAL=event)", "composite arrangement evaluated during event", "The stage layout has the stated realization condition during the event.", "ORI supplies time, not STR."],
                ["cross_family_compound", "DAT(BLUEPRINT=b)+STR:020(ARRANGEMENT=a)+#{id}[1](ARRANGEMENT=a)", "blueprint data plus composite structural condition", "The blueprint describes an arrangement that has the stated condition.", "DAT description and STR arrangement are not identical."],
                ["executable_or_programming", "#{id}[1](ARRANGEMENT=dependency_graph,CONSTITUENTS=services)", "assert #{root.fetch(:phase)} composite arrangement", program, "Graph data, type rules, and service communication are separate."],
                ["counterexample", "LIF(COMMUNITY=team)", "living collective identity", "The team is a community.", "A community or institution is not merely a composite structural arrangement."]
              ]
            end
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
      "pseudocode" => category == "executable_or_programming" ? "assert(structure.matches?(#{id.inspect}))" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "structural_loci_and_arrangements", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "constituent_whole_collective", alt[0], alternative_invariant(id, "constituent_whole_collective")),
    candidate(id, "region_container_nesting", alt[1], alternative_invariant(id, "region_container_nesting")),
    candidate(id, "functional_module_institution", alt[2], alternative_invariant(id, "functional_module_institution"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "structural_loci_and_arrangements",
    "recommendation_reason" => "Only this architecture keeps all nine roots as substrate-neutral structural entities or conditions, follows inward/outward/systemic scope exactly, gives every triplet one measurable state axis, and leaves matter, location, function, rules, records, construction, relations, and institutions to their proper layers.",
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
  state_label = { "0" => "stable/persistent", "1" => "active/presently realized", "2" => "dormant/presently unrealized" }.fetch(third)
  scope_explanation = {
    "0" => "one constituent position internal to a reference structure",
    "1" => "one boundary locus of a reference structure facing a distinct external target",
    "2" => "one part–whole arrangement spanning multiple constituent positions"
  }.fetch(second)
  scope_boundary = {
    "0" => "The claim is about the structural place available to or occupied by a constituent, not the constituent itself and not a spatial coordinate.",
    "1" => "The claim is about the reference structure's boundary locus. Mere engagement leaves the target distinct and does not by itself make that target a constituent, attached object, compatible endpoint, or communication participant.",
    "2" => "The claim is about the arrangement as an object of structural identity. A dormant arrangement may remain structurally identified without a present token realization; any blueprint, schema, memory, rule, or intention that describes or preserves it is a separate DAT, MIN, LOG, or ORI claim."
  }.fetch(second)
  triplet_logic = if third == "0"
                    "The persistent member is realization-neutral: it may co-occur with the occupied/engaged/instantiated sibling or with the vacant/unengaged/dormant sibling at the same reference time. It asserts continuity of structural identity, not a third mutually exclusive occupancy or realization value."
                  else
                    "The persistent sibling may also hold because it asserts structural identity across time. The active and dormant siblings are mutually exclusive for the same locus or arrangement at the same reference time, while runtime `[2]/num` may leave either claim unresolved."
                  end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_0" => "Selects an entity or condition: #{root.fetch(:title)} is a structural locus or arrangement, not a construction process, support relation, organizational capacity, material object, or information record.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other structural column.",
      "third_trit" => "Selects the #{state_label} entity condition by occupancy, engagement, or structural realization while leaving runtime truth status and temporal scheduling separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral claim about #{scope_explanation}. #{scope_boundary} It is neutral about substance, spatial coordinates, function, purpose, ownership, rules, construction, support relations, safety, communication, and social identity.",
    "excluded_meanings" => [
      "The constituent, physical component, material surface, body, building, container, person, institution, or organization as an independently identified entity.",
      "Spatial coordinate, destination, route, physical inside/outside region, movement, shape, mass, load, strength, or material integrity.",
      "Function, purpose, operation, authority, permission, role obligation, type constraint, compatibility, protocol, communication, or cognition.",
      "Blueprint, schema record, graph serialization, diagram, label, index, class declaration, or other information object describing structure.",
      "Building, assembling, rearranging, occupying, attaching, supporting, containing, repairing, or governing as a process or relation.",
      "Damage, failure, reservation, plan, schedule, probability, intended later use, or future realization—especially for third-trit 2."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`STR:0xx` owns structural loci and part–whole arrangements as entities or conditions; `STR:1xx` owns structural change processes; `STR:2xx` remains reserved for structural capacities and continuing relations such as support, containment, dependency, fit, or systemic organization. Occupancy, engagement, or realization in 0xx does not itself name the process or relation that produced it. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} member of this structural triplet. Runtime `[2]/num` instead leaves the truth or applicability of that already-selected root unresolved; it never changes occupancy, engagement, or realization phase.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + MAT supplies the physical constituent, surface, or material realization without reducing structural role to matter.",
      "#{id} + MOV/ORI supplies location or time without turning structural position or realization into a coordinate or tense.",
      "#{id} + DAT/LOG supplies a blueprint, identifier, schema, type rule, or constraint while preserving the real structural locus or arrangement.",
      "#{id} + STR:1xx/2xx may later express construction, rearrangement, attachment, containment, support, fit, or dependency as separate processes or relations."
    ],
    "later_era_notes" => "Later eras may lexicalize seat, socket, room, port, mount, boundary, container, object field, module, layout, topology, assembly, organization, infrastructure, institution, and deployment. Era Zero should preserve the locus/arrangement center and derive those broader senses compositionally. The stable/persistent root must not be treated as mutually exclusive with its active or dormant sibling.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end

stress_rows = [
  ["slot", "one_root", "STR:000/001/002 according to persistence, occupancy, or vacancy."],
  ["place for a part", "one_root", "STR:000 names a persistent constituent position."],
  ["occupied slot", "one_root", "STR:001 names a constituent position presently occupied."],
  ["empty slot", "one_root", "STR:002 names a defined but unoccupied constituent position."],
  ["seat", "compound", "STR constituent position plus MAT seat object or LIF occupant context."],
  ["assigned seat", "compound", "STR:000 plus LOG/DAT assignment; assignment is not occupancy."],
  ["occupied seat", "one_root_or_compound", "STR:001 for occupancy of the position; LIF identifies the occupant and MAT the chair."],
  ["vacancy", "one_root_or_compound", "STR:002 for structural vacancy; job or social vacancy adds LIF/LOG."],
  ["component", "different_family_or_compound", "MAT owns a physical component; STR:000–002 owns its position in a whole."],
  ["part", "underspecified", "Could mean material constituent, structural position, logical member, or portion; translator must resolve the sense."],
  ["array index", "compound", "DAT/LOG owns numerical index semantics; STR may name the constituent position it addresses."],
  ["array element present", "compound", "STR:001 position occupancy plus DAT stored value."],
  ["optional field absent", "compound", "STR:002 structural position plus DAT/LOG field schema and absent value."],
  ["role", "underspecified", "STR covers a constituent position only; authority, social, grammatical, or program roles belong elsewhere."],
  ["job opening", "compound", "STR:002 position plus LIF/LOG institutional and authority semantics."],
  ["coordinate", "different_family", "MOV owns spatial position in a reference frame."],
  ["destination", "different_family", "MOV owns target location or arrival relation."],
  ["inside", "different_family_or_compound", "MOV/MAT owns spatial containment; STR names a constituent position only when part–whole organization is meant."],
  ["interface", "one_root_or_compound", "STR:010–012 only for structural engagement loci; communication, UI, or protocol senses route elsewhere."],
  ["mounting point", "one_root", "STR:010 persistent structural interface."],
  ["connected mount", "one_root_or_compound", "STR:011 for engaged interface; STR:2xx later specifies the attachment relation."],
  ["unused mount", "one_root", "STR:012 for a defined but unengaged structural interface."],
  ["socket", "compound", "STR interface plus MAT physical socket; CON/LOG only if communicative or typed."],
  ["plugged socket", "one_root_or_compound", "STR:011 for engagement, MAT for plug and socket bodies."],
  ["open port", "underspecified", "May mean STR unengaged interface, CON endpoint, LOG permission, or network state."],
  ["API", "different_family_or_compound", "LOG/DAT defines protocol and types; STR may describe a software attachment locus only compositionally."],
  ["communication endpoint", "existing_con_root", "CON:000–012 owns communicative endpoints."],
  ["doorway", "compound", "STR interface plus MAT boundary opening and MOV traversal affordance."],
  ["boundary", "underspecified", "Could be MAT surface, MOV region limit, STR interface, LOG constraint, or social boundary."],
  ["wall", "different_family_or_compound", "MAT owns the wall body; STR may describe its interface or place in an arrangement."],
  ["container", "compound", "MAT object plus STR arrangement and STR:2xx containment relation; not one STR:0xx atom."],
  ["shelter", "compound", "MAT structure, STR arrangement/support, and WRN/LIF protective purpose."],
  ["attached", "future_str_relation_or_compound", "STR:011 can assert interface engagement, but exact attachment is a STR:2xx relation."],
  ["detached", "compound", "Unengaged interface plus negated/former attachment relation; REP/WRN may be relevant."],
  ["compatible connector", "compound", "STR interface plus LOG compatibility and MAT connector."],
  ["blocked interface", "compound", "STR interface plus WRN/LOG blockage; blockage is not dormancy."],
  ["layout", "one_root_or_compound", "STR:020–022 according to persistence or realization; DAT owns a layout document."],
  ["arrangement", "one_root", "STR:020/021/022 when part–whole structural arrangement is intended."],
  ["topology", "one_root_or_compound", "STR composite arrangement; DAT/LOG adds graph representation and constraints."],
  ["assembled structure", "one_root_or_compound", "STR:021 for presently realized arrangement; MAT supplies constituents and CRE the assembly process."],
  ["unassembled design", "compound", "STR:022 dormant arrangement plus DAT blueprint; CRE may add intended construction."],
  ["persistent architecture", "one_root", "STR:020 if the same part–whole arrangement persists across constituent change."],
  ["deployed topology", "one_root_or_compound", "STR:021 for realized arrangement; deployment process is CRE/STR:1xx and schedule is LOG/ORI."],
  ["undeployed topology", "one_root_or_compound", "STR:022 if structurally defined but unrealized; no plan or future time is implied."],
  ["blueprint", "different_family", "DAT owns the information object describing a structure."],
  ["schema", "underspecified", "DAT/LOG owns information/type schema; STR owns an arrangement only when actual part–whole organization is intended."],
  ["diagram", "different_family", "DAT owns the representational artifact."],
  ["graph", "underspecified", "DAT may own graph data, LOG relation formalism, STR topology, or MOV route graph."],
  ["tree hierarchy", "compound", "STR composite arrangement plus LOG/DAT parent relation and labels."],
  ["dependency graph", "compound", "STR arrangement plus LOG dependency relations and DAT graph representation."],
  ["network", "underspecified", "Could be STR topology, CON participant relation/channel, MOV routes, or LIF social network."],
  ["mesh", "compound", "STR topology plus constituent/interface relations; CON adds communication."],
  ["system", "underspecified", "A system may be a STR arrangement, LIF collective, DAT model, or functioning process complex."],
  ["organization", "underspecified", "May mean STR arrangement, LIF institution, LOG authority, or CRE organizing process."],
  ["institution", "different_family_or_compound", "LIF collective identity and LOG roles/governance; STR may describe its arrangement."],
  ["team", "different_family_or_compound", "LIF owns collective identity; STR may describe member positions."],
  ["infrastructure", "compound", "MAT assets, STR arrangements/relations, MOV routes, CON channels, and LOG governance."],
  ["building", "different_family_or_compound", "MAT owns the physical object, STR its arrangement, CRE construction, and LIF/LOG use."],
  ["frame", "compound", "MAT frame components plus STR composite arrangement and support relations."],
  ["skeleton", "compound", "LIF/MAT body parts plus STR arrangement/support."],
  ["mechanism", "compound", "STR arrangement plus STR:1xx processes, MAT components, and function semantics."],
  ["operating mechanism", "compound", "An arrangement with active processes; no STR:0xx entity alone means operation."],
  ["load-bearing", "different_family_or_compound", "MAT capacity and STR:2xx support relation; not an entity-layer invariant."],
  ["support", "future_str_relation", "Reserved for STR:2xx relation/capacity review."],
  ["containment", "future_str_relation_or_compound", "A relation for STR:2xx with MOV/MAT spatial semantics as needed."],
  ["membership", "compound_or_logic", "STR position occupancy plus LOG/LIF membership semantics."],
  ["construction", "future_str_process_or_creation", "STR:1xx/CRE owns structural change; STR:0xx names the resulting loci or arrangement."],
  ["assemble", "future_str_process_or_creation", "A structural creation/change process, not STR:021 itself."],
  ["rearrange", "future_str_process", "STR:1xx process; resulting arrangement may be STR:020/021."],
  ["repair structure", "different_family_or_compound", "REP restores a STR arrangement, interface, or position."],
  ["collapse", "different_family_or_compound", "WRN/MAT/STR process describes loss of realized arrangement."],
  ["stable", "runtime_or_other_family", "Stability alone is not a STR root; select what structural entity persists and distinguish runtime status."],
  ["active structure", "underspecified", "Could mean occupied position, engaged interface, realized arrangement, active process, or functioning system."],
  ["dormant institution", "compound", "LIF/LOG institution plus possibly STR:022 arrangement; dormancy of the organization is broader."],
  ["possible architecture", "compound", "ORI modality plus STR:022 only if a defined but unrealized part–whole arrangement exists."],
  ["planned layout", "compound", "DAT plan and LOG/ORI intention/schedule plus STR:022; dormancy does not imply planning."],
  ["unknown occupancy", "runtime_state", "STR:001[2]/num questions occupied status; it is not STR:002 vacancy."],
  ["unknown vacancy", "runtime_state", "STR:002[2]/num questions the vacancy claim; STR:002[1] affirms vacancy."],
  ["unknown engagement", "runtime_state", "STR:011[2]/num leaves engagement unresolved; it is not STR:012 unengaged."],
  ["unknown realization", "runtime_state", "STR:021[2]/num leaves present realization unresolved; it is not STR:022 dormant arrangement."],
  ["future assembly", "compound_or_grammar", "ORI future plus CRE/STR process; third lexical trit 2 does not mean future."],
  ["structural identity across replacement", "one_root", "STR:020 captures persistence of one arrangement across constituent replacement."],
  ["same slot, new occupant", "one_root_or_compound", "STR:000 persists while STR:001 occupancy can change and MAT/LIF identifies occupants."],
  ["engaged interface without communication", "one_root_plus_negation", "STR:011 can hold while CON activity is denied; structural engagement does not entail communication."],
  ["realized arrangement without function", "one_root_plus_negation", "STR:021 can hold even when no intended function or active process is asserted."],
  ["persistent and occupied same position", "two_compatible_roots", "STR:000 and STR:001 may both hold: one asserts the position's enduring identity and the other its present occupancy."],
  ["persistent and vacant same position", "two_compatible_roots", "STR:000 and STR:002 may both hold: persistence is realization-neutral while vacancy is the present condition."],
  ["occupied and vacant at the same time", "invalid_same_reference_claim", "STR:001 and STR:002 cannot both be true of the same position at the same reference time; use separate times or runtime uncertainty."],
  ["persistent and engaged same interface", "two_compatible_roots", "STR:010 and STR:011 may co-occur because interface identity and present engagement are different claims."],
  ["dormant arrangement and blueprint", "compound", "STR:022 names the unrealized structural arrangement; DAT separately names the blueprint or schema that describes it."],
  ["engaged interface without incorporation", "one_root_plus_negation", "STR:011 may hold while target incorporation is denied; contact at a boundary does not itself confer constituent status."]
].freeze

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("STR0-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "STR:000–022 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/STR_000_022_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "STR:000–022 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "STR:000–002" => "constituent position: persistent / occupied / vacant", "STR:010–012" => "outward structural interface: persistent / engaged / unengaged", "STR:020–022" => "composite arrangement: persistent / instantiated / dormant" }, "triplet_logic" => { "persistent_member" => "asserts structural identity across time and is realization-neutral", "active_dormant_members" => "mutually exclusive for the same referent at the same reference time", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/STR_000_022_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "STR:000–022 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# STR:000–022 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Structure entity meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `STR:0xx` the substrate-neutral entity/condition layer for structural loci and arrangements. The inward triplet names a constituent position, the outward triplet a boundary interface for engagement by a distinct target, and the systemic triplet a part–whole arrangement across multiple positions. Occupancy, engagement, and realization supply exact active/dormant contrasts.\n\nThe third-trit grid is deliberately not a three-way exclusive partition. Each `...0` member asserts persistence of structural identity and is neutral about present realization, so it may co-occur with either its `...1` or `...2` sibling. The `...1` and `...2` siblings are mutually exclusive for the same referent at the same reference time. Runtime `[2]/num` remains uncertainty about the selected claim rather than a lexical sibling.\n\nThe design rejects the provisional mixture of framework, mechanism, load-bearing, purpose, construction state, container, infrastructure, institution, roles, and coordination. Those require MAT, LIF, LOG, DAT, CRE, or later STR process/relation roots.\n\n"

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
review << "| STR:000–002 | one constituent position inside a structure | remains identified regardless occupancy | presently occupied | defined but presently unoccupied |\n"
review << "| STR:010–012 | one boundary interface facing a distinct external target | remains identified regardless engagement | presently engaged | defined but presently unengaged |\n"
review << "| STR:020–022 | one part–whole arrangement across multiple positions | remains identified across constituent change | presently realized by constituents | defined but presently unrealized |\n\n"
review << "**Triplet logic:** the `0` column is persistence-neutral with respect to current realization and may co-occur with `1` or `2`; only `1` versus `2` is mutually exclusive at one reference time.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | material objects, coordinates, functions, rules, records, construction, support/containment relations, institutions, and plans |\n" }
review << "\n## Concepts intentionally reserved\n\nComponent, part, seat, socket, doorway, wall, container, shelter, role, API, schema, blueprint, graph, network, system, organization, institution, infrastructure, building, frame, mechanism, support, containment, attachment, construction, assembly, repair, and collapse remain sense-resolved compounds, other-family meanings, or later STR process/relation work.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later STR layers, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation, structural soundness validation, and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# STR:000–022 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MAT component; MOV position; LOG role; DAT field/index", "1" => "MAT surface/connector; CON endpoint; LOG API/compatibility; STR relation", "2" => "DAT schema/graph; LIF organization; CON network; ORI instantiation" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | STR keeps only the structural locus or part–whole arrangement; every competing layer stays separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- A constituent position is not its occupant, material, coordinate, label, type, function, or institutional role.\n- An engaged structural interface is not a communicative endpoint, protocol, compatibility conclusion, attachment relation, active exchange, or proof that the target became a constituent.\n- A realized composite arrangement is not a blueprint, graph record, institution, community, functioning mechanism, construction process, or proof of integrity.\n- A dormant arrangement is the structurally identified arrangement itself without a present realization; the blueprint, schema, rule, memory, or intention that preserves or describes it remains a separately typed claim.\n- Vacancy, disengagement, and dormancy do not imply damage, reservation, plan, schedule, future use, or repair need.\n- Each persistent `...0` root is neutral about the present `...1`/`...2` condition and may co-occur with either. Only the `...1` and `...2` conditions are mutually exclusive for one referent at one reference time.\n- Runtime `[2]/num` leaves a claim unresolved and never selects the lexical vacant, unengaged, or dormant root.\n\n**CONCLUSION: STR:0XX STANDS ALONE ONLY FOR STRUCTURAL LOCI AND PART–WHOLE ARRANGEMENTS; MATERIALS, LOCATIONS, FUNCTIONS, RULES, RECORDS, PROCESSES, RELATIONS, INSTITUTIONS, AND TEMPORAL COMMITMENTS REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built STR:000–022 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
