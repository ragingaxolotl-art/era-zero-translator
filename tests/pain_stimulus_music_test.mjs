import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composePainStimulusSentence} from '../pages/pain_stimulus_sentences.mjs';
import {createPainStimulus} from '../pages/pain_stimulus.mjs';
import {composePainMeaning} from '../pages/pain_meaning.mjs';
import {midiFromPainStimulus,decodePainStimulusMidi} from '../pages/pain_stimulus_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set(),documents=[];
for(const phrase of ['The treatment caused bodily pain for Nora.','The treatment is not expected to cause bodily pain for Nora.','Does the treatment tend to cause bodily pain for Nora?'])for(const state of [0,1,2])for(const outcomeState of [0,1,2]){
 const base=await composePainStimulusSentence(`${phrase} [${state}]`,{allowDraft:true});
 const d=await createPainStimulus(base.stimulus,await composePainMeaning(`Nora is in bodily pain. [${outcomeState}]`,{allowDraft:true}),{allowDraft:true,relation:base.relation,runtimeState:state,speechAct:base.speech_act,scopes:base.scopes});
 documents.push(d);
 const bytes=await midiFromPainStimulus(d,authority,{allowDraft:true}),r=decodePainStimulusMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(r.relation,d.relation);assert.equal(r.runtime_state,state);assert.equal(r.outcome.runtime_state,outcomeState);assert.deepEqual(r.stimulus.phonemes,d.stimulus.name.phonemes);assert.deepEqual(r.outcome.experiencer.phonemes,d.outcome.experiencer.name.phonemes);assert.deepEqual(r.scopes,d.scopes);assert.equal(r.speech_act,d.speech_act);assert.equal(r.outcome_scope,d.outcome_scope);
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true}),r);assert.throws(()=>decodePainStimulusMidi(bytes,authority.atoms));
 assert.deepEqual(decodePainStimulusMidi(await midiFromPainStimulus(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);
 sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,27);console.log('PASS 27 stimulus/outcome runtime contrasts preserve relations, separate participants and scopes through unique shared MIDI decoding and transposition.');

const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_pain_stimulus','-rjson','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroPainStimulus.midi(d,allow_draft:true))})"],{input:JSON.stringify(documents),encoding:'utf8',maxBuffer:12000000}));
for(const [i,d] of documents.entries())assert.equal(Buffer.from(await midiFromPainStimulus(d,authority,{allowDraft:true})).toString('base64'),ruby[i]);
console.log('PASS 27 independent Ruby pain-stimulus performances match JavaScript with distinct outer and nested runtime values.');
const rejects=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_pain_stimulus','-rjson','-e',`d=JSON.parse(STDIN.read);checks=[];begin;EraZeroPainStimulus.midi(d);checks<<false;rescue ArgumentError;checks<<true;end;%w[criterion outcome_scope relation runtime_state].each do |key|;x=Marshal.load(Marshal.dump(d));x[key]='altered';hash=EraZeroContextualContent.digest(x.reject{|k,_|%w[content_id content_digest].include?(k)});x['content_digest']=hash;x['content_id']="EZPAINSTIM:#{hash[0,24]}";begin;EraZeroPainStimulus.midi(x,allow_draft:true);checks<<false;rescue ArgumentError;checks<<true;end;end;puts JSON.generate(checks)`],{input:JSON.stringify(documents[0]),encoding:'utf8'}));
assert.deepEqual(rejects,[true,true,true,true,true]);
console.log('PASS Ruby rejects unapproved draft use and rehashed relation, criterion, outcome-scope and runtime corruption.');
