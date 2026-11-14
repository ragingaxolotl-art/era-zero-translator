import {expandNegativeContractions} from './contractions.mjs';
import {personalPronounPlan,resolvePersonalPronouns} from './personal_pronoun_plan.mjs';
import {validReferent} from './pronouns.mjs';
import {contextualContentReference} from './contextual_content.mjs';
import {createOwnershipMeaning} from './ownership_meaning.mjs';
const REF='(?:I|[Yy]ou|[A-Z][a-z]+|"[^"\\n]+"|(?:[Tt]he|[Tt]his|[Tt]hat) [a-z]+)';
export function ownershipPlan(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),runtimeState=1;const tag=text.match(/\s*\[([012])\]([.!?]?)$/);
 if(tag){runtimeState=Number(tag[1]);text=text.slice(0,tag.index).trim();const punctuation=text.match(/[.!?]$/)?.[0];if(punctuation&&tag[2]&&punctuation!==tag[2])return null;if(!punctuation)text+=tag[2];}
 text=expandNegativeContractions(text,`(${REF})`);const question=text.endsWith('?');text=text.replace(/[.!?]$/,'');
 let m,owner,object,verb,negative=false;
 if(question){
  m=text.match(new RegExp(`^([Dd]o|[Dd]oes|[Dd]id) (${REF}) (not )?own (${REF})$`));if(!m)return null;
  verb=m[1].toLowerCase();owner=m[2];negative=!!m[3];object=m[4];
 }else{
  m=text.match(new RegExp(`^(${REF}) (?:(do not|does not|did not) )?(own|owns|owned) (${REF})$`));if(!m||m[2]&&m[3]!=='own')return null;
  owner=m[1];verb=m[2]?.split(' ')[0]||m[3];negative=!!m[2];object=m[4];
 }
 const firstOrSecond=owner==='I'||/^you$/i.test(owner);
 if(['do','does','own','owns'].includes(verb)&&!(firstOrSecond?['do','own']:['does','owns']).includes(verb))return null;
 return {owner,object,runtimeState,speechAct:question?'question':'assertion',scopes:[...(['did','owned'].includes(verb)?[{operator:'time',relation:'before_speech'}]:[]),...(negative?[{operator:'negation'}]:[])],required:'explicit_ownership_framework'};
}
export function ownershipPronounPlan(input){let interpretation_plan;const p=personalPronounPlan(input,probe=>(interpretation_plan=ownershipPlan(probe)),{includeNeutral:true});return p?{...p,interpretation_plan}:null;}
export async function composeOwnershipSentence(input,{allowDraft=false,framework,bindings}={}){
 if(!allowDraft)throw new Error('Ownership requires draft opt-in.');
 const pronouns=ownershipPronounPlan(input);if(pronouns)input=resolvePersonalPronouns(input,pronouns,bindings,validReferent).resolved;else if(bindings!==undefined)throw new Error('No unresolved pronouns.');
 const plan=ownershipPlan(input);if(!plan)throw new Error('Unsupported ownership sentence.');
 if(typeof framework!=='string'||!framework.trim())throw new Error('Identify the ownership framework explicitly.');
 return createOwnershipMeaning(await contextualContentReference(plan.owner),await contextualContentReference(plan.object),await contextualContentReference(framework),{allowDraft:true,speechAct:plan.speechAct,scopes:plan.scopes,runtimeState:plan.runtimeState});
}
