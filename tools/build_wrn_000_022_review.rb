#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

include EraZeroValidation

RANGE = "WRN:000–022"
IDS = EraZeroValidation.ids_for_range(RANGE)
STEM = "WRN_000_022"
SEMANTIC_CENTER = "adverse-condition entities: intrinsic faults, distinct external hazards, and correlated distributed faults"
atoms = EraZeroValidation.atoms_by_id(EraZeroValidation.load_yaml("lexicon/atoms.yaml"))
canonicalized_now = IDS.all? { |id| atoms.fetch(id)["status"] == "canonical" }

PHASE2 = {
  "WRN:000" => ["contained defect", "An inward error, weakness, or corruption is identified and bounded within an entity."],
  "WRN:001" => ["active internal fault", "An error or harmful condition is presently disrupting an entity from within."],
  "WRN:002" => ["latent defect", "An inward flaw or corruption may exist but is hidden, inactive, or not yet detectable."],
  "WRN:010" => ["known hazard", "A stable external source of danger, damage, error, or invalid behavior is identified."],
  "WRN:011" => ["active threat", "An external hazard is presently approaching, attacking, failing, or causing harm."],
  "WRN:012" => ["suspected hazard", "A possible external danger has been indicated but is inactive, inaccessible, or not yet confirmed."],
  "WRN:020" => ["contained incident field", "A system-level hazard or failure condition is known, bounded, and no longer spreading."],
  "WRN:021" => ["spreading corruption", "Error, damage, danger, or hostile behavior is actively propagating through a shared system."],
  "WRN:022" => ["latent systemic risk", "A distributed failure or hazard could emerge, but it is currently hidden or unrealized."]
}.freeze

ROOTS = {
  "WRN:000" => { title: "persistent internal fault", phase: "persistent", scope: "inward", kind: "intrinsic adverse condition", invariant: "An intrinsic adverse condition that remains identified within one reference entity independently of whether it is presently producing harmful deviation." },
  "WRN:001" => { title: "manifest internal fault", phase: "manifest", scope: "inward", kind: "intrinsic adverse condition", invariant: "An intrinsic adverse condition within one reference entity that is presently producing harmful deviation from that entity's accepted state." },
  "WRN:002" => { title: "latent internal fault", phase: "latent", scope: "inward", kind: "intrinsic adverse condition", invariant: "An intrinsic adverse condition within one reference entity that is present without presently producing harmful deviation." },
  "WRN:010" => { title: "persistent external hazard", phase: "persistent", scope: "outward", kind: "distinct external adverse condition", invariant: "A distinct external condition that remains identified as capable of adversely affecting one reference target independently of current contact or effect." },
  "WRN:011" => { title: "manifest external hazard", phase: "manifest", scope: "outward", kind: "distinct external adverse condition", invariant: "A distinct external condition that is presently expressing the harmful potential by which it can adversely affect one reference target." },
  "WRN:012" => { title: "dormant external hazard", phase: "dormant", scope: "outward", kind: "distinct external adverse condition", invariant: "A distinct external condition capable of adversely affecting one reference target that is present without presently expressing that harmful potential." },
  "WRN:020" => { title: "persistent distributed fault", phase: "persistent", scope: "systemic", kind: "correlated distributed adverse condition", invariant: "One correlated adverse condition that remains identified across multiple participant entities within a shared system independently of its present manifestation pattern." },
  "WRN:021" => { title: "manifest distributed fault", phase: "manifest", scope: "systemic", kind: "correlated distributed adverse condition", invariant: "One correlated adverse condition that is presently producing harmful deviation across multiple participant entities within a shared system." },
  "WRN:022" => { title: "latent distributed fault", phase: "latent", scope: "systemic", kind: "correlated distributed adverse condition", invariant: "One correlated adverse condition present across multiple participant entities within a shared system without presently producing harmful deviation." }
}.freeze

ARCHITECTURES = {
  "current_phase2" => { scores: [5, 7, 8, 4, 4, 7, 9, 7] },
  "adverse_condition_entities" => { scores: [10, 10, 10, 10, 9, 10, 10, 10] },
  "evidence_and_alarm_entities" => { scores: [8, 8, 6, 7, 4, 8, 9, 8] },
  "severity_ladder_entities" => { scores: [8, 6, 9, 5, 7, 8, 10, 7] },
  "norm_deviation_entities" => { scores: [9, 8, 7, 7, 5, 9, 8, 10] }
}.freeze

ALT_TITLES = {
  "WRN:000" => ["persistent anomaly evidence", "enduring minor defect", "persistent internal nonconformance"],
  "WRN:001" => ["active anomaly signal", "active serious fault", "manifest internal invalidity"],
  "WRN:002" => ["stored anomaly indication", "potential minor defect", "unverified internal nonconformance"],
  "WRN:010" => ["persistent warning object", "enduring external threat", "persistent target mismatch"],
  "WRN:011" => ["active alarm object", "immediate external danger", "active target incompatibility"],
  "WRN:012" => ["queued warning object", "potential external threat", "unverified target mismatch"],
  "WRN:020" => ["persistent shared alarm", "enduring crisis condition", "persistent systemic inconsistency"],
  "WRN:021" => ["active shared alarm", "active crisis condition", "manifest systemic invalidity"],
  "WRN:022" => ["stored shared warning", "potential crisis condition", "unverified systemic inconsistency"]
}.freeze

CROSS_FAMILY = {
  "LIF" => "LIF owns living identity, health state, care, harm to organisms, and social collectives. WRN may classify an adverse condition affecting life, but it does not itself assert injury, illness, fear, care, or social identity.",
  "MOV" => "MOV owns location, approach, traversal, redirection, and shared motion. A moving object can be hazardous, but WRN names the adverse condition rather than the displacement or route.",
  "MAT" => "MAT owns substance, energy, force, contact, fracture, and other physical states. WRN names the adverse significance of a condition; material damage, collision, heat, and pressure require MAT claims.",
  "MIN" => "MIN owns perception, belief, attention, intention, fear, and suspicion. A fault or hazard may be unknown or disbelieved and still exist; uncertainty in an observer is not lexical latency in WRN.",
  "CON" => "CON owns signals, alerts, messages, channels, and participant exchange. Communicating a warning does not create the adverse condition, and an uncommunicated condition may still be WRN:0xx.",
  "REP" => "REP owns diagnosis as restoration work, repair, recovery, replacement, and maintenance. A WRN entity may motivate repair but does not assert that repair is possible, attempted, or successful.",
  "STR" => "STR owns positions, interfaces, arrangements, transformations, and structural affordances. A malformed or unsafe structure needs WRN for adversity and STR for the structural fact; neither family subsumes the other.",
  "LOG" => "LOG owns validity, contradiction, permission, constraints, type judgments, and formal nonconformance. WRN does not make a proposition false or a value invalid merely because its consequences are dangerous.",
  "DAT" => "DAT owns records, error codes, evidence, measurements, schemas, and provenance. Data can describe a fault or hazard without being that condition; corrupted information requires DAT plus WRN when adversity is asserted.",
  "CRE" => "CRE owns generation, design, fabrication, mutation, and destruction as transformations of artifacts. A defect may result from creation or destruction, but WRN:0xx names the adverse condition after causal history is factored out.",
  "ORI" => "ORI owns time, existence, general possibility, necessity, and manifestation. WRN lexical stable, active, and dormant status is specific to adverse conditions and never replaces tense, probability, or unrestricted modality."
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
    values[0] -= 1 if ["0", "2"].include?(third)
    values[3] -= 1 if second == "2"
  when "adverse_condition_entities"
    values[4] += 1 if second == "0"
    values[6] -= 1 if second == "2"
  when "evidence_and_alarm_entities"
    values[4] -= 2 if second == "1"
    values[2] -= 1 if third == "2"
  when "severity_ladder_entities"
    values[1] -= 2 if second == "2"
    values[3] -= 1 if third == "0"
  when "norm_deviation_entities"
    values[4] -= 2 if second == "1"
    values[2] -= 1 if second == "2"
  end
  values.map { |value| [[value, 1].max, 10].min }
end

def candidate_analysis(id, architecture, title)
  root = ROOTS.fetch(id)
  case architecture
  when "current_phase2"
    {
      "why_it_fits" => "The provisional title follows the #{root.fetch(:scope)} and #{root.fetch(:phase)} slot labels and uses familiar warning vocabulary such as defect, threat, incident, corruption, and risk.",
      "useful_coverage" => "It reaches common talk about bugs, dangers, attacks, outages, spreading failures, and latent risks.",
      "semantic_territory_consumed" => "Across the block it mixes adverse conditions, evidence status, boundedness, approach, attack processes, causal harm, propagation, probability, and confirmation.",
      "conflicts_or_future_limitations" => "The mixed definitions are disjunctive, active roots absorb WRN processes and relations, and dormant roots confuse observer uncertainty with a condition's lexical inactivity."
    }
  when "adverse_condition_entities"
    {
      "why_it_fits" => "The first trit stays entity/condition; the second alone selects an intrinsic fault, a distinct external hazard, or one correlated distributed fault; the third alone selects persistent identity, present manifestation, or dormant/latent manifestation.",
      "useful_coverage" => "It supplies compact atoms for defects, bugs, hazards, threats, compromised nodes, outbreaks, systemic faults, silent failures, safety engineering, monitoring, and exception handling.",
      "semantic_territory_consumed" => "Only the substrate-neutral identity and manifestation state of an adverse condition. Evidence, belief, signals, damage mechanics, formal invalidity, warning actions, repair, probability, and causal history remain separate.",
      "conflicts_or_future_limitations" => "Broad English words such as error, failure, danger, attack, corruption, incident, and risk require sense resolution or compounds, but the resulting atoms remain stable and highly compositional."
    }
  when "evidence_and_alarm_entities"
    {
      "why_it_fits" => "Anomaly evidence, warning objects, and shared alarms can be stored, active, or dormant and are strongly associated with the Warning family.",
      "useful_coverage" => "It would directly cover logs, alerts, indicators, sirens, badges, notifications, and incident tickets.",
      "semantic_territory_consumed" => "Representations and communications about adverse conditions rather than the conditions themselves.",
      "conflicts_or_future_limitations" => "DAT owns records and evidence, CON owns alerts and signals, and MIN owns recognition; a quiet or missing alarm would incorrectly imply no underlying fault."
    }
  when "severity_ladder_entities"
    {
      "why_it_fits" => "Defect, threat, and crisis form an intuitive increase in seriousness and have natural stable, active, and potential readings.",
      "useful_coverage" => "It would make common severity distinctions concise in conversation, operations, medicine, security, and incident management.",
      "semantic_territory_consumed" => "Impact magnitude and urgency rather than inward, outward, and systemic reference scope.",
      "conflicts_or_future_limitations" => "Severity is contextual and graded, does not perfectly track the second trit, and would make the address cube encode policy-dependent thresholds rather than universal semantic direction."
    }
  when "norm_deviation_entities"
    {
      "why_it_fits" => "Internal nonconformance, target mismatch, and systemic inconsistency are precise technical warning conditions aligned with inward, outward, and shared scope.",
      "useful_coverage" => "It would serve validation, type checking, contracts, protocol compatibility, tests, invariants, and formal verification.",
      "semantic_territory_consumed" => "Departure from an explicit norm, rule, schema, contract, or proposition.",
      "conflicts_or_future_limitations" => "LOG owns validity and constraints and DAT owns schema conformance; many hazards are fully conformant, while many invalid states are harmless."
    }
  end
end

def alternative_invariant(id, architecture)
  root = ROOTS.fetch(id)
  case architecture
  when "evidence_and_alarm_entities"
    "A #{root.fetch(:phase)} evidential or alarm object concerning an adverse condition at #{root.fetch(:scope)} scope."
  when "severity_ladder_entities"
    "A #{root.fetch(:phase)} adverse entity at a severity level conventionally associated with #{root.fetch(:scope)} scope."
  when "norm_deviation_entities"
    "A #{root.fetch(:phase)} departure from an applicable norm at #{root.fetch(:scope)} scope."
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
  siblings = %w[0 1 2].reject { |x| x == third }.map { |x| "WRN:#{first}#{second}#{x}" }
  scopes = %w[0 1 2].reject { |x| x == second }.map { |x| "WRN:#{first}#{x}#{third}" }
  process = "WRN:1#{second}#{third}"
  relation = "WRN:2#{second}#{third}"
  (siblings + scopes + [process, relation]).uniq
end

def roles
  {
    "low" => "reference entity or target under evaluation",
    "middle" => "adverse condition as the asserted figure",
    "high" => "distinct external hazard source or affected participant",
    "sustained" => "shared system containing correlated participants"
  }
end

def runtime_states(id)
  root = ROOTS.fetch(id)
  case id[-1]
  when "0"
    {
      "0" => "Denies that the persistent #{root.fetch(:kind)} remains identified in the stated warning context; it does not affirm the manifest or dormant sibling and does not assert safety in every other respect.",
      "1" => "Affirms that the #{root.fetch(:kind)} persists as identified, without deciding current harmful manifestation, evidence, awareness, severity, damage, response, probability, or causal history beyond the invariant.",
      "2/num" => "Leaves unresolved whether the persistent #{root.fetch(:kind)} remains identified; the token stays the stable lexical root and does not become the manifest or dormant sibling."
    }
  when "1"
    {
      "0" => "Denies the present #{root.fetch(:phase)} condition of this #{root.fetch(:kind)}; persistence, dormancy, past manifestation, future manifestation, and observer knowledge remain undecided.",
      "1" => "Affirms that this #{root.fetch(:kind)} is presently #{root.fetch(:phase)}, without asserting a particular material mechanism, alert, belief, formal violation, repair action, severity, or final harm outcome.",
      "2/num" => "Leaves unresolved whether this #{root.fetch(:kind)} is presently #{root.fetch(:phase)}; runtime uncertainty does not select the persistent or dormant lexical sibling."
    }
  else
    {
      "0" => "Denies the #{root.fetch(:phase)} adverse-condition status named by this root; it does not affirm the persistent or manifest sibling and does not by itself certify complete safety.",
      "1" => "Affirms exactly that this #{root.fetch(:kind)} is #{root.fetch(:phase)}, without adding concealment from an observer, lack of evidence, probability, schedule, intention, damage, or response.",
      "2/num" => "Leaves unresolved whether even the lexical #{root.fetch(:phase)} condition holds; lexical third-trit 2 still names nonmanifest status, while runtime `[2]/num` marks uncertainty about the whole assertion."
    }
  end
end

def examples_for(id)
  root = ROOTS.fetch(id)
  entries = case id[-2]
            when "0"
              english = {
                "0" => "The account still has the same internal fault even when no error is visible.",
                "1" => "The payment service has an internal fault producing wrong totals right now.",
                "2" => "The device contains a latent fault that is not currently affecting operation."
              }.fetch(id[-1])
              physical = {
                "0" => "The beam retains an intrinsic crack condition even while unloaded.",
                "1" => "The cracked bearing is presently producing harmful vibration inside the pump.",
                "2" => "A hidden inclusion remains in the casting without presently deforming it."
              }.fetch(id[-1])
              program = {
                "0" => "The parser object retains a known internal defect across executions.",
                "1" => "The arithmetic bug is presently generating invalid output in this process.",
                "2" => "The race defect exists in the module but is not manifest in this execution."
              }.fetch(id[-1])
              [
                ["ordinary_conversation", "#{id}[1](ENTITY=e,FAULT=f)", "affirm #{root.fetch(:phase)} intrinsic adverse condition", english, "The root asserts the condition, not whether anyone knows or reports it."],
                ["physical_or_spatial", "MAT(BODY=b)+#{id}[1](ENTITY=b,FAULT=f)", "material body plus #{root.fetch(:phase)} internal fault", physical, "MAT supplies the physical realization; WRN supplies adverse status."],
                ["temporal_or_sequential", "#{id}[1](ENTITY=e,FAULT=f)+ORI(INTERVAL=w)", "internal fault status during interval w", "During the test interval, the entity has the stated internal-fault status.", "ORI supplies time; the lexical third trit supplies manifestation status, not tense."],
                ["cross_family_compound", "DAT(EVIDENCE=d)+MIN(AWARE=a)+#{id}[1](ENTITY=e,FAULT=f)", "evidence and awareness plus intrinsic fault", "The inspection record and the observer's awareness are separate from the internal fault itself.", "DAT and MIN can track a fault without constituting it."],
                ["executable_or_programming", "#{id}[1](ENTITY=module,FAULT=bug)", "assert #{root.fetch(:phase)} internal fault", program, "The program may test evidence, but the semantic assertion concerns the adverse condition."],
                ["counterexample", "LOG(INVALID=true)", "formal invalidity", "The proof step is invalid.", "Formal invalidity belongs to LOG unless an additional WRN claim says it is adverse in the relevant context."]
              ]
            when "1"
              english = {
                "0" => "That exposed cable remains an external hazard even while nobody is near it.",
                "1" => "The external hazard is presently expressing the condition that can harm this target.",
                "2" => "The dormant hazard is present but its harmful potential is not currently expressed."
              }.fetch(id[-1])
              physical = {
                "0" => "The unsecured ledge remains a fall hazard independently of current contact.",
                "1" => "The energized arc is presently expressing its harmful potential toward nearby equipment.",
                "2" => "The isolated chemical remains a dormant external hazard while sealed."
              }.fetch(id[-1])
              program = {
                "0" => "The untrusted input source remains a hazard to this parser even when idle.",
                "1" => "The malicious payload is presently expressing the harmful condition relevant to this parser.",
                "2" => "The quarantined payload remains present as a dormant external hazard."
              }.fetch(id[-1])
              [
                ["ordinary_conversation", "#{id}[1](HAZARD=h,TARGET=t)", "affirm #{root.fetch(:phase)} external hazard", english, "The root preserves one hazard distinct from one reference target."],
                ["physical_or_spatial", "MAT(SOURCE=s)+#{id}[1](HAZARD=s,TARGET=t)", "material source plus #{root.fetch(:phase)} external hazard", physical, "MAT supplies the source and mechanics; WRN supplies adverse significance."],
                ["temporal_or_sequential", "#{id}[1](HAZARD=h,TARGET=t)+ORI(INTERVAL=w)", "external-hazard status during interval w", "During the maintenance window, the source has the stated external-hazard status relative to the target.", "ORI locates the claim; lexical status is not a schedule."],
                ["cross_family_compound", "MOV(APPROACH=p)+MAT(ENERGY=q)+#{id}[1](HAZARD=h,TARGET=t)", "approach and physical energy plus external hazard", "The moving object has physical energy and is separately classified as the stated external hazard.", "Motion and matter explain mechanics; WRN supplies the adverse condition."],
                ["executable_or_programming", "#{id}[1](HAZARD=input,TARGET=parser)", "assert #{root.fetch(:phase)} external hazard", program, "Input provenance and formal validity remain DAT/LOG."],
                ["counterexample", "MOV:101[1](MOVER=m,PATH=p)", "ongoing approach", "The bicycle is approaching the gate.", "Approach is MOV; it becomes a WRN hazard only when adverse capability is separately asserted."]
              ]
            else
              english = {
                "0" => "The service cluster retains one distributed fault identity across its affected nodes.",
                "1" => "The distributed fault is presently producing failures across several services.",
                "2" => "The correlated fault is present across the cluster but is not currently manifesting failures."
              }.fetch(id[-1])
              physical = {
                "0" => "The contamination pattern remains one distributed adverse condition across several rooms.",
                "1" => "The same correlated contamination is presently producing harmful effects across multiple rooms.",
                "2" => "The correlated contamination remains across the rooms without currently producing detectable harmful effects."
              }.fetch(id[-1])
              program = {
                "0" => "The cluster retains one distributed fault identity across node restarts.",
                "1" => "The correlated fault is presently producing errors across multiple nodes.",
                "2" => "The compromised configuration is present across nodes but dormant in this execution window."
              }.fetch(id[-1])
              [
                ["ordinary_conversation", "#{id}[1](SYSTEM=s,PARTICIPANTS={a,b},FAULT=f)", "affirm #{root.fetch(:phase)} distributed fault", english, "The root requires one correlated condition across multiple participants, not merely many unrelated faults."],
                ["physical_or_spatial", "MAT(SUBSTRATES={a,b})+#{id}[1](SYSTEM=s,PARTICIPANTS={a,b},FAULT=f)", "material substrates plus #{root.fetch(:phase)} distributed fault", physical, "MAT supplies physical manifestation; WRN supplies correlated systemic adversity."],
                ["temporal_or_sequential", "#{id}[1](SYSTEM=s,PARTICIPANTS={a,b},FAULT=f)+ORI(INTERVAL=w)", "distributed-fault status during interval w", "Across the interval, the shared system has the stated distributed-fault status.", "ORI supplies the interval; WRN supplies scope and manifestation status."],
                ["cross_family_compound", "CON(DEPENDENCIES=g)+DAT(OBSERVATIONS=d)+#{id}[1](SYSTEM=s,PARTICIPANTS={a,b},FAULT=f)", "dependencies and observations plus distributed fault", "The communication graph and measurements help characterize one distributed adverse condition.", "CON and DAT describe linkage and evidence; neither alone establishes correlated adversity."],
                ["executable_or_programming", "#{id}[1](SYSTEM=cluster,PARTICIPANTS=nodes,FAULT=f)", "assert #{root.fetch(:phase)} distributed fault", program, "The assertion requires correlation across nodes rather than a list of independent exceptions."],
                ["counterexample", "WRN:001[1](ENTITY=a,FAULT=x)+WRN:001[1](ENTITY=b,FAULT=y)", "two unrelated manifest internal faults", "Two machines happen to fail for unrelated reasons.", "Multiple faults are not one systemic WRN:02x condition without a shared correlated adverse identity."]
              ]
            end
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
      "pseudocode" => category == "executable_or_programming" ? "assert(adverse_condition.matches?(#{id.inspect}))" : nil
    }.compact
  end
end

scored_roots = IDS.map do |id|
  root = ROOTS.fetch(id)
  old_title, old_definition = PHASE2.fetch(id)
  alt = ALT_TITLES.fetch(id)
  candidates = [
    candidate(id, "current_phase2", old_title, old_definition),
    candidate(id, "adverse_condition_entities", root.fetch(:title), root.fetch(:invariant)),
    candidate(id, "evidence_and_alarm_entities", alt[0], alternative_invariant(id, "evidence_and_alarm_entities")),
    candidate(id, "severity_ladder_entities", alt[1], alternative_invariant(id, "severity_ladder_entities")),
    candidate(id, "norm_deviation_entities", alt[2], alternative_invariant(id, "norm_deviation_entities"))
  ]
  {
    "canonical_id" => id,
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atoms.fetch(id)),
    "current_meaning_rationale" => candidate_analysis(id, "current_phase2", old_title).fetch("why_it_fits"),
    "candidates" => candidates,
    "recommended_candidate_id" => "adverse_condition_entities",
    "recommendation_reason" => "Only this architecture keeps all nine roots as substrate-neutral adverse conditions, follows inward/outward/systemic scope exactly, gives every triplet one manifestation axis, and leaves evidence, belief, signaling, mechanics, validity, response, repair, probability, and causation to their proper families or later WRN layers.",
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
  state_label = { "0" => "stable/persistent", "1" => "active/presently manifest", "2" => "dormant/presently nonmanifest" }.fetch(third)
  scope_explanation = {
    "0" => "one intrinsic adverse condition located within a reference entity",
    "1" => "one adverse condition distinct from and externally oriented toward one reference target",
    "2" => "one correlated adverse condition distributed across multiple participants in a shared system"
  }.fetch(second)
  scope_boundary = {
    "0" => "The claim is about an adverse condition intrinsic to the reference entity, not about an external source, an observer's belief, or a diagnostic record.",
    "1" => "The claim preserves one hazard as distinct from one target. Actual contact, approach, attack, exposure, damage, and warning actions remain separate processes or relations.",
    "2" => "The claim requires one correlated adverse identity across multiple participants. A coincidental collection of unrelated faults is not systemic, and the communication or dependency graph that links participants is separate."
  }.fetch(second)
  triplet_logic = if third == "0"
                    "The persistent member is manifestation-neutral: it may co-occur with the manifest sibling or the dormant sibling at the same reference time. It asserts continuity of adverse-condition identity rather than a third mutually exclusive manifestation value."
                  else
                    "The persistent sibling may also hold because it asserts adverse-condition identity across time. Manifest and dormant siblings are mutually exclusive for the same condition at the same reference time, while runtime `[2]/num` may leave either selected claim unresolved."
                  end
  {
    "fixed_generated_fields" => EraZeroValidation.packet_fixed_projection(atom),
    "proposal_status" => canonicalized_now ? "canonical_by_delegated_approval" : "recommended_pending_delegated_approval",
    "proposed_title" => root.fetch(:title),
    "invariant_definition" => root.fetch(:invariant),
    "semantic_center" => SEMANTIC_CENTER,
    "address_justification" => {
      "first_trit_0" => "Selects an entity or condition: #{root.fetch(:title)} is an adverse condition, not its detection, warning, containment, propagation, causal mechanism, susceptibility relation, evidence record, or repair.",
      "second_trit" => "Selects #{scope_label} scope: #{scope_explanation} and no other Warning-family column.",
      "third_trit" => "Selects the #{state_label} condition by adverse identity or manifestation while leaving runtime truth status, observer knowledge, tense, probability, and response phase separate."
    },
    "inclusion_boundary" => "Includes only the #{root.fetch(:phase)} #{root.fetch(:kind)} as a substrate-neutral claim about #{scope_explanation}. #{scope_boundary} It is neutral about physical mechanism, observer knowledge, evidential certainty, signaling, formal validity, moral blame, repairability, severity, probability, timing, and response.",
    "excluded_meanings" => [
      "The person, organism, material object, software component, institution, or system that bears, causes, observes, records, or responds to the condition.",
      "Physical fracture, force, heat, collision, displacement, approach, biological injury, illness, fear, or pain without a separate applicable WRN adverse classification.",
      "Formal falsehood, invalidity, contradiction, type error, permission violation, incompatibility, or schema mismatch merely as a rule judgment.",
      "Alarm, warning message, symptom report, log entry, error code, measurement, diagnosis, belief, suspicion, attention, or evidence about the condition.",
      "Detecting, warning, attacking, spreading, containing, isolating, shutting down, repairing, recovering, or responding as a process or relation.",
      "Severity, probability, uncertainty to an observer, possible future occurrence, schedule, cause, blame, intent, exploitability, vulnerability, exposure, or guaranteed harm."
    ],
    "nearest_neighbors" => nearest_neighbors(id),
    "same_family_contrast" => "`WRN:0xx` owns adverse conditions as entities; `WRN:1xx` remains the process layer for detecting, warning, containing, or responding; `WRN:2xx` remains the capacity/relation layer for susceptibility, exposure, and systemic risk relations. Manifestation in 0xx does not itself name the process that caused, detected, communicated, propagated, or remediated it, and an adverse condition does not entail a particular vulnerability or exposure relation. #{triplet_logic}",
    "cross_family_comparisons" => CROSS_FAMILY,
    "runtime_state_interpretation" => runtime_states(id),
    "lexical_runtime_distinction" => "Lexical third trit `#{third}` permanently selects the #{state_label} member of this adverse-condition triplet. Runtime `[2]/num` instead leaves the truth or applicability of that already-selected root unresolved; it never changes manifestation phase. Thus a latent root affirmed with `[1]` is a confirmed latent condition, while a persistent or manifest root carrying `[2]/num` remains lexically persistent or manifest but uncertain as a token claim.",
    "examples" => examples_for(id),
    "future_compound_examples" => [
      "#{id} + MAT/LIF supplies the physical or living bearer and concrete harm mechanism without reducing adverse status to matter or biology.",
      "#{id} + MOV/ORI supplies approach, location, sequence, or time without turning manifestation status into motion or tense.",
      "#{id} + DAT/MIN/CON supplies evidence, recognition, or a warning signal while preserving the underlying adverse condition as independent.",
      "#{id} + WRN:1xx/2xx may later express detection, warning, containment, susceptibility, exposure, or propagation as separate processes or relations."
    ],
    "later_era_notes" => "Later eras may lexicalize bug, crack, contamination, malware, pathogen, hostile actor, outage, cascading failure, incident, emergency, defect class, symptom, severity, and confidence. Era Zero should preserve the adverse-condition center and derive domain-specific senses compositionally. The stable/persistent root must not be treated as mutually exclusive with its manifest or dormant sibling.",
    "confidence" => 0.96,
    "canonicalized" => canonicalized_now
  }
end


stress_rows = [
  ["defect", "one_root_or_compound", "WRN:00x when an intrinsic adverse condition is meant; add MAT, DAT, LOG, or domain roots for its realization or classification."],
  ["persistent defect", "one_root", "WRN:000 names an intrinsic adverse condition that remains identified independently of current manifestation."],
  ["active defect", "one_root", "WRN:001 names an intrinsic adverse condition presently producing harmful deviation."],
  ["latent defect", "one_root", "WRN:002 names an intrinsic adverse condition present without current harmful deviation."],
  ["bug", "one_root_or_compound", "WRN:00x supplies adverse-condition status; DAT/LOG/program-domain composition supplies code, rule, and output details."],
  ["software bug firing", "one_root", "WRN:001 applies when an intrinsic software fault is presently producing harmful deviation."],
  ["dormant race condition", "one_root", "WRN:002 applies when the intrinsic fault exists but does not manifest in the current execution."],
  ["syntax error", "different_family_or_compound", "LOG/DAT owns formal invalidity or encoding; add WRN only when adverse status beyond invalidity is asserted."],
  ["wrong answer", "different_family_or_compound", "LOG owns incorrectness and DAT the output; WRN:001 applies only if an intrinsic adverse condition is also claimed."],
  ["crack", "compound", "MAT names the physical discontinuity; WRN:00x classifies it as an intrinsic adverse condition when context warrants."],
  ["fracture causing vibration", "compound", "MAT fracture and force effects plus WRN:001 manifest internal fault."],
  ["harmless variation", "not_warning", "A difference that is not adverse must not be forced into WRN even if unusual or statistically rare."],
  ["anomaly", "underspecified", "May mean DAT statistical deviation, MIN surprise, LOG nonconformance, or a WRN adverse condition; translator must resolve the sense."],
  ["symptom", "different_family_or_compound", "A symptom may be LIF/MAT/DAT evidence of WRN:001, but evidence or effect is not automatically the underlying fault."],
  ["diagnosis", "future_process_or_compound", "Detection and classification belong to WRN:1xx review plus MIN/DAT; WRN:0xx names the condition diagnosed."],
  ["suspected defect", "runtime_or_compound", "Observer uncertainty uses MIN/DAT or runtime `[2]/num`; it must not be confused with lexical WRN:002 latency."],
  ["unknown active fault", "runtime_state", "WRN:001[2]/num leaves present manifestation unresolved; it is not WRN:002."],
  ["confirmed latent fault", "one_root_plus_runtime", "WRN:002[1] affirms that the intrinsic fault exists in nonmanifest form."],
  ["persistent fault uncertain", "one_root_plus_runtime", "WRN:000[2]/num keeps stable lexical identity while leaving the token assertion unresolved."],
  ["persistent and manifest fault", "two_compatible_roots", "WRN:000 and WRN:001 may both hold: persistence concerns identity, manifestation concerns current harmful deviation."],
  ["persistent and latent fault", "two_compatible_roots", "WRN:000 and WRN:002 may both hold when the same enduring fault is currently nonmanifest."],
  ["manifest and latent simultaneously", "invalid_same_reference_claim", "WRN:001 and WRN:002 cannot both hold for the same condition at the same reference time."],
  ["hazard", "one_root_or_compound", "WRN:01x when a distinct external adverse condition relative to one target is meant; mechanics remain in other families."],
  ["persistent hazard", "one_root", "WRN:010 names a distinct external condition that remains capable of adversely affecting one target."],
  ["active hazard", "one_root", "WRN:011 names a distinct external condition presently expressing its harmful potential."],
  ["dormant hazard", "one_root", "WRN:012 names a present external hazard whose harmful potential is not currently expressed."],
  ["threat", "one_root_or_compound", "WRN:01x supplies external adverse-condition status; intent, approach, exposure, and attack require MIN, MOV, or WRN relation/process claims."],
  ["attacker", "compound", "LIF or artifact identity plus MIN intent and WRN external-hazard status; WRN alone does not mean person or agency."],
  ["attack", "future_process_or_compound", "An attack is an action or harmful relation, not a WRN:0xx entity; use the later WRN process/relation review plus domain roots."],
  ["approaching danger", "compound", "MOV approach plus WRN:011 only when the external adverse condition is presently manifest toward the target."],
  ["destination", "different_family", "MOV owns destinations; being a destination does not entail hazard."],
  ["obstacle", "compound", "MAT/STR/MOV describes the blocking object or relation; WRN adds adverse significance only in context."],
  ["exposed wire", "compound", "MAT describes the wire and exposure geometry; WRN:010 or 011 classifies external adverse status relative to a target."],
  ["sealed poison", "one_root_or_compound", "WRN:012 can name a dormant external hazard; MAT supplies the substance and containment."],
  ["loaded weapon", "compound", "MAT and CRE describe the artifact and state; WRN:01x supplies context-dependent hazard status."],
  ["warning sign", "different_family_or_compound", "DAT/CON owns the sign and communicated warning; it may refer to WRN:010 but is not the hazard itself."],
  ["alarm", "different_family", "CON/DAT owns an alarm signal or indicator; WRN names the adverse condition signaled."],
  ["false alarm", "compound", "CON/DAT alarm plus denial of the represented WRN condition; the alarm object does not become a fault."],
  ["unreported hazard", "one_root_plus_negation", "WRN:01x may hold while CON warning and DAT record claims are denied."],
  ["risk", "underspecified", "May mean an adverse condition, probability, vulnerability, exposure relation, or expected loss; translator must not force it into WRN:0xx."],
  ["probable hazard", "compound", "Probability or epistemic qualification plus WRN:01x; lexical third trit 2 does not encode likelihood."],
  ["future hazard", "compound_or_grammar", "ORI time/modal qualification plus WRN root; dormancy does not itself mean future."],
  ["external hazard uncertain", "runtime_state", "WRN:010[2]/num or WRN:011[2]/num questions the chosen claim; it is not automatically WRN:012."],
  ["confirmed dormant hazard", "one_root_plus_runtime", "WRN:012[1] affirms present nonmanifest external hazard status."],
  ["hazard source and target", "one_root", "WRN:01x preserves one distinct hazard source relative to one reference target."],
  ["two targets exposed to one hazard", "compound_or_relation", "WRN:01x may be asserted per target; shared exposure or propagation belongs to WRN:2xx relation review."],
  ["incident", "one_root_or_compound", "WRN:02x only when one correlated adverse condition spans multiple participants; event sequencing may require ORI or process roots."],
  ["persistent distributed fault", "one_root", "WRN:020 preserves one correlated adverse identity across multiple system participants."],
  ["active distributed fault", "one_root", "WRN:021 says one correlated adverse condition presently produces harmful deviation across participants."],
  ["latent distributed fault", "one_root", "WRN:022 says one correlated adverse condition is present across participants without current harmful deviation."],
  ["outage", "one_root_or_compound", "WRN:021 may classify a correlated active adverse condition; service state, cause, and temporal duration require other claims."],
  ["cascading failure", "future_relation_or_compound", "Propagation and causal cascade belong to WRN:1xx/2xx review; WRN:021 only states the manifest distributed condition."],
  ["epidemic", "compound", "LIF owns organisms and health; WRN:02x may supply correlated distributed adversity, while transmission is a separate process/relation."],
  ["network breach", "compound", "DAT/CON/LOG describes network, access, and rules; WRN:02x applies only if one distributed adverse condition is asserted."],
  ["compromised cluster", "one_root_or_compound", "WRN:02x supplies the correlated distributed fault; DAT/CON/STR supplies cluster structure and linkage."],
  ["many unrelated bugs", "not_systemic_root", "A list of independent WRN:00x faults is not one WRN:02x condition without correlation and shared-system scope."],
  ["shared dependency", "different_family_or_compound", "STR/LOG/CON owns dependency; it may enable a distributed fault but is not itself adverse."],
  ["system", "underspecified", "STR, CON, DAT, LIF, or LOG may define the system; WRN:02x names only its correlated adverse condition."],
  ["emergency", "compound", "WRN condition plus urgency, response, time, and often LIF/MAT impact; not one entity root."],
  ["catastrophe", "compound_or_later_vocabulary", "Severe realized harm requires WRN with magnitude and domain effects; severity is not encoded by second trit."],
  ["contained incident", "compound", "WRN:02x supplies incident condition and WRN:1xx process/relation review supplies containment; contained does not equal stable third trit."],
  ["spreading corruption", "future_process_or_relation", "Spreading is propagation; WRN:021 may describe the resulting manifest distributed condition but must not absorb the propagation process."],
  ["systemic risk", "future_relation_or_compound", "Vulnerability, dependency, probability, and propagation possibility belong to WRN:2xx and ORI/LOG; WRN:022 requires a present correlated dormant condition."],
  ["possible outage", "compound_or_gap", "ORI probability/modality plus a WRN condition or process; WRN:022 is not bare possibility of a future outage."],
  ["distributed fault uncertain", "runtime_state", "WRN:020[2]/num or WRN:021[2]/num questions a selected distributed claim rather than selecting WRN:022."],
  ["confirmed latent distributed fault", "one_root_plus_runtime", "WRN:022[1] affirms the correlated nonmanifest system condition."],
  ["persistent and active distributed fault", "two_compatible_roots", "WRN:020 and WRN:021 may co-occur because identity persistence and present manifestation are independent claims."],
  ["harm", "different_family_or_compound", "LIF, MAT, DAT, LOG, or other domains specify what is harmed; WRN supplies adverse classification, not all effect semantics."],
  ["damage", "different_family_or_compound", "MAT or domain roots describe physical or functional loss; WRN says the condition is adverse."],
  ["failure", "underspecified", "Could mean WRN adverse condition, LOG non-satisfaction, REP loss, MAT breakage, or a process event; translator must resolve sense."],
  ["invalid", "different_family", "LOG owns validity judgments; add WRN only for adverse consequences or condition classification."],
  ["unsafe", "compound", "WRN condition plus applicable standards, target, vulnerability, or probability; not automatically one atom."],
  ["dangerous idea", "compound", "MIN/DAT supplies the idea; WRN supplies context-specific adverse status if warranted."],
  ["corrupted file", "compound", "DAT owns the information object and representational corruption; WRN adds adverse status when consequences matter."],
  ["fear", "different_family", "MIN owns fear as mental state; an actual WRN hazard may be present or absent independently."],
  ["suspicion", "different_family", "MIN owns suspicion; runtime uncertainty can qualify a WRN claim without changing lexical latency."],
  ["warning someone", "future_process_or_compound", "CON communication plus WRN:1xx process review; WRN:0xx names the adverse condition referenced."],
  ["repair", "different_family", "REP owns repair and recovery; a repaired fault may cease to hold, but repair is not a WRN entity."],
  ["vulnerability", "future_wrn_capacity", "Reserved for WRN:2xx capacity/relation review; vulnerability is not the same as an existing fault."],
  ["exposure", "future_wrn_relation", "Reserved for WRN:2xx relation review; external hazard identity does not entail target exposure."],
  ["no alarm but active fault", "one_root_plus_negation", "WRN:001 may hold while CON/DAT alarm claims are denied, proving condition and representation are separate."],
  ["alarm but no fault", "different_family_plus_negation", "CON/DAT alarm may hold while the represented WRN condition is denied."],
  ["hazard moving but not active", "compound", "MOV can describe displacement while WRN:012 asserts dormant harmful potential; motion alone does not select manifest status."],
  ["active fault with no known cause", "one_root_plus_gap", "WRN:001 can be affirmed while causal source remains unresolved; the atom does not encode cause."],
  ["same adverse condition across nodes", "one_root", "WRN:020/021/022 is selected by persistence or manifestation of one correlated distributed condition."],
  ["coincidental simultaneous failures", "multiple_roots_not_one_systemic_root", "Use separate WRN:001 assertions unless evidence supports one correlated WRN:021 identity."],
  ["latent versus unknown", "scope_resolution_test", "WRN:002[1] affirms nonmanifest existence; WRN:001[2]/num leaves manifest status epistemically unresolved."],
  ["hazard versus approach", "scope_resolution_test", "WRN:01x identifies external adverse condition; MOV identifies approach or location."],
  ["distributed condition versus propagation", "scope_resolution_test", "WRN:02x identifies a correlated system condition; WRN process/relation roots must separately express spread."],
  ["condition versus warning message", "scope_resolution_test", "WRN:0xx identifies the adverse condition; CON/DAT identifies the message or record."],
  ["condition versus vulnerability", "scope_resolution_test", "WRN:0xx identifies a present adverse condition; WRN:2xx will determine susceptibility or exposure relations."],
  ["condition versus repairability", "scope_resolution_test", "WRN:0xx identifies adversity; REP identifies capacity or process for restoration."]
].freeze

stress_tests = stress_rows.each_with_index.map do |(concept, routing, analysis), index|
  { "test_id" => format("WRN0-T%03d", index + 1), "english_concept" => concept, "routing" => routing, "analysis" => analysis }
end

scored = {
  "metadata" => { "title" => "WRN:000–022 adversarial semantic candidates", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "review_complete_pending_preapproval_validation", "architecture_version" => "1.0", "range" => RANGE, "roots_reviewed" => 9, "candidate_architectures_per_root" => 5, "scored_categories" => EraZeroValidation::SCORE_KEYS, "generated_fields_changed" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/WRN_000_022_semantic_approval.yaml" : nil },
  "roots" => scored_roots
}

recommended = {
  "metadata" => { "title" => "WRN:000–022 recommended permanent semantic specification", "status" => canonicalized_now ? "approved_and_canonical_by_delegated_authority" : "recommended_pending_delegated_approval", "architecture_version" => "1.0", "semantic_center" => SEMANTIC_CENTER, "triplets" => { "WRN:000–002" => "intrinsic adverse condition: persistent / manifest / latent", "WRN:010–012" => "distinct external hazard: persistent / manifest / dormant", "WRN:020–022" => "correlated distributed fault: persistent / manifest / latent" }, "triplet_logic" => { "persistent_member" => "asserts adverse-condition identity across time and is manifestation-neutral", "active_dormant_members" => "mutually exclusive for the same adverse condition at the same reference time", "runtime_uncertainty" => "runtime [2]/num qualifies a selected lexical claim and does not select a sibling" }, "generated_fields_changed" => false, "gate4_started" => false, "translator_started" => false, "roots_canonicalized" => canonicalized_now ? IDS : [], "approval_record" => canonicalized_now ? "migrations/WRN_000_022_semantic_approval.yaml" : nil },
  "roots" => recommended_roots,
  "approval_checklist" => { "family_domain_preserved" => true, "address_axes_preserved" => true, "one_invariant_per_root" => true, "triplets_coherent" => true, "all_current_candidates_challenged" => true, "cross_family_collisions_explicit" => true, "runtime_state_separated" => true, "entity_process_relation_layers_separated" => true, "generated_fields_unchanged" => true, "gate4_not_started" => true, "translator_not_started" => true, "canonicalized" => canonicalized_now }
}

stress = { "metadata" => { "title" => "WRN:000–022 English coverage and routing tests", "status" => "review_evidence_not_translation_dictionary", "range" => RANGE, "test_count" => stress_tests.length, "no_forced_atomization" => true }, "tests" => stress_tests }

EraZeroValidation.write("reviews/#{STEM}_scored_candidates.yaml", YAML.dump(scored))
EraZeroValidation.write("reviews/#{STEM}_recommended_spec.yaml", YAML.dump(recommended))
EraZeroValidation.write("reviews/#{STEM}_stress_tests.yaml", YAML.dump(stress))

review = +"# WRN:000–022 Adversarial Semantic Design Review\n\n"
review << (canonicalized_now ? "Status: **REVIEW EVIDENCE — CANONICAL APPROVAL RECORDED SEPARATELY**\n\n" : "Status: **RECOMMENDED — NOT CANONICAL IN THIS REVIEW ARTIFACT**\n\n")
review << "This packet challenges all nine provisional Warning entity meanings. It compares five genuinely different architectures per address, scores 45 candidates across 360 criterion values, and routes #{stress_tests.length} English concepts without forcing broad words into atoms.\n\n"
review << "## Packet-level design decision\n\nThe strongest architecture makes `WRN:0xx` the substrate-neutral entity/condition layer for adversity. The inward triplet names an intrinsic adverse condition inside one reference entity, the outward triplet a distinct external hazard relative to one target, and the systemic triplet one correlated distributed adverse condition across multiple participants. Persistence, current manifestation, and dormancy supply the exact third-trit contrast.\n\nThe third-trit grid is deliberately not a three-way exclusive partition. Each `...0` member asserts persistence of adverse-condition identity and is neutral about present manifestation, so it may co-occur with either its `...1` or `...2` sibling. The `...1` and `...2` siblings are mutually exclusive for the same condition at the same reference time. Runtime `[2]/num` remains uncertainty about the selected claim rather than a lexical sibling.\n\nThe design rejects the provisional mixture of boundedness, evidence, confirmation, approach, attack, causal harm, spread, probability, and general risk. Those require DAT, MIN, CON, MOV, LOG, ORI, domain claims, or later WRN process/relation roots.\n\n"

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
review << "| WRN:000–002 | one intrinsic adverse condition within a reference entity | remains identified regardless manifestation | presently produces harmful deviation | present without current harmful deviation |\n"
review << "| WRN:010–012 | one external adverse condition distinct from one target | remains capable regardless current expression | presently expresses harmful potential | present without current harmful expression |\n"
review << "| WRN:020–022 | one correlated adverse condition across multiple system participants | remains one distributed identity | presently produces harmful deviation across participants | present across participants without current harmful deviation |\n\n"
review << "**Triplet logic:** the `0` column is persistence-neutral with respect to present manifestation and may co-occur with `1` or `2`; only `1` versus `2` is mutually exclusive at one reference time.\n\n"
review << "## Nine-root ownership matrix\n\n| Root | Owns | Intentionally belongs elsewhere |\n| --- | --- | --- |\n"
recommended_roots.each { |root| review << "| #{root.dig('fixed_generated_fields', 'canonical_id')} | #{root['proposed_title']} | evidence, belief, signals, mechanics, validity, severity, probability, causation, warning/containment processes, vulnerability/exposure relations, and repair |\n" }
review << "\n## Concepts intentionally reserved\n\nError codes, symptoms, alarms, warnings, suspicion, fear, invalidity, attack, propagation, containment, diagnosis, severity, likelihood, vulnerability, exposure, exploitability, repairability, injury, damage mechanics, and future risk remain sense-resolved compounds, other-family meanings, or later WRN process/relation work.\n\n## English coverage stress test\n\n#{stress_tests.length} concepts were routed across atoms, compounds, runtime state, grammar, other families, later WRN layers, and unresolved senses. See `reviews/#{STEM}_stress_tests.yaml`.\n\n## Approval checklist\n\n"
recommended.fetch("approval_checklist").each { |item, value| review << "- [#{value ? 'x' : ' '}] #{item.tr('_', ' ')}\n" }
review << (canonicalized_now ? "\n**Disposition:** the packet passed reusable validation and was approved under delegated authority.\n" : "\n**Recommendation:** approve only after reusable packet validation and the complete authority regression. Until then all nine meanings remain provisional.\n")
EraZeroValidation.write("reviews/#{STEM}_peer_review.md", review)

collision = +"# WRN:000–022 Cross-Family Collision Report\n\nStatus: **COLLISIONS EXPLICITLY EXCLUDED OR RESERVED FOR COMPOSITION**\n\n## Root-level collision matrix\n\n| Root | Permanent center | Highest collision risks | Disposition |\n| --- | --- | --- | --- |\n"
recommended_roots.each do |root|
  id = root.dig("fixed_generated_fields", "canonical_id")
  risks = { "0" => "MAT/LIF damage; LOG invalidity; DAT evidence; MIN diagnosis", "1" => "MOV approach; MAT contact; MIN intent; WRN exposure/attack relation", "2" => "CON/DAT network; STR dependency; ORI probability; WRN propagation process" }.fetch(id[-2])
  collision << "| #{id} | #{root['proposed_title']} | #{risks} | WRN keeps only adverse-condition identity and manifestation; every competing layer stays separately typed |\n"
end
collision << "\n## Family-by-family audit\n\n"
CROSS_FAMILY.each { |family, explanation| collision << "- **#{family}:** #{explanation}\n" }
collision << "\n## Required non-entailments and overlap rules\n\n- An intrinsic fault is not the entity bearing it, the material mechanism, a validity judgment, a symptom, an observer's belief, or a diagnostic record.\n- An external hazard is not its approach, contact, attack, exposure relation, warning signal, target damage, or the intent of an agent.\n- A distributed fault requires one correlated adverse identity across multiple participants; several unrelated faults, a dependency graph, or simultaneous symptoms do not suffice.\n- A latent or dormant condition is asserted to exist without current harmful manifestation; hidden from an observer, unconfirmed, improbable, merely possible, or scheduled for the future are different claims.\n- A manifest condition does not entail detection, communication, attribution, severity, successful harm, containment, repairability, or causal propagation.\n- Each persistent `...0` root is neutral about the present `...1`/`...2` condition and may co-occur with either. Only manifest `...1` and dormant `...2` are mutually exclusive for one condition at one reference time.\n- Runtime `[2]/num` leaves a selected assertion unresolved and never selects the lexical latent or dormant root.\n\n**CONCLUSION: WRN:0XX STANDS ALONE ONLY FOR ADVERSE-CONDITION IDENTITY AND MANIFESTATION; BEARERS, MECHANICS, EVIDENCE, BELIEFS, SIGNALS, RULES, PROCESSES, RELATIONS, PROBABILITY, SEVERITY, AND REPAIR REMAIN SEPARATE OR COMPOUNDED.**\n"
EraZeroValidation.write("reviews/#{STEM}_collision_report.md", collision)

puts "Built WRN:000–022 review packet: #{IDS.length} roots, #{scored_roots.sum { |root| root['candidates'].length }} candidates, #{stress_tests.length} stress tests."
