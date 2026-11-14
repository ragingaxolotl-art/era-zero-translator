import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {canonicalDigest,midiFromScheduledEvents} from '../pages/engine.mjs';
import {grammarMarker} from '../pages/scheduler.mjs';
import {composeAvailabilitySentence} from '../pages/availability_sentences.mjs';
import {midiFromCustodyOpportunity,decodeCustodyOpportunityMidi,custodyOpportunityMusicEvents} from '../pages/custody_opportunity_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_candidates.json',import.meta.url))).records,sounds=new Set(),documents=[];let count=0;
for(const accessContext of ['"Pantry access"','"Market access"'])for(const state of [0,1,2])for(const phrase of ['This tea is available to Nora.','Is this tea available to Nora?','This tea was not available to Nora.']){
 const d=await composeAvailabilitySentence(phrase+` [${state}]`,{allowDraft:true,interpretation:'practical_custody_opportunity',accessContext}),bytes=await midiFromCustodyOpportunity(d,authority,{allowDraft:true}),r=decodeCustodyOpportunityMidi(bytes,authority.atoms,{allowDraft:true});
 documents.push(d);assert.deepEqual(r.prospective_holder.phonemes,d.prospective_holder.name.phonemes);assert.deepEqual(r.resource.phonemes,d.resource.name.phonemes);assert.deepEqual(r.access_context.phonemes,d.access_context.name.phonemes);assert.equal(r.resource.reference_mode,'proximal_nominal');assert.equal(r.runtime_state,state);assert.equal(r.speech_act,d.speech_act);assert.deepEqual(r.scopes,d.scopes);assert.equal(r.activity_status,'possible_not_asserted');assert.equal(r.normative_permission,'not_entailed');assert.equal(r.actual_acquisition,'not_entailed');assert.equal(r.activity_time,'prospective_relative_to_opportunity');
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,records,{allowDraft:true}),r);assert.deepEqual(decodeCustodyOpportunityMidi(await midiFromCustodyOpportunity(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);assert.throws(()=>decodeStrictMusicMidi(bytes,authority.atoms));sounds.add(Buffer.from(bytes).toString('base64'));count++;
}
assert.equal(sounds.size,count);console.log(`PASS ${count} custody-opportunity musical inverses preserve context, resource, prospective holder, scope and runtime without asserting permission or acquisition; transposition and unique dispatch verified.`);

const independent=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_custody_opportunity','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroCustodyOpportunity.midi(d,allow_draft:true))})"],{input:JSON.stringify(documents),encoding:'utf8',maxBuffer:16000000}));
for(const [i,d] of documents.entries())assert.equal(Buffer.from(await midiFromCustodyOpportunity(d,authority,{allowDraft:true})).toString('base64'),independent[i]);
const bad=[];
for(const [key,value] of [['normative_permission','entailed'],['actual_acquisition','entailed'],['activity_time','before_speech'],['activity_compound','wrong'],['runtime_state',3],['resource',documents[0].prospective_holder]]){
 const d=structuredClone(documents[0]);d[key]=value;delete d.content_digest;delete d.content_id;const hash=await canonicalDigest(d);d.content_digest=hash;d.content_id=`EZCUSTOP:${hash.slice(0,24)}`;bad.push(d);
}
const rejected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_custody_opportunity','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|begin;EraZeroCustodyOpportunity.midi(d,allow_draft:true);false;rescue ArgumentError;true;end})"],{input:JSON.stringify(bad),encoding:'utf8'}));assert(rejected.every(Boolean));
const events=await custodyOpportunityMusicEvents(documents[0],authority,{allowDraft:true}),from=events.findIndex(e=>e.marker==='role_comparison_standard_open'),to=events.findIndex(e=>e.marker==='role_comparison_standard_close');assert(from>=0&&to>from);
const missing=events.filter((_,i)=>i<from||i>to),duplicate=events.map(e=>e.marker==='role_content_open'?grammarMarker({performance:{anchor_midi:60}},'custody_opportunity','role_experiencer_open'):e.marker==='role_content_close'?grammarMarker({performance:{anchor_midi:60}},'custody_opportunity','role_experiencer_close'):e);
for(const altered of [missing,duplicate]){const bytes=midiFromScheduledEvents(altered,60,[0,0]);decodeStrictMusicMidi(bytes,authority.atoms,{allowDraftCustodyOpportunity:true});assert.throws(()=>decodeCustodyOpportunityMidi(bytes,authority.atoms,{allowDraft:true}));await assert.rejects(decodeSupportedMeaningWithDrafts(bytes,authority.atoms,records,{allowDraft:true}));}
console.log('PASS 18 independent Ruby opportunity performances; forged realization/permission/dependency/identity and structurally valid missing-context or duplicated-role music reject.');
