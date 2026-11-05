import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composePainPreference} from '../pages/pain_preference.mjs';
import {midiFromPainPreference,decodePainPreferenceMidi} from '../pages/pain_preference_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),sounds=new Set();
for(const reverse of [false,true])for(const form of ['assertion','negation','question'])for(const state of [0,1,2]){
 const a=reverse?'more painful':'painful',b=reverse?'painful':'more painful',input=(form==='question'?`Does Nora prefer the ${a} treatment to the ${b} treatment?`:`Nora ${form==='negation'?'does not prefer':'prefers'} the ${a} treatment to the ${b} treatment.`)+` [${state}]`;
 const d=await composePainPreference(input,{allowDraft:true,experiencer:'Eli',interpretation:'expected_outcome',context:'this session',comparisonTarget:'other_alternative'}),bytes=await midiFromPainPreference(d,authority,{allowDraft:true}),r=decodePainPreferenceMidi(bytes,authority.atoms,{allowDraft:true});
 assert.equal(r.foundation_id,d.foundation_id);assert.equal(r.more_painful_role,d.more_painful_role);assert.equal(r.restriction_scope,d.restriction_scope);assert.equal(r.runtime_state,state);assert.deepEqual(r.scopes,d.scopes);assert.equal(r.speech_act,d.speech_act);
 assert.deepEqual(r.holder.phonemes,d.holder.name.phonemes);assert.deepEqual(r.pain_comparison.left.outcome.experiencer.phonemes,d.pain_comparison.left.outcome.experiencer.name.phonemes);
 assert.deepEqual(r.target.phonemes,r.comparison_standard.phonemes);assert.notEqual(r.target.instance_code,r.comparison_standard.instance_code);assert.equal(r.pain_comparison.scopes.length,0);
 assert.deepEqual(await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,[],{allowDraft:true}),r);assert.throws(()=>decodePainPreferenceMidi(bytes,authority.atoms));
 assert.deepEqual(decodePainPreferenceMidi(await midiFromPainPreference(d,authority,{allowDraft:true,anchor:72}),authority.atoms,{allowDraft:true}),r);sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,18);console.log('PASS 18 complete pain-preference MIDI inverses preserve holder, separate pain experiencer, ordered restrictions, scope, question and runtime; transposition and shared dispatch agree.');
