import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeDrinkingSentence} from '../pages/drinking_sentences.mjs';
import {midiFromDrinking,decodeDrinkingMidi} from '../pages/drinking_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set(),documents=[];
for(const viewpoint of ['ongoing','bounded','habitual'])for(const state of [0,1,2])for(const [material,reading] of [['tea','kind'],['this tea','contextual_portion']]){
 const d=await composeDrinkingSentence(`Does Nora not drink ${material}? [${state}]`,{allowDraft:true,interpretation:'literal_drinking',viewpoint,materialReading:reading}),bytes=await midiFromDrinking(d,authority,{allowDraft:true}),r=decodeDrinkingMidi(bytes,authority.atoms,{allowDraft:true});
 documents.push(d);
 assert.equal(r.viewpoint,viewpoint);assert.equal(r.runtime_state,state);assert.equal(r.material.reading,reading);assert.deepEqual(r.material.reference.phonemes,d.material.reference.name.phonemes);assert.deepEqual(r.drinker.phonemes,d.drinker.name.phonemes);assert.deepEqual(r.scopes,[{operator:'negation'}]);assert.equal(r.speech_act,'question');assert.equal(r.whole_amount_consumption,'not_asserted');
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true}),r);assert.throws(()=>decodeDrinkingMidi(bytes,authority.atoms));assert.deepEqual(decodeDrinkingMidi(await midiFromDrinking(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,18);console.log('PASS 18 drinking MIDI contrasts recover viewpoint, material kind/portion, participants, negated question and runtime via shared dispatch and transposition.');

const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_drinking','-rjson','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroDrinking.midi(d,allow_draft:true))})"],{input:JSON.stringify(documents),encoding:'utf8',maxBuffer:16000000}));
for(const [i,d] of documents.entries())assert.equal(Buffer.from(await midiFromDrinking(d,authority,{allowDraft:true})).toString('base64'),ruby[i]);
console.log('PASS 18 independent Ruby drinking performances match JavaScript.');
const rejected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_drinking','-rjson','-e',`d=JSON.parse(STDIN.read);checks=[];begin;EraZeroDrinking.midi(d);checks<<false;rescue ArgumentError;checks<<true;end;%w[action_category viewpoint_contract whole_amount_consumption runtime_state].each do |key|;x=Marshal.load(Marshal.dump(d));x[key]='altered';hash=EraZeroContextualContent.digest(x.reject{|k,_|%w[content_id content_digest].include?(k)});x['content_digest']=hash;x['content_id']="EZDRINK:#{hash[0,24]}";begin;EraZeroDrinking.midi(x,allow_draft:true);checks<<false;rescue ArgumentError;checks<<true;end;end;puts JSON.generate(checks)`],{input:JSON.stringify(documents[0]),encoding:'utf8'}));assert.deepEqual(rejected,[true,true,true,true,true]);
console.log('PASS independent renderer rejects default draft use and rehashed action, viewpoint, total-consumption and runtime changes.');
