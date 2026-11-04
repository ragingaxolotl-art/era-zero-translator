import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence as compose} from '../pages/foundation_sentences.mjs';
import {decodeFoundationSentenceMidi as decode} from '../pages/foundation_semantic_decoder.mjs';
import {validateFoundationIR} from '../pages/foundation_ir.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url))),authority=read('pages/data/index.json'),records=read('pages/data/foundation_preview_candidates.json').records;
const load=id=>({...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority});
const results=[];
for(const state of [0,1,2])for(const [phrase,outerNeg,innerNeg,controlled] of [
 ['Nora wants to know whether Eli is conscious.',false,false,true],
 ['Nora does not want to know whether Eli is conscious.',true,false,true],
 ['Nora wants not to know whether Eli is conscious.',false,true,true],
 ['Nora wants Orin to know whether Eli is conscious.',false,false,false],
 ['Does Nora want to know whether Eli is not conscious?',false,false,true]
]){
 const r=await compose(phrase+` [${state}]`,authority,records,load,{allowDraft:true,allowCognitive:true});await validateFoundationIR(r.semantic_ir,records,{allowDraft:true});
 const d=await decode(midiFromFormal(r.formal),authority.atoms,records,{allowDraft:true,allowDraftQuestionContent:true}),m=d.meaning,k=m.arguments.content.proposition;
 assert.equal(m.predicate.foundation_id,records[0].foundation_id);assert.equal(m.runtime_state,state);assert.deepEqual(m.scopes,outerNeg?[{operator:'negation'}]:[]);
 assert.equal(k.predicate.foundation_id,records[2].foundation_id);assert.deepEqual(k.scopes,innerNeg?[{operator:'negation'}]:[]);
 assert.equal(k.arguments.experiencer.reference.kind,controlled?'bound':'phonemic');
 if(controlled)assert.equal(k.arguments.experiencer.reference.binding,'parent_desire_experiencer');
 assert.equal(k.arguments.content.assertion_commitment,'neither_answer');assert.equal(k.arguments.content.proposition.predicate.root_id,'LIF:011');
 assert.equal(d.speech_act,phrase.endsWith('?')?'question':'assertion');results.push(r);
}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"x=JSON.parse(STDIN.read);puts JSON.generate(x['irs'].map{|ir|f=EraZeroRenderer.render(ir,foundation_records:x['records'],allow_draft_foundations:true);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,foundation_records:x['records'],allow_draft_foundations:true))}})"],{cwd:new URL('..',import.meta.url),input:JSON.stringify({irs:results.map(r=>r.semantic_ir),records}),encoding:'utf8',maxBuffer:15_000_000}));
results.forEach((r,i)=>{assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi)});
const bad=structuredClone(results[0].semantic_ir);bad.nodes.find(n=>n.node_id==='p').target_id=records[2].foundation_id;await assert.rejects(()=>validateFoundationIR(bad,records,{allowDraft:true}));
console.log('PASS 15 desired-knowledge sentences: reuse desire and knowledge, controlled/explicit holders, nested negation, questions and runtime; independent MIDI meanings and full Ruby formal/audio parity.');
