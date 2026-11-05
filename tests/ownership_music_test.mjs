import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {canonicalDigest,midiFromScheduledEvents} from '../pages/engine.mjs';
import {grammarMarker} from '../pages/scheduler.mjs';
import {composeOwnershipSentence} from '../pages/ownership_sentences.mjs';
import {midiFromOwnership,decodeOwnershipMidi,ownershipMusicEvents} from '../pages/ownership_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_candidates.json',import.meta.url))).records;
let count=0;const sounds=new Set(),documents=[];
for(const framework of ['"Harbor charter"','"Island charter"'])for(const state of [0,1,2])for(const phrase of ['Nora owns this tea.','Does Nora own this tea?','Nora did not own this tea.']){
 const d=await composeOwnershipSentence(phrase+` [${state}]`,{allowDraft:true,framework}),midi=await midiFromOwnership(d,authority,{allowDraft:true}),r=decodeOwnershipMidi(midi,authority.atoms,{allowDraft:true});
 documents.push(d);assert.equal(r.runtime_state,state);assert.equal(r.speech_act,d.speech_act);assert.deepEqual(r.scopes,d.scopes);assert.deepEqual(r.owner.phonemes,d.owner.name.phonemes);assert.deepEqual(r.object.phonemes,d.object.name.phonemes);assert.equal(r.object.reference_mode,'proximal_nominal');assert.deepEqual(r.framework.phonemes,d.framework.name.phonemes);assert.equal(r.physical_custody,'not_entailed');assert.equal(r.other_framework_status,'not_asserted');
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(midi,authority.atoms,records,{allowDraft:true}),r);assert.deepEqual(decodeOwnershipMidi(await midiFromOwnership(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);
 assert.throws(()=>decodeStrictMusicMidi(midi,authority.atoms));assert.throws(()=>decodeOwnershipMidi(midi,authority.atoms),/draft/);sounds.add(Buffer.from(midi).toString('base64'));count++;
}
assert.equal(sounds.size,count);console.log(`PASS ${count} ownership music/inverse cases preserve three references, scopes and runtime; transposition and unique draft dispatch verified.`);

const rendered=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_ownership','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroOwnership.midi(d,allow_draft:true))})"],{input:JSON.stringify(documents),encoding:'utf8',maxBuffer:12000000}));
for(const [i,d] of documents.entries())assert.equal(Buffer.from(await midiFromOwnership(d,authority,{allowDraft:true})).toString('base64'),rendered[i]);
const corrupt=[];
for(const [key,value] of [['physical_custody','entailed'],['framework_scope','outside_negation'],['runtime_state',3],['exclusive_ownership','entailed']]){
 const d=structuredClone(documents[0]);d[key]=value;delete d.content_digest;delete d.content_id;const hash=await canonicalDigest(d);d.content_digest=hash;d.content_id=`EZOWN:${hash.slice(0,24)}`;corrupt.push(d);
}
const rejected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_ownership','-e',"x=JSON.parse(STDIN.read);puts JSON.generate(x.map{|d|begin;EraZeroOwnership.midi(d,allow_draft:true);false;rescue ArgumentError;true;end})"],{input:JSON.stringify(corrupt),encoding:'utf8'}));assert(rejected.every(Boolean));
assert.equal(execFileSync('ruby',['-Itools/lib','-rera_zero_ownership','-e',"begin;EraZeroOwnership.midi(JSON.parse(STDIN.read));abort 'accepted draft';rescue ArgumentError;puts 'rejected';end"],{input:JSON.stringify(documents[0]),encoding:'utf8'}).trim(),'rejected');
console.log('PASS 18 independent Ruby ownership performances match JavaScript; default draft use and rehashed scope/rights/runtime corruption reject.');

const baseEvents=await ownershipMusicEvents(documents[0],authority,{allowDraft:true});
const from=baseEvents.findIndex(e=>e.marker==='role_comparison_standard_open'),to=baseEvents.findIndex(e=>e.marker==='role_comparison_standard_close');assert(from>=0&&to>from);
const absent=baseEvents.filter((_,i)=>i<from||i>to),duplicate=baseEvents.map(e=>e.marker==='role_content_open'?grammarMarker({performance:{anchor_midi:60}},'ownership','role_experiencer_open'):e.marker==='role_content_close'?grammarMarker({performance:{anchor_midi:60}},'ownership','role_experiencer_close'):e);
for(const events of [absent,duplicate]){
 const bad=midiFromScheduledEvents(events,60,[0,0]);decodeStrictMusicMidi(bad,authority.atoms,{allowDraftOwnership:true});assert.throws(()=>decodeOwnershipMidi(bad,authority.atoms,{allowDraft:true}));
 await assert.rejects(decodeSupportedMeaningWithDrafts(bad,authority.atoms,records,{allowDraft:true}));
}
console.log('PASS structurally valid music missing framework or duplicating owner role is rejected by ownership and shared semantic inverses.');
