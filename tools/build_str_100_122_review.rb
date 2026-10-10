#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "STR:100–122"
STEM = "STR_100_122"
IDS = EraZeroValidation.ids_for_range(RANGE)
SEMANTIC_CENTER = "substrate-neutral structural transformation: internal reconfiguration, target incorporation, and multi-structure integration"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "STR:100" => ["self-organization complete", "An inward arrangement, reinforcement, or reorganization has reached a stable finished form."],
  "STR:101" => ["active self-organization", "An entity is actively arranging, stabilizing, or restructuring its own components."],
  "STR:102" => ["queued reorganization", "An inward structural change is planned or possible but has not begun."],
  "STR:110" => ["construction complete", "The assembly, enclosure, or organization of an external target has reached its intended form."],
  "STR:111" => ["active construction", "Components are actively being assembled, enclosed, ordered, or installed into an external target."],
  "STR:112" => ["planned construction", "Work on a structure or organized target is designed or staged but not yet active."],
  "STR:120" => ["system deployment complete", "A shared architecture or organization has completed a defined build, rollout, or reorganization."],
  "STR:121" => ["system organization", "Components, roles, or boundaries are actively being coordinated across a larger system."],
  "STR:122" => ["staged system deployment", "A system-wide build or organizational change is prepared but has not begun."]
}.freeze

ROOTS = {
  "STR:100" => ["completed internal reconfiguration", "Completion of a structural transformation that changes how a reference structure's own constituents occupy its internal positions."],
  "STR:101" => ["active internal reconfiguration", "An ongoing structural transformation that changes how a reference structure's own constituents occupy its internal positions."],
  "STR:102" => ["potential internal reconfiguration", "A nonactualized structural transformation that would change how a reference structure's own constituents occupy its internal positions."],
  "STR:110" => ["completed target incorporation", "Completion of a structural transformation by which a distinct target becomes incorporated into a reference structure."],
  "STR:111" => ["active target incorporation", "An ongoing structural transformation by which a distinct target becomes incorporated into a reference structure."],
  "STR:112" => ["potential target incorporation", "A nonactualized structural transformation by which a distinct target would become incorporated into a reference structure."],
  "STR:120" => ["completed systemic integration", "Completion of a structural transformation by which multiple structures become organized as constituents of one composite arrangement."],
  "STR:121" => ["active systemic integration", "An ongoing structural transformation by which multiple structures become organized as constituents of one composite arrangement."],
  "STR:122" => ["potential systemic integration", "A nonactualized structural transformation by which multiple structures would become organized as constituents of one composite arrangement."]
}.freeze

SCORE_PROFILES = {
  "current_phase2" => [6, 7, 8, 5, 4, 7, 8, 8],
  "reconfiguration_incorporation_integration" => [10, 10, 10, 10, 9, 10, 10, 10],
  "physical_deformation_enclosure_assembly" => [8, 8, 7, 6, 5, 8, 9, 8],
  "schema_migration_installation_deployment" => [8, 8, 6, 7, 4, 9, 7, 10],
  "role_allocation_institutional_reorganization" => [7, 7, 6, 6, 4, 8, 9, 7]
}.freeze

ALT_TITLES = {
  "STR:100" => ["completed inward deformation", "completed local schema migration", "completed internal role reassignment"],
  "STR:101" => ["active inward deformation", "active local schema migration", "active internal role reassignment"],
  "STR:102" => ["potential inward deformation", "potential local schema migration", "potential internal role reassignment"],
  "STR:110" => ["completed enclosure of target", "completed target installation", "completed assignment of external role"],
  "STR:111" => ["active enclosure of target", "active target installation", "active assignment of external role"],
  "STR:112" => ["potential enclosure of target", "potential target installation", "potential assignment of external role"],
  "STR:120" => ["completed physical assembly", "completed system deployment", "completed institutional reorganization"],
  "STR:121" => ["active physical assembly", "active system deployment", "active institutional reorganization"],
  "STR:122" => ["potential physical assembly", "potential system deployment", "potential institutional reorganization"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identity, participant status, collectives, and institutions as social entities. STR may reorganize their structural arrangement but does not define organismic or social identity.",
  "MOV" => "MOV owns position, route, displacement, and traversal. A constituent may move during reconfiguration or incorporation, but STR names the resulting change in part–whole organization rather than its spatial path.",
  "MAT" => "MAT owns physical substance, shape, deformation, joining, and material assembly. STR abstracts the change in constituent positions and part–whole organization across physical, software, conceptual, and institutional substrates.",
  "MIN" => "MIN owns attention, belief, interpretation, and revision of a mental model. Conceiving or planning a new arrangement is mental activity; STR applies only when the structural transformation itself is asserted.",
  "CON" => "CON owns communicative exchange, participant channels, and connection relations. Coordination messages can support integration, but transmitting or agreeing is not itself structural integration.",
  "WRN" => "WRN owns instability, damage, mismatch, collapse, and risk. STR transformations are neutral about whether a prior arrangement was defective or whether the new arrangement is safe.",
  "REP" => "REP owns restoration after loss or failure. Reconfiguration and integration may be preventive, exploratory, or neutral; repair is expressed separately when restoration is essential.",
  "LOG" => "LOG owns rules, permissions, constraints, compatibility, roles, and validity. A rule may permit incorporation or integration, but STR names the actual or nonactualized structural transformation rather than its authorization.",
  "DAT" => "DAT owns blueprints, schemas, configuration records, and migrations of information representations. STR names transformation of the represented or instantiated arrangement, not editing the record that describes it.",
  "CRE" => "CRE owns generation, design, construction, and production of new entities. STR transformation may reorganize already identified structures without asserting that any constituent or whole was newly created.",
  "ORI" => "ORI owns time, modality, existence, and ontological transition. Lexical STR:1x2 selects a nonactualized structural process but does not itself encode plan, schedule, futurity, possibility strength, or eventual realization."
}.freeze

def lexical_axes(id)
  address = id.split(":").last
  scope = { "0" => "inward/self", "1" => "outward/target", "2" => "shared/systemic" }.fetch(address[1])
  phase = { "0" => "completed", "1" => "active", "2" => "nonactualized" }.fetch(address[2])
  [scope, phase]
end

def candidate_analysis(id, architecture)
  scope, phase = lexical_axes(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional choice follows the #{scope} and #{phase} slot labels and favors familiar words such as self-organization, construction, and deployment.",
      "useful_coverage" => "It offers direct everyday and technical labels for rearranging, stabilizing, building, installing, rolling out, and coordinating.",
      "semantic_territory_consumed" => "It mixes arrangement, reinforcement, stability, assembly, enclosure, installation, deployment, organizational roles, planning, staging, and queueing.",
      "conflicts_or_future_limitations" => "Triplets do not preserve one exact process, 1x2 roots improperly encode plans or queues, and definitions collide with MAT, CRE, LOG, DAT, LIF, CON, WRN, and REP."
    }
  when "reconfiguration_incorporation_integration"
    {
      "why_it_fits" => "Every address selects one substrate-neutral structural transformation; the second trit alone distinguishes internal constituent reassignment, incorporation of one distinct target, or integration of multiple structures, and the third alone selects phase.",
      "useful_coverage" => "It covers rearrange, reconfigure, insert, include, mount, onboard structurally, merge assemblies, integrate modules, compose systems, and exact graph or object-layout transformations.",
      "semantic_territory_consumed" => "Only transformation of constituent-to-position and structure-to-whole organization. Creation, physical deformation, repair, planning, rules, data descriptions, communication, and movement remain separate.",
      "conflicts_or_future_limitations" => "Broad English build, install, merge, deploy, organize, restructure, and integrate require sense analysis or compounds; this restriction is deliberate and translator-safe."
    }
  when "physical_deformation_enclosure_assembly"
    {
      "why_it_fits" => "Bending internally, enclosing a target, and physically assembling a whole are observable structural transformations with good spatial examples.",
      "useful_coverage" => "It covers fold, bend, compress, wrap, enclose, fasten, assemble, and fabricate.",
      "semantic_territory_consumed" => "Material shape change, surfaces, forces, joins, and construction operations.",
      "conflicts_or_future_limitations" => "The architecture is MAT-heavy, weak for abstract or software structure, duplicates CRE construction and REP reassembly, and makes the STR family substrate-specific."
    }
  when "schema_migration_installation_deployment"
    {
      "why_it_fits" => "Local migration, component installation, and distributed deployment mirror inward, target, and systemic scope and are technically useful.",
      "useful_coverage" => "It covers schema migration, package installation, configuration rollout, service deployment, and topology updates.",
      "semantic_territory_consumed" => "Software lifecycle, data representation, configuration records, execution environments, and operational release state.",
      "conflicts_or_future_limitations" => "It collides with DAT, LOG, CRE, and CON; it is historically narrow and would make ordinary physical and social structural transformations metaphorical extensions of software."
    }
  when "role_allocation_institutional_reorganization"
    {
      "why_it_fits" => "Internal reassignment, appointment of an outside participant, and institutional reorganization form an intuitive social-structure grid.",
      "useful_coverage" => "It covers staffing, appointing, assigning offices, restructuring departments, reorganizing teams, and governance changes.",
      "semantic_territory_consumed" => "Participant identity, social membership, authority, obligation, institutional continuity, and communicative coordination.",
      "conflicts_or_future_limitations" => "It collides with LIF, LOG, and CON, is anthropocentric, and cannot cleanly generalize to physical or computational part–whole organization."
    }
  end
end

def alternative_invariant(id, architecture)
  scope, phase = lexical_axes(id)
  case architecture
  when "physical_deformation_enclosure_assembly"
    "A #{phase} physical transformation that changes matter through #{scope} deformation, enclosure, or assembly."
  when "schema_migration_installation_deployment"
    "A #{phase} technical transformation that changes a schema, installs a target, or deploys a system at #{scope} scope."
  when "role_allocation_institutional_reorganization"
    "A #{phase} social transformation that reallocates roles or reorganizes an institution at #{scope} scope."
  end
end

def score_hash(values)
  EraZeroValidation::SCORE_KEYS.zip(values).to_h
end

def score_values(architecture, id)
  values = SCORE_PROFILES.fetch(architecture).dup
  second = id[-2]
  third = id[-1]
  case architecture
  when "current_phase2"
    values[0] -= 1 if third == "2"
    values[1] -= 1 if third == "2"
    values[4] -= 1 if second == "2"
  when "reconfiguration_incorporation_integration"
    values[6] -= 1 if third == "2"
  when "physical_deformation_enclosure_assembly"
    values[6] += 1 if second == "1"
    values[2] -= 1 if second == "0"
    values[7] -= 1 if second == "2"
  when "schema_migration_installation_deployment"
    values[7] += 1 if second == "2"
    values[6] -= 1 if second == "0"
    values[4] -= 1 if second == "1"
  when "role_allocation_institutional_reorganization"
    values[6] += 1 if second == "2"
    values[4] -= 1 if second == "2"
    values[7] -= 1 if second == "0"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate(id, architecture, title, invariant)
  scores = score_hash(score_values(architecture, id))
  {
    "candidate_id" => architecture,
    "title" => title,
    "invariant_candidate" => invariant,
    "analysis" => candidate_analysis(id, architecture),
    "scores" => scores,
    "total" => scores.values.sum,
    "maximum" => 80
  }
end

def nearest_neighbors(id)
  family, address = id.split(":")
  first, second, third = address.chars
  siblings = %w[0 1 2].reject { |value| value == third }.map { |value| "#{family}:#{first}#{second}#{value}" }
  scopes = %w[0 1 2].reject { |value| value == second }.map { |value| "#{family}:#{first}#{value}#{third}" }
  (siblings + scopes + ["#{family}:0#{second}#{third}", "#{family}:2#{second}#{third}"]).uniq
end

def role_registers
  {
    "low" => "reference structure or containing arrangement",
    "middle" => "structural transformation",
    "high" => "constituent, distinct target, or participating structure",
    "sustained" => "composite structural context"
  }
end

EXAMPLE_CONTENT = {
  "0" => {
    "ordinary" => ["closet", "clothes", "We reorganized the closet by assigning its own clothes to different positions.", "We are reorganizing the closet by assigning its own clothes to different positions.", "A reorganization of the closet's own contents is structurally available but is not occurring."],
    "physical" => ["device", "cells", "The device's existing cells were reseated into new internal positions.", "The device's existing cells are being reseated into new internal positions.", "Reseating the device's existing cells into new internal positions is nonactualized."],
    "program" => ["object_layout", "fields", "The object's existing fields completed reassignment among its internal slots.", "The object's existing fields are being reassigned among its internal slots.", "Reassignment of the object's existing fields among its internal slots is nonactualized."],
    "counter" => ["MOV(PATH=crate_route)", "crate follows a route", "The crate moved across the room.", "Movement changes spatial position but need not change any constituent-to-position assignment."]
  },
  "1" => {
    "ordinary" => ["cabinet", "new_shelf", "The new shelf became part of the cabinet's structure.", "The new shelf is becoming part of the cabinet's structure.", "Incorporation of the new shelf into the cabinet is nonactualized."],
    "physical" => ["frame", "brace", "The brace was incorporated into the frame.", "The brace is being incorporated into the frame.", "Incorporation of the brace into the frame is nonactualized."],
    "program" => ["application", "module", "The module completed incorporation into the application's component structure.", "The module is being incorporated into the application's component structure.", "Incorporation of the module into the application's component structure is nonactualized."],
    "counter" => ["CON:111[1](TARGET=module,EXPRESSION=message)", "module receiving a message", "The module is receiving a message.", "Reception does not make the module a constituent of the sender or message structure."]
  },
  "2" => {
    "ordinary" => ["workspace", "sections", "The separately organized sections became one composite workspace arrangement.", "The separately organized sections are becoming one composite workspace arrangement.", "Integration of the separate sections into one workspace arrangement is nonactualized."],
    "physical" => ["rail_network", "lines", "The independent rail-line structures were integrated as one network arrangement.", "The independent rail-line structures are being integrated as one network arrangement.", "Integration of the independent rail-line structures as one network arrangement is nonactualized."],
    "program" => ["service_system", "services", "The service structures completed integration into one composite system topology.", "The service structures are being integrated into one composite system topology.", "Integration of the service structures into one composite topology is nonactualized."],
    "counter" => ["CON:121[1](ENDPOINTS=teams,EXPRESSION=updates)", "updates distributed among teams", "The teams are exchanging updates.", "Communication among structures does not itself organize them as constituents of one composite arrangement."]
  }
}.freeze

def examples_for(id)
  address = id.split(":").last
  second, third = address[1], address[2]
  phase_index = { "0" => 2, "1" => 3, "2" => 4 }.fetch(third)
  content = EXAMPLE_CONTENT.fetch(second)
  scope_label = { "0" => "internal reconfiguration", "1" => "target incorporation", "2" => "systemic integration" }.fetch(second)
  phase_label = { "0" => "completed", "1" => "ongoing", "2" => "nonactualized" }.fetch(third)
  structure, target, ordinary = content.fetch("ordinary").values_at(0, 1, phase_index)
  physical_structure, physical_target, physical = content.fetch("physical").values_at(0, 1, phase_index)
  program_structure, program_target, program = content.fetch("program").values_at(0, 1, phase_index)
  counter_graph, counter_gloss, counter_english, counter_analysis = content.fetch("counter")
  role_key = { "0" => "CONSTITUENTS", "1" => "TARGET", "2" => "INPUT_STRUCTURES" }.fetch(second)
  scope_analysis = {
    "0" => "The reference whole is preserved and only assignments of its own constituents are changed.",
    "1" => "The named reference remains the organizing whole and one external target crosses into constituent status.",
    "2" => "The input structures are modeled as peer constituents of a higher-order whole, not as one target absorbed into one preserved reference."
  }.fetch(second)
  entries = [
    ["ordinary_conversation", "#{id}[1](STRUCTURE=#{structure},#{role_key}=#{target})", "#{phase_label} #{scope_label}", ordinary, "#{scope_analysis} The assertion does not add tidiness, usefulness, or approval."],
    ["physical_or_spatial", "MAT(OBJECT=#{physical_target})+#{id}[1](STRUCTURE=#{physical_structure},#{role_key}=#{physical_target})", "material realization plus #{phase_label} #{scope_label}", physical, "#{scope_analysis} MAT owns physical substance and force; STR owns the part–whole transformation."],
    ["temporal_or_sequential", "#{id}[1](STRUCTURE=#{structure})+ORI(INTERVAL=maintenance_window)", "#{phase_label} #{scope_label} during an explicit interval", "During the maintenance window, #{ordinary.sub(/\A./) { |letter| letter.downcase }}", "ORI supplies temporal location; lexical phase is not tense or schedule."],
    ["cross_family_compound", "DAT(BLUEPRINT=b)+LOG(PERMIT=true)+#{id}[1](STRUCTURE=#{structure},#{role_key}=#{target})", "blueprint and permission plus #{phase_label} #{scope_label}", "The blueprint and rule describe an authorized transformation; the STR process has the stated phase.", "#{scope_analysis} DAT and LOG remain separate from whether the structural transformation occurs."],
    ["executable_or_programming", "#{id}[1](STRUCTURE=#{program_structure},#{role_key}=#{program_target})", "assert #{phase_label} #{scope_label}", program, "#{scope_analysis} Data migration, dependency validity, and process success require separate DAT/LOG/WRN assertions."],
    ["counterexample", counter_graph, counter_gloss, counter_english, counter_analysis]
  ]
  entries.map do |category, graph, gloss, english, analysis|
    {
      "category" => category,
      "semantic_graph" => graph,
      "literal_gloss" => gloss,
      "natural_english" => english,
      "runtime_state" => 1,
      "contour" => category == "executable_or_programming" ? "level assertion or sharply falling execution" : "level declaration",
      "role_registers" => role_registers,
      "use_status" => category == "counterexample" ? "must_not_use_this_root" : "valid",
      "analysis" => analysis,
      "pseudocode" => category == "executable_or_programming" ? "assert(structural_process.matches?(#{id.inspect}))" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  phase2_title, phase2_definition = PHASE2.fetch(id)
  winner_title, winner_invariant = ROOTS.fetch(id)
  alternatives = ALT_TITLES.fetch(id)
  candidates = [
    ["current_phase2", phase2_title, phase2_definition],
    ["reconfiguration_incorporation_integration", winner_title, winner_invariant],
    ["physical_deformation_enclosure_assembly", alternatives[0], alternative_invariant(id, "physical_deformation_enclosure_assembly")],
    ["schema_migration_installation_deployment", alternatives[1], alternative_invariant(id, "schema_migration_installation_deployment")],
    ["role_allocation_institutional_reorganization", alternatives[2], alternative_invariant(id, "role_allocation_institutional_reorganization")]
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2")["why_it_fits"],
    "candidates" => candidates.map { |candidate_id, title, invariant| candidate(id, candidate_id, title, invariant) },
    "recommended_candidate_id" => "reconfiguration_incorporation_integration",
    "recommendation_reason" => "Only this architecture preserves one substrate-neutral STR process center, changes only scope across columns and phase across each triplet, composes directly with canonical STR:0xx loci, and avoids absorbing matter, creation, repair, data, rules, communication, or scheduling.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end

recommended_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  title, invariant = ROOTS.fetch(id)
  scope, phase = lexical_axes(id)
  second, third = id[-2], id[-1]
  process = { "0" => "internal-reconfiguration process", "1" => "target-incorporation process", "2" => "systemic-integration process" }.fetch(second)
  center = {
    "0" => "reassigns a reference structure's own constituents among its internal positions while preserving that structure as the reference whole",
    "1" => "makes one distinct external target a constituent of an already identified reference structure while that reference remains the organizing whole",
    "2" => "organizes two or more input structures as co-constituents of a higher-order composite arrangement whose whole is distinct from any single input"
  }.fetch(second)
  article = phase == "active" ? "an" : "a"
  scope_guard = {
    "0" => "Changing the structure's position inventory itself, adding an outside target, or forming a higher-order whole requires a different structural claim.",
    "1" => "The output preserves the reference structure as the containing whole; the external target crosses into constituent status. If every input instead becomes a peer constituent of a higher-order whole, use systemic integration.",
    "2" => "Every input is modeled as a peer constituent of the resulting higher-order whole. If one already identified reference remains the containing whole and only one target crosses into constituent status, use target incorporation."
  }.fetch(second)
  runtime = case third
            when "0"
              {
                "0" => "Denies that this #{process} reached completion in the stated structural context; it does not assert that the active or nonactualized sibling holds.",
                "1" => "Affirms that this #{process} reached its completed phase, without asserting success criteria, integrity, function, permanence, repair, or creation beyond the invariant.",
                "2/num" => "Leaves unresolved whether this #{process} reached completion or whether that completed result remains applicable; the lexical root stays completed."
              }
            when "1"
              {
                "0" => "Denies that this #{process} is presently ongoing or states that it has ceased; completion, reversal, and nonactualized availability remain undecided.",
                "1" => "Affirms that this #{process} is presently ongoing in the stated structural context, without guaranteeing eventual completion or fitness of the result.",
                "2/num" => "Leaves unresolved whether this #{process} is presently ongoing; the runtime marker does not select the completed or nonactualized lexical sibling."
              }
            else
              {
                "0" => "Denies that this #{process} holds even as a valid nonactualized transformation in the stated context; it does not assert activity or completion.",
                "1" => "Affirms this #{process} as nonactualized—neither ongoing nor completed—without adding plan, intention, queue, schedule, permission, readiness, probability, or future time.",
                "2/num" => "Leaves unresolved even the assertion that this #{process} is a valid nonactualized transformation; lexical nonactualization and runtime uncertainty remain distinct."
              }
            end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => title,
    "invariant_definition" => invariant,
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_1" => "Selects a structural process, action, or transformation rather than a structural locus, entity condition, capacity, or relationship.",
      "second_trit" => "Selects #{scope} scope: this root #{center}; no competing family or temporal phase is added by this axis.",
      "third_trit" => "Selects the #{phase} phase of the same #{process}; planning, queueing, schedule, futurity, permission, probability, and runtime truth status remain separate."
    },
    "inclusion_boundary" => "Includes only #{article} #{phase} substrate-neutral structural transformation that #{center}. #{scope_guard} The transformation may be realized physically, computationally, institutionally, or conceptually, but it does not itself assert motion, material change, creation, repair, communication, rule change, data migration, temporal scheduling, function, safety, or success criteria beyond achieving the invariant result for a completed root.",
    "excluded_meanings" => [
      "The constituent position, interface, composite arrangement, constituent, target, material object, participant, or data record as an entity or condition.",
      "Spatial movement, route traversal, physical deformation, joining force, enclosure, fabrication, construction, destruction, or generation as such.",
      "Planning, intention, staging, queueing, scheduling, permission, readiness, probability, futurity, obligation, or specification—especially for lexical 1x2.",
      "Repair, restoration, reinforcement, stabilization, damage correction, success, fitness, integrity, function, or operational deployment.",
      "Communication, coordination, consensus, mental reclassification, schema-document editing, role authority, or institutional identity.",
      "Support, containment, attachment, dependency, fit, membership, compatibility, or other continuing relation after the transformation."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "STR:0xx owns constituent positions, structural interfaces, and composite arrangements as entities or conditions. STR:1xx owns changes in how constituents or structures participate in those arrangements. STR:2xx remains reserved for capacities and continuing relations such as support, containment, dependency, fit, attachment, or systemic compatibility. Target incorporation is asymmetric: the reference remains the whole and one external target becomes its constituent. Systemic integration is higher-order: every input structure becomes a co-constituent of a composite distinct from any one input. A completed STR:1xx root entails only the structural result stated in its invariant at the completion reference time; it does not entail persistence, function, integrity, or any STR:2xx relation unless separately asserted.",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime,
    "lexical_runtime_distinction" => "The lexical third trit permanently selects the #{phase} member of this process triplet. Runtime `[2]/num` instead qualifies the truth, applicability, or resolution of a token of that already-selected root; it never changes the root into a planned, future, or different-phase process.",
    "catalogue_title_guard" => third == "2" ? "The word `potential` in the concise catalogue title is shorthand for the invariant's nonactualized phase only. It does not assert capability, readiness, probability, permission, intention, schedule, or future realization." : "The concise catalogue title is controlled by the invariant definition and must not be broadened with unstated result, function, or temporal semantics.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + STR:0xx identifies the constituent positions, interface, or composite arrangement transformed by the process.",
      "#{id} + MAT/MOV specifies physical constituents, forces, and displacement without reducing structural organization to matter or motion.",
      "#{id} + DAT/LOG specifies blueprint, schema, identifier, validity rule, permission, or compatibility while keeping the structural process separate.",
      "#{id} + CRE/REP/WRN distinguishes creation, repair, or failure-mitigation motives from the neutral reconfiguration, incorporation, or integration invariant."
    ],
    "later_era_notes" => "Later eras may lexicalize reorganize, install, mount, insert, absorb, merge, consolidate, assemble, deploy, refactor, restructure, and integrate as descendants or typed compounds. Era Zero must preserve the internal-reference / asymmetric-incorporation / higher-order-integration contrast and must not let nonactualized 1x2 roots acquire planning or modal-strength semantics.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end

STRESS_CONCEPTS = [
  ["rearrange", "one_root_or_compound", "STR:100/101/102 when one structure's own constituents change positions; MOV/MAT is added if physical displacement matters."],
  ["reconfigure", "one_root_or_compound", "STR internal reconfiguration by phase when constituent-position assignment changes; DAT/LOG is added for configuration records or rules."],
  ["reorder", "one_root_or_compound", "STR:1x0 for structural order of existing constituents; DAT handles ordering values in a record and ORI handles temporal sequence."],
  ["shuffle", "compound", "Internal reconfiguration plus iteration/randomness grammar; physical movement may require MOV."],
  ["rotate components", "compound", "MOV/MAT rotation plus STR internal reconfiguration only if structural positions or roles change."],
  ["refactor code", "compound", "STR internal reconfiguration of program structure plus DAT code and LOG behavioral invariants."],
  ["renovate", "compound", "STR reconfiguration plus MAT/CRE/REP according to alteration, creation, or restoration."],
  ["stabilize", "different_family_or_compound", "WRN/REP/MAT owns stability or reinforcement; STR is added only if constituent organization changes."],
  ["reinforce", "different_family_or_compound", "MAT/REP owns added strength or restoration, often with target incorporation when a brace becomes part of a structure."],
  ["fold", "different_family", "Physical deformation is MAT unless folding also changes a defined part–whole arrangement."],
  ["insert", "compound_or_one_root", "STR target incorporation when the target becomes a constituent; MOV alone covers putting an object into a spatial region."],
  ["include", "one_root_or_compound", "STR target incorporation when inclusion is structural; set membership or logical inclusion belongs to LOG."],
  ["incorporate", "one_root", "STR:110/111/112 by phase when one distinct target becomes part of a reference structure."],
  ["install", "compound", "Target incorporation plus CRE/LOG/DAT operational setup; the English word is too broad for one atom."],
  ["mount", "compound", "Target incorporation plus MAT interface and a later STR attachment/support relation."],
  ["attach", "future_str_relation_or_compound", "Attachment is a continuing STR:2xx relation; incorporation is asserted only when attachment makes the target a constituent."],
  ["enclose", "different_family_or_compound", "MAT/STR relation owns containment or boundary; enclosure is not automatically incorporation."],
  ["admit a member", "compound", "LIF/LOG membership and permission plus STR incorporation only when a structural role is instantiated."],
  ["onboard employee", "compound", "LIF participant, LOG role/authority, DAT credentials, and perhaps STR target incorporation."],
  ["add a field", "compound", "DAT schema element plus STR target incorporation into an instantiated object or schema structure."],
  ["plug in", "compound", "MOV target placement, MAT contact, STR incorporation if constituent status changes, and later STR/CON connectivity relation."],
  ["assemble", "compound_or_one_root", "STR systemic integration for multiple existing structures becoming one composite arrangement; CRE/MAT if fabrication or joining is central."],
  ["integrate", "one_root_or_compound", "STR:120/121/122 when multiple structures become constituents of one arrangement; software, social, or data senses add other families."],
  ["merge systems", "compound", "Systemic integration plus LOG/DAT identity and conflict-resolution rules; merging data values is DAT."],
  ["consolidate", "compound", "Systemic integration plus LOG decisions or MOV/MAT gathering when those senses matter."],
  ["federate", "compound", "Systemic integration of structures plus LOG autonomy rules and CON interoperation."],
  ["compose modules", "one_root_or_compound", "Systemic integration if existing module structures form one composite; CRE if modules or content are generated."],
  ["build", "different_family_or_compound", "CRE owns creation/construction; STR describes reconfiguration, incorporation, or integration only when those structural transformations are specifically asserted."],
  ["construct", "different_family_or_compound", "CRE/MAT owns physical construction; structural integration may be one component of the graph."],
  ["fabricate", "different_family", "CRE/MAT owns production of a physical artifact."],
  ["deploy", "compound", "CRE/LOG/DAT/ORI operational rollout plus STR integration when structures become one operating arrangement."],
  ["roll out", "compound", "Schedule, distribution, activation, and integration are separate; no one STR atom owns the English phrase."],
  ["organize", "underspecified_compound", "May mean internal reconfiguration, target incorporation, systemic integration, mental categorization, social coordination, or data sorting; translator must resolve the sense."],
  ["restructure", "underspecified_one_root", "Choose STR:1x0, 1x1, or 1x2 by what is structurally transformed; do not default from the English word alone."],
  ["transform", "unresolved_or_compound", "Family and structural scope must be known; generic change is not one STR atom."],
  ["transition", "different_family_or_compound", "ORI/MOV owns temporal or state transition generally; add STR only for structural organization change."],
  ["migrate schema", "different_family_or_compound", "DAT owns representation migration; STR internal reconfiguration applies only to the instantiated structural arrangement."],
  ["move a file", "different_family", "MOV/DAT owns relocation of a data object; structural incorporation applies only if it becomes a constituent of a containing structure."],
  ["join two beams", "compound", "MAT contact/join plus STR systemic integration if both beam structures become one composite arrangement."],
  ["connect networks", "compound", "CON connectivity and STR systemic integration are distinct; either may occur without the other."],
  ["coordinate teams", "different_family_or_compound", "CON/LOG owns communication and coordination; STR integration only if organizational part–whole structure changes."],
  ["reorganize department", "compound", "STR transformation plus LIF institutional identity and LOG role authority."],
  ["assign a role", "different_family", "LOG owns role assignment; it is not target incorporation unless an actual structural constituent relation changes."],
  ["schedule reorganization", "compound", "ORI/LOG schedule plus STR:102, 112, or 122 as the nonactualized process; scheduling is never inside lexical 1x2."],
  ["plan construction", "compound", "MIN/CRE/DAT plan and design; STR:1x2 may identify a nonactualized structural process without encoding the plan."],
  ["queue installation", "compound", "DAT/LOG queue status plus STR:112; the queue is not the invariant."],
  ["possible integration", "one_root_plus_grammar", "STR:122[1] affirms a nonactualized systemic integration; modality strength or probability is supplied separately."],
  ["finish reorganizing", "one_root", "STR:100 when internal constituent reassignment completed."],
  ["continue reorganizing", "one_root_plus_contour", "STR:101 plus continuation contour or timing grammar."],
  ["stop integrating", "one_root_plus_runtime_or_grammar", "Denied/ceased STR:121 plus event-boundary grammar; cessation does not itself assert STR:120."],
  ["undo incorporation", "compound", "A reverse structural process needs contour/direction plus STR target transformation; removal should not be smuggled into incorporation."],
  ["remove component", "compound_or_gap", "The inverse of incorporation requires explicit removal direction or a later descendant; MOV alone is insufficient."],
  ["disassemble", "compound_or_gap", "Reverse systemic integration needs directionality/decomposition grammar and may involve MAT/REP; it is not STR:120."],
  ["split a system", "compound_or_gap", "Decomposition is structurally meaningful but intentionally not forced into the integration atom without a reverse operator."],
  ["repair structure", "different_family_or_compound", "REP owns restoration; STR roots specify any accompanying reconfiguration, incorporation, or integration."],
  ["replace component", "compound", "REP replacement plus removal and target incorporation, with identity constraints from LOG."],
  ["upgrade system", "compound", "CRE/REP/DAT/LOG may contribute; STR says only how structural organization changes."],
  ["configure network", "compound", "DAT/LOG configuration plus STR internal or systemic transformation according to topology change."],
  ["nest objects", "compound", "STR integration or later containment relation plus explicit hierarchy; nesting is not automatically physical enclosure."],
  ["compose functions", "compound", "LOG/DAT function definitions plus STR systemic integration if program structures become one composite."],
  ["link libraries", "compound", "STR integration, LOG symbol resolution, and DAT program artifacts; linking is not pure communication."],
  ["package application", "compound", "STR integration plus DAT archive and CRE packaging operation."],
  ["synchronize replicas", "different_family_or_compound", "DAT/CON/LOG owns state alignment; STR applies only if their composite arrangement changes."],
  ["circulate", "different_family", "MOV/CON owns repeated movement or distribution; circulation does not imply structural integration."],
  ["unknown structural scope", "unresolved_gap", "If internal, target, or systemic scope cannot be resolved, preserve ambiguity or request clarification."],
  ["unknown structural phase", "unresolved_gap", "If completed, active, or nonactualized phase cannot be resolved, do not guess a third-trit value."],
  ["incorporate subsystem into existing host", "one_root_or_compound", "STR:110/111/112 applies when the host remains the organizing whole and one external subsystem crosses into constituent status."],
  ["integrate hosts into a new cluster", "one_root_or_compound", "STR:120/121/122 applies when all host structures become peer constituents of a higher-order cluster distinct from any one host."],
  ["incorporate one structure or integrate two", "scope_resolution_test", "Ask which identity remains the whole: preserved reference selects incorporation; a higher-order whole containing every input selects systemic integration."],
  ["completed integration with current result", "compound", "STR:120 states completed systemic integration at its completion time; add STR:021 and an explicit time relation to assert that the resulting composite is presently instantiated."],
  ["potential incorporation means likely", "must_not_infer", "STR:112 supplies nonactualization only. Probability, capability, readiness, permission, intention, schedule, and future realization require separate claims."],
  ["incorporation without attachment", "one_root_plus_negation", "STR:110 may hold without asserting a continuing attachment relation; the target may be structurally incorporated through another constituent relation."],
  ["engagement becomes incorporation", "two_process_or_state_claims", "STR:011 can describe interface engagement during STR:111, but neither entails the other without explicit target, position, and result relations."]
].freeze

stress_tests = STRESS_CONCEPTS.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("STR1-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => {
    "title" => "STR:100–122 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation",
    "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5,
    "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/#{STEM}_semantic_approval.yaml" : nil
  },
  "roots" => scored_roots
}

recommended = {
  "metadata" => {
    "title" => "STR:100–122 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval",
    "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER,
    "triplets" => { "STR:100–102" => "internal reconfiguration: completed / active / nonactualized", "STR:110–112" => "asymmetric target incorporation: completed / active / nonactualized", "STR:120–122" => "higher-order systemic integration: completed / active / nonactualized" },
    "scope_separation" => { "inward" => "reference whole preserved; its own constituents are reassigned", "outward" => "reference whole preserved; one distinct external target becomes its constituent", "systemic" => "two or more input structures become peer constituents of a higher-order whole distinct from any one input" },
    "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/#{STEM}_semantic_approval.yaml" : nil
  },
  "roots" => recommended_roots,
  "approval_checklist" => {
    "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true,
    "triplets_coherent" => true, "current_candidates_challenged" => true, "cross_family_collisions_explicit" => true,
    "runtime_state_separated" => true, "nonactualized_process_rule_preserved" => true,
    "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true,
    "canonicalized" => canonicalized_now
  }
}

stress = { "metadata" => { "title" => "STR:100–122 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# STR:100–122 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Structure process meanings from first principles. It compares five genuinely different semantic architectures at every address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level decision\n\nThe strongest architecture makes `STR:1xx` a substrate-neutral structural-transformation grid. `STR:100–102` changes assignments of a structure's own constituents while preserving it as the reference whole. `STR:110–112` asymmetrically incorporates one distinct external target into an already identified reference that remains the organizing whole. `STR:120–122` makes two or more input structures peer constituents of a higher-order composite distinct from any single input. The third trit changes only completion phase.\n\n"
review << "The grid composes directly with canonical `STR:0xx`: internal reconfiguration changes occupancy of constituent positions, target incorporation brings a distinct target into a reference structure, and systemic integration organizes structures into a composite arrangement. It excludes construction, physical deformation, repair, planning, data migration, rules, communication, and ongoing structural relations.\n\n"
IDS.each do |id|
  score_root = scored_roots.find { |root| root["canonical_id"] == id }
  spec = recommended_roots.find { |root| root.dig("fixed_generated_fields", "canonical_id") == id }
  fixed = spec.fetch("fixed_generated_fields")
  review << "## #{id} — #{spec['proposed_title']}\n\n"
  review << "### Fixed generated forms\n\n- Universal slot: **#{fixed['universal_slot']}**\n- Transliteration: **#{fixed['family_qualified_transliteration']}**\n- Compact root: **#{fixed['local_compact_root']}**\n- Formal carrier: **#{fixed['formal_carrier']}**\n- Harmonic signature: **#{fixed['harmonic_signature_semitones'].join('–')}**\n- Relative note path: **#{fixed['relative_note_path_semitones'].join(' → ')}**\n\n"
  review << "### Why the current meaning was probably chosen\n\n#{score_root['current_meaning_rationale']}\n\n"
  review << "### Candidate comparison\n\n| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n"
  score_root.fetch("candidates").each do |candidate_item|
    values = EraZeroValidation::SCORE_KEYS.map { |key| candidate_item.dig("scores", key) }
    review << "| #{candidate_item['title']} | #{values.join(' | ')} | **#{candidate_item['total']}/80** |\n"
  end
  review << "\n"
  score_root.fetch("candidates").each do |candidate_item|
    analysis = candidate_item.fetch("analysis")
    review << "#### #{candidate_item['title']}\n\n**Invariant candidate:** #{candidate_item['invariant_candidate']}\n\n- Fit: #{analysis['why_it_fits']}\n- Useful coverage: #{analysis['useful_coverage']}\n- Territory consumed: #{analysis['semantic_territory_consumed']}\n- Conflicts and limitations: #{analysis['conflicts_or_future_limitations']}\n\n"
  end
  review << "### Recommended permanent semantic specification\n\n**Title:** #{spec['proposed_title']}\n\n**Invariant:** #{spec['invariant_definition']}\n\n**Boundary:** #{spec['inclusion_boundary']}\n\n**Excluded meanings:**\n\n"
  spec.fetch("excluded_meanings").each { |item| review << "- #{item}\n" }
  review << "\n**Address justification:**\n\n"
  spec.fetch("address_justification").each { |axis, explanation| review << "- `#{axis}`: #{explanation}\n" }
  review << "\n**Nearest neighbors:** #{spec['nearest_neighbors'].map { |neighbor| "`#{neighbor}`" }.join(', ')}\n\n**Same-family boundary:** #{spec['same_family_contrast']}\n\n**Runtime meanings:**\n\n"
  spec.fetch("runtime_state_interpretation").each { |state, meaning| review << "- `[#{state}]`: #{meaning}\n" }
  review << "\n**Lexical/runtime distinction:** #{spec['lexical_runtime_distinction']}\n\n### Examples\n\n| Type | Semantic graph | Literal gloss | Natural English | State | Result |\n| --- | --- | --- | --- | ---: | --- |\n"
  spec.fetch("examples").each { |example| review << "| #{example['category']} | `#{example['semantic_graph']}` | #{example['literal_gloss']} | #{example['natural_english']} | #{example['runtime_state']} | #{example['use_status']} |\n" }
  review << "\n"
end
review << "## Triplet coherence\n\n| Triplet | Shared process | `0` completed | `1` active | `2` nonactualized |\n| --- | --- | --- | --- | --- |\n| STR:100–102 | reassign one reference structure's own constituents while preserving it as the whole | transformation reached completion | same transformation ongoing | same transformation unrealized |\n| STR:110–112 | preserve one reference as the whole while one external target becomes its constituent | transformation reached completion | same transformation ongoing | same transformation unrealized |\n| STR:120–122 | make two or more input structures co-constituents of a higher-order whole | transformation reached completion | same transformation ongoing | same transformation unrealized |\n\n**Scope guard:** incorporation preserves one input as the reference whole; integration places every input beneath a higher-order whole. The concise word *potential* on `STR:102`, `STR:112`, and `STR:122` means nonactualized only and never supplies capability, readiness, probability, permission, intention, schedule, or future time.\n\n"
review << "## Ownership matrix\n\n| Root | Owns | Belongs elsewhere or remains compound |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | creation, matter, movement, repair, planning, rules, data migration, communication, and continuing relations |\n" }
review << "\n## Intentionally reserved concepts\n\nInstall, build, deploy, repair, replace, merge data, coordinate teams, mount, attach, enclose, refactor, migrate a schema, disassemble, split, and remove remain typed compounds or direction-sensitive gaps. Generic *organize*, *restructure*, *transform*, and *transition* require sense resolution.\n\n"
review << "## Stress test\n\n#{stress_tests.length} English structural-process concepts were routed through single roots, compounds, grammar, other families, future STR relations, or explicit unresolved gaps. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** approved under `migrations/#{STEM}_semantic_approval.yaml`; this remains the adversarial evidence record.\n" : "\n**Recommendation:** approve only after reusable packet validation, combined STR soundness validation, and current-state regression. Until then all nine roots remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# STR:100–122 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MOV displacement; MAT deformation; MIN reclassification; REP rearrangement", "1" => "CRE construction; MAT joining; LOG membership; STR attachment relation", "2" => "CON coordination; DAT migration; LOG deployment; LIF institution" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | STR keeps only constituent-to-position or structure-to-whole transformation |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Same-family safeguards\n\n- `STR:0xx` owns structural loci and arrangements; `STR:1xx` owns transformations of constituent organization; `STR:2xx` remains reserved for capacities and continuing relations.\n- Reconfiguration preserves one reference whole and changes assignments of its own constituents; it does not add an outside target or create a higher-order whole.\n- Incorporation is asymmetric: one already identified reference remains the whole while one distinct external target becomes its constituent. It does not entail creation, attachment, support, compatibility, or membership authority.\n- Integration is higher-order: two or more input structures become peer constituents of a composite distinct from any single input. It does not entail communication, consensus, operational deployment, or institutional identity.\n- A completed process entails only its invariant structural result at the completion reference time; persistence, function, integrity, and continuing STR:2xx relations require separate claims.\n- Lexical `1x2` means nonactualized process only. The title word `potential` is catalogue shorthand, not capability, readiness, probability, permission, intention, schedule, or future time; runtime `[2]/num` leaves an assertion unresolved and never changes lexical phase.\n\n## Reserved compounds and gaps\n\nBuild, install, deploy, mount, repair, replace, refactor, migrate, merge, federate, disassemble, remove, split, and reorganize an institution remain compounds or direction-sensitive gaps.\n\n**CONCLUSION: STR:100–122 STANDS ALONE ONLY FOR SUBSTRATE-NEUTRAL STRUCTURAL TRANSFORMATION; MATERIAL, SPATIAL, COGNITIVE, COMMUNICATIVE, NORMATIVE, INFORMATIONAL, CREATIVE, REPARATIVE, AND TEMPORAL CLAIMS REMAIN SEPARATE.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built #{RANGE} review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
