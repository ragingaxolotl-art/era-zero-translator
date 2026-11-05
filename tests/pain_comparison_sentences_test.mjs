import assert from 'node:assert/strict';
import {composePainComparisonSentence,painComparisonPlan} from '../pages/pain_comparison_sentences.mjs';
const ids=new Set(),options={allowDraft:true,interpretation:'expected_outcome',context:'this session'};
for(const [word,relation,connector] of [['more','greater_than','than'],['less','less_than','than'],['equally','equal','as']])for(const past of [false,true])for(const negative of [false,true])for(const question of [false,true])for(const runtime of [0,1,2]){
 const predicate=`${negative?'not ':''}${word} painful for Nora ${connector} "Treatment B"`,text=(question?`${past?'Was':'Is'} "Treatment A" ${predicate}?`:`"Treatment A" ${past?'was':'is'} ${predicate}.`)+` [${runtime}]`;
 const d=await composePainComparisonSentence(text,options);ids.add(d.content_id);assert.equal(d.relation,relation);assert.equal(d.runtime_state,runtime);assert.equal(d.left.relation,'expected_outcome');assert.equal(d.left.outcome.experiencer.name.normalized_label,'nora');assert.equal(d.context.name.normalized_label,'session');assert.equal(d.scopes.some(s=>s.operator==='time'),past);assert.equal(d.scopes.some(s=>s.operator==='negation'),negative);assert.equal(d.speech_act,question?'question':'assertion');
}
assert.equal(ids.size,72);
const text='The treatment is more painful for Nora than the injection.';
await assert.rejects(composePainComparisonSentence(text,{allowDraft:true}),/Choose/);
await assert.rejects(composePainComparisonSentence(text,{allowDraft:true,interpretation:'actual_causation'}),/context/);
assert.deepEqual(await composePainComparisonSentence('It is more painful for them than the injection.',{...options,bindings:{ref0:'the treatment',ref1:{referent:'Nora',number:'singular'}}}),await composePainComparisonSentence(text,options));
for(const t of ['The treatment is more painful than the injection.','The treatment is more painful for Nora as the injection.','The treatment is equally painful for Nora than the injection.'])assert.equal(painComparisonPlan(t),null);
console.log('PASS 72 explicit pain comparison meanings preserve intensity direction, past/negation/question/runtime; reading and context are required, with neutral bindings.');
