require_relative 'lib/era_zero_presentation'
roles=YAML.load_file('spec/semantic_ir_schema.yaml')['semantic_roles'] || YAML.load_file('spec/semantic_ir_schema.yaml')['roles']
abort 'missing roles' unless roles
rows=roles.map do |role|
 ir={'ir_version'=>'1.0','root_clause'=>'c','speech_act'=>'assertion','nodes'=>[{'node_id'=>'c','kind'=>'clause','clause_type'=>'predication'},{'node_id'=>'p','kind'=>'lexical_occurrence','target_type'=>'atom','target_id'=>'LIF:211','runtime_state'=>{'code'=>1}},{'node_id'=>'a','kind'=>'lexical_occurrence','target_type'=>'atom','target_id'=>'LIF:010','runtime_state'=>{'code'=>1}}],'edges'=>[{'edge_id'=>'e0','type'=>'centers','from'=>'p','to'=>'c'},{'edge_id'=>'e1','type'=>'fills_role','from'=>'a','to'=>'p','role'=>role}],'discourse_constraints'=>{}}
 digest=EraZeroRenderer.semantic_digest(ir);ir.merge!('utterance_id'=>'UTT:'+digest[0,24],'serialization'=>{'content_digest'=>digest})
 f=EraZeroRenderer.render(ir);{'role'=>role,'midi_sha256'=>Digest::SHA256.hexdigest(EraZeroPresentation.midi(f))}
end
report=({'scope'=>'Structural role-encoding probes, not claims that every role is licensed by one English predicate.','collisions'=>rows.group_by{|r|r['midi_sha256']}.values.select{|group|group.length>1}.map{|group|group.map{|r|r['role']}},'records'=>rows})

File.write(File.expand_path('../reports/role_contrasts_after_frames.json',__dir__),JSON.pretty_generate(report)+"\n")
puts JSON.generate({roles:rows.length,collisions:report['collisions']})
exit(report['collisions'].empty? ? 0 : 1)
