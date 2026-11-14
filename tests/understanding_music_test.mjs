import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeUnderstandingContent} from '../pages/understanding_content.mjs';
import {understandingFoundation,midiFromUnderstanding,decodeUnderstandingMidi,understandingMusicEvents} from '../pages/understanding_music.mjs';
import {validateFoundations,foundationEvent} from '../pages/foundations.mjs';
import {midiFromScheduledEvents} from '../pages/engine.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),existing=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url))).records;
await validateFoundations([...existing,await understandingFoundation()],{allowDraft:true});
let count=0;const sounds=new Set(),parity=[];
for(const runtime of [0,1,2])for(const kind of ['communicated_content','reasons','perspective'])for(const phrase of ['Eli understands Nora.','Eli did not understand Nora.','Does Eli understand Nora?']){
 const doc=await composeUnderstandingContent(`${phrase} [${runtime}]`,{allowDraft:true,interpretation:kind}),bytes=await midiFromUnderstanding(doc,authority,{allowDraft:true});
 parity.push({document:doc,anchor:60,midi:Buffer.from(bytes).toString('base64')});
 const result=await decodeUnderstandingMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(result.runtime_state,runtime);assert.equal(result.content.content_kind,kind);assert.deepEqual(result.scopes,doc.scopes);assert.equal(result.speech_act,doc.speech_act);assert.equal(result.criterion,doc.criterion);
 assert.deepEqual(result.experiencer.phonemes,doc.experiencer.name.phonemes);assert.deepEqual(result.content.anchor.phonemes,doc.content.anchor.name.phonemes);
 await assert.rejects(()=>decodeUnderstandingMidi(bytes,authority.atoms));sounds.add(Buffer.from(bytes).toString('base64'));count++;
}
assert.equal(sounds.size,27);
for(const anchor of [48,72]){
 const d=await composeUnderstandingContent('I understand this robot.',{allowDraft:true,interpretation:'perspective'}),b=await midiFromUnderstanding(d,authority,{allowDraft:true,anchor});
 parity.push({document:d,anchor,midi:Buffer.from(b).toString('base64')});
 const r=await decodeUnderstandingMidi(b,authority.atoms,{allowDraft:true});assert.equal(r.experiencer.role,'speaker');assert.equal(r.content.anchor.reference_mode,'proximal_nominal');
}
const doc=await composeUnderstandingContent('Eli understands Nora.',{allowDraft:true,interpretation:'reasons'}),events=await understandingMusicEvents(doc,authority,{allowDraft:true});
await assert.rejects(()=>decodeUnderstandingMidi(midiFromScheduledEvents([...events,events.at(-1)],60,[0,0]),authority.atoms,{allowDraft:true}));
await assert.rejects(()=>decodeUnderstandingMidi(midiFromScheduledEvents(events,60,[0,-4]),authority.atoms,{allowDraft:true}));
await assert.rejects(()=>midiFromUnderstanding(doc,authority));
console.log(`PASS ${count} understanding MIDI-only meaning recoveries; distinct content criteria, roles, scopes, runtime and speech acts; draft opt-in, malformed head and command rejection.`);

const record=await understandingFoundation(),ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_foundations','-rjson','-e',"r=JSON.parse(STDIN.read);puts JSON.generate([0,1,2].map{|s|EraZeroFoundations.event(r,runtime_state:s,allow_draft:true)})"],{input:JSON.stringify(record),encoding:'utf8'}));
for(const runtimeState of [0,1,2])assert.deepEqual(ruby[runtimeState],await foundationEvent(record,{runtimeState,allowDraft:true}));
console.log('PASS Ruby/browser new predicate event parity across runtime 0/1/2; full sentence parity is checked below.');

const sentenceRuby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_understanding','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|x|Base64.strict_encode64(EraZeroUnderstanding.midi(x['document'],anchor_midi:x['anchor'],allow_draft:true))})"],{input:JSON.stringify(parity),encoding:'utf8',maxBuffer:20_000_000}));
assert.deepEqual(sentenceRuby,parity.map(p=>p.midi));
const corrupt=[];
for(const mutate of [d=>d.criterion='Attention alone',d=>d.runtime_state=3,d=>d.content.assertion_commitment='true',d=>d.experiencer.referent_id='wrong',d=>d.scopes.push({operator:'certainty'})]){
 const d=structuredClone(doc);mutate(d);const {content_id,content_digest,...body}=d;
 const {canonicalDigest}=await import('../pages/engine.mjs'),digest=await canonicalDigest(body);d.content_digest=digest;d.content_id=`EZUND:${digest.slice(0,24)}`;corrupt.push(d);
}
const rejected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_understanding','-e',"puts JSON.generate(JSON.parse(STDIN.read).each_with_index.map{|d,i|begin;EraZeroUnderstanding.midi(d,allow_draft:i>0);false;rescue StandardError;true;end})"],{input:JSON.stringify([doc,...corrupt]),encoding:'utf8'}));
assert.deepEqual(rejected,[true,true,true,true,true,true]);
console.log('PASS 29 full Ruby/browser understanding MIDI comparisons and default/rehashed-corruption rejection.');
