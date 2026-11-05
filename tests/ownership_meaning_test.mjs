import assert from 'node:assert/strict';
import {canonicalDigest} from '../pages/engine.mjs';
import {contextualContentReference} from '../pages/contextual_content.mjs';
import {createOwnershipMeaning,validateOwnershipMeaning} from '../pages/ownership_meaning.mjs';
const [nora,eli,tea,first,second]=await Promise.all(['Nora','Eli','this tea','"Harbor charter"','"Island charter"'].map(contextualContentReference)),ids=new Set();
for(const framework of [first,second])for(const owner of [nora,eli])for(const runtimeState of [0,1,2])for(const speechAct of ['assertion','question'])for(const negative of [false,true]){
 const scopes=[{operator:'time',relation:'before_speech'},...(negative?[{operator:'negation'}]:[])],d=await createOwnershipMeaning(owner,tea,framework,{allowDraft:true,speechAct,scopes,runtimeState});
 assert.deepEqual(await validateOwnershipMeaning(d,{allowDraft:true}),d);assert.deepEqual(d.owner,owner);assert.deepEqual(d.framework,framework);assert.deepEqual(d.object,tea);assert.equal(d.physical_custody,'not_entailed');assert.equal(d.unlimited_use_or_disposal,'not_entailed');assert.equal(d.other_framework_status,'not_asserted');ids.add(d.content_id);
}
assert.equal(ids.size,48);
await assert.rejects(createOwnershipMeaning(nora,tea,first),/draft opt-in/);
await assert.rejects(createOwnershipMeaning(nora,tea,undefined,{allowDraft:true}),/framework explicitly/);
await assert.rejects(createOwnershipMeaning(nora,tea,await contextualContentReference('I'),{allowDraft:true}),/framework explicitly/);
const valid=await createOwnershipMeaning(nora,tea,first,{allowDraft:true});
for(const [key,value] of [['physical_custody','entailed'],['unlimited_use_or_disposal','entailed'],['framework_scope','outside_negation'],['runtime_state',3],['exclusive_ownership','entailed'],['extra_hidden_right','transfer']]){
 const bad=structuredClone(valid);bad[key]=value;delete bad.content_id;delete bad.content_digest;const hash=await canonicalDigest(bad);bad.content_digest=hash;bad.content_id=`EZOWN:${hash.slice(0,24)}`;await assert.rejects(validateOwnershipMeaning(bad,{allowDraft:true}));
}
const tampered=structuredClone(valid);tampered.owner=eli;await assert.rejects(validateOwnershipMeaning(tampered,{allowDraft:true}),/identity mismatch/);
console.log('PASS 48 draft ownership meanings distinguish owner/framework/scope/runtime; absent framework, forged commitments and stale participant identity reject. No musical or English coverage claimed.');
