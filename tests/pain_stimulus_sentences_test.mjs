import assert from 'node:assert/strict';
import {composePainStimulusSentence,painStimulusPlan} from '../pages/pain_stimulus_sentences.mjs';
const forms=[['actual_causation','The treatment caused bodily pain for Nora.','The treatment did not cause bodily pain for Nora.','Did the treatment cause bodily pain for Nora?'],['expected_outcome','The treatment is expected to cause bodily pain for Nora.','The treatment is not expected to cause bodily pain for Nora.','Is the treatment expected to cause bodily pain for Nora?'],['disposition','The treatment tends to cause bodily pain for Nora.','The treatment does not tend to cause bodily pain for Nora.','Does the treatment tend to cause bodily pain for Nora?']];
const ids=new Set();
for(const [relation,...texts] of forms)for(const [i,text] of texts.entries())for(const runtime of [0,1,2]){
 const d=await composePainStimulusSentence(`${text} [${runtime}]`,{allowDraft:true});assert.equal(d.relation,relation);assert.equal(d.runtime_state,runtime);assert.equal(d.outcome.runtime_state,1);assert.equal(d.speech_act,i===2?'question':'assertion');assert.equal(d.scopes.some(s=>s.operator==='negation'),i===1);assert.equal(d.scopes.some(s=>s.operator==='time'),relation==='actual_causation');assert.equal(d.stimulus.name.normalized_label,'treatment');assert.equal(d.outcome.experiencer.name.normalized_label,'nora');ids.add(d.content_id);
}
assert.equal(ids.size,27);
assert.deepEqual(await composePainStimulusSentence('It caused bodily pain for them.',{allowDraft:true,bindings:{ref0:'the treatment',ref1:{referent:'Nora',number:'singular'}}}),await composePainStimulusSentence('The treatment caused bodily pain for Nora.',{allowDraft:true}));
for(const text of ['The treatment is painful.','The treatment caused Nora.','The treatment is expected not to cause bodily pain for Nora.','The treatment causes bodily pain for Nora.','I is expected to cause bodily pain for Nora.'])assert.equal(painStimulusPlan(text),null);
console.log('PASS 27 explicit causal/expected/dispositional sentence meanings plus neutral reference binding; ambiguous painful and inner negation are not silently reinterpreted.');
