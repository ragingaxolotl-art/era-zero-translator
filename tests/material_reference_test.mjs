import assert from 'node:assert/strict';
import {createMaterialReference,validateMaterialReference} from '../pages/material_reference.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const ids=new Set();
for(const noun of ['tea','water'])for(const [prefix,reading] of [['','kind'],['the ','contextual_portion'],['this ','contextual_portion'],['that ','contextual_portion']]){
 const d=await createMaterialReference(prefix+noun,{allowDraft:true,reading});await validateMaterialReference(d,{allowDraft:true});ids.add(d.content_id);
 assert.equal(d.reference.name.normalized_label,noun);assert.equal(d.quantity,'unspecified');assert.equal(d.whole_amount_consumption,'not_asserted');assert.equal(d.existence_commitment,'governed_by_enclosing_content');assert.equal(d.reference.value_type,reading==='kind'?'kind':'entity');
 for(const key of ['quantity','whole_amount_consumption','material_kind_commitment','existence_commitment']){
  const {content_id,content_digest,...body}=d;body[key]='invented';const hash=await canonicalDigest(body);await assert.rejects(validateMaterialReference({...body,content_digest:hash,content_id:`EZMATREF:${hash.slice(0,24)}`},{allowDraft:true}));
 }
}
assert.equal(ids.size,8);
for(const [text,reading] of [['tea',undefined],['tea','contextual_portion'],['the tea','kind'],['this tea','kind'],['two cups','contextual_portion'],['the hot tea','contextual_portion'],['it','kind']])await assert.rejects(createMaterialReference(text,{allowDraft:true,reading}));
await assert.rejects(createMaterialReference('tea',{reading:'kind'}));
console.log('PASS eight draft material references preserve kind/portion and deixis without amount, liquid or existence inference; malformed/implicit readings reject. No music or drinking claim.');
