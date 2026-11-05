import assert from 'node:assert/strict';
import fs from 'node:fs';
import {parseNamedSentence,composeNamedSentence,composeSentenceConjunction} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const load=async id=>authority.compound_plans[id]?{authority}:JSON.parse(fs.readFileSync(new URL('pages/'+authority.resolution_files[id],root))).variants['assertion:1'];
let count=0;
for(const state of [0,1,2])for(const [short,long,options] of [
 ["Eli isn't swimming.",'Eli is not swimming.'],
 ["Eli wasn’t swimming yesterday.",'Eli was not swimming yesterday.'],
 ["Eli doesn't swim across the river.",'Eli does not swim across the river.',{viewpoint:'habitual'}],
 ["I don't habitually swim.",'I do not habitually swim.'],
 ["Nora can't repair the radio.",'Nora cannot repair the radio.'],
 ["Nora didn't repair the radio.",'Nora did not repair the radio.'],
 ["Don't carry the box.",'Do not carry the box.'],
 ["Isn't Eli swimming?",'Is Eli not swimming?'],
 ["Doesn't Eli swim across the river?",'Does Eli not swim across the river?',{viewpoint:'ongoing'}],
 ["Didn't Nora repair the radio?",'Did Nora not repair the radio?'],
 ["The lamp isn't physically energized.",'The lamp is not physically energized.']
]){
 const input=short+` [${state}]`,expanded=long+` [${state}]`,p=parseNamedSentence(input);assert(p,input);
 const a=await composeNamedSentence(input,await load(p.predicate),options),b=await composeNamedSentence(expanded,await load(p.predicate),options);
 assert.deepEqual(a.formal,b.formal,input);assert.deepEqual(midiFromFormal(a.formal),midiFromFormal(b.formal),input);assert.equal(a.source_input,input);count++;
}
const a=await composeSentenceConjunction("Eli isn't swimming and Nora can't repair the radio.",load),b=await composeSentenceConjunction('Eli is not swimming and Nora cannot repair the radio.',load);assert.deepEqual(a.formal,b.formal);
for(const input of ["Eli's swimming.","Eli'd swim.",`"Isn't" is conscious.`,"Eli couldn't understand Nora."])assert.equal(parseNamedSentence(input),null,input);
console.log(`PASS ${count} contraction/state paraphrases and mixed conjunction preserve full formal/MIDI meaning; unsupported meanings and quoted labels are not rewritten.`);
