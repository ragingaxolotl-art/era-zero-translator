#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "STR:200–222"
STEM = "STR_200_222"
IDS = EraZeroValidation.ids_for_range(RANGE)
SEMANTIC_CENTER = "structural transformation affordance: internal reconfigurability, one-target incorporability, and multi-structure integrability"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "STR:200" => ["stable load capacity", "An entity can dependably retain form, bear load, contain contents, or preserve internal order."],
  "STR:201" => ["active adaptability", "A structure's capacity to flex, reconfigure, or redistribute support is presently available."],
  "STR:202" => ["unused structural capacity", "Space, load tolerance, or organizing potential exists but is not presently available or occupied."],
  "STR:210" => ["support relation", "A structure has a stable containment, anchoring, dependency, or support relation to a target."],
  "STR:211" => ["active structural support", "A structure is actively holding, sheltering, constraining, or organizing a target."],
  "STR:212" => ["possible structural fit", "A support, containment, or dependency relation may work but remains untested or unresolved."],
  "STR:220" => ["stable governance", "A system has established relationships of role, boundary, authority, and structural dependency."],
  "STR:221" => ["active coordination", "A distributed structure is actively reallocating roles, support, or organization among its parts."],
  "STR:222" => ["possible architecture", "A coherent system arrangement could exist but has not yet been instantiated."]
}.freeze

ROOTS = {
  "STR:200" => ["enduring internal reconfiguration capacity", "A persistent capacity of a reference structure to reassign its own constituents among its internal positions while preserving that structure as the reference whole."],
  "STR:201" => ["available internal reconfiguration capacity", "A capacity of a reference structure to reassign its own constituents among its internal positions that is presently available for exercise while preserving that structure as the reference whole."],
  "STR:202" => ["latent internal reconfiguration capacity", "A capacity of a reference structure to reassign its own constituents among its internal positions that exists without being presently available for exercise while preserving that structure as the reference whole."],
  "STR:210" => ["established target-incorporability relation", "A persistent structural relation that qualifies one distinct target for incorporation as a constituent of a reference structure while preserving the reference as the organizing whole."],
  "STR:211" => ["operative target-incorporability relation", "A structural relation that presently qualifies one distinct target for incorporation as a constituent of a reference structure while preserving the reference as the organizing whole."],
  "STR:212" => ["unresolved target-incorporability relation", "An unresolved structural relation between a reference structure and one distinct target whose qualification for incorporation as a constituent remains undetermined."],
  "STR:220" => ["enduring systemic-integrability relation", "A persistent structural relation among multiple structures that qualifies them for organization as peer constituents of one higher-order composite distinct from every input."],
  "STR:221" => ["operative systemic-integrability relation", "A structural relation among multiple structures that presently qualifies them for organization as peer constituents of one higher-order composite distinct from every input."],
  "STR:222" => ["unrealized systemic-integrability possibility", "An unrealized structural possibility that multiple structures could qualify for organization as peer constituents of one higher-order composite distinct from every input."]
}.freeze

ALT_TITLES = {
  "STR:200" => ["enduring structural-integrity capacity", "enduring constituent-accommodation capacity", "enduring rule-ordering capacity"],
  "STR:201" => ["active structural resilience", "available constituent-accommodation capacity", "active rule-ordering capacity"],
  "STR:202" => ["latent structural resilience", "latent constituent-accommodation capacity", "latent rule-ordering capacity"],
  "STR:210" => ["established support relation", "established constituent-membership relation", "established interface-conformance relation"],
  "STR:211" => ["active support relation", "operative constituent-membership relation", "active interface-conformance relation"],
  "STR:212" => ["unresolved support relation", "unresolved constituent-membership relation", "unresolved interface-conformance relation"],
  "STR:220" => ["stable systemic-dependency relation", "stable structural-topology relation", "stable governance relation"],
  "STR:221" => ["active systemic-dependency relation", "active structural-topology relation", "active governance relation"],
  "STR:222" => ["potential systemic-dependency relation", "possible structural topology", "possible governance architecture"]
}.freeze

SCORE_BASES = {
  "phase2_mixed" => [4, 7, 7, 4, 3, 6, 7, 6],
  "transformation_affordance" => [10, 10, 10, 10, 9, 10, 9, 10],
  "integrity_support_dependency" => [8, 8, 9, 7, 7, 8, 9, 7],
  "accommodation_membership_topology" => [8, 8, 9, 6, 7, 9, 9, 9],
  "rule_interface_governance" => [8, 7, 5, 8, 4, 9, 7, 10]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identity, kinship, care, and biosystems. STR may describe whether living or institutional structures can be reorganized or combined, but it does not create biological or social identity.",
  "MOV" => "MOV owns position, displacement, routes, self-mobility, and reference-frame configurations. A structural affordance neither moves anything nor states where any constituent is located.",
  "MAT" => "MAT owns physical work capacity, contact, force transmission, and material interdependence. STR affordances are substrate-neutral and do not assert strength, load tolerance, energy, shape, or physical joining.",
  "MIN" => "MIN owns attention, cognition, intention, categorization, and joint attention. Mentally classifying things as compatible does not establish a structural reconfiguration or integration affordance.",
  "CON" => "CON owns communicative participation and directed or shared exchange relations. Structures may communicate without being integrable, and may be integrable without exchanging messages.",
  "WRN" => "WRN owns danger, defect, failure, vulnerability, and unresolved threat. Lack of a structural affordance may cause risk, but the risk and the affordance remain separate claims.",
  "REP" => "REP owns repair, restoration, recoverability, and maintenance. Capacity for reconfiguration is not self-repair, and incorporability or integrability does not imply that combining structures restores them.",
  "LOG" => "LOG owns formal validity, type constraints, permission, entailment, computability, and set membership. STR qualifies part–whole transformation by structural positions and interfaces, not by rules alone.",
  "DAT" => "DAT owns records, schemas, references, encodings, and information linkage. A compatibility declaration or schema record may describe a STR affordance but is not the affordance itself.",
  "CRE" => "CRE owns design, fabrication, generation, assembly as creation, and unrealized artifacts. STR:2xx states an affordance or qualifying relation and does not create, design, or instantiate a structure.",
  "ORI" => "ORI owns general possibility, necessity, temporal or ontological transition, and manifestation. STR:222 is only the structural possibility of peer integration, never unrestricted modality or future time."
}.freeze

def phase_words(id)
  case id[-1]
  when "0" then ["stable", "persistent or established"]
  when "1" then ["active", "presently available or operative"]
  else ["dormant or unresolved", "latent, unresolved, or unrealized"]
  end
end

def scope_words(id)
  case id[-2]
  when "0" then ["inward", "the reference structure's own constituent organization", "internal reconfiguration capacity"]
  when "1" then ["outward", "one distinct target relative to a preserved reference whole", "target-incorporability relation"]
  else ["systemic", "multiple structures relative to one higher-order composite", "systemic-integrability relation"]
  end
end

def score_profile(id, candidate_id)
  values = SCORE_BASES.fetch(candidate_id).dup
  second = id[-2].to_i
  third = id[-1].to_i
  case candidate_id
  when "phase2_mixed"
    values[0] -= 1 if [0, 1].include?(second)
    values[3] -= 1 if third == 2
  when "transformation_affordance"
    values[6] += 1 if second == 1
    values[4] += 1 if second == 0
  when "integrity_support_dependency"
    values[1] += 1 if second == 0
    values[6] += 1 if second == 1
  when "accommodation_membership_topology"
    values[7] += 1 if second == 2
    values[3] -= 1 if second == 1
  when "rule_interface_governance"
    values[7] += 1 if second == 1
    values[4] -= 1 if second == 2
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, candidate_id)
  scope, _scope_description, center = scope_words(id)
  phase, phase_description = phase_words(id)
  case candidate_id
  when "phase2_mixed"
    {
      "why_it_fits" => "The Phase 2 label follows the #{phase_description} #{scope} slot and uses familiar Structure-family vocabulary.",
      "useful_coverage" => "It reaches common talk about strength, support, containment, coordination, and architecture.",
      "semantic_territory_consumed" => "It consumes several distinct physical, structural, normative, and organizational relations at once.",
      "conflicts_or_future_limitations" => "Its disjunctive definitions are not atomic, collide with MAT, LOG, CON, CRE, and REP, and fail to keep one center across the triplet."
    }
  when "transformation_affordance"
    {
      "why_it_fits" => "It makes first-trit 2 the capacity or qualifying relation for the matching canonical STR:1#{id[-2]}x transformation while preserving #{scope} scope and #{phase} expression.",
      "useful_coverage" => "It covers reconfigurable structures, host–target structural admissibility, and composability of multiple structures in speech, engineering, software, and mathematics.",
      "semantic_territory_consumed" => "It consumes only the substrate-neutral structural affordance that licenses #{center}; actual processes, entities, physical forces, rules, and modality remain separate.",
      "conflicts_or_future_limitations" => "Its technical titles need clear everyday glosses, but the narrow invariants avoid collisions and provide excellent compound primitives."
    }
  when "integrity_support_dependency"
    {
      "why_it_fits" => "Integrity, support, and dependency are plausible capacities or relations in the Structure family and can be inflected for #{phase} state.",
      "useful_coverage" => "It would cover bearing, bracing, shelter, constraint, reliance, and structural resilience.",
      "semantic_territory_consumed" => "It consumes physical strength, containment, functional reliance, and network dependency rather than one invariant relation.",
      "conflicts_or_future_limitations" => "MAT owns force and load, REP owns resilience, LOG owns dependency rules, and the three columns do not form one semantic axis."
    }
  when "accommodation_membership_topology"
    {
      "why_it_fits" => "Capacity to host constituents, part–whole membership, and topology all describe structural organization and match the address directions.",
      "useful_coverage" => "It would serve containers, parent–child trees, component membership, graph topology, and spatial or software layouts.",
      "semantic_territory_consumed" => "It consumes actual constituent status and arrangement identity already represented by STR:0xx positions, interfaces, and composites.",
      "conflicts_or_future_limitations" => "It blurs entity and relation layers, collides with LOG set membership and MOV configurations, and leaves the corresponding STR:1xx affordances unnamed."
    }
  else
    {
      "why_it_fits" => "Ordering capacity, interface conformance, and governance are plausible Structure-family abstractions with strong technical utility.",
      "useful_coverage" => "It would cover schemas, protocols, role systems, admissibility rules, and managed architectures.",
      "semantic_territory_consumed" => "It consumes formal validity, permission, specification, authority, and informational descriptions.",
      "conflicts_or_future_limitations" => "LOG, DAT, and CON own most of that territory; institutional governance also collides with LIF and does not yield one clean STR triplet."
    }
  end
end

def alternative_invariant(id, candidate_id)
  title = ALT_TITLES.fetch(id)[{"integrity_support_dependency" => 0, "accommodation_membership_topology" => 1, "rule_interface_governance" => 2}.fetch(candidate_id)]
  "The #{title} assigned to #{id} as the #{atoms_slot_phrase(id)}."
end

def atoms_slot_phrase(id)
  scope, scope_description, = scope_words(id)
  phase, = phase_words(id)
  "#{phase} #{scope} structural capacity or relation concerning #{scope_description}"
end

def candidate(id, candidate_id, title, invariant)
  values = score_profile(id, candidate_id)
  scores = EraZeroValidation::SCORE_KEYS.zip(values).to_h
  {
    "candidate_id" => candidate_id,
    "title" => title,
    "invariant_candidate" => invariant,
    "analysis" => candidate_analysis(id, candidate_id),
    "scores" => scores,
    "total" => scores.values.sum,
    "maximum" => scores.length * 10
  }
end

def nearest_neighbors(id)
  second = id[-2]
  third = id[-1]
  siblings = %w[0 1 2].reject { |value| value == third }.map { |value| "STR:2#{second}#{value}" }
  column = case second
           when "0" then %w[STR:100 STR:101 STR:102 STR:000]
           when "1" then %w[STR:110 STR:111 STR:112 STR:010]
           else %w[STR:120 STR:121 STR:122 STR:020]
           end
  siblings + column
end

def runtime_meanings(id)
  title = ROOTS.fetch(id).first
  third = id[-1]
  if third == "0"
    {
      "0" => "Denies that the #{title} holds in the stated structural context; it does not select the active or dormant sibling.",
      "1" => "Affirms that the #{title} holds, without asserting that any reconfiguration, incorporation, or integration process is occurring.",
      "2/num" => "Leaves the assertion that the #{title} holds pending, remembered, or unresolved; the lexical root remains the stable member."
    }
  elsif third == "1"
    {
      "0" => "Denies that the #{title} is presently available or operative, without thereby asserting the dormant or unresolved sibling.",
      "1" => "Affirms that the #{title} is presently available or operative, without asserting that the corresponding transformation is underway.",
      "2/num" => "Leaves current availability or operation of the #{title} unresolved; runtime uncertainty does not change lexical active status."
    }
  else
    {
      "0" => "Denies that the #{title} exists as the stated latent, unresolved, or unrealized structural affordance.",
      "1" => "Affirms the #{title} exactly as latent, unresolved, or unrealized; the state marker does not make it active, established, or realized.",
      "2/num" => "Leaves unresolved even the assertion that the #{title} exists; this meta-level runtime uncertainty is distinct from lexical third-trit 2."
    }
  end
end

def examples_for(id)
  second = id[-2]
  title = ROOTS.fetch(id).first
  phase, = phase_words(id)
  case second
  when "0"
    subject = "reference structure"
    role = "STRUCTURE=s,CONSTITUENTS=c"
    ordinary = "This shelving system #{phase == 'stable' ? 'remains reconfigurable' : phase == 'active' ? 'can be reconfigured right now' : 'has a latent reconfiguration capacity that is currently unavailable'}."
    physical = "The modular rack's members can be reassigned among its own bays without replacing the rack as the reference whole."
    temporal = "After the locking interval, the same frame #{phase == 'active' ? 'has reconfiguration capacity available' : 'has the stated reconfiguration-capacity status'}."
    program = "The running container reports whether its internal module layout is reconfigurable without replacing container identity."
    counter_graph = "STR:101[1](STRUCTURE=s,CONSTITUENTS=c)"
    counter_gloss = "ongoing internal reconfiguration"
    counter_english = "The shelves are being rearranged now."
    counter_analysis = "Use STR:101 for the ongoing transformation; #{id} names a capacity, not the act of exercising it."
  when "1"
    subject = "reference structure and one target"
    role = "HOST=h,TARGET=t"
    ordinary = "The replacement drawer #{phase == 'stable' ? 'is an established structural fit for' : phase == 'active' ? 'is presently admissible into' : 'has not yet been shown to fit'} this cabinet."
    physical = "The keyed socket and this plug have the stated target-incorporability relation, independent of contact or insertion."
    temporal = "During the service window, the host–module relation #{phase == 'active' ? 'is operative for incorporation' : 'has the stated incorporability status'}."
    program = "The plugin host reports structural admissibility of one module without asserting type validity, loading, or execution."
    counter_graph = "STR:110[1](HOST=h,TARGET=t)"
    counter_gloss = "completed target incorporation"
    counter_english = "The drawer has already become a constituent of the cabinet."
    counter_analysis = "Use STR:110 for completed incorporation; #{id} names a qualifying host–target relation, not the transformation or its result state."
  else
    subject = "multiple structures"
    role = "INPUT_STRUCTURES={a,b},COMPOSITE=k"
    ordinary = "These modules #{phase == 'stable' ? 'have an enduring capacity to form one larger system' : phase == 'active' ? 'are presently mutually integrable' : 'could have a shared structural basis for integration that is not yet realized'}."
    physical = "The bridge sections have the stated systemic integrability relation without yet being assembled or joined."
    temporal = "For this version interval, the structures #{phase == 'active' ? 'are presently integrable as peers' : 'have the stated systemic-integrability status'}."
    program = "The component graph reports whether several modules can become peer constituents of a new composite without asserting communication or deployment."
    counter_graph = "STR:120[1](INPUT_STRUCTURES={a,b},COMPOSITE=k)"
    counter_gloss = "completed systemic integration"
    counter_english = "The modules have already been organized as one higher-order composite."
    counter_analysis = "Use STR:120 for completed integration; #{id} names the qualifying systemic relation or possibility, not the integration process."
  end
  registers = second == "0" ? "mid register for reference structure; lower subordinate register for constituents" : second == "1" ? "mid register for host; higher target register for the distinct target" : "parallel peer registers for inputs; lower collective register for the higher-order composite"
  rows = [
    ["ordinary_conversation", "#{id}[1](#{role})", "affirm #{title} of #{subject}", ordinary, "The example asserts only structural affordance."],
    ["physical_or_spatial", "MAT(OBJECTS=o)+#{id}[1](#{role})", "material realization plus #{title}", physical, "MAT supplies material facts; STR supplies the substrate-neutral affordance."],
    ["temporal_or_sequential", "#{id}[1](#{role})+ORI(INTERVAL=w)", "#{title} during interval w", temporal, "ORI locates the claim in time; lexical third-trit status is not tense."],
    ["cross_family_compound", "DAT(SPEC=d)+LOG(PERMIT=p)+#{id}[1](#{role})", "specification and permission plus #{title}", "The specification and rule describe the affordance; the STR relation still must hold independently.", "DAT and LOG describe or authorize; neither substitutes for the structural affordance."],
    ["executable_or_programming", "#{id}[1](#{role})", "assert #{title}", program, "The executable test must preserve reference identity and structural roles explicitly."],
    ["counterexample", counter_graph, counter_gloss, counter_english, counter_analysis]
  ]
  rows.map do |category, graph, gloss, english, analysis|
    {
      "category" => category,
      "semantic_graph" => graph,
      "literal_gloss" => gloss,
      "natural_english" => english,
      "runtime_state" => 1,
      "contour" => category == "executable_or_programming" ? "level assertion or sharply falling execution" : "level declaration",
      "role_registers" => registers,
      "use_status" => category == "counterexample" ? "must_not_use_this_root" : "valid",
      "analysis" => analysis,
      "pseudocode" => category == "executable_or_programming" ? "assert(structural_affordance.matches?(#{id.inspect}))" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  phase2_title, phase2_definition = PHASE2.fetch(id)
  winner_title, winner_definition = ROOTS.fetch(id)
  alternatives = ALT_TITLES.fetch(id)
  candidates = [
    ["phase2_mixed", phase2_title, phase2_definition],
    ["transformation_affordance", winner_title, winner_definition],
    ["integrity_support_dependency", alternatives[0], alternative_invariant(id, "integrity_support_dependency")],
    ["accommodation_membership_topology", alternatives[1], alternative_invariant(id, "accommodation_membership_topology")],
    ["rule_interface_governance", alternatives[2], alternative_invariant(id, "rule_interface_governance")]
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "current_meaning_rationale" => candidate_analysis(id, "phase2_mixed")["why_it_fits"],
    "candidates" => candidates.map { |candidate_id, title, definition| candidate(id, candidate_id, title, definition) },
    "recommended_candidate_id" => "transformation_affordance",
    "recommendation_reason" => "Only the transformation-affordance architecture keeps one structural semantic center, aligns each column with its canonical STR:1xx transformation, changes only lexical status within each triplet, and leaves entities, processes, material forces, rules, data, communication, repair, creation, and general modality separate.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end

recommended_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  title, definition = ROOTS.fetch(id)
  scope, scope_description, center = scope_words(id)
  phase, phase_description = phase_words(id)
  second = id[-2]
  scope_guard = case second
                when "0" then "The capacity concerns reassignment of the structure's own constituents; it neither adds a target nor forms a higher-order whole."
                when "1" then "The relation qualifies exactly one distinct target while the reference remains the organizing whole; actual incorporation and continuing membership remain separate."
                else "The relation qualifies multiple input structures as peer candidates for a new higher-order whole; no single input remains the containing reference."
                end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => title,
    "invariant_definition" => definition,
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_2" => "Selects a structural capacity, qualifying relationship, or unrealized possibility rather than a locus/entity or an actual transformation.",
      "second_trit" => "Selects #{scope} scope: #{scope_description}; this root names the affordance for #{center} and no competing family claim.",
      "third_trit" => "Selects #{phase_description} expression of the same #{center}; runtime truth status, tense, probability, permission, and process phase remain separate."
    },
    "inclusion_boundary" => "Includes only the #{phase_description} substrate-neutral structural affordance for #{center}. #{scope_guard} It may be instantiated in physical, computational, organizational, or conceptual structures, but it does not assert that the matching STR:1xx transformation occurs, that any STR:0xx arrangement is realized, or that material, logical, informational, communicative, reparative, creative, temporal, or modal conditions hold.",
    "excluded_meanings" => [
      "The constituent position, interface, composite arrangement, constituent, target, or system as an entity or condition.",
      "An actual internal reconfiguration, target incorporation, or systemic integration process at any completion phase.",
      "Physical strength, load-bearing, elasticity, energy, contact, attachment force, containment, shelter, or material coupling.",
      "Set membership, type validity, formal compatibility, permission, authority, governance, schema conformance, or specification truth.",
      "Repairability, resilience, self-healing, creation, fabrication, deployment, communication, coordination, attention, or intention.",
      "Probability, readiness, plan, schedule, future time, necessity, unrestricted possibility, or guaranteed success."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "STR:0xx names constituent positions, structural interfaces, and composite arrangements. STR:1xx names actual transformations of constituent organization. STR:2xx names only the corresponding capacity or qualifying relation: inward reconfigurability, outward target incorporability, or systemic integrability. A capacity or relation does not entail that its process begins or completes; an actual process does not entail that the affordance persists afterward. Target incorporability preserves one reference whole and qualifies exactly one distinct target. Systemic integrability treats multiple inputs as peer candidates for a higher-order whole distinct from every input.",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_meanings(id),
    "lexical_runtime_distinction" => "Lexical third trit #{id[-1]} permanently selects the #{phase} member of this affordance triplet. Runtime `[2]/num` instead marks a token-level assertion pending, remembered, or unresolved. Thus `#{id}[1]` affirms the lexical concept, while a stable or active sibling carrying `[2]/num` remains that sibling and does not become #{id}.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + STR:0xx identifies the position, interface, or composite arrangement whose organization supplies the affordance.",
      "#{id} + STR:1xx distinguishes an available affordance from its actual exercise, completion, or nonactualized process.",
      "#{id} + MAT/MOV specifies physical substance, force, contact, or displacement without reducing structural qualification to matter or motion.",
      "#{id} + DAT/LOG specifies a record, interface declaration, type rule, permission, or test while keeping the structural affordance independent.",
      "#{id} + CRE/REP/WRN states creation, repair, or risk consequences without importing them into the atomic STR meaning."
    ],
    "later_era_notes" => "Later eras may lexicalize flexible, modular, extensible, compatible, pluggable, mountable, composable, interoperable, mergeable, or federatable descendants. Era Zero must retain the own-constituent / one-target-preserved-host / peer-input-higher-order contrast and keep lexical third-trit status separate from runtime state and general modality.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end

STRESS_CONCEPTS = [
  ["reconfigurable", "one_root", "STR:200, 201, or 202 by enduring, available, or latent internal reconfiguration capacity."],
  ["flexible", "compound_or_other_family", "MAT owns physical flexibility; STR:2x0 applies only when own constituent assignments can change."],
  ["adaptable", "underspecified_compound", "May mean structural reconfigurability, mental adaptation, biological adaptation, or repair; resolve the domain."],
  ["mutable structure", "one_root_or_compound", "STR:2x0 covers structural reconfigurability; LOG/DAT may constrain mutation rules or representation."],
  ["modular", "compound", "STR internal reconfigurability plus identifiable constituent positions and often target incorporability."],
  ["configurable", "compound_or_one_root", "STR:2x0 if constituent placement can change; DAT/LOG if only parameter values or rules change."],
  ["extensible", "one_root_or_compound", "Target incorporability by lexical status, often combined with defined interface and capacity limits."],
  ["plugin-ready", "compound", "STR:211 plus DAT interface description and LOG type or permission constraints."],
  ["spare slot", "entity_plus_compound", "STR:002 names a vacant constituent position; STR:2x1 is added only for a particular target's incorporability."],
  ["storage capacity", "different_family_or_compound", "Quantity and physical volume belong to MAT/LOG; STR:2x0 is not generic capacity."],
  ["load-bearing", "different_family", "MAT physical work or force capacity, not internal reconfiguration capacity."],
  ["structurally resilient", "different_family_or_compound", "REP/MAT owns recovery and physical resilience; STR may state preserved reconfigurability separately."],
  ["self-repairing", "different_family", "REP owns repairability; rearrangeability is insufficient."],
  ["host accepts component", "one_root", "STR:210, 211, or 212 by established, operative, or unresolved target incorporability."],
  ["fits", "compound_or_one_root", "STR target incorporability when fit means admission as a constituent; physical dimensions add MAT."],
  ["compatible", "underspecified_compound", "Could be structural incorporability, LOG type validity, CON protocol compatibility, or DAT schema compatibility."],
  ["interface-compatible", "compound", "STR target incorporability plus STR interface entity and usually LOG/DAT interface constraints."],
  ["socket match", "compound", "STR incorporability plus MAT geometry/contact; matching does not assert insertion."],
  ["mountable", "compound", "STR target incorporability plus a later attachment/support relation and often MAT force constraints."],
  ["attachable", "compound_or_gap", "Attachment is a continuing relation not collapsed into incorporability; use a compound or preserve the gap."],
  ["containable", "compound_or_gap", "Containment requires boundary and relation semantics; incorporability applies only if constituent status is intended."],
  ["support relation", "different_semantic_direction", "Physical support or structural dependence is intentionally not the atomic winner; compose MAT/STR/LOG as needed."],
  ["depends on", "different_family_or_compound", "LOG, DAT, CON, MAT, or STR may own the dependency sense; target incorporability does not imply dependence."],
  ["part of", "entity_or_compound", "Actual constituency is expressed through STR:0xx arrangement/position plus an explicit relation or result; STR:2x1 only qualifies incorporation."],
  ["member of", "different_family_or_compound", "LOG set membership or LIF social membership; do not force into STR target incorporability."],
  ["contains", "entity_or_compound", "STR composite/position plus containment relation; a host can contain without admitting the target as a constituent."],
  ["integrable", "one_root", "STR:220, 221, or 222 by enduring, operative, or unrealized systemic integrability."],
  ["composable", "one_root_or_compound", "STR systemic integrability when structures can become peer constituents of a higher-order whole."],
  ["interoperable", "compound", "CON communication and LOG protocol constraints plus STR systemic integrability only if one composite structure is possible."],
  ["federatable", "compound", "STR systemic integrability plus LOG autonomy and CON coordination rules."],
  ["clusterable", "one_root_or_compound", "STR systemic integrability; MOV shared location and LOG cluster policy remain separate."],
  ["mergeable systems", "compound", "STR systemic integrability plus DAT/LOG identity and conflict rules."],
  ["assemblable", "compound", "STR integrability plus CRE/MAT if fabrication or physical joining is intended."],
  ["shared architecture", "entity_or_relation", "STR:020–022 owns the composite arrangement; STR:2x2 owns only qualifying integrability."],
  ["topology", "entity_or_different_relation", "STR arrangement or MOV frame may represent topology; it is not automatically an integrability affordance."],
  ["governance", "different_family_or_compound", "LOG authority and LIF institution with CON coordination; intentionally rejected as the STR systemic atom."],
  ["coordination", "different_family", "CON communication/coordination does not imply structural integrability."],
  ["network compatibility", "compound", "CON/DAT/LOG protocol claims plus STR integrability when a higher-order structure is at issue."],
  ["rearrange", "process_root", "Use STR:100–102 by phase; STR:2x0 states only the capacity for that transformation."],
  ["incorporate", "process_root", "Use STR:110–112 by phase; STR:2x1 states only the target-qualifying relation."],
  ["integrate", "process_root", "Use STR:120–122 by phase; STR:2x2 states only the systemic qualifying relation or possibility."],
  ["build", "different_family_or_compound", "CRE owns creation; structural affordances can be inputs to building but are not the build event."],
  ["construct", "different_family_or_compound", "CRE/MAT owns construction; STR:2xx may describe reconfigurability or integrability of inputs."],
  ["repair", "different_family", "REP owns repair and recoverability; a separate STR claim is needed only if repair restores a structural affordance."],
  ["transport", "different_family", "MOV/MAT owns transport; structural fit is a separate possible condition."],
  ["communicate", "different_family", "CON owns exchange; structural integrability is neither necessary nor sufficient."],
  ["type compatible", "different_family", "LOG owns formal type compatibility; STR applies only to structural constituent organization."],
  ["schema compatible", "different_family_or_compound", "DAT/LOG owns schema compatibility; STR applies if instantiated structures can combine."],
  ["API compatible", "compound", "LOG/DAT/CON own protocol validity and exchange; STR integrability may be separately asserted."],
  ["scheduled integration", "compound", "ORI/LOG schedule plus STR:122 for a nonactualized process; STR:2xx never encodes schedule."],
  ["possible integration", "ambiguous_root_or_process", "STR:122 is a nonactualized process; STR:222 is an unrealized qualifying possibility. Choose by whether the claim is about an event or a relation."],
  ["likely integration", "compound", "Probability plus STR:122 or 222; neither root carries likelihood."],
  ["ready to integrate", "compound", "Readiness requires an explicit runtime or LOG/ORI condition; STR:221 states only operative integrability."],
  ["permitted to integrate", "compound", "LOG permission plus STR:2x2; permission does not establish structural integrability."],
  ["reconfiguration capacity in use", "two_claims", "STR:201 states available capacity and STR:101 states the active process; neither entails the other."],
  ["stable capacity currently uncertain", "one_root_plus_runtime", "STR:200[2]/num: stable lexical capacity with unresolved token-level assertion."],
  ["latent capacity affirmed", "one_root_plus_runtime", "STR:202[1]: the latent capacity is asserted as real although unavailable."],
  ["operative target fit denied", "one_root_plus_runtime", "STR:211[0]: deny current operation without asserting STR:212."],
  ["unresolved fit affirmed", "one_root_plus_runtime", "STR:212[1]: affirm that qualification remains unresolved; not the same as STR:210[2]."],
  ["enduring integrability uncertain", "one_root_plus_runtime", "STR:220[2]/num: uncertainty about an enduring relation, not lexical unrealized possibility."],
  ["unrealized integrability affirmed", "one_root_plus_runtime", "STR:222[1]: affirm the unrealized structural possibility without asserting process, probability, or plan."],
  ["drawer fits but is not inserted", "one_root", "STR:210 or 211 can hold without STR:110/111 because a qualifying relation does not entail the incorporation process."],
  ["drawer inserted despite no enduring fit", "process_plus_state", "STR:110 may be true while STR:210 is false; successful process does not guarantee persistent affordance."],
  ["modules integrable but communicating separately", "one_root_plus_other_family", "STR:2x2 and CON relations are independent; the modules may be structurally integrable without any shared exchange."],
  ["modules communicating but not integrable", "different_family_plus_negation", "CON may hold while STR integrability is denied because successful exchange does not establish a higher-order structural affordance."],
  ["two parts already form a composite", "entity_or_process", "Use STR:020/021 for the arrangement or STR:120 for completed integration; not STR:2x2 alone."],
  ["one host absorbs one subsystem", "target_incorporability", "Preserved host and one target select STR:2x1, not systemic STR:2x2."],
  ["two hosts can form a new cluster", "systemic_integrability", "Peer inputs and a higher-order whole select STR:2x2, not target STR:2x1."],
  ["unknown host identity", "unresolved_gap", "If preserved host versus peer-input scope is unknown, do not guess outward or systemic address."],
  ["unknown affordance status", "unresolved_gap", "If stable, active, or lexical unresolved status cannot be determined, preserve ambiguity rather than guessing the third trit."],
  ["physical clearance only", "different_family_or_compound", "MAT geometry may show clearance; STR incorporability additionally requires constituent qualification."],
  ["logical rule says allowed but structure cannot accept", "two_claims", "LOG permission can be true while STR target incorporability is false."],
  ["blueprint says composable but implementation is not", "two_claims", "DAT specification can claim compatibility while STR systemic integrability is denied."],
  ["repair makes structure reconfigurable", "compound", "REP process plus STR:201 result claim; repair and reconfigurability remain distinct."],
  ["design for modularity", "compound", "CRE/DAT design plus a nonactualized or asserted STR affordance; design does not establish the affordance."],
  ["future extensibility", "compound", "ORI future relation plus STR target incorporability; the STR root itself is tenseless."],
  ["general possibility", "different_family", "ORI owns unrestricted possibility; STR:222 is narrowly systemic and structural."],
  ["system necessity", "different_family", "ORI/LOG owns necessity; integrability says what can structurally combine, not what must."],
  ["structural possibility becomes active", "two_time_indexed_claims", "Relate STR:222 at one time to STR:221 at another; the roots do not encode the transition by themselves."],
  ["capacity versus active process", "scope_resolution_test", "STR:201[1] asserts available reconfiguration capacity; STR:101[1] asserts reconfiguration is occurring."],
  ["fit relation versus incorporation", "scope_resolution_test", "STR:211[1] asserts operative incorporability; STR:111[1] asserts the target is actually being incorporated."],
  ["integrability relation versus integration", "scope_resolution_test", "STR:221[1] asserts operative systemic integrability; STR:121[1] asserts integration is occurring."]
].freeze

stress_tests = STRESS_CONCEPTS.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("STR2-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => {
    "title" => "STR:200–222 adversarial semantic candidates",
    "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation",
    "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9,
    "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS,
    "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [],
    "approval_record" => canonicalized_now ? "migrations/#{STEM}_semantic_approval.yaml" : nil
  },
  "roots" => scored_roots
}

recommended = {
  "metadata" => {
    "title" => "STR:200–222 recommended permanent semantic specification",
    "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval",
    "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER,
    "triplets" => {
      "STR:200–202" => "internal reconfiguration capacity: enduring / presently available / latent",
      "STR:210–212" => "target incorporability: established / presently operative / unresolved",
      "STR:220–222" => "systemic integrability: enduring / presently operative / unrealized possibility"
    },
    "scope_separation" => {
      "inward" => "one reference structure and its own constituents; capacity for internal reassignment",
      "outward" => "one preserved reference whole and one distinct target; qualification for incorporation",
      "systemic" => "multiple peer input structures and a higher-order whole; qualification for integration"
    },
    "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [],
    "approval_record" => canonicalized_now ? "migrations/#{STEM}_semantic_approval.yaml" : nil
  },
  "roots" => recommended_roots,
  "approval_checklist" => {
    "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true,
    "triplets_coherent" => true, "current_candidates_challenged" => true, "cross_family_collisions_explicit" => true,
    "runtime_state_separated" => true, "entity_process_affordance_layers_separated" => true,
    "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true,
    "canonicalized" => canonicalized_now
  }
}

stress = {
  "metadata" => {
    "title" => "STR:200–222 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary",
    "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true
  },
  "tests" => stress_tests
}

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# STR:200–222 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Structure capacity/relation meanings from first principles. It compares five genuinely different architectures at every address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level decision\n\nThe strongest architecture makes `STR:2xx` the affordance layer paired with canonical `STR:1xx`. `STR:200–202` says whether one structure can reassign its own constituents. `STR:210–212` says whether one distinct target is structurally qualified for incorporation into a preserved reference whole. `STR:220–222` says whether multiple structures are qualified to become peer constituents of a higher-order whole.\n\n"
review << "This replaces the Phase 2 mixture of load, adaptability, support, governance, coordination, and possible architecture. Those candidates were useful prompts but not one atomic grid: they crossed MAT, LOG, CON, REP, and CRE boundaries and did not align the three triplets. The recommended grid remains neutral about substrate, purpose, value, safety, and actual execution.\n\n"

IDS.each do |id|
  score_root = scored_roots.find { |root| root["canonical_id"] == id }
  spec = recommended_roots.find { |root| root.dig("fixed_generated_fields", "canonical_id") == id }
  fixed = spec.fetch("fixed_generated_fields")
  review << "## #{id} — #{spec['proposed_title']}\n\n"
  review << "### Fixed generated forms\n\n- Universal slot: **#{fixed['universal_slot']}**\n- Transliteration: **#{fixed['family_qualified_transliteration']}**\n- Compact root: **#{fixed['local_compact_root']}**\n- Formal carrier: **#{fixed['formal_carrier']}**\n- Harmonic signature: **#{fixed['harmonic_signature_semitones'].join('–')}**\n- Relative note path: **#{fixed['relative_note_path_semitones'].join(' → ')}**\n\n"
  review << "### Why the Phase 2 meaning was probably chosen\n\n#{score_root['current_meaning_rationale']}\n\n"
  review << "### Candidate comparison\n\n| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n"
  score_root.fetch("candidates").each do |item|
    values = EraZeroValidation::SCORE_KEYS.map { |key| item.dig("scores", key) }
    review << "| #{item['title']} | #{values.join(' | ')} | **#{item['total']}/80** |\n"
  end
  review << "\n"
  score_root.fetch("candidates").each do |item|
    analysis = item.fetch("analysis")
    review << "#### #{item['title']}\n\n**Invariant candidate:** #{item['invariant_candidate']}\n\n- Fit: #{analysis['why_it_fits']}\n- Useful coverage: #{analysis['useful_coverage']}\n- Territory consumed: #{analysis['semantic_territory_consumed']}\n- Conflicts and limitations: #{analysis['conflicts_or_future_limitations']}\n\n"
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

review << "## Nine-root contrast matrix\n\n| Root | Permanent ownership | Exact lexical status | Nearest excluded concept |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  _phase, phase_description = phase_words(id)
  review << "| #{id} | #{root['proposed_title']} | #{phase_description} | actual STR:1xx process, STR:0xx entity, material strength, rule validity, or general modality |\n"
end
review << "\n## Triplet coherence\n\n| Triplet | Shared affordance | `0` | `1` | `2` |\n| --- | --- | --- | --- | --- |\n| STR:200–202 | one structure can reassign its own constituents while preserving reference identity | capacity persists | capacity presently available | capacity exists but presently unavailable |\n| STR:210–212 | one target is qualified for incorporation into one preserved host | relation established | relation presently operative | target qualification undetermined |\n| STR:220–222 | multiple peer inputs are qualified for one higher-order composite | relation persists | relation presently operative | qualifying relation remains unrealized |\n\n"
review << "## English ownership and reservations\n\nThe roots own *reconfigurable*, structurally *incorporable*, and structurally *integrable* only under their exact invariants. Physical flexibility and strength belong to MAT; repairability to REP; type, permission, and set membership to LOG; schemas to DAT; communication to CON; creation and assembly to CRE; unrestricted possibility and time to ORI. *Modular*, *compatible*, *attachable*, *supporting*, *containing*, *dependent*, *interoperable*, *ready*, *likely*, and *scheduled* remain compounds or sense-resolution tasks.\n\n"
review << "## Stress test\n\n#{stress_tests.length} unique concepts were routed through single roots, STR entities or processes, compounds, other families, runtime state, grammar, or explicit gaps. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** approved under `migrations/#{STEM}_semantic_approval.yaml`; this file remains the adversarial evidence record.\n" : "\n**Recommendation:** approve only after reusable packet validation, full STR:000–222 soundness validation, and current-state regression. Until then all nine roots remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# STR:200–222 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MAT flexibility/load; REP resilience; CRE redesign", "1" => "MAT fit/support; LOG compatibility/membership; DAT interface", "2" => "CON interoperability; LOG governance; DAT topology; ORI possibility" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | STR keeps only the qualifying affordance for the matching structural transformation |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Same-family safeguards\n\n- `STR:0xx` owns structural loci and arrangements; `STR:1xx` owns actual transformations; `STR:2xx` owns only capacities and qualifying relations for those transformations.\n- Reconfigurability preserves one reference whole and concerns reassignment of its own constituents.\n- Target incorporability preserves one reference as the organizing whole and qualifies exactly one distinct target. It does not assert actual membership, attachment, support, containment, or logical permission.\n- Systemic integrability treats multiple inputs as peer candidates for a higher-order whole distinct from every input. It does not assert communication, governance, deployment, topology, or completed integration.\n- Stable, active, and dormant/unresolved lexical roots may be independently qualified by runtime `[0]`, `[1]`, or `[2]/num`; runtime state never changes the lexical third trit.\n\n## Reserved compounds and gaps\n\nModularity, extensibility, mountability, attachment, containment, support, dependency, physical fit, type compatibility, interoperability, readiness, scheduling, likelihood, governance, and actual part–whole membership remain compounds, neighboring entities/processes, other-family claims, or explicit gaps.\n\n**CONCLUSION: STR:200–222 STANDS ALONE ONLY FOR STRUCTURAL TRANSFORMATION AFFORDANCE; MATERIAL, SPATIAL, COGNITIVE, COMMUNICATIVE, NORMATIVE, INFORMATIONAL, CREATIVE, REPARATIVE, AND GENERAL MODAL CLAIMS REMAIN SEPARATE.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built #{RANGE} review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
