import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence as compose} from '../pages/foundation_sentences.mjs';
import {decodeFoundationSentenceMidi as decode} from '../pages/foundation_semantic_decoder.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url))),authority=read('pages/data/index.json'),records=read('pages/data/foundation_preview_candidates.json').records;
const load=id=>({...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority}),results=[];
for(const state of [0,1,2])for(const [text,outer,inner] of [
 ['Nora knew whether Eli is conscious.',['before_speech'],[]],
 ["Nora didn't know whether Eli is conscious.",['before_speech','negation'],[]],
 ['Did Nora know whether Eli was conscious?',['before_speech'],['before_speech']],
 ['Yesterday, Nora knew whether Eli is conscious.',['previous_day'],[]],
 ['Today, Nora knew whether Eli was conscious yesterday.',['current_day','before_speech'],['previous_day']],
 ['Nora knows whether Eli was conscious yesterday.',[],['previous_day']],
 ["Didn't Nora know whether Eli was not conscious?",['before_speech','negation'],['before_speech','negation']]
]){
 const r=await compose(text+` [${state}]`,authority,records,load,{allowDraft:true,allowCognitive:true}),d=await decode(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true,allowDraftQuestionContent:true});
 assert.deepEqual(d.meaning.scopes.map(s=>s.relation||s.operator),outer,text);assert.deepEqual(d.meaning.arguments.content.proposition.scopes.map(s=>s.relation||s.operator),inner,text);
 assert.equal(d.meaning.runtime_state,state);assert.equal(d.speech_act,text.endsWith('?')?'question':'assertion');results.push(r);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"x=JSON.parse(STDIN.read);puts JSON.generate(x['irs'].map{|ir|f=EraZeroRenderer.render(ir,foundation_records:x['records'],allow_draft_foundations:true);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,foundation_records:x['records'],allow_draft_foundations:true))}})"],{cwd:new URL('..',import.meta.url),input:JSON.stringify({irs:results.map(r=>r.semantic_ir),records}),encoding:'utf8',maxBuffer:15_000_000}));
results.forEach((r,i)=>{assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi)});
for(const text of ['Yesterday, Nora knows whether Eli is conscious.','Nora learned whether Eli is conscious.','Nora will know whether Eli is conscious.'])await assert.rejects(()=>compose(text,authority,records,load,{allowDraft:true,allowCognitive:true}));
console.log('PASS 21 knowledge time/state cases: separate outer and question-content times/negation, questions and contractions, full Ruby formal/MIDI parity and independent musical scope recovery.');
