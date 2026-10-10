#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "yaml"
require_relative "lib/era_zero_validation"
require_relative "lib/era_zero_general_english"
require_relative "lib/era_zero_renderer"
require_relative "lib/era_zero_presentation"

root = EraZeroValidation::ROOT
pages = File.join(root, "pages")
data_dir = File.join(pages, "data")
resolution_dir = File.join(data_dir, "resolutions")
FileUtils.mkdir_p(resolution_dir)

index_html = File.read(File.join(root, "app/public/index.html"))
  .gsub('href="/"', 'href="./"')
  .gsub('href="/styles.css?v=1.1"', 'href="./styles.css?v=1.1"')
  .gsub('<script src="/app.js?v=1.1" defer></script>', '<script type="module" src="./app.js?v=1.1"></script>')
  .gsub('Canonical engine ready', 'Loading canonical browser engine')
  .gsub('Local workbench for', 'Browser workbench for')
  .gsub('DBA Era Zero · Local canonical translator', 'DBA Era Zero · Canonical browser translator')
File.write(File.join(pages, "index.html"), index_html)
FileUtils.cp(File.join(root, "app/public/styles.css"), File.join(pages, "styles.css"))
File.write(File.join(pages, ".nojekyll"), "")

senses = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml").fetch("senses")
compounds = EraZeroValidation.load_yaml("lexicon/compound_dictionary.yaml").fetch("entries")
compound_by_id = compounds.to_h { |compound| [compound.fetch("compound_id"), compound] }
allowed = senses.select { |sense| sense["controlled_input_allowed"] == true && %w[atom compound].include?(sense["route"]) }
canonical_by_target = allowed.group_by { |sense| sense.fetch("target_id") }.transform_values do |items|
  items.sort_by { |sense| [sense.fetch("sense_key") !~ /canonical_/, sense.fetch("sense_id")] }.first
end

translator = EraZeroGeneralEnglish::Translator.new
acts = %w[assertion question command definition possibility]
resolution_files = {}
required_roles = {}

canonical_by_target.sort.each do |target_id, sense|
  roles = if sense.fetch("route") == "compound"
            EraZeroRenderer.required_compound_roles(compound_by_id.fetch(target_id))
          else
            []
          end
  required_roles[target_id] = roles
  next unless roles.empty?

  variants = {}
  acts.each do |act|
    [0, 1, 2].each do |state|
      result = translator.resolve(sense.fetch("lemma"), sense_id: sense.fetch("sense_id"), runtime_state: state, speech_act: act)
      raise "resolution failed for #{target_id} #{act} #{state}" unless result["status"] == "resolved" && result["round_trip_equal"]
      result["presentation_manifest"] = EraZeroPresentation.manifest(result.fetch("formal"))
      variants["#{act}:#{state}"] = result
    end
  end
  filename = "#{target_id.tr(':', '_').downcase}.json"
  File.write(File.join(resolution_dir, filename), JSON.generate({ "target_id" => target_id, "variants" => variants }))
  resolution_files[target_id] = "./data/resolutions/#{filename}"
end

browser_index = {
  "format" => "EZ-WEB-1", "version" => "1.0.0", "generated" => "2026-10-10",
  "counts" => { "atoms" => 324, "compounds" => 28, "senses" => senses.length, "lemmas" => senses.map { |s| s["lemma"].downcase }.uniq.length, "gaps" => senses.count { |s| s["route"] == "gap" } },
  "senses" => senses,
  "controlled" => allowed.map { |sense| sense.slice("sense_id", "lemma", "route", "target_id") },
  "required_roles" => required_roles,
  "resolution_files" => resolution_files,
  "online_scope" => {
    "direct_targets" => resolution_files.length,
    "slotted_compounds" => required_roles.count { |_id, roles| !roles.empty? },
    "note" => "The static release resolves every atom and closed compound exactly. Open-slot compound role binding remains available in the local Ruby API."
  }
}
File.write(File.join(data_dir, "index.json"), JSON.generate(browser_index))

puts "Built GitHub Pages release: #{senses.length} senses, #{resolution_files.length} directly resolvable targets, #{required_roles.count { |_id, roles| !roles.empty? }} slotted compounds"
