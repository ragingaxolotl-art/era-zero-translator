import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,composeSentenceConditional,composeSentenceSequence} from '../pages/sentences.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority};
const id='CMP:7a6749aaf61cd6181e544bd6',results=[];
for(const state of [0,1,2])for(const text of ['Ada is carrying the box','The shelf is carrying the box','The box is carrying the shelf','I am carrying the box','Ada is not carrying the box','It is possible that Ada is carrying the box']){
 const result=await composeNamedSentence(`${text} [${state}].`,template);assert.equal(result.target_id,id);results.push(result);
 const p=result.semantic_ir.nodes.find(n=>n.target_id===id);
 assert.deepEqual(p.compound_bindings,[{slot_path:['q-support','s-source'],argument_id:'a'},{slot_path:['q-support','s-target'],argument_id:'b'},{slot_path:['s-load'],argument_id:'b'}]);
 const decoded=decodeStrictMusicMidi(midiFromFormal(result.formal),authority.atoms);
 assert.deepEqual(decoded.tokens.filter(t=>t.kind==='root').map(t=>[t.root_id,t.runtime_state]),[['MAT:010',null],['MAT:211',null],['MOV:121',state]]);
 for(const code of [3,4])assert(decoded.tokens.some(t=>t.marker===`convention_${code}_open`));
 assert.equal(decoded.tokens.find(t=>t.marker==='convention_3_close').boundary_after_beats,0);
}
results.push(await composeSentenceConditional('If Ada is carrying the box, then Ben is carrying the shelf.',async()=>template));
results.push(await composeSentenceSequence('Ada is carrying the box, then Ben is physically supporting the shelf.',async()=>template));
const references=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:10_000_000}));
for(const [i,result] of results.entries()){assert.deepEqual(result.formal,references[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(references[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
const support=await composeNamedSentence('Ada is physically supporting the box [0].',template);
assert.notDeepEqual(midiFromFormal(support.formal),midiFromFormal(results[0].formal));
for(const phrase of ['Ada is pushing the box.','Ada is carrying Ada.','Ada is carrying responsibility.','Exactly two shelves are carrying the box.'])assert.equal(parseNamedSentence(phrase),null);
const badInputs=[];
for(const mutate of [p=>p.compound_bindings[2].argument_id='a',p=>p.compound_bindings[0].argument_id='b']){
 const bad=structuredClone(results[0].semantic_ir);mutate(bad.nodes.find(n=>n.target_id===id));badInputs.push(bad);await assert.rejects(()=>renderLexicalOccurrences(bad,authority));
}
const audit=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_controlled_english','-e',String.raw`
 dictionary=EraZeroValidation.load_yaml('lexicon/compound_dictionary.yaml')['entries']
 id='CMP:7a6749aaf61cd6181e544bd6';entry=dictionary.find{|e|e['compound_id']==id}
 raise 'Versioned support missing' unless entry['nodes'].any?{|n|n['kind']=='compound_ref'&&n['compound_id']=='CMP:eef9fff8ac6618ce60927f18'&&n['definition_version']=='1.0.0'}
 migration=EraZeroValidation.load_yaml('migrations/physical_carrying_2026_10_28.yaml')
 raise 'Old compounds changed' unless EraZeroValidation.fingerprint(dictionary.reject{|e|['CMP:763faa4465065477220f6f06','CMP:74d98d19808f74d0b8196951'].include?(e['compound_id']) || e['compound_id']==id})==migration['before_dictionary_fingerprint']
 JSON.parse(STDIN.read).each do |bad|
  begin; EraZeroRenderer.render(bad);raise 'Invalid carrying accepted';rescue EraZeroRenderer::RenderError => error;raise unless error.message.include?('invalid_compound_bindings');end
 end
 c=EraZeroControlledEnglish::Compiler.new
 input='ASSERT "ongoing physical carrying" [2] ROLE source "distinct material object" [0] ROLE target "distinct material object" [1] ROLE actor REF target.'
 result=c.compile(input);raise result.inspect unless result['status']=='ok'
 rejected=c.compile(input.sub('ROLE actor REF target','ROLE actor "distinct material object" [1]'))
 raise 'Duplicate label guessed as same participant' unless rejected['status']=='error'
 ir=result.fetch('semantic_ir');puts JSON.generate({ir:ir,formal:EraZeroRenderer.render(ir)})
`],{cwd:root,input:JSON.stringify(badInputs),encoding:'utf8',maxBuffer:2_000_000}));
const bindings=audit.ir.nodes.find(n=>n.target_id===id).compound_bindings;
assert.equal(bindings.find(b=>b.slot_path.join('/')==='q-support/s-target').argument_id,bindings.find(b=>b.slot_path.join('/')==='s-load').argument_id);
const decoded=decodeStrictMusicMidi(midiFromFormal(audit.formal),authority.atoms);
assert.equal(decoded.tokens.find(t=>t.root_id==='MOV:121').runtime_state,2);
assert(decoded.tokens.some(t=>t.root_id==='MAT:010'&&t.runtime_state===0));
assert(decoded.tokens.some(t=>t.root_id==='MAT:010'&&t.runtime_state===1));
assert.equal(parseNamedSentence('Ada carries the box.').requiredViewpoint,true);
await assert.rejects(()=>composeNamedSentence('Ada carries the box.',template),e=>e.code==='carrying_viewpoint_required');
console.log(`Physical carrying: ${results.length} ordinary state/role/scope/clause cases match Ruby formal and MIDI; conventions 3/4 and runtime decode independently. Shared load, distinct carrier, exact dependency and unchanged prior compounds verified.`);
