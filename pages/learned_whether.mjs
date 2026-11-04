import {personalPronounPlan} from './personal_pronoun_plan.mjs';
import {validReferent} from './pronouns.mjs';
import {expandNegativeContractions} from './contractions.mjs';
import {composeFoundationSentence} from './foundation_sentences.mjs';
import {createKnowledgeAcquisition} from './knowledge_acquisition.mjs';
const HOLDER='(?:I|[Yy]ou|[A-Z][a-z]+|"[^"\\n]+"|(?:[Tt]he|[Tt]his|[Tt]hat) [a-z]+)';
export function parseLearnedWhether(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),state=1;const runtime=text.match(/\s+\[([012])\]([.!?]?)$/);
 if(runtime){const before=text.slice(0,runtime.index).match(/[.!?]$/)?.[0];if(before&&runtime[2]&&before!==runtime[2])return null;state=Number(runtime[1]);text=text.slice(0,runtime.index)+(before?'':runtime[2]);}
 text=expandNegativeContractions(text,`(${HOLDER})`);const question=text.endsWith('?');text=text.replace(/[.!?]$/,'');
 const day=text.match(/^(Yesterday|Today),\s+(.+)$/);if(day)text=day[2];
 let m=text.match(new RegExp(`^(${HOLDER}) (learned|did not learn) whether (.+)$`));
 if(!m&&question){const q=text.match(new RegExp(`^[Dd]id (${HOLDER}) (not )?learn whether (.+)$`));if(q)m=[q[0],q[1],q[2]?'did not learn':'learned',q[3]];}
 if(!m)return null;
 return {holder:m[1],body:m[3],runtimeState:state,speechAct:question?'question':'assertion',eventScopes:[...(day?[day[1]==='Yesterday'?'previous_day':'current_day']:[]),...(day?.[1]==='Yesterday'?[]:['before_speech']),...(m[2].includes('not')?['negation']:[])]};
}
export const learnedWhetherPronounPlan=input=>personalPronounPlan(input,parseLearnedWhether);
export async function composeLearnedWhether(input,authority,records,loadTemplate,{allowDraft=false,bindings}={}){
 if(!allowDraft)throw new Error('Learning composition requires explicit draft opt-in.');
 const pronouns=learnedWhetherPronounPlan(input);
 if(pronouns){
  if(!bindings||typeof bindings!=='object'||Array.isArray(bindings)||Object.keys(bindings).length!==pronouns.occurrences.length||pronouns.occurrences.some(o=>!Object.hasOwn(bindings,o.key)||!validReferent(bindings[o.key]))){const error=new Error('Identify each pronoun with an explicit name, noun reference or I/you.');error.code='pronoun_referents_required';throw error;}
  const chosen={...bindings};let resolved=input;
  for(const o of [...pronouns.occurrences].reverse())resolved=resolved.slice(0,o.start)+chosen[o.key]+resolved.slice(o.end);
  const result=await composeLearnedWhether(resolved,authority,records,loadTemplate,{allowDraft:true});
  return {...result,source_input:input,resolved_input:resolved,resolved_pronouns:pronouns.occurrences.map(o=>({...o,referent:chosen[o.key]}))};
 }
 if(bindings!==undefined)throw new Error('This learning sentence does not require pronoun bindings.');
 const plan=parseLearnedWhether(input);if(!plan)throw new Error('Unsupported learned-whether sentence.');
 // Result knowledge is bound to culmination; event tense must not be copied
 // onto it. The explicit terminal tag leaves any body tag on its own predicate.
 const result=await composeFoundationSentence(`${plan.holder} knows whether ${plan.body} [1]`,authority,records,loadTemplate,{allowDraft:true,allowCognitive:true});
 const acquisition=await createKnowledgeAcquisition(result,{allowDraft:true,runtimeState:plan.runtimeState,speechAct:plan.speechAct,eventScopes:plan.eventScopes});
 return {status:'draft_acquisition_translation',source_input:input,construction:'learned_whether',acquisition,result_formal:result.formal};
}
