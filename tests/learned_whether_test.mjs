import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeLearnedWhether as compose,parseLearnedWhether as parse} from '../pages/learned_whether.mjs';
import {midiFromKnowledgeAcquisition as midi} from '../pages/knowledge_acquisition_music.mjs';
import {decodeFoundationSentenceMidi as decode} from '../pages/foundation_semantic_decoder.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url))),data=read('pages/data/index.json'),records=read('pages/data/foundation_preview_candidates.json').records;
const load=id=>({...read('pages/'+data.resolution_files[id]).variants['assertion:1'],authority:data}),cases=[];
for(const runtime of [0,1,2])for(const [text,outer,inner] of [
 ['Nora learned whether Eli is conscious.',['before_speech'],[]],
 ["Nora didn't learn whether Eli is conscious.",['before_speech','negation'],[]],
 ['Did Nora learn whether Eli is not conscious?',['before_speech'],['negation']],
 ["Didn't Nora learn whether Eli was conscious?",['before_speech','negation'],['before_speech']],
 ['Yesterday, Nora learned whether Eli is conscious.',['previous_day'],[]],
 ['Today, Nora learned whether Eli was conscious yesterday.',['current_day','before_speech'],['previous_day']]
]){
 const result=await compose(text+` [${runtime}]`,data,records,load,{allowDraft:true}),bytes=await midi(result.acquisition,result.result_formal,data,{allowDraft:true});
 const d=await decode(bytes,data.atoms,records,{allowDraft:true,allowDraftQuestionContent:true,allowDraftAcquisition:true});
 assert.equal(d.meaning.predicate.root_id,'ORI:110');assert.equal(d.meaning.runtime_state,runtime);assert.deepEqual(d.meaning.scopes.map(s=>s.relation||s.operator),outer);
 assert.equal(d.meaning.result.runtime_state,1);assert.deepEqual(d.meaning.result.scopes,[]);assert.deepEqual(d.meaning.result.arguments.content.proposition.scopes.map(s=>s.relation||s.operator),inner);
 assert.equal(d.speech_act,text.endsWith('?')?'question':'assertion');assert.equal(d.meaning.result_assertion,'at_culmination_only');cases.push({document:result.acquisition,midi:Buffer.from(bytes).toString('base64')});
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_knowledge_acquisition','-rbase64','-e',"puts JSON.generate(JSON.parse(STDIN.read).map{|d|Base64.strict_encode64(EraZeroKnowledgeAcquisition.midi(d,allow_draft:true))})"],{cwd:new URL('..',import.meta.url),input:JSON.stringify(cases.map(c=>c.document)),encoding:'utf8',maxBuffer:15_000_000}));assert.deepEqual(ruby,cases.map(c=>c.midi));
for(const input of ['Nora learned the route.','Nora learned that Eli is conscious.','Nora learns whether Eli is conscious.','Nora learned whether Eli is conscious? [1].'])assert.equal(parse(input),null);
await assert.rejects(()=>compose('Nora learned whether the map.',data,records,load,{allowDraft:true}));
await assert.rejects(()=>compose('Nora learned whether Eli is conscious.',data,records,load));
console.log('PASS 18 learned-whether English cases: acquisition rather than past knowledge, independent event/content time and negation, runtime, questions/contractions, MIDI-only meanings and exact Ruby audio parity. Main UI not yet admitted.');
