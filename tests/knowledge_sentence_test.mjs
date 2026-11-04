import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseFoundationSentence as parse,composeFoundationSentence as compose} from '../pages/foundation_sentences.mjs';
import {validateFoundationIR} from '../pages/foundation_ir.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url))),authority=read('pages/data/index.json');
const records=[...read('reviews/foundation_extension_candidates.json').records,...read('reviews/cognitive_foundation_candidates.json').records];
const load=id=>({...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority});
const results=[];
for(const outer of [0,1,2])for(const inner of [0,1,2])for(const negative of [false,true]){
 const input=`Nora ${negative?'does not know':'knows'} whether Eli is not conscious [${inner}] [${outer}].`;
 assert.equal(parse(input),null);const r=await compose(input,authority,records,load,{allowDraft:true,allowCognitive:true});
 await validateFoundationIR(r.semantic_ir,records,{allowDraft:true});
 const ir=r.semantic_ir;assert.equal(ir.nodes.find(n=>n.node_id==='p').runtime_state.code,outer);assert.equal(ir.nodes.find(n=>n.target_id==='LIF:011').runtime_state.code,inner);
 const question=ir.nodes.find(n=>n.value_type==='question');assert.equal(question.question_kind,'polar');assert.equal(ir.nodes.filter(n=>n.operator==='negation').length,negative?2:1);
 assert.equal(ir.edges.find(e=>e.type==='centers'&&e.to===ir.root_clause).from,negative?'neg':'p');results.push(r);
}
for(const input of ["Does Nora know whether Eli is conscious?","Doesn't Nora know whether Eli is conscious?","Nora doesn't know whether Eli is conscious."]){const r=await compose(input,authority,records,load,{allowDraft:true,allowCognitive:true});assert.equal(r.semantic_ir.speech_act,input.endsWith('?')?'question':'assertion');results.push(r);}
const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e',"x=JSON.parse(STDIN.read);puts JSON.generate(x['irs'].map{|ir|f=EraZeroRenderer.render(ir,foundation_records:x['records'],allow_draft_foundations:true);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f,foundation_records:x['records'],allow_draft_foundations:true))}})"],{cwd:new URL('..',import.meta.url),input:JSON.stringify({irs:results.map(r=>r.semantic_ir),records}),encoding:'utf8',maxBuffer:15_000_000}));
results.forEach((r,i)=>{assert.deepEqual(r.formal,ruby[i].formal);assert.equal(Buffer.from(midiFromFormal(r.formal)).toString('base64'),ruby[i].midi)});
for(const input of ['Nora knows Eli.','Nora knows that Eli is conscious.','Nora learned whether Eli is conscious.','Nora knows whether the map.'])await assert.rejects(()=>compose(input,authority,records,load,{allowDraft:true,allowCognitive:true}));
await assert.rejects(()=>compose('Nora knows whether Eli is conscious.',authority,records,load,{allowCognitive:true}));
console.log(`PASS ${results.length} knows/whether compositions with independent inner/outer runtime, negation, questions and contractions; complete browser/Ruby formal and MIDI parity. Opt-in API only; semantic inverse/UI pending.`);
