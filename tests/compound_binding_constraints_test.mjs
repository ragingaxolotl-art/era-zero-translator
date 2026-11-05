import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const fixture=JSON.parse(execFileSync('ruby',['-Itools/lib','-e',String.raw`
require 'minitest/mock'
require 'era_zero_renderer'
require 'era_zero_browser_compounds'
require 'era_zero_compound_role_binding'
require 'era_zero_presentation'
require 'base64'
atoms, original=EraZeroRenderer.load_authority
inner=Marshal.load(Marshal.dump(original.fetch('CMP:eef9fff8ac6618ce60927f18')))
inner['compound_id']='fixture-support';inner['conventional_meaning']=inner['conventional_meaning'].merge('sound_code'=>100,'sense_key'=>'fixture_support')
inner['binding_constraints']=[{'relation'=>'distinct_arguments','slot_paths'=>[['s-source'],['s-target']]}]
outer={'compound_id'=>'fixture-transport','definition_version'=>'1.0.0','status'=>'approved','semantic_head'=>'h','lexical_constraints'=>[],
 'nodes'=>[{'node_id'=>'q','kind'=>'compound_ref','compound_id'=>'fixture-support','definition_version'=>'1.0.0'},{'node_id'=>'mover','kind'=>'slot','slot_name'=>'mover','slot_type'=>'entity'},{'node_id'=>'h','kind'=>'root','root_id'=>'MOV:121'}],
 'edges'=>[{'type'=>'qualifies','from'=>'q','to'=>'h'},{'type'=>'fills_role','from'=>'mover','to'=>'h','role'=>'actor'}],
 'conventional_meaning'=>{'profile'=>'EZLEX-1','sense_key'=>'fixture_transport','sound_code'=>101,'added_definition'=>'Test-only scope and participant identity fixture; not approved carrying vocabulary.','excludes'=>['Lexical approval inferred from this fixture']},
 'binding_constraints'=>[{'relation'=>'same_argument','slot_paths'=>[['q','s-target'],['mover']]}]}
[inner,outer].each{|entry|entry['content_digest']=EraZeroValidation.fingerprint(EraZeroCompoundConventions.semantic_payload(entry))}
entries=[inner,outer];registry=entries.to_h{|entry|[entry['compound_id'],entry]};expander=EraZeroCompoundExpansion::Expander.new(entries)
expanded=expander.expand('fixture-transport','1.0.0')
bindings=[{'slot_path'=>['q','s-source'],'argument_id'=>'a'},{'slot_path'=>['q','s-target'],'argument_id'=>'b'},{'slot_path'=>['mover'],'argument_id'=>'b'}]
arguments={'a'=>{'value_type'=>'entity'},'b'=>{'value_type'=>'entity'},'c'=>{'value_type'=>'entity'}}
raise 'Valid shared participant rejected' unless expander.bind_slots(expanded,bindings:bindings,arguments:arguments).length==3
failures=[]
check=lambda do |label,&block|
 begin;block.call;raise "Accepted invalid constraint: #{label}"
 rescue EraZeroCompoundExpansion::ExpansionError,EraZeroCompoundBindingConstraints::ConstraintError => error;failures<<{'label'=>label,'message'=>error.message};end
end
check.call('different mover'){bad=Marshal.load(Marshal.dump(bindings));bad.last['argument_id']='c';expander.bind_slots(expanded,bindings:bad,arguments:arguments)}
check.call('supporter equals load'){bad=Marshal.load(Marshal.dump(bindings));bad.first['argument_id']='b';expander.bind_slots(expanded,bindings:bad,arguments:arguments)}
check.call('same known referent'){expander.bind_slots(expanded,bindings:bindings,arguments:arguments.merge('a'=>{'value_type'=>'entity','referent_id'=>'same'},'b'=>{'value_type'=>'entity','referent_id'=>'same'}))}
[
 ['missing slot',[{'relation'=>'same_argument','slot_paths'=>[['q','absent'],['mover']]}]],
 ['duplicate slot',[{'relation'=>'same_argument','slot_paths'=>[['mover'],['mover']]}]],
 ['unknown relation',[{'relation'=>'similar','slot_paths'=>[['q','s-target'],['mover']]}]],
 ['transitive contradiction',outer['binding_constraints']+[{'relation'=>'same_argument','slot_paths'=>[['q','s-source'],['mover']]}]]
].each do |label,constraints|
 bad=Marshal.load(Marshal.dump(outer));bad['binding_constraints']=constraints
 check.call(label){EraZeroCompoundExpansion::Expander.new([inner,bad]).expand('fixture-transport','1.0.0')}
end
check.call('mistyped shared slot'){bad=Marshal.load(Marshal.dump(outer));bad['nodes'].find{|n|n['node_id']=='mover'}['slot_type']='event';EraZeroCompoundExpansion::Expander.new([inner,bad]).expand('fixture-transport','1.0.0')}
check.call('controlled adapter refuses implicit identity'){
 nodes=[{'node_id'=>'p','kind'=>'lexical_occurrence','target_type'=>'compound','target_id'=>'fixture-transport'}]+%w[a b c].map{|id|{'node_id'=>id,'kind'=>'lexical_occurrence','target_type'=>'atom','target_id'=>'MAT:010','value_type'=>'entity'}}
 edges=%w[source target actor].zip(%w[a b c]).map{|role,id|{'type'=>'fills_role','from'=>id,'to'=>'p','role'=>role}}
 EraZeroCompoundRoleBinding.bind_unique_roles!(nodes,edges,registry)
}
check.call('unmarked constraint'){bad=Marshal.load(Marshal.dump(inner));bad.delete('conventional_meaning');EraZeroCompoundExpansion::Expander.new([bad]).expand('fixture-support','1.0.0')}
# Inherited constraints must remain scoped when the same definition occurs twice.
double={'compound_id'=>'double','definition_version'=>'1.0.0','status'=>'approved','semantic_head'=>'b','nodes'=>%w[a b].map{|id|{'node_id'=>id,'kind'=>'compound_ref','compound_id'=>'fixture-support','definition_version'=>'1.0.0'}},'edges'=>[{'type'=>'qualifies','from'=>'a','to'=>'b'}]}
doubled=EraZeroCompoundExpansion::Expander.new([inner,double]).expand('double','1.0.0')
raise 'Lost occurrence scope' unless doubled['binding_constraints'].map{|c|c['slot_paths'].map(&:first)}==[%w[a a],%w[b b]]
plain=Marshal.load(Marshal.dump(outer));plain.delete('binding_constraints')
raise 'Constraints excluded from lexical identity' if EraZeroValidation.fingerprint(EraZeroCompoundConventions.semantic_payload(plain))==outer['content_digest']
results=[0,1,2].map do |state|
 ir={'ir_version'=>'1.0','root_clause'=>'c','speech_act'=>'assertion','discourse_constraints'=>{},'nodes'=>[{'node_id'=>'c','kind'=>'clause','clause_type'=>'predication'},{'node_id'=>'p','kind'=>'lexical_occurrence','target_type'=>'compound','target_id'=>'fixture-transport','runtime_state'=>{'code'=>state},'compound_bindings'=>bindings},
 {'node_id'=>'a','kind'=>'lexical_occurrence','target_type'=>'atom','target_id'=>'LIF:010','value_type'=>'entity','runtime_state'=>{'code'=>1}}, {'node_id'=>'b','kind'=>'lexical_occurrence','target_type'=>'atom','target_id'=>'MAT:010','value_type'=>'entity','runtime_state'=>{'code'=>2}}], 'edges'=>[{'edge_id'=>'e','type'=>'centers','from'=>'p','to'=>'c'}]}
 digest=EraZeroRenderer.semantic_digest(ir);ir.merge!('utterance_id'=>'UTT:'+digest[0,24],'serialization'=>{'content_digest'=>digest})
 EraZeroRenderer.stub(:load_authority,[atoms,registry]){f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}}
end
puts JSON.generate({authority:{atoms:atoms.values.map{|a|a.slice('canonical_id','note_path_semitones','harmonic_signature_semitones','canonical_transliteration','formal_carrier')},compounds:entries,compound_plans:EraZeroBrowserCompounds.plans(entries)},failures:failures,results:results})
`],{cwd:new URL('..',import.meta.url),encoding:'utf8',maxBuffer:5_000_000}));
assert.equal(fixture.failures.length,10);
for(const {formal,midi} of fixture.results){
 const events=await renderLexicalOccurrences(formal.semantic_ir,fixture.authority);
 assert.deepEqual(events,formal.performance.lexical_events);
 assert.deepEqual(Buffer.from(midiFromFormal(formal)),Buffer.from(midi,'base64'));
 const inverse=decodeStrictMusicMidi(Buffer.from(midi,'base64'),fixture.authority.atoms);
 assert.deepEqual(inverse.tokens.filter(t=>t.root_id==='MAT:010'&&t.runtime_state!==null).map(t=>t.runtime_state),[2,2]);
 for(const variant of ['different mover','same supporter','same referent']){
  const bad=structuredClone(formal.semantic_ir),p=bad.nodes.find(n=>n.node_id==='p');
  if(variant==='different mover'){bad.nodes.push({...structuredClone(bad.nodes.find(n=>n.node_id==='b')),node_id:'x'});p.compound_bindings.at(-1).argument_id='x';}
  if(variant==='same supporter')p.compound_bindings[0].argument_id='b';
  if(variant==='same referent')for(const n of bad.nodes.filter(n=>['a','b'].includes(n.node_id)))n.referent_id='same';
  await assert.rejects(()=>renderLexicalOccurrences(bad,fixture.authority),/same argument occurrence|distinct arguments/);
 }
}
console.log('Compound identity constraints: scoped equality and distinctness reject wrong participants and known aliases in Ruby/browser; inherited paths and transitive contradictions are checked. Three runtime states preserve reference music. Fixtures do not approve carrying.');
