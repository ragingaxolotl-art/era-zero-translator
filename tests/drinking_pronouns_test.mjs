import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeDrinkingSentence,drinkingPronounPlan} from '../pages/drinking_sentences.mjs';
import {midiFromDrinking,decodeDrinkingMidi} from '../pages/drinking_music.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),options={allowDraft:true,interpretation:'literal_drinking',materialReading:'contextual_portion'};
for(const [text,named] of [['They are drinking it.','Nora is drinking this tea.'],['Were they not drinking it?','Was Nora not drinking this tea?'],['Do they drink it?','Does Nora drink this tea?']])for(const state of [0,1,2]){
 const input=text+` [${state}]`,plan=drinkingPronounPlan(input);assert.equal(plan.occurrences.length,2);
 const bindings={ref0:{referent:'Nora',number:'singular'},ref1:'this tea'},d=await composeDrinkingSentence(input,{...options,viewpoint:'ongoing',bindings}),expected=await composeDrinkingSentence(named+` [${state}]`,{...options,viewpoint:'ongoing'});
 assert.deepEqual(d,expected);const bytes=await midiFromDrinking(d,authority,{allowDraft:true});assert.deepEqual(bytes,await midiFromDrinking(expected,authority,{allowDraft:true}));assert.equal(decodeDrinkingMidi(bytes,authority.atoms,{allowDraft:true}).runtime_state,state);
 await assert.rejects(composeDrinkingSentence(input,{...options,bindings:{...bindings,ref0:'Nora'}}),/one individual or a group/);
 await assert.rejects(composeDrinkingSentence(input,{...options,bindings:{...bindings,ref0:{referent:'Nora',number:'plural'}}}),/Group/);
}
console.log('PASS nine singular-they drinking cases match named meanings/music; missing number and plural coercion reject.');
