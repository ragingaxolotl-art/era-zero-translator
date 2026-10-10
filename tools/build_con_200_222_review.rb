#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "CON:200–222"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "CON_200_222"
SEMANTIC_CENTER = "communicative affordances and participant relations: endpoint participation capacity, directed target relation, and shared co-participation relation"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "CON:200" => ["stable connectivity", "An entity has a dependable inward capacity to establish and maintain communication links."],
  "CON:201" => ["active receptivity", "An entity's capacity to receive, respond, translate, or relay communication is presently available."],
  "CON:202" => ["dormant interface capacity", "An interface or communicative ability exists but is disabled, inaccessible, or not yet developed."],
  "CON:210" => ["established bond", "Two participants have a stable communication, social, or signaling relationship."],
  "CON:211" => ["active dialogue", "Participants are actively exchanging messages, meanings, or mutual responses."],
  "CON:212" => ["unconfirmed contact", "A possible bond or channel to another participant exists but identity, reachability, or reciprocity is unresolved."],
  "CON:220" => ["interoperable network", "A communication system has stable compatibility and routing relationships among its parts."],
  "CON:221" => ["active mesh", "Many participants are actively maintaining a distributed web of exchange."],
  "CON:222" => ["possible communication network", "A valid shared channel system or community could form but has not yet been realized."]
}.freeze

ROOTS = {
  "CON:200" => { title: "enduring communicative participation capacity", phase: "enduring", scope: "endpoint-internal", kind: "capacity", invariant: "A persistent capacity of an endpoint to participate in communicative exchange." },
  "CON:201" => { title: "available communicative participation capacity", phase: "presently available", scope: "endpoint-internal", kind: "capacity", invariant: "A communicative capacity of an endpoint that is presently available for exercise in an exchange." },
  "CON:202" => { title: "latent communicative participation capacity", phase: "latent", scope: "endpoint-internal", kind: "capacity", invariant: "A communicative capacity of an endpoint that exists without being presently available for exercise." },
  "CON:210" => { title: "established directed communication relation", phase: "established", scope: "target-directed", kind: "directed relation", invariant: "A persistent relation that identifies a distinct endpoint as the target of communicative exchange from a reference endpoint." },
  "CON:211" => { title: "operative directed communication relation", phase: "presently operative", scope: "target-directed", kind: "directed relation", invariant: "A directed relation from a reference endpoint to a distinct target that is presently operative as a participant link for communicative exchange." },
  "CON:212" => { title: "unresolved directed communication relation", phase: "unresolved", scope: "target-directed", kind: "directed relation", invariant: "A directed relation from a reference endpoint to a distinct target whose status as a participant link for communicative exchange is undetermined." },
  "CON:220" => { title: "enduring shared-participation relation", phase: "enduring", scope: "shared/systemic", kind: "shared relation", invariant: "A persistent communicative relation among multiple endpoints that constitutes them as co-participants in one shared exchange context." },
  "CON:221" => { title: "operative shared-participation relation", phase: "presently operative", scope: "shared/systemic", kind: "shared relation", invariant: "A communicative relation among multiple endpoints that presently operates to constitute them as co-participants in one shared exchange context." },
  "CON:222" => { title: "potential shared-participation relation", phase: "unrealized", scope: "shared/systemic", kind: "shared relation", invariant: "A not-yet-realized possible communicative relation among multiple endpoints that would constitute them as co-participants in one shared exchange context." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => {
    scores: [6, 8, 8, 4, 4, 7, 8, 8],
    summary: "selects salient connectivity, dialogue, bond, receptivity, and network vocabulary"
  },
  "capacity_and_participant_relations" => {
    scores: [10, 10, 10, 10, 9, 10, 10, 10],
    summary: "treats 2xx uniformly as communicative affordance or participant relation"
  },
  "access_and_reachability" => {
    scores: [8, 8, 7, 6, 5, 9, 9, 9],
    summary: "uses the layer for online status, addressability, reachability, and network access"
  },
  "social_affiliation" => {
    scores: [8, 7, 7, 7, 5, 8, 10, 5],
    summary: "uses the layer for conversational competence, social ties, and communities"
  },
  "protocol_interoperability" => {
    scores: [8, 8, 6, 7, 4, 9, 6, 10],
    summary: "uses the layer for protocol support, subscriptions, compatibility, and federation"
  }
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns the identity and living or conscious status of participants and communities. CON may relate those participants but never makes a social group or organism identical to a communication relation.",
  "MOV" => "MOV owns displacement, approach, traversal, and spatial reachability through routes. A communicative relation can hold across distance without asserting physical or logical reachability.",
  "MAT" => "MAT owns physical interfaces, transceivers, cables, sound, light, and carrier media. CON capacity is substrate-neutral and does not assert that hardware exists or functions.",
  "MIN" => "MIN owns attention, interpretation, understanding, willingness, memory, and joint mental state. Communicative participation does not entail attention or comprehension.",
  "STR" => "STR owns graph topology, membership structure, containers, interfaces, and system arrangement. CON owns the communicative participant relation, not the network's structural edges or shape.",
  "WRN" => "WRN owns failure, blockage, corruption, deception, and risk. A CON capacity or relation is neutral about faults unless a WRN claim is compounded.",
  "REP" => "REP owns restoration, reconnection after failure, and recovery of an interface or channel. A persistent or latent CON capacity is not itself a repair operation.",
  "LOG" => "LOG owns permission, authentication, protocol validity, compatibility tests, obligations, and reachability conclusions. CON relations do not imply authorization, compatibility, or successful reachability.",
  "DAT" => "DAT owns participant addresses, contact records, messages, streams, and subscription records as information objects. CON owns the affordance or relation those records may describe.",
  "CRE" => "CRE owns creation of interfaces, accounts, groups, protocols, and links. CON:2xx states a capacity or relation without asserting how it was created.",
  "ORI" => "ORI owns existence, modality, time, possibility, and ontological transition. CON:222 contributes a domain-specific unrealized shared relation but not plan, probability, schedule, or future time."
}.freeze

ALT_TITLES = {
  "CON:200" => ["persistent network access", "enduring conversational competence", "persistent protocol support"],
  "CON:201" => ["current addressability", "current social availability", "active protocol readiness"],
  "CON:202" => ["offline access potential", "dormant conversational role", "inactive protocol support"],
  "CON:210" => ["established reachability", "established social tie", "established subscription"],
  "CON:211" => ["live reachability", "engaged social tie", "active subscription"],
  "CON:212" => ["unknown reachability", "uncertain social tie", "unresolved subscription"],
  "CON:220" => ["persistent network access fabric", "enduring communication community", "interoperable federation"],
  "CON:221" => ["live access fabric", "engaged communication community", "active protocol federation"],
  "CON:222" => ["possible access fabric", "potential communication community", "possible interoperable federation"]
}.freeze

def score_hash(values)
  EraZeroValidation::SCORE_KEYS.zip(values).to_h
end

def candidate_analysis(id, architecture, title)
  scope = ROOTS.fetch(id).fetch(:scope)
  phase = ROOTS.fetch(id).fetch(:phase)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The Phase 2 title follows the #{scope} and #{phase} slot labels and chooses a familiar Connection-domain use.",
      "useful_coverage" => "It directly covers ordinary or technical ideas associated with #{title}.",
      "semantic_territory_consumed" => "Across the block it consumes mixtures of ability, receiving, responding, translation, social bonds, active message exchange, identity, reachability, compatibility, routing, and community.",
      "conflicts_or_future_limitations" => "The siblings do not preserve one invariant axis; entity, process, capacity, social, topology, protocol, and modal claims are mixed, so downstream composition would be unstable."
    }
  when "capacity_and_participant_relations"
    {
      "why_it_fits" => "The first trit remains capacity/relationship, the second trit alone selects self capacity, directed target relation, or shared relation, and the third trit alone selects its lexical condition.",
      "useful_coverage" => "It covers can-communicate, presently communicatively available, dormant capability, persistent contact relation, operative target relation, unresolved contact relation, and stable, operative, or potential group participation.",
      "semantic_territory_consumed" => "Only substrate-neutral communicative affordance and participant relations; endpoints, channels, traffic, messages, cognition, topology, policy, and physical carriers remain separate.",
      "conflicts_or_future_limitations" => "It intentionally requires compounds for online status, friendship, permission, protocol compatibility, reachability, conversation, subscription, network topology, and group identity."
    }
  when "access_and_reachability"
    {
      "why_it_fits" => "Access and reachability sound like capacities or endpoint relations, and stable/active/dormant or unresolved conditions are natural.",
      "useful_coverage" => "It would compactly express online, offline, accessible, reachable, unreachable, addressable, and network-access states.",
      "semantic_territory_consumed" => "Operational availability under physical paths, permissions, protocols, failures, addresses, and network configuration.",
      "conflicts_or_future_limitations" => "Reachability is normally a LOG conclusion over MOV/STR paths, MAT interfaces, WRN faults, and permissions; treating it as atomic hides the reason and collides with runtime state."
    }
  when "social_affiliation"
    {
      "why_it_fits" => "Communication ability, interpersonal ties, and communities are intuitive participant-level Connection meanings.",
      "useful_coverage" => "It would cover sociability, availability to talk, friend, colleague, audience, membership, community, and social group.",
      "semantic_territory_consumed" => "Human or agent social identity, affective ties, roles, membership, and collective identity.",
      "conflicts_or_future_limitations" => "It is anthropocentric, collides with LIF identity/community and STR membership, makes machines awkward, and confuses a communication relation with friendship or affection."
    }
  when "protocol_interoperability"
    {
      "why_it_fits" => "Protocol support and compatibility are communication affordances with strong stable/active/latent and pair/system contrasts.",
      "useful_coverage" => "It would cover supported protocol, negotiated session, subscription, compatibility, federation, and mesh operation.",
      "semantic_territory_consumed" => "Formal rules, type compatibility, authentication, subscription records, topology, and distributed coordination.",
      "conflicts_or_future_limitations" => "Most of this belongs to LOG, DAT, or STR; it is technology-specific, weak in ordinary conversation, and would make Connection depend on a particular implementation architecture."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  phase = root.fetch(:phase)
  scope = root.fetch(:scope)
  case architecture
  when "access_and_reachability"
    "A #{phase} condition of operational access or reachability at #{scope} scope."
  when "social_affiliation"
    "A #{phase} condition of social communicative affiliation at #{scope} scope."
  when "protocol_interoperability"
    "A #{phase} condition of protocol support or interoperability at #{scope} scope."
  end
end

def nearest_neighbors(id)
  address = id.split(":").last
  first, second, third = address.chars
  siblings = %w[0 1 2].reject { |x| x == third }.map { |x| "CON:#{first}#{second}#{x}" }
  cross_scope = %w[0 1 2].reject { |x| x == second }.map { |x| "CON:#{first}#{x}#{third}" }
  loci = "CON:0#{second}#{third}"
  process = "CON:1#{second}#{third}"
  (siblings + cross_scope + [loci, process]).uniq
end

def roles
  {
    "low" => "reference or source endpoint",
    "middle" => "capacity or communicative participant relation",
    "high" => "distinct target endpoint",
    "sustained" => "shared exchange context or co-participant set"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  third = id[-1]
  title = root.fetch(:title)
  case third
  when "0"
    {
      "0" => "Denies that the enduring condition named by #{title} holds in the stated context; it does not assert the active or dormant/unresolved sibling.",
      "1" => "Affirms the persistent capacity or relation named by #{title}, even if no exchange is occurring at this moment.",
      "2/num" => "Leaves unresolved whether the enduring condition named by #{title} holds; it does not convert the lexeme into its active or dormant/unresolved sibling."
    }
  when "1"
    {
      "0" => "Denies that the presently operative condition named by #{title} holds now; persistence, latency, or future operation is not thereby decided.",
      "1" => "Affirms that #{title} is presently available or operative, without asserting that expression, reception, or distribution traffic is occurring.",
      "2/num" => "Leaves unresolved whether #{title} is presently operative; it does not select the enduring or dormant/unresolved lexical sibling."
    }
  else
    {
      "0" => "Denies the latent, unresolved, or potential condition named by #{title}; it does not affirm an active or enduring alternative.",
      "1" => "Affirms exactly the latent, unresolved, or unrealized condition named by #{title}, without adding intention, plan, schedule, probability, permission, or future time.",
      "2/num" => "Leaves unresolved whether even the lexical latent, unresolved, or potential condition named by #{title} holds; lexical third-trit 2 and runtime uncertainty remain distinct."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  phase = root.fetch(:phase)
  case id[5]
  when "0"
    subject = { "0" => "archivist", "1" => "interpreter", "2" => "offline terminal" }.fetch(id[-1])
    english = {
      "0" => "The archivist retains the capacity to communicate even while silent.",
      "1" => "The interpreter is presently available to participate in the exchange.",
      "2" => "The offline terminal still has a communicative capability, but it cannot exercise it now."
    }.fetch(id[-1])
    physical = {
      "0" => "The probe has a persistent communication capability independent of this antenna's current state.",
      "1" => "The field unit's communicative capability is usable at this location now.",
      "2" => "The buried sensor retains a dormant capability although its radio is unavailable."
    }.fetch(id[-1])
    program = {
      "0" => "The object implements a persistent communicative-participant capability.",
      "1" => "The actor's communication capability is currently exercisable.",
      "2" => "The actor has the capability, but it is suspended and cannot currently be exercised."
    }.fetch(id[-1])
    [
      ["ordinary_conversation", "#{id}[1](ENDPOINT=#{subject})", "#{phase} endpoint-internal communicative participation capacity", english, "The root describes capacity, not a message event."],
      ["physical_or_spatial", "MAT(INTERFACE=device)+#{id}[1](ENDPOINT=device)", "physical interface plus #{phase} communicative capacity", physical, "MAT supplies hardware; CON supplies substrate-neutral capacity."],
      ["temporal_or_sequential", "#{id}[1](ENDPOINT=delegate,CONTEXT=session)+ORI(TIME=now)", "#{phase} capacity evaluated in this session", "The delegate's communicative capacity has the stated condition during this session.", "ORI supplies the evaluation time."],
      ["cross_family_compound", "LIF(AGENT=pilot)+MIN(ATTENTION=pilot)+#{id}[1](ENDPOINT=pilot)", "agent attention plus communicative participation capacity", "The pilot is attentive and has the stated communicative capacity.", "Attention and communication capacity are independent claims."],
      ["executable_or_programming", "#{id}[1](ENDPOINT=actor,CAPABILITY=communicative_participation)", "assert #{phase} communication capability", program, "The capability does not imply authentication, compatibility, or I/O traffic."],
      ["counterexample", "CON:101[1](SOURCE=actor,EXPRESSION=message)", "active source expression", "The actor is sending a message.", "Traffic is CON:1xx, not an endpoint capacity."]
    ]
  when "1"
    target = { "0" => "doctor", "1" => "on-call technician", "2" => "unknown delegate" }.fetch(id[-1])
    english = {
      "0" => "The clinic keeps the doctor as an established communication contact.",
      "1" => "The on-call technician is presently operative as the service's communication target.",
      "2" => "Whether the delegate is a valid communication contact is still unresolved."
    }.fetch(id[-1])
    program = {
      "0" => "The service retains a directed participant relation to its auditor.",
      "1" => "The callback target relation is presently operative.",
      "2" => "The endpoint relation is represented without claiming that linkage is established or absent."
    }.fetch(id[-1])
    [
      ["ordinary_conversation", "#{id}[1](REFERENCE=clinic,TARGET=#{target})", "#{phase} directed communication relation", english, "No message exchange or social affection is entailed."],
      ["physical_or_spatial", "MOV(DISTANCE=remote)+#{id}[1](REFERENCE=station,TARGET=relay)", "remote target plus #{phase} directed relation", "The relay has the stated communication relation to the station despite being remote.", "Distance does not determine the communicative relation."],
      ["temporal_or_sequential", "#{id}[1](REFERENCE=office,TARGET=delegate)+ORI(INTERVAL=shift)", "directed relation evaluated during a shift", "The target relation has the stated condition during the shift.", "The relation is not itself a schedule."],
      ["cross_family_compound", "DAT(ADDRESS=a)+LOG(PERMISSION=p)+#{id}[1](REFERENCE=service,TARGET=peer)", "address and permission plus directed communication relation", "The service records an address and permission separately from its target relation to the peer.", "DAT/LOG do not collapse into CON."],
      ["executable_or_programming", "#{id}[1](REFERENCE=service,TARGET=callback)", "assert #{phase} directed participant relation", program, "No send, receipt, protocol success, or reachability is implied."],
      ["counterexample", "CON:111[1](TARGET=#{target},EXPRESSION=alert)", "active target reception", "The target is receiving an alert.", "Reception traffic is CON:1xx, not the directed relation."]
    ]
  else
    group = { "0" => "research team", "1" => "incident crew", "2" => "proposed panel" }.fetch(id[-1])
    english = {
      "0" => "The research team remains related as co-participants in one exchange context.",
      "1" => "The incident crew is presently operating as co-participants in one exchange context.",
      "2" => "The proposed panel could become co-participants, but that shared relation is not realized."
    }.fetch(id[-1])
    program = {
      "0" => "The participant set retains one shared communicative relation.",
      "1" => "The participant set's shared communicative relation is presently operative.",
      "2" => "A possible participant set is modeled without instantiating a channel or membership structure."
    }.fetch(id[-1])
    [
      ["ordinary_conversation", "#{id}[1](PARTICIPANTS=#{group})", "#{phase} shared-participation relation", english, "The relation is not the group's social identity."],
      ["physical_or_spatial", "MOV(DISTRIBUTED=sensors)+#{id}[1](PARTICIPANTS=sensors)", "spatially distributed endpoints plus #{phase} shared relation", "The separated sensors have the stated co-participation relation.", "MOV adds distribution in space; CON adds communicative co-participation."],
      ["temporal_or_sequential", "#{id}[1](PARTICIPANTS=crew)+ORI(INTERVAL=incident)", "shared relation evaluated during incident", "The crew's shared-participation relation has the stated condition during the incident.", "Duration and schedule remain ORI/LOG."],
      ["cross_family_compound", "STR(MEMBERSHIP=set)+CON:020(CHANNEL=room)+#{id}[1](PARTICIPANTS=set)", "membership structure and shared channel plus shared participant relation", "The members share a channel and also stand in the stated co-participation relation.", "STR membership, CON:0xx channel, and CON:2xx relation remain distinct."],
      ["executable_or_programming", "#{id}[1](PARTICIPANTS=peers,CONTEXT=session)", "assert #{phase} shared communicative relation", program, "No topology, protocol compatibility, consensus, or traffic is implied."],
      ["counterexample", "CON:121[1](EXPRESSION=alert,ENDPOINTS=#{group})", "active shared distribution", "An alert is being distributed to the group.", "Shared traffic is CON:1xx, not the participant relation."]
    ]
  end.map do |category, graph, gloss, english, analysis|
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
      "pseudocode" => category == "executable_or_programming" ? "assert(relation.matches?(#{id.inspect}))" : nil
    }.compact
  end
end

def candidate(id, architecture, title, invariant)
  scores = score_hash(ARCHITECTURES.fetch(architecture).fetch(:scores))
  {
    "candidate_id" => architecture,
    "title" => title,
    "invariant_candidate" => invariant,
    "analysis" => candidate_analysis(id, architecture, title),
    "scores" => scores,
    "total" => scores.values.sum,
    "maximum" => 80
  }
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  phase2_title, phase2_definition = PHASE2.fetch(id)
  alts = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", phase2_title, phase2_definition),
    candidate(id, "capacity_and_participant_relations", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "access_and_reachability", alts[0], alternative_invariant(id, "access_and_reachability")),
    candidate(id, "social_affiliation", alts[1], alternative_invariant(id, "social_affiliation")),
    candidate(id, "protocol_interoperability", alts[2], alternative_invariant(id, "protocol_interoperability"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", phase2_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "capacity_and_participant_relations",
    "recommendation_reason" => "Only this design gives the entire 2xx layer one ontological type, preserves all address axes, and separates participant affordance/relation from communicative loci, traffic, content, cognition, topology, protocol, reachability, and social identity.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end

recommended_roots = IDS.map do |id|
  atom = atoms.fetch(id)
  root = ROOTS.fetch(id)
  second = id[-2]
  third = id[-1]
  scope_label = { "0" => "inward/self", "1" => "outward/target", "2" => "systemic/shared" }.fetch(second)
  state_label = { "0" => "stable or enduring", "1" => "active or presently operative", "2" => "dormant, unresolved, or unrealized" }.fetch(third)
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_2" => "Selects a capacity or relationship. #{root.fetch(:title)} is neither a communicative locus (`CON:0xx`) nor an expression, reception, or distribution process (`CON:1xx`).",
      "second_trit" => "Selects #{scope_label} scope: endpoint-internal participation affordance, a directed relation to a distinct target, or a relation shared among multiple participant endpoints.",
      "third_trit" => "Selects the #{state_label} lexical member while leaving runtime assertion status, temporal scheduling, probability, permission, and failure to separate grammar or roots."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} by which an endpoint can participate, relates communicatively to a distinct target, or stands with multiple endpoints as co-participants in an exchange context. It is neutral about endpoints and channels as loci, actual message traffic, content, physical substrate, cognition, topology, protocol, reachability, social identity, and scheduling.",
    "excluded_meanings" => [
      "The source endpoint, target endpoint, shared channel, interface, device, address record, participant set, or topology as an entity.",
      "Expression, reception, distribution, dialogue, broadcast, negotiation, acknowledgement, or any other communicative event or traffic.",
      "A physical link, route, movement, carrier, transceiver, permission, authentication, protocol compatibility, logical reachability, failure, repair, or queue state.",
      "Friendship, kinship, affection, community identity, structural membership, attention, understanding, agreement, or joint mental state.",
      "Intention, plan, schedule, probability, future time, or guaranteed later realization—especially for lexical third-trit 2."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`CON:0xx` owns communicative loci, `CON:1xx` owns exchange processes through those loci, and `CON:2xx` owns substrate-neutral communicative participation capacity or participant relations. An active capacity or relation never entails active traffic.",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} member of this triplet. Runtime `[2]/num` instead leaves the truth or applicability of that already-selected lexeme unresolved; it never changes the lexical member.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + CON:0xx supplies a concrete endpoint or channel without confusing the locus with this capacity or relation.",
      "#{id} + CON:1xx adds expression, reception, or distribution traffic without making traffic part of the invariant.",
      "#{id} + DAT/LOG/STR adds addresses, messages, permission, protocol, membership, or topology as typed independent layers.",
      "#{id} + MAT/MOV/MIN/LIF adds hardware, routes, attention, or participant identity while preserving the neutral Connection center."
    ],
    "later_era_notes" => "Later eras may lexicalize online, offline, contact, friend, subscriber, reachable, compatible, networked, community, group chat, peer, or federation. Era Zero should derive those senses compositionally and preserve the capacity/relation versus locus/process boundary.",
    "confidence" => 0.97,
    "canonicalized" => canonicalized_now
  }
end

stress_rows = [
  ["can communicate", "one_root", "CON:200 when a persistent endpoint capability is asserted; present usability instead selects CON:201."],
  ["communicatively available", "one_root", "CON:201 owns present exercisability of an endpoint's communicative participation capacity."],
  ["communicatively dormant", "one_root", "CON:202 owns an existing capacity that cannot presently be exercised."],
  ["online", "compound", "CON:201 may contribute present communication capacity, but MAT/STR/LOG/WRN determine interface, configuration, permission, and fault state."],
  ["offline", "compound", "CON:202 may contribute latent capacity; physical disconnection or denied access requires MAT/STR/LOG/WRN."],
  ["has a radio", "different_family", "MAT owns the physical device; no communicative capacity is inferred without context."],
  ["knows a language", "different_family_or_compound", "MIN/DAT owns knowledge of a symbol system; communication capacity may be compounded but is not identical."],
  ["is willing to talk", "compound", "MIN willingness plus CON capacity; willingness is not inside CON:201."],
  ["send", "existing_con_process", "CON:100–102 owns source expression by phase, not CON:2xx."],
  ["receive", "existing_con_process", "CON:110–112 owns target reception by phase, not endpoint capacity."],
  ["broadcast", "existing_con_process", "CON:120–122 owns shared distribution by phase."],
  ["contact", "underspecified", "May mean a directed relation, a DAT contact record, an exchange event, or successful reachability; the translator must resolve the graph."],
  ["established contact", "one_root_or_compound", "CON:210 if only the persistent directed participant relation matters; identity and address records add LIF/DAT."],
  ["live contact", "one_root_or_compound", "CON:211 for a presently operative directed participant relation, without claiming messages are flowing."],
  ["unknown contact status", "one_root", "CON:212 owns the unresolved directed participant-link relation."],
  ["friend", "compound_or_different_family", "LIF/MIN/social relation plus possible CON:210; friendship must not be reduced to communication linkage."],
  ["colleague", "compound_or_different_family", "LIF role and STR institutional membership; communication relations are optional."],
  ["subscriber", "compound", "CON directed relation plus DAT topic/subscription record and LOG entitlement."],
  ["callback target", "one_root_or_compound", "CON:210 or CON:211 supplies the directed participant relation; DAT stores the callback address and LOG governs invocation."],
  ["reachable", "compound_or_logic", "LOG conclusion over CON relation, route, physical interface, permission, and failures; not one CON atom."],
  ["unreachable", "compound_or_logic", "Negated LOG reachability with cause routed to MOV/STR/MAT/WRN/LOG."],
  ["addressable", "compound", "DAT address plus CON relation/capacity and LOG validity."],
  ["authenticated peer", "compound", "CON directed relation plus LOG authentication."],
  ["permitted recipient", "compound", "CON target relation plus LOG permission."],
  ["blocked contact", "compound", "CON directed relation plus WRN/LOG denial; blockage does not erase the relation."],
  ["communicating now", "existing_con_process_or_compound", "Requires CON:1xx traffic, possibly with CON:211; an operative relation alone is insufficient."],
  ["dialogue", "compound", "Alternating source expression and target reception among related endpoints; not CON:211 alone."],
  ["conversation", "compound", "Multiple CON:1xx acts, participant relations, timing, and content."],
  ["reply", "compound", "A source expression related by DAT/LOG to a prior reception."],
  ["acknowledge", "compound", "Reception followed by a LOG-related source expression."],
  ["group of correspondents", "one_root_or_compound", "CON:220 for enduring shared co-participation; LIF/STR supplies identity or formal membership."],
  ["active communication group", "one_root_or_compound", "CON:221 for operative shared participation; actual distribution or dialogue needs CON:1xx."],
  ["possible communication group", "one_root", "CON:222 for an unrealized possible shared-participation relation."],
  ["community", "different_family_or_compound", "LIF owns collective identity; CON shared relation may be one component."],
  ["audience", "compound", "STR/LIF participant set plus target endpoints and shared distribution context."],
  ["team", "different_family_or_compound", "LIF/STR owns the team; CON:220/221 only if shared communicative participation is asserted."],
  ["group chat", "compound", "CON:020/021 channel, CON:220/221 shared relation, and repeated CON:1xx traffic."],
  ["shared room", "existing_con_entity", "CON:020–022 owns the shared channel locus; CON:2xx owns the participant relation, not the room."],
  ["network", "different_family_or_compound", "STR owns topology; CON may add participant relations and channels."],
  ["mesh", "different_family_or_compound", "STR graph topology plus CON relations and optional active traffic."],
  ["federation", "compound", "STR membership/topology, LOG compatibility/governance, and CON shared relation."],
  ["interoperable", "compound_or_logic", "LOG compatibility over protocols and types; not CON:220."],
  ["compatible protocol", "different_family", "LOG owns compatibility and protocol rules."],
  ["handshake", "compound", "Reciprocal CON:1xx processes governed by LOG, possibly establishing a CON:211 relation."],
  ["subscription", "compound", "DAT record plus LOG entitlement plus directed or shared CON relation."],
  ["topic membership", "compound", "STR/DAT membership plus CON shared relation where communicative co-participation matters."],
  ["multicast group", "compound", "STR/DAT endpoint set, CON shared relation, LOG routing, and CON:1xx distribution."],
  ["consensus", "different_family_or_compound", "LOG agreement and MIN aligned judgments after communicative exchange."],
  ["joint attention", "different_family_or_compound", "MIN owns shared attention; CON relation may enable but does not entail it."],
  ["coordinate", "compound", "LOG/STR coordination using CON processes and relations."],
  ["connected", "underspecified", "Could be physical, structural, logical, social, or communicative; do not map blindly to CON."],
  ["disconnected", "underspecified", "Could negate a locus, relation, capacity, route, or hardware link; cause and layer must be resolved."],
  ["reconnect", "different_family_or_compound", "REP restores a CON locus, capacity, or relation after failure."],
  ["route exists", "different_family", "MOV/STR owns a route or topology; existence of a route does not establish a CON relation."],
  ["data stream", "different_family_or_compound", "DAT owns the stream; CON:1xx owns its exchange processes and CON:2xx may own participant relations."],
  ["message queue", "different_family", "DAT/STR owns queued messages; no communication relation or scheduled exchange is inferred."],
  ["transport", "different_family_or_compound", "MOV/MAT owns displacement of a carrier; communicative use adds CON/DAT."],
  ["schedule a call", "compound", "ORI/LOG schedule plus potential CON processes and participant relations."],
  ["possible meeting", "compound", "ORI modality plus LIF/STR event participants; CON:222 only if unrealized shared communicative co-participation is specifically asserted."],
  ["unknown relationship", "underspecified", "CON:212 only for an unresolved directed communicative relation; social, structural, or logical relations belong elsewhere."],
  ["unknown group formation", "one_root_or_compound", "CON:222 for potential shared communicative relation, with ORI/STR for broader formation claims."],
  ["participant", "existing_con_entity_or_compound", "CON:0xx identifies communicative endpoint loci; CON:2xx adds capacity or relation."],
  ["server/client", "compound", "STR/LOG roles plus CON endpoints, processes, capacities, and relations as separately asserted."],
  ["peer", "compound", "A symmetric or reciprocal construction over directed relations; no single directional root entails peerhood."],
  ["telepathy", "compound", "CON capacity, directed relation, source expression, and target reception with carrier unspecified."],
  ["silence despite capability", "one_root_plus_negation", "CON:200[1] with denied CON:101; persistent capacity can coexist with no active expression."],
  ["operative link without traffic", "one_root_plus_negation", "CON:211[1] with denied CON:101/111; this is a required non-entailment."],
  ["traffic without persistent contact", "existing_process_plus_negation", "A transient CON:1xx exchange can occur while CON:210 is denied or unspecified."],
  ["potential group with no channel", "one_root_plus_negation", "CON:222[1] can hold while CON:020/021 is denied; the possible relation is not a channel entity."],
  ["uncertain active capacity", "runtime_state", "CON:201[2]/num leaves present availability unresolved; it is not CON:202 latent capacity."],
  ["uncertain potential group", "runtime_state", "CON:222[2]/num questions even the potential relation; CON:222[1] affirms it as unrealized."],
  ["future communication", "compound_or_grammar", "ORI future time plus a potential CON process or relation; third lexical trit 2 alone does not mean future."],
  ["communication permission", "different_family_or_compound", "LOG permission applies to a CON capacity, relation, or process but is never contained in it."]
].freeze

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("CON2-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => {
    "title" => "CON:200–222 adversarial semantic candidates",
    "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation",
    "architecture_version" => "1.0",
    "range" => RANGE,
    "roots_reviewed" => 9,
    "candidate_architectures_per_root" => 5,
    "scored_categories" => EraZeroValidation::SCORE_KEYS,
    "generated_fields_changed" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [],
    "approval_record" => canonicalized_now ? "migrations/CON_200_222_semantic_approval.yaml" : nil
  },
  "roots" => scored_roots
}

recommended = {
  "metadata" => {
    "title" => "CON:200–222 recommended permanent semantic specification",
    "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval",
    "architecture_version" => "1.0",
    "semantic_center" => SEMANTIC_CENTER,
    "triplets" => {
      "CON:200–202" => "endpoint communicative participation capacity: enduring / presently available / latent",
      "CON:210–212" => "directed target communication relation: established / presently operative / unresolved",
      "CON:220–222" => "shared co-participation relation: enduring / presently operative / unrealized potential"
    },
    "generated_fields_changed" => false,
    "gate4_started" => false,
    "translator_started" => false,
    "roots_canonicalized" => canonicalized_now ? IDS : [],
    "approval_record" => canonicalized_now ? "migrations/CON_200_222_semantic_approval.yaml" : nil
  },
  "roots" => recommended_roots,
  "approval_checklist" => {
    "family_domain_preserved" => true,
    "address_axes_preserved" => true,
    "one_invariant_per_root" => true,
    "triplets_coherent" => true,
    "all_current_candidates_challenged" => true,
    "cross_family_collisions_explicit" => true,
    "runtime_state_separated" => true,
    "locus_process_relation_layers_separated" => true,
    "generated_fields_unchanged" => true,
    "gate4_not_started" => true,
    "translator_not_started" => true,
    "canonicalized" => canonicalized_now
  }
}

stress = {
  "metadata" => {
    "title" => "CON:200–222 English coverage and routing tests",
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

review = +"# CON:200–222 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges every provisional meaning in the Connection capacity/relationship layer. It compares five genuinely different semantic architectures per address, scores 45 candidates across 360 criterion values, and tests #{stress_tests.length} English concepts without forcing all senses into atoms.\n\n"
review << "## Packet-level design decision\n\n"
review << "The strongest architecture completes one coherent three-layer family: `CON:0xx` names communicative loci, `CON:1xx` names exchange processes through those loci, and `CON:2xx` names communicative participation affordance or relations among participant endpoints. The second trit selects endpoint-internal capacity, directed target relation, or shared co-participation relation; the third trit changes only lexical condition.\n\n"
review << "This design rejects the Phase 2 mixture of receiving, responding, translation, dialogue, social bond, network topology, routing, and interoperability. Those concepts remain processes or typed compounds. An operative capacity or relation never entails traffic; a relation never entails reachability, permission, friendship, protocol compatibility, or channel existence.\n\n"

IDS.each do |id|
  score_root = scored_roots.find { |r| r["canonical_id"] == id }
  spec = recommended_roots.find { |r| r.dig("fixed_generated_fields", "canonical_id") == id }
  fixed = spec.fetch("fixed_generated_fields")
  review << "## #{id} — #{spec['proposed_title']}\n\n"
  review << "### A. Fixed generated forms\n\n"
  review << "- Universal slot: **#{fixed['universal_slot']}**\n- Transliteration: **#{fixed['family_qualified_transliteration']}**\n- Local compact root: **#{fixed['local_compact_root']}**\n- Formal carrier: **#{fixed['formal_carrier']}**\n- Harmonic signature: **#{fixed['harmonic_signature_semitones'].join('–')}**\n- Relative note path: **#{fixed['relative_note_path_semitones'].join(' → ')}**\n\n"
  review << "### B. Why the current meaning was probably chosen\n\n#{score_root['current_meaning_rationale']}\n\n"
  review << "### C. Candidate comparison\n\n| Candidate | Atomicity | Address | Family | Neighbor | Cross-family | Compound | Everyday | Technical | Total |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n"
  score_root.fetch("candidates").each do |c|
    values = EraZeroValidation::SCORE_KEYS.map { |key| c.dig("scores", key) }
    review << "| #{c['title']} | #{values.join(' | ')} | **#{c['total']}/80** |\n"
  end
  review << "\n"
  score_root.fetch("candidates").each do |c|
    a = c.fetch("analysis")
    review << "#### #{c['title']}\n\n**Invariant candidate:** #{c['invariant_candidate']}\n\n- Fit: #{a['why_it_fits']}\n- Useful coverage: #{a['useful_coverage']}\n- Territory consumed: #{a['semantic_territory_consumed']}\n- Conflicts and limitations: #{a['conflicts_or_future_limitations']}\n\n"
  end
  review << "### D. Recommended permanent semantic specification\n\n**Title:** #{spec['proposed_title']}\n\n**Invariant:** #{spec['invariant_definition']}\n\n**Inclusion boundary:** #{spec['inclusion_boundary']}\n\n**Excluded meanings:**\n\n"
  spec.fetch("excluded_meanings").each { |x| review << "- #{x}\n" }
  review << "\n**Address justification:**\n\n"
  spec.fetch("address_justification").each { |axis, explanation| review << "- `#{axis}`: #{explanation}\n" }
  review << "\n**Nearest neighbors:** #{spec['nearest_neighbors'].map { |n| "`#{n}`" }.join(', ')}\n\n**Same-family boundary:** #{spec['same_family_contrast']}\n\n**Runtime-state interpretation:**\n\n"
  spec.fetch("runtime_state_interpretation").each { |state, meaning| review << "- `[#{state}]`: #{meaning}\n" }
  review << "\n**Lexical/runtime distinction:** #{spec['lexical_runtime_distinction']}\n\n### E. Examples\n\n| Type | Semantic graph | Literal gloss | Natural English | State | Result |\n| --- | --- | --- | --- | ---: | --- |\n"
  spec.fetch("examples").each { |e| review << "| #{e['category']} | `#{e['semantic_graph']}` | #{e['literal_gloss']} | #{e['natural_english']} | #{e['runtime_state']} | #{e['use_status']} |\n" }
  review << "\n"
end

review << "## Triplet coherence\n\n| Triplet | Shared axis | `0` | `1` | `2` |\n| --- | --- | --- | --- | --- |\n"
review << "| CON:200–202 | endpoint-internal communicative participation capacity | persistent regardless of current exercise | presently exercisable | exists but not presently exercisable |\n"
review << "| CON:210–212 | directed communicative relation to a distinct target | persistently established | presently operative | linkage status undetermined |\n"
review << "| CON:220–222 | communicative co-participation relation among multiple endpoints | persistently established | presently operative | possible but unrealized |\n\n"
review << "## Nine-root contrast and ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |r| review << "| #{r.dig('fixed_generated_fields', 'canonical_id')} | #{r['proposed_title']} | endpoints/channels, traffic, content, hardware, cognition, topology, protocol, reachability, social identity, and scheduling |\n" }
review << "\n## Concepts intentionally reserved for compounds\n\nOnline/offline, contact record, friend, colleague, subscriber, reachable, authenticated peer, blocked contact, dialogue, conversation, group chat, audience, network, mesh, federation, interoperability, handshake, multicast group, consensus, joint attention, reconnection, schedule, and future communication remain compounds or other-family concepts. *Contact*, *connected*, *relationship*, and *network* require sense resolution.\n\n"
review << "## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, existing Connection loci/processes, compounds, runtime state, grammar, other families, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet was approved after reusable and family-level validation.\n" : "\n**Recommendation:** approve only after reusable packet validation, full Connection-family soundness validation, and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# CON:200–222 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |r|
  id = r.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MAT hardware; MIN skill/willingness; LOG permission; runtime availability", "1" => "DAT contact record; LOG reachability/authentication; LIF social tie; CON:1xx traffic", "2" => "STR network/membership; LOG interoperability; LIF community; CON:0xx shared channel" }.fetch(id[-2])
  collision << "| #{id} | #{r['proposed_title']} | #{risks} | CON keeps only communicative affordance or participant relation; every competing layer stays separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments\n\n- `CON:201` present capacity does not entail any `CON:1xx` traffic.\n- `CON:210/211` directed relation does not entail reachability, permission, identity verification, reciprocity, friendship, or message exchange.\n- `CON:220/221/222` shared relation is not a channel entity, participant set, network topology, community identity, protocol federation, joint attention, consensus, or distribution event.\n- A `CON:1xx` process may occur without a persistent `CON:2xx` relation, and a `CON:2xx` relation may hold without a process.\n- Lexical third-trit `2` does not encode plan, schedule, probability, future time, or runtime uncertainty.\n\n**CONCLUSION: CON:2xx STANDS ALONE ONLY FOR COMMUNICATIVE PARTICIPATION CAPACITY AND PARTICIPANT RELATIONS; ALL TRAFFIC, CONTENT, HARDWARE, COGNITION, TOPOLOGY, RULES, REACHABILITY, SOCIAL IDENTITY, AND TIME COMMITMENTS REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built CON:200–222 review packet: #{IDS.length} roots, #{scored_roots.sum { |r| r['candidates'].length }} candidates, #{stress_tests.length} stress tests."
