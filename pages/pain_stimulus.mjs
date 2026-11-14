// Draft relation prerequisite; no musical or English route is claimed here.
import {canonicalDigest} from './engine.mjs';
import {validatePainMeaning} from './pain_meaning.mjs';
import {createContextualContent} from './contextual_content.mjs';
export const PAIN_RELATIONS=Object.freeze({
 actual_causation:'The stimulus causally contributes to the specified pain experience; causal contribution is not mere correlation or temporal order and need not be the sole cause.',
 expected_outcome:'In the selected local context, occurrence or application of the stimulus is expected to produce the specified pain experience; neither occurrence nor pain is asserted as actual.',
 disposition:'The stimulus has a contextually qualified tendency to produce the specified pain experience when encountered or applied; no particular occurrence, inevitability or present pain is asserted.'
});
const scopes=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
export async function validatePainStimulus(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Pain stimulus requires draft opt-in.');
 const d=structuredClone(document),keys=['profile','status','relation','criterion','stimulus','outcome','speech_act','scopes','runtime_state','outcome_scope','content_digest','content_id'];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZPAIN-STIMULUS-1'||d.status!=='draft'||!Object.hasOwn(PAIN_RELATIONS,d.relation)||d.criterion!==PAIN_RELATIONS[d.relation]||d.outcome_scope!=='governed_by_relation_and_matrix_scope'||![0,1,2].includes(d.runtime_state)||!['assertion','question'].includes(d.speech_act)||!scopes.some(s=>JSON.stringify(s)===JSON.stringify(d.scopes)))throw new Error('Invalid pain stimulus contract.');
 await createContextualContent('topic',d.stimulus,{allowDraft:true});await validatePainMeaning(d.outcome,{allowDraft:true});
 if(d.outcome.speech_act!=='assertion'||d.outcome.scopes.length)throw new Error('Pain outcome must be positive untimed content, not an independently scoped utterance.');
 const {content_digest,content_id,...body}=d,hash=await canonicalDigest(body);
 if(content_digest!==hash||content_id!==`EZPAINSTIM:${hash.slice(0,24)}`)throw new Error('Pain stimulus identity mismatch.');return d;
}
export async function createPainStimulus(stimulus,outcome,{allowDraft=false,relation,speechAct='assertion',scopes:outerScopes=[],runtimeState=1}={}){
 if(!allowDraft)throw new Error('Pain stimulus requires draft opt-in.');
 if(!Object.hasOwn(PAIN_RELATIONS,relation))throw new Error('Choose actual causation, expected outcome or disposition explicitly.');
 const body={profile:'EZPAIN-STIMULUS-1',status:'draft',relation,criterion:PAIN_RELATIONS[relation],stimulus:structuredClone(stimulus),outcome:structuredClone(outcome),speech_act:speechAct,scopes:structuredClone(outerScopes),runtime_state:runtimeState,outcome_scope:'governed_by_relation_and_matrix_scope'},hash=await canonicalDigest(body);
 return validatePainStimulus({...body,content_digest:hash,content_id:`EZPAINSTIM:${hash.slice(0,24)}`},{allowDraft:true});
}
