import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
import {createKnowledgeAcquisition as create,validateKnowledgeAcquisition as validate,evaluateKnowledgeAcquisition as evaluate} from '../pages/knowledge_acquisition.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url))),authority=read('pages/data/index.json'),records=read('pages/data/foundation_preview_candidates.json').records;
const load=id=>({...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority});
const compose=input=>composeFoundationSentence(input,authority,records,load,{allowDraft:true,allowCognitive:true});
const source=await compose('Nora knows whether Eli is not conscious.'),document=await create(source,{allowDraft:true});
assert.deepEqual(document.result_state,source.semantic_ir);assert.equal(document.transition_root,'ORI:110');assert.equal(document.result_assertion,'at_culmination_only');assert.equal(document.phase_contract.after,'unspecified');
for(const input of ['Nora does not know whether Eli is conscious.','Nora knew whether Eli is conscious.','Does Nora know whether Eli is conscious?','Nora wants Eli to be conscious.'])await assert.rejects(async()=>create(await compose(input),{allowDraft:true}));
await assert.rejects(()=>create(source));
for(const change of [d=>{d.phase_contract.after='holds'},d=>{d.result_assertion='at_speech_time'},d=>{d.transition_root='MIN:110'},d=>{d.result_state.nodes.find(n=>n.target_type==='foundation').runtime_state.code=2}]){
 const d=structuredClone(document);change(d);const {content_digest,acquisition_id,...body}=d;d.content_digest=await canonicalDigest(body);d.acquisition_id=`EZACQ:${d.content_digest.slice(0,24)}`;await assert.rejects(()=>validate(d,{allowDraft:true}));
}
// Independent exhaustive completion semantics for all partially known phases.
const expand=x=>x===null?[false,true]:[x];let count=0;
for(const before of [false,true,null])for(const culmination of [false,true,null])for(const transitionCompleted of [false,true,null]){
 const outcomes=new Set(expand(before).flatMap(b=>expand(culmination).flatMap(c=>expand(transitionCompleted).map(t=>!b&&c&&t))));
 assert.equal(evaluate({before,culmination,transitionCompleted}),outcomes.size===1?[...outcomes][0]:null);count++;
}
for(const n of [0,1,2])assert.throws(()=>evaluate({before:n,culmination:true,transitionCompleted:true}));
console.log(`PASS acquisition result identity, nonassertion-at-speech-time, phase invariants, invalid state/time/mutation rejection and ${count} independently enumerated partial-information contrasts. Draft semantic contract only; English and music not yet admitted.`);
