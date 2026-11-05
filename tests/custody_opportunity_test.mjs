import assert from 'node:assert/strict';
import {canonicalDigest} from '../pages/engine.mjs';
import {contextualContentReference} from '../pages/contextual_content.mjs';
import {createCustodyOpportunity,validateCustodyOpportunity} from '../pages/custody_opportunity.mjs';
const [nora,eli,tea,first,second]=await Promise.all(['Nora','Eli','this tea','"Pantry access"','"Market access"'].map(contextualContentReference)),ids=new Set();
for(const holder of [nora,eli])for(const context of [first,second])for(const runtimeState of [0,1,2])for(const speechAct of ['assertion','question'])for(const negative of [false,true]){
 const d=await createCustodyOpportunity(holder,tea,context,{allowDraft:true,runtimeState,speechAct,scopes:negative?[{operator:'negation'}]:[]});assert.deepEqual(await validateCustodyOpportunity(d,{allowDraft:true}),d);assert.deepEqual(d.prospective_holder,holder);assert.deepEqual(d.access_context,context);assert.equal(d.activity_status,'possible_not_asserted');assert.equal(d.current_custody,'not_entailed');assert.equal(d.normative_permission,'not_entailed');assert.equal(d.activity_time,'prospective_relative_to_opportunity');ids.add(d.content_id);
}
assert.equal(ids.size,48);
await assert.rejects(createCustodyOpportunity(nora,tea,first),/draft/);
await assert.rejects(createCustodyOpportunity(nora,tea,undefined,{allowDraft:true}),/context explicitly/);
await assert.rejects(createCustodyOpportunity(nora,nora,first,{allowDraft:true}),/distinct/);
const base=await createCustodyOpportunity(nora,tea,first,{allowDraft:true});
for(const [key,value] of [['normative_permission','entailed'],['actual_acquisition','entailed'],['activity_status','asserted'],['activity_time','before_speech'],['activity_compound','wrong'],['custody_at_culmination_if_realized',false],['runtime_state',3]]){
 const d=structuredClone(base);d[key]=value;delete d.content_id;delete d.content_digest;const hash=await canonicalDigest(d);d.content_digest=hash;d.content_id=`EZCUSTOP:${hash.slice(0,24)}`;await assert.rejects(validateCustodyOpportunity(d,{allowDraft:true}));
}
console.log('PASS 48 draft opportunity cases keep holder/resource/context, possibility, scope and runtime distinct; forged realization, permission, event dependency and past-time commitments reject. No music or English availability coverage claimed.');
