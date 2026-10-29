import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,composeSentenceConditional} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority};
const id='CMP:eef9fff8ac6618ce60927f18',results=[];
for(const state of [0,1,2])for(const [left,right] of [['Ada','the box'],['The shelf','the box'],['The box','the shelf']])for(const prefix of ['', 'It is possible that ']){
 const text=`${prefix}${prefix?left[0].toLowerCase()+left.slice(1):left} is physically supporting ${right} [${state}].`;
 // Proper names retain capitalization inside a modal clause.
 const input=text.replace('that ada','that Ada');
 const result=await composeNamedSentence(input,template);assert.equal(result.target_id,id);
 results.push(result);
 const decoded=decodeStrictMusicMidi(midiFromFormal(result.formal),authority.atoms);
 assert.deepEqual(decoded.tokens.filter(t=>t.kind==='root').map(t=>[t.root_id,t.runtime_state]),[['MAT:010',null],['MAT:211',state]]);
 const qualifier=decoded.tokens.find(t=>t.root_id==='MAT:010');
 assert(qualifier.enclosing_scopes.some(index=>decoded.tokens[index].marker==='role_target_open'));
 assert.equal(qualifier.boundary_after_beats,0);
 assert(decoded.tokens.some(t=>t.marker==='convention_3_open'));
 assert.equal(result.semantic_ir.edges.some(e=>e.type==='fills_role'),false);
}
results.push(await composeNamedSentence('Ada is not physically supporting the box.',template));
results.push(await composeSentenceConditional('If Ada is physically supporting the box, then Ben is physically supporting the shelf.',async()=>template));
const references=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:10_000_000}));
for(const [i,result] of results.entries()){assert.deepEqual(result.formal,references[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(references[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
for(const phrase of ['Ada supports the box.','Ada is pushing the box.','Ada is emotionally supporting Ben.','Ada is physically supporting Ada.','Exactly two shelves are physically supporting the box.'])assert.equal(parseNamedSentence(phrase),null);
const audit=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-e',String.raw`
 id='CMP:eef9fff8ac6618ce60927f18'
 dictionary=EraZeroValidation.load_yaml('lexicon/compound_dictionary.yaml')['entries']
 migration=EraZeroValidation.load_yaml('migrations/physical_support_2026_10_28.yaml')
 raise 'Old compound definitions changed' unless EraZeroValidation.fingerprint(dictionary.reject{|e|['CMP:763faa4465065477220f6f06','CMP:74d98d19808f74d0b8196951','CMP:0aca609416668978e1527dac'].include?(e['compound_id']) || [id,'CMP:7a6749aaf61cd6181e544bd6'].include?(e['compound_id'])})==migration['before_dictionary_fingerprint']
 c=EraZeroControlledEnglish::Compiler.new
 ir=c.compile('ASSERT "active physical load support" [2] ROLE source "distinct material object" [1] ROLE target "distinct material object" [0].')['semantic_ir']
 formal=EraZeroRenderer.render(ir)
 registry=dictionary.to_h{|e|[e['compound_id'],e]}
 nested={'compound_id'=>'fixture-nested','definition_version'=>'1.0.0','status'=>'approved','semantic_head'=>'b','nodes'=>%w[a b].map{|n|{'node_id'=>n,'kind'=>'compound_ref','compound_id'=>id,'definition_version'=>'1.0.0'}},'edges'=>[{'type'=>'qualifies','from'=>'a','to'=>'b'}]}
 registry['fixture-nested']=nested
 begin
  EraZeroCompoundRoleBinding.bind_unique_roles!([{'node_id'=>'p','kind'=>'lexical_occurrence','target_type'=>'compound','target_id'=>'fixture-nested'}],[],registry)
  raise 'Repeated roles were guessed'
 rescue ArgumentError => error
  raise unless error.message.include?('Repeated scoped roles')
 end
 bad_nodes=Marshal.load(Marshal.dump(ir['nodes']));bad_nodes.find{|n|n['node_id']=='n002'}.delete('compound_bindings');bad_nodes.find{|n|n['node_id']=='n003'}['value_type']='event'
 bad_edges=[{'type'=>'fills_role','from'=>'n003','to'=>'n002','role'=>'source'},{'type'=>'fills_role','from'=>'n004','to'=>'n002','role'=>'target'}]
 begin
  EraZeroCompoundRoleBinding.bind_unique_roles!(bad_nodes,bad_edges,registry)
  raise 'Mistyped role was accepted'
 rescue ArgumentError => error
  raise unless error.message.include?('entity occurrence')
 end
 puts JSON.generate({ir:ir,formal:formal})
`],{cwd:root,encoding:'utf8',maxBuffer:2_000_000}));
assert.deepEqual(audit.ir.nodes.find(n=>n.target_id===id).compound_bindings.map(b=>b.slot_path).sort(),[['s-source'],['s-target']]);
assert.deepEqual(audit.formal.performance.lexical_events.filter(e=>e.runtime_tail).map(e=>e.runtime_tail.code).sort(),[0,1,2]);
console.log(`Physical support: ${results.length} role/runtime/scope sentences match Ruby formal and MIDI; target qualification and convention decode independently. Prior compound definitions are unchanged. Controlled role bindings become explicit paths. Carrying and metaphorical support remain distinct.`);
