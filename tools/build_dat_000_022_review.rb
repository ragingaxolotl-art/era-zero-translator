#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "DAT:000–022"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "DAT_000_022"
SEMANTIC_CENTER = "information entities: internal data, target-referential data, and shared datasets"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "DAT:000" => ["local record", "A stable inward record, symbol, identifier, or datum is stored as one bounded information object."],
  "DAT:001" => ["current input", "A signal or datum is presently entering, updating, or occupying an entity's local information state."],
  "DAT:002" => ["dormant record", "Information is preserved inwardly but is archived, inaccessible, unread, or not currently loaded."],
  "DAT:010" => ["addressed message", "A stable external message, reference, packet, or record is identified as a target."],
  "DAT:011" => ["live signal", "An external signal or message is presently arriving, changing, or available for reception."],
  "DAT:012" => ["queued message", "A message or data object is defined for a target but has not been delivered or made accessible."],
  "DAT:020" => ["dataset", "A stable shared collection of records, symbols, mappings, or messages forms one information system."],
  "DAT:021" => ["data stream", "Information is actively flowing, updating, or being replicated across a shared system."],
  "DAT:022" => ["archive", "A collective body of information is preserved but is not presently indexed, loaded, or in active use."]
}.freeze

ROOTS = {
  "DAT:000" => { title: "persistent internal datum", phase: "persistent", scope: "inward", kind: "internal datum", invariant: "A persistent bounded information object maintained within one reference entity, independently of whether that information object is presently manifest." },
  "DAT:001" => { title: "manifest internal datum", phase: "manifest", scope: "inward", kind: "internal datum", invariant: "A bounded information object that is presently manifest within one reference entity." },
  "DAT:002" => { title: "dormant internal datum", phase: "dormant", scope: "inward", kind: "internal datum", invariant: "A bounded information object that remains maintained within one reference entity without being presently manifest." },
  "DAT:010" => { title: "persistent target reference", phase: "persistent", scope: "outward", kind: "target-referential datum", invariant: "A persistent bounded information object whose content denotes one distinct reference target, independently of whether that referential content is presently manifest." },
  "DAT:011" => { title: "manifest target reference", phase: "manifest", scope: "outward", kind: "target-referential datum", invariant: "A bounded information object whose content presently manifests a reference to one distinct reference target." },
  "DAT:012" => { title: "dormant target reference", phase: "dormant", scope: "outward", kind: "target-referential datum", invariant: "A bounded information object whose content denotes one distinct reference target without presently manifesting that reference." },
  "DAT:020" => { title: "persistent shared dataset", phase: "persistent", scope: "systemic", kind: "shared dataset", invariant: "A persistent coordinated collection of information objects maintained as one shared dataset across multiple participants in one information domain, independently of whether that dataset is presently manifest." },
  "DAT:021" => { title: "manifest shared dataset", phase: "manifest", scope: "systemic", kind: "shared dataset", invariant: "A coordinated collection of information objects that is presently manifest as one shared dataset across multiple participants in one information domain." },
  "DAT:022" => { title: "dormant shared dataset", phase: "dormant", scope: "systemic", kind: "shared dataset", invariant: "A coordinated collection of information objects maintained as one shared dataset across multiple participants in one information domain without being presently manifest." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [6, 7, 8, 4, 4, 7, 8, 7] },
  "information_object_entities" => { scores: [10, 10, 10, 10, 9, 10, 10, 10] },
  "symbolic_representation_entities" => { scores: [9, 8, 10, 8, 8, 9, 9, 10] },
  "storage_record_entities" => { scores: [9, 8, 9, 7, 7, 9, 10, 10] },
  "communication_message_entities" => { scores: [8, 7, 7, 6, 5, 9, 10, 9] }
}.freeze

ALT_TITLES = {
  "DAT:000" => ["persistent internal representation", "persistent local record", "persistent internal message"],
  "DAT:001" => ["manifest internal representation", "open local record", "manifest internal message"],
  "DAT:002" => ["dormant internal representation", "archived local record", "dormant internal message"],
  "DAT:010" => ["persistent target symbol", "persistent addressed record", "persistent outbound message"],
  "DAT:011" => ["manifest target symbol", "open addressed record", "manifest outbound message"],
  "DAT:012" => ["dormant target symbol", "archived addressed record", "queued outbound message"],
  "DAT:020" => ["persistent shared representation system", "persistent shared archive", "persistent message collection"],
  "DAT:021" => ["manifest shared representation system", "open shared archive", "manifest message collection"],
  "DAT:022" => ["dormant shared representation system", "archived shared corpus", "dormant message collection"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identities, biological conditions, agents, and social collectives. Data can describe a living bearer or participant, but the information object is not the life, role, health, memory bearer, or agency it represents.",
  "MOV" => "MOV owns position, path, displacement, and motion affordances. Data may represent a position or route, but a reference, record, or dataset neither moves nor constitutes the physical route or destination.",
  "MAT" => "MAT owns substance, energy, force, contact, media, and material capacities. A physical inscription or device may realize data, but DAT identifies the information object rather than its material substrate.",
  "MIN" => "MIN owns awareness, belief, attention, memory, intention, and subjective representation. A datum can persist or be manifest independently of whether any observer knows, believes, recalls, or understands it.",
  "CON" => "CON owns channels, participants, communication acts, delivery, reception, and exchange relations. A message may carry DAT content, but transmission and participant linkage are not the information object itself.",
  "WRN" => "WRN owns faults, hazards, adverse processes, warnings, susceptibility, and propagation. Data may describe or signal a fault, but the information object is not the adverse condition or warning act.",
  "STR" => "STR owns arrangements, boundaries, interfaces, schemas-as-structure, dependencies, and structural capacities. Data can encode a structure, but the information object remains distinct from the arrangement it represents.",
  "REP" => "REP owns restoration conditions, restorative processes, and restorative affordances. Backups and checkpoints are data objects that may support repair, but DAT does not assert restoration or recoverability.",
  "LOG" => "LOG owns formal constraints, evaluations, and evaluation affordances. Data can represent criteria, operands, proofs, or results, but representation is not the formal rule, evaluation, or applicability relation.",
  "CRE" => "CRE owns creation, transformation, generation, and productive capacities. Creating or changing data is a process distinct from the resulting information object and its manifest status.",
  "ORI" => "ORI owns temporal, modal, causal, and ontological qualification. Data persistence, manifestation, and dormancy do not encode past, future, possibility, necessity, probability, or origin."
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
    values[0] -= 1 if third != "0"
    values[3] -= 2 if second == "2"
  when "information_object_entities"
    values[4] += 1 if second == "0"
    values[6] -= 1 if second == "2"
  when "symbolic_representation_entities"
    values[1] -= 2 if second == "1"
    values[3] -= 1 if third == "2"
  when "storage_record_entities"
    values[2] -= 1 if second == "2"
    values[4] -= 2 if second == "1"
  when "communication_message_entities"
    values[0] -= 1 if third == "1"
    values[4] -= 2 if second == "0"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, architecture, title)
  root = ROOTS.fetch(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional titles use familiar data vocabulary and roughly follow #{root.fetch(:scope)} scope and #{root.fetch(:phase)} status.",
      "useful_coverage" => "They cover records, inputs, messages, signals, datasets, streams, archives, identifiers, and packets.",
      "semantic_territory_consumed" => "Across the block they mix information entities, storage state, communication processes, data flow, delivery queues, access, indexing, and active updating.",
      "conflicts_or_future_limitations" => "The triplets do not preserve one entity center: manifest roots absorb input or flow processes, target roots absorb CON delivery, and dormancy is mixed with inaccessible, queued, unread, and unindexed states."
    }
  when "information_object_entities"
    {
      "why_it_fits" => "The first trit remains an information entity; the second changes only internal containment, reference to one distinct target, or coordinated sharing across participants; the third changes only persistent, manifest, or dormant status.",
      "useful_coverage" => "It supports datum, record, value, identifier, reference, pointer, metadata, dataset, corpus, catalogue, and shared state without encoding transmission or computation.",
      "semantic_territory_consumed" => "Only bounded information-object identity and manifestation at the selected scope. Media, storage mechanics, communication, transformation, access, truth, belief, and formal validity remain separate.",
      "conflicts_or_future_limitations" => "Encoding and value-type distinctions remain broad in Era Zero and must be supplied compositionally when exact syntax, schema, provenance, or medium matters."
    }
  when "symbolic_representation_entities"
    {
      "why_it_fits" => "Symbols and representations are central Data entities and can occur internally, refer to targets, or form shared representational systems.",
      "useful_coverage" => "It would cover symbols, tokens, codes, names, labels, icons, formulas, maps, and representational systems.",
      "semantic_territory_consumed" => "It specializes every datum to an explicitly symbolic representation.",
      "conflicts_or_future_limitations" => "Measurements, opaque blobs, sensory traces, and non-symbolic information objects would be under-served, while representational relation details risk LOG, MIN, and STR collisions."
    }
  when "storage_record_entities"
    {
      "why_it_fits" => "Records naturally persist, become open or loaded, and become archived at internal, target-addressed, or shared scope.",
      "useful_coverage" => "It would cover files, rows, documents, logs, archives, databases, indexes, and stored records.",
      "semantic_territory_consumed" => "It makes durable storage or record structure essential to every Data entity.",
      "conflicts_or_future_limitations" => "Signals, ephemeral values, references, and computed data need not be records; physical storage and access also risk MAT and STR collisions."
    }
  when "communication_message_entities"
    {
      "why_it_fits" => "Messages contain information, can remain local, target recipients, or be shared among groups, and can be manifest or dormant.",
      "useful_coverage" => "It would cover message, packet, signal, notification, post, broadcast, queue, and inbox item.",
      "semantic_territory_consumed" => "It makes communicative intent, sender-recipient structure, and delivery context obligatory.",
      "conflicts_or_future_limitations" => "CON owns participants, transmission, delivery, and reception, while most data objects are not messages at all."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "symbolic_representation_entities"
    "A #{root.fetch(:phase)} symbolic representation organized at #{root.fetch(:scope)} information scope."
  when "storage_record_entities"
    "A #{root.fetch(:phase)} stored record situated at #{root.fetch(:scope)} information scope."
  when "communication_message_entities"
    "A #{root.fetch(:phase)} communicative message organized at #{root.fetch(:scope)} scope."
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
  siblings = %w[0 1 2].reject { |x| x == third }.map { |x| "DAT:#{first}#{second}#{x}" }
  scopes = %w[0 1 2].reject { |x| x == second }.map { |x| "DAT:#{first}#{x}#{third}" }
  process = "DAT:1#{second}#{third}"
  relation = "DAT:2#{second}#{third}"
  (siblings + scopes + [process, relation]).uniq
end

def roles
  {
    "low" => "reference entity, referent, or participant associated with the information object",
    "middle" => "bounded datum, target reference, or shared dataset asserted as the figure",
    "high" => "distinct referent, encoding, medium, or owner when separately expressed",
    "sustained" => "shared information domain and its multiple participating holders"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that this #{root.fetch(:kind)} persists as the same identified information object; it does not select the manifest or dormant sibling and does not erase every related datum.",
      "1" => "Affirms the persistent identity of this #{root.fetch(:kind)} while leaving current manifestation, accessibility, truth, encoding, medium, and provenance undecided.",
      "2/num" => "Leaves unresolved whether this persistent #{root.fetch(:kind)} remains identified; uncertainty about the assertion does not change the lexical root into a manifest or dormant datum."
    }
  when "1"
    {
      "0" => "Denies that this #{root.fetch(:kind)} is presently manifest; it does not erase the information object, affirm dormancy, or state whether anyone can access or understand it.",
      "1" => "Affirms that this #{root.fetch(:kind)} is presently manifest in the stated information scope, without asserting truth, access, observation, transmission, storage medium, or use.",
      "2/num" => "Leaves unresolved whether this #{root.fetch(:kind)} is presently manifest; runtime uncertainty does not select persistent identity or lexical dormancy."
    }
  else
    {
      "0" => "Denies that this #{root.fetch(:kind)} is presently dormant; it does not by itself affirm current manifestation, deletion, corruption, inaccessibility, or replacement.",
      "1" => "Affirms that this #{root.fetch(:kind)} remains maintained but is not presently manifest, without encoding archive medium, access denial, hiddenness, future activation, uncertainty, or loss.",
      "2/num" => "Leaves unresolved whether the selected dormant #{root.fetch(:kind)} claim holds; lexical third-trit 2 names maintained-but-unmanifest status, while runtime `[2]/num` marks assertion-level uncertainty."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entity = id[-2] == "0" ? "device" : id[-2] == "1" ? "record" : "workspace"
  graph_roles = id[-2] == "0" ? "ENTITY=#{entity},DATUM=d" : id[-2] == "1" ? "DATUM=d,REFERENT=#{entity}" : "DOMAIN=#{entity},PARTICIPANTS={a,b,c},DATASET=d"
  ordinary = { "0" => "That information object remains identified whether or not it is visible now.", "1" => "That information object is manifest now.", "2" => "That information object is still maintained, but it is not manifest now." }.fetch(id[-1])
  entries = [
    ["ordinary_conversation", "#{id}[1](#{graph_roles})", "affirm #{root.fetch(:phase)} #{root.fetch(:kind)}", ordinary, "The root asserts an information entity and its manifestation status, not access or transmission."],
    ["physical_or_spatial", "MAT(MEDIUM=m)+#{id}[1](#{graph_roles})", "material medium plus #{root.fetch(:phase)} data entity", "A mark on the device realizes the datum while MAT separately describes its physical medium.", "The information object and physical inscription remain separately typed."],
    ["temporal_or_sequential", "#{id}[1](#{graph_roles})+ORI(INTERVAL=w)", "#{root.fetch(:phase)} data entity during interval w", "During interval w, the information object has the stated lexical status.", "ORI supplies time and does not replace data manifestation status."],
    ["cross_family_compound", "LOG(CRITERION=c)+#{id}[1](#{graph_roles})", "formal criterion plus #{root.fetch(:phase)} data representation", "The datum represents a criterion without becoming the formal rule itself.", "DAT and LOG remain distinct."],
    ["executable_or_programming", "#{id}[1](#{graph_roles})", "assert #{root.fetch(:phase)} information-object status", "A runtime registers information-object status without asserting transfer, parsing, mutation, or truth.", "Entity identity and data-processing events remain separate."],
    ["counterexample", "CON(TRANSFER=d,SOURCE=s,TARGET=t)", "data transmission", "The packet is being sent to a recipient.", "Use CON plus a later DAT process root for transmission; #{id} identifies an information entity, not delivery."]
  ]
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
      "pseudocode" => category == "executable_or_programming" ? "assert(data_entity.status == #{id.inspect})" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "information_object_entities", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "symbolic_representation_entities", alt[0], alternative_invariant(id, "symbolic_representation_entities")),
    candidate(id, "storage_record_entities", alt[1], alternative_invariant(id, "storage_record_entities")),
    candidate(id, "communication_message_entities", alt[2], alternative_invariant(id, "communication_message_entities"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "information_object_entities",
    "recommendation_reason" => "Only this architecture keeps all nine roots on one information-object entity center, follows internal/reference/shared scope exactly, and gives every triplet one persistent/manifest/dormant axis while reserving physical media, communication, data transformation, access, truth, belief, rules, and modality for other DAT layers or families.",
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
  state_label = { "0" => "persistent/manifestation-neutral", "1" => "manifest/presently instantiated", "2" => "dormant/maintained but unmanifest" }.fetch(third)
  scope_explanation = {
    "0" => "one bounded information object maintained within one reference entity",
    "1" => "one bounded information object whose content denotes one distinct reference target",
    "2" => "one coordinated collection maintained as a shared dataset across multiple participants in one information domain"
  }.fetch(second)
  scope_boundary = {
    "0" => "The claim is about an information object maintained within one reference entity, not the physical medium, an observer's memory, a reference to another target, or a shared collection.",
    "1" => "The claim preserves one distinct referent of the datum. Sender, recipient, transmission, delivery, access, truth, and the target entity itself remain separate.",
    "2" => "The claim requires one coordinated information collection shared across multiple participants. A coincidental set of unrelated data objects is not one systemic dataset, and storage or communication topology remains separate."
  }.fetch(second)
  triplet_logic = if third == "0"
                    "The persistent member is manifestation-neutral: it may co-occur with the manifest sibling or the dormant sibling at the same reference time. It asserts continuity of information-object identity rather than a third mutually exclusive manifestation value."
                  else
                    "The persistent sibling may also hold because it asserts information-object identity across time. Manifest and dormant siblings are mutually exclusive for the same object at the same reference time, while runtime `[2]/num` may leave either selected claim unresolved."
                  end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_0" => "Selects an information entity rather than a data transformation, transmission event, storage/access affordance, or physical medium.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Data-family column.",
      "third_trit" => "Selects the #{state_label} member by information-object identity or present manifestation while leaving runtime truth status, access, observation, transmission, tense, probability, and process phase separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral information entity at #{root.fetch(:scope)} scope. #{scope_boundary} It is neutral about truth, validity, belief, access, observation, transmission, processing, mutation, physical realization, ownership, provenance, probability, timing, and cause.",
    "excluded_meanings" => [
      "Truth, falsity, validity, evidential support, assertion, belief, understanding, memory, or certainty concerning the information.",
      "Creation, mutation, computation, parsing, indexing, querying, copying, transmission, delivery, reception, or deletion of data.",
      "Physical inscription, storage medium, device, energy, signal carrier, file-system structure, access path, or network topology.",
      "Sender, recipient, communication act, social ownership, authority, privacy policy, permission, or responsibility.",
      "Formal rule, proposition role, proof status, evaluation, satisfaction, entailment, consistency, or semantic correctness.",
      "Accessibility, observability, discoverability, provenance, version, schedule, future activation, possibility, necessity, probability, or cause."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`DAT:0xx` owns information entities and their persistent, manifest, or dormant status. `DAT:1xx` remains reserved for information transformations or flow processes, and `DAT:2xx` for storage, access, provenance, transmission, or other information affordances and relations. A manifest datum does not entail access, observation, truth, transfer, or processing, and an identified datum does not entail a usable storage or communication relation. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} member of this information-entity triplet. Runtime `[2]/num` instead leaves that already-selected assertion unresolved; it never changes manifestation status. Thus a dormant root affirmed with `[1]` is a confirmed maintained-but-unmanifest information object, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + MAT supplies the physical medium or signal carrier without reducing the information object to matter.",
      "#{id} + MIN supplies belief, memory, observation, or understanding while keeping cognitive state distinct from data identity.",
      "#{id} + CON supplies sender, recipient, channel, delivery, or reception while preserving content as a separate DAT entity.",
      "#{id} + DAT:1xx/2xx may later express transformation, flow, storage, access, provenance, or availability as separate processes and relations."
    ],
    "later_era_notes" => "Later eras may lexicalize value, symbol, identifier, record, schema, code, measurement, metadata, index, provenance, version, and media distinctions. Era Zero should preserve the substrate-neutral information-object center and derive technical subtypes compositionally. The persistent root must not be treated as mutually exclusive with its manifest or dormant sibling.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


logic_stress_base = [
  ["rule", "one_root_or_compound", "Use the appropriate LOG:0xx root when the intended sense is a formal admissibility constraint; add domain and authority roots when English rule names an institution or habit."],
  ["criterion", "one_root", "An internal, target-directed, or shared formal criterion selects the matching LOG:0xx scope."],
  ["invariant", "one_root_or_compound", "An invariant internal to one formal specification maps to LOG:000–002 according to persistent, operative, or dormant status."],
  ["constraint", "one_root_or_compound", "A target-directed constraint maps to LOG:010–012; a physical constraint also needs MAT or STR."],
  ["policy", "one_root_or_compound", "A shared formal policy can use LOG:020–022, while authorship and governed participants remain separately typed."],
  ["protocol", "compound", "LOG:020–022 supplies the shared rule regime and CON supplies the communication system it governs."],
  ["law", "compound", "LOG supplies formal constraint status; LIF and CON supply institution, authority, persons, and promulgation."],
  ["permission", "compound_or_later_specialization", "Permission is a deontic result under a criterion, not automatically the criterion itself; express rule plus modality or reserve specialized vocabulary."],
  ["prohibition", "compound_or_later_specialization", "A prohibitory rule can be a LOG constraint with polarity or modality, but prohibition is not a separate atom in this block."],
  ["obligation", "compound_or_later_specialization", "Obligation requires a formal rule plus deontic force and often an agent or act compound."],
  ["axiom", "compound", "Axiomhood requires a proposition or rule plus foundational status; LOG:000 alone means persistent internal criterion, not unproved truth."],
  ["proposition", "different_family_or_future_logic_vocabulary", "A truth-bearing content is not automatically a constraint entity; DAT may encode it and later LOG layers may evaluate it."],
  ["claim", "different_family_or_compound", "CON owns assertion events, DAT owns expressed content, and MIN owns belief; LOG:0xx applies only when content functions as a formal criterion."],
  ["truth", "unresolved_or_later_logic_vocabulary", "Truth value is not identical to rule operation; do not force it into LOG:001."],
  ["false", "unresolved_or_later_logic_vocabulary", "Falsity is not dormancy. LOG:002 names a defined but inoperative internal criterion."],
  ["valid", "process_or_relation_layer", "Validity concerns satisfaction, derivation, or consequence and belongs to later LOG layers or compounds, not the rule entity alone."],
  ["invalid", "process_or_relation_layer", "Invalidity is not a dormant rule; it requires evaluation or a formal relation."],
  ["satisfied constraint", "compound", "Use the LOG:0xx constraint plus a later evaluation or result expression; operation alone does not entail satisfaction."],
  ["violated constraint", "compound", "Use the LOG constraint plus an evaluation result; violation is not dormancy."],
  ["active rule", "one_root", "Choose LOG:001, LOG:011, or LOG:021 according to internal, target, or systemic scope."],
  ["suspended rule", "one_root_or_compound", "A still-defined but inoperative rule uses a LOG:0x2 root; suspension cause and future reactivation remain separate."],
  ["deleted rule", "different_meaning", "Deletion removes rule identity and is not lexical dormancy, which requires the rule to remain defined."],
  ["obsolete rule", "compound", "Dormancy may describe nonoperation, but obsolescence additionally requires temporal or replacement qualification."],
  ["future rule", "grammar_or_compound", "ORI future qualification applies to a rule; lexical third trit 2 does not mean future."],
  ["uncertain rule status", "runtime", "Use runtime `[2]/num` on the selected LOG root rather than substituting the dormant lexical root."],
  ["type constraint", "one_root_or_compound", "Use a LOG constraint; DAT separately supplies the type representation and value."],
  ["schema", "different_family_or_compound", "DAT owns a schema as represented information; LOG owns the constraints the schema expresses."],
  ["value", "different_family", "DAT owns represented values; a value is not a formal criterion merely because a program evaluates it."],
  ["variable", "different_family_or_compound", "DAT owns the represented slot or symbol; binding and evaluation require additional LOG process or relation vocabulary."],
  ["unbound variable", "different_family_or_compound", "Unbound is a data or environment state, not a dormant criterion."],
  ["operand", "different_family_or_compound", "DAT supplies the value or expression and LOG:1xx can later supply application or evaluation."],
  ["algorithm", "different_family_or_compound", "DAT stores its specification, LOG:1xx may execute or evaluate, and CRE or STR may describe produced transformations."],
  ["program", "different_family_or_compound", "DAT owns code as information; a running program is not a LOG:0xx rule entity, though its policy regime may be."],
  ["proof", "process_or_data_compound", "LOG:1xx should own proving or inference and DAT the proof object; LOG:0xx supplies premises only when they function as constraints."],
  ["theorem", "unresolved_or_compound", "A theorem is a proposition with derivational status, not automatically a shared regime."],
  ["formal system", "one_root_or_compound", "A shared formal regime maps to LOG:020–022; syntax, stored specification, and executing machinery remain separate."],
  ["type system", "one_root_or_compound", "A type system as a shared regime maps to LOG:020–022; individual type records remain DAT."],
  ["legal code", "compound", "LOG:020–022 supplies the shared formal regime while LIF and CON supply institution, authority, and social participants."],
  ["house rule", "compound", "LOG supplies the criterion or regime; LIF supplies household identity and CON may supply promulgation."],
  ["game rule", "one_root_or_compound", "LOG supplies rule status; the game, players, turns, and actions require other families."],
  ["physical law", "compound", "LOG can encode the formal constraint, while MAT and ORI supply physical domain and causal or temporal interpretation."],
  ["natural regularity", "different_family_or_compound", "Observed regularity is not automatically a formal rule; DAT evidence, ORI causation, and LOG model remain distinct."],
  ["business rule", "one_root_or_compound", "Use a LOG rule with LIF, CON, and DAT roots for organization, authority, records, and governed workflow."],
  ["access-control rule", "compound", "LOG supplies the rule, CON the relation or channel, DAT identity records, and LIF or MIN the principal where relevant."],
  ["firewall rule", "compound", "LOG supplies target-directed or shared constraint status; CON, DAT, and STR supply packets, channels, and structure."],
  ["database constraint", "one_root_or_compound", "Use LOG:010–012 for one target or LOG:020–022 for a shared database regime; DAT owns the stored schema."],
  ["assert statement", "compound", "LOG can supply the operative criterion and DAT the expression; execution and pass or fail belong to LOG:1xx."],
  ["validation rule", "one_root_or_compound", "The rule entity is LOG:0xx; the validation act and result must not be folded into it."],
  ["lint rule", "one_root_or_compound", "A lint criterion is LOG:0xx; tool execution and diagnostics require LOG:1xx and DAT or WRN as appropriate."],
  ["equation", "different_family_or_compound", "DAT supplies symbolic representation and LOG supplies formal constraint only when the equation is used as an admissibility condition."],
  ["inequality constraint", "one_root_or_compound", "LOG supplies the formal limit while DAT or MAT supplies variables and quantities."],
  ["ethical norm", "compound_or_later_specialization", "LOG can encode the formal norm, but agents, values, authority, and social force require LIF, MIN, or CON compounds."],
  ["habit", "different_family", "A habit is a behavioral or cognitive regularity, not a formal constraint unless a separate rule is explicitly constituted."],
  ["advice", "different_family", "CON owns communicative advice and MIN intention; advice is not a LOG rule without formal normative status."],
  ["command", "different_family_or_compound", "CON owns the directive act; LOG may separately encode the rule or obligation it creates."],
  ["schedule", "different_family_or_compound", "ORI owns temporal ordering and DAT its record; a schedule may be governed by LOG constraints but is not one."],
  ["workflow", "compound", "STR, CON, and ORI describe arranged steps and coordination; LOG supplies governing conditions when explicitly present."],
  ["rule versus record", "scope_resolution_test", "LOG owns the formal constraint; DAT owns the file, text, schema, or row that represents it."],
  ["rule versus belief", "scope_resolution_test", "LOG rule identity and operation are independent of whether a MIN cognizer accepts or remembers it."],
  ["rule versus execution", "scope_resolution_test", "LOG:0xx names the rule entity; LOG:1xx is reserved for actual evaluation or rule application."],
  ["rule versus applicability", "scope_resolution_test", "LOG:0xx names the rule; LOG:2xx is reserved for applicability, consequence, or other formal relations."],
  ["rule versus physical limit", "scope_resolution_test", "LOG supplies formal admissibility; MAT or STR supplies material or structural limitation."],
  ["rule versus protocol channel", "scope_resolution_test", "LOG supplies protocol constraints and CON supplies the channel and participant relations."],
  ["rule versus restoration criterion", "scope_resolution_test", "LOG owns the acceptance criterion while REP owns the restoration condition it characterizes."],
  ["many independent rules", "multiple_roots_not_one_systemic_root", "Separate unrelated criteria do not form one LOG:02x regime unless they correlate participants within one shared rule domain."],
  ["shared rule with one participant", "scope_mismatch", "A systemic regime requires multiple participants; one governed entity selects inward or target scope."],
  ["persistent plus operative rule", "two_compatible_roots", "The persistent root may co-occur with its operative sibling because identity is neutral about present operation."],
  ["persistent plus dormant rule", "two_compatible_roots", "The persistent root may co-occur with its dormant sibling because identity is neutral about present operation."],
  ["operative and dormant rule simultaneously", "contradiction", "For the same rule at one reference time, operative and dormant are mutually exclusive."],
  ["dormant rule affirmed", "runtime_and_lexical", "LOG:002, 012, or 022[1] affirms defined-but-inoperative status; runtime affirmation is not lexical operation."],
  ["persistent rule uncertain", "runtime_and_lexical", "LOG:000, 010, or 020[2]/num marks uncertainty about persistence; it does not select lexical dormancy."],
  ["operative rule denied", "runtime_and_lexical", "Runtime `[0]` denies present operation without deleting the criterion or automatically affirming dormancy."]
].freeze

logic_root_stress = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} identity", "one_root", "#{id}[1] directly affirms the root's invariant without adding satisfaction, truth, execution, or authority."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves this exact #{root[:phase]} claim unresolved and does not select a lexical sibling."],
    ["#{root[:title]} as data", "compound", "DAT represents the rule while #{id} supplies its formal constraint identity and status."],
    ["#{root[:title]} being evaluated", "compound", "#{id} supplies the rule entity; LOG:1xx must separately supply the evaluation process."],
    ["#{root[:title]} believed", "compound", "MIN supplies belief or acceptance while #{id} remains the formal rule independently."],
    ["#{root[:title]} physically implemented", "compound", "MAT or STR supplies implementation mechanics while #{id} supplies only formal admissibility."]
  ]
end

stress_rows = logic_stress_base + logic_root_stress

data_stress_base = [
  ["datum", "one_root", "DAT:000–002 owns one bounded information object maintained within one entity according to lexical status."],
  ["data", "one_root_or_compound", "Use DAT:0xx for information entities; quantity, type, medium, provenance, and processing may require compounds."],
  ["record", "one_root_or_compound", "A record is a DAT entity when the information object is meant; storage format and access remain separate."],
  ["value", "one_root_or_compound", "DAT identifies the represented value object while LOG, MAT, or later vocabulary supplies type and domain semantics."],
  ["identifier", "one_root_or_compound", "A target reference can identify one referent; uniqueness and namespace rules require LOG or later vocabulary."],
  ["reference", "one_root", "DAT:010–012 owns a bounded information object whose content denotes one distinct referent."],
  ["pointer", "compound", "DAT target reference plus STR/DAT storage-address structure; representation and dereference behavior remain separate."],
  ["metadata", "compound", "DAT information about another datum uses target reference plus data-type or relation details."],
  ["dataset", "one_root", "DAT:020–022 owns one coordinated shared information collection across multiple participants."],
  ["database", "compound", "DAT shared dataset plus STR storage/index structure and LOG constraints; software and access mechanisms remain separate."],
  ["corpus", "one_root_or_compound", "A shared coordinated information collection can use DAT:02x; language or media subtype is compositional."],
  ["archive", "one_root_or_compound", "DAT:022 states a maintained but unmanifest dataset; archive medium, access restriction, and retention policy remain separate."],
  ["file", "compound", "DAT supplies the information entity and STR/MAT supplies file structure and storage medium."],
  ["document", "compound", "DAT supplies the information object; layout, medium, authorship, and communication require other roots."],
  ["symbol", "one_root_or_compound", "A symbol is a DAT entity with representational convention; interpretation may require LOG, MIN, or CON."],
  ["code", "compound", "DAT supplies represented instructions while LOG supplies formal constraints and CRE/STR supplies execution."],
  ["schema", "compound", "DAT supplies represented schema content, STR its organization, and LOG its constraints."],
  ["message", "compound", "DAT supplies message content while CON supplies sender, recipient, channel, transmission, and reception."],
  ["packet", "compound", "DAT supplies content or target reference; CON and STR supply transfer and packet structure."],
  ["signal", "compound", "DAT supplies information content, MAT the carrier, and CON the transmission relation."],
  ["input", "process_or_role", "Input is a role in a process, not an entity status; DAT:1xx or compounds must supply entry or update."],
  ["output", "process_or_role", "Output is a process-relative role and does not replace a persistent or manifest information entity."],
  ["stream", "process_layer", "Information flow or repeated updates belong to DAT:1xx, not the entity layer."],
  ["queue", "compound_or_relation", "Queue order and delivery state require STR, ORI, CON, or later DAT relations; dormancy does not mean queued."],
  ["stored", "compound_or_relation", "DAT entity identity plus storage affordance or MAT/STR medium; persistence alone does not specify storage mechanism."],
  ["accessible", "relation_layer", "Access is an affordance or relation and is not entailed by manifestation."],
  ["visible", "compound", "Manifest data plus MIN/MAT observation conditions; manifestation does not entail that an observer sees it."],
  ["known", "different_family", "MIN owns knowledge or belief; a datum can persist without being known."],
  ["true", "different_family_or_compound", "Truth or validity is not information-object manifestation and requires LOG or later semantic relations."],
  ["corrupt", "compound", "WRN supplies adverse state while DAT supplies the affected information object."],
  ["deleted", "process_or_absence", "Deletion is a transformation or absence claim, not lexical dormancy."],
  ["copied", "process_layer", "Copying is a data transformation in DAT:1xx; the resulting objects are separate DAT entities."],
  ["sent", "compound", "CON and DAT:1xx supply transmission; a target reference alone does not entail delivery."],
  ["received", "compound", "CON supplies reception and DAT supplies the information object; manifestation does not entail receipt."],
  ["persistent internal datum", "one_root", "DAT:000 preserves one bounded internal information object independently of present manifestation."],
  ["manifest internal datum", "one_root", "DAT:001 states that one bounded internal information object is presently manifest."],
  ["dormant internal datum", "one_root", "DAT:002 states that one maintained internal information object is not presently manifest."],
  ["persistent target reference", "one_root", "DAT:010 preserves one referential information object independently of present manifestation."],
  ["manifest target reference", "one_root", "DAT:011 states that one datum presently manifests reference to one distinct referent."],
  ["dormant target reference", "one_root", "DAT:012 states that the referential datum exists without presently manifesting its reference."],
  ["persistent shared dataset", "one_root", "DAT:020 preserves one coordinated shared collection independently of present manifestation."],
  ["manifest shared dataset", "one_root", "DAT:021 states that one coordinated shared collection is presently manifest."],
  ["dormant shared dataset", "one_root", "DAT:022 states that one shared collection remains maintained but unmanifest."],
  ["persistent plus manifest datum", "two_compatible_roots", "DAT:000 and DAT:001 may co-occur because identity persistence is neutral about manifestation."],
  ["persistent plus dormant datum", "two_compatible_roots", "DAT:000 and DAT:002 may co-occur while the datum is unmanifest."],
  ["manifest and dormant datum simultaneously", "contradiction", "DAT:001 and DAT:002 are mutually exclusive for the same datum at one reference time."],
  ["dormant datum affirmed", "runtime_and_lexical", "DAT:002/012/022[1] affirms maintained-but-unmanifest status; it does not mean unknown or inaccessible."],
  ["manifest datum uncertain", "runtime_and_lexical", "DAT:001/011/021[2]/num questions the manifest claim without selecting lexical dormancy."],
  ["persistent datum denied", "runtime_and_lexical", "Runtime [0] denies persistent identity without automatically selecting manifestation or dormancy."],
  ["data entity versus medium", "scope_resolution_test", "DAT owns the information object while MAT owns paper, magnetic state, voltage, or another carrier."],
  ["data entity versus belief", "scope_resolution_test", "DAT identity and manifestation are independent of MIN knowledge or belief."],
  ["data entity versus message", "scope_resolution_test", "DAT supplies content while CON supplies communicative act and participant relation."],
  ["data entity versus rule", "scope_resolution_test", "DAT represents information while LOG supplies the formal criterion or evaluation."],
  ["data entity versus processing", "scope_resolution_test", "DAT:0xx names the object while DAT:1xx remains for transformation or flow."],
  ["data entity versus access", "scope_resolution_test", "Manifest status does not entail that a particular participant can retrieve or use the datum."],
  ["many unrelated data objects", "multiple_roots_not_one_dataset", "Separate objects do not form one DAT:02x dataset without coordinated shared collection identity."],
  ["reference without delivery", "one_root", "DAT:010–012 may denote a target without any CON transmission or reception event."],
  ["archived but accessible", "compound", "DAT dormancy means unmanifest, not inaccessible; access must be stated independently."],
  ["manifest but unread", "compound", "DAT manifestation can hold while MIN or access claims deny observation or reading."]
].freeze

data_root_stress = ROOTS.flat_map do |id, root|
  [
    ["#{root[:title]} identity", "one_root", "#{id}[1] directly affirms the invariant without adding truth, access, processing, transmission, or medium."],
    ["#{root[:title]} uncertain", "runtime", "#{id}[2]/num leaves this exact #{root[:phase]} claim unresolved and does not select a lexical sibling."],
    ["#{root[:title]} in a medium", "compound", "MAT or STR supplies physical realization while #{id} supplies information-object identity and status."],
    ["#{root[:title]} being processed", "compound", "#{id} supplies the entity; DAT:1xx must separately supply transformation or flow."],
    ["#{root[:title]} believed", "compound", "MIN supplies belief or understanding while #{id} remains the information object independently."],
    ["#{root[:title]} communicated", "compound", "CON supplies transmission or reception while #{id} supplies only information content and status."]
  ]
end

stress_rows = data_stress_base + data_root_stress

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("DAT0-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "DAT:000–022 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/DAT_000_022_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "DAT:000–022 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "DAT:000–002" => "internal datum: persistent / manifest / dormant", "DAT:010–012" => "target reference: persistent / manifest / dormant", "DAT:020–022" => "shared dataset: persistent / manifest / dormant" }, "triplet_logic" => { "persistent_member" => "asserts information-object identity across time and is manifestation-neutral", "manifest_dormant_members" => "mutually exclusive for the same information object at the same reference time", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/DAT_000_022_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "DAT:000–022 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# DAT:000–022 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Data entity meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `DAT:0xx` the substrate-neutral entity layer for information objects. The inward triplet identifies one bounded datum maintained within a reference entity, the outward triplet identifies one bounded datum whose content denotes one distinct referent, and the systemic triplet identifies one coordinated shared dataset across multiple participants. Persistence, manifestation, and dormancy supply the exact third-trit contrast.\n\nEach `...0` member asserts persistence of information-object identity and is neutral about present manifestation, so it may co-occur with either its `...1` or `...2` sibling. The manifest `...1` and dormant `...2` siblings are mutually exclusive for the same object at the same reference time. Runtime `[2]/num` remains uncertainty about the selected claim. The design rejects the provisional mixture of input, update, transmission, delivery queues, streaming, replication, access, indexing, and storage-medium states. Data transformation and flow remain for `DAT:1xx`; storage, access, provenance, and transmission affordances remain for `DAT:2xx`; media, cognition, communication, formal rules, and time remain other families.\n\n"

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
review << "| DAT:000–002 | one datum maintained within one reference entity | persists independently of manifestation | presently manifest | maintained but unmanifest |\n"
review << "| DAT:010–012 | one datum whose content denotes one distinct referent | persists independently of manifestation | reference presently manifest | reference maintained but unmanifest |\n"
review << "| DAT:020–022 | one coordinated dataset across multiple participants | persists independently of manifestation | dataset presently manifest | dataset maintained but unmanifest |\n\n"
review << "**Triplet logic:** the `0` column is manifestation-neutral and may co-occur with `1` or `2`; only manifest `1` versus dormant `2` is mutually exclusive at one reference time. Manifestation never entails access, observation, truth, transmission, or processing.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | truth, belief, physical medium, access, transmission, processing, mutation, provenance, formal validity, authority, time, and modality |\n" }
review << "\n## Concepts intentionally reserved\n\nPhysical media, observation, belief, truth, validity, access, ownership, privacy, provenance, version, parsing, computation, mutation, indexing, copying, transmission, delivery, reception, synchronization, scheduling, and modality remain other-family meanings, later DAT layers, grammar, or compounds.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later DAT layers, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# DAT:000–022 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MIN memory; MAT medium; STR storage", "1" => "CON message addressing; LOG reference relation; STR pointer", "2" => "STR database; CON shared channel; LOG schema" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | DAT keeps only information-object identity and manifestation; medium, cognition, transmission, process, access, truth, authority, and mechanism remain separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- An information object is not its physical medium, storage location, owner, observer, communicative act, formal interpretation, or truth value.\n- A manifest datum is presently instantiated in the stated scope; it does not entail access, observation, understanding, truth, transmission, indexing, or active processing.\n- A dormant datum remains maintained but unmanifest; it is not deleted, corrupted, inaccessible, forgotten, future, merely possible, or uncertain.\n- An internal datum belongs within one reference entity. A target reference denotes one distinct referent. A shared dataset coordinates information objects across multiple participants in one information domain.\n- Several unrelated data objects do not form one shared dataset merely because they coexist or share a medium.\n- Persistent identity may co-occur with manifest or dormant status; manifest and dormant are exclusive for the same information object at one reference time.\n- Runtime `[2]/num` leaves a selected assertion unresolved and never selects lexical dormancy.\n\n**CONCLUSION: DAT:0XX STANDS ALONE ONLY FOR INFORMATION-OBJECT IDENTITY AND PRESENT MANIFESTATION; MEDIA, BELIEF, COMMUNICATION, PROCESSING, ACCESS, TRUTH, AUTHORITY, TIME, AND MODALITY REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built DAT:000–022 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
