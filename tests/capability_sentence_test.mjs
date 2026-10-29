import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {scheduledLexicalEvents} from '../pages/scheduler.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const template=JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files['REP:211'],root))).variants['assertion:1'];
const results=[];
for(const input of ['Nora can repair the radio [0].','Nora can repair the radio [1].','Nora can repair the radio [2].','Nora cannot repair the radio.','Nora is able to restore Eli.']){
 const parsed=parseNamedSentence(input);assert.equal(parsed.predicate,'REP:211');
 const result=await composeNamedSentence(input,template);
 const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-e','puts JSON.generate(EraZeroRenderer.render(JSON.parse(STDIN.read)))'],{cwd:root,input:JSON.stringify(result.semantic_ir),encoding:'utf8'}));
 assert.deepEqual(result.formal,ruby);results.push(result);
}
for(const state of [0,1,2]){
 const result=results[state],predicate=result.semantic_ir.nodes.find(n=>n.kind==='lexical_occurrence');
 assert.equal(predicate.target_id,'REP:211');assert.equal(predicate.runtime_state.code,state);
 assert.equal(result.semantic_ir.nodes.some(n=>n.operator==='negation'),false);
 const event=result.formal.performance.lexical_events.find(e=>e.occurrence_id==='p');
 assert.deepEqual(event.address_relative_semitones,template.formal.performance.lexical_events[0].address_relative_semitones);
 assert.equal(event.runtime_tail.code,state);
}
assert.equal(new Set(results.slice(0,3).map(r=>Buffer.from(midiFromFormal(r.formal)).toString('base64'))).size,3);
assert.equal(results[3].semantic_ir.nodes.find(n=>n.kind==='lexical_occurrence').runtime_state.code,1);
assert(scheduledLexicalEvents(results[3].formal).some(e=>e.marker==='negation_open'));
assert.notDeepEqual(midiFromFormal(results[0].formal),midiFromFormal(results[3].formal));
assert.doesNotMatch(results[2].semantic_note,/never-finished-becoming/);
assert.match(results[4].semantic_note,/does not assert permission/);
assert.equal(parseNamedSentence('Nora can repair the radio [3].'),null);
console.log('Capability statements preserve REP:211 and all three runtime endings; inactive and negated-active remain musically distinct.');
