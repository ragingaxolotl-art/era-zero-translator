import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {parseNamedSentence,composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const root=new URL('..',import.meta.url),index=JSON.parse(fs.readFileSync(new URL('pages/data/index.json',root)));
const forms=[['Repair the radio','!','command','REP:111'],['Do not physically repair the radio','!','command','CMP:2816a7eeb356c2148b26beca'],['Did Nora restore Eli','?','question','REP:110'],['Is Nora restoring Eli','?','question','REP:111']];
for(const [content,punctuation,act,target] of forms){
 const sounds=[];
 for(const state of [0,1,2]){
  const input=`${content} [${state}]${punctuation}`;
  const parsed=parseNamedSentence(input);assert.ok(parsed,input);assert.equal(parsed.predicate,target);assert.equal(parsed.runtimeState,state);assert.equal(parsed.speechAct,act);
  assert.deepEqual(parseNamedSentence(`${content}${punctuation} [${state}]`),parsed);
  const template=JSON.parse(fs.readFileSync(new URL('pages/'+index.resolution_files[target],root))).variants['assertion:1'];
  const result=await composeNamedSentence(input,template);
  const ruby=JSON.parse(execFileSync('ruby',['-Itools/lib','-rera_zero_renderer','-e','puts JSON.generate(EraZeroRenderer.render(JSON.parse(STDIN.read)))'],{cwd:root,input:JSON.stringify(result.semantic_ir),encoding:'utf8'}));
  assert.deepEqual(result.formal,ruby);
  const predicateEvents=result.formal.performance.lexical_events.filter(e=>e.occurrence_id==='p');
  assert.equal(predicateEvents.filter(e=>e.runtime_tail).length,1);
  assert.equal(predicateEvents.at(-1).runtime_tail.code,state);
  assert.equal(result.semantic_ir.speech_act,act);
  assert.equal(result.formal.performance.primary_contour,act==='command'?'sharply_falling':'rising');
  sounds.push(Buffer.from(midiFromFormal(result.formal)).toString('base64'));
 }
 assert.equal(new Set(sounds).size,3);
}
for(const input of ['Repair the radio [0] [1]!','Did Nora restore Eli? [2]!','It is possible that repair the radio [2].','Repair the radio [3]!'])assert.equal(parseNamedSentence(input),null,input);
console.log('Questions and commands retain all three runtime states, independent contours, and exactly one compound-head ending.');
