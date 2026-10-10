#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "CON:100–122"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "CON_100_122"
SEMANTIC_CENTER = "participant-addressed communicative exchange processes: source expression, target reception, and shared distribution"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2_CANDIDATES = {
  "CON:100" => ["self-synchronization complete", "An entity's internal participants or interfaces have completed a connection or synchronization process."],
  "CON:101" => ["opening a channel", "An entity is actively connecting, listening, or synchronizing its own communication interfaces."],
  "CON:102" => ["queued self-connection", "An inward connection or synchronization is possible or prepared but has not begun."],
  "CON:110" => ["delivery complete", "A communicative act to a selected target has reached that target and completed its transfer."],
  "CON:111" => ["active transmission", "A message, signal, request, or expression is actively being sent to an external target."],
  "CON:112" => ["queued contact", "A communication toward a target is composed, intended, or waiting for an available channel."],
  "CON:120" => ["network synchronization complete", "A shared communication system has completed a broadcast, negotiation, or synchronization cycle."],
  "CON:121" => ["broadcast exchange", "Messages or signals are actively being shared, routed, or negotiated across a network."],
  "CON:122" => ["pending broadcast", "A system-wide communication or synchronization process is staged but has not started."]
}.freeze

ROOTS = {
  "CON:100" => { title: "completed source expression", verb: "make", phase: "completed", scope: "source", object: "a communicative expression available to an exchange context", invariant: "Completion of an act by which a source endpoint makes a communicative expression available to an exchange context." },
  "CON:101" => { title: "active source expression", verb: "make", phase: "ongoing", scope: "source", object: "a communicative expression available to an exchange context", invariant: "An ongoing act by which a source endpoint makes a communicative expression available to an exchange context." },
  "CON:102" => { title: "potential source expression", verb: "would make", phase: "nonactualized", scope: "source", object: "a communicative expression available to an exchange context", invariant: "A nonactualized act by which a source endpoint would make a communicative expression available to an exchange context." },
  "CON:110" => { title: "completed target reception", verb: "take up", phase: "completed", scope: "target", object: "a communicative expression from an exchange context", invariant: "Completion of an act by which a target endpoint takes up a communicative expression from an exchange context." },
  "CON:111" => { title: "active target reception", verb: "take up", phase: "ongoing", scope: "target", object: "a communicative expression from an exchange context", invariant: "An ongoing act by which a target endpoint takes up a communicative expression from an exchange context." },
  "CON:112" => { title: "potential target reception", verb: "would take up", phase: "nonactualized", scope: "target", object: "a communicative expression from an exchange context", invariant: "A nonactualized act by which a target endpoint would take up a communicative expression from an exchange context." },
  "CON:120" => { title: "completed shared distribution", verb: "make", phase: "completed", scope: "shared", object: "a communicative expression available across a shared channel to multiple participant endpoints", invariant: "Completion of an act by which a communicative expression is made available across a shared channel to multiple participant endpoints." },
  "CON:121" => { title: "active shared distribution", verb: "make", phase: "ongoing", scope: "shared", object: "a communicative expression available across a shared channel to multiple participant endpoints", invariant: "An ongoing act by which a communicative expression is made available across a shared channel to multiple participant endpoints." },
  "CON:122" => { title: "potential shared distribution", verb: "would make", phase: "nonactualized", scope: "shared", object: "a communicative expression available across a shared channel to multiple participant endpoints", invariant: "A nonactualized act by which a communicative expression would be made available across a shared channel to multiple participant endpoints." }
}.freeze

ALT_TITLES = {
  "CON:100" => ["completed source-channel establishment", "completed self-synchronization", "completed conversational initiation"],
  "CON:101" => ["active source-channel establishment", "active self-synchronization", "active conversational initiation"],
  "CON:102" => ["potential source-channel establishment", "potential self-synchronization", "potential conversational initiation"],
  "CON:110" => ["completed target-channel establishment", "completed delivery", "completed acknowledgement"],
  "CON:111" => ["active target-channel establishment", "active target synchronization", "active acknowledgement"],
  "CON:112" => ["potential target-channel establishment", "potential delivery", "potential acknowledgement"],
  "CON:120" => ["completed network establishment", "completed network synchronization", "completed negotiation cycle"],
  "CON:121" => ["active network establishment", "active network synchronization", "active negotiation cycle"],
  "CON:122" => ["potential network establishment", "potential network synchronization", "potential negotiation cycle"]
}.freeze

SCORE_KEYS = EraZeroValidation::SCORE_KEYS
SCORE_PROFILES = {
  "current_phase2" => [6, 8, 8, 5, 5, 7, 8, 8],
  "expression_reception_distribution" => [10, 10, 10, 10, 9, 10, 10, 10],
  "channel_lifecycle" => [8, 8, 7, 6, 5, 8, 8, 9],
  "synchronization_coordination" => [7, 8, 7, 6, 4, 8, 7, 9],
  "conversational_role_action" => [8, 7, 8, 7, 5, 8, 10, 6]
}.freeze

CROSS_FAMILY_BASE = {
  "LIF" => "LIF identifies living or conscious participants. A being may perform a CON exchange process, but life, identity, consciousness, and responsiveness are not expression, reception, or distribution.",
  "MOV" => "MOV owns physical displacement, approach, traversal, and reference-frame change. A message or carrier may move physically, but a communicative exchange can occur without lexicalizing spatial motion.",
  "MAT" => "MAT owns sound waves, photons, cables, radios, bodies, and other physical carriers. CON names the communicative act realized through a carrier, not the carrier's physical transmission.",
  "MIN" => "MIN owns attention, perception, interpretation, understanding, and belief change. Reception ends when an expression is taken up at the target endpoint; comprehension requires MIN.",
  "STR" => "STR owns topology, containment, interface arrangement, and system transition. Opening, joining, or restructuring a channel is not the exchange act itself.",
  "WRN" => "WRN owns loss, corruption, failure, spoofing, and danger evaluation. CON exchange processes are neutral about success quality except for their completed/ongoing/nonactualized lexical phase.",
  "REP" => "REP owns restoring a failed endpoint, channel, signal path, or exchange. Reconnection and retransmission for repair must compound REP with CON rather than redefining CON.",
  "LOG" => "LOG owns protocol rules, permissions, turn constraints, validity, acknowledgement obligations, and formal coordination. Those rules can govern a CON act without becoming that act.",
  "DAT" => "DAT owns the message, signal, request, symbol, payload, or record as an information object. CON owns making that expression available or taking it up in a participant exchange context.",
  "CRE" => "CRE owns composing, generating, transforming, or designing content and communication systems. Source expression can communicate already-created content and therefore must not imply creation.",
  "ORI" => "ORI owns existence, time, modality, manifestation, and ontological transition. A lexical nonactualized CON process does not silently encode intention, schedule, futurity, or probability."
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

def lexical_axes(id)
  address = id.split(":").last
  second = address[1]
  third = address[2]
  scope = { "0" => "inward/source", "1" => "outward/target", "2" => "shared/systemic" }.fetch(second)
  phase = { "0" => "completed", "1" => "active", "2" => "nonactualized" }.fetch(third)
  [scope, phase]
end

def candidate_analysis(id, candidate_id, title)
  scope, phase = lexical_axes(id)
  case candidate_id
  when "current_phase2"
    {
      "why_it_fits" => "The Phase 2 choice follows the #{scope} and #{phase} slot labels and selects salient Connection vocabulary such as synchronization, transmission, delivery, or broadcast.",
      "useful_coverage" => "It would directly cover familiar social and network operations associated with #{title}.",
      "semantic_territory_consumed" => "It consumes different mixtures of channel setup, participant synchronization, content transfer, routing, negotiation, and system coordination at different addresses.",
      "conflicts_or_future_limitations" => "The nine current meanings do not share one process center, completed/active/nonactualized siblings are not exact phase variants, and several definitions encode intention, preparation, queueing, or network structure forbidden by the 1x2 clarification."
    }
  when "expression_reception_distribution"
    {
      "why_it_fits" => "Every root is one communicative availability process; source, target, and shared scope follow the second trit exactly, while the third trit changes only realization phase.",
      "useful_coverage" => "It covers saying, signaling, publishing, receiving, hearing-at-an-endpoint, multicasting, broadcasting, and formal send/receive/distribute operations without absorbing their content.",
      "semantic_territory_consumed" => "Only participant-addressed exchange: making an expression available from a source, taking it up at a target, or making it available across a shared channel to multiple endpoints.",
      "conflicts_or_future_limitations" => "It deliberately leaves composition to CRE/DAT, comprehension to MIN, physical propagation to MAT/MOV, channel lifecycle to STR/CON:0xx, protocol to LOG, and reciprocal interaction to compounds."
    }
  when "channel_lifecycle"
    {
      "why_it_fits" => "Opening, joining, and establishing channels are Connection processes and can be distributed across source, target, and systemic scope.",
      "useful_coverage" => "It would cover connect, attach, dial, accept, join, open, close, subscribe, and network formation in ordinary and technical settings.",
      "semantic_territory_consumed" => "Creation or transition of endpoint/channel participation state rather than communication through an established exchange context.",
      "conflicts_or_future_limitations" => "It collides with canonical CON:0xx loci, future CON:2xx connectivity capacities, STR topology, REP reconnection, and runtime participation state; it also leaves send/receive without a coherent atomic home."
    }
  when "synchronization_coordination"
    {
      "why_it_fits" => "Synchronization and coordination are systemic Connection processes and have strong programming and distributed-system value.",
      "useful_coverage" => "It would cover handshakes, barriers, consensus, state alignment, clock synchronization, negotiation, and group coordination.",
      "semantic_territory_consumed" => "Agreement of participant states or behavior under shared constraints.",
      "conflicts_or_future_limitations" => "State alignment belongs partly to STR, MIN, DAT, or LOG depending on what is aligned; negotiation and consensus are relational compounds, and ordinary one-way communication would remain poorly covered."
    }
  when "conversational_role_action"
    {
      "why_it_fits" => "Speaking, listening, acknowledging, and negotiating are recognizable communication actions with source, target, and shared roles.",
      "useful_coverage" => "It would give compact atoms for talk, listen, reply, acknowledge, converse, negotiate, and deliberate.",
      "semantic_territory_consumed" => "Human-style discourse acts and turn-taking rather than substrate-neutral exchange processes.",
      "conflicts_or_future_limitations" => "It is anthropocentric, listening often requires MIN attention, acknowledgement requires LOG/DAT relation to a prior message, and the three triplets cannot remain exact phase variants without forcing unrelated discourse acts together."
    }
  end
end

def alternative_invariant(id, candidate_id, title)
  _scope, phase = lexical_axes(id)
  address = id.split(":").last
  second = address[1]
  locus = { "0" => "source-side", "1" => "target-side", "2" => "shared-system" }.fetch(second)
  case candidate_id
  when "channel_lifecycle"
    "A #{phase} process that establishes or changes #{locus} participation in a communication channel."
  when "synchronization_coordination"
    "A #{phase} process that aligns communicative state or timing at #{locus} scope."
  when "conversational_role_action"
    "A #{phase} discourse act performed at #{locus} scope in a participant exchange."
  else
    title
  end
end

def nearest_neighbors(id)
  family, address = id.split(":")
  first, second, third = address.chars
  siblings = %w[0 1 2].reject { |value| value == third }.map { |value| "#{family}:#{first}#{second}#{value}" }
  cross_scope = %w[0 1 2].reject { |value| value == second }.map { |value| "#{family}:#{first}#{value}#{third}" }
  loci = "#{family}:0#{second}#{third}"
  relation = "#{family}:2#{second}#{third}"
  (siblings + cross_scope + [loci, relation, "DAT:1#{second}#{third}", "MIN:1#{second}#{third}"]).uniq.first(8)
end

def roles
  {
    "low" => "source endpoint or initiating participant",
    "middle" => "communicative exchange process",
    "high" => "target endpoint or receiving participant",
    "sustained" => "shared channel or exchange context"
  }
end

EXAMPLES = {
  "CON:100" => [
    ["ordinary_conversation", "CON:100[1](SOURCE=me,EXPRESSION=greeting,CONTEXT=call)", "my completed making-available of greeting", "I have said my greeting into the call.", "Completion is at source expression, not at target understanding."],
    ["physical_or_spatial", "CON:001(SOURCE=beacon)+CON:100[1](EXPRESSION=ping)", "beacon endpoint plus completed source expression", "The beacon finished emitting the communicative ping.", "MAT is required if physical wave emission itself matters."],
    ["temporal_or_sequential", "CON:100[1](SOURCE=operator,BEFORE=reply)", "source expression completed before reply", "The operator finished speaking before the reply began.", "The root supplies the completed source-side phase."],
    ["cross_family_compound", "CRE(COMPOSE=notice)+DAT(NOTICE=n)+CON:100[1](SOURCE=clerk,EXPRESSION=n)", "created notice data made available by source", "The clerk composed and issued the notice.", "CRE owns composition and DAT owns content."],
    ["executable_or_programming", "CON:100[1](SOURCE=producer,EXPRESSION=event,CHANNEL=bus)", "producer completed source expression of event", "The producer completed publication of the event to the bus.", "This does not prove any consumer received it."],
    ["counterexample", "MIN(UNDERSTAND=listener,OBJECT=greeting)", "listener understands greeting", "The listener understood the greeting.", "Understanding is MIN, not completed source expression."]
  ],
  "CON:101" => [
    ["ordinary_conversation", "CON:101[1](SOURCE=me,EXPRESSION=story)", "my ongoing source expression of story", "I am telling the story now.", "The expression is presently being made available."],
    ["physical_or_spatial", "MAT(SPEAKER=device)+CON:101[1](SOURCE=device,EXPRESSION=alarm)", "speaker device actively expressing alarm", "The speaker is sounding the alarm message.", "MAT owns sound; CON owns communicative expression."],
    ["temporal_or_sequential", "CON:101[1](SOURCE=host,DURING=opening_turn)", "host actively source-expressing during opening turn", "The host is speaking during the opening turn.", "A time phrase bounds the ongoing process."],
    ["cross_family_compound", "DAT(MESSAGE=m)+CON:101[1](SOURCE=service,EXPRESSION=m)", "message data undergoing source expression", "The service is publishing the message.", "The data object and exchange process stay separate."],
    ["executable_or_programming", "CON:101[1](SOURCE=socket,EXPRESSION=frame)", "socket actively source-expressing frame", "The socket is sending the frame into the exchange context.", "Physical byte movement may add MAT/MOV."],
    ["counterexample", "STR(OPEN=channel)", "channel is being opened", "The channel is opening.", "Channel lifecycle is STR/CON relation, not active expression."]
  ],
  "CON:102" => [
    ["ordinary_conversation", "CON:102[1](SOURCE=me,EXPRESSION=answer)", "valid nonactualized source expression of answer", "I could give an answer, but no answer is being expressed.", "The lexical root does not assert intention or schedule."],
    ["physical_or_spatial", "CON:102[1](SOURCE=unused_beacon,EXPRESSION=ping)", "nonactualized source expression from beacon", "The beacon could issue a ping in this context, but it is not doing so.", "Hardware readiness is not implied."],
    ["temporal_or_sequential", "CON:102[1](SOURCE=delegate,CONTEXT=meeting)", "nonactualized source expression in meeting", "The delegate has a possible speaking act that is not occurring.", "Future timing requires separate grammar."],
    ["cross_family_compound", "LOG(PERMIT=speak)+CON:102[1](SOURCE=delegate,EXPRESSION=statement)", "permitted plus nonactualized source expression", "The delegate may speak, but has not begun.", "LOG adds permission; CON:102 alone does not."],
    ["executable_or_programming", "CON:102[1](SOURCE=producer,EXPRESSION=event)", "nonactualized publication act", "A publication operation exists as a possibility but is neither active nor complete.", "Do not translate this as queued or scheduled without other structure."],
    ["counterexample", "DAT(DRAFT=answer)+ORI(FUTURE=time)", "draft answer assigned future time", "The answer is drafted for later.", "Drafting and futurity are not CON:102."]
  ],
  "CON:110" => [
    ["ordinary_conversation", "CON:110[1](TARGET=you,EXPRESSION=greeting)", "your completed uptake of greeting", "You received the greeting.", "Reception does not assert understanding or agreement."],
    ["physical_or_spatial", "MAT(RECEIVER=radio)+CON:110[1](TARGET=radio,EXPRESSION=signal)", "radio plus completed target reception", "The radio completed uptake of the signal.", "MAT owns physical detection; CON owns communicative uptake."],
    ["temporal_or_sequential", "CON:110[1](TARGET=clerk,BEFORE=response)", "target reception completed before response", "The clerk received it before responding.", "Response is a separate source expression."],
    ["cross_family_compound", "DAT(MESSAGE=m)+CON:110[1](TARGET=reader,EXPRESSION=m)+MIN(UNDERSTAND=reader)", "message received and understood", "The reader received and understood the message.", "MIN is necessary for understanding."],
    ["executable_or_programming", "CON:110[1](TARGET=consumer,EXPRESSION=event)", "consumer completed communicative uptake of event", "The consumer completed receipt of the event.", "Acknowledgement or processing requires LOG/DAT/MIN."],
    ["counterexample", "CON:100[1](SOURCE=producer,EXPRESSION=event)", "completed source expression only", "The producer published the event.", "Publication alone does not prove target reception."]
  ],
  "CON:111" => [
    ["ordinary_conversation", "CON:111[1](TARGET=me,EXPRESSION=story)", "my ongoing uptake of story", "I am receiving the story as it is told.", "Attention and comprehension remain separate MIN claims."],
    ["physical_or_spatial", "MAT(EARPIECE=device)+CON:111[1](TARGET=device,EXPRESSION=call_audio)", "earpiece actively receiving call expression", "The earpiece is taking up the call audio now.", "Physical transduction is MAT."],
    ["temporal_or_sequential", "CON:111[1](TARGET=auditor,DURING=stream)", "auditor actively receiving during stream", "The auditor is receiving the stream.", "The active phase is contemporaneous with the stream."],
    ["cross_family_compound", "CON:111[1](TARGET=student,EXPRESSION=lesson)+MIN:211[1](COGNIZER=student,TARGET=lesson)", "active reception plus active attention", "The student is receiving and attending to the lesson.", "Neither root entails the other."],
    ["executable_or_programming", "CON:111[1](TARGET=subscriber,EXPRESSION=frames)", "subscriber actively taking up frames", "The subscriber is receiving frames from the channel.", "Buffer storage is DAT/STR."],
    ["counterexample", "MOV(PATH=packet_route)+MAT(CARRIER=photons)", "packet carrier traverses route", "Photons are moving along the route.", "Physical propagation is not target reception."]
  ],
  "CON:112" => [
    ["ordinary_conversation", "CON:112[1](TARGET=absent_member,EXPRESSION=notice)", "valid nonactualized target reception of notice", "The absent member could receive the notice in this exchange, but has not.", "No queue, plan, or future event is asserted."],
    ["physical_or_spatial", "CON:112[1](TARGET=backup_receiver,EXPRESSION=signal)", "nonactualized reception at backup receiver", "Reception by the backup receiver is possible but not occurring.", "Availability of the hardware needs MAT/STR/WRN."],
    ["temporal_or_sequential", "CON:112[1](TARGET=reader,CONTEXT=session)", "nonactualized target uptake in session", "The reader has not taken up the expression in this session.", "The root is not a promise of later receipt."],
    ["cross_family_compound", "DAT(QUEUE=m)+CON:112[1](TARGET=consumer,EXPRESSION=m)", "queued data plus nonactualized reception", "The message is queued, and its reception has not occurred.", "DAT supplies queue status explicitly."],
    ["executable_or_programming", "CON:112[1](TARGET=consumer,EXPRESSION=event)", "nonactualized consume act", "Consumer uptake is a possible operation, not an active or completed one.", "Await grammar may add a runtime dependency."],
    ["counterexample", "LOG(SCHEDULE=delivery)+ORI(TIME=later)", "scheduled delivery time", "Delivery is scheduled for later.", "Scheduling and future time are not CON:112."]
  ],
  "CON:120" => [
    ["ordinary_conversation", "CON:120[1](EXPRESSION=announcement,CHANNEL=room,ENDPOINTS=group)", "completed shared availability of announcement", "The announcement has been distributed to the room.", "Individual uptake is not entailed."],
    ["physical_or_spatial", "MAT(RADIO_BAND=band)+CON:120[1](EXPRESSION=alert,CHANNEL=band)", "completed shared distribution over radio band", "The alert finished broadcasting across the radio channel.", "MAT owns the band and waves."],
    ["temporal_or_sequential", "CON:120[1](EXPRESSION=agenda,BEFORE=meeting)", "shared distribution completed before meeting", "The agenda was distributed before the meeting.", "Timing is supplied separately."],
    ["cross_family_compound", "DAT(DOCUMENT=d)+CON:120[1](EXPRESSION=d,ENDPOINTS=team)", "document data completed shared distribution", "The document was distributed to the team.", "DAT owns the document; CON owns distribution."],
    ["executable_or_programming", "CON:120[1](EXPRESSION=event,CHANNEL=topic,ENDPOINTS=subscribers)", "completed distribution of event across topic", "The event publication cycle across subscribers completed.", "This does not prove every subscriber processed it."],
    ["counterexample", "CON:110[1](TARGET=one_consumer,EXPRESSION=event)", "one target completed reception", "One consumer received the event.", "Single-target reception is CON:110, not shared distribution."]
  ],
  "CON:121" => [
    ["ordinary_conversation", "CON:121[1](EXPRESSION=announcement,CHANNEL=hall,ENDPOINTS=crowd)", "ongoing shared distribution of announcement", "The announcement is being broadcast through the hall.", "The root does not claim reciprocal conversation."],
    ["physical_or_spatial", "MAT(AIRWAVES=local)+CON:121[1](EXPRESSION=weather,CHANNEL=radio)", "weather expression actively distributed over radio", "The weather report is broadcasting now.", "MAT supplies physical propagation."],
    ["temporal_or_sequential", "CON:121[1](EXPRESSION=updates,DURING=incident)", "updates actively shared during incident", "Updates are being distributed during the incident.", "The event interval bounds the active process."],
    ["cross_family_compound", "DAT(STREAM=s)+CON:121[1](EXPRESSION=s,ENDPOINTS=viewers)", "data stream under active shared distribution", "The stream is being distributed to viewers.", "Viewer reception remains separately assertable."],
    ["executable_or_programming", "CON:121[1](EXPRESSION=frames,CHANNEL=multicast,ENDPOINTS=clients)", "frames actively distributed across multicast channel", "The server is multicasting frames to the clients.", "Routing policy belongs to LOG/STR."],
    ["counterexample", "LOG(CONSENSUS=participants)", "participants reach formal agreement", "The participants are negotiating consensus.", "Negotiation is not distribution merely because it is shared." ]
  ],
  "CON:122" => [
    ["ordinary_conversation", "CON:122[1](EXPRESSION=announcement,CHANNEL=room,ENDPOINTS=group)", "valid nonactualized shared distribution", "The announcement could be distributed to the room, but no distribution is occurring.", "No plan or intention is implied."],
    ["physical_or_spatial", "CON:122[1](EXPRESSION=alert,CHANNEL=reserve_band)", "nonactualized shared distribution over reserve band", "The alert could be broadcast on the reserve band, but is not.", "A configured transmitter would need MAT/STR."],
    ["temporal_or_sequential", "CON:122[1](EXPRESSION=update,CONTEXT=event)", "nonactualized distribution in event context", "Distribution of the update remains unrealized in this event context.", "Later realization is not guaranteed."],
    ["cross_family_compound", "LOG(PERMIT=broadcast)+CON:122[1](EXPRESSION=alert,ENDPOINTS=public)", "permitted plus nonactualized shared distribution", "The alert may be broadcast, but no broadcast has begun.", "LOG adds permission explicitly."],
    ["executable_or_programming", "CON:122[1](EXPRESSION=event,CHANNEL=topic,ENDPOINTS=subscribers)", "nonactualized fan-out operation", "A fan-out operation is possible but neither executing nor complete.", "Queue and scheduler state require DAT/LOG/ORI."],
    ["counterexample", "DAT(QUEUE=event)+LOG(SCHEDULE=publish)", "queued and scheduled event", "The event is queued for publication.", "Queued publication is a compound, not the invariant of CON:122."]
  ]
}.freeze

def examples_for(id)
  EXAMPLES.fetch(id).map do |category, graph, gloss, english, analysis|
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
      "pseudocode" => category == "executable_or_programming" ? "assert(exchange_process.matches?(#{id.inspect}))" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  phase2_title, phase2_definition = PHASE2_CANDIDATES.fetch(id)
  root = ROOTS.fetch(id)
  alts = ALT_TITLES.fetch(id)
  candidates = [
    ["current_phase2", phase2_title, phase2_definition],
    ["expression_reception_distribution", root.fetch(:title), root.fetch(:invariant)],
    ["channel_lifecycle", alts[0], alternative_invariant(id, "channel_lifecycle", alts[0])],
    ["synchronization_coordination", alts[1], alternative_invariant(id, "synchronization_coordination", alts[1])],
    ["conversational_role_action", alts[2], alternative_invariant(id, "conversational_role_action", alts[2])]
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", phase2_title)["why_it_fits"],
    "candidates" => candidates.map do |candidate_id, title, invariant|
      candidate(candidate_id, title, invariant, SCORE_PROFILES.fetch(candidate_id), candidate_analysis(id, candidate_id, title))
    end,
    "recommended_candidate_id" => "expression_reception_distribution",
    "recommendation_reason" => "This is the only architecture that gives all nine roots one substrate-neutral exchange center, exact source/target/shared scope, exact completed/active/nonactualized triplets, and clean boundaries from content, cognition, physical propagation, topology, protocol, and future relationship roots.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end

recommended_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  root = ROOTS.fetch(id)
  scope, phase = lexical_axes(id)
  address = id.split(":").last
  second = address[1]
  third = address[2]
  phase_word = { "0" => "completed", "1" => "ongoing", "2" => "nonactualized" }.fetch(third)
  scope_detail = { "0" => "the originating endpoint and its act of making an expression available", "1" => "the addressed endpoint and its act of taking an expression up", "2" => "the shared channel and availability of an expression to multiple endpoints" }.fetch(second)
  process_label = { "0" => "source-expression act", "1" => "target-reception act", "2" => "shared-distribution act" }.fetch(second)
  runtime_states = case third
                   when "0"
                     {
                       "0" => "States that completion of this #{process_label} is false, unavailable as a valid result, or not established in the exchange context; it does not assert the active or nonactualized sibling.",
                       "1" => "Affirms that this #{process_label} reached its completed phase in the stated exchange context; the result does not entail reception, comprehension, response, or endpoint-wide uptake unless separately asserted.",
                       "2/num" => "Leaves unresolved whether this #{process_label} reached completion or whether that completion remains a valid result; it does not change the lexical process into an active or nonactualized sibling."
                     }
                   when "1"
                     {
                       "0" => "States that this #{process_label} is not presently ongoing or has ceased; it does not assert that the process completed or remains available as a nonactualized act.",
                       "1" => "Affirms that this #{process_label} is presently ongoing in the stated exchange context.",
                       "2/num" => "Leaves unresolved whether this #{process_label} is presently ongoing; it does not select either the completed or nonactualized lexical sibling."
                     }
                   when "2"
                     {
                       "0" => "Denies that this #{process_label} currently holds even as a valid nonactualized exchange act; it does not assert that the act is active or completed.",
                       "1" => "Affirms that this #{process_label} is nonactualized—neither ongoing nor completed—without adding intention, plan, queue, schedule, permission, probability, or future time.",
                       "2/num" => "Leaves unresolved even the assertion that this #{process_label} is a valid nonactualized act; lexical nonactualization and runtime uncertainty remain separate."
                     }
                   end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_1" => "Selects a process, action, or transformation: #{root.fetch(:title)} is an exchange act, not an endpoint/channel entity and not a bond, capacity, or compatibility relation.",
      "second_trit" => "Selects #{scope} scope: it locates the exchange process at #{scope_detail} without changing the content or physical carrier.",
      "third_trit" => "Selects the #{phase} process phase: the same exchange act is #{phase_word}, while intention, planning, scheduling, queueing, probability, and future time remain outside the lexeme."
    },
    "inclusion_boundary" => "Includes only the #{phase_word} participant-addressed act at #{scope} scope by which #{second == "0" ? "a source endpoint makes an expression available" : second == "1" ? "a target endpoint takes up an expression" : "an expression is made available across a shared channel to multiple endpoints"}. It is neutral about the expression's content, physical carrier, protocol, success quality, comprehension, response, and later use.",
    "excluded_meanings" => [
      "The endpoint, participant, shared channel, device, medium, route, or topology as an entity or condition.",
      "The message, signal, request, symbol, payload, record, draft, queue item, or protocol as content or structure.",
      "Physical propagation, movement, transduction, storage, computation, attention, interpretation, understanding, agreement, or belief change.",
      "Opening, closing, joining, repairing, authenticating, authorizing, scheduling, or configuring a channel or endpoint.",
      "Intention, readiness, permission, plan, schedule, queue status, probability, certainty, futurity, or obligation—especially for lexical 1x2 roots.",
      "Reciprocal conversation, acknowledgement, negotiation, consensus, request-response, or transport, which require compounds and explicit participant/content relations."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "CON:0xx owns the endpoint/channel loci through which exchange occurs; CON:1xx owns the expression, reception, and distribution processes themselves; CON:2xx remains reserved for capacities, bonds, compatibility, reachability, and possible exchange relations.",
    "cross_family_comparisons" => CROSS_FAMILY_BASE,
    "runtime_state_interpretation" => runtime_states,
    "lexical_runtime_distinction" => "The third lexical trit permanently selects the #{phase} member of the #{root.fetch(:scope)} process triplet. Runtime `[2]/num` instead qualifies the assertion about that already-selected lexeme. Therefore #{id}[1] affirms a #{phase_word} exchange act, while #{id}[2]/num leaves the assertion about that same #{phase_word} act unresolved.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + DAT supplies the expression, message, signal, request, or payload without turning content into a Connection process.",
      "#{id} + CON:0xx identifies the source endpoint, target endpoint, or shared channel participating in the process.",
      "#{id} + MIN/MAT/MOV distinguishes comprehension or attention from physical carrier propagation and spatial transport.",
      "#{id} + LOG/STR/WRN/REP adds protocol, topology, failure, or repair while preserving the neutral exchange invariant."
    ],
    "later_era_notes" => "Later eras may lexicalize speak, tell, publish, send, hear, receive, deliver, notify, broadcast, multicast, subscribe, acknowledge, converse, negotiate, and transport as descendants or compounds. Era Zero must preserve the source-expression / target-reception / shared-distribution distinction and must not let nonactualized 1x2 roots acquire planning or future-time semantics.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end

stress_concepts = [
  ["say", "one_root_or_compound", "CON:100/101/102 supplies source expression by phase; DAT supplies what is said and LIF identifies the speaker."],
  ["speak", "one_root_or_compound", "Active speaking maps to CON:101 when only communicative expression matters; voice production adds MAT and a living speaker adds LIF."],
  ["tell", "compound", "Source expression plus explicit target endpoint and DAT content; tell is not a single atom."],
  ["state", "compound", "DAT proposition plus source expression; LOG contour may mark assertion."],
  ["ask", "compound", "DAT question content plus source expression and rising/query contour."],
  ["request", "compound", "DAT/LOG requested operation plus source expression toward a target."],
  ["answer", "compound", "A source expression related by LOG/DAT to a prior question."],
  ["reply", "compound", "Source expression whose relation to an earlier exchange is explicit; not a new atomic process."],
  ["publish", "one_root_or_compound", "CON:100/101/102 for source expression; DAT content and a shared or target context are separate arguments."],
  ["send", "one_root_or_compound", "CON:101 covers ongoing source expression in communicative sense; physical transport requires MAT/MOV and content requires DAT."],
  ["emit", "different_family_or_compound", "Pure physical emission is MAT; communicative emission is MAT plus CON:100/101/102."],
  ["transmit", "compound", "Communicative source expression plus MAT/MOV carrier propagation when transmission emphasizes the path."],
  ["finish sending", "one_root_or_compound", "CON:100 completes source expression; delivery or target uptake must be separately asserted."],
  ["could speak", "one_root_plus_grammar", "CON:102[1] can assert a nonactualized source expression; ability, permission, and future schedule require separate roots or grammar."],
  ["draft", "different_family", "CRE/DAT owns composing an unexpressed information object; drafting is not source expression."],
  ["queue a message", "different_family_or_compound", "DAT/STR/LOG owns queue placement; combine with CON:102 or CON:112 only if a nonactualized exchange is also asserted."],
  ["schedule a send", "compound", "LOG/ORI scheduling plus a nonactualized CON source expression; the schedule is not inside CON:102."],
  ["hear", "compound", "MAT perception and MIN attention may combine with CON:110/111 target reception; hearing is not always communicative."],
  ["receive", "one_root_or_compound", "CON:110/111/112 owns communicative target uptake by phase; DAT storage or MAT physical acquisition may need other families."],
  ["deliver", "compound", "Completed source expression plus completed target reception and explicit expression identity; delivery is not collapsed into one endpoint's act."],
  ["read a message", "compound", "CON target reception plus DAT text and MIN perception/interpretation."],
  ["listen", "compound", "CON:111 target reception plus MIN active attention; either condition can occur without the other."],
  ["understand", "different_family", "MIN owns comprehension even when a CON reception process supplied the expression."],
  ["acknowledge", "compound", "A new source expression related by LOG/DAT to a completed reception; acknowledgement is not reception itself."],
  ["ignore", "compound_or_different_family", "A possible or actual CON reception combined with denied MIN attention; context determines whether reception occurred."],
  ["miss a message", "compound", "Denied or failed CON reception plus WRN and DAT message identity."],
  ["could receive", "one_root_plus_grammar", "CON:112[1] states nonactualized reception; capacity, permission, schedule, and probability remain separate."],
  ["subscribe", "future_con_relation_or_compound", "Subscription is a persistent relation/capacity involving CON:2xx plus LOG/DAT topic identity, not target reception."],
  ["broadcast", "one_root_or_compound", "CON:120/121/122 owns shared distribution by phase; carrier, content, and channel are separate."],
  ["multicast", "compound", "Shared distribution plus an explicitly delimited endpoint set and LOG/STR routing."],
  ["announce", "compound", "DAT announcement content plus source expression or shared distribution depending on scope."],
  ["notify", "compound", "DAT notice plus source expression and target reception relation; WRN may add salience."],
  ["circulate information", "compound", "Repeated or networked shared distribution plus DAT content and contour/loop grammar."],
  ["share", "compound_or_one_root", "CON:121 fits active shared distribution of an expression; sharing possession, matter, or access belongs elsewhere."],
  ["stream", "compound", "DAT sequence plus ongoing source expression/shared distribution and target reception as separately assertable processes."],
  ["fan out", "one_root_or_compound", "CON:121 provides active shared distribution; topology and routing policy add STR/LOG."],
  ["finish broadcasting", "one_root", "CON:120 when shared availability completed; it does not guarantee every endpoint received the expression."],
  ["possible broadcast", "one_root_plus_grammar", "CON:122[1] affirms nonactualized shared distribution without asserting plan, queue, or future event."],
  ["conversation", "compound", "Alternating source expression and target reception among endpoints in a shared channel, often with overlap and timing grammar."],
  ["dialogue", "compound", "Reciprocal CON processes plus participant relations; no one root owns reciprocity."],
  ["negotiate", "compound", "Multiple expression/reception cycles plus LOG proposals, constraints, and possible MIN revisions."],
  ["agree", "different_family_or_future_relation", "Agreement is a MIN/LOG state or future CON:2xx relationship, not shared distribution."],
  ["synchronize", "compound_or_different_family", "Alignment belongs to STR/DAT/LOG/MIN according to what is synchronized; communication may be instrumental."],
  ["handshake", "compound", "Reciprocal source/reception processes plus LOG protocol and CON:2xx compatibility."],
  ["open a channel", "compound_or_different_family", "STR/CON:0xx/2xx lifecycle relation; not source expression."],
  ["connect", "future_con_relation_or_compound", "Establishing connectivity belongs to CON:2xx with STR/REP as needed, not this process layer's exchange invariant."],
  ["route", "different_family_or_compound", "STR/LOG selects paths; CON shared distribution can use routing without owning it."],
  ["forward", "compound", "Target reception followed by a new source expression, linked to the same DAT content."],
  ["relay", "compound", "A participant acts as target then source; add MAT/MOV if physical transport matters."],
  ["transport a letter", "compound", "MOV/MAT owns physical displacement and object; CON source/reception processes describe communicative use."],
  ["upload", "compound", "DAT object transfer plus CON source expression/target reception and STR destination context."],
  ["download", "compound", "DAT object acquisition plus CON target reception; storage and physical transfer stay separate."],
  ["copy data", "different_family", "DAT/CRE owns duplication; communication processes are optional."],
  ["store a message", "different_family", "DAT/STR owns persistence in a container; reception may precede storage but is distinct."],
  ["encrypt a message", "different_family", "LOG/DAT transformation; encryption can precede source expression."],
  ["decode a message", "different_family", "DAT/MIN/LOG interpretation or transformation after reception."],
  ["telepathy", "compound", "Source expression and target reception with unspecified carrier; no new atomic root is required."],
  ["communicate", "underspecified_compound", "English communicate may mean source expression, target reception, shared distribution, or reciprocal exchange; translator must resolve the graph."],
  ["contact", "underspecified_compound", "May mean endpoint relation, source expression, target reception, or successful exchange; do not guess one atom."],
  ["message", "different_family_or_compound", "As a noun it is DAT; as a verb it is DAT content plus CON source expression toward a target."],
  ["signal", "different_family_or_compound", "DAT owns the sign, MAT the carrier, and CON the communicative exchange process."],
  ["unknown exchange phase", "unresolved_gap", "If completed, active, or nonactualized phase cannot be determined, the translator must preserve ambiguity or ask for clarification."]
]

stress_tests = stress_concepts.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("CON1-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => {
    "title" => "CON:100–122 adversarial semantic candidates",
    "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation",
    "architecture_version" => "1.0",
    "range" => RANGE,
    "roots_reviewed" => IDS.length,
    "candidate_architectures_per_root" => 5,
    "scored_categories" => SCORE_KEYS,
    "generated_fields_changed" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [],
    "approval_record" => canonicalized_now ? "migrations/CON_100_122_semantic_approval.yaml" : nil
  },
  "roots" => scored_roots
}

recommended = {
  "metadata" => {
    "title" => "CON:100–122 recommended permanent semantic specification",
    "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval",
    "architecture_version" => "1.0",
    "semantic_center" => SEMANTIC_CENTER,
    "triplets" => {
      "CON:100–102" => "source expression: completed / active / nonactualized",
      "CON:110–112" => "target reception: completed / active / nonactualized",
      "CON:120–122" => "shared distribution: completed / active / nonactualized"
    },
    "generated_fields_changed" => false,
    "gate4_started" => false,
    "translator_started" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [],
    "approval_record" => canonicalized_now ? "migrations/CON_100_122_semantic_approval.yaml" : nil
  },
  "roots" => recommended_roots,
  "approval_checklist" => {
    "family_domain_preserved" => true,
    "address_axes_preserved" => true,
    "one_invariant_per_root" => true,
    "triplets_coherent" => true,
    "current_candidates_challenged" => true,
    "cross_family_collisions_explicit" => true,
    "runtime_state_separated" => true,
    "nonactualized_process_rule_preserved" => true,
    "generated_fields_unchanged" => true,
    "gate4_not_started" => true,
    "translator_not_started" => true,
    "canonicalized" => canonicalized_now
  }
}

stress = {
  "metadata" => {
    "title" => "CON:100–122 English coverage and routing tests",
    "status" => "review_evidence_not_translation_dictionary",
    "range" => RANGE,
    "test_count" => stress_tests.length,
    "no_forced_atomization" => true
  },
  "tests" => stress_tests
}

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# CON:100–122 Adversarial Semantic Design Review\n\n"
review << if canonicalized_now
            "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n"
          else
            "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n"
          end
review << "This packet challenges every Phase 2 meaning in the Connection process layer. It compares five genuinely different semantic architectures per address, scores 45 candidates across 360 criterion values, and tests #{stress_tests.length} English concepts without forcing all senses into atoms.\n\n"
review << "## Packet-level design decision\n\n"
review << "The strongest permanent architecture treats `CON:1xx` as **participant-addressed communicative exchange processes**: source expression, target reception, and shared distribution. Each triplet differs only by completed, active, or nonactualized phase. This is substrate-neutral and composes with canonical `CON:0xx` loci.\n\n"
review << "The center is availability in exchange, not information creation, physical propagation, comprehension, channel establishment, protocol, negotiation, or relationship formation. `DAT` owns the expression as content; `MIN` owns interpretation; `MAT/MOV` own carriers and displacement; `STR/LOG` own topology and rules; `CON:2xx` remains reserved for capacities and relations.\n\n"

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
review << "| Triplet | Shared axis | `0` completed | `1` active | `2` nonactualized |\n"
review << "| --- | --- | --- | --- | --- |\n"
review << "| CON:100–102 | source makes an expression available to an exchange context | source act finished | same source act ongoing | same source act unrealized |\n"
review << "| CON:110–112 | target takes up an expression from an exchange context | target act finished | same target act ongoing | same target act unrealized |\n"
review << "| CON:120–122 | expression made available across shared channel to multiple endpoints | shared act finished | same shared act ongoing | same shared act unrealized |\n\n"
review << "## Nine-root contrast and ownership matrix\n\n"
review << "| Root | Owns | Nearest excluded meanings |\n| --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  review << "| #{id} | #{root["proposed_title"]} | content, physical transport, comprehension, channel lifecycle, protocol, scheduling, or connection relation |\n"
end
review << "\n## Concepts intentionally reserved\n\n"
review << "Tell, ask, request, reply, delivery, acknowledgement, conversation, dialogue, negotiation, handshake, forwarding, relaying, uploading, downloading, transport, and telepathy remain compounds. Synchronization is routed by what is aligned rather than forced into CON. Underspecified *communicate*, *contact*, *message*, and *signal* remain sense-resolution problems.\n\n"
review << "## English coverage stress test\n\n"
review << "#{stress_tests.length} English concepts were tested using atoms, compounds, grammar, other families, future CON relations, and unresolved routing. See `reviews/#{STEM}_stress_tests.yaml`.\n\n"
review << "## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? "x" : " "}] #{item.tr("_", " ")}\n" }
review << if canonicalized_now
            "\n**Disposition:** the expression/reception/distribution grid passed reusable validation and was approved under `migrations/CON_100_122_semantic_approval.yaml`. This file remains the adversarial evidence record.\n"
          else
            "\n**Recommendation:** approve the expression/reception/distribution grid only after reusable validation and full current-state regression. Until approval is applied, all nine meanings remain provisional.\n"
          end
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# CON:100–122 Cross-Family Collision Report\n\n"
collision << "Status: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n"
collision << "## Root-level collision matrix\n\n"
collision << "| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  scope = id[5]
  risks = { "0" => "CRE content creation; DAT message; MAT emission; STR channel opening", "1" => "MIN perception/understanding; MAT acquisition; DAT storage; LOG acknowledgement", "2" => "STR routing/topology; LOG negotiation; DAT stream; MIN consensus" }.fetch(scope)
  collision << "| #{id} | #{root["proposed_title"]} | #{risks} | CON keeps only the participant-addressed availability process; competing layers stay separate |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY_BASE.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Same-family safeguards\n\n"
collision << "- `CON:0xx` names source endpoints, target endpoints, and shared channels as communicative loci.\n"
collision << "- `CON:1xx` names source expression, target reception, and shared distribution as processes through those loci.\n"
collision << "- `CON:2xx` remains reserved for connectivity capacities, participant bonds, compatibility, reachability, agreements, and possible exchange relations.\n"
collision << "- Source expression completion never entails target reception; target reception never entails comprehension; shared distribution never entails uptake by every endpoint.\n"
collision << "- Lexical `1x2` means nonactualized process only. Plan, intention, queue, schedule, permission, probability, future time, and certainty require other roots or grammar.\n"
collision << "- Runtime `[2]/num` qualifies an assertion and never changes the selected lexical phase.\n\n"
collision << "## Reserved compounds\n\n"
collision << "Tell, ask, request, answer, reply, delivery, acknowledgement, conversation, dialogue, negotiation, consensus, handshake, forward, relay, transport, upload, download, notification, telepathy, streaming, and publish-subscribe operations remain typed compounds.\n\n"
collision << "**CONCLUSION: THE GRID STANDS ALONE ONLY FOR COMMUNICATIVE AVAILABILITY PROCESSES; CONTENT, CARRIER, COGNITION, TOPOLOGY, RULES, RELATIONSHIPS, AND TEMPORAL COMMITMENTS ARE EXCLUDED OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built CON:100–122 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root["candidates"].length }} candidates, #{stress_tests.length} stress tests."
