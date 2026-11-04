import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeCognitiveConjunction,cognitiveConjunctionPlan,createCognitiveConjunction,validateCognitiveConjunction} from '../pages/cognitive_conjunction.mjs';
import {midiFromCognitiveConjunction,decodeCognitiveConjunctionMidi} from '../pages/cognitive_conjunction_music.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {midiFromCuriosity} from '../pages/curiosity_music.mjs';
import {midiFromUnderstanding} from '../pages/understanding_music.mjs';
import {midiFromUnderstandingAcquisition} from '../pages/understanding_acquisition_music.mjs';
import {midiFromRouteLearning} from '../pages/route_learning_music.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url))).records;
const clauses=['Orin is not curious about the map','Eli understands what Nora said','Nora learned this route','Eli came to understand Nora’s reasons'];
let count=0;
for(let left=0;left<4;left++)for(let right=0;right<4;right++)for(const runtime of [0,1,2]){
 const input=`${clauses[left]} [${runtime}] and ${clauses[right]} [${2-runtime}].`;
 const options=[left,right].map(index=>index===2?{interpretation:'navigation',resultRuntime:0}:{});
 const d=await composeCognitiveConjunction(input,{allowDraft:true,clauseOptions:options}),midi=await midiFromCognitiveConjunction(d,authority,records,{allowDraft:true}),r=await decodeSupportedMeaningWithDrafts(midi,authority.atoms,records,{allowDraft:true});
 assert.equal(r.operator,'all_of');assert.equal(r.members.length,2);
 for(const [i,member] of d.members.entries()){
  const bytes=member.profile==='EZCURIOSITY-1'?await midiFromCuriosity(member,authority,records,{allowDraft:true}):await ({'EZUNDERSTANDING-CONTENT-1':midiFromUnderstanding,'EZROUTE-LEARNING-1':midiFromRouteLearning,'EZUNDERSTANDING-ACQUISITION-1':midiFromUnderstandingAcquisition}[member.profile])(member,authority,{allowDraft:true});
  assert.deepEqual(r.members[i],await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,records,{allowDraft:true}));
 }
 await assert.rejects(()=>decodeCognitiveConjunctionMidi(midi,authority.atoms,records));count++;
}
await assert.rejects(()=>composeCognitiveConjunction('Orin is curious about the map and Nora learned the route.',{allowDraft:true}),e=>e.code==='route_learning_interpretation_required'&&e.clause_index===1);
const d=await composeCognitiveConjunction('They are curious about the map and Eli understands Nora.',{allowDraft:true,clauseOptions:[{bindings:{ref0:{referent:'Orin',number:'singular'}}},{interpretation:'perspective'}]});
assert.equal(d.members[0].experiencer.name.normalized_label,'orin');assert.equal(d.members[1].content.content_kind,'perspective');
assert.equal(cognitiveConjunctionPlan('"Ash and Elm" is curious about the map and Eli understands Nora.').clauses.length,2);
for(const input of ['Orin is curious about the map and the route.','Is Orin curious about the map and Eli understands Nora?','Orin is curious about the map or Eli understands Nora.'])assert.equal(cognitiveConjunctionPlan(input),null);
await assert.rejects(()=>createCognitiveConjunction([d.members[0]],{allowDraft:true}));
const corrupted=structuredClone(d);corrupted.members[0].outcome_commitment='asserted';const {content_id,content_digest,...body}=corrupted,digest=await canonicalDigest(body);corrupted.content_digest=digest;corrupted.content_id=`EZCOGAND:${digest.slice(0,24)}`;await assert.rejects(()=>validateCognitiveConjunction(corrupted,{allowDraft:true}));
console.log(`PASS ${count} mixed cognitive conjunctions: complete member meanings independently recovered, local negation and runtimes preserved, interpretation/pronoun choices explicit, malformed composition rejected.`);

for(const size of [3,8]){
 const combined=await createCognitiveConjunction(Array.from({length:size},(_,i)=>d.members[i%2]),{allowDraft:true});
 const bytes=await midiFromCognitiveConjunction(combined,authority,records,{allowDraft:true,anchor:72});
 assert.equal((await decodeCognitiveConjunctionMidi(bytes,authority.atoms,records,{allowDraft:true})).members.length,size);
}
await assert.rejects(()=>createCognitiveConjunction(Array(9).fill(d.members[0]),{allowDraft:true}));
console.log('PASS three/eight-member transposed conjunctions and oversized-document rejection.');
