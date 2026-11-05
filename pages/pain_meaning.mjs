// Draft semantic prerequisite. No music code or canonical vocabulary admission.
import {canonicalDigest} from './engine.mjs';
import {contextualContentReference,createContextualContent} from './contextual_content.mjs';
import {personalPronounPlan,resolvePersonalPronouns} from './personal_pronoun_plan.mjs';
import {validReferent} from './pronouns.mjs';
const CONTRACT=Object.freeze({predicate:'felt_bodily_pain',dependency:'CMP:6c9e3042a361ccae6ecf5980',dependency_version:'1.0.0',quality:'bodily_pain_experience',injury_commitment:'not_entailed',cause_commitment:'unspecified',intensity_commitment:'unspecified',stimulus_commitment:'unspecified'});
const REF='(?:I|you|You|[A-Z][a-z]+|"[^"\\n]+"|(?:[Tt]he|[Tt]his|[Tt]hat) [a-z]+)';
export function painMeaningPlan(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),runtime_state=1;const tag=text.match(/\s*\[([012])\]([.!?]?)$/);
 if(tag){runtime_state=Number(tag[1]);text=text.slice(0,tag.index).trim();const mark=text.match(/[.!?]$/)?.[0];if(mark&&tag[2]&&mark!==tag[2])return null;if(!mark)text+=tag[2];}
 const speech_act=text.endsWith('?')?'question':'assertion';text=text.replace(/[.!?]$/,'');
 let m=text.match(new RegExp(`^(${REF}) (am|is|are|was|were) (not )?in bodily pain$`));
 if(speech_act==='question'){const q=text.match(new RegExp(`^([Aa]m|[Ii]s|[Aa]re|[Ww]as|[Ww]ere) (${REF}) (not )?in bodily pain$`));if(!q)return null;m=[q[0],q[2],q[1].toLowerCase(),q[3]];}
 if(!m)return null;const forms=m[1]==='I'?['am','was']:/^you$/i.test(m[1])?['are','were']:['is','was'];if(!forms.includes(m[2]))return null;
 return {experiencer:m[1],speech_act,runtime_state,scopes:[...(['was','were'].includes(m[2])?[{operator:'time',relation:'before_speech'}]:[]),...(m[3]?[{operator:'negation'}]:[])]};
}
export async function validatePainMeaning(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Pain meaning requires draft opt-in.');
 const d=structuredClone(document),keys=['profile','status',...Object.keys(CONTRACT),'experiencer','speech_act','runtime_state','scopes','content_digest','content_id'];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZPAIN-MEANING-1'||d.status!=='draft'||Object.entries(CONTRACT).some(([k,v])=>d[k]!==v)||![0,1,2].includes(d.runtime_state)||!['assertion','question'].includes(d.speech_act))throw new Error('Invalid pain meaning contract.');
 const scopes=[[],[{operator:'negation'}],[{operator:'time',relation:'before_speech'}],[{operator:'time',relation:'before_speech'},{operator:'negation'}]];
 if(!scopes.some(s=>JSON.stringify(s)===JSON.stringify(d.scopes)))throw new Error('Unsupported pain scope.');
 await createContextualContent('topic',d.experiencer,{allowDraft:true});
 const {content_digest,content_id,...body}=d,digest=await canonicalDigest(body);
 if(content_digest!==digest||content_id!==`EZPAIN:${digest.slice(0,24)}`)throw new Error('Pain identity mismatch.');return d;
}
export async function composePainMeaning(input,{allowDraft=false,bindings}={}){
 if(!allowDraft)throw new Error('Pain meaning requires draft opt-in.');
 const pronouns=personalPronounPlan(input,painMeaningPlan,{includeNeutral:true});
 if(pronouns)input=resolvePersonalPronouns(input,pronouns,bindings,validReferent).resolved;else if(bindings!==undefined)throw new Error('No unresolved pronouns.');
 const p=painMeaningPlan(input);if(!p)throw new Error('Select an explicit supported bodily-pain meaning.');
 const body={profile:'EZPAIN-MEANING-1',status:'draft',...CONTRACT,...p,experiencer:await contextualContentReference(p.experiencer)},digest=await canonicalDigest(body);
 return validatePainMeaning({...body,content_digest:digest,content_id:`EZPAIN:${digest.slice(0,24)}`},{allowDraft:true});
}
