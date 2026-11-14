import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const template=JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files['MOV:111'],root))).variants['assertion:1'];
const cases=['Eli is moving from the archive to the gate.','Eli is moving from the gate to the archive.','Eli is not moving from the archive to the gate.','I am moving from the archive toward the gate [2].','Was Eli moving from the archive to the gate yesterday?'];
const results=[];
for(const input of cases){
 const parsed=parseNamedSentence(input);assert.equal(parsed?.predicate,'MOV:111',input);
 const result=await composeNamedSentence(input,template),ir=result.semantic_ir;
 assert.deepEqual(ir.edges.filter(e=>e.type==='fills_role').map(e=>e.role),['actor','source','destination']);
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_presentation','-rbase64','-e','f=EraZeroRenderer.render(JSON.parse(STDIN.read));puts JSON.generate({formal:f,midi:Base64.strict_encode64(EraZeroPresentation.midi(f))})'],{cwd:root,input:JSON.stringify(ir),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby.formal);assert.deepEqual(Buffer.from(midiFromFormal(result.formal)),Buffer.from(ruby.midi,'base64'));
 assert.equal(result.formal.performance.lexical_events.find(e=>e.occurrence_id==='b').register,'low');
 assert.equal(result.formal.performance.lexical_events.find(e=>e.occurrence_id==='d2').register,'high');
 assert.equal(ir.nodes.find(n=>n.kind==='lexical_occurrence').runtime_state.code,input.includes('[2]')?2:1);
 results.push(result);
}
assert.notDeepEqual(midiFromFormal(results[0].formal),midiFromFormal(results[1].formal));
assert.notDeepEqual(midiFromFormal(results[0].formal),midiFromFormal(results[2].formal));
assert.equal(results[4].semantic_ir.speech_act,'question');
assert.equal(results[4].semantic_ir.nodes.find(n=>n.kind==='time_anchor').day_offset,'-1');
for(const input of ['Eli is moving from the archive to the archive.','Eli is moving from the archive to the gate quickly.','Eli arrived from the archive to the gate.'])assert.equal(parseNamedSentence(input),null,input);
console.log('Movement paths retain mover, source and destination; reversal changes music, with negation, num and past-question scope preserved.');
