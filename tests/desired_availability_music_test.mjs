import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {canonicalDigest} from '../pages/engine.mjs';
import {composeDesiredAvailability} from '../pages/desired_availability.mjs';
import {midiFromDesiredAvailability,decodeDesiredAvailabilityMidi} from '../pages/desired_availability_music.mjs';
import {midiFromCustodyOpportunity,decodeCustodyOpportunityMidi} from '../pages/custody_opportunity_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_candidates.json',import.meta.url))).records,sounds=new Set(),documents=[];
for(const outer of [0,1,2])for(const inner of [0,1,2])for(const negative of [false,true]){
 const d=await composeDesiredAvailability(`Didn't Nora want this tea to ${negative?'not ':''}be available to Eli [${inner}]? [${outer}]`,{allowDraft:true,interpretation:'practical_custody_opportunity',accessContext:'"Pantry access"'});
 documents.push(d);
 const bytes=await midiFromDesiredAvailability(d,authority,{allowDraft:true}),r=decodeDesiredAvailabilityMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(r.runtime_state,outer);assert.equal(r.content.runtime_state,inner);assert.equal(r.speech_act,'question');assert.deepEqual(r.scopes,[{operator:'time',relation:'before_speech'},{operator:'negation'}]);
 assert.deepEqual(r.content,decodeCustodyOpportunityMidi(await midiFromCustodyOpportunity(d.content,authority,{allowDraft:true}),authority.atoms,{allowDraft:true}));
 assert.deepEqual(r.holder.phonemes,d.holder.name.phonemes);assert.deepEqual(r.content.resource.phonemes,d.content.resource.name.phonemes);assert.deepEqual(r.content.prospective_holder.phonemes,d.content.prospective_holder.name.phonemes);
 assert.equal(r.content_status,'intensional');assert.equal(r.outcome_commitment,'desired_not_asserted');assert.equal(r.foundation_id,d.foundation_id);assert.equal(r.subject_binding,'explicit_content_subject');
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,records,{allowDraft:true}),r);assert.deepEqual(decodeDesiredAvailabilityMidi(await midiFromDesiredAvailability(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);assert.throws(()=>decodeDesiredAvailabilityMidi(bytes,authority.atoms));sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,18);
console.log('PASS 18 desired availability musical contrasts, complete nested inverse, participant identity, independent scopes, shared dispatch and transposition.');

const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_desired_availability','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroDesiredAvailability.midi(d,allow_draft:true))})"],{input:JSON.stringify(documents),encoding:'utf8',maxBuffer:16000000}));
for(const [i,d] of documents.entries())assert.equal(Buffer.from(await midiFromDesiredAvailability(d,authority,{allowDraft:true})).toString('base64'),ruby[i]);
const corrupted=[];
for(const [key,value] of [['content_status','asserted'],['outcome_commitment','happens'],['foundation_id','wrong'],['subject_binding','same_as_desire_holder']]){
 const d=structuredClone(documents.at(-1));d[key]=value;delete d.content_id;delete d.content_digest;const hash=await canonicalDigest(d);d.content_digest=hash;d.content_id=`EZDESAVAIL:${hash.slice(0,24)}`;corrupted.push(d);
 await assert.rejects(midiFromDesiredAvailability(d,authority,{allowDraft:true}));
}
const rejects=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_desired_availability','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|begin;EraZeroDesiredAvailability.midi(d,allow_draft:true);false;rescue ArgumentError;true;end})"],{input:JSON.stringify(corrupted),encoding:'utf8'}));assert(rejects.every(Boolean));
console.log('PASS independent Ruby performances match all 18 meanings; forged commitments, foundation and participant control reject in both implementations.');
