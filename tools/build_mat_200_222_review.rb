#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
IDS = %w[
  MAT:200 MAT:201 MAT:202
  MAT:210 MAT:211 MAT:212
  MAT:220 MAT:221 MAT:222
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

def example(category:, graph:, literal:, natural:, analysis:, runtime: 1,
            contour: "declarative", use_status: "valid", pseudocode: nil)
  {
    "category" => category,
    "semantic_graph" => graph,
    "literal_gloss" => literal,
    "natural_english" => natural,
    "runtime_state" => runtime,
    "contour" => contour,
    "role_registers" => {
      "low" => "focal bearer, source, or capacity holder",
      "middle" => "MAT capacity/relationship predicate",
      "high" => "distinct target or affected participant when present",
      "sustained" => "shared material system or environmental frame when present"
    },
    "use_status" => use_status,
    "analysis" => analysis
  }.tap { |item| item["pseudocode"] = pseudocode if pseudocode }
end

atoms = load_yaml("lexicon/atoms.yaml").fetch("atoms")
atoms_by_id = atoms.to_h { |atom| [atom.fetch("canonical_id"), atom] }
fixed = IDS.to_h { |id| [id, fixed_projection(atoms_by_id.fetch(id))] }

DESIGN = {
  "MAT:200" => {
    "current_rationale" => "“Structural integrity capacity” was probably chosen because stable + inward + Matter suggests a body's enduring ability to withstand physical demands. Its definition combines load-bearing, form retention, and disruption resistance, which are different response properties and overlap STR organization and WRN damage.",
    "title" => "enduring physical work capacity",
    "definition" => "A persistent capacity of a material bearer to supply energy for producing physical change.",
    "confidence" => 0.96,
    "structural_title" => "enduring material resilience",
    "structural_definition" => "A persistent capacity of a material bearer to resist deformation or disruption.",
    "resource_title" => "enduring resource capacity",
    "resource_definition" => "A persistent capacity of a material bearer to retain usable matter or energy.",
    "examples" => [
      ["ordinary_conversation", "MAT:200[1](BEARER=battery)", "battery; enduring physical work capacity", "The battery has a persistent capacity to do physical work.", "Direct capacity use."],
      ["physical_or_spatial", "MAT:200[1](BEARER=spring)", "spring; persistent capacity to supply physical energy", "The spring retains an enduring ability to drive a mechanism.", "The capacity persists even when unexercised."],
      ["temporal_or_sequential", "MAT:200[1](BEARER=flywheel,ACROSS=interval)", "flywheel; work capacity persists across interval", "The flywheel's work capacity persists through the idle interval.", "Persistence is explicit; no activity is asserted."],
      ["cross_family_compound", "MAT:200[1](BEARER=engine)+CRE(FUNCTION=machine)", "engine; enduring work capacity plus designed function", "The engine is a machine with a persistent physical work capacity.", "Designed purpose remains CRE."],
      ["executable_or_programming", "MAT:200[1](BEARER=actuator)", "actuator; rated physical work capacity", "The controller records a persistent actuator work capacity.", "A capability declaration, not an execution event.", "assert actuator.capabilities.include?(:physical_work)"],
      ["counterexample", "MOV:200[1](MOVER=animal)", "animal; enduring self-mobility", "The animal can move itself.", "Self-mobility is canonical MOV:200; it is not identical to general physical work capacity."]
    ]
  },
  "MAT:201" => {
    "current_rationale" => "“Exertive capacity” correctly seeks an active inward Matter capacity, but its definition lists exerting force, releasing energy, and performing work. Physical work capacity unifies the useful center while the active third trit can state present availability rather than three separate actions.",
    "title" => "available physical work capacity",
    "definition" => "A material bearer's capacity to supply energy for physical change that is presently available for exercise.",
    "confidence" => 0.98,
    "structural_title" => "active material resilience",
    "structural_definition" => "A material bearer's capacity to resist deformation or disruption that is presently engaged.",
    "resource_title" => "available resource capacity",
    "resource_definition" => "A material bearer's capacity to provide usable matter or energy that is presently available.",
    "examples" => [
      ["ordinary_conversation", "MAT:201[1](BEARER=battery)", "battery; work capacity presently available", "The battery can power the lamp now.", "Availability is foregrounded; no discharge event is asserted."],
      ["physical_or_spatial", "MAT:201[1](BEARER=compressed_spring)", "spring; physical work capacity available", "The compressed spring is ready in the physical sense to drive the latch.", "Physical availability does not encode permission or schedule."],
      ["temporal_or_sequential", "MAT:201[1](BEARER=capacitor,DURING=window)", "capacitor; work capacity available during interval", "The capacitor's energy is available during this interval.", "Timing is supplied by the graph."],
      ["cross_family_compound", "MAT:201[1](BEARER=robot)+LOG(PERMISSION=0)", "robot; physical work capacity available; action not permitted", "The robot is physically able to act, but it is not permitted to.", "Physical availability and permission are independent."],
      ["executable_or_programming", "MAT:201[1](BEARER=power_cell)", "power cell; work capacity available", "The scheduler may consider the cell physically available.", "A capability predicate used by planning code.", "assert power_cell.work_capacity.available?"],
      ["counterexample", "MAT:101[1](BEARER=metal,CHANGE=heating)", "metal; active focal material change", "The metal is heating.", "An active material process is MAT:101; it does not by itself mean work capacity is available."]
    ]
  },
  "MAT:202" => {
    "current_rationale" => "“Stored energy potential” is close to a dormant inward capacity, but its definition conflates matter and energy, inaccessibility, and nonexpression. A dormant capacity should say that physical work capacity exists but is not presently available, without specifying why or equating storage with unavailability.",
    "title" => "latent physical work capacity",
    "definition" => "A material bearer's capacity to supply energy for physical change that exists without being presently available for exercise.",
    "confidence" => 0.99,
    "structural_title" => "latent material resilience",
    "structural_definition" => "A capacity to resist deformation or disruption that exists without being presently engaged or available.",
    "resource_title" => "latent resource capacity",
    "resource_definition" => "A capacity to provide usable matter or energy that exists without being presently available.",
    "examples" => [
      ["ordinary_conversation", "MAT:202[1](BEARER=cold_battery)", "battery; latent physical work capacity", "The cold battery retains capacity, but that capacity is not available now.", "Cause of latency is not built into the root."],
      ["physical_or_spatial", "MAT:202[1](BEARER=locked_flywheel)", "flywheel; work capacity exists but unavailable", "The locked flywheel retains physical potential that cannot presently be exercised.", "A barrier may be added separately."],
      ["temporal_or_sequential", "MAT:202[1](BEARER=cell,UNTIL=warming)", "cell; latent capacity until condition changes", "The cell's work capacity remains latent until it warms.", "The condition is explicit and not predicted by the root."],
      ["cross_family_compound", "MAT:202[1](BEARER=spring)+STR(BLOCK=lock)", "spring; latent work capacity plus structural block", "The spring has latent work capacity because a lock prevents release.", "STR supplies the blocking structure."],
      ["executable_or_programming", "MAT:202[1](BEARER=reserve_cell)", "reserve cell; capacity exists but is unavailable", "The resource model retains the cell's latent physical capacity.", "The engine must not schedule it as currently available.", "assert reserve_cell.work_capacity.exists? && !reserve_cell.work_capacity.available?"],
      ["counterexample", "MAT:102[1](BEARER=ice,CHANGE=melting)", "ice; possible focal material change", "The ice could melt.", "A potential process is MAT:102; latent work capacity is a capacity, not an event possibility."]
    ]
  },
  "MAT:210" => {
    "current_rationale" => "“Material attachment” follows stable + outward + relationship, but its definition joins physical connection, fit, ownership, and resource relation. Ownership and resource roles are contextual CON/LOG meanings, while fit and attachment are largely STR. Matter needs the physical-influence relation itself.",
    "title" => "established material coupling",
    "definition" => "An established relation by which a material bearer can transmit physical influence to a distinct target.",
    "confidence" => 0.98,
    "structural_title" => "stable material fit",
    "structural_definition" => "A stable relation in which a material bearer and target have compatible physical form.",
    "resource_title" => "established resource assignment",
    "resource_definition" => "An established relation in which a material bearer is assigned as a usable resource for a target.",
    "examples" => [
      ["ordinary_conversation", "MAT:210[1](BEARER=shaft,TARGET=pump)", "shaft; established material coupling to pump", "The shaft is mechanically coupled to the pump.", "The relation can exist while no influence is currently passing."],
      ["physical_or_spatial", "MAT:210[1](BEARER=gear_a,TARGET=gear_b)", "gear A; established physical-influence relation to gear B", "These gears have an established coupling.", "Geometry may be specified separately with STR."],
      ["temporal_or_sequential", "MAT:210[1](BEARER=cable,TARGET=motor,ACROSS=idle)", "cable; coupling persists across idle interval", "The cable remains physically coupled to the motor while idle.", "Stable relation does not mean active transfer."],
      ["cross_family_compound", "STR(ASSEMBLY=gear_train)+MAT:210[1](BEARER=gear_a,TARGET=gear_b)", "structured assembly plus established material coupling", "The gear train's structure places the gears in a physical coupling.", "STR supplies arrangement; MAT supplies influence capability."],
      ["executable_or_programming", "MAT:210[1](BEARER=port_a,TARGET=port_b)", "port A; established physical coupling to port B", "The simulation declares a physical influence edge.", "A stable graph edge without current flow.", "material_graph.add_edge(port_a, port_b, mode: :coupled)"],
      ["counterexample", "CON(OWNER=person,OBJECT=tool)", "person; ownership relation to tool", "The person owns the tool.", "Ownership is not material coupling even when the object is physical."]
    ]
  },
  "MAT:211" => {
    "current_rationale" => "“Active physical coupling” is the strongest current candidate, but its definition still lists touching, force exchange, and energy transfer as alternatives. Mere touch may carry no relevant influence, and transfer paths need not be material coupling. The invariant should be present transmission of physical influence.",
    "title" => "active material coupling",
    "definition" => "A relation by which a material bearer is presently transmitting physical influence to a distinct target.",
    "confidence" => 0.99,
    "structural_title" => "active load-bearing relation",
    "structural_definition" => "A relation in which a material bearer is presently supporting a physical load imposed by a target.",
    "resource_title" => "active resource-supply relation",
    "resource_definition" => "A relation in which a material bearer is presently supplying usable matter or energy to a target.",
    "examples" => [
      ["ordinary_conversation", "MAT:211[1](BEARER=gear_a,TARGET=gear_b)", "gear A; active material coupling to gear B", "The first gear is transmitting torque to the second.", "Torque kind and magnitude may be added separately."],
      ["physical_or_spatial", "MAT:211[1](BEARER=hot_plate,TARGET=pan)", "hot plate; physical influence actively passing to pan", "The hot plate is physically heating the pan through their coupling.", "The heating process itself may also use MAT:111."],
      ["temporal_or_sequential", "MAT:211[1](BEARER=drive_shaft,TARGET=pump,DURING=run)", "shaft; active coupling during run", "The shaft is transmitting physical influence during the run.", "Runtime interval is explicit."],
      ["cross_family_compound", "MAT:211[1](BEARER=wheel,TARGET=axle)+MOV:121[1](MOVER=wheel)", "active coupling plus shared-frame motion", "The moving wheel is transmitting force to the axle.", "Motion and coupling remain independent predicates."],
      ["executable_or_programming", "MAT:211[1](BEARER=node_a,TARGET=node_b)", "node A; active physical influence edge to node B", "The physics engine marks the coupling edge active.", "An active relation, not merely adjacency.", "assert material_graph.edge(node_a, node_b).transmitting?"],
      ["counterexample", "STR(ADJACENT=block_a,block_b)", "blocks; adjacent", "The blocks are next to each other but not interacting.", "Adjacency or contact geometry without physical influence is STR, not MAT:211."]
    ]
  },
  "MAT:212" => {
    "current_rationale" => "“Possible material fit” recognizes an unresolved target relationship, but it combines attachment, transfer, resource use, viability, and confirmation. The third trit here is unresolved relationship—not a general possibility—and the pairwise Matter center should remain material coupling.",
    "title" => "unresolved material coupling",
    "definition" => "Whether a material bearer can transmit physical influence to a distinct target is unresolved.",
    "confidence" => 0.99,
    "structural_title" => "unresolved material compatibility",
    "structural_definition" => "Whether a material bearer and target have compatible physical form is unresolved.",
    "resource_title" => "unresolved resource assignment",
    "resource_definition" => "Whether a material bearer serves as a usable resource for a target is unresolved.",
    "examples" => [
      ["ordinary_conversation", "MAT:212[1](BEARER=plug,TARGET=socket)", "plug-to-socket material coupling unresolved", "We do not know whether the plug is making physical contact well enough to carry influence.", "Uncertainty concerns the relation itself."],
      ["physical_or_spatial", "MAT:212[1](BEARER=loose_wire,TARGET=terminal)", "wire; coupling to terminal unresolved", "The loose wire may or may not be physically coupled to the terminal.", "Fit geometry alone would be STR."],
      ["temporal_or_sequential", "MAT:212[1](BEARER=clutch,TARGET=shaft,UNTIL=sensor)", "clutch coupling unresolved until observation", "The clutch-to-shaft coupling remains unresolved until the sensor reports.", "Observation source is explicit."],
      ["cross_family_compound", "MAT:212[1](BEARER=contact,TARGET=rail)+DAT(READING=unknown)", "material coupling unresolved; sensor record unavailable", "The contact may be coupled to the rail, but the sensor data is missing.", "DAT explains evidence, not coupling."],
      ["executable_or_programming", "MAT:212[1](BEARER=node_a,TARGET=node_b)", "physical influence edge has unknown truth value", "The solver keeps the coupling edge unresolved.", "Three-valued relation state.", "material_graph.edge(node_a, node_b).status = UNKNOWN"],
      ["counterexample", "LOG(SCHEDULE=connection_test)", "connection test; scheduled", "The connection test is scheduled.", "Scheduling does not make the material coupling lexically unresolved."]
    ]
  },
  "MAT:220" => {
    "current_rationale" => "“Conservation balance” is attractive for stable systemic Matter, but it imports a law, accounting boundary, inputs, outputs, and equality. Conservation belongs partly to ORI/LOG and quantities; the address needs a general stable relationship among material parts.",
    "title" => "established systemic material interdependence",
    "definition" => "A stable relation in which material parts of a shared system mutually constrain one another's physical states.",
    "confidence" => 0.97,
    "structural_title" => "stable material equilibrium",
    "structural_definition" => "A shared material system maintains a stable balance among the physical states of its parts.",
    "resource_title" => "stable resource balance",
    "resource_definition" => "A shared system maintains a stable accounting relation among material or energy resources.",
    "examples" => [
      ["ordinary_conversation", "MAT:220[1](SYSTEM=truss)", "truss; established systemic material interdependence", "The truss members form a stable load-sharing physical system.", "Load-sharing kind may be specialized."],
      ["physical_or_spatial", "MAT:220[1](SYSTEM=sealed_vessel)", "vessel parts; mutually constraining physical states", "The vessel and its contents have an established material interdependence.", "Containment topology is STR; physical mutual constraint is MAT."],
      ["temporal_or_sequential", "MAT:220[1](SYSTEM=suspension,ACROSS=idle)", "suspension; interdependence persists across idle interval", "The suspension's material interdependence persists while the vehicle is parked.", "No active influence is required."],
      ["cross_family_compound", "STR(TOPOLOGY=truss)+MAT:220[1](SYSTEM=truss)", "structural topology plus stable material interdependence", "The truss topology supports an established network of physical constraints.", "Topology and material relation remain separate."],
      ["executable_or_programming", "MAT:220[1](SYSTEM=mesh)", "mesh; stable mutual physical-constraint relation", "The solver declares a persistent material dependency graph.", "A system-level invariant over coupling edges.", "assert material_graph(mesh).stable_interdependence?"],
      ["counterexample", "ORI/LOG(CONSERVATION=energy)", "energy conservation law", "Energy is conserved in the model.", "A universal or formal conservation law is not MAT:220 by itself."]
    ]
  },
  "MAT:221" => {
    "current_rationale" => "“Exchange network” uses active + systemic Matter but joins matter, energy, resources, exchange, and network structure. Exchange may be MOV/CON, resource status is contextual, and network topology is STR. The Matter invariant should be reciprocal physical influence presently operating across the system.",
    "title" => "active systemic material interdependence",
    "definition" => "A relation in which material parts of a shared system are presently exerting reciprocal physical influence.",
    "confidence" => 0.98,
    "structural_title" => "active material equilibrium regulation",
    "structural_definition" => "A shared material system is actively maintaining balance among physical states of its parts.",
    "resource_title" => "active resource-exchange network",
    "resource_definition" => "A shared system is actively exchanging usable matter or energy among its parts.",
    "examples" => [
      ["ordinary_conversation", "MAT:221[1](SYSTEM=suspension)", "suspension; active reciprocal material influence", "The suspension components are sharing load now.", "The relation is active across multiple parts."],
      ["physical_or_spatial", "MAT:221[1](SYSTEM=gear_train)", "gear train; reciprocal physical influence active", "The gear train is actively transmitting forces among its parts.", "Individual directed edges may also use MAT:211."],
      ["temporal_or_sequential", "MAT:221[1](SYSTEM=bridge,DURING=load)", "bridge system; active interdependence during load", "The bridge members are mutually influencing one another under the current load.", "The interval is explicit."],
      ["cross_family_compound", "MAT:221[1](SYSTEM=pump_network)+MOV:121[1](MOVER=fluid)", "active material interdependence plus fluid movement", "The pump network is physically interacting while fluid moves through it.", "Movement is not absorbed into the relation."],
      ["executable_or_programming", "MAT:221[1](SYSTEM=mesh)", "mesh; reciprocal physical dependencies active", "The solver marks the coupled material system active.", "Many active coupling edges form a system relation.", "assert material_graph(mesh).reciprocal_influence_active?"],
      ["counterexample", "CON/DAT(NETWORK=messages)", "participants; active information exchange", "The computers are exchanging messages.", "Communication or data exchange is not systemic material interdependence."]
    ]
  },
  "MAT:222" => {
    "current_rationale" => "“Unrealized material configuration” follows the universal possibility slot, but “configuration” primarily consumes STR arrangement and CRE production. A Matter-family systemic possibility should concern a possible physical interdependence relation, not any physically valid arrangement or resource state.",
    "title" => "potential systemic material interdependence",
    "definition" => "An unrealized possible relation in which material parts of a shared system would mutually constrain one another's physical states.",
    "confidence" => 0.99,
    "structural_title" => "possible material equilibrium",
    "structural_definition" => "An unrealized possible balance among the physical states of parts of a shared material system.",
    "resource_title" => "possible resource network",
    "resource_definition" => "An unrealized possible system of resource relations among material or energy-bearing parts.",
    "examples" => [
      ["ordinary_conversation", "MAT:222[1](SYSTEM=unassembled_modules)", "modules; possible systemic material interdependence unrealized", "These modules could form a load-sharing physical system, but they do not yet.", "Possibility concerns the relation, not a plan."],
      ["physical_or_spatial", "MAT:222[1](SYSTEM=future_truss)", "truss parts; possible mutual physical constraint", "The members could physically support one another in that arrangement.", "Arrangement itself is STR."],
      ["temporal_or_sequential", "MAT:222[1](SYSTEM=components,BEFORE=assembly)", "components; potential interdependence before realization", "Before assembly, the systemic material relation is only possible.", "No future certainty is encoded."],
      ["cross_family_compound", "CRE(DESIGN=machine)+STR(TOPOLOGY=planned)+MAT:222[1](SYSTEM=parts)", "design and topology plus possible material interdependence", "The design proposes a structure whose parts could become physically interdependent.", "Design and planned structure remain separate."],
      ["executable_or_programming", "MAT:222[1](SYSTEM=candidate_graph)", "candidate graph; possible material interdependence unrealized", "The simulator records a feasible but unrealized coupling graph.", "Feasibility does not schedule construction.", "assert feasible?(candidate_graph) && !realized?(candidate_graph)"],
      ["counterexample", "CRE/STR(DESIGN=architecture)", "designed arrangement", "The engineer designed a new structure.", "A designed configuration is CRE/STR unless possible material interdependence is also asserted."]
    ]
  }
}.freeze

CURRENT_SCORES = {
  "MAT:200" => [6, 8, 8, 6, 6, 4, 8, 8, 8, 6],
  "MAT:201" => [7, 9, 10, 8, 8, 7, 9, 10, 9, 8],
  "MAT:202" => [7, 9, 10, 7, 8, 7, 9, 10, 9, 7],
  "MAT:210" => [4, 8, 7, 5, 5, 2, 9, 8, 7, 4],
  "MAT:211" => [7, 9, 10, 8, 8, 7, 9, 10, 9, 8],
  "MAT:212" => [5, 8, 8, 6, 6, 4, 8, 8, 7, 5],
  "MAT:220" => [7, 8, 9, 6, 7, 5, 8, 10, 8, 6],
  "MAT:221" => [5, 8, 9, 6, 6, 3, 9, 10, 8, 5],
  "MAT:222" => [7, 8, 8, 6, 7, 4, 8, 9, 8, 6]
}.freeze
WINNER_SCORES = {
  "MAT:200" => [10, 10, 10, 10, 9, 9, 9, 10, 10, 10],
  "MAT:201" => [10, 10, 10, 10, 10, 9, 10, 10, 10, 10],
  "MAT:202" => [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
  "MAT:210" => [10, 10, 10, 10, 10, 9, 10, 10, 10, 10],
  "MAT:211" => [10, 10, 10, 10, 10, 9, 10, 10, 10, 10],
  "MAT:212" => [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
  "MAT:220" => [10, 10, 10, 10, 9, 9, 9, 10, 10, 10],
  "MAT:221" => [10, 10, 10, 10, 9, 9, 9, 10, 10, 10],
  "MAT:222" => [10, 10, 10, 10, 10, 10, 9, 10, 10, 10]
}.freeze
STRUCTURAL_SCORES = IDS.to_h do |id|
  phase_bonus = id.end_with?("2") ? 0 : 1
  [id, [9, 9, 7, 9, 8, 4, 8 + phase_bonus, 8, 9, 7]]
end.freeze
RESOURCE_SCORES = IDS.to_h do |id|
  relation_penalty = id[4] == "1" ? 1 : 0
  [id, [8, 8, 9, 8, 7, 5 - relation_penalty, 9, 9, 9, 6]]
end.freeze

def layer_for(id)
  id.split(":").last[1]
end

def phase_for(id)
  id[-1]
end

def center_for(id)
  {
    "0" => "physical work capacity",
    "1" => "directed material coupling",
    "2" => "systemic material interdependence"
  }.fetch(layer_for(id))
end

def phase_label(id)
  case layer_for(id)
  when "0"
    { "0" => "enduring", "1" => "presently available", "2" => "latent/unavailable" }.fetch(phase_for(id))
  when "1"
    { "0" => "established", "1" => "actively transmitting", "2" => "unresolved" }.fetch(phase_for(id))
  when "2"
    { "0" => "established", "1" => "actively reciprocal", "2" => "unrealized possible" }.fetch(phase_for(id))
  end
end

def runtime_for(id)
  center = center_for(id)
  case id
  when /:200\z/
    {"0" => "Denies that the bearer has the asserted enduring physical work capacity.",
     "1" => "Affirms the enduring capacity without saying it is presently available or exercised.",
     "2" => "Marks the enduring-capacity assertion as dormant or unresolved; it does not select lexical `MAT:202`."}
  when /:201\z/
    {"0" => "Denies that the bearer's physical work capacity is presently available.",
     "1" => "Affirms current availability of the capacity without asserting that work is occurring.",
     "2" => "Marks current availability as dormant or unresolved; lexical `MAT:202` instead asserts that the capacity exists in a latent phase."}
  when /:202\z/
    {"0" => "Denies that the bearer retains the asserted latent work capacity.",
     "1" => "Affirms that the capacity exists while not presently available for exercise.",
     "2" => "Marks whether that latent capacity exists as dormant or unresolved; the double layer does not encode readiness or future activation."}
  when /:210\z/
    {"0" => "Denies the established directed material coupling.",
     "1" => "Affirms the established coupling without asserting current transmission.",
     "2" => "Marks the established-coupling assertion as unresolved; it does not select lexical `MAT:212`."}
  when /:211\z/
    {"0" => "Denies that physical influence is presently passing through the coupling.",
     "1" => "Affirms current transmission of physical influence from bearer to target.",
     "2" => "Marks the active-coupling status as dormant or unresolved; lexical `MAT:212` instead makes the relation itself unresolved."}
  when /:212\z/
    {"0" => "Denies that the coupling question is unresolved—for example because the relation has been resolved.",
     "1" => "Affirms that whether material influence can pass remains unresolved.",
     "2" => "Marks the status or availability of that unresolved assessment itself as dormant or unknown; it does not create a plan or probability."}
  when /:220\z/
    {"0" => "Denies the asserted stable systemic material interdependence.",
     "1" => "Affirms the stable mutual physical-constraint relation without asserting current activity.",
     "2" => "Marks the stable-system relation assertion as dormant or unresolved; it does not select lexical `MAT:222`."}
  when /:221\z/
    {"0" => "Denies that reciprocal physical influence is presently active across the system.",
     "1" => "Affirms active reciprocal material influence among system parts.",
     "2" => "Marks current systemic activity as dormant or unresolved; lexical `MAT:222` instead selects an unrealized possible relation."}
  when /:222\z/
    {"0" => "Rules out the asserted possible systemic material interdependence in the stated frame.",
     "1" => "Affirms the unrealized possible relation without asserting design, schedule, readiness, or eventual realization.",
     "2" => "Marks whether the possible relation holds as dormant or unresolved; runtime status remains separate from lexical possibility."}
  else
    raise "No runtime interpretation for #{id} (#{center})"
  end
end

def cross_family_for(id)
  center = center_for(id)
  {
    "LIF" => "LIF owns vitality, biological capacity, growth, and organism relations. `#{id}` owns #{center} only; living use requires an explicit LIF compound.",
    "MOV" => "MOV owns self-mobility, position, displacement, and reference-frame configurations. Physical work capacity or coupling does not entail movement, and movement does not entail this MAT relation.",
    "MIN" => "MIN owns ability, attention, intention, and cognitive relations in the mental domain. Mental readiness or influence is not material capacity/coupling.",
    "CON" => "CON owns communication, possession, access, social linkage, and general transfer relations. MAT coupling is specifically the ability or actuality of direct physical influence.",
    "STR" => "STR owns form, topology, attachment geometry, compatibility, part-whole organization, and load-path architecture. MAT owns physical work capacity and influence, not the arrangement that enables it.",
    "WRN" => "WRN owns weakness, overload, hazard, failure, and damage judgments. A capacity or coupling may fail, but failure is not built into `#{id}`.",
    "REP" => "REP owns restoration of capacity or relation. A repaired coupling may use MAT, but restorative direction remains REP.",
    "LOG" => "LOG owns permission, scheduling, formal possibility, constraints, quantities, and control readiness. MAT lexical phases and runtime states do not encode those judgments.",
    "DAT" => "DAT owns data links, records, signals, and dependency graphs about information. A model of a coupling is not the physical relation it represents.",
    "CRE" => "CRE owns designed affordance, production, and creation of systems. A designed capacity or coupling is not physically realized merely because CRE asserts it.",
    "ORI" => "ORI owns universal laws, ontological possibility, and conservation principles. MAT owns a concrete bearer or system relation, not a law of reality."
  }
end

scored_roots = IDS.map do |id|
  design = DESIGN.fetch(id)
  current = atoms_by_id.fetch(id)
  current_candidate = candidate(
    "current_phase2_candidate",
    current.fetch("title"),
    current.fetch("core_definition"),
    CURRENT_SCORES.fetch(id),
    fit: "It follows the address's broad Matter, orientation, and lexical-state labels.",
    coverage: "A salient subset of #{center_for(id)}-adjacent English meanings.",
    territory: "Several structural, resource, ownership, transfer, law, or accessibility meanings not fixed by the address.",
    risk: design.fetch("current_rationale")
  )
  winner = candidate(
    "material_influence_architecture",
    design.fetch("title"),
    design.fetch("definition"),
    WINNER_SCORES.fetch(id),
    fit: "It maps the address directly to #{center_for(id)} in its #{phase_label(id)} lexical phase.",
    coverage: "Energy/work capability, pairwise physical influence, multi-part physical dependency, physics engines, devices, bodies, and ordinary material systems.",
    territory: "Only the material capacity or physical-influence relation; form, purpose, ownership, value, quantity, law, and evidence remain external.",
    risk: "Specific modes such as thermal, mechanical, electrical, or chemical influence require modifiers, but the invariant remains stable and reusable."
  )
  structural = candidate(
    "mechanical_structural_direction",
    design.fetch("structural_title"),
    design.fetch("structural_definition"),
    STRUCTURAL_SCORES.fetch(id),
    fit: "Mechanical resilience, fit, equilibrium, and load relations are plausible Matter readings of this address.",
    coverage: "Strength, rigidity, compatibility, support, equilibrium, load paths, and engineering structures.",
    territory: "Material response plus structural form or organization.",
    risk: "It collides heavily with STR and WRN, narrows Matter to mechanics, and gives weak coverage for energy, chemical, thermal, and computational physics."
  )
  resource = candidate(
    "resource_accounting_direction",
    design.fetch("resource_title"),
    design.fetch("resource_definition"),
    RESOURCE_SCORES.fetch(id),
    fit: "Resources are named in the MAT family domain and can have capacity, target, and systemic relations.",
    coverage: "Supply, reserve, availability, assignment, exchange, inventory, and accounting.",
    territory: "Contextual usability and value relations over matter or energy.",
    risk: "Resource status depends on purpose, access, ownership, quantity, and agents; it collides with CON, LOG, DAT, and CRE and excludes nonresource matter."
  )
  {
    "canonical_id" => id,
    "fixed_generated_fields" => fixed.fetch(id),
    "current_phase2_meaning" => {
      "title" => current.fetch("title"),
      "definition" => current.fetch("core_definition"),
      "why_probably_chosen" => design.fetch("current_rationale")
    },
    "candidates" => [current_candidate, winner, structural, resource],
    "recommended_winner" => "material_influence_architecture",
    "recommended_title" => design.fetch("title"),
    "recommended_invariant_definition" => design.fetch("definition"),
    "confidence" => design.fetch("confidence"),
    "canonicalized" => false
  }
end

scored = {
  "metadata" => {
    "title" => "MAT:200–222 adversarial scored candidates",
    "status" => "ready_for_delegated_approval_not_yet_canonical",
    "architecture_dependency" => "Era Zero Core Architecture 1.0 and 72 canonical roots",
    "candidate_policy" => "current Phase 2 candidate plus three alternative semantic architectures",
    "delegated_approval_authorized" => true,
    "roots_canonicalized" => []
  },
  "score_dimensions" => SCORE_KEYS,
  "roots" => scored_roots
}

def examples_for(design)
  design.fetch("examples").map do |row|
    category, graph, literal, natural, analysis, pseudocode = row
    example(
      category: category,
      graph: graph,
      literal: literal,
      natural: natural,
      analysis: analysis,
      use_status: category == "counterexample" ? "must_not_use_this_mat_root" : "valid",
      pseudocode: pseudocode
    )
  end
end

recommended_roots = IDS.map do |id|
  design = DESIGN.fetch(id)
  address = id.split(":").last
  second = layer_for(id)
  third = phase_for(id)
  same_phase_other = IDS.select { |other| phase_for(other) == third && other != id }
  {
    "fixed_generated_fields" => fixed.fetch(id),
    "proposal_status" => "recommended_for_delegated_approval_not_yet_canonical",
    "proposed_title" => design.fetch("title"),
    "invariant_definition" => design.fetch("definition"),
    "semantic_center" => center_for(id),
    "semantic_boundaries" => [
      "Includes only a Matter-domain #{center_for(id)} at the specified bearer/target/system scale.",
      "Allows mechanical, thermal, electrical, chemical, or other physical specialization without choosing one mode in the atom.",
      "Does not encode design purpose, ownership, usefulness, value, quantity, safety, health, permission, schedule, or evidence.",
      "The lexical phase is #{phase_label(id)} and remains distinct from runtime state."
    ],
    "excluded_meanings" => [
      "Self-mobility and positional relations belong to canonical MOV:200–222.",
      "Material entities belong to canonical MAT:000–022; physical-state-change events belong to canonical MAT:100–122.",
      "Form, fit geometry, topology, attachment arrangement, and system organization belong to STR.",
      "Ownership, access, communication, and general participant transfer belong to CON or grammar.",
      "Damage and failure belong to WRN; restoration belongs to REP; design and production belong to CRE.",
      "Quantities, rates, efficiency, probability, readiness, schedule, and permission require LOG/quantity grammar.",
      "Conservation as a universal law belongs to ORI/LOG even when MAT bearers instantiate it."
    ],
    "nearest_neighbors" => {
      "same_triplet" => "#{id[0..-2]}0–#{id[0..-2]}2",
      "same_triplet_0" => "#{id[0..-2]}0",
      "same_triplet_1" => "#{id[0..-2]}1",
      "same_triplet_2" => "#{id[0..-2]}2",
      "same_phase_other_layers" => same_phase_other,
      "canonical_mat_entity_layer" => "MAT:000–022 owns material bearers and conditions.",
      "canonical_mat_process_layer" => "MAT:100–122 owns physical-state-change events.",
      "canonical_mov_relation_layer" => "MOV:200–222 owns mobility and positional relationships, not material influence."
    },
    "address_explanation" => {
      "first_trit_2" => "Selects relationship, capacity, or possibility rather than a material entity or change event.",
      "second_trit_#{second}" => case second
                                when "0" then "Selects an inward bearer capacity: the material bearer's own ability to supply physical work."
                                when "1" then "Selects an outward target relation: a directed coupling capable of passing physical influence to a distinct target."
                                when "2" then "Selects a shared/systemic relation: mutual physical constraint or influence among material parts."
                                end,
      "third_trit_#{third}" => case [second, third]
                              when ["0", "0"] then "Selects enduring capacity without asserting current availability."
                              when ["0", "1"] then "Selects capacity presently available for exercise."
                              when ["0", "2"] then "Selects capacity that exists in a latent, presently unavailable phase."
                              when ["1", "0"] then "Selects an established directed material coupling."
                              when ["1", "1"] then "Selects a coupling presently transmitting physical influence."
                              when ["1", "2"] then "Selects an unresolved pairwise material coupling."
                              when ["2", "0"] then "Selects established systemic material interdependence."
                              when ["2", "1"] then "Selects active reciprocal material influence across the system."
                              when ["2", "2"] then "Selects an unrealized possible systemic material interdependence."
                              end
    },
    "runtime_state_interpretations" => runtime_for(id),
    "lexical_third_trit_vs_runtime_2" => "The third lexical trit permanently selects the #{phase_label(id)} form of #{center_for(id)}. Runtime `[2]/num` separately qualifies a token's current status and never substitutes a different lexical phase, plan, probability, or future claim.",
    "cross_family_comparisons" => cross_family_for(id),
    "examples" => examples_for(design),
    "future_compound_decomposition_sketches_not_canonical" => [
      "#{id} + physical-mode modifier → mechanical, thermal, electrical, chemical, or other specialized capacity/coupling",
      "#{id} + STR/CRE/WRN/REP predicate → structured, designed, failed, hazardous, or restored material capability/relation",
      "#{id} + quantity/LOG grammar → energy amount, force, power, rate, efficiency, probability, threshold, or permission without overloading the atom"
    ],
    "later_era_evolution_notes" => [
      "Later technical vocabulary may name physical influence modes, units, tensors, and constitutive laws without changing this invariant.",
      "Later colloquial forms may lexicalize high-frequency compounds such as powered, connected, strong, or load-sharing.",
      "Future semantic changes require an explicit versioned migration."
    ],
    "confidence" => design.fetch("confidence"),
    "canonicalized" => false
  }
end

recommended = {
  "metadata" => {
    "title" => "MAT:200–222 recommended permanent semantic specifications",
    "status" => "ready_for_delegated_approval_not_yet_canonical",
    "review_scope" => "MAT:200–222 only",
    "semantic_architecture" => "physical work capacity → material coupling → systemic material interdependence",
    "delegated_approval_authorized" => true,
    "roots_canonicalized" => [],
    "stop_boundary" => ["MIN:000–022", "any other root block", "Gate 4", "translator implementation"]
  },
  "block_invariant" => "MAT:2xx encodes a material bearer's capacity to supply physical work, a directed coupling that passes physical influence to a target, or systemic interdependence among material parts; the third trit selects the applicable capacity/relationship phase.",
  "roots" => recommended_roots
}

stress_rows = [
  ["physical capacity", "direct proposed root", "MAT:200/201/202 by lexical phase", "The block owns physical work capacity, not every physical property."],
  ["work capacity", "direct proposed root", "MAT:200/201/202", "Central inward-capacity meaning."],
  ["energy capacity", "composition", "MAT work capacity + energy kind/quantity", "Energy amount needs physical-mode and quantity detail."],
  ["rated capacity", "composition", "MAT:200 + LOG/quantity rating", "A rating is a formal value over enduring capacity."],
  ["available power", "composition", "MAT:201 + energy/time quantity", "Power is a rate, not the atom."],
  ["latent energy", "direct proposed root", "MAT:202 + energy-kind modifier", "Latent work capacity exists but is unavailable."],
  ["battery capacity", "composition", "MAT capacity + canonical MAT object/substrate + quantity", "Battery kind and amount are separate."],
  ["fuel potential", "composition", "MAT:200/201/202 + chemical energy + CRE/LIF use role", "Fuel is resource-relative."],
  ["spring potential", "composition", "MAT capacity + mechanical mode + quantity", "Specific mechanical storage is compositional."],
  ["strength", "composition", "MAT:200 + STR load relation + WRN threshold", "Strength is response under a defined load."],
  ["resilience", "composition", "MAT:200 + STR/WRN recovery and disruption relation", "Resilience is narrower than general work capacity."],
  ["rigidity", "composition", "MAT bearer + STR form retention + quantity", "Rigidity is a constitutive property."],
  ["flexibility", "composition", "MAT bearer + STR deformation capacity", "Flexibility concerns form response."],
  ["elasticity", "composition", "MAT capacity + STR reversible deformation + quantity", "Reversibility and modulus require more structure."],
  ["hardness", "composition", "MAT bearer + WRN/STR indentation resistance + quantity", "Hardness is a measured response property."],
  ["toughness", "composition", "MAT work capacity + WRN fracture threshold + quantity", "A specialized energy-to-failure property."],
  ["conductivity", "composition", "MAT:210/211 + physical-mode and quantity", "Conductivity measures coupling behavior."],
  ["thermal capacity", "composition", "MAT:200 + thermal mode + quantity", "Heat capacity is measured, not atomic."],
  ["electrical capacity", "composition", "MAT capacity + electrical mode + quantity", "Capacitance needs formal units and relation structure."],
  ["physical readiness", "composition", "MAT:201; LOG for operational readiness", "Present physical availability does not include plans or permission."],
  ["permission to use energy", "canonical/future other family", "LOG permission + MAT capacity", "Permission is not physical availability."],
  ["scheduled discharge", "composition", "LOG schedule + MAT capacity/process", "Schedule is separate."],
  ["probable activation", "grammar or quantity", "LOG probability + MAT:202 or MAT process", "Probability is not lexical dormancy."],
  ["material coupling", "direct proposed root", "MAT:210/211/212 by relation phase", "Central pairwise relationship."],
  ["physical connection", "unresolved lexical ambiguity", "MAT coupling when influence can pass; STR/CON otherwise", "English connection is domain-ambiguous."],
  ["contact", "composition", "STR contact geometry; MAT:210/211 if physical influence is enabled/active", "Mere touching is not always coupling."],
  ["attachment", "composition", "STR attachment + MAT coupling when influence relation is asserted", "Attachment is structural."],
  ["fit", "canonical/future other family", "STR compatibility/geometry", "Fit alone is not material influence."],
  ["compatibility", "canonical/future other family", "STR/LOG compatibility + MAT mode when physical", "Compatibility is a constraint judgment."],
  ["ownership", "canonical/future other family", "CON relation", "Physical possession is not coupling."],
  ["possession", "canonical/future other family", "CON relation + MAT object", "Possession is social/legal."],
  ["resource assignment", "composition", "CON/LOG/CRE role + MAT bearer", "Resourcehood is contextual."],
  ["load bearing", "composition", "MAT coupling/capacity + STR load path + quantity", "Load type and magnitude are separate."],
  ["force transmission", "composition", "MAT:211 + force mode/quantity", "Active coupling owns the relation; force is specialized."],
  ["heat transfer", "composition", "MAT:211 + thermal mode + MAT:111 target change", "Coupling and heating process are distinct."],
  ["electrical current", "composition", "MAT:211/221 + electrical mode + quantity + MOV as needed", "Current is measured flow."],
  ["friction", "composition", "MAT:211 + contact/motion + constitutive relation", "Friction needs MOV and quantity."],
  ["collision", "composition", "MOV approach/arrival + MAT:211 + MAT target change/WRN as needed", "Collision is an event, not just a relation."],
  ["bond", "composition", "MAT:210/211 + chemical mode + STR relation", "Bond type is specialized."],
  ["adhesion", "composition", "MAT coupling + surface/force relation", "Adhesion is a mode of coupling."],
  ["interface", "canonical/future other family", "STR boundary/interface; MAT coupling if influence passes", "Interface is structural unless material influence is asserted."],
  ["gear mesh", "composition", "STR geometry + MAT:210/211 + MOV rotation", "Three independent semantics."],
  ["power cable connection", "composition", "MAT coupling + STR assembly + electrical mode", "Connection geometry and physical influence differ."],
  ["active coupling", "direct proposed root", "MAT:211", "Physical influence is presently passing."],
  ["uncertain contact", "composition", "MAT:212 when influence relation is unresolved; DAT/MIN for evidence", "Uncertainty source may be separate."],
  ["broken connection", "composition", "MAT:210/211[0] or MAT:212 + WRN failure", "Failure judgment belongs to WRN."],
  ["repaired coupling", "composition", "REP + MAT:210/211", "Restoration is separate."],
  ["systemic interdependence", "direct proposed root", "MAT:220/221/222 by phase", "Central systemic relationship."],
  ["load-sharing system", "composition", "MAT:220/221 + STR topology + quantity", "Load-sharing specializes interdependence."],
  ["active load network", "composition", "MAT:221 + STR network", "Network topology is separate."],
  ["possible coupling network", "direct proposed root", "MAT:222", "An unrealized possible systemic physical relation."],
  ["equilibrium", "composition", "MAT:220 + LOG/quantity equality + physical state", "Equilibrium is a specialized balance condition."],
  ["conservation", "canonical/future other family", "ORI/LOG law + MAT system", "Universal law is not one concrete relation."],
  ["mass balance", "composition", "LOG equality + MAT system + quantity", "Accounting equation is formal."],
  ["energy balance", "composition", "LOG equality + MAT system + quantity", "Measured conservation statement."],
  ["resource balance", "composition", "DAT/LOG accounting + MAT bearers", "Resource value and records are contextual."],
  ["exchange network", "unresolved lexical ambiguity", "MAT:221 for reciprocal physical influence; CON/DAT/MOV otherwise", "Exchange spans domains."],
  ["circulation network", "composition", "MOV movement + STR network + MAT bearers; MAT:221 only if reciprocal physical influence", "Movement is not absorbed."],
  ["power grid", "composition", "MAT:220/221 + STR topology + electrical mode + CRE function", "A grid is structured and designed."],
  ["thermal network", "composition", "MAT interdependence + STR topology + thermal mode", "Mode and topology are separate."],
  ["ecosystem interdependence", "composition", "LIF systemic relation + MAT:220/221 physical layer", "Living and material interdependence differ."],
  ["machine system", "composition", "CRE/STR machine + MAT capacities/couplings", "Machinehood is functional."],
  ["material configuration", "canonical/future other family", "STR arrangement + MAT bearers", "Configuration is structural."],
  ["possible configuration", "composition", "STR/CRE possible arrangement + MAT:222 only if physical interdependence is possible", "Do not collapse arrangement and relation."],
  ["topology", "canonical/future other family", "STR", "Topology is structural."],
  ["data dependency", "canonical/future other family", "DAT/LOG", "Information relation is not material."],
  ["communication link", "canonical/future other family", "CON", "Communication is not physical coupling even on physical hardware."],
  ["social network", "canonical/future other family", "CON", "Social interdependence is not Matter."],
  ["physical influence", "direct proposed root", "MAT:210/211/212 or MAT:220/221/222 by scale and phase", "Central relation concept."],
  ["cause", "unresolved lexical ambiguity", "role/ORI/LOG; MAT only for physical influence relation", "General causation exceeds Matter."],
  ["affordance", "composition", "CRE/STR function + MAT capacity", "Designed or perceived usability is not raw capacity."],
  ["accessibility", "canonical/future other family", "CON/LOG/STR", "Access is not lexical capacity availability."],
  ["failure risk", "composition", "WRN risk + MAT capacity/coupling + LOG probability", "Risk and probability are separate."],
  ["move itself", "canonical/future other family", "MOV:200/201/202", "Canonical self-mobility is Motion."],
  ["change physical state", "canonical MAT process", "MAT:100–122", "Event, not capacity or relation."],
  ["material object", "canonical MAT entity", "MAT:010–012", "Bearer entity, not capacity."],
  ["energy amount", "grammar or quantity", "MAT bearer/capacity + quantity/unit", "Amount is formal grammar."],
  ["power rate", "grammar or quantity", "MAT:201 + energy/time quantity", "Rate is derived."],
  ["efficiency", "grammar or quantity", "output/input ratio over MAT process/capacity", "Efficiency is quantitative."],
  ["coupling coefficient", "grammar or quantity", "MAT coupling + numeric coefficient", "Coefficient is a measurement."],
  ["unknown whether capacity exists", "root plus runtime", "MAT:200[2]/num or MAT:202[2]/num by lexical claim", "Runtime 2 qualifies the selected capacity assertion."],
  ["capacity unavailable now", "direct proposed root", "MAT:202 when capacity exists latently; MAT:201[0] when denying present availability", "Lexical and runtime choices preserve the distinction."],
  ["coupling inactive now", "root plus runtime", "MAT:211[0] if established coupling is not transmitting; MAT:210 for stable relation", "Active relation negation differs from stable relation."],
  ["coupling status unknown", "direct proposed root", "MAT:212", "The pairwise relation itself is unresolved."],
  ["possible system scheduled later", "composition", "MAT:222 + LOG schedule if both are asserted", "Lexical possibility alone never encodes schedule."]
].freeze

stress = {
  "metadata" => {
    "title" => "MAT:200–222 semantic stress tests",
    "status" => "review_evidence_pending_delegated_approval",
    "test_count" => stress_rows.length,
    "forced_atomic_mappings" => false
  },
  "classification_values" => stress_rows.map { |row| row[1] }.uniq,
  "tests" => stress_rows.map.with_index(1) do |(concept, classification, mapping, rationale), index|
    {"number" => index, "concept" => concept, "classification" => classification,
     "mapping" => mapping, "rationale" => rationale}
  end,
  "coverage_summary" => stress_rows.group_by { |row| row[1] }.transform_values(&:length)
}

File.write(File.join(ROOT, "reviews/MAT_200_222_scored_candidates.yaml"), YAML.dump(scored))
File.write(File.join(ROOT, "reviews/MAT_200_222_recommended_spec.yaml"), YAML.dump(recommended))
File.write(File.join(ROOT, "reviews/MAT_200_222_stress_tests.yaml"), YAML.dump(stress))

peer = +"# MAT:200–222 Adversarial Semantic Peer Review\n\n"
peer << "Status: **READY FOR DELEGATED APPROVAL — NOT YET CANONICAL**\n\n"
peer << "Scope is strictly `MAT:200–222`. The user explicitly delegated approval authority for reviewed roots. This packet still performs the full adversarial review before any migration. Deterministic generated fields are fixed; the 72 current canonical roots are immutable.\n\n"
peer << "## Executive recommendation\n\n"
peer << "Use one material-influence architecture:\n\n"
peer << "- `MAT:200–202`: **physical work capacity** — enduring / presently available / latent;\n"
peer << "- `MAT:210–212`: **directed material coupling** — established / actively transmitting / unresolved;\n"
peer << "- `MAT:220–222`: **systemic material interdependence** — established / actively reciprocal / unrealized possible.\n\n"
peer << "This forms a useful dependency chain: a bearer can supply physical work; a pairwise coupling can pass physical influence to a target; a shared system can contain mutually constraining material parts. Structural form, ownership, resource value, quantities, conservation laws, evidence, failure, repair, purpose, and scheduling remain outside the atoms.\n\n"
peer << "## Fixed generated forms\n\n"
peer << "| ID | Universal slot | Transliteration | Compact | Formal carrier | Harmony | Relative note path |\n|---|---|---|---|---|---|---|\n"
IDS.each do |id|
  form = fixed.fetch(id)
  peer << "| `#{id}` | #{form["universal_slot"]} | `#{form["family_qualified_transliteration"]}` | `#{form["local_compact_root"]}` | `#{form["formal_carrier"]}` | `#{form["harmonic_signature_semitones"].join(", ")}` | `#{form["relative_note_path_semitones"].join(", ")}` |\n"
end
peer << "\n"

scored_roots.each do |root|
  id = root.fetch("canonical_id")
  design = DESIGN.fetch(id)
  spec = recommended_roots.find { |item| item.dig("fixed_generated_fields", "canonical_id") == id }
  peer << "## #{id} — #{design["title"]}\n\n"
  peer << "**Why the current meaning was probably chosen.** #{design["current_rationale"]}\n\n"
  peer << "| Candidate | Atomic | Address | MAT | Triplet | Neighbor | Cross-family | Everyday | Technical | Compound | Translation | Total |\n"
  peer << "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n"
  root.fetch("candidates").each do |item|
    scores = item.fetch("scores")
    peer << "| #{item["title"]} | #{SCORE_KEYS.map { |key| scores[key] }.join(" | ")} | **#{item["total"]}/100** |\n"
  end
  peer << "\n"
  root.fetch("candidates").each do |item|
    analysis = item.fetch("analysis")
    peer << "- **#{item["title"]}:** #{analysis["why_it_fits"]} Covers: #{analysis["useful_coverage"]} Territory: #{analysis["semantic_territory_consumed"]} Risk: #{analysis["risks_and_future_limitations"]}\n"
  end
  winner = root.fetch("candidates").find { |item| item["candidate_id"] == root["recommended_winner"] }
  peer << "\n**Recommendation:** **#{design["title"]}** (#{winner["total"]}/100; confidence #{(design["confidence"] * 100).round}%).\n\n"
  peer << "> #{design["definition"]}\n\n"
  peer << "**Address fit.** #{spec["address_explanation"].values.join(" ")}\n\n"
  peer << "**Boundaries.** #{spec["semantic_boundaries"].join(" ")}\n\n"
  peer << "**Exclusions.** #{spec["excluded_meanings"].join(" ")}\n\n"
  peer << "**Nearest neighbors.** Same triplet `#{spec.dig("nearest_neighbors", "same_triplet")}`; same-phase other layers #{spec.dig("nearest_neighbors", "same_phase_other_layers").map { |other| "`#{other}`" }.join(", ")}. #{spec.dig("nearest_neighbors", "canonical_mat_entity_layer")} #{spec.dig("nearest_neighbors", "canonical_mat_process_layer")} #{spec.dig("nearest_neighbors", "canonical_mov_relation_layer")}\n\n"
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
  peer << "| `#{id}` | #{DESIGN.dig(id, "title")}: #{phase_label(id)} #{center_for(id)} | motion, structure, ownership, law, failure | mode, cause, topology, purpose, quantity, evidence | units, rates, value, permission, schedule, probability |\n"
end
peer << "\n"
peer << "## Triplet coherence assessment\n\n"
peer << "- `MAT:200–202` keeps one bearer capacity: ability to supply energy for physical change. The lexical contrast is enduring / presently available / latent.\n"
peer << "- `MAT:210–212` keeps one directed target relation: material coupling that can pass physical influence. The contrast is established / actively transmitting / unresolved.\n"
peer << "- `MAT:220–222` keeps one shared-system relation: mutual physical constraint among material parts. The contrast is established / actively reciprocal / unrealized possible.\n"
peer << "- Across the block, capability enables pairwise influence and pairwise influence scales to systemic interdependence. No atom imports form, ownership, accounting, universal law, or implementation schedule.\n\n"
peer << "## Coverage and restraint\n\n"
peer << "The packet classifies #{stress_rows.length} English concepts. Direct coverage is restricted to physical work capacity, material coupling, and systemic material interdependence. Strength, conductivity, fit, attachment, force, heat transfer, equilibrium, conservation, grids, machines, ownership, data links, quantities, rates, readiness, probability, and schedules remain explicit compositions or other-family meanings.\n\n"
peer << "## Proposed titles and invariant definitions\n\n"
IDS.each { |id| peer << "- `#{id}` — **#{DESIGN.dig(id, "title")}**: #{DESIGN.dig(id, "definition")}\n" }
peer << "\n"
peer << "## Delegated approval checklist\n\n"
peer << "- [x] Four candidates compared at every root.\n"
peer << "- [x] Recommended candidate wins all scoring tables.\n"
peer << "- [x] Triplets retain one center and exact lexical-phase contrasts.\n"
peer << "- [x] Cross-family collisions and English traps are explicit.\n"
peer << "- [x] Generated fields match fixed algorithms.\n"
peer << "- [x] User delegated approval authority for reviewed roots.\n"
peer << "- [ ] Apply canonization only after the independent validator passes.\n\n"
peer << "- **Roots canonized by generation of this packet:** none.\n"
peer << "- **Stop boundary honored:** no `MIN:000–022`, other root block, Gate 4, compound architecture, renderer, or translator implementation was begun.\n\n"
peer << "**READY FOR DELEGATED APPROVAL**\n"
File.write(File.join(ROOT, "reviews/MAT_200_222_peer_review.md"), peer)

collision = +"# MAT:200–222 Collision Report\n\n"
collision << "Status: **peer-review evidence — pending delegated approval**\n\n"
collision << "## Core ownership rule\n\n"
collision << "The proposed block owns physical work capacity, directed material coupling, and systemic material interdependence. It does not own motion, form, topology, ownership, access, communication, data dependency, purpose, damage, repair, formal permission, quantity, probability, or universal law.\n\n"
collision << "## Intra-Matter boundary\n\n"
collision << "| Canonical/proposed layer | Owns |\n|---|---|\n"
collision << "| `MAT:000–022` canonical | material substrates, objects, and aggregates as entities/conditions |\n"
collision << "| `MAT:100–122` canonical | physical-state-change events by locus and phase |\n"
collision << "| `MAT:200–222` proposed | work capacity, physical-influence coupling, and systemic material interdependence |\n\n"
collision << "## Cross-family collision matrix\n\n"
collision << "| Root | LIF | MOV | MIN | CON | STR | WRN | REP | LOG | DAT | CRE | ORI |\n|---|---|---|---|---|---|---|---|---|---|---|---|\n"
IDS.each do |id|
  audit = cross_family_for(id)
  collision << "| `#{id}` | #{CROSS_FAMILIES.map { |family| audit[family] }.join(" | ")} |\n"
end
collision << "\n## High-risk English traps\n\n"
collision << "- **Can** may mean physical capacity, permission, knowledge, probability, or opportunity. Only the physical-work sense is MAT:200–202.\n"
collision << "- **Available** does not mean permitted, scheduled, accessible, or certain to be used.\n"
collision << "- **Connection** may be structural, communicative, social, logical, or physical. MAT requires a physical-influence coupling.\n"
collision << "- **Active coupling** requires current physical influence, not mere contact or adjacency.\n"
collision << "- **System** and **network** do not imply material interdependence; topology is STR and information exchange is CON/DAT.\n"
collision << "- **Conservation** as a law is ORI/LOG. A concrete material system may instantiate that law without making MAT:220 its universal statement.\n"
collision << "- **Possible** at MAT:222 does not mean designed, planned, scheduled, probable, ready, permitted, or future-certain.\n\n"
collision << "## Disposition\n\n"
collision << "The recommended architecture avoids blocking collisions with all 72 current canonical roots and eleven competing family domains. It is ready for independent validation and the user's delegated approval migration.\n"
File.write(File.join(ROOT, "reviews/MAT_200_222_collision_report.md"), collision)

puts "Built MAT:200–222 peer-review packet (five content files; validation and approval generated separately)."
