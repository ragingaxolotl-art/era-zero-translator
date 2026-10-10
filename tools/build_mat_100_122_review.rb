#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MAT:100 MAT:101 MAT:102
  MAT:110 MAT:111 MAT:112
  MAT:120 MAT:121 MAT:122
].freeze
SCORE_KEYS = %w[
  atomicity address_fit matter_family_fit triplet_coherence
  neighbor_separation cross_family_separation everyday_language_usefulness
  technical_programming_usefulness compound_usefulness translation_safety
].freeze
CROSS_FAMILIES = %w[LIF MOV MIN CON STR WRN REP LOG DAT CRE ORI].freeze

def load_yaml(path)
  YAML.load_file(File.join(ROOT, path))
end

def fixed_projection(atom)
  {
    "canonical_id" => atom["canonical_id"],
    "universal_slot" => atom["universal_slot"],
    "family_qualified_transliteration" => atom["canonical_transliteration"],
    "local_compact_root" => atom["local_compact_root"],
    "formal_carrier" => atom["formal_carrier"],
    "harmonic_signature_semitones" => atom["harmonic_signature_semitones"],
    "relative_note_path_semitones" => atom["note_path_semitones"]
  }
end

def candidate(id, title, definition, scores, fit:, coverage:, territory:, risk:)
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

def review_example(category:, graph:, literal:, natural:, analysis:, runtime: 1,
                   contour: "declarative", use_status: "valid", pseudocode: nil)
  {
    "category" => category,
    "semantic_graph" => graph,
    "literal_gloss" => literal,
    "natural_english" => natural,
    "runtime_state" => runtime,
    "contour" => contour,
    "role_registers" => {
      "low" => "focal bearer, affected source, or initiating participant",
      "middle" => "MAT process predicate",
      "high" => "distinct target, result, or contrasted participant when present",
      "sustained" => "shared material environment or system when present"
    },
    "use_status" => use_status,
    "analysis" => analysis
  }.tap { |item| item["pseudocode"] = pseudocode if pseudocode }
end

atoms = load_yaml("lexicon/atoms.yaml").fetch("atoms")
atoms_by_id = atoms.to_h { |atom| [atom.fetch("canonical_id"), atom] }
fixed = IDS.to_h { |id| [id, fixed_projection(atoms_by_id.fetch(id))] }

ROOT_DESIGN = {
  "MAT:100" => {
    "current_rationale" => "“Consolidation complete” was probably chosen because address 100 is a completed inward Matter process. The definition correctly sought a finished change local to the entity, but it adds a stable result and privileges consolidation even though neither result-state stability nor consolidation is encoded by the address.",
    "recommended_title" => "completed focal material change",
    "definition" => "Completion of a physical-state change localized within the focal material bearer.",
    "confidence" => 0.97,
    "transfer_title" => "completed material uptake",
    "transfer_definition" => "Completion of matter crossing into the focal material bearer.",
    "energy_title" => "completed internal energy conversion",
    "energy_definition" => "Completion of a conversion of physical energy within the focal material bearer.",
    "winner_example" => ["MAT:100[1](BEARER=ice,CHANGE=phase)", "ice; focal material change; completed", "The ice has finished melting."],
    "physical_example" => ["MAT:100[1](BEARER=forged_bar,CHANGE=cooling)", "bar; internal physical-state change; completed", "The forged bar has cooled through the specified transition."],
    "temporal_example" => ["MAT:100[1](BEARER=resin,CHANGE=curing,AFTER=interval)", "resin; focal material change completed after interval", "After ten minutes, the resin finished curing."],
    "compound_example" => ["MAT:100[1](BEARER=printed_part)+CRE(ORIGIN=printing)", "created part; subsequent focal material change completed", "The printed part finished hardening after fabrication."],
    "program_example" => ["MAT:100[1](BEARER=batch,CHANGE=phase)", "batch; physical-state transition reached completion", "The controller records the batch transition as complete.", "assert transition(batch, :phase).completed?"],
    "counterexample" => ["MOV:110[1](MOVER=person,TARGET=door)", "person; target arrival completed", "The person arrived at the door.", "Arrival changes position, not intrinsic material state; do not use MAT:100."]
  },
  "MAT:101" => {
    "current_rationale" => "“Self-reconfiguration” follows active + inward + Matter, but its definition joins changing, assembling, consuming, and redistributing. Those are different event structures with different participants and family collisions, so the provisional atom lacks one invariant center.",
    "recommended_title" => "active focal material change",
    "definition" => "An ongoing physical-state change localized within the focal material bearer.",
    "confidence" => 0.98,
    "transfer_title" => "active material uptake",
    "transfer_definition" => "Matter is presently crossing into the focal material bearer.",
    "energy_title" => "active internal energy conversion",
    "energy_definition" => "Physical energy is presently being converted within the focal material bearer.",
    "winner_example" => ["MAT:101[1](BEARER=soup,CHANGE=cooling)", "soup; focal material change; ongoing", "The soup is cooling."],
    "physical_example" => ["MAT:101[1](BEARER=wire,CHANGE=annealing)", "wire; internal physical-state change; ongoing", "The wire is annealing inside the furnace."],
    "temporal_example" => ["MAT:101[1](BEARER=mixture,CHANGE=reaction,DURING=interval)", "mixture; focal material change active during interval", "The mixture is reacting during this stage."],
    "compound_example" => ["MAT:101[1](BEARER=pipe)+WRN(CAUSE=corrosion)", "pipe; active material change with damage classification", "The pipe is corroding."],
    "program_example" => ["MAT:101[1](BEARER=sample,CHANGE=thermal)", "sample; physical-state transition currently active", "The monitor reports that the sample is changing temperature.", "assert transition(sample, :thermal).active?"],
    "counterexample" => ["DAT:101[1](RECORD=config)", "configuration record; active decoding or mutation", "The configuration data is changing.", "A data mutation is not a material-state change; do not use MAT:101 without a physical bearer change."]
  },
  "MAT:102" => {
    "current_rationale" => "“Queued reconfiguration” tried to lexicalize the third trit as not-yet-begun activity. The later canonical 1x2 clarification rejects queueing, preparation, scheduling, intention, readiness, probability, and guaranteed futurity; only a nonactualized process belongs here.",
    "recommended_title" => "potential focal material change",
    "definition" => "A possible physical-state change localized within the focal material bearer that is not active or completed.",
    "confidence" => 0.99,
    "transfer_title" => "potential material uptake",
    "transfer_definition" => "A possible crossing of matter into the focal material bearer that is not active or completed.",
    "energy_title" => "potential internal energy conversion",
    "energy_definition" => "A possible conversion of physical energy within the focal material bearer that is not active or completed.",
    "winner_example" => ["MAT:102[1](BEARER=chocolate,CHANGE=melting)", "chocolate; possible focal material change; nonactualized", "The chocolate could melt."],
    "physical_example" => ["MAT:102[1](BEARER=alloy,CHANGE=softening)", "alloy; possible internal physical-state change", "The alloy can soften under suitable conditions."],
    "temporal_example" => ["MAT:102[1](BEARER=sample,CHANGE=crystallization)", "sample; nonactualized possible material change", "Crystallization remains physically possible, but it has not started."],
    "compound_example" => ["MAT:102[1](BEARER=surface)+WRN(POSSIBLE=corrosion)", "surface; possible physical change classified as harmful", "The surface could corrode."],
    "program_example" => ["MAT:102[1](BEARER=material,CHANGE=phase)", "material; phase change lies in the reachable physical state space", "The simulator permits a phase transition from this state.", "assert reachable?(material.state, :phase_changed)"],
    "counterexample" => ["LOG(plan)+ORI(future)", "operation; planned for later", "The operation is scheduled for tomorrow.", "Scheduling does not follow from lexical trit 2; MAT:102 alone must not encode a plan or queue."]
  },
  "MAT:110" => {
    "current_rationale" => "“Fabrication complete” uses completed + target-oriented Matter and gives a salient ordinary result. It nevertheless imports production, bounded result, and an external agent. Those belong to CRE, STR, and role grammar; the address only requires a completed target-local material process.",
    "recommended_title" => "completed target material change",
    "definition" => "Completion of a physical-state change localized in a distinct material target.",
    "confidence" => 0.98,
    "transfer_title" => "completed material delivery",
    "transfer_definition" => "Completion of matter being transferred to a distinct material target.",
    "energy_title" => "completed force application",
    "energy_definition" => "Completion of a physical force being applied to a distinct material target.",
    "winner_example" => ["MAT:110[1](TARGET=blade,CHANGE=tempering)", "blade; target material change; completed", "The blade has finished tempering."],
    "physical_example" => ["MAT:110[1](TARGET=panel,CHANGE=deformation)", "panel; target-local physical-state change completed", "The panel has been bent to its final curvature."],
    "temporal_example" => ["MAT:110[1](TARGET=coating,CHANGE=curing,AFTER=interval)", "coating; target change completed after interval", "The coating finished curing after the hold period."],
    "compound_example" => ["CRE(AGENT=smith,GOAL=blade)+MAT:110[1](TARGET=blade)", "intentional creation process plus completed target material change", "The smith finished physically forming the blade."],
    "program_example" => ["MAT:110[1](TARGET=workpiece,CHANGE=hardening)", "workpiece; requested physical transition completed", "The machine marks the workpiece hardening step complete.", "assert material_step(workpiece, :hardening).completed?"],
    "counterexample" => ["CRE:110[1](TARGET=artifact)", "artifact creation completed", "The designer completed the artifact.", "Completion of a designed artifact is CRE unless an actual target-local physical-state change is asserted."]
  },
  "MAT:111" => {
    "current_rationale" => "“Force transfer” recognized an active outward Matter process, but the definition combines matter application, energy application, movement, consumption, and transfer. A force can occur without changing a target, while material movement belongs partly to MOV and participant transfer to CON.",
    "recommended_title" => "active target material change",
    "definition" => "An ongoing physical-state change localized in a distinct material target.",
    "confidence" => 0.98,
    "transfer_title" => "active material delivery",
    "transfer_definition" => "Matter is presently being transferred to a distinct material target.",
    "energy_title" => "active force application",
    "energy_definition" => "A physical force is presently being applied to a distinct material target.",
    "winner_example" => ["MAT:111[1](TARGET=coating,CHANGE=dissolution)", "coating; target material change; ongoing", "The coating is dissolving."],
    "physical_example" => ["MAT:111[1](TARGET=sheet,CHANGE=deformation)", "sheet; target-local physical-state change active", "The press is bending the sheet."],
    "temporal_example" => ["MAT:111[1](TARGET=sample,CHANGE=heating,DURING=stage)", "sample; target change active during stage", "The sample is heating during the current stage."],
    "compound_example" => ["MAT:111[1](TARGET=beam)+WRN(CAUSE=fracture)", "beam; active target change classified as damage", "The beam is cracking under load."],
    "program_example" => ["MAT:111[1](TARGET=part,CHANGE=coating)", "part; physical-state transition currently executing", "The cell reports that the part coating process is active.", "assert material_step(part, :coating).active?"],
    "counterexample" => ["MOV:121[1](MOVER=crate,FRAME=room)", "crate; active shared-frame movement", "The crate is moving across the room.", "Displacement without intrinsic physical change is MOV, not MAT:111."]
  },
  "MAT:112" => {
    "current_rationale" => "“Staged material operation” was chosen as the outward analogue of queued reconfiguration. It violates the accepted 1x2 rule by importing staging and operational specification, and “operation” is too broad to identify one Matter-family process.",
    "recommended_title" => "potential target material change",
    "definition" => "A possible physical-state change localized in a distinct material target that is not active or completed.",
    "confidence" => 0.99,
    "transfer_title" => "potential material delivery",
    "transfer_definition" => "A possible transfer of matter to a distinct material target that is not active or completed.",
    "energy_title" => "potential force application",
    "energy_definition" => "A possible application of physical force to a distinct material target that is not active or completed.",
    "winner_example" => ["MAT:112[1](TARGET=pipe,CHANGE=thawing)", "pipe; possible target material change; nonactualized", "The pipe could thaw."],
    "physical_example" => ["MAT:112[1](TARGET=glass,CHANGE=fracture)", "glass; possible target-local physical-state change", "The glass can fracture under this load."],
    "temporal_example" => ["MAT:112[1](TARGET=coating,CHANGE=curing)", "coating; target change possible but inactive", "The coating can cure, but curing has not begun."],
    "compound_example" => ["MAT:112[1](TARGET=cell)+REP(POSSIBLE=healing)", "cell; possible physical change under restorative interpretation", "The tissue could physically heal."],
    "program_example" => ["MAT:112[1](TARGET=component,CHANGE=deformation)", "component; deformation lies in reachable physical states", "The model permits deformation of the component.", "assert reachable?(component.state, :deformed)"],
    "counterexample" => ["LOG(queue)+MAT(target)", "target operation; queued", "The machine queued the coating operation.", "Queue status needs LOG/grammar; it is not encoded by MAT:112."]
  },
  "MAT:120" => {
    "current_rationale" => "“Closed material cycle” uses completed + systemic Matter, but “cycle” adds recurrence, closure criteria, and a defined system boundary. A distributed change need not be cyclic, and a completed cycle may contain many processes rather than one atom.",
    "recommended_title" => "completed systemic material change",
    "definition" => "Completion of a physical-state change distributed across materially interacting parts of a shared system.",
    "confidence" => 0.96,
    "transfer_title" => "completed material redistribution",
    "transfer_definition" => "Completion of a bounded redistribution of matter among parts of a shared system.",
    "energy_title" => "completed systemic energy exchange",
    "energy_definition" => "Completion of physical-energy exchange among parts of a shared system.",
    "winner_example" => ["MAT:120[1](SYSTEM=reactor,CHANGE=equilibration)", "reactor system; distributed material change; completed", "The reactor contents have finished equilibrating."],
    "physical_example" => ["MAT:120[1](SYSTEM=coolant_loop,CHANGE=thermal_equalization)", "coolant loop; distributed physical-state change completed", "The coolant loop reached thermal equilibrium throughout."],
    "temporal_example" => ["MAT:120[1](SYSTEM=batch,CHANGE=mixing,AFTER=cycle)", "batch system; distributed material change completed", "After the cycle, the batch was uniformly mixed."],
    "compound_example" => ["MAT:120[1](SYSTEM=recycling_batch)+CRE(RESULT=new_material)", "distributed physical change completed with creation result", "The recycling batch finished becoming usable material."],
    "program_example" => ["MAT:120[1](SYSTEM=mesh,CHANGE=equilibration)", "material system; distributed transition converged", "The simulation reports material equilibration complete.", "assert material_field(mesh).converged?"],
    "counterexample" => ["DAT:120[1](SYSTEM=replicas)", "replicated data process completed", "The data replicas finished synchronizing.", "A distributed information process is DAT/CON, not a systemic material change."]
  },
  "MAT:121" => {
    "current_rationale" => "“Systemic resource flow” correctly notices active + systemic Matter, but it bundles matter, energy, resources, transformation, and exchange. Flow may be pure displacement, resources are role-relative, and exchange adds participant relations; the candidate lacks a single process center.",
    "recommended_title" => "active systemic material change",
    "definition" => "An ongoing physical-state change distributed across materially interacting parts of a shared system.",
    "confidence" => 0.97,
    "transfer_title" => "active material circulation",
    "transfer_definition" => "Matter is presently circulating among parts of a shared system.",
    "energy_title" => "active systemic energy exchange",
    "energy_definition" => "Physical energy is presently being exchanged among parts of a shared system.",
    "winner_example" => ["MAT:121[1](SYSTEM=fermentation_vat,CHANGE=reaction)", "vat system; distributed material change; ongoing", "The vat is fermenting throughout."],
    "physical_example" => ["MAT:121[1](SYSTEM=alloy_bath,CHANGE=mixing)", "alloy bath; distributed physical-state change active", "The alloy bath is changing composition across the whole vessel."],
    "temporal_example" => ["MAT:121[1](SYSTEM=reactor,CHANGE=equilibration,DURING=stage)", "reactor; distributed material change active during stage", "The reactor is equilibrating during this stage."],
    "compound_example" => ["MAT:121[1](SYSTEM=ecosystem)+LIF(PROCESS=metabolism)", "distributed material change within a living system", "Material is being transformed across the ecosystem’s living processes."],
    "program_example" => ["MAT:121[1](SYSTEM=grid,CHANGE=thermal)", "material field; distributed transition currently evolving", "The solver is evolving the thermal state across the grid.", "assert material_field(grid).evolving?"],
    "counterexample" => ["MOV:121[1](MOVER=water,FRAME=pipe_network)", "water; active shared-frame movement", "Water is circulating without changing physical state.", "Pure circulation is MOV plus a material bearer; MAT:121 requires distributed physical-state change."]
  },
  "MAT:122" => {
    "current_rationale" => "“Pending material cycle” applies a future/staged reading to systemic trit 2 and assumes cyclic structure. The fixed architecture permits only a nonactualized systemic Matter process, not staging, schedule, recurrence, readiness, or eventual completion.",
    "recommended_title" => "potential systemic material change",
    "definition" => "A possible physical-state change distributed across materially interacting parts of a shared system that is not active or completed.",
    "confidence" => 0.99,
    "transfer_title" => "potential material redistribution",
    "transfer_definition" => "A possible redistribution of matter among parts of a shared system that is not active or completed.",
    "energy_title" => "potential systemic energy exchange",
    "energy_definition" => "A possible exchange of physical energy among parts of a shared system that is not active or completed.",
    "winner_example" => ["MAT:122[1](SYSTEM=atmosphere,CHANGE=condensation)", "atmospheric system; possible distributed material change", "Condensation could develop across the system."],
    "physical_example" => ["MAT:122[1](SYSTEM=reactor,CHANGE=runaway_reaction)", "reactor system; possible distributed physical-state change", "A system-wide reaction is physically possible but has not started."],
    "temporal_example" => ["MAT:122[1](SYSTEM=batch,CHANGE=crystallization)", "batch; distributed change nonactualized", "The batch could crystallize throughout; no such change is active."],
    "compound_example" => ["MAT:122[1](SYSTEM=grid)+WRN(POSSIBLE=overheating)", "systemic physical change possible and hazardous", "The grid could overheat system-wide."],
    "program_example" => ["MAT:122[1](SYSTEM=mesh,CHANGE=phase)", "mesh; distributed phase transition belongs to reachable state space", "The model allows a system-wide phase transition.", "assert reachable?(mesh.state, :distributed_phase_change)"],
    "counterexample" => ["LOG(schedule)+MAT(system)", "system operation; scheduled", "The plant scheduled a material cycle.", "Scheduling and cycle specification are separate LOG/grammar structures; MAT:122 alone must not encode them."]
  }
}.freeze

CURRENT_SCORES = {
  "MAT:100" => [8, 8, 9, 7, 8, 7, 8, 8, 8, 7],
  "MAT:101" => [5, 8, 9, 6, 6, 5, 9, 8, 8, 5],
  "MAT:102" => [7, 5, 9, 6, 7, 8, 8, 8, 7, 3],
  "MAT:110" => [7, 8, 8, 7, 7, 5, 9, 8, 8, 6],
  "MAT:111" => [4, 8, 9, 5, 5, 3, 9, 9, 8, 4],
  "MAT:112" => [7, 5, 8, 6, 7, 7, 8, 8, 7, 3],
  "MAT:120" => [8, 8, 9, 7, 8, 7, 8, 9, 8, 7],
  "MAT:121" => [4, 8, 9, 5, 5, 3, 9, 9, 8, 4],
  "MAT:122" => [7, 5, 9, 6, 7, 7, 8, 8, 7, 3]
}.freeze

WINNER_SCORES = {
  "MAT:100" => [10, 10, 10, 10, 9, 9, 10, 10, 10, 10],
  "MAT:101" => [10, 10, 10, 10, 10, 9, 10, 10, 10, 10],
  "MAT:102" => [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
  "MAT:110" => [10, 10, 10, 10, 10, 9, 10, 10, 10, 10],
  "MAT:111" => [10, 10, 10, 10, 10, 9, 10, 10, 10, 10],
  "MAT:112" => [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
  "MAT:120" => [10, 10, 10, 10, 9, 9, 9, 10, 10, 10],
  "MAT:121" => [10, 10, 10, 10, 9, 9, 9, 10, 10, 10],
  "MAT:122" => [10, 10, 10, 10, 10, 10, 9, 10, 10, 10]
}.freeze

TRANSFER_SCORES = {
  "MAT:100" => [10, 9, 10, 9, 8, 7, 9, 10, 9, 8],
  "MAT:101" => [10, 9, 10, 9, 8, 7, 9, 10, 9, 8],
  "MAT:102" => [10, 9, 10, 9, 8, 8, 9, 10, 9, 8],
  "MAT:110" => [10, 9, 10, 9, 8, 6, 9, 10, 9, 7],
  "MAT:111" => [10, 9, 10, 9, 8, 6, 9, 10, 9, 7],
  "MAT:112" => [10, 9, 10, 9, 8, 7, 9, 10, 9, 7],
  "MAT:120" => [9, 9, 10, 9, 8, 6, 9, 10, 9, 7],
  "MAT:121" => [9, 9, 10, 9, 8, 5, 9, 10, 9, 7],
  "MAT:122" => [9, 9, 10, 9, 8, 6, 9, 10, 9, 7]
}.freeze

ENERGY_SCORES = {
  "MAT:100" => [10, 9, 10, 9, 8, 8, 8, 10, 9, 8],
  "MAT:101" => [10, 9, 10, 9, 8, 8, 8, 10, 9, 8],
  "MAT:102" => [10, 9, 10, 9, 8, 9, 8, 10, 9, 8],
  "MAT:110" => [10, 9, 9, 9, 8, 6, 9, 10, 9, 7],
  "MAT:111" => [10, 9, 9, 9, 8, 6, 9, 10, 9, 7],
  "MAT:112" => [10, 9, 9, 9, 8, 7, 9, 10, 9, 7],
  "MAT:120" => [10, 9, 10, 9, 8, 7, 9, 10, 9, 8],
  "MAT:121" => [10, 9, 10, 9, 8, 7, 9, 10, 9, 8],
  "MAT:122" => [10, 9, 10, 9, 8, 8, 9, 10, 9, 8]
}.freeze

def orientation_for(id)
  id.split(":").last[1]
end

def phase_for(id)
  id[-1]
end

def orientation_label(id)
  {
    "0" => "focal/inward",
    "1" => "distinct-target/outward",
    "2" => "shared-system/systemic"
  }.fetch(orientation_for(id))
end

def phase_label(id)
  { "0" => "completed", "1" => "active/ongoing", "2" => "potential/nonactualized" }.fetch(phase_for(id))
end

def runtime_for(id)
  locus = orientation_label(id)
  case phase_for(id)
  when "0"
    {
      "0" => "Denies or deactivates the claim that the #{locus} physical-state change reached completion.",
      "1" => "Affirms that the #{locus} change reached its completion boundary; it does not describe the resulting entity state.",
      "2" => "Marks the completion assertion itself as dormant, unavailable, remembered, or unresolved. It does not select lexical potential `#{id.sub(/0\z/, "2")}`."
    }
  when "1"
    {
      "0" => "Denies that the #{locus} physical-state change is presently underway.",
      "1" => "Affirms that the #{locus} physical-state change is underway at the reference time.",
      "2" => "Marks the current status of this active-process assertion as dormant, paused, unavailable, or unresolved. It does not change the lexeme into `#{id.sub(/1\z/, "2")}`."
    }
  when "2"
    {
      "0" => "Rules out the asserted #{locus} physical-state change as a live possibility in the stated frame.",
      "1" => "Affirms that the #{locus} physical-state change is possible while remaining nonactualized.",
      "2" => "Marks whether that nonactualized possibility holds as dormant or unresolved. This layered status still does not encode a plan, queue, schedule, readiness, or future certainty."
    }
  end
end

def cross_family_for(id)
  locus = orientation_label(id)
  phase = phase_label(id)
  {
    "LIF" => "LIF owns living growth, metabolism, vitality, and identity. `#{id}` owns only the #{phase} physical-state change at the #{locus} locus; use a compound when a living process has a material realization.",
    "MOV" => "MOV owns position and displacement. Matter crossing space or circulating without intrinsic physical-state change uses MOV with a material bearer, not `#{id}` alone.",
    "MIN" => "MIN owns mental-state change, attention, memory, and learning. A thought or perception changing does not select `#{id}` unless a physical material change is separately asserted.",
    "CON" => "CON owns communication, transfer relations, access, and participant linkage. `#{id}` does not by itself encode giver, receiver, possession, or transmission.",
    "STR" => "STR owns topology, organization, part-whole structure, assembly schema, and boundary relations. `#{id}` owns physical-state change, not abstract or functional reorganization.",
    "WRN" => "WRN owns damage, hazard, failure, and corruption judgments. A physical change is not inherently harmful; combine WRN when the change is damage or risk.",
    "REP" => "REP owns restoration and healing as goal-directed return toward a prior or viable state. `#{id}` describes the physical change without restorative purpose.",
    "LOG" => "LOG owns scheduling, queueing, control flow, permission, conditions, and formal state transitions. Lexical process phase and runtime status do not encode those operations.",
    "DAT" => "DAT owns information mutation, storage, decoding, and signal flow. A data structure changing is not a material process unless its physical storage bearer is separately foregrounded.",
    "CRE" => "CRE owns intentional generation, design, novel form, and production semantics. `#{id}` may supply physical realization, but it never entails artifact creation or purpose.",
    "ORI" => "ORI owns ontological becoming, temporal framing, and reality-level transition. `#{id}` is limited to a Matter-family physical-state change in an already asserted frame."
  }
end

scored_roots = IDS.map do |id|
  design = ROOT_DESIGN.fetch(id)
  current = atoms_by_id.fetch(id)
  current_candidate = candidate(
    "current_phase2_candidate",
    current.fetch("title"),
    current.fetch("core_definition"),
    CURRENT_SCORES.fetch(id),
    fit: "It was built from the broad Matter domain plus the address's process, orientation, and phase labels.",
    coverage: "It covers a salient cluster of #{orientation_label(id)} material events.",
    territory: "It consumes completion/result, activity, resource, transfer, production, or operational semantics beyond the three trits.",
    risk: design.fetch("current_rationale")
  )
  winner_candidate = candidate(
    "physical_state_change",
    design.fetch("recommended_title"),
    design.fetch("definition"),
    WINNER_SCORES.fetch(id),
    fit: "It maps first trit to one physical-state-change process, second trit to #{orientation_label(id)} locus, and third trit to #{phase_label(id)} phase.",
    coverage: "Thermal, phase, compositional, chemical, electrical, mechanical, and other intrinsic material changes at an explicit scale.",
    territory: "Only change in intrinsic physical state at the selected locus; cause, purpose, route, value, and result classification remain separate.",
    risk: "Its breadth requires compounds or modifiers for the change kind, cause, magnitude, and result, but that is safer than nine overloaded English verbs."
  )
  transfer_candidate = candidate(
    "material_transfer",
    design.fetch("transfer_title"),
    design.fetch("transfer_definition"),
    TRANSFER_SCORES.fetch(id),
    fit: "Directional matter flux strongly expresses the #{orientation_label(id)} axis and the #{phase_label(id)} phase.",
    coverage: "Uptake, delivery, circulation, redistribution, transport interfaces, resource accounting, and mass-flow programs.",
    territory: "Matter crossing a bearer, target, or system boundary.",
    risk: "It collides with MOV displacement and CON transfer relations, and it leaves heating, melting, deformation, reaction, and other non-flux material processes without a general MAT process atom."
  )
  energy_candidate = candidate(
    "energy_or_work_process",
    design.fetch("energy_title"),
    design.fetch("energy_definition"),
    ENERGY_SCORES.fetch(id),
    fit: "Energy and force are central to Matter and can be oriented inward, toward a target, or across a system.",
    coverage: "Energy conversion, force application, work, heat transfer, electrical exchange, and physical simulation.",
    territory: "Energy or force process rather than material state generally.",
    risk: "It is too narrow for the entire Matter process layer and collides with later MAT capacities/relationships, MOV mechanics, and quantitative grammar."
  )
  {
    "canonical_id" => id,
    "fixed_generated_fields" => fixed.fetch(id),
    "current_phase2_meaning" => {
      "title" => current.fetch("title"),
      "definition" => current.fetch("core_definition"),
      "why_probably_chosen" => design.fetch("current_rationale")
    },
    "candidates" => [current_candidate, winner_candidate, transfer_candidate, energy_candidate],
    "recommended_winner" => "physical_state_change",
    "recommended_title" => design.fetch("recommended_title"),
    "recommended_invariant_definition" => design.fetch("definition"),
    "confidence" => design.fetch("confidence"),
    "canonicalized" => false
  }
end

scored = {
  "metadata" => {
    "title" => "MAT:100–122 adversarial scored candidates",
    "status" => "ready_for_user_approval_not_canonical",
    "architecture_dependency" => "Era Zero Core Architecture 1.0 only",
    "semantic_dependency_on_pending_mov_200_222" => false,
    "semantic_dependency_on_pending_mat_000_022" => false,
    "candidate_policy" => "current Phase 2 candidate plus three genuinely different replacements",
    "roots_canonicalized" => []
  },
  "score_dimensions" => SCORE_KEYS,
  "roots" => scored_roots
}

def examples_for(id, design)
  [
    review_example(
      category: "ordinary_conversation",
      graph: design["winner_example"][0],
      literal: design["winner_example"][1],
      natural: design["winner_example"][2],
      analysis: "Direct ordinary use of the proposed invariant."
    ),
    review_example(
      category: "physical_or_spatial",
      graph: design["physical_example"][0],
      literal: design["physical_example"][1],
      natural: design["physical_example"][2],
      analysis: "Physical example; any location is contextual and does not replace the intrinsic-change invariant."
    ),
    review_example(
      category: "temporal_or_sequential",
      graph: design["temporal_example"][0],
      literal: design["temporal_example"][1],
      natural: design["temporal_example"][2],
      analysis: "Time or sequence is supplied by the graph, not silently by the atomic root."
    ),
    review_example(
      category: "cross_family_compound",
      graph: design["compound_example"][0],
      literal: design["compound_example"][1],
      natural: design["compound_example"][2],
      analysis: "A decomposition sketch showing how purpose, harm, life, restoration, or creation remains outside MAT."
    ),
    review_example(
      category: "executable_or_programming",
      graph: design["program_example"][0],
      literal: design["program_example"][1],
      natural: design["program_example"][2],
      analysis: "Typed event-state interpretation suitable for a future semantic IR.",
      pseudocode: design["program_example"][3]
    ),
    review_example(
      category: "counterexample",
      graph: design["counterexample"][0],
      literal: design["counterexample"][1],
      natural: design["counterexample"][2],
      analysis: design["counterexample"][3],
      use_status: "must_not_use_this_mat_root"
    )
  ]
end

recommended_roots = IDS.map do |id|
  design = ROOT_DESIGN.fetch(id)
  address = id.split(":").last
  orientation = orientation_for(id)
  phase = phase_for(id)
  triplet = "#{id[0..-2]}0–#{id[0..-2]}2"
  same_phase_other = IDS.select { |other| phase_for(other) == phase && other != id }
  {
    "fixed_generated_fields" => fixed.fetch(id),
    "proposal_status" => "recommended_pending_user_decision_not_canonical",
    "proposed_title" => design.fetch("recommended_title"),
    "invariant_definition" => design.fetch("definition"),
    "semantic_center" => "physical-state change",
    "semantic_boundaries" => [
      "Includes a change in an intrinsic physical state of matter at the stated observational scale.",
      "Allows thermal, phase, compositional, chemical, electrical, or mechanical specialization without building those subtypes into the atom.",
      "Does not require an intentional agent, beneficial or harmful result, transfer path, schedule, or named cause.",
      "The process locus is #{orientation_label(id)} and the lexical phase is #{phase_label(id)}."
    ],
    "excluded_meanings" => [
      "Position or displacement without intrinsic physical-state change belongs to MOV.",
      "Creation purpose belongs to CRE; structural organization to STR; damage to WRN; restoration to REP.",
      "Mental, informational, logical, social, and ontological changes belong to their own families.",
      "Matter/energy transport, input, output, circulation, or exchange requires MOV/CON roles unless intrinsic physical-state change is also asserted.",
      "Scheduling, planning, queueing, readiness, probability, and future certainty are never supplied by lexical trit 2.",
      "A material entity/condition belongs to MAT:0xx; a capacity or relationship remains for MAT:2xx review."
    ],
    "nearest_neighbors" => {
      "triplet" => triplet,
      "same_triplet_completed" => "#{id[0..-2]}0",
      "same_triplet_active" => "#{id[0..-2]}1",
      "same_triplet_potential" => "#{id[0..-2]}2",
      "same_phase_other_loci" => same_phase_other,
      "entity_layer" => "MAT:0xx describes material bearers/conditions, not change events.",
      "capacity_relationship_layer" => "MAT:2xx remains provisional and must not be preempted by this process root."
    },
    "address_explanation" => {
      "first_trit_1" => "Selects a process/action/transformation rather than a material entity or capacity.",
      "second_trit_#{orientation}" => case orientation
                                     when "0" then "Localizes the physical-state change within the focal bearer: inward/self/source orientation."
                                     when "1" then "Localizes the physical-state change in a distinct target: outward/other/target orientation."
                                     when "2" then "Distributes the physical-state change across interacting parts of a shared system or environment."
                                     end,
      "third_trit_#{phase}" => case phase
                              when "0" then "Selects the completed lexical phase: the change event reached its boundary."
                              when "1" then "Selects the active lexical phase: the change is presently ongoing."
                              when "2" then "Selects a nonactualized lexical phase: the change is possible but neither active nor completed."
                              end
    },
    "runtime_state_interpretations" => runtime_for(id),
    "lexical_third_trit_vs_runtime_2" => "The third lexical trit permanently selects #{phase_label(id)} physical-state change. Runtime `[2]/num` instead qualifies the current status of a token of that already selected lexeme and never inserts planning, scheduling, or a different lexical phase.",
    "cross_family_comparisons" => cross_family_for(id),
    "examples" => examples_for(id, design),
    "future_compound_decomposition_sketches_not_canonical" => [
      "#{id} + change-kind modifier → a specific physical process such as melting, heating, curing, or deformation",
      "#{id} + CRE/STR/WRN/REP predicate → created, organized, harmful, or restorative physical change",
      "#{id} + MOV/CON roles → material ingress, delivery, transport, circulation, or exchange with explicit participants"
    ],
    "later_era_evolution_notes" => [
      "Later technical vocabulary may subtype physical-state dimensions and attach measurements without changing this invariant.",
      "Later colloquial forms may lexicalize common compounds such as melt, burn, or bend, but the Era Zero atom remains the general locus-and-phase process.",
      "Any future reassignment requires an explicit versioned migration after user approval."
    ],
    "confidence" => design.fetch("confidence"),
    "canonicalized" => false
  }
end

recommended = {
  "metadata" => {
    "title" => "MAT:100–122 recommended permanent semantic specifications",
    "status" => "ready_for_user_approval_not_canonical",
    "review_scope" => "MAT:100–122 only",
    "semantic_architecture" => "physical-state change × locus × lexical phase",
    "roots_canonicalized" => [],
    "stop_boundary" => ["MAT:200–222", "any other root block", "Gate 4", "translator implementation"]
  },
  "block_invariant" => "MAT:1xx denotes physical-state change. The second trit selects focal, target, or systemic locus; the third selects completed, ongoing, or nonactualized phase.",
  "roots" => recommended_roots
}

stress_rows = [
  ["melt", "direct proposed root", "MAT:100/101/102, MAT:110/111/112, or MAT:120/121/122 by locus and phase", "Melting is a physical-state change; English omits locus and phase."],
  ["freeze", "direct proposed root", "MAT process root by locus and phase + phase-kind modifier", "Freezing specializes physical-state change."],
  ["evaporate", "direct proposed root", "MAT process root by locus and phase + phase-kind modifier", "Phase transition is direct; escape path is separate MOV."],
  ["condense", "direct proposed root", "MAT process root by locus and phase + phase-kind modifier", "Condensation is intrinsic material change."],
  ["heat", "direct proposed root", "MAT process root by locus and phase + thermal modifier", "Heating changes thermal state."],
  ["cool", "direct proposed root", "MAT process root by locus and phase + thermal modifier", "Cooling changes thermal state."],
  ["warm", "direct proposed root", "active or completed MAT change + magnitude", "Warm may also describe a resulting condition."],
  ["chill", "direct proposed root", "MAT change + thermal direction and magnitude", "The atom does not encode direction or amount."],
  ["burn", "composition", "MAT change + WRN and/or CRE reaction-kind", "Burning is physical change often classified as destructive."],
  ["ignite", "composition", "MAT:100/101/110/111 + transition-to-combustion modifier", "Onset and causation require event structure."],
  ["extinguish", "composition", "MAT target change + REP/WRN[0] as context requires", "Ending combustion is not a primitive in this block."],
  ["dissolve", "direct proposed root", "MAT change by affected locus + dissolution modifier", "Dissolution is a material-state/composition change."],
  ["crystallize", "direct proposed root", "MAT change by locus and phase + crystallization modifier", "Crystallization is physical-state change."],
  ["corrode", "composition", "MAT active/potential change + WRN damage", "Corrosion is material change with harmful interpretation."],
  ["rust", "composition", "MAT change + chemical-kind modifier + WRN when damage is asserted", "Rust is a specific reaction/result."],
  ["oxidize", "direct proposed root", "MAT change + chemical-kind modifier", "Oxidation need not be harmful."],
  ["reduce chemically", "direct proposed root", "MAT change + chemical-kind modifier", "Chemical reduction is physical composition/state change."],
  ["ferment", "composition", "MAT change + LIF microorganism/process context", "Fermentation joins material and living processes."],
  ["digest", "composition", "LIF process + MAT focal/target change", "Biological digestion is not Matter alone."],
  ["metabolize", "canonical/future other family", "LIF process + MAT participants", "Metabolism is fundamentally living-system activity."],
  ["cure material", "direct proposed root", "MAT change by locus and phase + curing modifier", "Material curing is direct."],
  ["harden", "direct proposed root", "MAT change + property-direction modifier", "Hardening changes material response properties."],
  ["soften", "direct proposed root", "MAT change + property-direction modifier", "Softening changes material response properties."],
  ["bend", "direct proposed root", "MAT target/focal change + deformation modifier", "Bending is intrinsic deformation; mere rotation is MOV."],
  ["deform", "direct proposed root", "MAT process root by locus and phase", "Deformation is a physical-state change."],
  ["stretch", "direct proposed root", "MAT change + deformation direction/quantity", "Magnitude and axis require grammar."],
  ["compress", "direct proposed root", "MAT change + compression modifier and quantity", "Pressure cause remains separate."],
  ["fracture", "composition", "MAT change + WRN damage", "Fracture combines physical change with failure."],
  ["break", "composition", "MAT change + WRN/STR boundary failure", "English break conflates process and failure result."],
  ["crush", "composition", "MAT target change + force/cause + WRN as needed", "Cause and damage are separate."],
  ["grind", "composition", "MAT target change + repetition/instrument roles", "Grinding is iterated deformation/fragmentation."],
  ["mix", "direct proposed root", "MAT:120/121/122 when distributed intrinsic composition changes; otherwise MOV/STR composition", "Mixing may be state change or only rearrangement."],
  ["separate mixture", "composition", "MAT change + STR partition/MOV separation", "Separation adds topology and displacement."],
  ["filter", "composition", "STR selection boundary + MOV material passage + MAT bearers", "Filtering is not one intrinsic state-change atom."],
  ["absorb", "composition", "MAT focal change + MOV/CON ingress roles", "Absorption includes transfer across a boundary."],
  ["ingest", "composition", "LIF actor + MOV/CON ingress + MAT object", "Ingestion is living-agent intake."],
  ["consume", "unresolved lexical ambiguity", "MAT change, LIF use, or resource/accounting graph by sense", "English consume spans physical, biological, and abstract senses."],
  ["emit", "composition", "MOV source departure + MAT bearer/energy + cause", "Emission is outward movement, not necessarily intrinsic change."],
  ["excrete", "composition", "LIF process + MOV source departure + MAT bearer", "Biological expulsion is cross-family."],
  ["leak", "composition", "MOV source departure + STR boundary failure + MAT bearer + WRN as needed", "Leak includes displacement and failed containment."],
  ["pour", "canonical/future other family", "MOV movement + MAT aggregate + agent/instrument roles", "Pouring can occur without material-state change."],
  ["inject", "composition", "MOV target approach/arrival + MAT bearer + CON/role grammar", "Injection is targeted transfer."],
  ["coat", "composition", "MAT target change + MOV/CON material delivery + CRE goal if intentional", "Coating combines delivery, result, and often purpose."],
  ["paint", "composition", "CRE design/purpose + MAT target change + material delivery", "Painting is intentional creation plus physical process."],
  ["forge", "composition", "CRE production + MAT target change + force/thermal modifiers", "Forging is not an atomic target change without purpose and method."],
  ["fabricate", "canonical/future other family", "CRE process + MAT physical realization", "Fabrication is creation-oriented."],
  ["manufacture", "canonical/future other family", "CRE/STR process + MAT realization", "Manufacture includes design, organization, and production."],
  ["assemble", "canonical/future other family", "STR organization + CRE process + MAT parts", "Assembly changes structure, not necessarily intrinsic material state."],
  ["disassemble", "composition", "STR organization reversal + MOV part separation + MAT parts", "Disassembly is structural."],
  ["repair", "canonical/future other family", "REP process + MAT affected bearer/change", "Restorative purpose belongs to REP."],
  ["heal", "canonical/future other family", "REP + LIF + MAT physical realization", "Healing is restorative and biological."],
  ["grow", "canonical/future other family", "LIF growth + MAT incorporation/change", "Growth is living development when biological."],
  ["decay", "composition", "MAT change + WRN/LIF/ORI context", "Decay may be material, biological, or abstract."],
  ["decompose materially", "direct proposed root", "MAT change + decomposition modifier", "Material decomposition is physical composition change."],
  ["charge battery", "composition", "MAT focal/target change + later MAT energy capacity + quantity", "Stored capacity is not a process invariant."],
  ["discharge battery", "composition", "MAT change + later MAT capacity + energy transfer roles", "Capacity and transfer need separate semantics."],
  ["power device", "composition", "MAT active condition/process + later MAT energy capacity + CON roles", "Power can mean supply, capacity, or operation."],
  ["apply force", "composition", "MAT target change only if state changes + force relation/quantity", "A force with no intrinsic change is not direct MAT:111."],
  ["push", "canonical/future other family", "MOV/force relation; add MAT target change if deformation occurs", "Pushing usually foregrounds motion."],
  ["pull", "canonical/future other family", "MOV/force relation; add MAT change if deformation occurs", "Pulling usually foregrounds motion."],
  ["carry", "canonical/future other family", "MOV shared-frame movement + CON support relation + MAT object", "Carrying does not imply intrinsic change."],
  ["transport", "canonical/future other family", "MOV process + MAT bearer + source/target roles", "Transport is displacement."],
  ["circulate", "composition", "MOV shared-frame movement + MAT material; MAT:121 only when distributed state change also occurs", "Pure circulation is not physical-state change."],
  ["exchange materials", "composition", "CON participant relation + MOV transfers + MAT bearers", "Exchange ownership/participants are separate."],
  ["redistribute", "composition", "MOV movements + STR distribution + MAT bearers", "Redistribution can preserve intrinsic states."],
  ["recycle", "composition", "CRE/REP goal + MAT systemic change + MOV/STR logistics", "Recycling includes purpose and multi-step structure."],
  ["process a batch", "unresolved lexical ambiguity", "MAT:120/121/122 only for distributed physical change; otherwise CRE/LOG/STR", "Process is domain-unspecific."],
  ["phase transition", "direct proposed root", "MAT process root by locus and phase + phase-kind", "A central direct use."],
  ["physical state change", "direct proposed root", "MAT:100–122 by locus and lexical phase", "This is the block invariant."],
  ["transform", "unresolved lexical ambiguity", "MAT, CRE, STR, DAT, MIN, LIF, or ORI by changed domain", "English transform is cross-domain."],
  ["convert energy", "composition", "MAT state change + later energy relationship/quantity", "Energy-specific conversion is narrower than the block invariant."],
  ["create", "canonical/future other family", "CRE", "Creation is not equivalent to physical change."],
  ["destroy", "composition", "WRN/CRE/ORI + MAT physical change as applicable", "Destruction includes loss and evaluation."],
  ["data mutation", "canonical/future other family", "DAT/LOG", "Abstract information change is not Matter."],
  ["move", "canonical/future other family", "MOV", "Position change alone is Motion."],
  ["temperature rise of five degrees", "grammar or quantity", "MAT active/completed change + thermal direction + quantity 5", "Magnitude requires quantity grammar."],
  ["possible melting scheduled tomorrow", "composition", "MAT:102/112/122 + LOG schedule + ORI/reference time", "Lexical potential does not encode schedule."],
  ["material change probability", "grammar or quantity", "MAT potential process + LOG probability value", "Probability is not lexical trit 2."],
  ["finished changing but result unknown", "composition", "MAT:100/110/120[1] + DAT/LOG unresolved result", "Completed event and unknown result are independent."],
  ["change paused midway", "composition", "MAT active root with runtime/state/timing grammar", "Paused execution is not automatically lexical potential."],
  ["no physical change", "root plus runtime", "appropriate MAT process root [0]", "Runtime zero negates the selected process assertion."],
  ["uncertain whether change completed", "root plus runtime", "MAT:100/110/120[2]/num", "Runtime 2 qualifies the completion claim; it does not select potential process."]
].freeze

stress = {
  "metadata" => {
    "title" => "MAT:100–122 semantic stress tests",
    "status" => "review_evidence_not_canonical",
    "test_count" => stress_rows.length,
    "forced_atomic_mappings" => false
  },
  "classification_values" => stress_rows.map { |row| row[1] }.uniq,
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

File.write(File.join(ROOT, "reviews/MAT_100_122_scored_candidates.yaml"), YAML.dump(scored))
File.write(File.join(ROOT, "reviews/MAT_100_122_recommended_spec.yaml"), YAML.dump(recommended))
File.write(File.join(ROOT, "reviews/MAT_100_122_stress_tests.yaml"), YAML.dump(stress))

peer = +"# MAT:100–122 Adversarial Semantic Peer Review\n\n"
peer << "Status: **READY FOR USER APPROVAL — NOT CANONICAL**\n\n"
peer << "Scope is strictly `MAT:100–122`. The current Phase 2 meanings are candidates, not presumptions. Deterministic generated fields are fixed. The review depends only on Core Architecture 1.0 and the 45 canonical LIF/MOV roots; it does not treat pending `MOV:200–222` or `MAT:000–022` recommendations as authority.\n\n"
peer << "## Executive recommendation\n\n"
peer << "Use one invariant process—**physical-state change**—with two orthogonal address dimensions:\n\n"
peer << "- second trit `0`: change localized within the focal material bearer;\n"
peer << "- second trit `1`: change localized in a distinct material target;\n"
peer << "- second trit `2`: change distributed across materially interacting parts of a shared system;\n"
peer << "- third trit `0/1/2`: completed / ongoing / possible-but-nonactualized.\n\n"
peer << "This removes result-state stability, consolidation, fabrication purpose, force, transfer, resource roles, cycles, staging, and queues from the atomic definitions. Those meanings remain available to compounds, roles, grammar, other families, or later MAT layers.\n\n"
peer << "## Fixed generated forms\n\n"
peer << "| ID | Universal slot | Transliteration | Compact | Formal carrier | Harmony | Relative note path |\n|---|---|---|---|---|---|---|\n"
IDS.each do |id|
  form = fixed.fetch(id)
  peer << "| `#{id}` | #{form["universal_slot"]} | `#{form["family_qualified_transliteration"]}` | `#{form["local_compact_root"]}` | `#{form["formal_carrier"]}` | `#{form["harmonic_signature_semitones"].join(", ")}` | `#{form["relative_note_path_semitones"].join(", ")}` |\n"
end
peer << "\n"

scored_roots.each do |root|
  id = root.fetch("canonical_id")
  design = ROOT_DESIGN.fetch(id)
  spec = recommended_roots.find { |item| item.dig("fixed_generated_fields", "canonical_id") == id }
  peer << "## #{id} — #{design["recommended_title"]}\n\n"
  peer << "**Why the current meaning was probably chosen.** #{design["current_rationale"]}\n\n"
  peer << "| Candidate | Atomic | Address | MAT | Triplet | Neighbor | Cross-family | Everyday | Technical | Compound | Translation | Total |\n"
  peer << "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n"
  root.fetch("candidates").each do |item|
    score = item.fetch("scores")
    peer << "| #{item["title"]} | #{SCORE_KEYS.map { |key| score[key] }.join(" | ")} | **#{item["total"]}/100** |\n"
  end
  peer << "\n"
  root.fetch("candidates").each do |item|
    analysis = item.fetch("analysis")
    peer << "- **#{item["title"]}:** #{analysis["why_it_fits"]} Covers: #{analysis["useful_coverage"]} Territory: #{analysis["semantic_territory_consumed"]} Risk: #{analysis["risks_and_future_limitations"]}\n"
  end
  peer << "\n**Recommendation:** **#{design["recommended_title"]}** (#{root["candidates"][1]["total"]}/100; confidence #{(design["confidence"] * 100).round}%).\n\n"
  peer << "> #{design["definition"]}\n\n"
  peer << "**Address fit.** #{spec["address_explanation"].values.join(" ")}\n\n"
  peer << "**Boundaries.** #{spec["semantic_boundaries"].join(" ")}\n\n"
  peer << "**Exclusions.** #{spec["excluded_meanings"].join(" ")}\n\n"
  peer << "**Nearest neighbors.** Same triplet `#{spec.dig("nearest_neighbors", "triplet")}`; same-phase other loci #{spec.dig("nearest_neighbors", "same_phase_other_loci").map { |other| "`#{other}`" }.join(", ")}. #{spec.dig("nearest_neighbors", "entity_layer")} #{spec.dig("nearest_neighbors", "capacity_relationship_layer")}\n\n"
  peer << "**Runtime states.** `[0]` #{spec.dig("runtime_state_interpretations", "0")} `[1]` #{spec.dig("runtime_state_interpretations", "1")} `[2]/num` #{spec.dig("runtime_state_interpretations", "2")}\n\n"
  peer << "**Lexical/runtime distinction.** #{spec["lexical_third_trit_vs_runtime_2"]}\n\n"
  peer << "**Examples.**\n\n"
  peer << "| Type | Graph | Literal gloss | Natural rendering | Runtime | Use |\n|---|---|---|---|---:|---|\n"
  spec.fetch("examples").each do |item|
    peer << "| #{item["category"]} | `#{item["semantic_graph"]}` | #{item["literal_gloss"]} | #{item["natural_english"]} | `[#{item["runtime_state"]}]` | #{item["use_status"]} |\n"
  end
  peer << "\n**Future compound sketches—not canonical.** #{spec["future_compound_decomposition_sketches_not_canonical"].join("; ")}.\n\n"
  peer << "**Later-Era notes.** #{spec["later_era_evolution_notes"].join(" ")}\n\n"
end

peer << "## Nine-root contrast matrix\n\n"
peer << "| Root | Owns | Closest exclusions | Reserved for compounds | Intentionally undefined here |\n|---|---|---|---|---|\n"
IDS.each do |id|
  title = ROOT_DESIGN.dig(id, "recommended_title")
  locus = orientation_label(id)
  phase = phase_label(id)
  peer << "| `#{id}` | #{title}: #{phase} physical-state change at #{locus} locus | movement, structure, creation, damage, repair | change kind, cause, result, transfer, purpose, measurement | schedule, probability, material property/capacity |\n"
end
peer << "\n"
peer << "## Triplet coherence assessment\n\n"
peer << "- `MAT:100–102` keeps one process and one locus: physical-state change within the focal bearer. Only lexical phase changes.\n"
peer << "- `MAT:110–112` keeps one process and one locus: physical-state change in a distinct target. Only lexical phase changes.\n"
peer << "- `MAT:120–122` keeps one process and one locus: physical-state change distributed across a shared material system. Only lexical phase changes.\n"
peer << "- Across rows, same-phase roots differ only by locus. No root silently introduces an agent, schedule, cycle, transfer path, purpose, or result judgment.\n\n"
peer << "## Coverage and restraint\n\n"
peer << "The packet tests #{stress_rows.length} English concepts. Common intrinsic changes such as melting, heating, cooling, deformation, reaction, dissolution, and curing use a proposed MAT process plus change-kind detail. Transport, circulation, assembly, fabrication, repair, growth, data mutation, and scheduling remain other-family or compound meanings. English “transform,” “consume,” and “process” remain explicitly sense-ambiguous.\n\n"
peer << "## Unresolved decisions\n\n"
peer << "- No root must remain unresolved under the proposed grid.\n"
peer << "- The catalogue may later choose “physical-state change” or “material change” as its preferred short wording; the invariant definitions already fix the intended boundary.\n"
peer << "- A later ontology must decide how thermal, phase, chemical, electrical, and mechanical change kinds are represented. That decision must not broaden these atoms.\n\n"
peer << "## Proposed titles and invariant definitions\n\n"
IDS.each { |id| peer << "- `#{id}` — **#{ROOT_DESIGN.dig(id, "recommended_title")}**: #{ROOT_DESIGN.dig(id, "definition")}\n" }
peer << "\n"
peer << "## Approval checklist\n\n"
peer << "- [ ] Approve the shared `physical-state change` invariant for MAT:1xx.\n"
peer << "- [ ] Approve focal / target / shared-system locus as the second-trit contrast.\n"
peer << "- [ ] Approve completed / ongoing / nonactualized as the third-trit contrast.\n"
peer << "- [ ] Confirm transfer, force, resource, cycle, fabrication, queue, schedule, and result-state meanings remain outside the atoms.\n"
peer << "- [ ] Confirm all nine titles and invariant definitions, or name revisions.\n"
peer << "- [ ] Authorize a separate canonization migration only if the packet is accepted.\n\n"
peer << "- **Roots canonized by this packet:** none.\n"
peer << "- **Stop boundary honored:** no `MAT:200–222`, other root block, Gate 4, compound architecture, renderer, or translator implementation was begun.\n\n"
peer << "**READY FOR USER APPROVAL**\n"
File.write(File.join(ROOT, "reviews/MAT_100_122_peer_review.md"), peer)

collision = +"# MAT:100–122 Collision Report\n\n"
collision << "Status: **peer-review evidence — not canonical**\n\n"
collision << "## Core ownership rule\n\n"
collision << "The proposed block owns intrinsic physical-state change. It does not own positional displacement, participant transfer, structure, purpose, damage, repair, living growth, data mutation, control flow, or ontological becoming. Locus and lexical phase are fixed by address; change kind, cause, magnitude, result, and evaluation remain compositional.\n\n"
collision << "## Intra-Matter boundary\n\n"
collision << "| Layer | Owns | Must not absorb |\n|---|---|---|\n"
collision << "| `MAT:0xx` | material entities and conditions after their own review | process events |\n"
collision << "| `MAT:1xx` proposed | physical-state change by locus and phase | material capacity, stored energy, force relation, conservation law |\n"
collision << "| `MAT:2xx` pending | capacities and relationships after later review | entity or process semantics already assigned elsewhere |\n\n"
collision << "## Cross-family collision matrix\n\n"
collision << "| Root | LIF | MOV | MIN | CON | STR | WRN | REP | LOG | DAT | CRE | ORI |\n|---|---|---|---|---|---|---|---|---|---|---|---|\n"
IDS.each do |id|
  audit = cross_family_for(id)
  collision << "| `#{id}` | #{CROSS_FAMILIES.map { |family| audit[family] }.join(" | ")} |\n"
end
collision << "\n## High-risk English traps\n\n"
collision << "- **Change** is not automatically Matter; select the family of the changed state.\n"
collision << "- **Move, carry, circulate, inject, emit, and transport** foreground displacement or participant relations and require MOV/CON even when matter participates.\n"
collision << "- **Build, fabricate, manufacture, and create** require CRE/STR purpose and organization; MAT supplies only physical realization when present.\n"
collision << "- **Break, corrode, decay, and destroy** require WRN or other evaluation when damage or loss is asserted.\n"
collision << "- **Repair and heal** require REP; physical change alone does not encode restoration.\n"
collision << "- **Queued, staged, scheduled, ready, likely, and future** are never lexical meanings of third trit 2.\n"
collision << "- **Completed** describes the process boundary, not a stable, successful, intact, useful, or known result.\n\n"
collision << "## Disposition\n\n"
collision << "All nine recommendations stand alone as Matter process atoms, modify or combine with other-family predicates when those semantics are present, and avoid blocking collisions. They remain provisional pending explicit user approval.\n"
File.write(File.join(ROOT, "reviews/MAT_100_122_collision_report.md"), collision)

puts "Built MAT:100–122 peer-review packet (five content files; validation generated separately)."
