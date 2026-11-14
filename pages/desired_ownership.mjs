import {personalPronounPlan,resolvePersonalPronouns} from './personal_pronoun_plan.mjs';
import {validReferent} from './pronouns.mjs';
import {parseFoundationSentence} from './foundation_sentences.mjs';
import {contextualContentReference,createContextualContent} from './contextual_content.mjs';
import {composeOwnershipSentence,ownershipPlan} from './ownership_sentences.mjs';
import {validateOwnershipMeaning} from './ownership_meaning.mjs';
import {canonicalDigest} from './engine.mjs';
const FOUNDATION='FND:f66b7a3877f4b0140a0b7023';
export function desiredOwnershipPlan(input){
 const p=parseFoundationSentence(input);if(p?.type!=='desire'||p.calendarDay!==undefined)return null;
 let content=p.content.replace(/^that /,''),binding='explicit_content_subject';
 const m=content.match(/^(?:(I|you|me|[A-Z][a-z]+|"[^"\n]+"|(?:the|this|that) [a-z]+) )?(not )?to (not )?own (.+)$/);
 if(m){
  if(m[2]&&m[3])return null;const subject=m[1]==='me'?'I':m[1]||p.holder,first=/^(I|you)$/i.test(subject),negative=!!(m[2]||m[3]);
  content=`${subject} ${negative?(first?'do not own':'does not own'):(first?'own':'owns')} ${m[4]}`;binding=m[1]?'explicit_content_subject':'same_as_desire_holder';
 }
 const inner=ownershipPlan(content);if(!inner||inner.speechAct!=='assertion')return null;
 return {holder:p.holder,content,subject_binding:binding,speech_act:p.speechAct,runtime_state:p.state,scopes:[...(p.speechTime?[{operator:'time',relation:'before_speech'}]:[]),...(p.negated?[{operator:'negation'}]:[])]};
}
export async function validateDesiredOwnership(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Desired ownership requires draft opt-in.');
 const d=structuredClone(document),keys=['profile','status','foundation_id','holder','content','content_status','outcome_commitment','subject_binding','speech_act','scopes','runtime_state','content_digest','content_id'];
 const scopes=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZDESIRED-OWNERSHIP-1'||d.status!=='draft'||d.foundation_id!==FOUNDATION||d.content_status!=='intensional'||d.outcome_commitment!=='desired_not_asserted'||!['same_as_desire_holder','explicit_content_subject'].includes(d.subject_binding)||!['assertion','question'].includes(d.speech_act)||![0,1,2].includes(d.runtime_state)||!scopes.some(s=>JSON.stringify(s)===JSON.stringify(d.scopes)))throw new Error('Invalid desired ownership contract.');
 await createContextualContent('topic',d.holder,{allowDraft:true});await validateOwnershipMeaning(d.content,{allowDraft:true});
 if(d.content.speech_act!=='assertion'||(d.subject_binding==='same_as_desire_holder'&&await canonicalDigest(d.holder)!==await canonicalDigest(d.content.owner)))throw new Error('Invalid desired owner binding.');
 const {content_digest,content_id,...body}=d,hash=await canonicalDigest(body);if(content_digest!==hash||content_id!==`EZDESOWN:${hash.slice(0,24)}`)throw new Error('Desired ownership identity mismatch.');return d;
}
export function desiredOwnershipPronounPlan(input){let interpretation_plan;const p=personalPronounPlan(input,probe=>(interpretation_plan=desiredOwnershipPlan(probe)),{includeNeutral:true});return p?{...p,interpretation_plan}:null;}
export async function composeDesiredOwnership(input,{allowDraft=false,framework,bindings}={}){
 if(!allowDraft)throw new Error('Desired ownership requires draft opt-in.');
 const pronouns=desiredOwnershipPronounPlan(input);if(pronouns)input=resolvePersonalPronouns(input,pronouns,bindings,validReferent).resolved;else if(bindings!==undefined)throw new Error('No unresolved pronouns.');
 const p=desiredOwnershipPlan(input);if(!p)throw new Error('Unsupported desired ownership sentence.');
 const content=await composeOwnershipSentence(p.content,{allowDraft:true,framework});
 const body={profile:'EZDESIRED-OWNERSHIP-1',status:'draft',foundation_id:FOUNDATION,holder:await contextualContentReference(p.holder),content,content_status:'intensional',outcome_commitment:'desired_not_asserted',subject_binding:p.subject_binding,speech_act:p.speech_act,scopes:p.scopes,runtime_state:p.runtime_state},hash=await canonicalDigest(body);
 return validateDesiredOwnership({...body,content_digest:hash,content_id:`EZDESOWN:${hash.slice(0,24)}`},{allowDraft:true});
}
