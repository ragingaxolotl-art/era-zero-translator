import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence,needsSentenceComposition} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root))),results=[];
const template=id=>({...JSON.parse(fs.readFileSync(new URL(`pages/data/resolutions/${id.toLowerCase().replace(':','_')}.json`,root))).variants['assertion:1'],authority});
const texts=['Ada arrived at the gate.','The box arrived at the gate.','I arrived at the gate.','Ada did not arrive at the gate.','Did Ada arrive at the gate?','Did Ada not arrive at the gate?','Ada arrived at the gate yesterday.','Did the box arrive at the gate today?','The heavy box arrived at the gate.'];
for(const state of [0,1,2])for(const text of texts){
 const input=text+` [${state}]`,parsed=parseNamedSentence(input);assert(parsed,input);
 const r=await composeNamedSentence(input,template(parsed.predicate),text.includes('heavy')?{interpretation:'mass_standard',standard:{dimension:'mass',threshold:'20',scale:'kilogram'}}:{});results.push(r);
 const decoded=decodeStrictMusicMidi(midiFromFormal(r.formal),authority.atoms);
 assert.equal(decoded.tokens.find(t=>t.root_id==='MOV:110').runtime_state,state);
 assert(!decoded.tokens.some(t=>['MOV:111','MOV:121'].includes(t.root_id)||t.marker==='role_recipient_open'));
 assert(decoded.tokens.some(t=>t.marker==='role_destination_open'));
 assert(decoded.tokens.some(t=>t.marker==='role_actor_open'));
 assert.equal(decoded.tokens.some(t=>t.marker==='negation_open'),text.includes('not'));
 assert.equal(r.semantic_ir.speech_act,text.startsWith('Did ')?'question':'assertion');
 assert(decoded.tokens.some(t=>t.marker===(text.includes('yesterday')?'time_previous_day_open':'time_before_speech_open')));
 const mover=r.semantic_ir.nodes.find(n=>n.node_id==='a');
 const moverToken=decoded.tokens.find(t=>['phonemic','deictic'].includes(t.kind)&&t.enclosing_scopes.some(i=>decoded.tokens[i].marker==='role_actor_open'));
 assert(moverToken);
 if(mover.name)assert.deepEqual(moverToken.phonemes,mover.name.phonemes);
 else assert.equal(moverToken.deictic_role,'speaker');
}
const expected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:20_000_000}));
for(const [i,r] of results.entries()){assert.deepEqual(r.formal,expected[i].formal);assert.deepEqual(Buffer.from(midiFromFormal(r.formal)),Buffer.from(expected[i].midi,'base64'));}
assert.equal(new Set(results.map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,results.length);
for(const state of [0,1,2]){
 const approach=await composeNamedSentence(`Ada is moving toward the gate [${state}].`,template('MOV:111'));
 const arrival=results[state*texts.length];
 const a=decodeStrictMusicMidi(midiFromFormal(approach.formal),authority.atoms);
 assert(a.tokens.some(t=>t.root_id==='MOV:111'&&t.runtime_state===state));
 assert.notDeepEqual(Buffer.from(midiFromFormal(approach.formal)),Buffer.from(midiFromFormal(arrival.formal)));
}
for(const input of ['Ada arrived at the gate quickly.','Ada arrived at the gate tomorrow.','Ada arrived at Ada.','Ada arrived at exactly two gates.','Ada arrived at the conclusion.','Ada arrived at the gate with the box.','Ada is arriving at the gate.','Ada arrives at the gate.']){assert.equal(parseNamedSentence(input),null,input);assert(needsSentenceComposition(input),input);}
console.log(`Arrival: ${results.length} participant/negation/question/calendar/property/runtime cases match Ruby formal and MIDI. Independent tokens distinguish completed arrival from approach without recipient or carrying inference.`);
