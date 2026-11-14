import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {composePainMeaning} from '../pages/pain_meaning.mjs';
import {midiFromPain,decodePainMidi} from '../pages/pain_music.mjs';
import {decodeFeltConditionMidi} from '../pages/felt_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set(),documents=[];
for(const state of [0,1,2])for(const past of [false,true])for(const neg of [false,true])for(const q of [false,true]){
 const text=(q?`${past?'Was':'Is'} Nora ${neg?'not ':''}in bodily pain?`:`Nora ${past?'was':'is'} ${neg?'not ':''}in bodily pain.`)+` [${state}]`;
 const d=await composePainMeaning(text,{allowDraft:true}),bytes=await midiFromPain(d,authority,{allowDraft:true}),r=decodePainMidi(bytes,authority.atoms,{allowDraft:true});
 documents.push(d);
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true}),r);
 assert.equal(r.predicate,d.predicate);assert.deepEqual(r.experiencer.phonemes,d.experiencer.name.phonemes);assert.deepEqual(r.scopes,d.scopes);assert.equal(r.runtime_state,state);assert.equal(r.speech_act,d.speech_act);assert.equal(r.injury_commitment,'not_entailed');
 assert.throws(()=>decodePainMidi(bytes,authority.atoms));assert.throws(()=>decodeFeltConditionMidi(bytes,authority.atoms));
 sounds.add(Buffer.from(bytes).toString('base64'));
 const shifted=await midiFromPain(d,authority,{allowDraft:true,anchor:72});assert.deepEqual(decodePainMidi(shifted,authority.atoms,{allowDraft:true}),r);
}
assert.equal(sounds.size,24);console.log('PASS 24 pain music contrasts with full MIDI meaning recovery, transposition, default opt-out and generic-feeling cross-rejection.');

for(const text of ['I am in bodily pain.','You are in bodily pain.','This robot is in bodily pain.','"Mary Jane" was in bodily pain.'])documents.push(await composePainMeaning(text,{allowDraft:true}));
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_pain','-rjson','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d| Base64.strict_encode64(EraZeroPain.midi(d,allow_draft:true))})"],{input:JSON.stringify(documents),encoding:'utf8',maxBuffer:12000000}));
for(const [i,d] of documents.entries())assert.equal(Buffer.from(await midiFromPain(d,authority,{allowDraft:true})).toString('base64'),ruby[i]);
console.log('PASS 28 independent Ruby pain performances match JavaScript, including deictic, demonstrative and quoted-name references.');
const rejected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_pain','-rjson','-e',`d=JSON.parse(STDIN.read);checks=[];begin;EraZeroPain.midi(d);checks<<false;rescue ArgumentError;checks<<true;end;%w[quality injury_commitment dependency runtime_state].each do |field|;x=Marshal.load(Marshal.dump(d));x[field]='altered';body=x.reject{|k,_|%w[content_digest content_id].include?(k)};hash=EraZeroContextualContent.digest(body);x['content_digest']=hash;x['content_id']="EZPAIN:#{hash[0,24]}";begin;EraZeroPain.midi(x,allow_draft:true);checks<<false;rescue ArgumentError;checks<<true;end;end;puts JSON.generate(checks)`],{input:JSON.stringify(documents[0]),encoding:'utf8'}));
assert.deepEqual(rejected,[true,true,true,true,true]);
console.log('PASS Ruby rejects default draft use and rehashed changes to pain quality, injury commitment, dependency and runtime.');
