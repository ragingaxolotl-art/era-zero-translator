import {expandNegativeContractions} from './contractions.mjs';
import {personalPronounPlan,resolvePersonalPronouns} from './personal_pronoun_plan.mjs';
import {validReferent} from './pronouns.mjs';
import {contextualContentReference} from './contextual_content.mjs';
import {createCustodyOpportunity} from './custody_opportunity.mjs';
const REF='(?:I|[Yy]ou|[A-Z][a-z]+|"[^"\\n]+"|(?:[Tt]he|[Tt]his|[Tt]hat) [a-z]+)';
export function availabilityPlan(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),runtimeState=1;const tag=text.match(/\s*\[([012])\]([.!?]?)$/);
 if(tag){runtimeState=Number(tag[1]);text=text.slice(0,tag.index).trim();const punctuation=text.match(/[.!?]$/)?.[0];if(punctuation&&tag[2]&&punctuation!==tag[2])return null;if(!punctuation)text+=tag[2];}
 text=expandNegativeContractions(text,`(${REF})`);const question=text.endsWith('?');text=text.replace(/[.!?]$/,'');
 const m=question?text.match(new RegExp(`^([Ii]s|[Ww]as) (${REF}) (not )?available(?: to (${REF}))?$`)):text.match(new RegExp(`^(${REF}) (is|was) (not )?available(?: to (${REF}))?$`));if(!m)return null;
 const resource=question?m[2]:m[1],verb=(question?m[1]:m[2]).toLowerCase();if(/^(I|you)$/i.test(resource))return null;
 return {resource,prospectiveHolder:m[4]||null,runtimeState,speechAct:question?'question':'assertion',scopes:[...(verb==='was'?[{operator:'time',relation:'before_speech'}]:[]),...(m[3]?[{operator:'negation'}]:[])],required:['explicit_availability_reading','explicit_access_context',...(!m[4]?['explicit_prospective_holder']:[])]};
}
export function availabilityPronounPlan(input){let interpretation_plan;const p=personalPronounPlan(input,probe=>(interpretation_plan=availabilityPlan(probe)),{includeNeutral:true});return p?{...p,interpretation_plan}:null;}
export async function composeAvailabilitySentence(input,{allowDraft=false,interpretation,accessContext,prospectiveHolder,bindings}={}){
 if(!allowDraft)throw new Error('Availability requires draft opt-in.');
 const pronouns=availabilityPronounPlan(input);if(pronouns)input=resolvePersonalPronouns(input,pronouns,bindings,validReferent).resolved;else if(bindings!==undefined)throw new Error('No unresolved pronouns.');
 const p=availabilityPlan(input);if(!p)throw new Error('Unsupported availability sentence.');
 if(interpretation!=='practical_custody_opportunity')throw new Error('Select the practical opportunity to acquire physical custody reading. Other availability senses require different meanings.');
 if(p.prospectiveHolder&&prospectiveHolder!==undefined)throw new Error('The sentence already specifies the prospective holder.');
 const holder=p.prospectiveHolder||prospectiveHolder;if(typeof holder!=='string'||!holder.trim())throw new Error('Identify who has the opportunity explicitly.');
 if(typeof accessContext!=='string'||!accessContext.trim())throw new Error('Identify the access context explicitly.');
 return createCustodyOpportunity(await contextualContentReference(holder),await contextualContentReference(p.resource),await contextualContentReference(accessContext),{allowDraft:true,speechAct:p.speechAct,scopes:p.scopes,runtimeState:p.runtimeState});
}
