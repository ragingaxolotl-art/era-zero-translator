import {canonicalDigest} from './engine.mjs';
import {contextualContentReference,createContextualContent} from './contextual_content.mjs';
import {createContextualInquiry,validateContextualInquiry} from './contextual_inquiry.mjs';
import {personalPronounPlan,resolvePersonalPronouns} from './personal_pronoun_plan.mjs';
import {validReferent} from './pronouns.mjs';
export const CURIOSITY_CONTRACT=Object.freeze({
 predicate:'epistemic_curiosity',desire_foundation_id:'FND:f66b7a3877f4b0140a0b7023',
 criterion:'The experiencer has epistemic interest in the contextual inquiry: resolving some contextually relevant uncertainty about the topic is itself motivationally attractive, rather than wanted solely for a separate practical outcome. Instrumental motives may coexist. This does not require pleasure, current attention, a conscious feeling, intention, action, successful discovery or complete ignorance of the topic.',
 desired_outcome:'same_experiencer_gains_contextually_relevant_information_resolving_some_inquiry_uncertainty',
 outcome_commitment:'desired_not_asserted',question_commitment:'contextual_not_specified'
});
const REF='(?:I|[Yy]ou|[A-Z][a-z]+|"[^"\\n]+"|(?:[Tt]he|[Tt]his|[Tt]hat) [a-z]+)';
export function curiosityInterpretationPlan(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),runtime=1;const tag=text.match(/\s*\[([012])\]([.!?]?)$/);
 if(tag){runtime=Number(tag[1]);text=text.slice(0,tag.index).trim();const punctuation=text.match(/[.!?]$/)?.[0];if(punctuation&&tag[2]&&punctuation!==tag[2])return null;if(!punctuation)text+=tag[2];}
 const question=text.endsWith('?');text=text.replace(/[.!?]$/,'').replace(/\b(isn|aren|wasn|weren)['’]t\b/gi,(_,v)=>({isn:'is',aren:'are',wasn:'was',weren:'were'}[v.toLowerCase()]+' not'));
 let match=text.match(new RegExp(`^(${REF}) (am|is|are|was|were) (not )?curious about (${REF})$`));
 if(question){const q=text.match(new RegExp(`^([Aa]m|[Ii]s|[Aa]re|[Ww]as|[Ww]ere) (not )?(${REF}) (not )?curious about (${REF})$`));if(q){if(q[2]&&q[4])return null;match=[q[0],q[3],q[1].toLowerCase(),q[2]||q[4],q[5]];}}
 if(!match)return null;
 const expected=match[1]==='I'?['am','was']:/^you$/i.test(match[1])?['are','were']:['is','was'];if(!expected.includes(match[2]))return null;
 return {experiencer:match[1],topic:match[4],speech_act:question?'question':'assertion',runtime_state:runtime,scopes:[...(['was','were'].includes(match[2])?[{operator:'time',relation:'before_speech'}]:[]),...(match[3]?[{operator:'negation'}]:[])]};
}
export function curiosityPronounPlan(input){let interpretation_plan;const plan=personalPronounPlan(input,probe=>(interpretation_plan=curiosityInterpretationPlan(probe)),{includeNeutral:true});return plan?{...plan,interpretation_plan}:null;}
export function validCuriosityScopes(scopes){return [[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]].some(s=>JSON.stringify(s)===JSON.stringify(scopes));}
export async function validateCuriosity(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Curiosity requires draft opt-in.');
 const d=structuredClone(document),keys=['profile','status',...Object.keys(CURIOSITY_CONTRACT),'experiencer','inquiry','speech_act','scopes','runtime_state','content_digest','content_id'];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZCURIOSITY-1'||d.status!=='draft'||Object.entries(CURIOSITY_CONTRACT).some(([k,v])=>d[k]!==v)||![0,1,2].includes(d.runtime_state)||!['assertion','question'].includes(d.speech_act)||!validCuriosityScopes(d.scopes))throw new Error('Invalid curiosity contract.');
 await createContextualContent('topic',d.experiencer,{allowDraft:true});await validateContextualInquiry(d.inquiry,{allowDraft:true});
 const {content_digest,content_id,...body}=d,digest=await canonicalDigest(body);if(content_digest!==digest||content_id!==`EZCUR:${digest.slice(0,24)}`)throw new Error('Curiosity identity mismatch.');return d;
}
export async function composeCuriosity(input,{allowDraft=false,bindings}={}){
 if(!allowDraft)throw new Error('Curiosity requires draft opt-in.');
 const pronouns=curiosityPronounPlan(input);if(pronouns)input=resolvePersonalPronouns(input,pronouns,bindings,validReferent).resolved;else if(bindings!==undefined)throw new Error('No unresolved pronouns.');
 const p=curiosityInterpretationPlan(input);if(!p)throw new Error('Unsupported curiosity sentence.');
 const body={profile:'EZCURIOSITY-1',status:'draft',...CURIOSITY_CONTRACT,experiencer:await contextualContentReference(p.experiencer),inquiry:await createContextualInquiry(await contextualContentReference(p.topic),{allowDraft:true}),speech_act:p.speech_act,scopes:p.scopes,runtime_state:p.runtime_state},digest=await canonicalDigest(body);
 return validateCuriosity({...body,content_digest:digest,content_id:`EZCUR:${digest.slice(0,24)}`},{allowDraft:true});
}
