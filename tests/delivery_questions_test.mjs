import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeNamedSentence} from '../pages/sentences.mjs';
import {composePronounSentence} from '../pages/pronouns.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeCustodyDeliveryMidi} from '../pages/delivery_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),load=()=>({authority});
let count=0;
for(const state of [0,1,2])for(const [delivery,carrying,viewpoint] of [
 ['Does Nora deliver this tea to Eli?','Does Nora carry this tea to Eli?','bounded'],
 ['Did Nora not deliver this tea to Eli?','Did Nora not carry this tea to Eli?'],
 ["Didn't Nora deliver this tea to Eli?","Didn't Nora carry this tea to Eli?"],
 ['Is Nora delivering this tea to Eli?','Is Nora carrying this tea to Eli?'],
 ['Was Nora not delivering this tea to Eli?','Was Nora not carrying this tea to Eli?'],
 ['Do I deliver this tea to you?','Do I carry this tea to you?','habitual']
]){
 const options={destination:'custody_delivery',...(viewpoint?{viewpoint}:{})},a=await composeNamedSentence(delivery+` [${state}]`,{authority},options),b=await composeNamedSentence(carrying+` [${state}]`,{authority},options);
 assert.deepEqual(a.semantic_ir,b.semantic_ir);assert.deepEqual(midiFromFormal(a.formal),midiFromFormal(b.formal));
 const inverse=decodeCustodyDeliveryMidi(midiFromFormal(a.formal),authority.atoms);assert.equal(inverse.speech_act,'question');assert.equal(inverse.runtime_state,state);assert.equal(inverse.meaning.ownership_asserted,false);count++;
}
for(const [source,target,viewpoint] of [
 ['They deliver this tea to them.','Nora delivers this tea to Eli.','ongoing'],
 ['Do they deliver this tea to them?','Does Nora deliver this tea to Eli?','bounded'],
 ['They habitually deliver this tea to them.','Nora habitually delivers this tea to Eli.'],
 ['Are they delivering this tea to them?','Is Nora delivering this tea to Eli?']
]){
 const options={destination:'custody_delivery',...(viewpoint?{viewpoint}:{})},a=await composePronounSentence(source,load,{ref0:{referent:'Nora',number:'singular'},ref1:{referent:'Eli',number:'singular'}},options),b=await composeNamedSentence(target,{authority},options);
 assert.deepEqual(a.semantic_ir,b.semantic_ir);assert.deepEqual(midiFromFormal(a.formal),midiFromFormal(b.formal));const inverse=decodeCustodyDeliveryMidi(midiFromFormal(a.formal),authority.atoms);assert.notDeepEqual(inverse.participants.carrier,inverse.participants.recipient);
}
await assert.rejects(composeNamedSentence('Did Nora deliver this tea to Eli?',{authority},{destination:'spatial'}),/explicitly/);
console.log(`PASS ${count} delivery question/runtime contrasts and four neutral participant cases preserve full meanings/music without inferring gender or receipt outside question scope.`);
