#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "yaml"

ROOT = File.expand_path("..", __dir__)

FAMILIES = {
  "LIF" => { "onset" => "ni", "harmony" => [0, 4, 7], "domain" => "life, identity, consciousness, and growth" },
  "MOV" => { "onset" => "gi", "harmony" => [0, 2, 7], "domain" => "motion, position, transition, and time" },
  "MAT" => { "onset" => "ba", "harmony" => [0, 7, 12], "domain" => "matter, body, energy, and resources" },
  "MIN" => { "onset" => "si", "harmony" => [0, 3, 7], "domain" => "mind, memory, perception, and learning" },
  "CON" => { "onset" => "wu", "harmony" => [0, 4, 7, 9], "domain" => "connection, communication, and sharing" },
  "STR" => { "onset" => "do", "harmony" => [0, 5, 7], "domain" => "structure, order, shelter, and systems" },
  "WRN" => { "onset" => "da", "harmony" => [0, 3, 6], "domain" => "danger, error, failure, and corruption" },
  "REP" => { "onset" => "ya", "harmony" => [0, 3, 7, 9], "domain" => "repair, healing, and restoration" },
  "LOG" => { "onset" => "te", "harmony" => [0, 4, 8], "domain" => "logic, mathematics, rules, and programming" },
  "DAT" => { "onset" => "li", "harmony" => [0, 4, 7, 11], "domain" => "information, records, and signals" },
  "CRE" => { "onset" => "ga", "harmony" => [0, 3, 7, 11], "domain" => "creation, design, and transformation" },
  "ORI" => { "onset" => "nu", "harmony" => [0, 1, 7], "domain" => "origin, reality, and universal law" }
}.freeze

UNIVERSAL_SLOTS = {
  "000" => "stable inward entity",
  "001" => "active inward entity",
  "002" => "dormant inward entity",
  "010" => "stable outward entity",
  "011" => "active outward entity",
  "012" => "dormant outward entity",
  "020" => "stable collective entity",
  "021" => "active collective entity",
  "022" => "dormant collective entity",
  "100" => "completed inward process",
  "101" => "active inward process",
  "102" => "pending inward process",
  "110" => "completed outward process",
  "111" => "active outward process",
  "112" => "pending outward process",
  "120" => "completed systemic process",
  "121" => "active systemic process",
  "122" => "pending systemic process",
  "200" => "stable inward capacity",
  "201" => "active inward capacity",
  "202" => "dormant inward capacity",
  "210" => "stable outward relationship",
  "211" => "active outward relationship",
  "212" => "unresolved outward relationship",
  "220" => "stable systemic relationship",
  "221" => "active systemic relationship",
  "222" => "unrealized systemic possibility"
}.freeze

# One row per nine-root semantic chunk. Each of the three variants is:
# title :: core definition. These are proposals, not source-extracted claims.
SEMANTIC_ROWS = <<~'ROWS'
MOV	10	departure complete :: Movement away from the source has finished and the mover is no longer occupying its starting position.	self-departure :: An entity is actively leaving its own source or current position.	departure readiness :: An entity is prepared to leave its source, but outward motion has not yet begun.
MOV	11	arrival complete :: Movement to the selected destination has finished and the mover has entered or reached it.	destination approach :: An entity is actively moving toward a selected destination.	pending arrival :: Movement toward a destination is intended or queued, but arrival is not yet in progress.
MOV	12	system transition complete :: A route-wide transfer, circulation step, or temporal transition has reached its defined end state.	system flow :: Entities, signals, or time-indexed states are actively moving through a shared route system.	pending system transition :: A route-wide transfer or temporal transition is staged but has not started.
MOV	20	stable mobility :: An entity has a dependable capacity to change its own position.	expressed mobility :: An entity's capacity for movement is currently available and being exercised.	latent mobility :: An entity could move under suitable conditions, but that capacity is not presently available or expressed.
MOV	21	fixed trajectory relation :: A mover has an established directional or sequential relation to a target.	active pursuit relation :: A mover is actively following, approaching, escorting, or tracking a target.	unresolved route relation :: A possible path between mover and target exists, but its direction, reachability, or completion is not resolved.
MOV	22	stable cycle relation :: A transport, orbital, or temporal system has an established recurring order.	synchronized flow relation :: Multiple movers or transitions are actively coordinated within one route, cadence, or schedule.	possible path branch :: A valid system-level route or future sequence could exist, but no branch has yet been selected or realized.
MAT	00	material integrity :: An entity's own body or material core is bounded, persistent, and structurally intact.	energized body :: An entity's matter or bodily substrate is presently energized, changing, or physically active.	material reserve :: Matter or bodily substance is retained inwardly in an inactive, unformed, or unavailable state.
MAT	01	bounded object :: A discrete external object is materially stable and can be treated as one physical target.	active implement :: An external material object is presently exerting force, consuming energy, or performing physical work.	latent material target :: A material object or resource is identified but remains inaccessible, unformed, or physically inactive.
MAT	02	material system :: A shared arrangement of matter, bodies, energy, or resources is stable as a bounded physical system.	resource circulation :: Matter, energy, or resources are actively circulating through an environment or distributed system.	dormant stock :: A collective supply of material or energy exists in reserve but is not currently circulating or being used.
MAT	10	consolidation complete :: An inward material change has finished, leaving the entity in a stable physical state.	self-reconfiguration :: An entity is actively changing, assembling, consuming, or redistributing its own material substance.	queued reconfiguration :: An inward physical transformation is possible or prepared but has not begun.
MAT	11	fabrication complete :: A physical change applied to an external target has finished and produced a bounded material result.	force transfer :: Matter or energy is actively being applied, moved, consumed, or transferred to an external target.	staged material operation :: A physical operation on a target is prepared but not yet under way.
MAT	12	closed material cycle :: A system-wide material, energy, or resource process has completed its defined cycle.	systemic resource flow :: Matter, energy, or resources are actively transformed or exchanged across a shared system.	pending material cycle :: A system-level physical or resource transformation is staged but has not begun.
MAT	20	structural integrity capacity :: An entity has a stable inward capacity to bear load, retain form, or resist material disruption.	exertive capacity :: An entity is actively able to exert force, release energy, or perform physical work.	stored energy potential :: An entity contains material or energy potential that is not presently accessible or expressed.
MAT	21	material attachment :: An object has a stable physical connection, fit, ownership, or resource relation to a target.	active physical coupling :: Two material entities are actively touching, exchanging force, or transferring energy.	possible material fit :: A physical attachment, transfer, or resource relation may be viable but remains unconfirmed.
MAT	22	conservation balance :: A material system has a stable relationship among its matter, energy, inputs, and outputs.	exchange network :: A distributed system is actively exchanging matter, energy, or resources among its parts.	unrealized material configuration :: A physically valid arrangement or resource state could exist at system scale but has not been produced.
MIN	00	stable inner model :: A persistent internal memory, concept, or self-model is available as a bounded mental object.	present attention :: Awareness is actively focused within the mind on a current thought, sensation, or internal state.	latent memory :: A memory or mental representation is preserved but not presently recalled or consciously accessible.
MIN	01	known target model :: A stable mental representation identifies a specific external object, event, or other mind.	active perception :: An external target is presently being sensed, recognized, or mentally represented.	unrecognized impression :: Information about a target has entered the mind but remains indistinct, inaccessible, or not yet recognized.
MIN	02	shared knowledge model :: A group or system holds a stable common schema, convention, or body of understanding.	collective attention :: Multiple minds are actively attending to, interpreting, or learning the same shared subject.	dormant knowledge tradition :: A shared body of knowledge remains preserved in potential but is not currently understood or practiced.
MIN	10	understanding achieved :: An inward cognitive process has completed and produced a stable memory, insight, or decision.	active reflection :: A mind is actively remembering, imagining, evaluating, or reorganizing its own representations.	pending reflection :: An inward act of recall, learning, or decision is intended but has not begun or reached awareness.
MIN	11	target assessment complete :: Observation or reasoning about an external target has reached a settled interpretation or decision.	active inquiry :: A mind is actively observing, questioning, learning about, or deciding with respect to a target.	planned inquiry :: Investigation or learning about a target is possible or scheduled but not yet active.
MIN	12	collective learning complete :: A shared inquiry or group-learning process has reached a stable common result.	distributed reasoning :: Multiple minds are actively combining perceptions, memories, or judgments within a shared cognitive process.	pending collective inquiry :: A group-level learning or reasoning process is prepared but has not started.
MIN	20	stable competence :: A mind has a dependable inward capacity to understand, remember, learn, or decide.	expressed focus :: Mental capacity is actively available as concentration, recall, imagination, or problem solving.	latent aptitude :: A capacity to learn or understand exists but is undeveloped, inaccessible, or not presently expressed.
MIN	21	settled belief relation :: A mind has a stable interpretive, recognition, or belief relation toward a particular target.	active attention relation :: A mind is actively attending to, interpreting, trusting, doubting, or evaluating a target.	uncertain interpretation :: A possible belief or understanding about a target exists but remains unresolved.
MIN	22	coherent worldview :: A system of concepts and beliefs has stable internal and shared relationships.	distributed intelligence :: Multiple minds or cognitive agents are actively coordinating into a larger reasoning system.	hypothesis space :: A set of system-level explanations or understandings could be valid, but none is yet realized or selected.
CON	00	stable self-link :: An entity has a persistent internal communication link among its own parts, voices, or interfaces.	receptive presence :: An entity is actively listening, receiving, or holding an internal channel open.	disconnected interface :: An internal connection point exists but is inactive, unavailable, or not yet linked.
CON	01	identified counterpart :: A specific external participant or endpoint is stably recognized as a communication target.	active correspondent :: An external participant is presently connected, responsive, or exchanging communication.	unavailable counterpart :: A known participant or endpoint exists but is offline, unreachable, or not yet engaged.
CON	02	established network :: A shared communication network, language community, or channel system is stable and bounded.	live network :: A shared network is actively carrying messages, signals, attention, or social exchange.	dormant network :: A communication system or community remains defined but is not currently connected or exchanging.
CON	10	self-synchronization complete :: An entity's internal participants or interfaces have completed a connection or synchronization process.	opening a channel :: An entity is actively connecting, listening, or synchronizing its own communication interfaces.	queued self-connection :: An inward connection or synchronization is possible or prepared but has not begun.
CON	11	delivery complete :: A communicative act to a selected target has reached that target and completed its transfer.	transmission :: A message, signal, request, or expression is actively being sent to an external target.	queued contact :: A communication toward a target is composed, intended, or waiting for an available channel.
CON	12	network synchronization complete :: A shared communication system has completed a broadcast, negotiation, or synchronization cycle.	broadcast exchange :: Messages or signals are actively being shared, routed, or negotiated across a network.	pending broadcast :: A system-wide communication or synchronization process is staged but has not started.
CON	20	stable connectivity :: An entity has a dependable inward capacity to establish and maintain communication links.	active receptivity :: An entity's capacity to receive, respond, translate, or relay communication is presently available.	dormant interface capacity :: An interface or communicative ability exists but is disabled, inaccessible, or not yet developed.
CON	21	established bond :: Two participants have a stable communication, social, or signaling relationship.	active dialogue :: Participants are actively exchanging messages, meanings, or mutual responses.	unconfirmed contact :: A possible bond or channel to another participant exists but identity, reachability, or reciprocity is unresolved.
CON	22	interoperable network :: A communication system has stable compatibility and routing relationships among its parts.	active mesh :: Many participants are actively maintaining a distributed web of exchange.	possible communication network :: A valid shared channel system or community could form but has not yet been realized.
STR	00	internal framework :: An entity has a stable inward organization of components, boundaries, and supporting relations.	operating mechanism :: An entity's internal structure is actively bearing load, regulating behavior, or coordinating parts.	latent component :: An inward structural element or arrangement exists in reserve but is inactive, folded, or not yet installed.
STR	01	bounded structure :: A stable external construction, container, shelter, or organized unit is treated as one target.	functioning structure :: An external structure is presently occupied, operating, or actively supporting a purpose.	reserved structure :: A defined external structure is unoccupied, unfinished, folded, or not presently in service.
STR	02	organized system :: A shared architecture, institution, settlement, or infrastructure has stable boundaries and roles.	operating system structure :: A distributed organization or infrastructure is actively coordinating its components.	dormant institution :: A system's roles and architecture remain defined but the organization is not currently operating.
STR	10	self-organization complete :: An inward arrangement, reinforcement, or reorganization has reached a stable finished form.	self-organization :: An entity is actively arranging, stabilizing, or restructuring its own components.	queued reorganization :: An inward structural change is planned or possible but has not begun.
STR	11	construction complete :: The assembly, enclosure, or organization of an external target has reached its intended form.	construction :: Components are actively being assembled, enclosed, ordered, or installed into an external target.	planned construction :: Work on a structure or organized target is designed or staged but not yet active.
STR	12	system deployment complete :: A shared architecture or organization has completed a defined build, rollout, or reorganization.	system organization :: Components, roles, or boundaries are actively being coordinated across a larger system.	staged system deployment :: A system-wide build or organizational change is prepared but has not begun.
STR	20	stable load capacity :: An entity can dependably retain form, bear load, contain contents, or preserve internal order.	active adaptability :: A structure's capacity to flex, reconfigure, or redistribute support is presently available.	unused structural capacity :: Space, load tolerance, or organizing potential exists but is not presently available or occupied.
STR	21	support relation :: A structure has a stable containment, anchoring, dependency, or support relation to a target.	active structural support :: A structure is actively holding, sheltering, constraining, or organizing a target.	possible structural fit :: A support, containment, or dependency relation may work but remains untested or unresolved.
STR	22	stable governance :: A system has established relationships of role, boundary, authority, and structural dependency.	active coordination :: A distributed structure is actively reallocating roles, support, or organization among its parts.	possible architecture :: A coherent system arrangement could exist but has not yet been instantiated.
WRN	00	contained defect :: An inward error, weakness, or corruption is identified and bounded within an entity.	active internal fault :: An error or harmful condition is presently disrupting an entity from within.	latent defect :: An inward flaw or corruption may exist but is hidden, inactive, or not yet detectable.
WRN	01	known hazard :: A stable external source of danger, damage, error, or invalid behavior is identified.	active threat :: An external hazard is presently approaching, attacking, failing, or causing harm.	suspected hazard :: A possible external danger has been indicated but is inactive, inaccessible, or not yet confirmed.
WRN	02	contained incident field :: A system-level hazard or failure condition is known, bounded, and no longer spreading.	spreading corruption :: Error, damage, danger, or hostile behavior is actively propagating through a shared system.	latent systemic risk :: A distributed failure or hazard could emerge, but it is currently hidden or unrealized.
WRN	10	diagnosis complete :: An inward process of detecting, classifying, or tracing an entity's fault has reached a stable result.	self-monitoring :: An entity is actively checking itself for danger, error, damage, or corruption.	pending inspection :: An inward diagnostic process is required or scheduled but has not begun.
WRN	11	containment complete :: A warning, block, isolation, or shutdown applied to a target has finished and bounded the hazard.	warn or isolate :: A dangerous target is actively being signaled, blocked, quarantined, or shut down.	pending containment :: A warning or isolation action toward a target is prepared but not yet executing.
WRN	12	incident closure :: A coordinated system-level detection and containment process has reached a stable end state.	emergency response :: A network or community is actively detecting, warning about, isolating, or responding to a distributed incident.	staged contingency :: A system-level warning or emergency response is prepared but has not been activated.
WRN	20	stable vulnerability :: An entity has a known, persistent inward susceptibility to error, attack, damage, or failure.	active susceptibility :: A vulnerability is presently exposed or capable of being exploited.	hidden vulnerability :: A weakness could exist within an entity but is dormant, inaccessible, or not yet discovered.
WRN	21	known exposure relation :: A stable relation connects a hazard to a target it can affect.	active attack relation :: A hazard is actively exploiting, damaging, misleading, or corrupting a target.	uncertain threat relation :: A possible harmful relation between source and target exists but cause, reach, or severity is unresolved.
WRN	22	stable risk structure :: A system has known dependencies through which danger or failure could propagate.	cascading risk :: Vulnerabilities or failures are actively interacting across a system and increasing shared danger.	catastrophe possibility :: A coherent system-level failure or corruption state could occur but has not been realized.
REP	00	restored integrity :: An entity's inward health, function, or correctness has been returned to a stable condition.	active recovery state :: An entity is presently healing, recalibrating, or returning its own function toward integrity.	recoverable damage :: An entity remains damaged or incomplete but preserves an inward basis for future recovery.
REP	01	repaired target :: An external target is in a stable restored, healed, or corrected condition.	target under care :: An external target is presently being supported, healed, corrected, or maintained.	queued repair target :: A damaged target is identified and recoverable but repair is not yet under way.
REP	02	restored system :: A community, network, habitat, or infrastructure has regained stable shared function.	system recovery state :: A distributed system is actively healing, restoring service, or coordinating maintenance.	preserved restore point :: A backup, seed, reserve, or prior system state is retained for future restoration but is not currently deployed.
REP	10	self-repair complete :: An entity has completed an inward process of healing, correction, recalibration, or restoration.	self-repair :: An entity is actively healing, correcting, or rebuilding its own function.	queued self-repair :: An inward recovery process is possible or scheduled but has not begun.
REP	11	target repair complete :: Repair, healing, correction, or restoration applied to an external target has finished.	repair target :: A target is actively being healed, corrected, restored, or recalibrated.	scheduled target repair :: A repair operation for a target is prepared but not yet executing.
REP	12	system recovery complete :: A coordinated recovery or maintenance cycle has restored stable function across a system.	coordinated restoration :: Participants are actively repairing, healing, restoring, or maintaining a shared system.	staged system recovery :: A system-level restoration plan and resources are prepared but have not been activated.
REP	20	stable resilience :: An entity has a dependable inward capacity to withstand damage and return to valid function.	active regeneration :: An entity's capacity to heal, adapt, restore, or correct itself is presently available.	reserve recoverability :: Recovery remains possible through dormant backups, reserves, or undeveloped regenerative capacity.
REP	21	maintenance bond :: A stable relation establishes responsibility, compatibility, or access for repairing a target.	active care relation :: One participant is actively sustaining, healing, correcting, or restoring another target.	unconfirmed repairability :: A target may be repairable or compatible with a remedy, but the relation is not yet verified.
REP	22	stable redundancy :: A system has established backup, substitution, and recovery relationships that preserve function.	adaptive recovery network :: A distributed system is actively reallocating support and repair capacity around damage.	possible recovery path :: A system-level route back to valid function could exist but has not yet been demonstrated.
LOG	00	axiom :: A stable inward rule, invariant, identity, or truth is accepted as a bounded logical object.	current proposition :: A proposition, value, or logical state is presently expressed for evaluation.	undefined variable :: A logical object or value slot exists but remains unbound, unknown, or unresolved.
LOG	01	fixed operand :: A specific external value, expression, rule, or argument is selected as a stable target.	evaluated value :: An external expression or operand is presently resolved and available to an operation.	unresolved operand :: A required value or expression is identified but unavailable, undefined, or not yet computed.
LOG	02	formal system :: A stable collection of rules, types, operators, or proofs defines a shared logical domain.	executing rule system :: A program, proof system, or rule set is presently evaluating or transforming states.	dormant procedure :: A valid algorithm, rule set, or proof structure exists but is not currently invoked.
LOG	10	proof complete :: An inward evaluation, calculation, or inference has completed with a stable result.	computation :: A logical agent is actively calculating, evaluating, inferring, or checking its own state.	deferred computation :: An inward evaluation is specified or possible but has not started or lacks a needed value.
LOG	11	comparison resolved :: A test, operator, or comparison applied to a target has produced a stable result.	apply operator :: A target is actively being compared, tested, classified, or transformed by a rule.	pending test :: A test or operation on a target is specified but not yet evaluated.
LOG	12	execution complete :: A program, proof, iteration, or multi-step rule process has reached its defined end state.	system execution :: Rules, branches, or iterations are actively executing across a formal system.	scheduled execution :: A program or system-level evaluation is ready or waiting but has not begun.
LOG	20	stable decidability :: An inward question has a dependable capacity to be resolved under the available rules.	active computability :: A calculation or inference is currently possible with available rules and resources.	latent rule applicability :: A rule or solution capacity exists but required conditions, bindings, or resources are absent.
LOG	21	implication relation :: A stable formal relationship connects a premise, input, or condition to a conclusion or target.	active entailment :: A target is actively being derived, constrained, or validated by a premise or rule.	conditional dependency :: A possible implication or constraint relation exists but its conditions or truth remain unresolved.
LOG	22	consistent rule space :: A formal system has stable relationships that preserve validity across its rules and values.	active recursive system :: Logical processes are actively composing, iterating, or operating in parallel within one rule space.	formal possibility space :: A consistent program, proof, or solution could exist within the rules but has not been constructed.
DAT	00	local record :: A stable inward record, symbol, identifier, or datum is stored as one bounded information object.	current input :: A signal or datum is presently entering, updating, or occupying an entity's local information state.	dormant record :: Information is preserved inwardly but is archived, inaccessible, unread, or not currently loaded.
DAT	01	addressed message :: A stable external message, reference, packet, or record is identified as a target.	live signal :: An external signal or message is presently arriving, changing, or available for reception.	queued message :: A message or data object is defined for a target but has not been delivered or made accessible.
DAT	02	dataset :: A stable shared collection of records, symbols, mappings, or messages forms one information system.	data stream :: Information is actively flowing, updating, or being replicated across a shared system.	archive :: A collective body of information is preserved but is not presently indexed, loaded, or in active use.
DAT	10	local encoding complete :: An inward process of reading, decoding, recording, or reformatting data has reached a stable result.	read or decode :: An entity is actively inspecting, parsing, decoding, or updating its local information.	pending read :: An inward data operation is requested or possible but has not begun or is waiting for access.
DAT	11	data transfer complete :: Writing, copying, retrieving, or transmitting information to a target has finished successfully.	write or transmit :: Information is actively being written, copied, sent, retrieved, or assigned to a target.	queued output :: A data transfer or write to a target is prepared but not yet executing.
DAT	12	synchronization complete :: A shared data indexing, aggregation, replication, or synchronization cycle has reached a stable result.	system data processing :: Information is actively being aggregated, indexed, synchronized, or replicated across a system.	pending synchronization :: A system-wide data operation is scheduled or waiting for prerequisites.
DAT	20	stable access capacity :: An entity has dependable permission and means to read, retain, or use its own information.	active retrievability :: Information is currently readable, writable, searchable, or recoverable by the entity.	locked data potential :: Information exists and may be recoverable, but access, decoding, or retrieval is presently unavailable.
DAT	21	stable reference :: An information object has an established addressing, citation, lookup, or identity relation to a target.	active dereference :: A reference is presently resolving, retrieving, validating, or linking its target.	unresolved reference :: A possible link to a target exists but is broken, ambiguous, missing, or not yet verified.
DAT	22	stable information integrity :: A data system has established fidelity, provenance, consistency, and replication relationships.	active provenance network :: Records are actively being traced, checked, reconciled, or replicated across a distributed system.	recoverable information possibility :: A coherent system-level record could be reconstructed or discovered, but it is not yet available.
CRE	00	internal design :: A stable inward concept, plan, style, or imagined form is held as one bounded creative object.	active inspiration :: A concept or form is presently emerging, changing, or demanding creative attention.	unrealized idea :: A design or imagined form is preserved inwardly but has not yet been developed or expressed.
CRE	01	finished artifact :: A created external object, work, design, or transformation result is stable and bounded.	evolving prototype :: An external created form is presently being tested, revised, or expressed.	unbuilt design :: A defined artifact or transformation target remains conceptual, unavailable, or not yet instantiated.
CRE	02	design system :: A stable shared language of forms, templates, styles, or generative constraints defines a creative domain.	generative environment :: A shared creative system is actively producing, combining, or transforming forms.	dormant template library :: A collective set of designs or generative patterns exists but is not presently in use.
CRE	10	conception complete :: An inward process of imagining, designing, or composing has reached a stable concept.	ideation :: A creator is actively imagining, composing, planning, or transforming an inward concept.	incubating concept :: An inward creative process is possible or developing but has not entered active formation.
CRE	11	instantiation complete :: Creating, assembling, rendering, or transforming an external target has produced a finished result.	create artifact :: A target is actively being designed, generated, assembled, rendered, or transformed.	queued fabrication :: Creation or transformation of a target is specified and possible but has not begun.
CRE	12	system generation complete :: A shared world, design system, production, or generative process has reached its defined result.	collective generation :: Participants or generative components are actively co-creating, composing, or transforming a system.	staged instantiation :: A system-level creative process is prepared but has not been activated.
CRE	20	stable creative agency :: An entity has a dependable inward capacity to imagine, design, generate, or transform forms.	expressed creativity :: Creative capacity is presently available and producing or revising forms.	untapped creativity :: A capacity for creation exists but is undeveloped, inaccessible, or not presently expressed.
CRE	21	established authorship :: A stable relation connects a creator, design intention, or source transformation to a target work.	active design influence :: A creator or source form is actively shaping, generating, or transforming a target.	unresolved authorship :: A possible creative source, ownership, or design relation exists but is disputed or unconfirmed.
CRE	22	stable design space :: A creative system has established relationships among its forms, constraints, templates, and transformations.	active composability :: Forms and generators are actively combining and influencing one another across a creative system.	unrealized form space :: A coherent family of artifacts, worlds, or transformations could exist but has not yet been created.
ORI	00	foundational source :: A stable inward first condition or ontological ground is treated as the source of existence.	present actuality :: Existence is presently manifest as an active inward state of reality.	latent first condition :: An origin-state is preserved as dormant or pre-manifest potential rather than current actuality.
ORI	01	manifest fact :: A stable external condition is actual and bounded within reality.	emergent phenomenon :: A condition or entity is actively becoming manifest as an observable part of reality.	unmanifest condition :: A possible external fact or phenomenon is defined but has not entered actuality.
ORI	02	universal order :: Stable laws or foundational relations hold across a shared reality.	unfolding reality :: A cosmos or shared reality is actively expressing change under its foundational laws.	pre-manifest world state :: A coherent shared reality is possible or preserved in potential but is not currently manifest.
ORI	10	origin transition complete :: An inward passage from non-expression to stable existence has reached completion.	becoming :: Existence is actively emerging, continuing, or differentiating from an inward source.	pending emergence :: An inward transition into actuality is possible or prepared but has not begun.
ORI	11	manifestation complete :: A source condition has fully produced or actualized an external fact, entity, or result.	manifest :: A source is actively causing, expressing, or actualizing a target within reality.	poised manifestation :: A target could become actual from its source conditions but has not yet emerged.
ORI	12	world transition complete :: A system-wide ontological, cosmological, or epochal transition has reached a stable new reality state.	reality unfolding :: A shared reality is actively evolving, differentiating, or passing through a foundational transition.	pending world transition :: A coherent system-level transformation of reality is possible or staged but not yet active.
ORI	20	stable existence capacity :: A source has a dependable inward capacity to exist, persist, or become actual.	expressed possibility :: An inward possibility is currently viable and participating in actuality.	pure potential :: A capacity for existence is present only as dormant, pre-manifest possibility.
ORI	21	necessary dependence :: A stable causal or ontological relation makes a target depend on a source or prior condition.	active causation :: A source condition is actively bringing about, constraining, or sustaining a target.	contingency :: A possible causal or ontological relation could hold, but necessity, outcome, or dependence is unresolved.
ORI	22	universality :: A foundational relation holds stably across every relevant part of a reality.	lawful interdependence :: Parts of reality are actively co-determining one another under shared laws.	possible world :: A coherent system of reality and law could exist, but it is not presently realized.
ROWS

def parse_semantics
  records = {}
  SEMANTIC_ROWS.each_line.with_index(1) do |line, line_number|
    next if line.strip.empty?

    family, prefix, *variants = line.chomp.split("\t")
    raise "Bad semantic row #{line_number}" unless FAMILIES.key?(family) && prefix&.match?(/\A[012]{2}\z/) && variants.length == 3

    variants.each_with_index do |variant, third|
      title, definition = variant.split(" :: ", 2)
      raise "Bad semantic variant #{line_number}.#{third}" unless title && definition

      address = "#{prefix}#{third}"
      id = "#{family}:#{address}"
      raise "Duplicate semantic ID #{id}" if records.key?(id)

      records[id] = { "title" => title, "core_definition" => definition }
    end
  end
  records
end

def compact_root(address)
  initials = { "0" => "n", "1" => "k", "2" => "m" }
  vowels = { "0" => "a", "1" => "o", "2" => "i" }
  finals = { "0" => "m", "1" => "k", "2" => "n" }
  "#{initials.fetch(address[0])}#{vowels.fetch(address[1])}#{finals.fetch(address[2])}"
end

def formal_carrier(onset, address)
  carriers = { "0" => "ma", "1" => "ki", "2" => "nu" }
  ([onset] + address.chars.map { |trit| carriers.fetch(trit) }).join("-")
end

def note_path(address)
  movements = { "0" => 0, "1" => 2, "2" => -2 }
  address.chars.each_with_object([0]) { |trit, path| path << path.last + movements.fetch(trit) }
end

def address_axes(address)
  first = {
    "0" => "entity, substance, or condition",
    "1" => "process, action, or transformation",
    "2" => "relationship, capacity, or possibility"
  }
  second = {
    "0" => "inward, self, or source",
    "1" => "outward, other, or target",
    "2" => "shared, environmental, distributed, or systemic"
  }
  third = {
    "0" => "stable, bounded, or completed",
    "1" => "active, changing, or expressed",
    "2" => "dormant, unresolved, or potential"
  }
  {
    "first_trit" => first.fetch(address[0]),
    "second_trit" => second.fetch(address[1]),
    "third_trit" => third.fetch(address[2])
  }
end

def build_atom(id, semantic)
  family, address = id.split(":")
  family_data = FAMILIES.fetch(family)
  onset = family_data.fetch("onset")
  local_root = compact_root(address)
  sibling_ids = %w[0 1 2].map { |third| "#{family}:#{address[0, 2]}#{third}" } - [id]

  {
    "family" => family,
    "address" => address,
    "canonical_id" => id,
    "title" => semantic.fetch("title"),
    "status" => "provisional_for_review",
    "approval_effect" => "The address and encoding are fixed by accepted algorithms; the proposed title and meaning require explicit user approval before becoming canonical.",
    "semantic_origin" => "Model-authored Phase 2 completion requested by the user; not extracted from the Era Zero source conversation.",
    "family_domain" => family_data.fetch("domain"),
    "family_onset" => onset,
    "harmonic_signature_semitones" => family_data.fetch("harmony"),
    "universal_slot" => UNIVERSAL_SLOTS.fetch(address),
    "address_axes" => address_axes(address),
    "local_compact_root" => local_root,
    "canonical_transliteration" => "#{onset}·#{local_root}",
    "formal_carrier" => formal_carrier(onset, address),
    "core_definition" => semantic.fetch("core_definition"),
    "translation_candidates" => [semantic.fetch("title")],
    "distinctions_and_exclusions" => [
      "Keep this root inside the #{family} domain: #{family_data.fetch('domain')}.",
      "The third address trit is part of the lexical meaning; it is not the runtime-state ending.",
      "A following runtime state [0], [1], or [2]/num may still mark this root inactive, active, or pending in the current utterance."
    ],
    "neighbor_contrasts" => sibling_ids,
    "normal_example" => "#{id} [1] — #{semantic.fetch('core_definition')}",
    "technical_example" => "#{onset}·#{local_root} / #{formal_carrier(onset, address)} / path #{note_path(address).join(', ')} semitones.",
    "runtime_state_examples" => {
      "0" => "#{id} [0] — this lexical concept is currently inactive, false, ended, unavailable, or inaccessible.",
      "1" => "#{id} [1] — this lexical concept is currently active, valid, expressed, or executing.",
      "2" => "#{id} [2] — this lexical concept is currently dormant, pending, remembered, possible, or unresolved; the vocal ending is num."
    },
    "note_path_semitones" => note_path(address),
    "proposal" => {
      "phase" => 2,
      "review_unit" => "nine-root chunk",
      "source_support" => "encoding algorithms and universal slot only; lexical title and definition are new proposals"
    }
  }
end

def chunk_definitions
  chunks = []
  chunk_number = 0
  {
    "MOV" => %w[1 2],
    "MAT" => %w[0 1 2],
    "MIN" => %w[0 1 2],
    "CON" => %w[0 1 2],
    "STR" => %w[0 1 2],
    "WRN" => %w[0 1 2],
    "REP" => %w[0 1 2],
    "LOG" => %w[0 1 2],
    "DAT" => %w[0 1 2],
    "CRE" => %w[0 1 2],
    "ORI" => %w[0 1 2]
  }.each do |family, layers|
    layers.each do |layer|
      chunk_number += 1
      addresses = %w[00 01 02 10 11 12 20 21 22].map { |tail| "#{layer}#{tail}" }
      chunks << {
        "number" => chunk_number,
        "family" => family,
        "layer" => layer,
        "range" => "#{family}:#{layer}00–#{layer}22",
        "ids" => addresses.map { |address| "#{family}:#{address}" }
      }
    end
  end
  chunks
end

def write_yaml(path, object)
  File.write(path, YAML.dump(object), encoding: "UTF-8")
end

semantics = parse_semantics
completed = YAML.load_file(File.join(ROOT, "lexicon/completed_atoms.yaml")).fetch("atoms")
completed_ids = completed.map { |atom| atom.fetch("canonical_id") }
all_ids = FAMILIES.keys.flat_map do |family|
  (0..26).map { |number| "#{family}:#{number.to_s(3).rjust(3, '0')}" }
end
missing_ids = all_ids - completed_ids

unless semantics.keys.sort == missing_ids.sort
  absent = missing_ids - semantics.keys
  extra = semantics.keys - missing_ids
  raise "Semantic catalogue mismatch. Absent: #{absent.inspect}; extra: #{extra.inspect}"
end

provisional = missing_ids.map { |id| build_atom(id, semantics.fetch(id)) }
all_atoms = (completed + provisional).sort_by { |atom| [FAMILIES.keys.index(atom.fetch("family")), atom.fetch("address")] }
chunks = chunk_definitions

FileUtils.mkdir_p(File.join(ROOT, "reports/phase2_chunks"))

write_yaml(
  File.join(ROOT, "lexicon/provisional_atoms.yaml"),
  {
    "metadata" => {
      "title" => "Era Zero Phase 2 provisional atomic lexicon",
      "status" => "provisional_for_review",
      "count" => provisional.length,
      "canonical_baseline_count" => completed.length,
      "approval_policy" => "Approve, revise, or reject by nine-root chunk. No proposed meaning is canonical until explicitly approved."
    },
    "atoms" => provisional
  }
)

write_yaml(
  File.join(ROOT, "lexicon/all_atoms.yaml"),
  {
    "metadata" => {
      "title" => "Era Zero complete 324-address lexicon",
      "total_count" => all_atoms.length,
      "canonical_count" => completed.length,
      "provisional_count" => provisional.length,
      "semantic_status" => "mixed_canonical_and_provisional"
    },
    "atoms" => all_atoms
  }
)

write_yaml(
  File.join(ROOT, "spec/phase2_provisional_spec.yaml"),
  {
    "metadata" => {
      "title" => "Era Zero Phase 2 provisional core completion",
      "status" => "draft_for_user_review",
      "canonical_rule_source" => "spec/canonical_spec.yaml",
      "canonical_atom_source" => "lexicon/completed_atoms.yaml",
      "provisional_atom_source" => "lexicon/provisional_atoms.yaml"
    },
    "scope" => {
      "addresses_total" => 324,
      "canonical_meanings" => 36,
      "provisional_meanings" => 288,
      "review_chunks" => 32,
      "not_in_scope" => [
        "English translator",
        "new syntax rules",
        "long-address encoding",
        "negation design",
        "glyph geometry",
        "historical contraction canonization"
      ]
    },
    "semantic_constraints" => {
      "family_domain_required" => true,
      "universal_slot_required" => true,
      "third_trit_is_lexical" => true,
      "runtime_state_is_separate" => true,
      "canonical_36_are_immutable_in_this_phase" => true
    },
    "ori_num_resolution" => {
      "status" => "provisional_resolution",
      "ORI:002" => {
        "generated_transliteration" => "nu·nan",
        "proposed_meaning" => "latent first condition"
      },
      "runtime_state_2" => {
        "name" => "num",
        "role" => "runtime ending, not the ORI:002 compact root"
      },
      "historical_num_contraction" => "remains unresolved and is not canonized by this phase"
    },
    "review_chunks" => chunks
  }
)

chunks.each do |chunk|
  chunk_atoms = provisional.select { |atom| chunk.fetch("ids").include?(atom.fetch("canonical_id")) }
  filename = format("%02d_%s_%s00-%s22.md", chunk.fetch("number"), chunk.fetch("family"), chunk.fetch("layer"), chunk.fetch("layer"))
  lines = []
  lines << "# Chunk #{format('%02d', chunk.fetch('number'))}: #{chunk.fetch('range')}"
  lines << ""
  lines << "**Status:** Provisional for review. Approving this file promotes only these nine meanings."
  lines << ""
  lines << "| ID | Form | Title | Universal slot | Proposed core definition |"
  lines << "| --- | --- | --- | --- | --- |"
  chunk_atoms.each do |atom|
    definition = atom.fetch("core_definition").gsub("|", "\\|")
    lines << "| `#{atom.fetch('canonical_id')}` | **#{atom.fetch('canonical_transliteration')}** | #{atom.fetch('title')} | #{atom.fetch('universal_slot')} | #{definition} |"
  end
  lines << ""
  lines << "Review options: **approve**, **approve with edits**, or **return for revision**."
  lines << ""
  File.write(File.join(ROOT, "reports/phase2_chunks", filename), lines.join("\n"), encoding: "UTF-8")
end

review_lines = [
  "# Era Zero Phase 2 — 32-Chunk Review Catalogue",
  "",
  "The 36 source-approved roots remain canonical and unchanged. The following 288 meanings are proposals.",
  "",
  "Approve, revise, or reject in nine-root chunks. Encoding fields are generated from accepted algorithms; semantic titles and definitions are new.",
  ""
]
chunks.each do |chunk|
  review_lines << "## Chunk #{format('%02d', chunk.fetch('number'))}: `#{chunk.fetch('range')}`"
  review_lines << ""
  provisional.select { |atom| chunk.fetch("ids").include?(atom.fetch("canonical_id")) }.each do |atom|
    review_lines << "- `#{atom.fetch('canonical_id')}` **#{atom.fetch('canonical_transliteration')} — #{atom.fetch('title')}**: #{atom.fetch('core_definition')}"
  end
  review_lines << ""
end
File.write(File.join(ROOT, "reports/phase2_chunk_review.md"), review_lines.join("\n"), encoding: "UTF-8")

completion_lines = [
  "# Era Zero Phase 2 Completion Report",
  "",
  "## Outcome",
  "",
  "- Canonical meanings preserved unchanged: **#{completed.length}**",
  "- New provisional meanings generated: **#{provisional.length}**",
  "- Complete encoded address inventory: **#{all_atoms.length}**",
  "- Nine-root review chunks: **#{chunks.length}**",
  "- Missing addresses after generation: **0**",
  "",
  "The address inventory is complete, but the new meanings are not canonical until the user explicitly approves them.",
  "",
  "## Semantic method",
  "",
  "Every proposal was constrained by its family domain and the accepted three-trit universal slot. Neighboring roots in each three-member row contrast stable/completed (`0`), active/expressed (`1`), and dormant/pending/potential (`2`) lexical meanings.",
  "",
  "Runtime state remains a separate ending. A lexical `...2` root can carry runtime `[0]`, `[1]`, or `[2]` without changing its address.",
  "",
  "## ORI / num treatment",
  "",
  "- Proposed `ORI:002`: **nu·nan**, “latent first condition,” generated by the latest compact-root algorithm.",
  "- Runtime state 2 retains the name **num**.",
  "- The historical use of *num* as a contraction remains unresolved and is not made canonical here.",
  "",
  "## Review entry points",
  "",
  "- Unified review: `reports/phase2_chunk_review.md`",
  "- Per-chunk files: `reports/phase2_chunks/`",
  "- Full provisional records: `lexicon/provisional_atoms.yaml`",
  "- Mixed complete inventory: `lexicon/all_atoms.yaml`",
  "- Provisional core extension: `spec/phase2_provisional_spec.yaml`"
]
File.write(File.join(ROOT, "reports/phase2_completion_report.md"), completion_lines.join("\n"), encoding: "UTF-8")

puts "Generated #{provisional.length} provisional atoms, #{all_atoms.length} total atoms, and #{chunks.length} review chunks."
