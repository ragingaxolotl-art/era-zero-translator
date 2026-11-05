import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeObjectDesiredDrinking} from '../pages/object_desired_drinking.mjs';
import {midiFromDesiredDrinking,decodeDesiredDrinkingMidi} from '../pages/desired_drinking_music.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),opts={allowDraft:true,interpretation:'literal_drinking',viewpoint:'bounded',materialReading:'contextual_portion',desiredProposition:'Eli drinks this tea [0].'};
for(const phrase of ['Nora wants this tea.','Nora does not want this tea.','Does Nora want this tea?'])for(const state of [0,1,2]){
 const input=phrase+` [${state}]`,result=await composeObjectDesiredDrinking(input,authority,opts),d=result.meaning,r=decodeDesiredDrinkingMidi(await midiFromDesiredDrinking(d,authority,{allowDraft:true}),authority.atoms,{allowDraft:true});
 assert.equal(result.source_input,input);assert.equal(result.object_desire_resolution.relation_source,'explicit_user_clarification');assert.equal(r.runtime_state,state);assert.equal(r.content.runtime_state,0);assert.equal(r.content.material.reference.reference_mode,'proximal_nominal');assert.equal(d.holder.name.normalized_label,'nora');assert.equal(d.content.drinker.name.normalized_label,'eli');assert.equal(r.outcome_commitment,'desired_not_asserted');assert.deepEqual(r.scopes,phrase.includes('not')?[{operator:'negation'}]:[]);assert.equal(r.speech_act,phrase.endsWith('?')?'question':'assertion');
}
await assert.rejects(composeObjectDesiredDrinking('Nora wants tea.',authority,{...opts,desiredProposition:undefined}),/Specify/);
await assert.rejects(composeObjectDesiredDrinking('Nora wants that tea.',authority,opts),/original object/);
await assert.rejects(composeObjectDesiredDrinking('Nora wants water.',authority,opts),/original object/);
await assert.rejects(composeObjectDesiredDrinking('Nora wants tea.',authority,{...opts,interpretation:undefined}),/Select/);
const bare=await composeObjectDesiredDrinking('Nora wants tea.',authority,{...opts,desiredProposition:'Nora drinks tea.',materialReading:'kind'});assert.equal(bare.meaning.content.material.reading,'kind');
console.log('PASS nine object-desire drinking clarifications preserve original reference and separate scope/runtime; missing or mismatched choices reject.');
