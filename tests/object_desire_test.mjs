import assert from 'node:assert/strict';
import fs from 'node:fs';
import {objectDesirePlan,composeObjectDesire} from '../pages/object_desire.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeFoundationSentenceMidi} from '../pages/foundation_semantic_decoder.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),records=JSON.parse(fs.readFileSync(new URL('../reviews/foundation_extension_candidates.json',import.meta.url))).records;
const load=id=>!authority.resolution_files[id]?{authority}:({...JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files[id],import.meta.url))).variants['assertion:1'],authority});
const compose=(input,desiredProposition)=>composeObjectDesire(input,authority,records,load,{allowDraft:true,desiredProposition});
assert.equal(objectDesirePlan('Nora wants tea.').automatic_relation,null);
await assert.rejects(compose('Nora wants tea.'),/Specify/);
await assert.rejects(compose('Nora wants tea.','Eli is happy.'),/original object/);
const sounds=new Set();
for(const form of ['Nora wants tea.','Nora does not want tea.','Does Nora want tea?'])for(const state of [0,1,2]){
 const input=form+` [${state}]`,r=await compose(input,'Eli has physical custody of the tea.'),bytes=midiFromFormal(r.formal),decoded=await decodeFoundationSentenceMidi(bytes,authority.atoms,records,{allowDraft:true});
 assert.equal(decoded.meaning.runtime_state,state);assert.equal(decoded.speech_act,form.endsWith('?')?'question':'assertion');assert.deepEqual(decoded.meaning.scopes,form.includes('not')?[{operator:'negation'}]:[]);assert.equal(decoded.meaning.arguments.content.content_status,'intensional');assert.equal(decoded.meaning.arguments.content.proposition.predicate.name,'practical_physical_custody');assert.equal(decoded.meaning.arguments.content.proposition.meaning.ownership_asserted,false);assert.equal(r.object_desire_resolution.relation_source,'explicit_user_clarification');assert(r.object_desire_resolution.matching_content_references.length);sounds.add(Buffer.from(bytes).toString('base64'));
}
assert.equal(sounds.size,9);console.log('PASS object desire requires explicit content, rejects unrelated outcomes, and preserves outer scope/runtime/question through existing music.');
