#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/era_zero_validation"

ROOT = EraZeroValidation::ROOT
AXES = {
  "LIF" => {
    family: %w[life living alive person being creature health growth care],
    axes: {"00"=>["sense of self",%w[self identity person me]],"01"=>["another being",%w[other person someone individual]],"02"=>["living group",%w[community species lineage population]],"10"=>["personal awakening or growth",%w[wake awaken develop grow recover]],"11"=>["awakening or supporting another",%w[wake help activate revive]],"12"=>["growth of a living community",%w[population ecosystem grow preserve]],"20"=>["ability to stay alive",%w[viability vitality survival resilience]],"21"=>["care or bond between beings",%w[care bond kinship nurture support]],"22"=>["living system or possible life",%w[ecosystem biosystem network life]]}
  },
  "MOV" => {
    family: %w[move movement place location travel direction route position],
    axes: {"00"=>["starting or current place",%w[origin start here position location]],"01"=>["destination",%w[goal destination endpoint there]],"02"=>["route or movement network",%w[path road route corridor traffic]],"10"=>["leaving a place",%w[leave depart exit go-away]],"11"=>["approaching or reaching a place",%w[approach arrive reach come]],"12"=>["movement through the surroundings",%w[move travel cross relocate]],"20"=>["ability to move",%w[mobility movable travel ability]],"21"=>["position compared with a goal",%w[near far relative-position tracking]],"22"=>["layout of places",%w[layout map arrangement configuration]]}
  },
  "MAT" => {
    family: %w[physical matter material object body energy force],
    axes: {"00"=>["physical body or material",%w[body matter material substance]],"01"=>["physical object",%w[object item thing body]],"02"=>["group of physical parts",%w[pile collection assembly material-group]],"10"=>["physical change within something",%w[change transform heat cool break]],"11"=>["physical change to another object",%w[alter affect push damage]],"12"=>["physical change across a system",%w[system-change chain-reaction material-process]],"20"=>["capacity to do physical work",%w[energy power work strength]],"21"=>["physical connection or influence",%w[contact coupling force link]],"22"=>["mutual physical dependence",%w[interdependence interaction feedback system]]}
  },
  "MIN" => {
    family: %w[mind thought idea attention awareness memory belief learning],
    axes: {"00"=>["idea of oneself",%w[self-image self-concept identity memory]],"01"=>["idea or awareness of something",%w[idea knowledge awareness memory target]],"02"=>["shared understanding",%w[shared-belief common-knowledge worldview schema]],"10"=>["change of self-understanding",%w[rethink self-discovery change-mind]],"11"=>["learning or changing an idea",%w[learn discover notice understand revise]],"12"=>["change in shared understanding",%w[collective-learning consensus culture-change]],"20"=>["ability to pay attention",%w[focus concentration attention capacity]],"21"=>["attention toward something",%w[focus notice watch search attend]],"22"=>["shared attention",%w[joint-attention look-together shared-focus]]}
  },
  "CON" => {
    family: %w[communication message talk listen share connect conversation],
    axes: {"00"=>["speaker or sender",%w[speaker sender source caller]],"01"=>["listener or receiver",%w[listener receiver audience target]],"02"=>["communication channel",%w[channel conversation room network]],"10"=>["speaking or sending a message",%w[say speak send express write]],"11"=>["hearing or receiving a message",%w[hear listen receive read]],"12"=>["sharing a message with a group",%w[broadcast share announce publish]],"20"=>["ability to communicate",%w[communicate ability voice access]],"21"=>["direct contact between people",%w[contact connection link address]],"22"=>["group conversation",%w[group-chat participation community conversation]]}
  },
  "STR" => {
    family: %w[structure part arrangement connection container slot layout],
    axes: {"00"=>["place for a part",%w[slot position place inside]],"01"=>["connection point",%w[interface port edge connection]],"02"=>["arrangement of parts",%w[structure layout assembly container]],"10"=>["rearranging parts",%w[rearrange reorganize restructure move-parts]],"11"=>["adding or fitting a part",%w[insert attach include incorporate]],"12"=>["joining parts into one system",%w[integrate combine assemble merge]],"20"=>["ability to be rearranged",%w[configurable editable rearrangeable]],"21"=>["ability to accept another part",%w[compatible attachable insertable fit]],"22"=>["ability to integrate as a system",%w[integrable interoperable composable]]}
  },
  "WRN" => {
    family: %w[warning danger problem fault risk harm failure],
    axes: {"00"=>["problem inside something",%w[fault defect bug illness]],"01"=>["outside danger",%w[hazard danger threat risk]],"02"=>["problem across a system",%w[system-fault outage widespread-problem]],"10"=>["something getting worse inside",%w[degrade worsen decay fail]],"11"=>["harm happening to a target",%w[harm damage injure attack]],"12"=>["failure spreading across a system",%w[cascade spread outage system-failure]],"20"=>["vulnerability to an internal problem",%w[vulnerable weakness failure-risk]],"21"=>["exposure to an outside danger",%w[at-risk exposed threatened]],"22"=>["shared or system-wide risk",%w[system-risk shared-danger cascade-risk]]}
  },
  "REP" => {
    family: %w[repair restore recover heal fix maintenance],
    axes: {"00"=>["restored condition inside something",%w[recovered healthy repaired restored]],"01"=>["restored condition of another target",%w[fixed healed repaired target]],"02"=>["restored condition across a system",%w[system-recovery restored-service repaired-network]],"10"=>["recovery happening within something",%w[recover heal mend self-repair]],"11"=>["repairing another target",%w[repair fix heal restore]],"12"=>["repair across a system",%w[system-repair recovery restore-service]],"20"=>["ability to recover",%w[recoverable resilient repairable]],"21"=>["available way to repair a target",%w[fixable repair-path treatment]],"22"=>["shared recovery path",%w[backup recovery-system repair-network]]}
  },
  "LOG" => {
    family: %w[logic rule test check valid constraint policy],
    axes: {"00"=>["rule used inside something",%w[rule criterion condition test]],"01"=>["rule applied to a target",%w[constraint requirement limit policy]],"02"=>["shared set of rules",%w[rulebook regime policy system]],"10"=>["checking something against its rule",%w[check validate evaluate test]],"11"=>["applying a rule to a target",%w[enforce check constrain validate]],"12"=>["checking a group under shared rules",%w[audit group-check system-validation]],"20"=>["ability to be checked",%w[testable checkable validatable]],"21"=>["whether a rule applies",%w[applicable relevant covered-by-rule]],"22"=>["ability to check a group together",%w[joint-test audit-ready system-check]]}
  },
  "DAT" => {
    family: %w[data information file record reference dataset computer],
    axes: {"00"=>["stored information",%w[data file record information]],"01"=>["reference to something",%w[reference pointer link address]],"02"=>["shared collection of data",%w[dataset database records library]],"10"=>["changing information",%w[edit convert process transform]],"11"=>["sending information",%w[send transfer upload download migrate]],"12"=>["keeping data in sync",%w[sync synchronize align update]],"20"=>["ability to change information",%w[editable convertible processable]],"21"=>["ability to transfer information",%w[transferable sendable connected]],"22"=>["ability to synchronize data",%w[syncable synchronization replication]]}
  },
  "CRE" => {
    family: %w[create make build design produce generate],
    axes: {"00"=>["instructions or pattern for making something",%w[template design recipe blueprint program]],"01"=>["created product",%w[creation product artifact result]],"02"=>["shared creative toolkit",%w[toolkit library repertoire shared-template]],"10"=>["designing or changing a pattern",%w[design compose plan author]],"11"=>["making a product",%w[create make build generate]],"12"=>["creating something together",%w[cocreate collaborate build-together]],"20"=>["ability to design a pattern",%w[creative ability design-capacity]],"21"=>["ability to create a particular result",%w[can-create generative source]],"22"=>["ability to create together",%w[collaboration co-creation team-capacity]]}
  },
  "ORI" => {
    family: %w[existence cause source reality depend possibility condition],
    axes: {"00"=>["source or basis of something",%w[source basis ground reason origin]],"01"=>["something existing",%w[exist real presence existence]],"02"=>["condition of the shared world",%w[reality world condition context]],"10"=>["establishing a source or basis",%w[establish ground originate begin]],"11"=>["bringing something into existence",%w[appear actualize come-to-exist]],"12"=>["change in the shared world",%w[transition world-change reality-change]],"20"=>["ability to serve as a source",%w[cause grounding power source-capacity]],"21"=>["dependence on a requirement",%w[need require depend prerequisite]],"22"=>["limit on what can exist",%w[world-rule possibility-limit constraint]]}
  }
}.freeze

PHASES = {
  "0" => {
    "0" => ["lasting", %w[lasting stable persistent kept]],
    "1" => ["current", %w[current active present awake visible]],
    "2" => ["inactive or stored", %w[inactive stored hidden dormant unused]]
  },
  "1" => {
    "0" => ["finished", %w[finished completed done already]],
    "1" => ["ongoing", %w[ongoing happening active now]],
    "2" => ["possible or planned", %w[possible planned pending not-started]]
  },
  "2" => {
    "0" => ["lasting", %w[lasting established persistent available-in-principle]],
    "1" => ["active", %w[current working available active usable]],
    "2" => ["possible but inactive", %w[possible inactive latent unavailable unresolved]]
  }
}.freeze

def normalize_tags(values)
  values.flatten.compact.map { |value| value.to_s.downcase.strip }.reject(&:empty?).uniq
end

atoms = EraZeroValidation.load_yaml("lexicon/all_atoms.yaml").fetch("atoms")
senses = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml").fetch("senses")
compounds = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml").fetch("entries")
senses_by_target = senses.group_by { |sense| sense["target_id"] }

entries = atoms.map do |atom|
  family = atom.fetch("family")
  address = atom.fetch("address")
  profile = AXES.fetch(family)
  axis = profile.fetch(:axes).fetch(address[0, 2])
  phase_label, phase_terms = PHASES.fetch(address[0]).fetch(address[2])
  base, base_terms = axis
  plain_label = "#{phase_label} #{base}"
  plain_explanation = case address[0]
                      when "0" then "Talk about #{base} as #{phase_label}; use the canonical definition for the exact boundary."
                      when "1" then "Talk about #{base} as #{phase_label}; this is a process, not the resulting thing or a general ability."
                      else "Talk about #{base} as #{phase_label}; this is a capacity or relation, not the action itself."
                      end
  indexed = Array(senses_by_target[atom.fetch("canonical_id")]).map { |sense| [sense["lemma"], *Array(sense["surface_forms"])] }
  tags = normalize_tags([profile.fetch(:family), base_terms, phase_terms, indexed, atom.fetch("title").split])
  match_phrases = normalize_tags([plain_label, "#{base_terms.first} #{phase_terms.first}", "#{phase_terms.first} #{base_terms.first}", base_terms])
  {
    "target_id" => atom.fetch("canonical_id"),
    "target_type" => "atom",
    "canonical_title" => atom.fetch("title"),
    "plain_label" => plain_label,
    "plain_explanation" => plain_explanation,
    "ordinary_terms" => tags,
    "match_phrases" => match_phrases,
    "example_searches" => [plain_label, "#{base_terms.first} #{phase_terms.first}", base_terms.first].uniq,
    "mapping_status" => "discovery_only_noncanonical",
    "authority_note" => "These words help people find the atom. They do not replace or broaden its invariant definition."
  }
end

entries.concat(compounds.map do |compound|
  id = compound.fetch("compound_id")
  indexed = Array(senses_by_target[id]).flat_map { |sense| [sense["lemma"], *Array(sense["surface_forms"])] }
  title = compound["display_title"] || compound["title"] || indexed.first
  {
    "target_id" => id,
    "target_type" => "compound",
    "canonical_title" => title,
    "plain_label" => indexed.min_by { |term| [term.to_s.split.length, term.to_s.length] } || title,
    "plain_explanation" => compound["usage_note"] || "An everyday discovery label for the approved compound “#{title}”; the compound graph controls its exact meaning.",
    "ordinary_terms" => normalize_tags([title.to_s.split, indexed]),
    "match_phrases" => normalize_tags([indexed, title]),
    "example_searches" => normalize_tags([indexed, title]).first(3),
    "mapping_status" => "discovery_only_noncanonical",
    "authority_note" => "These words help people find the compound. They do not replace or broaden its canonical graph."
  }
end)

document = {
  "format" => "EZ-PLAIN-ENGLISH-1",
  "version" => "1.0.0",
  "status" => "noncanonical_discovery_layer",
  "canonical_semantic_changes" => 0,
  "policy" => {
    "purpose" => "Help ordinary users find canonical atoms and compounds with familiar English words.",
    "authority" => "Canonical titles, invariant definitions, boundaries, and compound graphs remain controlling.",
    "translator_use" => "Tags are search and suggestion evidence only; they must not independently authorize automatic semantic resolution."
  },
  "counts" => {"atoms" => atoms.length, "compounds" => compounds.length, "entries" => entries.length},
  "entries" => entries.sort_by { |entry| entry.fetch("target_id") }
}

File.write(File.join(ROOT, "lexicon/plain_english_index.yaml"), YAML.dump(document))
puts "Built plain-English discovery index: #{atoms.length} atoms, #{compounds.length} compounds, #{entries.length} entries"
