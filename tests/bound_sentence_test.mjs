import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence,composeSentenceConjunction,composeSentenceSequence,composeSentenceConditional} from '../pages/sentences.mjs';
import {renderLexicalOccurrences} from '../pages/bound_compounds.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const root=new URL('..',import.meta.url),authority=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const template={authority},results=[];
for(const state of [0,1,2])for(const text of ['Ada has a directed data link to Ben','I have a directed data link to you','The sensor has a directed data link to the bell','Ada does not have a directed data link to Ben','It is possible that Ada has a directed data link to Ben','It is not necessary that Ada has a directed data link to Ben']){
 const result=await composeNamedSentence(`${text} [${state}].`,template);
 const p=result.semantic_ir.nodes.find(n=>n.node_id==='p');
 assert.deepEqual(p.compound_bindings,[{slot_path:['a-source-01'],argument_id:'a'},{slot_path:['a-target-01'],argument_id:'b'}]);
 assert.deepEqual(result.formal.performance.lexical_events.filter(e=>e.runtime_tail).map(e=>e.runtime_tail.code),[state]);
 results.push(result);
}
for(const [compose,text] of [[composeSentenceConjunction,'Ada has a directed data link to Ben and Ben has a directed data link to Ada.'],[composeSentenceSequence,'Ada has a directed data link to Ben, then Ben has a directed data link to Ada.'],[composeSentenceConditional,'If Ada has a directed data link to Ben, then Ben has a directed data link to Ada.']])results.push(await compose(text,async()=>template));
const expected=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-rera_zero_presentation','-rbase64','-e','puts JSON.generate(JSON.parse(STDIN.read).map{|ir|f=EraZeroRenderer.render(ir);{formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))}})'],{cwd:root,input:JSON.stringify(results.map(r=>r.semantic_ir)),encoding:'utf8',maxBuffer:10_000_000}));
for(const [i,result] of results.entries()){
 assert.deepEqual(result.formal,expected[i].formal,result.source_input);
 assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(expected[i].midi,'base64'));
}
for(const text of ['Exactly two sensors have a directed data link to the bell.','Ada has a directed data link to Ada.'])assert.equal(parseNamedSentence(text),null);
const ir=results[0].semantic_ir;
for(const mutate of [x=>x.nodes.find(n=>n.node_id==='p').compound_bindings.pop(),x=>x.nodes.find(n=>n.node_id==='p').compound_bindings[0].slot_path=['missing'],x=>x.nodes.find(n=>n.node_id==='a').value_type='event',x=>x.nodes.find(n=>n.node_id==='a').name.events.pop(),x=>{const p=x.nodes.find(n=>n.node_id==='p');p.value_type='entity';p.compound_bindings[0].argument_id='p'},x=>x.nodes.find(n=>n.node_id==='p').compound_bindings[0].role='experiencer']){
 const bad=structuredClone(ir);mutate(bad);await assert.rejects(()=>renderLexicalOccurrences(bad,authority));
}
await assert.rejects(()=>renderLexicalOccurrences(ir,authority,{maxEvents:1}),/limit/);
const corrupt=structuredClone(authority);corrupt.compound_plans[results[0].target_id].bound_components.reverse();
await assert.rejects(()=>renderLexicalOccurrences(ir,corrupt),/digest/);
console.log(`Bound sentences: ${results.length} name/deictic/nominal/state/scope/clause cases match reference formal and MIDI; invalid bindings, references, plans and event limits are rejected.`);
