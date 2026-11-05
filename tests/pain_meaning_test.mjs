import assert from 'node:assert/strict';
import {composePainMeaning,validatePainMeaning,painMeaningPlan} from '../pages/pain_meaning.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const ids=new Set();
for(const runtime of [0,1,2])for(const past of [false,true])for(const neg of [false,true])for(const question of [false,true]){
 const copula=past?'was':'is',phrase=question?`${past?'Was':'Is'} Nora ${neg?'not ':''}in bodily pain?`:`Nora ${copula} ${neg?'not ':''}in bodily pain.`;
 const d=await composePainMeaning(`${phrase} [${runtime}]`,{allowDraft:true});
 assert.equal(d.runtime_state,runtime);assert.equal(d.speech_act,question?'question':'assertion');assert.equal(d.scopes.some(s=>s.operator==='negation'),neg);assert.equal(d.scopes.some(s=>s.operator==='time'),past);ids.add(d.content_id);
 for(const field of ['injury_commitment','cause_commitment','dependency']){
  const {content_digest,content_id,...body}=d;body[field]='invented';const digest=await canonicalDigest(body);
  await assert.rejects(validatePainMeaning({...body,content_digest:digest,content_id:`EZPAIN:${digest.slice(0,24)}`},{allowDraft:true}));
 }
}
assert.equal(ids.size,24);
const named=await composePainMeaning('Nora is in bodily pain.',{allowDraft:true});
assert.deepEqual(await composePainMeaning('They are in bodily pain.',{allowDraft:true,bindings:{ref0:{referent:'Nora',number:'singular'}}}),named);
for(const text of ['Nora is painful.','The treatment is painful.','Nora is in pain.','Nora is in more bodily pain.','I is in bodily pain.'])assert.equal(painMeaningPlan(text),null);
await assert.rejects(composePainMeaning('Nora is in bodily pain.'));
console.log('PASS 24 draft pain meaning contrasts, singular they binding, explicit reading boundaries and rehashed semantic-corruption rejection. No music implementation claimed.');
