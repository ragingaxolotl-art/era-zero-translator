import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {canonicalDigest} from '../pages/engine.mjs';
import {composeDesiredOwnership} from '../pages/desired_ownership.mjs';
import {midiFromDesiredOwnership,decodeDesiredOwnershipMidi} from '../pages/desired_ownership_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_candidates.json',import.meta.url))).records,sounds=new Set(),documents=[];
for(const subject of ['','Eli '])for(const outer of [0,1,2])for(const inner of [0,1,2]){
 const d=await composeDesiredOwnership(`Does Nora not want ${subject}to not own this tea [${inner}]? [${outer}]`,{allowDraft:true,framework:'"Harbor charter"'}),midi=await midiFromDesiredOwnership(d,authority,{allowDraft:true}),r=decodeDesiredOwnershipMidi(midi,authority.atoms,{allowDraft:true});
 documents.push(d);assert.equal(r.runtime_state,outer);assert.equal(r.content.runtime_state,inner);assert.equal(r.speech_act,'question');assert.equal(r.content.speech_act,'assertion');assert.equal(r.content_status,'intensional');assert.equal(r.outcome_commitment,'desired_not_asserted');assert.deepEqual(r.scopes,[{operator:'negation'}]);assert.deepEqual(r.content.scopes,[{operator:'negation'}]);assert.equal(r.subject_binding,d.subject_binding);assert.deepEqual(r.content.framework.phonemes,d.content.framework.name.phonemes);
 if(subject)assert.notDeepEqual(r.holder,r.content.owner);else assert.deepEqual(r.holder,r.content.owner);
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(midi,authority.atoms,records,{allowDraft:true}),r);assert.deepEqual(decodeDesiredOwnershipMidi(await midiFromDesiredOwnership(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);assert.throws(()=>decodeDesiredOwnershipMidi(midi,authority.atoms));sounds.add(Buffer.from(midi).toString('base64'));
}
assert.equal(sounds.size,18);console.log('PASS 18 desired ownership musical contrasts preserve subject control, scoped ownership framework, separate negations and runtime pairs; unique shared inverse and transposition verified.');

const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_desired_ownership','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroDesiredOwnership.midi(d,allow_draft:true))})"],{input:JSON.stringify(documents),encoding:'utf8',maxBuffer:16000000}));
for(const [i,d] of documents.entries())assert.equal(Buffer.from(await midiFromDesiredOwnership(d,authority,{allowDraft:true})).toString('base64'),ruby[i]);
const corrupted=[];
for(const [key,value] of [['content_status','asserted'],['outcome_commitment','happens'],['foundation_id','wrong'],['subject_binding','same_as_desire_holder']]){
 const d=structuredClone(documents.at(-1));d[key]=value;delete d.content_id;delete d.content_digest;const hash=await canonicalDigest(d);d.content_digest=hash;d.content_id=`EZDESOWN:${hash.slice(0,24)}`;corrupted.push(d);
}
const rejects=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_desired_ownership','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|begin;EraZeroDesiredOwnership.midi(d,allow_draft:true);false;rescue ArgumentError;true;end})"],{input:JSON.stringify(corrupted),encoding:'utf8'}));assert(rejects.every(Boolean));
console.log('PASS 18 independent desired-ownership performances match; rehashed assertion, foundation and subject-control corruption rejects.');
