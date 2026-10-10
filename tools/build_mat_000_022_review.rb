#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MAT:000 MAT:001 MAT:002
  MAT:010 MAT:011 MAT:012
  MAT:020 MAT:021 MAT:022
].freeze
SCORE_KEYS = %w[
  atomicity address_fit matter_family_fit neighbor_separation
  separation_from_canonical_lif_mov separation_from_mat_1xx_2xx
  cross_family_separation everyday_language_usefulness
  technical_programming_usefulness compound_usefulness
].freeze

def candidate(id, title, definition, scores, fit, coverage, territory, risk)
  raise "#{id}: expected #{SCORE_KEYS.length} scores" unless scores.length == SCORE_KEYS.length

  {
    "candidate_id" => id,
    "title" => title,
    "invariant_candidate" => definition,
    "analysis" => {
      "why_it_fits" => fit,
      "useful_coverage" => coverage,
      "semantic_territory_consumed" => territory,
      "risks_and_future_limitations" => risk
    },
    "scores" => SCORE_KEYS.zip(scores).to_h,
    "total" => scores.sum,
    "maximum" => 100
  }
end

def example(graph, literal, natural, state = 1)
  {
    "semantic_graph" => graph,
    "literal_gloss" => literal,
    "natural_english" => natural,
    "runtime_state" => state,
    "contour" => "declarative",
    "role_registers" => {
      "low" => "focal bearer or source",
      "middle" => "MAT entity/condition",
      "high" => "external object or result when present",
      "sustained" => "physical environment or persistent condition when present"
    }
  }
end

def technical(graph, interpretation, pseudocode)
  {
    "semantic_graph" => graph,
    "interpretation" => interpretation,
    "pseudocode" => pseudocode,
    "runtime_state" => 1
  }
end

ROOTS = {
  "MAT:000" => {
    "current_rationale" => "The provisional meaning chose material integrity because stable + inward + entity naturally evokes the focal being's own body persisting as one intact whole. It is useful, but 'structurally intact' consumes STR territory and competes with the future MAT:200 capacity row.",
    "candidates" => [
      candidate("current_material_integrity", "material integrity", "An entity's own body or material core is bounded, persistent, and structurally intact.",
                [8, 9, 9, 8, 9, 6, 5, 9, 9, 9],
                "It is a stable inward material condition.",
                "Intact body, physical wholeness, durable material core.",
                "The focal body's constitution plus structural soundness.",
                "Integrity is partly structural and capacity-like; damage resistance belongs later in MAT:200 and STR."),
      candidate("persistent_material_substrate", "persistent material substrate", "The enduring matter that constitutes a focal entity's physical body.",
                [10, 10, 10, 9, 10, 10, 9, 10, 10, 10],
                "It is the minimal stable inward Matter entity: the focal bearer's own enduring physical substrate.",
                "Body-as-matter, hardware substrate, material embodiment, persistent physical bearer.",
                "Only constitutive matter viewed as the focal entity's own substrate.",
                "It must not imply life, consciousness, intact organization, health, strength, or ownership."),
      candidate("bounded_physical_body", "bounded physical body", "A focal entity exists as one bounded physical body.",
                [9, 9, 9, 8, 8, 9, 6, 10, 9, 9],
                "A body is a stable inward material entity.",
                "My body, an organism's body, a robot body, a physical shell.",
                "Embodied wholeness and boundary.",
                "Body language collides with LIF identity and STR boundaries and excludes diffuse or distributed substrates."),
      candidate("material_identity", "material identity", "A focal entity retains sameness through continuity of its material constitution.",
                [8, 9, 9, 8, 6, 8, 5, 7, 9, 9],
                "Stable inward Matter can be read as physical identity.",
                "Same physical object, persistence through replacement, provenance.",
                "Criteria for material sameness over time.",
                "Identity belongs partly to LIF/ORI/LOG and creates difficult metaphysical commitments.")
    ],
    "winner" => "persistent_material_substrate",
    "recommended_title" => "persistent material substrate",
    "definition" => "The enduring matter that constitutes a focal entity's physical body.",
    "confidence" => 0.95,
    "boundaries" => [
      "Includes the constitutive matter of the focal bearer at a stable descriptive scale.",
      "May describe biological bodies, machines, artifacts, or explicitly physical computational models.",
      "Does not assert that the substrate is healthy, structurally sound, alive, conscious, powered, or currently active."
    ],
    "exclusions" => [
      "Present energetic activity of the substrate is MAT:001.",
      "Dormant substrate is MAT:002.",
      "An external object is MAT:010–012; a collective aggregate is MAT:020–022.",
      "Identity belongs to LIF, organization and boundaries to STR, damage to WRN, repair to REP, and load-bearing capacity to the later MAT:200 review."
    ],
    "mat_contrasts" => {
      "MAT:001" => "same focal substrate in a lexically active physical state",
      "MAT:002" => "same focal substrate in a lexically dormant physical state",
      "MAT:010" => "a distinct external object rather than the focal bearer's constitutive matter",
      "MAT:200 candidate layer" => "capacity to withstand load or disruption, not the substrate entity itself"
    },
    "runtime" => {
      "0" => "Denies that the asserted persistent material substrate constitutes the focal entity.",
      "1" => "Affirms the substrate as a valid enduring physical bearer, regardless of whether it is active.",
      "2" => "Marks the truth, availability, or identification of that stable-substrate assertion as dormant, remembered, possible, or unresolved; it does not select lexical MAT:002."
    },
    "ordinary" => [
      example("MAT:000[1](BEARER=robot)", "robot; persistent material substrate", "The robot still has its physical body."),
      example("MAT:000[1](BEARER=tree)", "tree; enduring constitutive matter", "The tree's material body remains present."),
      example("MAT:000[1](BEARER=ship)", "ship; persistent physical substrate", "The ship remains materially embodied even while inactive.")
    ],
    "technical" => [
      technical("MAT:000[1](BEARER=device,SUBSTRATE=hardware)", "Declares the enduring physical bearer without asserting operational state.", "assert physical_substrate(device) == hardware"),
      technical("MAT:000[1](BEARER=agent,MODEL=physical)", "Types an explicitly physical agent as materially instantiated.", "type(agent).includes(:material_substrate)")
    ],
    "compounds" => [
      "MAT:000 + STR coherent organization → intact physical body",
      "MAT:000 + LIF:000 → materially embodied continuous self",
      "MAT:000 + WRN damage condition → damaged substrate"
    ],
    "era_notes" => [
      "Later quantity grammar may attach mass, volume, composition, or continuity thresholds.",
      "Do not redefine this root as integrity; integrity is a judgment about the substrate."
    ]
  },
  "MAT:001" => {
    "current_rationale" => "The provisional energized-body meaning correctly read active inward entity as the focal substrate in an expressed physical state. Its list of energized, changing, or active readings is too loose and can accidentally absorb motion, life, and transformation.",
    "candidates" => [
      candidate("current_energized_body", "energized body", "An entity's matter or bodily substrate is presently energized, changing, or physically active.",
                [8, 9, 9, 8, 8, 8, 7, 9, 9, 9],
                "It makes the focal body materially active.",
                "Powered body, heated matter, working muscle, active hardware.",
                "Energy, physical change, and activity in one broad condition.",
                "The disjunction is non-invariant and can swallow MOV displacement, LIF activity, and MAT process roots."),
      candidate("active_material_substrate", "active material substrate", "A focal entity's material substrate in a presently energized physical state.",
                [10, 10, 10, 9, 10, 10, 9, 10, 10, 10],
                "It preserves one center: the active lexical phase of the focal material substrate.",
                "Powered hardware, energized tissue, heated or charged substrate, active physical bearer.",
                "Current energetic expression of constitutive matter.",
                "The reference scale must be explicit in technical use, and mere movement or consciousness must not be enough."),
      candidate("metabolically_active_body", "metabolically active body", "A focal body is presently sustaining material processes associated with life.",
                [9, 8, 7, 8, 7, 8, 5, 9, 8, 8],
                "Metabolism is inward material activity.",
                "Living tissue, biological activity, resource consumption.",
                "Biological physical activity.",
                "It is too narrow for Matter, collides with LIF vitality, and excludes machines and nonliving matter."),
      candidate("kinetic_material_body", "kinetic material body", "A focal material body is presently in physical motion.",
                [9, 8, 8, 7, 3, 7, 4, 9, 9, 8],
                "Motion supplies a salient active material reading.",
                "Moving body, rotating body, vibrating object.",
                "Positional or mechanical motion.",
                "It duplicates canonical MOV:101/111/121 and mistakes movement for a material-state entity.")
    ],
    "winner" => "active_material_substrate",
    "recommended_title" => "active material substrate",
    "definition" => "A focal entity's material substrate in a presently energized physical state.",
    "confidence" => 0.94,
    "boundaries" => [
      "Includes current physical energetic expression in the focal substrate at the relevant scale.",
      "May be specialized by thermal, electrical, chemical, mechanical, or biological-material modifiers.",
      "Does not require positional movement, consciousness, purpose, or an external target."
    ],
    "exclusions" => [
      "Stable substrate without active-state foregrounding is MAT:000; dormant substrate is MAT:002.",
      "Movement is MOV; life and vitality are LIF; mental activation is MIN.",
      "A material change event belongs to the future MAT:100–122 process review.",
      "Available capacity for work belongs to the future MAT:201 review rather than this entity/condition."
    ],
    "mat_contrasts" => {
      "MAT:000" => "stable constitutive matter without an active-state assertion",
      "MAT:002" => "constitutive matter without present energetic expression",
      "MAT:011" => "an active external object rather than the focal bearer's own substrate",
      "MAT:101 candidate layer" => "a physical change process affecting the substrate rather than its current active condition"
    },
    "runtime" => {
      "0" => "Denies that the focal substrate is presently in the asserted energized state.",
      "1" => "Affirms the active material-substrate condition now.",
      "2" => "Marks the active-condition token as paused, dormant, remembered, possible, or unresolved; lexical MAT:002 instead selects dormant substrate as the concept."
    },
    "ordinary" => [
      example("MAT:001[1](BEARER=person,SUBSTRATE=muscle)", "person's material substrate; energized", "My muscles are physically active."),
      example("MAT:001[1](BEARER=robot,SUBSTRATE=power_bus)", "robot substrate; energized state", "The robot's internal hardware is energized."),
      example("MAT:001[1](BEARER=engine,SUBSTRATE=core)", "engine core; active physical state", "The engine's material core is hot and active.")
    ],
    "technical" => [
      technical("MAT:001[1](BEARER=device,STATE=energized)", "A physical-state assertion, not an execution command.", "assert substrate_state(device) == ENERGIZED"),
      technical("MAT:001[1](BEARER=cell,ENERGY=chemical)", "The material substrate currently expresses chemical energy.", "physical_state(cell).energy_mode = :expressed")
    ],
    "compounds" => [
      "MAT:001 + LIF:201 → physically energized living vitality",
      "MAT:001 + MAT energy-kind modifier → thermal/electrical/chemical activation",
      "MAT:001 + WRN overload → dangerously energized substrate"
    ],
    "era_notes" => [
      "A later physical-state ontology may subtype energy modes without changing the atom.",
      "Explicitly reject 'moving therefore MAT:001'; Motion and material activity are independent assertions."
    ]
  },
  "MAT:002" => {
    "current_rationale" => "The provisional material-reserve reading tried to use dormant inward entity for retained matter or bodily substance. It usefully captured persistence without expression, but mixed inactivity, unformedness, unavailability, and resource reserve.",
    "candidates" => [
      candidate("current_material_reserve", "material reserve", "Matter or bodily substance is retained inwardly in an inactive, unformed, or unavailable state.",
                [7, 8, 9, 7, 9, 6, 6, 8, 9, 8],
                "Retained inward matter fits dormant entity.",
                "Stored bodily resource, unused material, retained substance.",
                "Inactive matter plus formation and availability status.",
                "It bundles three causes and collides with MAT:202 stored potential, STR form, and LOG availability."),
      candidate("dormant_material_substrate", "dormant material substrate", "A focal entity's material substrate persisting without presently expressed physical activity.",
                [10, 10, 10, 9, 10, 10, 9, 10, 10, 10],
                "It is the exact dormant phase of the focal substrate triplet.",
                "Unpowered body, inert sample, dormant hardware, materially present but inactive bearer.",
                "Constitutive matter in a nonexpressed physical phase.",
                "Physical inactivity is scale-relative and must not imply death, damage, unavailability, or future activation."),
      candidate("unformed_raw_material", "unformed raw material", "Matter belonging to a focal entity is present before taking a defined physical form.",
                [9, 8, 9, 7, 9, 8, 7, 9, 9, 9],
                "Unformed material is a dormant inward substance.",
                "Feedstock, undifferentiated matter, ingredients.",
                "Lack of form.",
                "It imports CRE production and STR form, and it excludes dormant but already formed bodies."),
      candidate("stored_internal_energy", "stored internal energy", "A focal entity contains physical energy that is not presently being expressed.",
                [9, 8, 9, 8, 9, 5, 8, 9, 10, 9],
                "Stored energy is a dormant inward physical entity/condition.",
                "Battery charge, chemical reserve, compressed spring energy.",
                "Latent physical energy.",
                "It duplicates the likely MAT:202 capacity meaning and leaves dormant matter without an atom.")
    ],
    "winner" => "dormant_material_substrate",
    "recommended_title" => "dormant material substrate",
    "definition" => "A focal entity's material substrate persisting without presently expressed physical activity.",
    "confidence" => 0.96,
    "boundaries" => [
      "Includes materially present constitutive substance in a lexically dormant physical phase.",
      "May describe unpowered, inert, quiescent, or stored embodiments when their matter remains the focus.",
      "Does not say whether the substrate can reactivate, why it is dormant, or whether it is alive or damaged."
    ],
    "exclusions" => [
      "Stable substrate is MAT:000; presently energized substrate is MAT:001.",
      "Dormant life is LIF:002/012/022; a dormant route is MOV:022.",
      "Stored energy capacity belongs to the later MAT:202 review.",
      "Unavailability, legal restriction, structural blockage, and missing data belong elsewhere."
    ],
    "mat_contrasts" => {
      "MAT:000" => "stable substrate without lexical dormancy",
      "MAT:001" => "substrate with present energetic expression",
      "MAT:012" => "a dormant external object rather than focal constitutive matter",
      "MAT:202 candidate layer" => "latent capacity or stored potential rather than the dormant substrate entity"
    },
    "runtime" => {
      "0" => "Denies that the focal entity has the asserted dormant material substrate.",
      "1" => "Affirms the dormant-substrate condition as currently valid.",
      "2" => "Marks whether that dormant substrate persists or is correctly identified as unresolved; this is runtime status layered over lexical dormancy."
    },
    "ordinary" => [
      example("MAT:002[1](BEARER=stored_robot)", "stored robot; dormant material substrate", "The stored robot's body remains, but it is physically inactive."),
      example("MAT:002[1](BEARER=sample)", "sample; persistent inactive matter", "The sample is materially present and inert for now."),
      example("MAT:002[1](BEARER=seed)", "seed; dormant material substrate", "The seed's physical body is dormant.", 1)
    ],
    "technical" => [
      technical("MAT:002[1](BEARER=device)", "The device remains materially instantiated while its substrate activity is absent.", "assert present(device.hardware) && substrate_activity(device) == DORMANT"),
      technical("MAT:002[1](BEARER=specimen,REFERENCE_SCALE=macro)", "Dormancy is declared at an explicit observational scale.", "material_state(specimen, scale: :macro) = DORMANT")
    ],
    "compounds" => [
      "MAT:002 + LIF:002 → dormant self with persistent physical substrate",
      "MAT:002 + MAT:202 candidate → dormant substrate retaining stored physical potential",
      "MAT:002 + WRN failure → physically inactive because of failure"
    ],
    "era_notes" => [
      "Later grammar should allow an explicit reference scale for active versus dormant material state.",
      "Do not turn dormancy into a prediction of future activation."
    ]
  },
  "MAT:010" => {
    "current_rationale" => "The provisional bounded-object meaning is already close to the minimal stable outward Matter entity. 'Can be treated as one physical target' was probably added to explain the outward axis, but targethood is contextual and need not be part of the invariant.",
    "candidates" => [
      candidate("current_bounded_object", "bounded object", "A discrete external object is materially stable and can be treated as one physical target.",
                [9, 10, 10, 9, 10, 10, 9, 10, 10, 10],
                "A stable external material entity is a bounded object.",
                "Thing, artifact, stone, component, discrete physical target.",
                "Discrete object plus contextual target role.",
                "Target wording can imply selection or purpose; boundary details belong partly to STR."),
      candidate("distinct_material_object", "distinct material object", "A materially bounded body treated as a distinct external object.",
                [10, 10, 10, 9, 10, 10, 9, 10, 10, 10],
                "It states exactly stable + outward + Matter entity without adding use or activity.",
                "Object, component, artifact, physical item, bounded resource unit.",
                "One external physical object as distinct from the focal bearer.",
                "Object individuation may be context-dependent, but that is appropriate to the outward relational frame."),
      candidate("material_resource_unit", "material resource unit", "A bounded quantity of matter is identified as an external usable resource.",
                [9, 9, 9, 8, 10, 8, 7, 9, 9, 9],
                "A resource unit is a stable external Matter entity.",
                "Fuel unit, food portion, spare part, supply item.",
                "Usability and resource role.",
                "It excludes nonresource objects and imports purpose, ownership, and availability."),
      candidate("physical_tool", "physical tool", "A stable external material object has a defined instrumental function.",
                [9, 8, 8, 7, 10, 8, 5, 10, 9, 10],
                "Tools are salient outward Matter entities.",
                "Tool, instrument, machine, implement.",
                "Designed function and use.",
                "Purpose and design belong to STR/CRE/LOG; the atom would be far too narrow.")
    ],
    "winner" => "distinct_material_object",
    "recommended_title" => "distinct material object",
    "definition" => "A materially bounded body treated as a distinct external object.",
    "confidence" => 0.98,
    "boundaries" => [
      "Includes one contextually individuated external physical object.",
      "May be natural or manufactured, useful or useless, active or inactive.",
      "Does not make the object a destination, tool, resource, possession, or data record."
    ],
    "exclusions" => [
      "The focal bearer's substrate is MAT:000–002.",
      "An active external object is MAT:011; a dormant one is MAT:012.",
      "A collective material aggregate is MAT:020–022.",
      "Purpose belongs to CRE/STR/LOG, ownership to CON, and location/movement to MOV."
    ],
    "mat_contrasts" => {
      "MAT:011" => "same external-object center with lexical physical activity",
      "MAT:012" => "same external-object center in a dormant physical phase",
      "MAT:020" => "multiple material constituents treated collectively rather than one distinct object",
      "MAT:110 candidate layer" => "creation/transformation result or process, not objecthood itself"
    },
    "runtime" => {
      "0" => "Denies that the referent is the asserted distinct material object.",
      "1" => "Affirms the stable object classification.",
      "2" => "Marks the object's identification, persistence, or availability as unresolved or dormant; it does not select lexical MAT:012."
    },
    "ordinary" => [
      example("MAT:010[1](OBJECT=stone)", "stone; distinct material object", "That stone is one physical object."),
      example("MAT:010[1](OBJECT=cup)", "cup; bounded material body", "The cup is a distinct object."),
      example("MAT:010[1](OBJECT=bolt)", "bolt; stable external object", "This bolt is the physical item I mean.")
    ],
    "technical" => [
      technical("MAT:010[1](OBJECT=component_17)", "Creates a material-object node without assigning function.", "assert type(component_17) == MATERIAL_OBJECT"),
      technical("MAT:010[1](OBJECT=mesh,BOUNDARY=b)", "An engine may bind a geometry boundary while keeping objecthood semantic.", "object(mesh).material_boundary = b")
    ],
    "compounds" => [
      "MAT:010 + CRE designed function → tool or artifact",
      "MAT:010 + CON ownership → possessed object",
      "MAT:010 + MOV:010 destination role → physical destination object"
    ],
    "era_notes" => [
      "A later classifier layer may distinguish count objects, portions, and continuous substances.",
      "Do not hard-code artifact, target, or resource roles into the atom."
    ]
  },
  "MAT:011" => {
    "current_rationale" => "The provisional active-implement meaning made an external object active by listing force, energy consumption, and physical work. It is practical, but 'implement' adds purpose and the list mixes object state with several processes.",
    "candidates" => [
      candidate("current_active_implement", "active implement", "An external material object is presently exerting force, consuming energy, or performing physical work.",
                [7, 8, 9, 7, 9, 7, 6, 9, 9, 9],
                "An implement in use is an active outward material entity.",
                "Working tool, powered machine, actuator, active device.",
                "Purpose plus force, consumption, and work processes.",
                "It is non-atomic and collides with CRE function, MAT:111 processes, and MAT:201 capacity."),
      candidate("active_material_object", "active material object", "A distinct external material object in a presently energized physical state.",
                [10, 10, 10, 9, 10, 10, 9, 10, 10, 10],
                "It is the direct active phase of the external-object triplet.",
                "Powered object, hot object, charged component, physically active machine.",
                "Current energetic state of one external physical object.",
                "It must not imply use, purpose, motion, force transfer, or capability."),
      candidate("external_energy_source", "external energy source", "A distinct external object presently supplies physical energy.",
                [9, 8, 9, 8, 9, 7, 8, 9, 10, 9],
                "A source is outward and active in Matter.",
                "Battery, generator, heater, fuel source.",
                "Energy-provision role.",
                "It narrows the row to one role and turns an entity into a transfer process/source relation."),
      candidate("object_under_force", "object under force", "A distinct external material object is presently subject to physical force.",
                [9, 9, 9, 8, 9, 7, 8, 9, 10, 9],
                "Force makes the object's material condition active.",
                "Loaded beam, pressed object, accelerating mass.",
                "Current force-bearing condition.",
                "It excludes active thermal/chemical states and depends on future MAT relationship/process semantics.")
    ],
    "winner" => "active_material_object",
    "recommended_title" => "active material object",
    "definition" => "A distinct external material object in a presently energized physical state.",
    "confidence" => 0.95,
    "boundaries" => [
      "Includes one external object's current physical energetic expression.",
      "May be powered, heated, charged, reacting, or otherwise materially active at the relevant scale.",
      "Does not imply purpose, usefulness, movement, agency, or transfer to a target."
    ],
    "exclusions" => [
      "Stable object is MAT:010; dormant object is MAT:012.",
      "Movement is MOV; data execution is DAT/LOG; biological activity is LIF.",
      "Force or energy transfer is a future MAT process/relationship question.",
      "Usable work capacity belongs to the later MAT:201 review."
    ],
    "mat_contrasts" => {
      "MAT:010" => "external object without active-state foregrounding",
      "MAT:012" => "external object without present energetic expression",
      "MAT:001" => "the focal bearer's own active substrate rather than an external object",
      "MAT:111 candidate layer" => "the event of applying or transferring physical influence, not the active object"
    },
    "runtime" => {
      "0" => "Denies that the external object is presently in the active material state.",
      "1" => "Affirms the active material-object condition.",
      "2" => "Marks the active-object assertion as dormant, paused, remembered, possible, or unresolved; lexical MAT:012 instead names a dormant object."
    },
    "ordinary" => [
      example("MAT:011[1](OBJECT=drill)", "drill; active material object", "The drill is physically active."),
      example("MAT:011[1](OBJECT=capacitor)", "capacitor; energized external object", "The capacitor is charged."),
      example("MAT:011[1](OBJECT=metal_block)", "metal block; active thermal state", "That metal block is hot and physically active.")
    ],
    "technical" => [
      technical("MAT:011[1](OBJECT=actuator,STATE=energized)", "Asserts object state without commanding or measuring it.", "assert material_state(actuator) == ACTIVE"),
      technical("MAT:011[1](OBJECT=reactor_cell)", "Represents an active physical entity node, with process edges separate.", "graph.add_entity(reactor_cell, MAT_011)")
    ],
    "compounds" => [
      "MAT:011 + CRE instrumental function → active tool",
      "MAT:011 + MAT process edge → object actively transferring force or energy",
      "MAT:011 + WRN hazardous state → dangerously active material object"
    ],
    "era_notes" => [
      "Later energy-mode vocabulary should specialize the active state compositionally.",
      "Keep implement and machine roles out of the invariant."
    ]
  },
  "MAT:012" => {
    "current_rationale" => "The provisional latent-material-target meaning attempted to cover identified but inaccessible, unformed, or inactive things. Those are three unrelated reasons and targethood is not inherent to a dormant external entity.",
    "candidates" => [
      candidate("current_latent_material_target", "latent material target", "A material object or resource is identified but remains inaccessible, unformed, or physically inactive.",
                [6, 8, 9, 6, 9, 8, 5, 7, 8, 7],
                "An identified external thing can occupy a dormant phase.",
                "Unavailable resource, unformed target, inactive tool.",
                "Object/resource identity plus access, form, and activity.",
                "It is non-atomic and collides with CON/LOG access, CRE formation, and STR form."),
      candidate("dormant_material_object", "dormant material object", "A distinct external material object persisting without presently expressed physical activity.",
                [10, 10, 10, 9, 10, 10, 9, 10, 10, 10],
                "It is the exact dormant phase of the external-object triplet.",
                "Unpowered device, inert object, inactive component, stored physical item.",
                "One external object in a nonexpressed physical phase.",
                "It must not imply inaccessibility, damage, reserve status, future use, or absence."),
      candidate("stored_material_object", "stored material object", "A distinct material object is retained outside present use.",
                [9, 9, 9, 8, 10, 9, 7, 10, 9, 9],
                "Storage is a natural dormant external-entity state.",
                "Put-away tool, archived part, warehoused object.",
                "Functional nonuse and retention.",
                "Storage is a STR location/role plus timing; dormant objects need not be stored."),
      candidate("unformed_artifact", "unformed artifact", "A material object is identified by intended result although its physical form is not realized.",
                [8, 8, 8, 7, 9, 7, 5, 8, 9, 9],
                "An unformed target is outward and dormant.",
                "Blank, future part, raw workpiece, unrealized product.",
                "Design intention and nonrealized form.",
                "It belongs to CRE possibility and may not yet be a material object at all.")
    ],
    "winner" => "dormant_material_object",
    "recommended_title" => "dormant material object",
    "definition" => "A distinct external material object persisting without presently expressed physical activity.",
    "confidence" => 0.97,
    "boundaries" => [
      "Includes an existing distinct external object in a lexically dormant material phase.",
      "May describe unpowered, inert, quiescent, or stored objects when inactivity is foregrounded.",
      "Does not assert access, ownership, damage, purpose, or future activation."
    ],
    "exclusions" => [
      "Stable object is MAT:010; active object is MAT:011.",
      "Dormant focal substrate is MAT:002; dormant aggregate is MAT:022.",
      "Inaccessibility belongs to CON/LOG/STR depending the cause.",
      "Unformed possibility belongs to CRE/ORI; failure to WRN; stored energy capacity to later MAT:202."
    ],
    "mat_contrasts" => {
      "MAT:010" => "same object center without lexical dormancy",
      "MAT:011" => "same object center with present energetic expression",
      "MAT:002" => "focal constitutive substrate rather than external object",
      "MAT:022" => "collective material aggregate rather than one object"
    },
    "runtime" => {
      "0" => "Denies that the referent is the asserted dormant material object.",
      "1" => "Affirms the dormant-object condition.",
      "2" => "Marks the status or persistence of that dormant object as itself unresolved; runtime uncertainty does not replace lexical dormancy."
    },
    "ordinary" => [
      example("MAT:012[1](OBJECT=unplugged_drill)", "drill; dormant material object", "The unplugged drill is physically inactive."),
      example("MAT:012[1](OBJECT=stored_sensor)", "sensor; dormant external object", "The stored sensor remains an object, but it is dormant."),
      example("MAT:012[1](OBJECT=cold_reactor_part)", "reactor part; no expressed physical activity", "The reactor component is cold and inactive.")
    ],
    "technical" => [
      technical("MAT:012[1](OBJECT=device)", "The object node exists while its material activity state is dormant.", "assert exists(device) && material_state(device) == DORMANT"),
      technical("MAT:012[1](OBJECT=component,REFERENCE_SCALE=operational)", "Operational dormancy is explicitly scoped.", "classify(component, MAT_012, scale: :operational)")
    ],
    "compounds" => [
      "MAT:012 + STR storage relation → stored inactive object",
      "MAT:012 + WRN failure → failed inactive object",
      "MAT:012 + LOG permission[0] → dormant object that is also unavailable by rule"
    ],
    "era_notes" => [
      "A later object-state vocabulary may distinguish off, inert, cooled, and discharged.",
      "Do not make dormancy synonymous with inaccessible or broken."
    ]
  },
  "MAT:020" => {
    "current_rationale" => "The provisional material-system meaning recognized that a stable collective Matter entity should contain multiple physical constituents. Its wording mixed matter, bodies, energy, resources, arrangement, boundary, and system structure.",
    "candidates" => [
      candidate("current_material_system", "material system", "A shared arrangement of matter, bodies, energy, or resources is stable as a bounded physical system.",
                [8, 10, 9, 8, 10, 9, 6, 9, 10, 9],
                "A stable shared Matter entity naturally reads as a material system.",
                "Physical system, resource system, collection of bodies, bounded environment.",
                "Constituents, arrangement, boundary, energy, and resources.",
                "System and arrangement collide with STR; the list is too broad for one invariant."),
      candidate("stable_material_aggregate", "stable material aggregate", "A collection of material constituents treated as one persistent physical aggregate.",
                [10, 10, 10, 9, 10, 10, 9, 10, 10, 10],
                "It is a stable collective Matter entity without importing organization or process.",
                "Batch, pile, body of material, inventory-as-physical-stock, physical ensemble.",
                "Collective material membership and persistence.",
                "It must not imply structural organization, functional systemhood, exchange, circulation, or conservation."),
      candidate("material_kind", "material kind", "A stable class groups entities by shared physical substance or composition.",
                [9, 8, 9, 8, 10, 9, 7, 9, 9, 9],
                "Collective can denote a shared kind, paralleling LIF:020 life-kind.",
                "Metal, water, polymer, fuel type, substance class.",
                "Classification by material composition.",
                "Kind/class semantics lean LOG/DAT and cannot represent actual aggregates or stocks."),
      candidate("physical_environment", "physical environment", "A stable shared physical medium surrounds or contains material entities.",
                [8, 9, 9, 7, 9, 9, 6, 9, 10, 9],
                "Environment is directly licensed by second-trit systemic/shared.",
                "Air, water medium, terrain, ambient material context.",
                "Surrounding physical medium.",
                "It imports containment and space from STR/MOV and is only one subtype of collective matter.")
    ],
    "winner" => "stable_material_aggregate",
    "recommended_title" => "stable material aggregate",
    "definition" => "A collection of material constituents treated as one persistent physical aggregate.",
    "confidence" => 0.94,
    "boundaries" => [
      "Includes multiple material constituents grouped as one physical aggregate.",
      "The grouping may be continuous, granular, mixed, distributed, natural, or manufactured.",
      "Does not assert topology, organization, purpose, exchange, circulation, ownership, or quantity."
    ],
    "exclusions" => [
      "One external object is MAT:010–012; focal constitutive substrate is MAT:000–002.",
      "Active aggregate is MAT:021; dormant aggregate is MAT:022.",
      "Structural systemhood belongs to STR; material flow to later MAT processes and MOV where displacement is asserted.",
      "Classification by kind and exact quantity require LOG/grammar."
    ],
    "mat_contrasts" => {
      "MAT:021" => "same collective center with present internal energetic interaction",
      "MAT:022" => "same collective center without present collective activity",
      "MAT:010" => "one distinct object rather than multiple constituents treated collectively",
      "MAT:120 candidate layer" => "completion of a systemic material process rather than the aggregate entity"
    },
    "runtime" => {
      "0" => "Denies that the constituents form the asserted stable material aggregate.",
      "1" => "Affirms the persistent aggregate as a valid collective material entity.",
      "2" => "Marks the aggregate's membership, persistence, or identification as dormant or unresolved; it does not select lexical MAT:022."
    },
    "ordinary" => [
      example("MAT:020[1](AGGREGATE=sand_pile,CONSTITUENTS=grains)", "grains; stable material aggregate", "The pile of sand is one material aggregate."),
      example("MAT:020[1](AGGREGATE=batch,CONSTITUENTS=alloy_pieces)", "alloy pieces; persistent aggregate", "This batch of alloy is a stable physical collection."),
      example("MAT:020[1](AGGREGATE=water_body,CONSTITUENTS=water)", "water; shared material aggregate", "The tank contains one body of material.")
    ],
    "technical" => [
      technical("MAT:020[1](AGGREGATE=batch_42,MEMBERS=parts)", "Groups physical constituents without asserting structural edges.", "aggregate(batch_42).members = parts"),
      technical("MAT:020[1](AGGREGATE=continuum,MODEL=material)", "Declares a material ensemble node for simulation.", "model.add_material_aggregate(continuum)")
    ],
    "compounds" => [
      "MAT:020 + STR organization → material system",
      "MAT:020 + LOG quantity → measured material stock",
      "MAT:020 + CON ownership → owned resource inventory"
    ],
    "era_notes" => [
      "A later classifier/quantity system may distinguish continuous substance, count collection, and mixture.",
      "Do not make aggregate membership imply structural organization."
    ]
  },
  "MAT:021" => {
    "current_rationale" => "The provisional resource-circulation meaning tried to make the collective entity active by describing matter, energy, or resources moving through a system. That is a process and collides with MOV flow and the future MAT:121 process slot.",
    "candidates" => [
      candidate("current_resource_circulation", "resource circulation", "Matter, energy, or resources are actively circulating through an environment or distributed system.",
                [6, 7, 9, 6, 6, 3, 6, 9, 9, 8],
                "Circulation is systemic, shared, and active within Matter.",
                "Resource flow, energy circulation, material transport.",
                "A movement/exchange process across a system.",
                "It is a disguised process and duplicates MOV:021/121 plus the future MAT:121 slot."),
      candidate("active_material_aggregate", "active material aggregate", "A material aggregate whose constituents are presently in collective energetic interaction.",
                [10, 10, 10, 9, 10, 10, 9, 9, 10, 10],
                "It makes the collective entity active without naming the process that produces activity.",
                "Reacting mixture, energized physical ensemble, active reactor material, interacting resource stock.",
                "Current collective energetic state of multiple material constituents.",
                "Interaction must remain physical and collective; coordination, structure, movement, and data flow remain separate."),
      candidate("active_material_medium", "active material medium", "A shared material medium presently transmits physical influence among embedded entities.",
                [8, 8, 9, 8, 9, 7, 7, 9, 10, 9],
                "A medium is a shared active material entity.",
                "Conducting medium, fluid, atmosphere, pressure medium.",
                "Transmission through a shared substance.",
                "It narrows the collective row and imports CON transmission and MAT process semantics."),
      candidate("resource_supply_in_use", "resource supply in use", "A collective material supply is presently being consumed or deployed.",
                [7, 8, 9, 7, 9, 6, 6, 10, 9, 9],
                "A supply in use is an active collective Matter entity.",
                "Fuel supply, active inventory, food stock in use.",
                "Functional deployment and consumption.",
                "Use and consumption are processes/roles, not the entity's invariant physical state.")
    ],
    "winner" => "active_material_aggregate",
    "recommended_title" => "active material aggregate",
    "definition" => "A material aggregate whose constituents are presently in collective energetic interaction.",
    "confidence" => 0.92,
    "boundaries" => [
      "Includes a multi-constituent material entity in a currently active collective physical state.",
      "Constituents may exchange energy, force, or matter internally, but the root selects the aggregate condition rather than an exchange event.",
      "Does not require organized structure, circulation, transport, purpose, or external coordination."
    ],
    "exclusions" => [
      "Stable aggregate is MAT:020; dormant aggregate is MAT:022.",
      "Flow or displacement is MOV; material exchange events belong to the future MAT:120–122 review.",
      "Network structure belongs to STR; coordination to CON; measured telemetry to DAT.",
      "A single active object is MAT:011."
    ],
    "mat_contrasts" => {
      "MAT:020" => "collective material entity without active-state foregrounding",
      "MAT:022" => "collective material entity without present energetic interaction",
      "MAT:011" => "one active external object rather than an interacting aggregate",
      "MAT:121 candidate layer" => "the systemic material exchange process rather than the active aggregate entity"
    },
    "runtime" => {
      "0" => "Denies that the aggregate is presently in collective energetic interaction.",
      "1" => "Affirms the active material-aggregate condition.",
      "2" => "Marks the active-aggregate assertion as suspended, dormant, possible, or unresolved; lexical MAT:022 instead selects dormant aggregate."
    },
    "ordinary" => [
      example("MAT:021[1](AGGREGATE=reacting_mixture)", "mixture; active material aggregate", "The mixture is physically active as a whole."),
      example("MAT:021[1](AGGREGATE=reactor_core)", "reactor material; collective energetic interaction", "The reactor core's material is active."),
      example("MAT:021[1](AGGREGATE=storm_cloud)", "cloud constituents; active physical aggregate", "The cloud is an active material system.")
    ],
    "technical" => [
      technical("MAT:021[1](AGGREGATE=mesh,MEMBERS=cells)", "Declares current collective material activity while process edges remain separate.", "aggregate_state(mesh) = ACTIVE"),
      technical("MAT:021[1](AGGREGATE=plasma,INTERACTION=energetic)", "Types the ensemble condition for a physics model.", "assert collective_interaction(plasma).physical?")
    ],
    "compounds" => [
      "MAT:021 + STR organized network → active material system",
      "MAT:021 + MAT systemic process → aggregate undergoing material exchange",
      "MAT:021 + MOV:121 → materially active aggregate also changing shared-frame position"
    ],
    "era_notes" => [
      "A later physics layer may distinguish reaction, conduction, pressure, and exchange modes.",
      "The entity root must not become a synonym for resource flow."
    ]
  },
  "MAT:022" => {
    "current_rationale" => "The provisional dormant-stock meaning is useful and close to the slot because a reserve is a dormant collective material entity. It is narrower than the full systemic/entity position and adds a functional resource role.",
    "candidates" => [
      candidate("current_dormant_stock", "dormant stock", "A collective supply of material or energy exists in reserve but is not currently circulating or being used.",
                [8, 9, 9, 8, 9, 9, 8, 10, 10, 10],
                "A reserve stock is a natural dormant collective Matter entity.",
                "Inventory, fuel reserve, stored material, unused energy supply.",
                "Collective resource role plus nonuse/noncirculation.",
                "It excludes dormant nonresources and imports purpose, availability, use, and flow."),
      candidate("dormant_material_aggregate", "dormant material aggregate", "A material aggregate persisting without presently expressed collective physical activity.",
                [10, 10, 10, 9, 10, 10, 9, 10, 10, 10],
                "It is the direct dormant phase of the material-aggregate triplet.",
                "Stored stock, inert mixture, inactive system material, reserve collection.",
                "Collective material entity in a nonexpressed physical phase.",
                "It must not imply reserve purpose, storage location, scarcity, usability, or future activity."),
      candidate("inactive_material_system", "inactive material system", "A shared physical system persists while its material interactions are inactive.",
                [9, 9, 9, 9, 10, 9, 7, 9, 9, 9],
                "Systemic dormancy is well expressed.",
                "Shutdown plant, cold network, inactive reactor.",
                "Dormant organized system.",
                "System structure belongs to STR and excludes unorganized aggregates."),
      candidate("unrealized_material_collection", "unrealized material collection", "A possible collective body of matter has not yet been assembled.",
                [8, 7, 8, 7, 9, 7, 5, 7, 8, 8],
                "Dormant/potential can suggest a collection not yet realized.",
                "Future stock, unassembled batch, possible resource pool.",
                "Nonexistent possible aggregate.",
                "The slot is a dormant entity, not necessarily unrealized; this collides with CRE/ORI possibility and future MAT:222.")
    ],
    "winner" => "dormant_material_aggregate",
    "recommended_title" => "dormant material aggregate",
    "definition" => "A material aggregate persisting without presently expressed collective physical activity.",
    "confidence" => 0.96,
    "boundaries" => [
      "Includes an existing multi-constituent material aggregate in a lexically dormant collective state.",
      "Reserve stocks, stored batches, inert mixtures, and inactive system matter are valid contextual readings.",
      "Does not assert purpose, storage, accessibility, scarcity, future use, or ability to reactivate."
    ],
    "exclusions" => [
      "Stable aggregate is MAT:020; active aggregate is MAT:021.",
      "One dormant external object is MAT:012; focal dormant substrate is MAT:002.",
      "Resource role, ownership, location, and quantity require compounds or grammar.",
      "Unrealized material configuration belongs to the later MAT:222 review; dormant routes belong to MOV:022."
    ],
    "mat_contrasts" => {
      "MAT:020" => "collective entity without lexical dormancy",
      "MAT:021" => "collective entity with present energetic interaction",
      "MAT:012" => "one dormant external object rather than a collective aggregate",
      "MAT:222 candidate layer" => "unrealized material-system possibility rather than an existing dormant aggregate"
    },
    "runtime" => {
      "0" => "Denies that the asserted dormant material aggregate exists or remains dormant.",
      "1" => "Affirms the dormant aggregate as a valid present material entity.",
      "2" => "Marks the dormant aggregate's persistence, membership, or status as itself unresolved; this is second-order runtime status."
    },
    "ordinary" => [
      example("MAT:022[1](AGGREGATE=fuel_stock)", "fuel constituents; dormant material aggregate", "The fuel stock remains physically dormant."),
      example("MAT:022[1](AGGREGATE=stored_parts)", "parts; inactive material aggregate", "The stored batch of parts is inactive."),
      example("MAT:022[1](AGGREGATE=inert_mixture)", "mixture; no collective physical activity", "The mixture remains present but inert.")
    ],
    "technical" => [
      technical("MAT:022[1](AGGREGATE=inventory,MEMBERS=items)", "Inventory is materially present while collective activity is absent.", "assert exists(inventory) && aggregate_state(inventory) == DORMANT"),
      technical("MAT:022[1](AGGREGATE=reactor_material)", "Represents shutdown material state without asserting damage or capacity.", "classify(reactor_material, MAT_022)")
    ],
    "compounds" => [
      "MAT:022 + LOG quantity + CON ownership → reserve inventory",
      "MAT:022 + STR storage location → stored material stock",
      "MAT:022 + MAT:202 candidate → dormant aggregate retaining stored physical potential"
    ],
    "era_notes" => [
      "A later resource ontology may distinguish reserve, waste, inventory, feedstock, and surplus.",
      "Keep those functional labels compositional rather than narrowing this atom."
    ]
  }
}.freeze

def cross_family_for(id)
  scope =
    case id[4, 2]
    when "00" then "focal material substrate"
    when "01" then "distinct external material object"
    else "material aggregate"
    end
  phase =
    case id[-1]
    when "0" then "stable"
    when "1" then "physically active"
    else "dormant"
    end

  {
    "LIF" => "LIF owns living identity, consciousness, viability, and vitality. MAT:#{id[-3, 3]} denotes a #{phase} #{scope} and never implies life.",
    "MOV" => "MOV owns position and displacement. Movement alone does not make this MAT root active; material energetic state must be independently foregrounded.",
    "MIN" => "MIN owns attention, perception, intention, and mental state. Mental activation or an idea of an object is not the material entity.",
    "CON" => "CON owns ownership, access, linkage, communication, and coordination. Those relations may connect to the #{scope} but are not part of it.",
    "STR" => "STR owns boundary rules, topology, containment, organization, and functional system structure. MAT owns physical substance/entity state only.",
    "WRN" => "WRN owns damage, hazard, failure, corruption, and risk. A #{phase} material entity is not necessarily safe, intact, or failed.",
    "REP" => "REP owns repair, healing, and restoration. A repaired result may use MAT, but repair status is not material entity phase.",
    "LOG" => "LOG owns classification rules, permission, quantities as formal values, and constraint judgments. Validity or availability is not built into this MAT atom.",
    "DAT" => "DAT owns records, sensor readings, models, and identifiers. Information about a #{scope} is not the physical referent.",
    "CRE" => "CRE owns design, fabrication, generation, and transformation. Natural or manufactured origin does not change the MAT entity invariant.",
    "ORI" => "ORI owns existence, reality, universality, and ontological possibility. MAT applies only when a physical substrate/object/aggregate is asserted."
  }
end

atoms = YAML.load_file(File.join(ROOT, "lexicon/atoms.yaml")).fetch("atoms")
fixed = IDS.to_h do |id|
  record = atoms.find { |atom| atom["canonical_id"] == id } || raise("missing #{id}")
  [id, {
    "canonical_id" => record["canonical_id"],
    "family" => record["family"],
    "address" => record["address"],
    "universal_slot" => record["universal_slot"],
    "family_onset" => record["family_onset"],
    "family_qualified_transliteration" => record["canonical_transliteration"],
    "local_compact_root" => record["local_compact_root"],
    "formal_carrier" => record["formal_carrier"],
    "harmonic_signature_semitones" => record["harmonic_signature_semitones"],
    "relative_note_path_semitones" => record["note_path_semitones"]
  }]
end

scored = {
  "metadata" => {
    "title" => "MAT:000–022 scored semantic candidates",
    "status" => "peer_review_recommendations_not_canonical",
    "roots_reviewed" => 9,
    "candidates_per_root_minimum" => 4,
    "generated_fields_changed" => false,
    "semantic_dependency_on_mov_200_222" => false,
    "score_role" => "Decision aid only; written reasoning is authoritative."
  },
  "scoring" => {
    "scale" => "1–10",
    "categories" => SCORE_KEYS,
    "maximum_total" => 100
  },
  "roots" => IDS.map do |id|
    data = ROOTS.fetch(id)
    atom = atoms.find { |record| record["canonical_id"] == id }
    {
      "canonical_id" => id,
      "authority_status" => "provisional_pending_user_decision",
      "fixed_generated_fields" => fixed.fetch(id),
      "current_provisional_meaning" => {
        "title" => atom["title"],
        "definition" => atom["core_definition"],
        "probable_rationale" => data["current_rationale"]
      },
      "candidates" => data["candidates"],
      "recommended_winner" => data["winner"],
      "recommended_title" => data["recommended_title"],
      "recommended_invariant_definition" => data["definition"],
      "confidence" => data["confidence"],
      "canonicalized" => false
    }
  end
}

recommended = {
  "metadata" => {
    "title" => "MAT:000–022 recommended semantic specification",
    "status" => "ready_for_user_approval_not_canonical",
    "architecture_version" => "1.0",
    "canonical_baseline" => "LIF:000–222 and MOV:000–122",
    "noncanonical_review_context" => ["MOV:200–222"],
    "generated_fields_changed" => false,
    "roots_canonicalized" => [],
    "stop_boundary" => ["MAT:100–122", "any other root block", "Gate 4", "translator implementation"]
  },
  "layer_design" => {
    "first_trit" => "entity, substance, or condition; never a disguised process or capacity",
    "row_00x" => "focal material substrate: persistent / physically active / dormant",
    "row_01x" => "distinct external material object: stable / physically active / dormant",
    "row_02x" => "material aggregate: stable / physically active / dormant",
    "activity_invariant" => "The active lexical phase foregrounds physical energetic expression at the relevant scale. Positional movement, life, cognition, data execution, or social activity alone is insufficient.",
    "parallelism_assessment" => "The three rows share one scope progression—constitutive substrate, external object, collective aggregate—and one phase progression—stable, physically active, dormant."
  },
  "roots" => IDS.map do |id|
    data = ROOTS.fetch(id)
    {
      "authority_status" => "recommended_not_canonical",
      "fixed_generated_fields" => fixed.fetch(id),
      "recommended_title" => data["recommended_title"],
      "invariant_definition" => data["definition"],
      "confidence" => data["confidence"],
      "semantic_boundaries" => data["boundaries"],
      "excluded_meanings" => data["exclusions"],
      "nearest_mat_contrasts" => data["mat_contrasts"],
      "cross_family_comparisons" => cross_family_for(id),
      "address_explanation" => {
        "first_trit_0" => "Selects a physical entity, substance, or condition rather than a material event or capacity.",
        "second_trit" =>
          case id[5]
          when "0" then "Inward/self/source selects the focal bearer's constitutive substrate."
          when "1" then "Outward/other/target selects a distinct external physical object."
          else "Shared/environmental/systemic selects multiple material constituents treated collectively."
          end,
        "third_trit" =>
          case id[6]
          when "0" then "Stable/bounded selects enduring or established material entity status."
          when "1" then "Active/changing/expressed selects present physical energetic expression."
          else "Dormant/unresolved/potential selects existing material entity status without present physical activity."
          end
      },
      "runtime_state_interpretations" => data["runtime"],
      "ordinary_language_examples" => data["ordinary"],
      "technical_programming_examples" => data["technical"],
      "future_compound_decomposition_sketches_not_canonical" => data["compounds"],
      "later_era_evolution_notes" => data["era_notes"]
    }
  end
}

stress_rows = [
  ["body", "composition", "MAT:000 + role/context", "The root owns constitutive matter; biological identity still requires LIF."],
  ["physical self", "composition", "LIF:000 + MAT:000", "Identity and material substrate are independent."],
  ["corpse", "composition", "MAT:000 or MAT:002 + LIF state/absence + WRN/ORI as needed", "Death is not reducible to dormant matter."],
  ["matter", "direct proposed root", "MAT:000, MAT:010, or MAT:020 by scope", "English matter underspecifies focal substrate, object, or aggregate."],
  ["substance", "composition", "MAT:020 + kind/classifier", "A substance kind needs classification beyond aggregate existence."],
  ["material", "grammar or modifier", "MAT family typing", "Adjectival material normally modifies another concept."],
  ["object", "direct proposed root", "MAT:010", "Distinct external material object."],
  ["thing", "unresolved lexical ambiguity", "MAT:010 only when physical", "Thing may be abstract, living, informational, or physical."],
  ["tool", "composition", "MAT:010/011 + CRE/STR function", "Instrumental purpose is not material objecthood."],
  ["machine", "composition", "MAT object/aggregate + STR organization + CRE function", "Machine is a structured functional artifact."],
  ["device", "composition", "MAT:010 + STR/CRE function", "Devicehood is functional."],
  ["active machine", "composition", "MAT:011 or MAT:021 + STR machine structure", "Material activity and machine organization are separate."],
  ["inactive machine", "composition", "MAT:012 or MAT:022 + STR machine structure", "Dormant material entity plus machine structure."],
  ["resource", "composition", "MAT entity + LOG/CON/CRE use-role", "Resource is a contextual usability relation."],
  ["raw material", "composition", "MAT:020/022 + CRE unformed role", "Rawness is relative to a creation process."],
  ["fuel", "composition", "MAT entity + MAT:202 candidate energy potential + use-role", "Requires the later capacity review."],
  ["food", "composition", "MAT entity + LIF nourishment relation", "Food is matter in a life-support role."],
  ["water", "composition", "MAT:020 + substance-kind classifier", "The atomic root supplies aggregate matter, not chemical identity."],
  ["air", "composition", "MAT:020 + gas/medium classifier", "Material aggregate plus phase/kind."],
  ["energy", "unresolved lexical ambiguity", "MAT:001, MAT:011/021, or later MAT:201/202 by sense", "Expressed state, bearer, available work, and stored potential are distinct."],
  ["power", "MAT later layer", "likely MAT:201 + quantity/time", "Power is a rate/capacity concept, not an entity root."],
  ["charge", "composition", "active/dormant MAT entity + physical-state modifier", "Charge type and magnitude need physical/quantity vocabulary."],
  ["heat", "composition", "MAT:001/011/021 + thermal modifier", "Thermal activity specializes material activity."],
  ["temperature", "grammar or quantity", "MAT entity + LOG quantity + thermal scale", "A measured scalar is not an atomic entity."],
  ["mass", "grammar or quantity", "MAT entity + quantitative property", "Mass belongs to the later property/quantity layer."],
  ["weight", "composition", "MAT entity + force relation + quantity", "Weight depends on force and frame."],
  ["volume", "grammar or quantity", "MAT entity + STR spatial extent + quantity", "Volume is measured extent."],
  ["size", "grammar or quantity", "MAT/MOV/STR extent + quantity", "Context determines the domain."],
  ["shape", "different future family", "STR form/configuration", "Shape is structural organization of a material bearer."],
  ["boundary", "different future family", "STR boundary + MAT bearer", "Boundary is structural, though physically instantiated."],
  ["part", "composition", "MAT:010 + STR part-whole relation", "Part is a structural relationship."],
  ["whole", "composition", "MAT entity + STR whole relation", "Wholeness is not material substance alone."],
  ["collection", "direct proposed root", "MAT:020", "When the collection is explicitly material."],
  ["aggregate", "direct proposed root", "MAT:020/021/022 by phase", "Phase distinguishes stable, active, and dormant aggregate."],
  ["stock", "composition", "MAT:020/022 + quantity + resource role", "Stock is a material aggregate in an inventory role."],
  ["reserve", "composition", "MAT:022 + capacity/use-role", "Reserve purpose is not lexical dormancy itself."],
  ["supply", "composition", "MAT aggregate + CON access + LOG availability", "Supply is a relational/functional reading."],
  ["inventory", "composition", "MAT aggregate + DAT record + CON ownership", "Physical stock and inventory record are distinct."],
  ["powered", "direct proposed root", "MAT:001 or MAT:011", "Scope chooses focal substrate or external object."],
  ["unpowered", "direct proposed root", "MAT:002 or MAT:012", "Dormant material state; cause may require more roots."],
  ["hot", "composition", "MAT active root + thermal modifier", "Hot is a quantitative thermal specialization."],
  ["cold", "composition", "MAT stable/dormant root + thermal modifier", "Cold does not necessarily mean dormant."],
  ["solid", "composition", "MAT entity + material-phase classifier", "Phase-of-matter vocabulary is not yet atomic."],
  ["liquid", "composition", "MAT aggregate + material-phase classifier", "Liquid is a material kind/phase."],
  ["gas", "composition", "MAT aggregate + material-phase classifier", "Gas is a material kind/phase."],
  ["plasma", "composition", "MAT:021 + material-phase classifier", "Often active aggregate, but plasma identity needs a classifier."],
  ["hard", "MAT later layer", "MAT:200/210 candidate property relation", "Hardness is a capacity/property, not an entity."],
  ["soft", "MAT later layer", "MAT:200/210 candidate property relation", "Softness is a response property."],
  ["flexible", "MAT later layer", "MAT:200 plus STR deformation relation", "Flexibility is a material/structural capacity."],
  ["rigid", "MAT later layer", "MAT:200 plus STR form retention", "Rigidity is capacity to resist deformation."],
  ["strong", "MAT later layer", "MAT:200 + load relation", "Strength is capacity."],
  ["weak", "root plus runtime or later property", "MAT:200[0] candidate + quantity", "Requires approval of the capacity layer."],
  ["dense", "grammar or quantity", "MAT aggregate + mass/volume ratio", "Density is derived quantity."],
  ["sparse", "grammar or quantity", "MAT aggregate + low density/distribution", "Sparse is structural/quantitative."],
  ["intact", "composition", "MAT:000/010/020 + STR coherence + WRN[0]", "Integrity is intentionally not atomic here."],
  ["broken", "different future family", "WRN failure/damage + MAT bearer", "Brokenness is a warning/failure condition."],
  ["damaged", "different future family", "WRN damage + MAT bearer", "Matter supplies the affected entity."],
  ["repaired", "canonical/future other family", "REP restoration + MAT bearer", "Repair status is not a material entity phase."],
  ["force", "MAT later layer", "MAT:111/210/211 candidate review", "Force is a process/relationship, not a 0xx entity."],
  ["pressure", "composition", "MAT aggregate + force/area quantity", "Pressure is a derived physical relation."],
  ["chemical reaction", "MAT later layer", "MAT:101/121 candidate process + MAT entities", "The active aggregate may be a participant, not the reaction event."],
  ["consumption", "MAT later layer", "MAT:101/111/121 candidate process", "Consumption is transformation/transfer."],
  ["flow of matter", "composition", "MOV:121 + MAT entity, or future MAT:121 when exchange is foregrounded", "Displacement and material-domain exchange are distinct."],
  ["electric current", "composition", "MAT:021 + flow/process + quantity", "Active aggregate is not itself the current process."],
  ["moving object", "composition", "MAT:010/011 + MOV:121", "Movement does not automatically make the object materially active."],
  ["living body", "composition", "LIF entity + MAT:000/001", "Life and substrate are separate domains."],
  ["conscious body", "composition", "LIF:001 + MAT:000/001", "Consciousness does not follow from energetic matter."],
  ["data object", "different future family", "DAT entity; MAT only for physical storage bearer", "Do not treat spatial metaphors or software objects as matter."],
  ["ownership", "different future family", "CON relation + MAT object", "Ownership is not material attachment."],
  ["accessibility", "different future family", "CON/LOG/STR relation + MAT entity", "Access is explicitly excluded from dormant MAT roots."],
  ["scarce", "grammar or quantity", "MAT stock + low quantity relative to demand", "Scarcity is comparative/contextual."],
  ["abundant", "grammar or quantity", "MAT stock + high quantity relative to demand", "Abundance is comparative/contextual."],
  ["empty", "root plus runtime or quantity", "aggregate membership/quantity = zero", "Empty is not dormant; an empty container may remain active."],
  ["full", "grammar or quantity", "MAT/STR container + capacity ratio", "Fullness is a quantity relation."],
  ["conservation", "MAT later layer", "MAT:220 candidate + LOG equality", "Conservation is a systemic relationship/law."]
].freeze

stress = {
  "metadata" => {
    "title" => "MAT:000–022 semantic stress tests",
    "status" => "review_evidence_not_canonical",
    "test_count" => stress_rows.length,
    "forced_atomic_mappings" => false
  },
  "classification_values" => [
    "direct proposed root",
    "root plus runtime or later property",
    "composition",
    "MAT later layer",
    "canonical/future other family",
    "different future family",
    "grammar or modifier",
    "grammar or quantity",
    "unresolved lexical ambiguity"
  ],
  "tests" => stress_rows.map.with_index(1) do |(concept, classification, mapping, rationale), index|
    {
      "number" => index,
      "concept" => concept,
      "classification" => classification,
      "mapping" => mapping,
      "rationale" => rationale
    }
  end,
  "coverage_summary" => stress_rows.group_by { |row| row[1] }.transform_values(&:length)
}

File.write(File.join(ROOT, "reviews/MAT_000_022_scored_candidates.yaml"), YAML.dump(scored))
File.write(File.join(ROOT, "reviews/MAT_000_022_recommended_spec.yaml"), YAML.dump(recommended))
File.write(File.join(ROOT, "reviews/MAT_000_022_stress_tests.yaml"), YAML.dump(stress))

peer = +"# MAT:000–022 Adversarial Semantic Peer Review\n\n"
peer << "Status: **READY FOR USER APPROVAL — NOT CANONICAL**\n\n"
peer << "Scope is strictly `MAT:000–022`. The nine current Phase 2 titles are treated as replaceable candidates. All deterministic generated fields remain fixed. The review uses only the fixed architecture and the 45 canonical LIF/MOV roots as semantic authority; it does not depend on the unapproved `MOV:200–222` recommendations.\n\n"
peer << "## Executive recommendation\n\n"
peer << "The strongest Matter entity-layer architecture is one scope grid with one phase grid:\n\n"
peer << "- `MAT:000–002`: **focal material substrate** — persistent / physically active / dormant;\n"
peer << "- `MAT:010–012`: **distinct external material object** — stable / physically active / dormant;\n"
peer << "- `MAT:020–022`: **material aggregate** — stable / physically active / dormant.\n\n"
peer << "This removes integrity, targethood, tool use, access, circulation, reserve purpose, topology, and future process/capacity meanings from the atoms. Those concepts remain expressible through later roots, grammar, or compounds.\n\n"
peer << "## Fixed generated forms\n\n"
peer << "| ID | Universal slot | Transliteration | Compact | Formal carrier | Harmony | Relative note path |\n|---|---|---|---|---|---|---|\n"
IDS.each do |id|
  f = fixed.fetch(id)
  peer << "| `#{id}` | #{f["universal_slot"]} | `#{f["family_qualified_transliteration"]}` | `#{f["local_compact_root"]}` | `#{f["formal_carrier"]}` | `#{f["harmonic_signature_semitones"].join(", ")}` | `#{f["relative_note_path_semitones"].join(", ")}` |\n"
end
peer << "\n"

IDS.each do |id|
  data = ROOTS.fetch(id)
  winner = data["candidates"].find { |item| item["candidate_id"] == data["winner"] }
  peer << "## #{id} — #{data["recommended_title"]}\n\n"
  peer << "**Why the current meaning was chosen.** #{data["current_rationale"]}\n\n"
  peer << "| Candidate | Atomic | Address | MAT | Neighbor | vs canonical LIF/MOV | vs MAT 1xx/2xx | Cross-family | Everyday | Technical | Compound | Total |\n"
  peer << "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n"
  data["candidates"].each do |item|
    s = item["scores"]
    peer << "| #{item["title"]} | #{s["atomicity"]} | #{s["address_fit"]} | #{s["matter_family_fit"]} | #{s["neighbor_separation"]} | #{s["separation_from_canonical_lif_mov"]} | #{s["separation_from_mat_1xx_2xx"]} | #{s["cross_family_separation"]} | #{s["everyday_language_usefulness"]} | #{s["technical_programming_usefulness"]} | #{s["compound_usefulness"]} | **#{item["total"]}/100** |\n"
  end
  peer << "\n"
  data["candidates"].each do |item|
    a = item["analysis"]
    peer << "- **#{item["title"]}:** #{a["why_it_fits"]} Covers #{a["useful_coverage"]} Consumes #{a["semantic_territory_consumed"]} Risk: #{a["risks_and_future_limitations"]}\n"
  end
  peer << "\n**Recommendation:** **#{data["recommended_title"]}** (#{winner["total"]}/100; confidence #{(data["confidence"] * 100).round}%).\n\n"
  peer << "> #{data["definition"]}\n\n"
  peer << "**Boundaries.** #{data["boundaries"].join(" ")}\n\n"
  peer << "**Exclusions.** #{data["exclusions"].join(" ")}\n\n"
  peer << "**Nearest Matter contrasts.** #{data["mat_contrasts"].map { |key, value| "`#{key}`: #{value}." }.join(" ")}\n\n"
  peer << "**Runtime states.** `[0]` #{data["runtime"]["0"]} `[1]` #{data["runtime"]["1"]} `[2]/num` #{data["runtime"]["2"]}\n\n"
  peer << "**Ordinary examples.** #{data["ordinary"].map { |item| "`#{item["semantic_graph"]}` — #{item["natural_english"]}" }.join(" ")}\n\n"
  peer << "**Programming examples.** #{data["technical"].map { |item| "`#{item["pseudocode"]}` — #{item["interpretation"]}" }.join(" ")}\n\n"
  peer << "**Future decomposition sketches (not canonical compounds).** #{data["compounds"].join("; ")}.\n\n"
  peer << "**Later-Era notes.** #{data["era_notes"].join(" ")}\n\n"
end

peer << "## Nine-root contrast matrix\n\n"
peer << "| Root | Owns | Does not own | Reserved for composition | Deliberately deferred |\n|---|---|---|---|---|\n"
matrix = {
  "MAT:000" => ["persistent focal material substrate", "integrity, life, structure", "embodied self; intact body", "mass/composition metrics"],
  "MAT:001" => ["active focal material substrate", "movement, vitality, change process", "thermal/electrical/chemical activation", "energy-mode ontology"],
  "MAT:002" => ["dormant focal material substrate", "stored capacity, death, failure", "unpowered body; dormant living embodiment", "cause and reactivation"],
  "MAT:010" => ["distinct external material object", "tool, resource, ownership, targethood", "artifact; possessed object; physical target", "classifier system"],
  "MAT:011" => ["active external material object", "force transfer, function, motion", "active tool; hazardous object", "energy-mode ontology"],
  "MAT:012" => ["dormant external material object", "inaccessibility, damage, future artifact", "stored/failed/restricted object", "cause and future use"],
  "MAT:020" => ["stable collective material aggregate", "topology, system purpose, quantity", "material system; stock; substance kind", "aggregate classifiers"],
  "MAT:021" => ["active collective material aggregate", "circulation, exchange event, coordination", "reacting/organized/moving aggregate", "interaction subtypes"],
  "MAT:022" => ["dormant collective material aggregate", "reserve purpose, storage, scarcity", "inventory; reserve stock; inactive system", "resource ontology"]
}
matrix.each { |id, values| peer << "| `#{id}` | #{values.join(" | ")} |\n" }
peer << "\n"
peer << "## Triplet coherence\n\n"
peer << "- `MAT:000–002` keeps one referent center: the focal entity's constitutive material substrate. The lexical contrast is persistent / physically energized / physically dormant.\n"
peer << "- `MAT:010–012` keeps one referent center: one distinct external material object. The contrast is stable / physically energized / physically dormant.\n"
peer << "- `MAT:020–022` keeps one referent center: multiple material constituents treated collectively. The contrast is stable / collectively energetic / collectively dormant.\n"
peer << "- The active phase describes an entity/condition, not the process that produces it. MAT process roots must later own transformation, force transfer, consumption, and exchange events.\n\n"
peer << "## Stress-test result\n\n"
peer << "The packet classifies #{stress_rows.length} common Matter concepts. Only scope-and-phase concepts map directly. Tools, resources, integrity, quantities, properties, material kinds, forces, flows, damage, repair, and ownership remain compositions, later-layer questions, or other-family meanings.\n\n"
peer << "## Final recommendations\n\n"
IDS.each { |id| peer << "- `#{id}` — **#{ROOTS[id]["recommended_title"]}**: #{ROOTS[id]["definition"]}\n" }
peer << "\n"
peer << "- **Roots ready for user approval:** all nine (`MAT:000–022`).\n"
peer << "- **Roots that should remain unresolved:** none.\n"
peer << "- **Nonblocking terminology questions:** whether catalogue labels prefer “active” or “energized,” and whether “aggregate” later receives distinct count/continuum subtypes. The invariant definitions do not depend on those label choices.\n"
peer << "- **Roots canonized by this packet:** none.\n"
peer << "- **Stop boundary honored:** no `MAT:100–122`, other root block, Gate 4, renderer, or translator implementation was begun.\n\n"
peer << "**READY FOR USER APPROVAL**\n"
File.write(File.join(ROOT, "reviews/MAT_000_022_peer_review.md"), peer)

collision = +"# MAT:000–022 Collision Report\n\n"
collision << "Status: **peer-review evidence — not canonical**\n\n"
collision << "## Core ownership rule\n\n"
collision << "The proposed block owns physical substrate, object, and aggregate entities/conditions at stable, active, or dormant lexical phases. It does not own identity, movement, cognition, access, structure, failure, repair, formal validity, data, creation, or ontology.\n\n"
collision << "## Intra-Matter layer boundary\n\n"
collision << "| Entity block | Reserved for MAT:100–122 review | Reserved for MAT:200–222 review |\n|---|---|---|\n"
collision << "| substrate/object/aggregate conditions | transformation, assembly, consumption, force/energy transfer, systemic exchange | integrity capacity, available work, stored potential, coupling, physical fit, conservation relationships |\n\n"
collision << "## Canonical LIF/MOV audit\n\n"
collision << "- LIF roots classify living identity, consciousness, life processes, vitality, and biosystems; Matter roots only supply physical bearers.\n"
collision << "- MOV roots classify positions, routes, displacement, departure, arrival, and shared-frame movement; movement alone never selects an active Matter entity.\n"
collision << "- A living, conscious, moving, material being therefore uses a graph with independent LIF, MOV, and MAT assertions rather than one overloaded atom.\n\n"
collision << "## Cross-family collision matrix\n\n"
collision << "| Root | LIF | MOV | MIN | CON | STR | WRN | REP | LOG | DAT | CRE | ORI |\n|---|---|---|---|---|---|---|---|---|---|---|---|\n"
IDS.each do |id|
  cross = cross_family_for(id)
  collision << "| `#{id}` | #{cross.values.join(" | ")} |\n"
end
collision << "\n## High-risk English traps\n\n"
collision << "- **Body** is not automatically life or consciousness: combine MAT substrate with LIF when those meanings are asserted.\n"
collision << "- **Active** does not mean moving, executing code, thinking, alive, or socially engaged; this block requires physical energetic expression.\n"
collision << "- **Object** does not imply tool, resource, possession, target, or artifact.\n"
collision << "- **Dormant** does not imply broken, inaccessible, stored, reserved, dead, or certain to reactivate.\n"
collision << "- **Aggregate** does not imply structural organization, network topology, ownership, quantity, or resource purpose.\n"
collision << "- **Flow** is not an entity meaning here. Use MOV for displacement and later MAT process roots for material exchange.\n\n"
collision << "## Disposition\n\n"
collision << "The narrowed recommendations avoid blocking collisions with the 45 canonical roots, the future Matter process/capacity layers, and all eleven competing family domains. They remain provisional pending explicit user approval.\n"
File.write(File.join(ROOT, "reviews/MAT_000_022_collision_report.md"), collision)

puts "Built MAT:000–022 peer-review packet (five content files; validation generated separately)."
