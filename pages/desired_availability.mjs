import {personalPronounPlan,resolvePersonalPronouns} from './personal_pronoun_plan.mjs';
import {validReferent} from './pronouns.mjs';
import {parseFoundationSentence} from './foundation_sentences.mjs';
import {contextualContentReference,createContextualContent} from './contextual_content.mjs';
import {composeAvailabilitySentence,availabilityPlan} from './availability_sentences.mjs';
import {validateCustodyOpportunity} from './custody_opportunity.mjs';
import {canonicalDigest} from './engine.mjs';
const FOUNDATION='FND:f66b7a3877f4b0140a0b7023';
export function desiredAvailabilityPlan(input){
 const p=parseFoundationSentence(input);if(p?.type!=='desire'||p.calendarDay!==undefined)return null;
 let content=p.content.replace(/^that /,''),binding='explicit_content_subject';
 // An explicit resource is necessary: bare “to be available” may describe scheduling.
 const m=content.match(/^([A-Z][a-z]+|"[^"\n]+"|(?:the|this|that) [a-z]+) (not )?to (not )?be available(.*)$/);
 if(m){
  if(m[2]&&m[3])return null;
  content=`${m[1]} is ${m[2]||m[3]?'not ':''}available${m[4]}`;
 }
 const inner=availabilityPlan(content);if(!inner||inner.speechAct!=='assertion')return null;
 return {holder:p.holder,content,subject_binding:binding,speech_act:p.speechAct,runtime_state:p.state,scopes:[...(p.speechTime?[{operator:'time',relation:'before_speech'}]:[]),...(p.negated?[{operator:'negation'}]:[])]};
}
export async function validateDesiredAvailability(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Desired availability requires draft opt-in.');
 const d=structuredClone(document),keys=['profile','status','foundation_id','holder','content','content_status','outcome_commitment','subject_binding','speech_act','scopes','runtime_state','content_digest','content_id'];
 const scopes=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZDESIRED-AVAILABILITY-1'||d.status!=='draft'||d.foundation_id!==FOUNDATION||d.content_status!=='intensional'||d.outcome_commitment!=='desired_not_asserted'||d.subject_binding!=='explicit_content_subject'||!['assertion','question'].includes(d.speech_act)||![0,1,2].includes(d.runtime_state)||!scopes.some(s=>JSON.stringify(s)===JSON.stringify(d.scopes)))throw new Error('Invalid desired availability contract.');
 await createContextualContent('topic',d.holder,{allowDraft:true});await validateCustodyOpportunity(d.content,{allowDraft:true});
 if(d.content.speech_act!=='assertion')throw new Error('Desired availability content must be a proposition.');
 const {content_digest,content_id,...body}=d,hash=await canonicalDigest(body);if(content_digest!==hash||content_id!==`EZDESAVAIL:${hash.slice(0,24)}`)throw new Error('Desired availability identity mismatch.');return d;
}
export function desiredAvailabilityPronounPlan(input){let interpretation_plan;const p=personalPronounPlan(input,probe=>(interpretation_plan=desiredAvailabilityPlan(probe)),{includeNeutral:true});return p?{...p,interpretation_plan}:null;}
export async function composeDesiredAvailability(input,{allowDraft=false,interpretation,accessContext,prospectiveHolder,bindings}={}){
 if(!allowDraft)throw new Error('Desired availability requires draft opt-in.');
 const pronouns=desiredAvailabilityPronounPlan(input);if(pronouns)input=resolvePersonalPronouns(input,pronouns,bindings,validReferent).resolved;else if(bindings!==undefined)throw new Error('No unresolved pronouns.');
 const p=desiredAvailabilityPlan(input);if(!p)throw new Error('Unsupported desired availability sentence.');
 const content=await composeAvailabilitySentence(p.content,{allowDraft:true,interpretation,accessContext,prospectiveHolder});
 const body={profile:'EZDESIRED-AVAILABILITY-1',status:'draft',foundation_id:FOUNDATION,holder:await contextualContentReference(p.holder),content,content_status:'intensional',outcome_commitment:'desired_not_asserted',subject_binding:p.subject_binding,speech_act:p.speech_act,scopes:p.scopes,runtime_state:p.runtime_state},hash=await canonicalDigest(body);
 return validateDesiredAvailability({...body,content_digest:hash,content_id:`EZDESAVAIL:${hash.slice(0,24)}`},{allowDraft:true});
}
