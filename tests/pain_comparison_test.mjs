import assert from 'node:assert/strict';
import {composePainMeaning} from '../pages/pain_meaning.mjs';
import {createPainStimulus} from '../pages/pain_stimulus.mjs';
import {contextualContentReference} from '../pages/contextual_content.mjs';
import {createPainComparison,validatePainComparison} from '../pages/pain_comparison.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const pain=await composePainMeaning('Nora is in bodily pain. [2]',{allowDraft:true}),a=await contextualContentReference('"Treatment A"'),b=await contextualContentReference('"Treatment B"'),context=await contextualContentReference('this session'),ids=new Set();
let left,right;
for(const mode of ['actual_causation','expected_outcome','disposition']){
 left=await createPainStimulus(a,pain,{allowDraft:true,relation:mode,runtimeState:0});right=await createPainStimulus(b,pain,{allowDraft:true,relation:mode,runtimeState:2});
 for(const relation of ['greater_than','less_than','equal'])for(const runtimeState of [0,1,2])for(const speechAct of ['assertion','question'])for(const negative of [false,true]){
  const d=await createPainComparison(left,right,context,{allowDraft:true,relation,runtimeState,speechAct,scopes:negative?[{operator:'negation'}]:[]});ids.add(d.content_id);
  assert.equal(d.left.runtime_state,0);assert.equal(d.right.runtime_state,2);assert.equal(d.left.outcome.runtime_state,2);assert.equal(d.scale,'ordinal_no_numeric_score');assert.equal(d.runtime_state,runtimeState);assert.equal(d.left.relation,mode);
 }
}
assert.equal(ids.size,108);
const options={allowDraft:true,relation:'greater_than'},d=await createPainComparison(left,right,context,options);
assert.notEqual(d.content_id,(await createPainComparison(right,left,context,options)).content_id);
const other=await createPainStimulus(b,await composePainMeaning('Eli is in bodily pain.',{allowDraft:true}),{allowDraft:true,relation:'disposition'});
await assert.rejects(createPainComparison(left,other,context,options),/Cross-experiencer/);
await assert.rejects(createPainComparison(left,right,context,{...options,relation:'more_runtime'}));
const {content_digest,content_id,...body}=d;body.scale='numeric_0_1_2';const hash=await canonicalDigest(body);await assert.rejects(validatePainComparison({...body,content_digest:hash,content_id:`EZPAINCMP:${hash.slice(0,24)}`},{allowDraft:true}));
// Ordinal countermodels: negating greater-than permits equality; reversal is not negation.
const greater=(a,b)=>a>b;assert(!greater(4,4));assert(!greater(4,4)&&!(4<4));assert(greater(7,4)&&!greater(4,7));
console.log('PASS 108 draft comparison documents preserve relation mode, scope and independent runtimes; reject cross-person scales and runtime-as-intensity. No music claim.');
