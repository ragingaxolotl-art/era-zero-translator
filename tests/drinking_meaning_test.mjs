import assert from 'node:assert/strict';
import {createDrinkingMeaning,validateDrinkingMeaning} from '../pages/drinking_meaning.mjs';
import {createMaterialReference} from '../pages/material_reference.mjs';
import {contextualContentReference} from '../pages/contextual_content.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const drinker=await contextualContentReference('Nora'),material=await createMaterialReference('this tea',{allowDraft:true,reading:'contextual_portion'}),ids=new Set();
for(const viewpoint of ['ongoing','bounded','habitual'])for(const speechAct of ['assertion','question'])for(const negated of [false,true])for(const runtimeState of [0,1,2]){
 const d=await createDrinkingMeaning(drinker,material,{allowDraft:true,viewpoint,speechAct,scopes:negated?[{operator:'negation'}]:[],runtimeState});ids.add(d.content_id);assert.equal(d.runtime_state,runtimeState);assert.equal(d.material.reference.reference_mode,'proximal_nominal');assert.equal(d.whole_amount_consumption,'not_asserted');assert.equal(d.thirst_commitment,'not_entailed');
}
assert.equal(ids.size,36);
const original=await createDrinkingMeaning(drinker,material,{allowDraft:true,viewpoint:'ongoing'});
for(const key of ['action_category','participant_binding','thirst_commitment','whole_amount_consumption','viewpoint_contract']){
 const {content_id,content_digest,...body}=original;body[key]='changed';const hash=await canonicalDigest(body);await assert.rejects(validateDrinkingMeaning({...body,content_digest:hash,content_id:`EZDRINK:${hash.slice(0,24)}`},{allowDraft:true}));
}
await assert.rejects(createDrinkingMeaning(drinker,material,{allowDraft:true}),/Choose/);
await assert.rejects(createDrinkingMeaning(drinker,material,{viewpoint:'ongoing'}));
const other=await createDrinkingMeaning(await contextualContentReference('Eli'),material,{allowDraft:true,viewpoint:'ongoing'});assert.notEqual(other.content_id,original.content_id);
console.log('PASS 36 draft drinking viewpoint/scope/runtime meanings, participant contrast and rehashed contract rejection. No English or music completeness claim.');
