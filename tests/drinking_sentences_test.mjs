import assert from 'node:assert/strict';
import {composeDrinkingSentence,drinkingPlan} from '../pages/drinking_sentences.mjs';
const options={allowDraft:true,interpretation:'literal_drinking',materialReading:'contextual_portion'};
let count=0;
for(const [phrase,viewpoint,past,neg,question] of [
 ['Nora is drinking this tea.','ongoing',false,false,false],['Was Nora not drinking this tea?','ongoing',true,true,true],
 ['Nora drank this tea.','bounded',true,false,false],['Did Nora not drink this tea?','bounded',true,true,true],
 ['Nora habitually drinks this tea.','habitual',false,false,false],['Does Nora not habitually drink this tea?','habitual',false,true,true],
 ['I am drinking this tea.','ongoing',false,false,false],['You do not habitually drink this tea.','habitual',false,true,false]])for(const state of [0,1,2]){
 const d=await composeDrinkingSentence(phrase+` [${state}]`,options);assert.equal(d.viewpoint,viewpoint);assert.equal(d.runtime_state,state);assert.equal(d.speech_act,question?'question':'assertion');assert.deepEqual(d.scopes,[...(past?[{operator:'time',relation:'before_speech'}]:[]),...(neg?[{operator:'negation'}]:[])]);count++;
}
await assert.rejects(composeDrinkingSentence('Nora drinks tea.',{...options,materialReading:'kind'}),/Choose/);
const d=await composeDrinkingSentence('Nora drinks tea.',{...options,materialReading:'kind',viewpoint:'habitual'});assert.equal(d.material.reading,'kind');
await assert.rejects(composeDrinkingSentence('Nora is drinking this tea.',{...options,viewpoint:'bounded'}),/conflicts/);
await assert.rejects(composeDrinkingSentence('Nora is drinking this tea.',{...options,interpretation:undefined}),/Select/);
for(const text of ['Nora drink tea.','I drinks tea.','Are Nora drinking tea?','Nora does not drank tea.'])assert.equal(drinkingPlan(text),null);
console.log(`PASS ${count} drinking English scope/runtime cases; simple present, material reading and literal interpretation require explicit choices.`);
