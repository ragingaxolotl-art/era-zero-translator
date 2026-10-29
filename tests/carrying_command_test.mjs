import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,needsSentenceComposition,parseSentenceConditional,composeSentenceConditional} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority};
const load=async id=>authority.compound_plans[id]?.required_roles.length?template:JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'];
const results=[];
for(const state of [0,1,2])for(const text of ['Carry the box','Do not carry the box','Carry the box toward the gate','Do not carry the box toward the gate','Physically support the box','Do not physically support the box']){
 const result=await composeNamedSentence(`${text} [${state}].`,template);results.push(result);
 const ir=result.semantic_ir,p=ir.nodes.find(n=>n.node_id==='p');
 assert.equal(ir.speech_act,'command');assert.equal(p.runtime_state.code,state);
 assert.equal(ir.nodes.find(n=>n.node_id==='a').referent_id,'discourse:addressee');
 assert.equal(p.compound_bindings.find(b=>b.slot_path.at(-1)==='s-source').argument_id,'a');
 assert.equal(ir.nodes.some(n=>n.operator==='negation'),text.startsWith('Do not'));
 const decoded=decodeStrictMusicMidi(midiFromFormal(result.formal),authority.atoms);
 assert.equal(decoded.speech_act,'command');assert.equal(decoded.tokens.find(t=>t.root_id===(text.includes('support')?'MAT:211':'MOV:121')).runtime_state,state);
 const speaker=decoded.tokens.find(t=>t.kind==='deictic');assert.equal(speaker.deictic_role,'addressee');
 assert(speaker.enclosing_scopes.some(i=>decoded.tokens[i].marker==='role_source_open'));
}
for(const text of ['If the box is damaged, carry it.','If the box is damaged, carry it toward the gate.','If the box is damaged, do not physically support it.']){
 const r=await composeSentenceConditional(text,load);results.push(r);
 assert.equal(r.semantic_ir.speech_act,'command');
 assert.equal(r.semantic_ir.nodes.find(n=>n.node_id==='s001_b').referent_id,r.semantic_ir.nodes.find(n=>n.node_id==='s000_a').referent_id);
}
const expected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:12_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,expected[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(expected[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
for(const text of ['If Ada is carrying the box, carry it toward the gate.','If a box is damaged, carry it toward the gate.','If exactly two boxes are damaged, carry it toward the gate.','If the box is damaged, carry the shelf toward it quickly.'])assert.equal(parseSentenceConditional(text),null,text);
const statement=await composeNamedSentence('you are carrying the box [0].',template);
assert.notDeepEqual(midiFromFormal(statement.formal),midiFromFormal(results[0].formal));
for(const text of ['Carry you.','Carry the box quickly.','Support the box.','Carry exactly two boxes.','Carry the box toward the gate and the shelf.']){assert.equal(parseNamedSentence(text),null,text);assert(needsSentenceComposition(text),text);}
console.log(`Carrying/support commands: ${results.length} runtime/negation/destination/conditional cases match reference formal and MIDI; addressee and command contour decode independently, and local it retains its antecedent.`);

assert.equal(parseNamedSentence('Carry the box to the gate.').requiredDestination,true);
