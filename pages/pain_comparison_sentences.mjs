import {composePainMeaning} from './pain_meaning.mjs';
import {createPainStimulus,PAIN_RELATIONS} from './pain_stimulus.mjs';
import {createPainComparison} from './pain_comparison.mjs';
import {contextualContentReference} from './contextual_content.mjs';
import {personalPronounPlan,resolvePersonalPronouns} from './personal_pronoun_plan.mjs';
import {validReferent} from './pronouns.mjs';
const REF='(?:I|me|you|You|[A-Z][a-z]+|"[^"\\n]+"|(?:[Tt]he|[Tt]his|[Tt]hat) [a-z]+)';
export function painComparisonPlan(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),runtimeState=1;const tag=text.match(/\s*\[([012])\]([.!?]?)$/);
 if(tag){runtimeState=Number(tag[1]);text=text.slice(0,tag.index).trim();const p=text.match(/[.!?]$/)?.[0];if(p&&tag[2]&&p!==tag[2])return null;if(!p)text+=tag[2];}
 const speechAct=text.endsWith('?')?'question':'assertion';text=text.replace(/[.!?]$/,'');
 const suffix=`(not )?(more|less|equally) painful for (${REF}) (than|as) (${REF})`;
 let m=text.match(new RegExp(`^(${REF}) (is|was) ${suffix}$`));
 if(speechAct==='question'){const q=text.match(new RegExp(`^([Ii]s|[Ww]as) (${REF}) ${suffix}$`));if(!q)return null;m=[q[0],q[2],q[1].toLowerCase(),...q.slice(3)];}
 if(!m||/^(I|me|you)$/i.test(m[1])||((m[4]==='equally')!==(m[6]==='as')))return null;
 return {left:m[1],right:m[7],experiencer:m[5],relation:{more:'greater_than',less:'less_than',equally:'equal'}[m[4]],speechAct,runtimeState,scopes:[...(m[2]==='was'?[{operator:'time',relation:'before_speech'}]:[]),...(m[3]?[{operator:'negation'}]:[])],requires_interpretation:true,requires_context:true};
}
export function painComparisonPronounPlan(input){let interpretation_plan;const p=personalPronounPlan(input,probe=>(interpretation_plan=painComparisonPlan(probe)),{includeNeutral:true});return p?{...p,interpretation_plan}:null;}
export async function composePainComparisonSentence(input,{allowDraft=false,interpretation,context,bindings}={}){
 if(!allowDraft)throw new Error('Pain comparison requires draft opt-in.');
 const pronouns=painComparisonPronounPlan(input);if(pronouns)input=resolvePersonalPronouns(input,pronouns,bindings,validReferent).resolved;else if(bindings!==undefined)throw new Error('No unresolved pronouns.');
 const p=painComparisonPlan(input);if(!p)throw new Error('Specify supported comparison with an explicit experiencer and both alternatives.');
 if(!Object.hasOwn(PAIN_RELATIONS,interpretation))throw new Error('Choose actual, expected or dispositional bodily-pain outcomes.');
 if(typeof context!=='string'||!context.trim())throw new Error('Identify the shared comparison context.');
 const person=/^(I|me)$/i.test(p.experiencer)?'I':p.experiencer,copula=person==='I'?'am':/^you$/i.test(person)?'are':'is';
 const outcome=await composePainMeaning(`${person} ${copula} in bodily pain.`,{allowDraft:true});
 const operands=[];for(const text of [p.left,p.right])operands.push(await createPainStimulus(await contextualContentReference(text),outcome,{allowDraft:true,relation:interpretation}));
 return createPainComparison(...operands,await contextualContentReference(context),{allowDraft:true,relation:p.relation,speechAct:p.speechAct,scopes:p.scopes,runtimeState:p.runtimeState});
}
