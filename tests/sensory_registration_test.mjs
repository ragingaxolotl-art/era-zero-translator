import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,needsSentenceComposition} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {decodeConventionFrame} from '../pages/compound_conventions.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const id='CMP:ade73037114406a2cd91ce13';
const template=JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files[id],root))).variants['assertion:1'];
const sentences=[
 'The sensor is registering sensory input from the bell',
 'The bell is registering sensory input from the sensor',
 'Ada is registering sensory input from Pip',
 'I am registering sensory input from you',
 'The sensor is not registering sensory input from the bell',
 'It is possible that the sensor is registering sensory input from the bell',
 'It is not necessary that the sensor is registering sensory input from the bell',
 'With 25% confidence, it is possible that the sensor is registering sensory input from the bell'
];
const outputs=[];
for(const sentence of sentences)for(const state of [0,1,2]){
 const input=`${sentence} [${state}].`,parsed=parseNamedSentence(input);
 assert.equal(parsed.predicate,id);assert.equal(parsed.role,'target');assert.equal(parsed.targetRole,'source');
 const result=await composeNamedSentence(input,template),ir=result.semantic_ir;
 assert.equal(ir.edges.find(e=>e.from==='a'&&e.type==='fills_role').role,'target');
 assert.equal(ir.edges.find(e=>e.from==='b'&&e.type==='fills_role').role,'source');
 assert.equal(ir.nodes.find(n=>n.node_id==='p').runtime_state.code,state);
 const reference=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','f=EraZeroRenderer.render(JSON.parse(STDIN.read));puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:root,input:JSON.stringify(ir),encoding:'utf8'}));
 assert.deepEqual(result.formal,reference.formal);
 const midi=midiFromFormal(result.formal);assert.deepEqual(Buffer.from(midi),Buffer.from(reference.midi,'base64'));
 const predicate=scheduledLexicalEvents(result.formal).filter(e=>e.occurrence_id==='p');
 assert.deepEqual(predicate.map(e=>e.marker||e.target_id),['convention_0_open','MAT:211','DAT:111','convention_0_close']);
 assert.deepEqual(predicate.filter(e=>e.runtime_tail).map(e=>e.runtime_tail.code),[state]);
 assert.match(result.semantic_note,/does not by itself assert consciousness/);
 const {notes,division}=notesFromMidi(midi),segments=[];
 for(const note of notes){if(!segments.length||note.start_tick>segments.at(-1).at(-1).end_tick)segments.push([]);segments.at(-1).push(note);}
 // Frame decoding receives note pitches, not source lexical IDs or IR.
 const frames=segments.map(s=>{const frame=decodeConventionFrame(s.map(n=>n.midi-60));if(frame)assert(s.every(n=>n.end_tick-n.start_tick===division/4));return frame;}).filter(Boolean);
 assert.deepEqual(frames.map(f=>[f.side,f.sound_code]),[['open',0],['close',0]]);
 outputs.push(Buffer.from(midi).toString('base64'));
}
assert.equal(new Set(outputs).size,24);
for(const text of ['The sensor is registering sensory input from the sensor.','Ada hears Pip.','Ada sees Pip.','Ada is registering sensory input from Pip and understands it.']){
 assert.equal(parseNamedSentence(text),null,text);
}
assert(needsSentenceComposition('Ada is registering sensory input from Pip and understands it.'));
console.log('Sensory registration: 24 sentence/runtime cases preserve receiver versus source, negation/modality/confidence, exact Ruby/browser formal and MIDI parity, and independently readable convention code 0. No hearing, seeing or understanding alias is inferred.');
