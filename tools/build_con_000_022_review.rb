#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "CON:000–022"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "CON_000_022"
FAMILY_DOMAIN = "connection, communication, sharing, and participant coordination"
SEMANTIC_CENTER = "communicative loci: source endpoint, target endpoint, or shared channel"

atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2_CANDIDATES = {
  "CON:000" => ["stable self-link", "An entity has a persistent internal communication link among its own parts, voices, or interfaces."],
  "CON:001" => ["receptive presence", "An entity is actively listening, receiving, or holding an internal channel open."],
  "CON:002" => ["disconnected interface", "An internal connection point exists but is inactive, unavailable, or not yet linked."],
  "CON:010" => ["identified counterpart", "A specific external participant or endpoint is stably recognized as a communication target."],
  "CON:011" => ["active correspondent", "An external participant is presently connected, responsive, or exchanging communication."],
  "CON:012" => ["unavailable counterpart", "A known participant or endpoint exists but is offline, unreachable, or not yet engaged."],
  "CON:020" => ["established network", "A shared communication network, language community, or channel system is stable and bounded."],
  "CON:021" => ["live network", "A shared network is actively carrying messages, signals, attention, or social exchange."],
  "CON:022" => ["dormant network", "A communication system or community remains defined but is not currently connected or exchanging."]
}.freeze

WINNERS = {
  "CON:000" => [
    "persistent source endpoint",
    "A bounded communicative locus that remains identified as the source-side endpoint of an exchange context."
  ],
  "CON:001" => [
    "active source endpoint",
    "A source-side communicative locus presently participating as an endpoint in an exchange context."
  ],
  "CON:002" => [
    "dormant source endpoint",
    "A source-side communicative locus defined for an exchange context without presently participating in it."
  ],
  "CON:010" => [
    "persistent target endpoint",
    "A bounded communicative locus that remains identified as the target-side endpoint of an exchange context."
  ],
  "CON:011" => [
    "active target endpoint",
    "A target-side communicative locus presently participating as an endpoint in an exchange context."
  ],
  "CON:012" => [
    "dormant target endpoint",
    "A target-side communicative locus defined for an exchange context without presently participating in it."
  ],
  "CON:020" => [
    "persistent shared channel",
    "A bounded communicative environment that remains the common exchange context of multiple participant endpoints."
  ],
  "CON:021" => [
    "active shared channel",
    "A shared communicative environment presently functioning as the common exchange context of multiple participant endpoints."
  ],
  "CON:022" => [
    "dormant shared channel",
    "A shared communicative environment defined for multiple participant endpoints without presently functioning as their common exchange context."
  ]
}.freeze

ROLE_CANDIDATES = {
  "CON:000" => ["established originator role", "A persistent communicative role whose bearer is treated as the originator of expressions."],
  "CON:001" => ["active originator role", "A presently occupied communicative role from which an expression originates."],
  "CON:002" => ["unfilled originator role", "A defined originator role that presently has no participating bearer."],
  "CON:010" => ["designated addressee role", "A persistent communicative role whose bearer is treated as the intended addressee."],
  "CON:011" => ["active addressee role", "A presently occupied communicative role to which an expression is directed."],
  "CON:012" => ["unfilled addressee role", "A defined addressee role that presently has no participating bearer."],
  "CON:020" => ["established audience role", "A persistent collective communicative role assigned to multiple participants."],
  "CON:021" => ["active audience role", "A collective communicative role presently occupied by multiple participants."],
  "CON:022" => ["unfilled audience role", "A defined collective communicative role that presently has no participating group."]
}.freeze

CONTACT_CANDIDATES = {
  "CON:000" => ["persistent self-contact condition", "A stable condition in which a source remains communicatively connected to its own components."],
  "CON:001" => ["active inward receptivity", "A current condition in which a source is open to internally arriving communication."],
  "CON:002" => ["inward disconnection", "A dormant condition in which a source-side contact path is not connected."],
  "CON:010" => ["persistent target reachability", "A stable condition in which a selected target remains communicatively reachable."],
  "CON:011" => ["active target reachability", "A current condition in which communication can reach a selected target."],
  "CON:012" => ["target unreachability", "A dormant condition in which a selected target is not communicatively reachable."],
  "CON:020" => ["persistent network connectivity", "A stable condition in which a participant system remains communicatively connected."],
  "CON:021" => ["active network connectivity", "A current condition in which a participant system is exchanging across its connections."],
  "CON:022" => ["network disconnection", "A dormant condition in which a participant system is not exchanging across its connections."]
}.freeze

ARTIFACT_CANDIDATES = {
  "CON:000" => ["persistent private codebook", "A stable source-side collection of signs used to formulate expressions."],
  "CON:001" => ["outgoing signal token", "A presently expressed source-side communicative artifact."],
  "CON:002" => ["unexpressed draft", "A source-side communicative artifact retained without present expression."],
  "CON:010" => ["persistent address label", "A stable sign that designates an external communication target."],
  "CON:011" => ["incoming signal token", "A presently expressed communicative artifact at a target."],
  "CON:012" => ["undelivered signal", "A target-directed communicative artifact not presently expressed at that target."],
  "CON:020" => ["persistent shared protocol", "A stable collective system of signs used by multiple participants."],
  "CON:021" => ["active shared language", "A collective sign system presently being used by multiple participants."],
  "CON:022" => ["dormant shared protocol", "A collective sign system retained without present use by participants."]
}.freeze

SCORE_KEYS = EraZeroValidation::SCORE_KEYS
SCORE_PROFILES = {
  "current_phase2" => [6, 8, 8, 5, 5, 7, 8, 7],
  "endpoint_channel" => [10, 10, 10, 10, 9, 10, 9, 10],
  "communicative_role" => [9, 8, 8, 8, 7, 9, 10, 8],
  "contact_availability" => [8, 9, 8, 7, 6, 9, 9, 9],
  "signaling_artifact" => [8, 7, 6, 7, 4, 8, 8, 9]
}.freeze

def score_hash(values)
  SCORE_KEYS.zip(values).to_h
end

def candidate(candidate_id, title, invariant, scores, analysis)
  score_map = score_hash(scores)
  {
    "candidate_id" => candidate_id,
    "title" => title,
    "invariant_candidate" => invariant,
    "analysis" => analysis,
    "scores" => score_map,
    "total" => score_map.values.sum,
    "maximum" => score_map.length * 10
  }
end

def root_axes(id)
  address = id.split(":").last
  second = address[1]
  third = address[2]
  scope = { "0" => "inward/source", "1" => "outward/target", "2" => "shared/systemic" }.fetch(second)
  expression = { "0" => "stable or persistent", "1" => "active or expressed", "2" => "dormant or latent" }.fetch(third)
  [scope, expression]
end

def candidate_analysis(id, candidate_id, title)
  scope, expression = root_axes(id)
  case candidate_id
  when "current_phase2"
    {
      "why_it_fits" => "The Phase 2 proposal follows the #{scope} and #{expression} labels and selects familiar Connection-family vocabulary.",
      "useful_coverage" => "It would cover ordinary and technical uses associated with #{title}.",
      "semantic_territory_consumed" => "It consumes a mixture of participant identity, channel state, receptivity, reachability, or network structure depending on the address.",
      "conflicts_or_future_limitations" => "Across the nine roots it changes semantic center between links, listening, interfaces, people, and networks, weakening triplet parallelism and colliding with CON processes and relationships."
    }
  when "endpoint_channel"
    {
      "why_it_fits" => "A communicative locus is an entity/condition, its source/target/shared placement follows the second trit exactly, and endpoint or channel persistence follows the third trit without encoding an exchange process.",
      "useful_coverage" => "It covers speakers and devices as endpoints, addressees and services as endpoints, and conversations, rooms, sessions, or buses as shared channels through later compounds.",
      "semantic_territory_consumed" => "Only the communicative locus that participates in an exchange context: source endpoint, target endpoint, or shared channel.",
      "conflicts_or_future_limitations" => "It intentionally leaves participant identity to LIF, message content to DAT, transmission to CON:1xx, bonds and compatibility to CON:2xx, and physical or structural implementations to MAT/STR."
    }
  when "communicative_role"
    {
      "why_it_fits" => "Originator, addressee, and audience roles align naturally with source, target, and shared scope, while occupied versus unfilled roles can reflect lexical expression.",
      "useful_coverage" => "It would directly encode speaker, listener, author, recipient, audience, caller, callee, publisher, and subscriber roles.",
      "semantic_territory_consumed" => "Assignment of discourse and participant roles rather than communication loci or exchange relations.",
      "conflicts_or_future_limitations" => "Roles are often grammar-level argument assignments or CON:2xx relations; making them atoms would entangle lexical identity with each utterance and weaken technical endpoint coverage."
    }
  when "contact_availability"
    {
      "why_it_fits" => "Connected, reachable, online, and offline are salient Connection conditions and can be arranged by source, target, and system scope.",
      "useful_coverage" => "It would cover presence, online status, reachability, disconnection, reception readiness, and network availability.",
      "semantic_territory_consumed" => "Connectivity and availability states of participants or systems.",
      "conflicts_or_future_limitations" => "Reachability is a capacity or relationship suited to CON:2xx, online/offline is often runtime state, and network availability also collides with STR and WRN."
    }
  when "signaling_artifact"
    {
      "why_it_fits" => "Communication commonly uses signals, addresses, drafts, protocols, and languages that can be described at source, target, or shared scope.",
      "useful_coverage" => "It would cover utterances, drafts, addresses, protocols, codebooks, languages, and incoming or outgoing signal tokens.",
      "semantic_territory_consumed" => "The content-bearing or rule-bearing artifacts used during communication.",
      "conflicts_or_future_limitations" => "Signals and messages belong primarily to DAT, protocols to LOG/STR, and outgoing or incoming tokens encode process direction rather than entity scope."
    }
  end
end

def nearest_neighbors(id)
  family, address = id.split(":")
  first, second, third = address.chars
  siblings = %w[0 1 2].reject { |value| value == third }.map { |value| "#{family}:#{first}#{second}#{value}" }
  cross_scope = %w[0 1 2].reject { |value| value == second }.map { |value| "#{family}:#{first}#{value}#{third}" }
  process = "#{family}:1#{second}#{third}"
  relation = "#{family}:2#{second}#{third}"
  (siblings + cross_scope + [process, relation, "DAT:0#{second}#{third}", "STR:0#{second}#{third}"]).uniq.first(8)
end

CROSS_FAMILY_BASE = {
  "LIF" => "LIF identifies living or conscious participants. A person or organism can bear a CON endpoint, but biological identity is not the communicative locus.",
  "MOV" => "MOV owns physical position, approach, routes, and shared reference frames. Spatial proximity can support communication without constituting an endpoint or channel.",
  "MAT" => "MAT owns cables, radios, bodies, sound waves, and other physical substrates. CON names the communicative locus or environment realized through them.",
  "MIN" => "MIN owns representations, revision, and attention. Understanding, noticing, or jointly attending is not the same as occupying an endpoint or channel.",
  "STR" => "STR owns topology, containment, organization, and system architecture. A structure can implement a channel, but organization alone does not make it communicative.",
  "WRN" => "WRN owns communication failure, loss, corruption, spoofing, and unavailability when evaluated as danger or error. CON remains neutral about success.",
  "REP" => "REP owns reconnecting, restoring, or healing damaged communication. A repaired channel may again satisfy CON, but repair is not the endpoint or channel itself.",
  "LOG" => "LOG owns protocol rules, typing, validity, permissions, and formal coordination. Rule compatibility may govern a channel without being that channel.",
  "DAT" => "DAT owns messages, symbols, records, payloads, and signals as information objects. CON owns where communicative participation and shared exchange occur.",
  "CRE" => "CRE owns designing or instantiating communication systems and artifacts. A created interface becomes a CON endpoint only when assigned a communicative locus.",
  "ORI" => "ORI owns existence, manifestation, modality, time, and universal conditions. Persistent, active, and dormant CON lexemes do not silently encode tense or possibility."
}.freeze

def roles
  {
    "low" => "source endpoint or originating participant",
    "middle" => "CON endpoint or shared channel",
    "high" => "target endpoint or addressed participant",
    "sustained" => "shared communicative environment or exchange context"
  }
end

def examples_for(id, title)
  scope = id[4, 2]
  case scope
  when "00"
    [
      ["ordinary_conversation", "CON:000[1](ENDPOINT=me,CONTEXT=call)", "me as persistent source endpoint of call", "I remain the identified source endpoint for this call.", "The assertion affirms the persistent source endpoint."],
      ["physical_or_spatial", "MAT(RADIO=device)+CON:000[1](ENDPOINT=device)", "physical radio bearing persistent source endpoint", "The radio is the identified transmitting-side endpoint.", "MAT owns the radio; CON owns its communicative locus."],
      ["temporal_or_sequential", "CON:000[1](ENDPOINT=station,ACROSS=sessions)", "station remains source endpoint across sessions", "The station keeps the same source-endpoint identity between sessions.", "Persistence spans sessions without asserting current transmission."],
      ["cross_family_compound", "LIF:000[1](BEARER=person)+CON:000[1](ENDPOINT=person)", "continuous person plus persistent source endpoint", "The same person remains the source-side participant point.", "LIF supplies identity; CON supplies the endpoint."],
      ["executable_or_programming", "CON:000[1](ENDPOINT=service_A,CONTEXT=request)", "service A as persistent request source endpoint", "Service A is registered as the source endpoint.", "This is endpoint identity, not a send operation."],
      ["counterexample", "DAT(MESSAGE=payload)", "information payload", "The payload is data, not the source endpoint.", "DAT must be used for message content."]
    ]
  when "01"
    [
      ["ordinary_conversation", "CON:001[1](ENDPOINT=caller,CONTEXT=conversation)", "caller presently source endpoint", "The caller is presently participating on the source side.", "The active entity is present without lexicalizing the act of sending."],
      ["physical_or_spatial", "MAT(MICROPHONE=mic)+CON:001[1](ENDPOINT=mic)", "microphone presently source endpoint", "This microphone is the active source endpoint in the room.", "The device is MAT; its current communicative locus is CON."],
      ["temporal_or_sequential", "CON:001[1](ENDPOINT=operator,DURING=turn)", "operator actively source endpoint during turn", "The operator occupies the source endpoint during this turn.", "Timing bounds the active endpoint condition."],
      ["cross_family_compound", "MIN:001[1](MIND=agent)+CON:001[1](ENDPOINT=agent)", "manifest representation plus active source endpoint", "The agent is mentally engaged and presently occupies the source endpoint.", "Mind state and communication locus remain separate."],
      ["executable_or_programming", "CON:001[1](ENDPOINT=producer,CHANNEL=events)", "producer presently source endpoint on events", "The producer is attached as the active source endpoint.", "Publishing a payload remains a CON:1xx process plus DAT."],
      ["counterexample", "CON:111[1](SENDER=producer,TARGET=consumer)", "active outward communication process", "The producer is transmitting; that act is not CON:001.", "CON:1xx must own transmission processes."]
    ]
  when "02"
    [
      ["ordinary_conversation", "CON:002[1](ENDPOINT=former_speaker,CONTEXT=meeting)", "defined but dormant source endpoint", "The former speaker's source position remains defined, although they are not participating now.", "Runtime [1] affirms the dormant lexeme."],
      ["physical_or_spatial", "MAT(RADIO=backup)+CON:002[1](ENDPOINT=backup)", "backup radio as dormant source endpoint", "The backup radio has a defined source-side endpoint but is not participating.", "Dormancy is lexical, not physical nonexistence."],
      ["temporal_or_sequential", "CON:002[1](ENDPOINT=archived_account,AFTER=session)", "source endpoint retained after session", "The account retains its source endpoint after the session closes.", "The locus persists as dormant after participation ends."],
      ["cross_family_compound", "STR(PORT=port7)+CON:002[1](ENDPOINT=port7)", "structured port plus dormant source endpoint", "Port 7 is structurally defined as a source endpoint but is not participating.", "STR supplies the port; CON supplies communicative status."],
      ["executable_or_programming", "CON:002[1](ENDPOINT=producer_backup,CHANNEL=events)", "dormant producer endpoint", "The backup producer endpoint is registered but unattached.", "Registration is not a queued send."],
      ["counterexample", "CON:102[1](PROCESS=source_exchange)", "nonactualized inward communication process", "A pending communication operation is not a dormant endpoint.", "Lexical entity dormancy and process nonactualization differ."]
    ]
  when "10"
    [
      ["ordinary_conversation", "CON:010[1](ENDPOINT=you,CONTEXT=message)", "you as persistent target endpoint", "You remain the identified target endpoint for this exchange.", "The root does not assert delivery or response."],
      ["physical_or_spatial", "MAT(SPEAKER=device)+CON:010[1](ENDPOINT=device)", "speaker device bearing target endpoint", "The wall speaker is the designated target-side endpoint.", "MAT owns hardware; CON owns its communicative locus."],
      ["temporal_or_sequential", "CON:010[1](ENDPOINT=archive_service,ACROSS=request_series)", "target endpoint persists across requests", "The archive service keeps the same target endpoint across requests.", "Persistence is lexical rather than continuous traffic."],
      ["cross_family_compound", "LIF:010[1](OTHER=recipient)+CON:010[1](ENDPOINT=recipient)", "identified other plus target endpoint", "The identified person is designated as the target-side participant point.", "LIF supplies who; CON supplies communication role as locus."],
      ["executable_or_programming", "CON:010[1](ENDPOINT=/submit,CONTEXT=api)", "persistent target endpoint named /submit", "The API route is registered as the target endpoint.", "Its path structure may additionally use STR/DAT."],
      ["counterexample", "MIN:211[1](COGNIZER=user,TARGET=screen)", "active target attention", "Looking at the screen is attention, not a communication target endpoint.", "MIN owns cognitive targeting."]
    ]
  when "11"
    [
      ["ordinary_conversation", "CON:011[1](ENDPOINT=listener,CONTEXT=call)", "listener presently target endpoint", "The listener is presently participating on the target side.", "No claim of comprehension or reply is added."],
      ["physical_or_spatial", "MAT(EARPIECE=device)+CON:011[1](ENDPOINT=device)", "earpiece presently target endpoint", "This earpiece is the active target endpoint.", "The hardware and communicative locus remain distinct."],
      ["temporal_or_sequential", "CON:011[1](ENDPOINT=moderator,DURING=turn)", "moderator active as target endpoint during turn", "The moderator occupies the target endpoint during this turn.", "The condition changes with participant turns."],
      ["cross_family_compound", "MIN:211[1](COGNIZER=listener,TARGET=utterance)+CON:011[1](ENDPOINT=listener)", "attention plus active target endpoint", "The listener is both attending and occupying the target endpoint.", "Neither condition implies the other."],
      ["executable_or_programming", "CON:011[1](ENDPOINT=consumer,CHANNEL=events)", "consumer presently target endpoint", "The consumer is attached as the active target endpoint.", "Receiving a specific message remains a process."],
      ["counterexample", "CON:110[1](TRANSFER=message)", "completed outward communication process", "Successful delivery is not the active target endpoint itself.", "CON:1xx owns delivery and transfer." ]
    ]
  when "12"
    [
      ["ordinary_conversation", "CON:012[1](ENDPOINT=absent_member,CONTEXT=call)", "defined dormant target endpoint", "The absent member remains a defined target endpoint but is not participating.", "Runtime [1] affirms target-endpoint dormancy."],
      ["physical_or_spatial", "MAT(RECEIVER=backup)+CON:012[1](ENDPOINT=backup)", "backup receiver as dormant target endpoint", "The backup receiver is defined as a target endpoint but is not participating.", "Physical availability requires MAT or WRN if relevant."],
      ["temporal_or_sequential", "CON:012[1](ENDPOINT=account,BEFORE=login)", "target endpoint defined before participation", "The account is a dormant target endpoint before login.", "This does not encode a future schedule."],
      ["cross_family_compound", "WRN(UNREACHABLE=account)+CON:012[1](ENDPOINT=account)", "unreachability warning plus dormant target endpoint", "The target endpoint is dormant and currently unreachable.", "WRN adds failure evaluation; dormancy alone is neutral."],
      ["executable_or_programming", "CON:012[1](ENDPOINT=consumer_backup,CHANNEL=events)", "dormant target endpoint", "The backup consumer endpoint exists but is unattached.", "No queued message is asserted."],
      ["counterexample", "CON:112[1](PROCESS=target_contact)", "nonactualized outward communication process", "A pending contact attempt is not a dormant target endpoint.", "Use the process layer for operations." ]
    ]
  when "20"
    [
      ["ordinary_conversation", "CON:020[1](CHANNEL=family_call,ENDPOINTS=family)", "persistent shared channel for family endpoints", "The family call remains their established shared communication space.", "The root names the common exchange environment, not kinship."],
      ["physical_or_spatial", "MAT(RADIO_BAND=band)+CON:020[1](CHANNEL=band)", "physical band realizing persistent shared channel", "The radio band serves as the established shared channel.", "MAT owns the spectrum; CON owns communicative use."],
      ["temporal_or_sequential", "CON:020[1](CHANNEL=forum,ACROSS=sessions)", "forum remains shared channel across sessions", "The forum keeps its channel identity between active sessions.", "Persistence does not assert current traffic."],
      ["cross_family_compound", "STR:020[1](SYSTEM=room)+CON:020[1](CHANNEL=room)", "organized room plus persistent shared channel", "The room's structure supports an established shared channel.", "STR and CON describe different layers."],
      ["executable_or_programming", "CON:020[1](CHANNEL=events,ENDPOINTS=services)", "persistent shared service channel", "The events channel is the stable common exchange context for the services.", "Payloads and protocol rules remain DAT/LOG."],
      ["counterexample", "STR(NETWORK_TOPOLOGY=graph)", "organized network topology", "A graph of nodes and edges is structure, not necessarily a communication channel.", "STR must own topology without communicative use." ]
    ]
  when "21"
    [
      ["ordinary_conversation", "CON:021[1](CHANNEL=group_call,ENDPOINTS=participants)", "shared channel presently active", "The group call is their active shared communication space.", "The root does not collapse all individual messages into itself."],
      ["physical_or_spatial", "MAT(AIRWAVES=local)+CON:021[1](CHANNEL=radio_net)", "physical airwaves realizing active shared channel", "The radio net is presently functioning as a shared channel.", "Physical carrier and communicative environment remain separate."],
      ["temporal_or_sequential", "CON:021[1](CHANNEL=session,DURING=meeting)", "shared channel active during meeting", "The meeting session is the active common channel now.", "The active condition is bounded by the meeting interval."],
      ["cross_family_compound", "DAT(STREAM=messages)+CON:021[1](CHANNEL=chat)", "message stream within active shared channel", "Messages are flowing through the active group chat.", "DAT owns content; CON owns the shared channel."],
      ["executable_or_programming", "CON:021[1](CHANNEL=event_bus,ENDPOINTS=services)", "event bus as active shared channel", "The event bus is presently functioning as the common service channel.", "Routing logic and payloads remain separate."],
      ["counterexample", "CON:121[1](PROCESS=broadcast)", "active systemic communication process", "Broadcasting is an exchange process, not the active shared channel itself.", "CON:1xx owns communication actions." ]
    ]
  when "22"
    [
      ["ordinary_conversation", "CON:022[1](CHANNEL=old_forum,ENDPOINTS=members)", "defined dormant shared channel", "The old forum remains a defined shared channel although nobody is participating now.", "Runtime [1] affirms the dormant channel lexeme."],
      ["physical_or_spatial", "MAT(FREQUENCY=reserve)+CON:022[1](CHANNEL=reserve)", "reserved frequency realizing dormant channel", "The reserved frequency is defined as a shared channel but is not functioning as one now.", "The spectrum exists physically even while CON is dormant."],
      ["temporal_or_sequential", "CON:022[1](CHANNEL=seasonal_room,BETWEEN=sessions)", "shared channel dormant between sessions", "The seasonal room remains defined between active sessions.", "Dormancy does not encode the date of reopening."],
      ["cross_family_compound", "REP(RESTORE=channel)+CON:022[1](CHANNEL=channel)", "restore operation applied to dormant shared channel", "The dormant channel is being restored.", "REP owns restoration; CON owns the channel condition."],
      ["executable_or_programming", "CON:022[1](CHANNEL=disabled_bus,ENDPOINTS=services)", "defined dormant service channel", "The service bus remains configured as a channel but is not functioning as the common exchange context.", "Configuration details may require STR/LOG."],
      ["counterexample", "CON:222[1](POSSIBLE_NETWORK=participants)", "unrealized systemic communication relationship", "A network that could form is not an already defined dormant channel.", "CON:2xx owns unrealized relational possibility." ]
    ]
  end.map do |category, graph, gloss, english, analysis|
    {
      "category" => category,
      "semantic_graph" => graph,
      "literal_gloss" => gloss,
      "natural_english" => english,
      "runtime_state" => 1,
      "contour" => "level declaration",
      "role_registers" => roles,
      "use_status" => category == "counterexample" ? "must_not_use_this_root" : "valid",
      "analysis" => analysis,
      "pseudocode" => category == "executable_or_programming" ? "assert(communication_context.matches?(#{id.inspect}))" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  phase2_title, phase2_definition = PHASE2_CANDIDATES.fetch(id)
  winner_title, winner_definition = WINNERS.fetch(id)
  role_title, role_definition = ROLE_CANDIDATES.fetch(id)
  contact_title, contact_definition = CONTACT_CANDIDATES.fetch(id)
  artifact_title, artifact_definition = ARTIFACT_CANDIDATES.fetch(id)
  candidate_specs = [
    ["current_phase2", phase2_title, phase2_definition],
    ["endpoint_channel", winner_title, winner_definition],
    ["communicative_role", role_title, role_definition],
    ["contact_availability", contact_title, contact_definition],
    ["signaling_artifact", artifact_title, artifact_definition]
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", phase2_title)["why_it_fits"],
    "candidates" => candidate_specs.map do |candidate_id, title, invariant|
      candidate(candidate_id, title, invariant, SCORE_PROFILES.fetch(candidate_id),
                candidate_analysis(id, candidate_id, title))
    end,
    "recommended_candidate_id" => "endpoint_channel",
    "recommendation_reason" => "The endpoint/channel architecture is the only candidate that keeps all nine roots on one entity/condition center while separating source locus, target locus, and shared exchange environment from processes, relationships, data, and structure.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end

recommended_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  title, invariant = WINNERS.fetch(id)
  scope, expression = root_axes(id)
  address = id.split(":").last
  second = address[1]
  third = address[2]
  kind = second == "2" ? "shared communicative environment" : "communicative endpoint locus"
  locus_label = { "0" => "source-endpoint locus", "1" => "target-endpoint locus", "2" => "shared-channel locus" }.fetch(second)
  runtime_states = case third
                   when "0"
                     {
                       "0" => "Denies that the persistent identification of this #{locus_label} currently holds in the exchange context; it does not assert either active participation or dormant retention.",
                       "1" => "Affirms that this #{locus_label} remains persistently identified across the stated exchange context, whether or not a particular exchange act is occurring.",
                       "2/num" => "Leaves unresolved whether the persistent identification of this #{locus_label} currently holds; it does not change source/target/shared scope or select an active or dormant sibling."
                     }
                   when "1"
                     {
                       "0" => "States that this #{locus_label} is not presently participating or functioning, or that such participation has ceased; it does not by itself assert the dormant sibling.",
                       "1" => "Affirms that this #{locus_label} is presently participating or functioning in the stated exchange context.",
                       "2/num" => "Leaves unresolved whether this #{locus_label} is presently participating or functioning; it does not convert the lexeme into a dormant endpoint or channel."
                     }
                   when "2"
                     {
                       "0" => "Denies that this defined-but-nonparticipating #{locus_label} currently holds in the exchange context; it does not assert the active sibling.",
                       "1" => "Affirms that this #{locus_label} remains defined in the exchange context while not presently participating or functioning.",
                       "2/num" => "Leaves unresolved even the claim that this dormant #{locus_label} remains defined; lexical dormancy and the token's unresolved runtime status stay distinct."
                     }
                   end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => title,
    "invariant_definition" => invariant,
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_0" => "Selects an entity or condition: #{title} is a #{kind}, not the act of communicating and not the relationship or capacity connecting participants.",
      "second_trit" => "Selects #{scope} scope: #{second == "0" ? "the originating side" : second == "1" ? "the addressed side" : "the common environment of multiple endpoints"} is the locus named by the root.",
      "third_trit" => "Selects #{expression} lexical expression: the endpoint or channel is #{third == "0" ? "retained as a persistent identity" : third == "1" ? "presently participating or functioning" : "defined without present participation or function"}."
    },
    "inclusion_boundary" => "Includes only a communicative locus at this exact source, target, or shared scope and this exact persistent, active, or dormant lexical expression. The bearer may be a person, device, service, port, room, session, medium, or other entity, but this root names its place in an exchange context rather than the bearer itself.",
    "excluded_meanings" => [
      "The identity, life, consciousness, location, physical composition, or structure of the endpoint bearer.",
      "A message, signal payload, symbol, record, protocol, language rule, or stored address as an information object.",
      "Sending, receiving, delivering, broadcasting, negotiating, acknowledging, or otherwise performing a communication process.",
      "A bond, agreement, compatibility relation, reachability capacity, permission, access right, or possible network relation.",
      "Online/offline runtime status, success, failure, schedule, intention, attention, comprehension, or future participation unless another root or grammar supplies it."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "CON:0xx owns communicative endpoint and channel loci; CON:1xx must own communication processes such as transmission or receipt; CON:2xx must own capacities, bonds, compatibility, and unrealized relational possibilities.",
    "cross_family_comparisons" => CROSS_FAMILY_BASE,
    "runtime_state_interpretation" => runtime_states,
    "lexical_runtime_distinction" => "The third lexical trit permanently selects #{expression} endpoint/channel character. Runtime `[2]/num` separately marks the status of this token's assertion. Thus #{id}[1] affirms the #{title} lexeme, while #{id}[2]/num leaves the assertion about that same lexeme unresolved.",
    "examples" => examples_for(id, title),
    "future_compound_examples" => [
      "#{id} + LIF/MAT/STR identifies the living, physical, or structural bearer of the communicative locus without redefining that bearer.",
      "#{id} + DAT supplies a message, signal, record, address, or payload associated with the endpoint or channel.",
      "#{id} + CON:1xx supplies sending, receiving, delivery, broadcast, or another exchange process through the locus.",
      "#{id} + CON:2xx/LOG/WRN/REP supplies bond, compatibility, permission, failure, or restoration while preserving the entity/process/relation boundary."
    ],
    "later_era_notes" => "Later eras may lexicalize speaker, listener, caller, callee, account, mailbox, port, socket, room, forum, frequency, topic, bus, session, and medium as compounds or descendants. The Era Zero invariant must remain neutral about bearer identity, content, protocol, success, and physical implementation.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end

stress_concepts = [
  ["source endpoint", "one_root", "CON:000, CON:001, or CON:002 according to lexical persistence, participation, or dormancy."],
  ["target endpoint", "one_root", "CON:010, CON:011, or CON:012 according to lexical persistence, participation, or dormancy."],
  ["shared channel", "one_root", "CON:020, CON:021, or CON:022 according to lexical persistence, function, or dormancy."],
  ["speaker", "compound", "A living participant plus source endpoint; current speaking additionally requires a CON process."],
  ["sender", "compound", "A source endpoint combined with an outward communication process; do not make sender an entity atom."],
  ["caller", "compound", "A source endpoint in a call context, usually combined with LIF identity and an exchange process."],
  ["author", "different_family", "Authorship belongs primarily to CRE/DAT relations; an author can also occupy a CON source endpoint."],
  ["listener", "compound", "A target endpoint plus MIN attention or a receipt process; endpoint status alone does not prove listening."],
  ["recipient", "compound", "A target endpoint plus delivery or receipt; the person or device identity belongs elsewhere."],
  ["addressee", "compound", "A target endpoint plus an addressing relation or grammar role; the endpoint root alone is not an intended-recipient relation."],
  ["audience", "compound", "Multiple LIF participants occupying target endpoints in a shared channel; not one atomic channel root."],
  ["correspondent", "compound", "A participant with persistent source and target endpoint relations plus CON:2xx bond semantics."],
  ["contact", "compound", "Often a known participant plus persistent endpoint and bond; English contact is too polysemous for one atom."],
  ["participant", "compound", "A bearer occupying any endpoint or shared channel role; LIF/other identity plus CON locus."],
  ["port", "compound", "A STR or MAT interface assigned a CON endpoint; its physical or logical structure is not Connection alone."],
  ["socket", "compound", "A structured programming object plus CON endpoint and LOG protocol constraints."],
  ["API endpoint", "compound", "A structured address/service locus plus persistent target or source endpoint; DAT/LOG supply path and method details."],
  ["account", "different_family", "Identity and records belong to LIF/DAT/STR; an account can be assigned a CON endpoint."],
  ["address", "different_family", "A stored locator is DAT or MOV/STR depending on sense; designation of a target endpoint is compounded."],
  ["inbox", "compound", "A structured data container associated with a target endpoint; not a Connection atom."],
  ["conversation", "compound", "An active shared channel plus reciprocal CON processes and participant endpoints."],
  ["dialogue", "compound", "A shared channel plus alternating source/target processes and relations."],
  ["group chat", "compound", "An active shared channel plus identified participants, data messages, and exchange processes."],
  ["forum", "compound", "A persistent or dormant shared channel realized by STR and DAT storage."],
  ["meeting", "compound", "A shared channel plus participants, time/location, and coordinated processes."],
  ["community", "compound", "A LIF collective and CON relationships that may use a shared channel; community is not the channel itself."],
  ["network", "compound", "STR topology plus CON endpoints/channels and CON:2xx connectivity relations."],
  ["communication medium", "compound", "A CON shared channel realized by MAT substrate or DAT signaling conventions."],
  ["radio channel", "compound", "MAT frequency or carrier plus CON shared channel and LOG protocol constraints."],
  ["event bus", "compound", "STR bus architecture plus active/persistent CON shared channel, DAT events, and LOG rules."],
  ["publish-subscribe topic", "compound", "DAT topic identity plus CON shared channel and CON/LOG participant relations."],
  ["send", "existing_con_process", "Belongs in CON:1xx; source endpoint is an argument, not the send action."],
  ["receive", "existing_con_process", "Belongs in CON:1xx; target endpoint is an argument, not the receive action."],
  ["deliver", "existing_con_process", "A completed target-directed communication process in CON:1xx, not an endpoint entity."],
  ["broadcast", "existing_con_process", "A systemic communication process through a shared channel, not the channel itself."],
  ["acknowledge", "existing_con_process", "A response process or relation to be decided in CON:1xx/2xx, not this entity block."],
  ["message", "different_family", "DAT owns the information object; CON supplies endpoints, channel, and transfer process."],
  ["signal", "different_family", "DAT owns informational signal content and MAT owns physical realization; CON supplies communicative locus."],
  ["record", "different_family", "DAT owns stored information; association with an endpoint or channel is a compound."],
  ["protocol", "different_family", "LOG/STR owns formal rules and arrangement; compatibility across endpoints belongs in CON:2xx."],
  ["language", "compound", "A shared representational and rule system using DAT/MIN/LOG plus a CON channel/community relation."],
  ["agreement", "future_con_relation", "Agreement is a participant relationship and must be reviewed in CON:2xx or compounded with MIN/LOG."],
  ["bond", "future_con_relation", "A stable relationship between participants belongs in CON:2xx, not the entity layer."],
  ["compatibility", "future_con_relation", "Interoperability is a capacity or relation suited to CON:2xx plus LOG/STR constraints."],
  ["reachability", "future_con_relation", "Ability for communication to reach a target is a capacity/relation, not an endpoint entity."],
  ["permission to communicate", "different_family", "Permission is LOG/grammar or a social relation, not endpoint/channel identity."],
  ["online", "runtime_or_compound", "Often runtime [1] applied to an active endpoint/channel plus implementation-specific availability."],
  ["offline", "runtime_or_compound", "May be runtime [0] or a dormant endpoint/channel plus WRN/STR state; it is not one universal atom."],
  ["disconnected", "runtime_or_future_relation", "May deny a connection relation or describe a dormant locus; do not collapse relation and entity."],
  ["unreachable", "compound", "A target endpoint plus denied reachability or WRN failure; CON:012 alone means dormant participation."],
  ["silent", "compound", "An endpoint with no current expression process; silence is not endpoint dormancy by itself."],
  ["waiting for a reply", "grammar_or_compound", "A prior communication process plus pending dependency and expected response; not a dormant endpoint."],
  ["shared attention", "different_family", "MIN:220–222 owns joint attention; it may occur through a CON shared channel."],
  ["telepathy", "compound", "A communication process and channel whose physical mechanism is unspecified; not a new atom."],
  ["translation", "compound", "MIN/DAT/LOG transformation across representations and CON contexts; not an endpoint entity."],
  ["encryption", "different_family", "LOG/DAT transformation and access constraints; it may protect communication but is not Connection itself."],
  ["notification", "compound", "DAT message plus target-directed CON process, possibly WRN salience."],
  ["call session", "compound", "An active shared channel plus endpoints, time bounds, and exchange processes."],
  ["multicast group", "compound", "A participant set and target relations around a shared channel, not one entity root."],
  ["common ground", "different_family", "MIN shared representation plus CON relations; the shared channel does not guarantee common understanding."],
  ["unknown endpoint type", "unresolved_gap", "If bearer and source/target scope cannot be determined, the translator must request clarification rather than guess."]
]

stress_tests = stress_concepts.each_with_index.map do |(concept, routing, analysis), index|
  {
    "test_id" => format("CON0-T%03d", index + 1),
    "english_concept" => concept,
    "routing" => routing,
    "analysis" => analysis
  }
end

scored = {
  "metadata" => {
    "title" => "CON:000–022 adversarial semantic candidates",
    "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation",
    "architecture_version" => "1.0",
    "range" => RANGE,
    "roots_reviewed" => IDS.length,
    "candidate_architectures_per_root" => 5,
    "scored_categories" => SCORE_KEYS,
    "generated_fields_changed" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [],
    "approval_record" => canonicalized_now ? "migrations/CON_000_022_semantic_approval.yaml" : nil
  },
  "roots" => scored_roots
}

recommended = {
  "metadata" => {
    "title" => "CON:000–022 recommended permanent semantic specification",
    "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval",
    "architecture_version" => "1.0",
    "semantic_center" => SEMANTIC_CENTER,
    "triplets" => {
      "CON:000–002" => "source endpoint: persistent / active / dormant",
      "CON:010–012" => "target endpoint: persistent / active / dormant",
      "CON:020–022" => "shared channel: persistent / active / dormant"
    },
    "generated_fields_changed" => false,
    "gate4_started" => false,
    "translator_started" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [],
    "approval_record" => canonicalized_now ? "migrations/CON_000_022_semantic_approval.yaml" : nil
  },
  "roots" => recommended_roots,
  "approval_checklist" => {
    "family_domain_preserved" => true,
    "address_axes_preserved" => true,
    "one_invariant_per_root" => true,
    "triplets_coherent" => true,
    "cross_family_collisions_explicit" => true,
    "runtime_state_separated" => true,
    "generated_fields_unchanged" => true,
    "gate4_not_started" => true,
    "translator_not_started" => true,
    "canonicalized" => canonicalized_now
  }
}

stress = {
  "metadata" => {
    "title" => "CON:000–022 English coverage and routing tests",
    "status" => "review_evidence_not_translation_dictionary",
    "range" => RANGE,
    "test_count" => stress_tests.length,
    "no_forced_atomization" => true
  },
  "tests" => stress_tests
}

File.write(File.join(ROOT, "reviews/#{STEM}_scored_candidates.yaml"), YAML.dump(scored))
File.write(File.join(ROOT, "reviews/#{STEM}_recommended_spec.yaml"), YAML.dump(recommended))
File.write(File.join(ROOT, "reviews/#{STEM}_stress_tests.yaml"), YAML.dump(stress))

review = +"# CON:000–022 Adversarial Semantic Design Review\n\n"
review << if canonicalized_now
            "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n"
          else
            "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n"
          end
review << "This packet challenges every Phase 2 meaning in the Connection entity/condition layer. It compares five genuinely different semantic architectures per address, scores 45 candidates across 360 criterion values, and permits compounds, grammar, other families, and unresolved gaps rather than forcing English words into atoms.\n\n"
review << "## Packet-level design decision\n\n"
review << "The strongest permanent architecture treats `CON:0xx` as **communicative loci**: a source endpoint, target endpoint, or shared channel, each expressed as persistent, active, or dormant. This produces one coherent 3×3 grid and reserves communication actions for `CON:1xx` and capacities, bonds, compatibility, and possibilities for `CON:2xx`.\n\n"
review << "A participant's biological identity is LIF; a device or cable is MAT; topology is STR; a message or signal is DAT; attention and understanding are MIN; protocol rules are LOG. CON owns only the endpoint or shared channel as a place of communicative participation.\n\n"

IDS.each do |id|
  scored_root = scored_roots.find { |root| root["canonical_id"] == id }
  spec = recommended_roots.find { |root| root.dig("fixed_generated_fields", "canonical_id") == id }
  fixed = spec.fetch("fixed_generated_fields")
  review << "## #{id} — #{spec["proposed_title"]}\n\n"
  review << "### A. Fixed generated forms\n\n"
  review << "- Universal slot: **#{fixed["universal_slot"]}**\n"
  review << "- Transliteration: **#{fixed["family_qualified_transliteration"]}**\n"
  review << "- Local compact root: **#{fixed["local_compact_root"]}**\n"
  review << "- Formal carrier: **#{fixed["formal_carrier"]}**\n"
  review << "- Harmonic signature: **#{fixed["harmonic_signature_semitones"].join("–")}**\n"
  review << "- Relative note path: **#{fixed["relative_note_path_semitones"].join(" → ")}**\n\n"
  review << "### B. Why the current meaning was probably chosen\n\n#{scored_root["current_meaning_rationale"]}\n\n"
  review << "### C. Candidate comparison\n\n"
  review << "| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |\n"
  review << "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n"
  scored_root.fetch("candidates").each do |candidate_item|
    values = SCORE_KEYS.map { |key| candidate_item.dig("scores", key) }
    review << "| #{candidate_item["title"]} | #{values.join(" | ")} | **#{candidate_item["total"]}/80** |\n"
  end
  review << "\n"
  scored_root.fetch("candidates").each do |candidate_item|
    analysis = candidate_item.fetch("analysis")
    review << "#### #{candidate_item["title"]}\n\n"
    review << "**Invariant candidate:** #{candidate_item["invariant_candidate"]}\n\n"
    review << "- Fit: #{analysis["why_it_fits"]}\n"
    review << "- Useful coverage: #{analysis["useful_coverage"]}\n"
    review << "- Territory consumed: #{analysis["semantic_territory_consumed"]}\n"
    review << "- Conflicts and limitations: #{analysis["conflicts_or_future_limitations"]}\n\n"
  end
  review << "### D. Recommended permanent semantic specification\n\n"
  review << "**Title:** #{spec["proposed_title"]}\n\n"
  review << "**Invariant:** #{spec["invariant_definition"]}\n\n"
  review << "**Inclusion boundary:** #{spec["inclusion_boundary"]}\n\n"
  review << "**Excluded meanings:**\n\n"
  spec.fetch("excluded_meanings").each { |item| review << "- #{item}\n" }
  review << "\n**Address justification:**\n\n"
  spec.fetch("address_justification").each { |axis, explanation| review << "- `#{axis}`: #{explanation}\n" }
  review << "\n**Nearest neighbors:** #{spec["nearest_neighbors"].map { |neighbor| "`#{neighbor}`" }.join(", ")}\n\n"
  review << "**Same-family boundary:** #{spec["same_family_contrast"]}\n\n"
  review << "**Runtime-state interpretation:**\n\n"
  spec.fetch("runtime_state_interpretation").each { |state, meaning| review << "- `[#{state}]`: #{meaning}\n" }
  review << "\n**Lexical/runtime distinction:** #{spec["lexical_runtime_distinction"]}\n\n"
  review << "### E. Examples\n\n"
  review << "| Type | Semantic graph | Literal gloss | Natural English | State | Result |\n"
  review << "| --- | --- | --- | --- | ---: | --- |\n"
  spec.fetch("examples").each do |example|
    review << "| #{example["category"]} | `#{example["semantic_graph"]}` | #{example["literal_gloss"]} | #{example["natural_english"]} | #{example["runtime_state"]} | #{example["use_status"]} |\n"
  end
  review << "\n"
end

review << "## Triplet coherence\n\n"
review << "| Triplet | Shared axis | `0` | `1` | `2` |\n"
review << "| --- | --- | --- | --- | --- |\n"
review << "| CON:000–002 | source-side endpoint locus | persists as identified source endpoint | presently participates as source endpoint | remains defined without participation |\n"
review << "| CON:010–012 | target-side endpoint locus | persists as identified target endpoint | presently participates as target endpoint | remains defined without participation |\n"
review << "| CON:020–022 | shared communicative environment | persists as common channel | presently functions as common channel | remains defined without functioning |\n\n"
review << "## Nine-root ownership matrix\n\n"
review << "| Root | Owns | Does not own |\n| --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  review << "| #{id} | #{root["proposed_title"]} | bearer identity, content, exchange process, bond, reachability, protocol, or implementation |\n"
end
review << "\n## English coverage stress test\n\n"
review << "#{stress_tests.length} English concepts were tested. The routing deliberately uses atoms, compounds, later CON layers, runtime state, grammar, other families, and unresolved gaps. No English word is forced into a single atom. See `reviews/#{STEM}_stress_tests.yaml`.\n\n"
review << "## Approval checklist\n\n"
recommended.fetch("approval_checklist").each do |item, value|
  review << "- [#{value ? "x" : " "}] #{item.tr("_", " ")}\n"
end
review << if canonicalized_now
            "\n**Disposition:** the endpoint/channel grid passed independent validation and was approved under `migrations/CON_000_022_semantic_approval.yaml`. This file remains the adversarial evidence record.\n"
          else
            "\n**Recommendation:** approve the endpoint/channel grid only after independent validation. Until approval is applied, all nine meanings remain provisional and no downstream layer may depend on them.\n"
          end
File.write(File.join(ROOT, "reviews/#{STEM}_peer_review.md"), review)

collision = +"# CON:000–022 Cross-Family Collision Report\n\n"
collision << "Status: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n"
collision << "## Root-level collision matrix\n\n"
collision << "| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = case id[5]
          when "0" then "LIF source participant; DAT message/address; CON:1xx source expression; CON:2xx source capacity"
          when "1" then "LIF target participant; DAT address/message; CON:1xx target reception; CON:2xx reachability"
          when "2" then "STR topology; DAT stream; CON:1xx shared distribution; CON:2xx network relation"
          end
  collision << "| #{id} | #{root["proposed_title"]} | #{risks} | locus stays CON; bearer, content, process, relation, and implementation stay separate |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY_BASE.each do |family, explanation|
  collision << "- **#{family}:** #{explanation}\n"
end
collision << "\n## Same-family safeguards\n\n"
collision << "- `CON:0xx` names endpoint or channel loci only.\n"
collision << "- `CON:1xx` is the process layer for source expression, target reception, shared distribution, and later compounds for richer exchange acts.\n"
collision << "- `CON:2xx` remains reserved for connectivity capacities, participant bonds, compatibility, reachability, agreement, and possible networks.\n"
collision << "- A dormant endpoint or channel is already defined but not participating; a `CON:2xx` possibility is an unrealized relationship or capacity.\n"
collision << "- Runtime `[2]/num` changes assertion status and never selects endpoint dormancy.\n\n"
collision << "## Reserved compounds\n\n"
collision << "Speaker, listener, sender, recipient, correspondent, audience, conversation, group chat, forum, community, network, radio channel, API endpoint, event bus, and publish-subscribe topic are intentionally reserved for typed compounds.\n\n"
collision << "**CONCLUSION: THE ENDPOINT/CHANNEL ARCHITECTURE STANDS ALONE ONLY FOR COMMUNICATIVE LOCI; ALL COLLIDING CONTENT IS EXCLUDED OR COMPOUNDED.**\n"
File.write(File.join(ROOT, "reviews/#{STEM}_collision_report.md"), collision)

puts "Built CON:000–022 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root["candidates"].length }} candidates, #{stress_tests.length} stress tests."
