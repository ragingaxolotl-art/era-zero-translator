import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeDesiredDrinking} from '../pages/desired_drinking.mjs';
import {midiFromDesiredDrinking,decodeDesiredDrinkingMidi} from '../pages/desired_drinking_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set(),documents=[];
for(const subject of ['', 'Eli '])for(const outerNeg of ['', 'not '])for(const innerNeg of ['', 'not '])for(const state of [0,1,2]){
 const d=await composeDesiredDrinking(`Does Nora ${outerNeg}want ${subject}to ${innerNeg}drink tea? [${state}]`,{allowDraft:true,interpretation:'literal_drinking',viewpoint:'bounded',materialReading:'kind'}),bytes=await midiFromDesiredDrinking(d,authority,{allowDraft:true}),r=decodeDesiredDrinkingMidi(bytes,authority.atoms,{allowDraft:true});
 documents.push(d);
 assert.equal(r.runtime_state,state);assert.equal(r.content.runtime_state,1);assert.equal(r.content_status,'intensional');assert.equal(r.subject_binding,d.subject_binding);assert.deepEqual(r.holder.phonemes,d.holder.name.phonemes);assert.deepEqual(r.content.drinker.phonemes,d.content.drinker.name.phonemes);assert.deepEqual(r.scopes,outerNeg?[{operator:'negation'}]:[]);assert.deepEqual(r.content.scopes,innerNeg?[{operator:'negation'}]:[]);assert.equal(r.speech_act,'question');assert.equal(r.content.material.reading,'kind');
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true}),r);assert.throws(()=>decodeDesiredDrinkingMidi(bytes,authority.atoms));assert.deepEqual(decodeDesiredDrinkingMidi(await midiFromDesiredDrinking(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,24);console.log('PASS 24 desired-drinking musical contrasts preserve subject control, separate negations, question and runtime through shared inverse/transposition.');

const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_desired_drinking','-rjson','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroDesiredDrinking.midi(d,allow_draft:true))})"],{input:JSON.stringify(documents),encoding:'utf8',maxBuffer:16000000}));
for(const [i,d] of documents.entries())assert.equal(Buffer.from(await midiFromDesiredDrinking(d,authority,{allowDraft:true})).toString('base64'),ruby[i]);
const rejected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_desired_drinking','-rjson','-e',`d=JSON.parse(STDIN.read);checks=[];begin;EraZeroDesiredDrinking.midi(d);checks<<false;rescue ArgumentError;checks<<true;end;%w[content_status outcome_commitment foundation_id subject_binding].each do |key|;x=Marshal.load(Marshal.dump(d));x[key]=key=='subject_binding' ? 'same_as_desire_holder' : 'altered';hash=EraZeroContextualContent.digest(x.reject{|k,_|%w[content_id content_digest].include?(k)});x['content_digest']=hash;x['content_id']="EZDESDRINK:#{hash[0,24]}";begin;EraZeroDesiredDrinking.midi(x,allow_draft:true);checks<<false;rescue ArgumentError;checks<<true;end;end;puts JSON.generate(checks)`],{input:JSON.stringify(documents.at(-1)),encoding:'utf8'}));assert.deepEqual(rejected,[true,true,true,true,true]);
console.log('PASS 24 independent desired-drinking performances agree; rehashed scope/commitment/foundation/control corruption rejects.');
