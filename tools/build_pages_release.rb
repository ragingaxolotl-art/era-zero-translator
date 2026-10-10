#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "uri"
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
  .gsub('href="/styles.css?v=1.8.0"', 'href="./styles.css?v=1.8.0"')
  .gsub('<script src="/app.js?v=1.8.0" defer></script>', '<script type="module" src="./app.js?v=1.8.0"></script>')
  .gsub('Canonical engine ready', 'Loading canonical browser engine')
  .gsub('Local workbench for', 'Browser workbench for')
  .gsub('DBA Era Zero · Local canonical translator', 'DBA Era Zero · Canonical browser translator')
File.write(File.join(pages, "index.html"), index_html)
FileUtils.cp(File.join(root, "app/public/styles.css"), File.join(pages, "styles.css"))
File.write(File.join(pages, ".nojekyll"), "")
%w[rig.json head/base.json eyes/happy.json eyes/sad.json eyes/angry.json mouth/sounds.json].each do |relative|
  destination = File.join(pages, "visemes", relative)
  FileUtils.mkdir_p(File.dirname(destination))
  FileUtils.cp(File.join(root, "visemes", relative), destination)
end

senses = EraZeroValidation.load_yaml("lexicon/english_sense_index.yaml").fetch("senses")
game_story_senses = EraZeroValidation.load_yaml("lexicon/game_story_surface_routes.yaml").fetch("senses")
atoms = EraZeroValidation.load_yaml("lexicon/all_atoms.yaml").fetch("atoms")
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
  "game_story_senses" => game_story_senses,
  "atoms" => atoms,
  "compounds" => compounds,
  "controlled" => allowed.map { |sense| sense.slice("sense_id", "lemma", "route", "target_id") },
  "required_roles" => required_roles,
  "resolution_files" => resolution_files,
  "game_story_profile" => {
    "version" => "0.1.0",
    "surface_routes" => game_story_senses.length,
    "canonical_semantic_changes" => 0,
    "note" => "Generalized routes disclose lost detail; unknown predicates remain unresolved; nouns may retain nonsemantic EZNAME labels."
  },
  "online_scope" => {
    "direct_targets" => resolution_files.length,
    "slotted_compounds" => required_roles.count { |_id, roles| !roles.empty? },
    "note" => "The static release resolves every atom and closed compound exactly. Open-slot compound role binding remains available in the local Ruby API."
  }
}
File.write(File.join(data_dir, "index.json"), JSON.generate(browser_index))

document_extensions = %w[.md .yaml .yml .json .jsonl .txt .svg .mid]
document_directories = %w[docs spec lexicon migrations reviews reports tests examples extraction visemes]
document_paths = document_directories.flat_map do |directory|
  Dir.glob(File.join(root, directory, "**", "*"))
end.select { |path| File.file?(path) && document_extensions.include?(File.extname(path).downcase) }
document_paths.concat(%w[README.md README_TRANSLATOR.md semantic_authority_status.md gate3_withdrawal_record.md canonical_claims.yaml superseded_claims.yaml unresolved_issues.yaml conflict_report.md].map { |path| File.join(root, path) })
document_paths.select! { |path| File.file?(path) }
document_paths.uniq!
category_for = lambda do |relative|
  case relative
  when %r{\Adocs/}, /README/, /semantic_authority_status/, /gate3_withdrawal/ then "Core documentation"
  when %r{\Aspec/} then "Specifications"
  when %r{\Alexicon/} then "Lexicons and authority"
  when %r{\Amigrations/} then "Migrations and approvals"
  when %r{\Areviews/} then "Semantic reviews"
  when %r{\Areports/} then "Validation reports"
  when %r{\Atests/} then "Test evidence"
  when %r{\Aexamples/} then "Examples and presentation"
  when %r{\Aextraction/}, /claims/, /conflict_report/ then "Source extraction"
  else "Project records"
  end
end
documents = document_paths.map do |absolute|
  relative = absolute.delete_prefix("#{root}/")
  encoded = relative.split("/").map { |segment| URI.encode_www_form_component(segment) }.join("/")
  {
    "title" => File.basename(relative, File.extname(relative)).tr("_-", " ").split.map(&:capitalize).join(" "),
    "path" => relative,
    "category" => category_for.call(relative),
    "format" => File.extname(relative).delete_prefix(".").upcase,
    "bytes" => File.size(absolute),
    "url" => "https://github.com/ragingaxolotl-art/era-zero-translator/blob/main/#{encoded}"
  }
end.sort_by { |entry| [entry.fetch("category"), entry.fetch("path")] }
document_manifest = {
  "format" => "EZ-DOCUMENT-MANIFEST-1",
  "generated" => "2026-10-10",
  "count" => documents.length,
  "categories" => documents.map { |entry| entry.fetch("category") }.uniq,
  "sources" => [
    { "title" => "Original shared conversation", "detail" => "313 decoded source nodes · 129 visible turns · SHA-256 5a89af8c…2475", "url" => "https://chatgpt.com/share/6a666bd1-8ba4-83ea-90f9-b85db783af13" },
    { "title" => "Integrated DBA ERA 0 Language document", "detail" => "Human-readable long-form standard and milestone history", "url" => "https://docs.google.com/document/d/1btnSrT37YJt1aD4gXGtJBO8e3ZRG6COYmFLaRkykHA8/edit?tab=t.0" },
    { "title" => "Versioned machine authority", "detail" => "Canonical YAML, migrations, semantic reviews, regression evidence, and Git history", "url" => "https://github.com/ragingaxolotl-art/era-zero-translator" }
  ],
  "documents" => documents
}
File.write(File.join(data_dir, "documents.json"), JSON.generate(document_manifest))

puts "Built GitHub Pages release: #{senses.length} senses, #{resolution_files.length} directly resolvable targets, #{required_roles.count { |_id, roles| !roles.empty? }} slotted compounds, #{documents.length} documents"
