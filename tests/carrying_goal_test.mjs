import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,needsSentenceComposition,composeSentenceConditional} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),template={authority};
const results=[];
for(const state of [0,1,2])for(const text of ['Ada is carrying the box toward the gate','Ada is carrying the gate toward the box','I am carrying the box toward you','Ada is not carrying the box toward the gate','It is possible that Ada is carrying the box toward the gate']){
 const result=await composeNamedSentence(`${text} [${state}].`,template);results.push(result);
 const ir=result.semantic_ir,p=ir.nodes.find(n=>n.node_id==='p');
 assert.deepEqual(p.compound_bindings,[{slot_path:['q-support','s-source'],argument_id:'a'},{slot_path:['q-support','s-target'],argument_id:'b'},{slot_path:['s-load'],argument_id:'b'}]);
 assert.deepEqual(ir.edges.filter(e=>e.type==='fills_role').map(e=>[e.from,e.to,e.role]),[['d2','p','destination']]);
 const decoded=decodeStrictMusicMidi(midiFromFormal(result.formal),authority.atoms);
 assert.equal(decoded.tokens.find(t=>t.root_id==='MOV:121').runtime_state,state);
 assert.equal(decoded.tokens.filter(t=>t.marker==='role_destination_open').length,1);
 const destination=ir.nodes.find(n=>n.node_id==='d2');
 const goalToken=decoded.tokens.find(t=>['phonemic','deictic'].includes(t.kind)&&t.enclosing_scopes.some(i=>decoded.tokens[i].marker==='role_destination_open'));
 assert(goalToken);
 if(destination.name)assert.deepEqual(goalToken.phonemes,destination.name.phonemes);
 else assert.equal(goalToken.deictic_role,'addressee');
 assert.equal(goalToken.register,'high');
 assert(!decoded.tokens.some(t=>t.marker==='role_recipient_open'));
 assert(result.semantic_note.includes('arrival, delivery and a recipient are not asserted'));
}
results.push(await composeNamedSentence('Was Ada carrying the box toward the gate yesterday?',template));
results.push(await composeSentenceConditional('If Ada is carrying the box toward the gate, then Ben is physically supporting the shelf.',async()=>template));
const expected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:10_000_000}));
for(const [i,result] of results.entries()){assert.deepEqual(result.formal,expected[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(expected[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
assert.equal(results[15].semantic_ir.speech_act,'question');
assert.equal(results[15].semantic_ir.nodes.find(n=>n.kind==='time_anchor').day_offset,'-1');
for(const input of ['Ada is carrying the box toward the gate quickly.','Ada is carrying the box toward the box.','Ada is carrying exactly two boxes toward the gate.','Ada is carrying the box toward the gate and the shelf.']){assert.equal(parseNamedSentence(input),null,input);assert(needsSentenceComposition(input),input);}
console.log(`Carrying goals: ${results.length} role/runtime/negation/modality/past-question/conditional cases match reference formal and MIDI. Destination differs from load and remains audible; arrival is not inferred; unsupported additions stay incomplete.`);

assert.equal(parseNamedSentence('Ada is carrying the box to the gate.').requiredDestination,true);
