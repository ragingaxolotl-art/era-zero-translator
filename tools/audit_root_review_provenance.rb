#!/usr/bin/env ruby
# This is a repository citation inventory, not recovery of the conversation.
require_relative 'lib/era_zero_validation'
V=EraZeroValidation
atoms=V.load_yaml('lexicon/atoms.yaml').fetch('atoms')
by_path={}
atoms.each do |root|
 root.fetch('review_history',{}).each do |kind,path|
  next unless path.is_a?(String)&&path.start_with?('reviews/')
  abort 'Unsafe provenance path' if path.split('/').include?('..')
  (by_path[path]||=[]) << {'root_id'=>root.fetch('canonical_id'),'citation_kind'=>kind}
 end
end
sources=by_path.sort.map do |path,refs|
 absolute=File.join(V::ROOT,path);present=File.file?(absolute)
 status=present ? File.readlines(absolute).first(20).select{|line|line.match?(/\AStatus:/)}.map(&:strip) : []
 {'path'=>path,'status'=>present ? 'present_at_cited_path' : 'missing_at_cited_path','sha256'=>present ? Digest::SHA256.file(absolute).hexdigest : nil,'declared_status_lines'=>status,'citations'=>refs}
end
cited=sources.flat_map{|s|s['citations'].map{|r|r['root_id']}}.uniq
report={'scope'=>'Every reviews/ path explicitly cited in current atoms.review_history; not all historical sources or external storage.',
 'root_inventory_sha256'=>Digest::SHA256.file(File.join(V::ROOT,'lexicon/atoms.yaml')).hexdigest,
 'root_count'=>atoms.length,'cited_roots'=>cited.length,'roots_without_review_path'=>atoms.map{|a|a.fetch('canonical_id')}-cited,
 'source_count'=>sources.length,'missing_count'=>sources.count{|s|s['status']=='missing_at_cited_path'},
 'authority_limit'=>'Existence and a root claiming approval do not prove the cited approval took place. Preserve missing references as unresolved provenance; do not fabricate approval files.',
 'sources'=>sources,'completion_proven'=>false}
V.write('reports/root_review_provenance_audit.json',JSON.pretty_generate(report)+"\n")
puts JSON.generate(report.slice('root_count','cited_roots','source_count','missing_count','completion_proven'))
