import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,needsSentenceComposition,composeSentenceConditional} from '../pages/sentences.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority};
const id='CMP:0aca609416668978e1527dac',results=[];
const inputs=['Ada has physical custody of Ben.','Ben has physical custody of Ada.','Ada has physical custody of the box.','Ben has physical custody of the box.','Ada has physical custody of the shelf.','I have physical custody of the box.','You do not have physical custody of the box.','Ada does not have physical custody of the box.','It is possible that Ada has physical custody of the box.','Does Ada have physical custody of the box?','Does Ada not have physical custody of the box?'];
for(const state of [0,1,2])for(const text of inputs){
 const input=text.replace(/([.?])$/,` [${state}]$1`),r=await composeNamedSentence(input,template);assert.equal(r.target_id,id,input);results.push(r);
 const decoded=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);
 assert.deepEqual(decoded.tokens.filter(t=>t.kind==='root').map(t=>[t.root_id,t.runtime_state]),[['MAT:010',null],['MAT:210',state]]);
 assert.equal(decoded.tokens.filter(t=>t.marker==='convention_7_open').length,1);
 assert.equal(decoded.tokens.filter(t=>t.marker==='convention_7_close').length,1);
 const qualifier=decoded.tokens.find(t=>t.root_id==='MAT:010');assert(qualifier.enclosing_scopes.some(i=>decoded.tokens[i].marker==='role_target_open'));
 assert.equal(qualifier.boundary_after_beats,0);
 assert(!decoded.tokens.some(t=>['MOV:110','MAT:211'].includes(t.root_id)));
 const bad=structuredClone(r.semantic_ir),p=bad.nodes.find(n=>n.target_id===id);p.compound_bindings[1].argument_id=p.compound_bindings[0].argument_id;
 await assert.rejects(()=>renderLexicalOccurrences(bad,authority),/distinct arguments/);
 const aliased=structuredClone(r.semantic_ir),bindings=aliased.nodes.find(n=>n.target_id===id).compound_bindings;
 for(const b of bindings)aliased.nodes.find(n=>n.node_id===b.argument_id).referent_id='same-object';
 await assert.rejects(()=>renderLexicalOccurrences(aliased,authority),/distinct arguments/);
}
results.push(await composeSentenceConditional('If Ada has physical custody of the box, then Ben has physical custody of the shelf.',async()=>template));
const references=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:12_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,references[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(references[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
for(const text of ['Ada owns the box.','Ada holds the box.','Ada receives the box.','Ada has physical custody of Ada.','Ada has legal custody of Ben.','Ada has physical custody of the box unwillingly.','Exactly two people have physical custody of the box.'])assert.equal(parseNamedSentence(text),null,text);
assert(needsSentenceComposition('Ada has physical custody of the box unwillingly.'));
const fixture=JSON.parse(execFileSync('ruby',['-Itools/lib','-e',String.raw`
require 'minitest/mock'
require 'era_zero_controlled_english'
require 'era_zero_browser_compounds'
require 'era_zero_presentation'
require 'base64'
id='CMP:0aca609416668978e1527dac'
atoms,dictionary=EraZeroRenderer.load_authority
m=EraZeroValidation.load_yaml('migrations/physical_custody_2026_10_29.yaml')
raise 'Prior compounds changed' unless dictionary.length==40 && EraZeroValidation.fingerprint(dictionary.values.reject{|e|e['compound_id']==id})==m['before_dictionary_fingerprint']
c=EraZeroControlledEnglish::Compiler.new
controlled=[0,1,2].map{|s|ir=c.compile(%Q{ASSERT "practical physical custody" [#{s}] ROLE source "identified other" [0] ROLE target "distinct material object" [2].})['semantic_ir'];f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}}
bad=c.compile('ASSERT "practical physical custody" [1] ROLE source "distinct material object" [1] ROLE target REF source.')
raise 'Self-custody accepted' unless bad['status']=='error' && bad.dig('error','message').include?('distinct arguments')

inner=dictionary.fetch(id)
outer={'compound_id'=>'custody-nesting-fixture','definition_version'=>'1.0.0','status'=>'approved','semantic_head'=>'b','lexical_constraints'=>[],
 'nodes'=>%w[a b].map{|n|{'node_id'=>n,'kind'=>'compound_ref','compound_id'=>id,'definition_version'=>'1.0.0'}},'edges'=>[{'type'=>'qualifies','from'=>'a','to'=>'b'}]}
outer['content_digest']=EraZeroValidation.fingerprint(EraZeroCompoundConventions.semantic_payload(outer))
entries=[inner,outer];registry=entries.to_h{|e|[e['compound_id'],e]}
plans=EraZeroBrowserCompounds.plans(entries)
nested=[0,1,2].map do |state|
 ir=Marshal.load(Marshal.dump(controlled[state][:formal]['semantic_ir']))
 p=ir['nodes'].find{|n|n['target_id']==id};p['target_id']=outer['compound_id'];p['compound_bindings']=p['compound_bindings'].flat_map{|b|%w[a b].map{|prefix|b.merge('slot_path'=>[prefix]+b['slot_path'])}}
 digest=EraZeroRenderer.semantic_digest(ir);ir['utterance_id']='UTT:'+digest[0,24];ir['serialization']={'content_digest'=>digest}
 EraZeroRenderer.stub(:load_authority,[atoms,registry]){f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}}
end
puts JSON.generate({controlled:controlled,nested:nested,authority:{atoms:atoms.values,compounds:entries,compound_plans:plans}})
`],{cwd:root,encoding:'utf8',maxBuffer:8_000_000}));
for(const [state,r] of fixture.controlled.entries()){
 assert.deepEqual(await renderLexicalOccurrences(r.formal.semantic_ir,authority),r.formal.performance.lexical_events);
 const d=decodeStrictMusicMidi(Buffer.from(r.midi,'base64'),authority.atoms);
 assert.deepEqual(d.tokens.filter(t=>t.runtime_state!==null&&t.kind==='root').map(t=>[t.root_id,t.runtime_state]),[['LIF:010',0],['MAT:010',2],['MAT:210',state]]);
}
for(const [state,r] of fixture.nested.entries()){
 assert.deepEqual(await renderLexicalOccurrences(r.formal.semantic_ir,fixture.authority),r.formal.performance.lexical_events);
 assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(r.midi,'base64'));
 const d=decodeStrictMusicMidi(Buffer.from(r.midi,'base64'),authority.atoms);
 assert.equal(d.tokens.filter(t=>t.marker==='convention_7_open').length,2);
 assert.equal(d.tokens.filter(t=>t.root_id==='MAT:210'&&t.runtime_state===state).length,1);
}
console.log(`Physical custody: ${results.length} role/state/negation/question/modal/conditional sentences match Ruby/browser formal and MIDI; independent audible structure distinguishes custody from support and arrival. Three controlled and three nested performances preserve independent runtime states. Prior 39 compounds and distinct-participant constraints are checked; receipt is not inferred.`);
