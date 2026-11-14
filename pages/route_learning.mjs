// Draft route-learning meanings; result contracts precede musical admission.
import {canonicalDigest} from './engine.mjs';
import {contextualContentReference,createContextualContent} from './contextual_content.mjs';
import {validAcquisitionScopes} from './acquisition_scopes.mjs';
import {evaluateKnowledgeAcquisition} from './knowledge_acquisition.mjs';
import {personalPronounPlan,resolvePersonalPronouns} from './personal_pronoun_plan.mjs';
import {validReferent} from './pronouns.mjs';
export const ROUTE_LEARNING_READINGS=Object.freeze({
 memorization:Object.freeze({predicate:'route_information_recall',definition:'The experiencer retains contextually selected information representing the route and can recall that information to the contextual memory criterion. Recall need not be occurring now. The represented information need not be true or sufficient for navigation.',excludes:Object.freeze(['Truth of the memorized information','Practical navigation knowledge','Current attention or recall','Actual route traversal or permanent retention'])}),
 navigation:Object.freeze({predicate:'practical_route_knowledge',definition:'The experiencer knows how to follow the contextually identified route to the contextual practical-navigation criterion. This is usable procedural knowledge, not merely reciting route information. It does not assert present physical ability, actual traversal, complete mastery of every circumstance or permanent retention.',excludes:Object.freeze(['Physical mobility or actual travel','Verbatim recall of route instructions','Success under every circumstance','Permanent retention'])}),
 familiarity:Object.freeze({predicate:'route_familiarity',definition:'The experiencer has contextually adequate cognitive acquaintance with the identified route through direct or mediated exposure, so it is familiar rather than wholly unfamiliar. This does not by itself establish recall of route instructions, practical navigation knowledge, or actual traversal.',excludes:Object.freeze(['Practical navigation knowledge','Recall of complete instructions','Actual route traversal','Permanent retention'])})
});
const REF='(?:I|[Yy]ou|[A-Z][a-z]+|"[^"\\n]+"|(?:[Tt]he|[Tt]his|[Tt]hat) [a-z]+)';
const ROUTE='(?:[Tt]he|[Tt]his|[Tt]hat) route';
export function routeLearningInterpretationPlan(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),runtime=1;const tag=text.match(/\s*\[([012])\]([.!?]?)$/);
 if(tag){runtime=Number(tag[1]);text=text.slice(0,tag.index).trim();const before=text.match(/[.!?]$/)?.[0];if(before&&tag[2]&&before!==tag[2])return null;if(!before)text+=tag[2];}
 const question=text.endsWith('?');text=text.replace(/[.!?]$/,'');
 let match=text.match(new RegExp(`^(${REF}) (learned|learnt|did not learn|didn['’]t learn) (${ROUTE})$`));
 if(question){const q=text.match(new RegExp(`^([Dd]id|[Dd]idn['’]t) (${REF}) (not )?learn (${ROUTE})$`));if(q)match=[q[0],q[2],q[1].toLowerCase()!=='did'||q[3]?'did not learn':'learned',q[4]];}
 if(!match)return null;
 return {profile:'EZROUTE-LEARNING-INTERPRETATION-1',status:'draft',experiencer:match[1],route:match[3],transition_runtime:runtime,speech_act:question?'question':'assertion',event_scopes:['before_speech',...(/^did/.test(match[2])?['negation']:[])],requires_interpretation:true,choices:Object.entries(ROUTE_LEARNING_READINGS).map(([id,r])=>({id,description:r.definition}))};
}
export function routeLearningPronounPlan(input){let interpretation_plan;const p=personalPronounPlan(input,probe=>(interpretation_plan=routeLearningInterpretationPlan(probe)),{includeNeutral:true});return p?{...p,interpretation_plan}:null;}
const exact=(v,fields)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===fields.length&&fields.every(k=>Object.hasOwn(v,k));
export async function validateRouteLearning(input,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Route learning requires draft opt-in.');
 const d=structuredClone(input);
 if(!exact(d,['profile','status','transition_root','transition_runtime','speech_act','event_scopes','result_assertion','phase_contract','result_state','content_digest','acquisition_id']))throw new Error('Invalid route learning fields.');
 if(d.profile!=='EZROUTE-LEARNING-1'||d.status!=='draft'||d.transition_root!=='ORI:110'||d.result_assertion!=='at_culmination_only'||await canonicalDigest(d.phase_contract)!==await canonicalDigest({before:'does_not_hold',culmination:'holds',after:'unspecified'}))throw new Error('Invalid route acquisition contract.');
 if(![0,1,2].includes(d.transition_runtime)||!['assertion','question'].includes(d.speech_act)||!validAcquisitionScopes(d.event_scopes))throw new Error('Invalid route event runtime or scope.');
 const r=d.result_state;
 if(!exact(r,['reading','predicate','criterion','experiencer','route','runtime_state','content_commitment'])||!Object.hasOwn(ROUTE_LEARNING_READINGS,r.reading)||![0,1,2].includes(r.runtime_state))throw new Error('Invalid route result state.');
 const definition=ROUTE_LEARNING_READINGS[r.reading];
 if(r.predicate!==definition.predicate||r.criterion!==definition.definition||r.content_commitment!==(r.reading==='memorization'?'representation_without_truth_assertion':'contextual_route_reference'))throw new Error('Route result meaning mismatch.');
 await createContextualContent('topic',r.experiencer,{allowDraft:true});await createContextualContent('topic',r.route,{allowDraft:true});
 if(r.route.kind!=='phonemic_reference'||r.route.name.normalized_label!=='route'||!['definite_nominal','proximal_nominal','distal_nominal'].includes(r.route.reference_mode))throw new Error('Expected an explicit route reference.');
 const {content_digest,acquisition_id,...body}=d,digest=await canonicalDigest(body);
 if(content_digest!==digest||acquisition_id!==`EZROUTEACQ:${digest.slice(0,24)}`)throw new Error('Route learning identity mismatch.');
 return d;
}
export async function composeRouteLearning(input,{allowDraft=false,interpretation,bindings,resultRuntime=1}={}){
 if(!allowDraft)throw new Error('Route learning requires draft opt-in.');
 const pronouns=routeLearningPronounPlan(input);
 if(pronouns)input=resolvePersonalPronouns(input,pronouns,bindings,validReferent).resolved;
 else if(bindings!==undefined)throw new Error('This route sentence has no unresolved pronouns.');
 const plan=routeLearningInterpretationPlan(input);if(!plan)throw new Error('Unsupported route-learning sentence.');
 if(!Object.hasOwn(ROUTE_LEARNING_READINGS,interpretation)){const e=new Error('Choose memorization, practical navigation knowledge, or familiarity.');e.code='route_learning_interpretation_required';e.plan=plan;throw e;}
 const definition=ROUTE_LEARNING_READINGS[interpretation],body={profile:'EZROUTE-LEARNING-1',status:'draft',transition_root:'ORI:110',transition_runtime:plan.transition_runtime,speech_act:plan.speech_act,event_scopes:plan.event_scopes,result_assertion:'at_culmination_only',phase_contract:{before:'does_not_hold',culmination:'holds',after:'unspecified'},result_state:{reading:interpretation,predicate:definition.predicate,criterion:definition.definition,experiencer:await contextualContentReference(plan.experiencer),route:await contextualContentReference(plan.route),runtime_state:resultRuntime,content_commitment:interpretation==='memorization'?'representation_without_truth_assertion':'contextual_route_reference'}},digest=await canonicalDigest(body);
 return validateRouteLearning({...body,content_digest:digest,acquisition_id:`EZROUTEACQ:${digest.slice(0,24)}`},{allowDraft:true});
}
// Same completed-state transition model; caller must establish the selected
// result independently. Neither source truth nor runtime bits establish it.
export const evaluateRouteLearning=evaluateKnowledgeAcquisition;
