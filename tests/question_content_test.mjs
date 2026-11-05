import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composePolarQuestionContent as compose,validatePolarQuestionContent as validate,polarAnswerAlternatives as answers} from '../pages/question_content.mjs';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const data=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const load=id=>data.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority:data}:{...JSON.parse(fs.readFileSync(new URL('../pages/'+data.resolution_files[id],import.meta.url))).variants['assertion:1'],authority:data};
const documents=[];
for(const state of [0,1,2])for(const text of ['Nora is conscious.','Nora is not conscious.','Eli is repairing the radio.','Eli is swimming.']){
 const input=text+` [${state}]`,question=await compose('whether '+input,load,{allowDraft:true});
 const parsed=parseNamedSentence(input),assertion=await composeNamedSentence(input,await load(parsed.predicate));
 assert.deepEqual(question.proposition,assertion.semantic_ir);assert.equal(question.assertion_commitment,'neither_answer');
 assert.equal((await validate(question,{allowDraft:true})).content_id,question.content_id);
 const copy=await validate(question,{allowDraft:true});copy.proposition.nodes[0].node_id='changed';assert.notDeepEqual(copy,question);
 documents.push(question);
}
assert.equal(new Set(documents.map(d=>d.content_id)).size,12);
assert.deepEqual(answers(true),{positive:true,negative:false});assert.deepEqual(answers(false),{positive:false,negative:true});assert.deepEqual(answers(null),{positive:null,negative:null});
for(const runtime of [0,1,2])assert.throws(()=>answers(runtime),/runtime/);
await assert.rejects(()=>compose('whether Nora is conscious.',load),/opt-in/);
for(const input of ['the map','whether the map','whether Nora is curious.','whether Is Nora conscious?'])await assert.rejects(()=>compose(input,load,{allowDraft:true}));
for(const change of [d=>{d.assertion_commitment='positive'},d=>{d.truth=true},d=>{d.proposition.speech_act='question'},d=>{d.proposition.nodes.find(n=>n.kind==='lexical_occurrence').runtime_state.code=2}]){
 const d=structuredClone(documents[0]);change(d);const {content_id,content_digest,...body}=d;d.content_digest=await canonicalDigest(body);d.content_id=`EZQ:${d.content_digest.slice(0,24)}`;
 await assert.rejects(()=>validate(d,{allowDraft:true}));
}
console.log('PASS 12 polar-content compositions preserve complete proposition graphs and all runtime states; questions assert neither answer, reject runtime-as-truth and malformed/rehashed content.');
