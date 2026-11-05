import assert from 'node:assert/strict';
import {composePainPreference,validatePainPreference} from '../pages/pain_preference.mjs';
import {canonicalDigest} from '../pages/engine.mjs';
const options={allowDraft:true,experiencer:'Eli',interpretation:'expected_outcome',context:'this session',comparisonTarget:'other_alternative'},ids=new Set();
for(const reverse of [false,true])for(const form of ['assertion','negation','question'])for(const state of [0,1,2]){
 const a=reverse?'more painful':'painful',b=reverse?'painful':'more painful',input=(form==='question'?`Does Nora prefer the ${a} treatment to the ${b} treatment?`:`Nora ${form==='negation'?'does not prefer':'prefers'} the ${a} treatment to the ${b} treatment.`)+` [${state}]`;
 const d=await composePainPreference(input,options);ids.add(d.content_id);assert.equal(d.holder.name.normalized_label,'nora');assert.equal(d.pain_comparison.left.outcome.experiencer.name.normalized_label,'eli');assert.equal(d.more_painful_role,reverse?'target':'comparison_standard');assert.equal(d.runtime_state,state);assert.notEqual(d.target.name.name_id,d.comparison_standard.name.name_id);assert.deepEqual(d.target.name.phonemes,d.comparison_standard.name.phonemes);assert.equal(d.pain_comparison.scopes.length,0);assert.equal(d.scopes.some(s=>s.operator==='negation'),form==='negation');
 const {content_id,content_digest,...body}=d;body.more_painful_role=reverse?'comparison_standard':'target';const hash=await canonicalDigest(body);await assert.rejects(validatePainPreference({...body,content_digest:hash,content_id:`EZPAINPREF:${hash.slice(0,24)}`},{allowDraft:true}));
}
assert.equal(ids.size,18);
const original='Nora prefers the painful treatment to the more painful treatment.';
await assert.rejects(composePainPreference(original,{...options,comparisonTarget:undefined}),/Confirm/);await assert.rejects(composePainPreference(original,{...options,experiencer:undefined}),/experiencer/);
console.log('PASS 18 modified pain-preference meaning contrasts, original sentence with explicit missing-context choices, and rehashed argument-binding rejection. No music claim.');
// A fully rehashed document must not collapse the two descriptive alternatives.
const valid=await composePainPreference(original,options),collapsed=structuredClone(valid);
collapsed.comparison_standard=structuredClone(collapsed.target);
collapsed.pain_comparison.left.stimulus=structuredClone(collapsed.target);
for(const [object,prefix] of [[collapsed.pain_comparison.left,'EZPAINSTIM'],[collapsed.pain_comparison,'EZPAINCMP'],[collapsed,'EZPAINPREF']]){
 const {content_id,content_digest,...body}=object,hash=await canonicalDigest(body);object.content_digest=hash;object.content_id=`${prefix}:${hash.slice(0,24)}`;
}
await assert.rejects(validatePainPreference(collapsed,{allowDraft:true}),/distinct reference/);
const {execFileSync}=await import('node:child_process');
assert.equal(execFileSync('ruby',['-Itools/lib','-rera_zero_pain_preference','-rjson','-e',"begin;EraZeroPainPreference.validate!(JSON.parse(STDIN.read),allow_draft:true);puts 'accepted';rescue ArgumentError;puts 'rejected';end"],{input:JSON.stringify(collapsed),encoding:'utf8'}).trim(),'rejected');
console.log('PASS both validators reject fully rehashed collapsed treatment identities.');
