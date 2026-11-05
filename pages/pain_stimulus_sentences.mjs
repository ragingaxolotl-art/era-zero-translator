import {composePainMeaning} from './pain_meaning.mjs';
import {contextualContentReference} from './contextual_content.mjs';
import {createPainStimulus} from './pain_stimulus.mjs';
import {personalPronounPlan,resolvePersonalPronouns} from './personal_pronoun_plan.mjs';
import {validReferent} from './pronouns.mjs';
const REF='(?:I|me|you|You|[A-Z][a-z]+|"[^"\\n]+"|(?:[Tt]he|[Tt]his|[Tt]hat) [a-z]+)';
export function painStimulusPlan(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),runtimeState=1;const tag=text.match(/\s*\[([012])\]([.!?]?)$/);
 if(tag){runtimeState=Number(tag[1]);text=text.slice(0,tag.index).trim();const p=text.match(/[.!?]$/)?.[0];if(p&&tag[2]&&p!==tag[2])return null;if(!p)text+=tag[2];}
 const speechAct=text.endsWith('?')?'question':'assertion';text=text.replace(/[.!?]$/,'');
 const forms=speechAct==='question'?[
  ['actual_causation',new RegExp(`^[Dd]id (${REF}) (not )?cause bodily pain for (${REF})$`),true],
  ['expected_outcome',new RegExp(`^[Ii]s (${REF}) (not )?expected to cause bodily pain for (${REF})$`),false],
  ['disposition',new RegExp(`^[Dd]oes (${REF}) (not )?tend to cause bodily pain for (${REF})$`),false]
 ]:[
  ['actual_causation',new RegExp(`^(${REF}) (caused|did not cause) bodily pain for (${REF})$`),true],
  ['expected_outcome',new RegExp(`^(${REF}) is (not )?expected to cause bodily pain for (${REF})$`),false],
  ['disposition',new RegExp(`^(${REF}) (tends|does not tend) to cause bodily pain for (${REF})$`),false]
 ];
 for(const [relation,re,past] of forms){const m=text.match(re);if(!m)continue;
  // The present forms above are singular third-person forms only.
  if(!past&&/^(?:I|me|you)$/i.test(m[1]))return null;
  if(/^me$/i.test(m[1]))return null;
  return {stimulus:m[1],experiencer:m[3],relation,speechAct,runtimeState,scopes:[...(past?[{operator:'time',relation:'before_speech'}]:[]),...(/\bnot\b/.test(m[2]||'')?[{operator:'negation'}]:[])]};
 }
 return null;
}
export function painStimulusPronounPlan(input){let interpretation_plan;const p=personalPronounPlan(input,probe=>(interpretation_plan=painStimulusPlan(probe)),{includeNeutral:true});return p?{...p,interpretation_plan}:null;}
export async function composePainStimulusSentence(input,{allowDraft=false,bindings}={}){
 if(!allowDraft)throw new Error('Pain stimulus requires draft opt-in.');
 const pronouns=painStimulusPronounPlan(input);
 if(pronouns)input=resolvePersonalPronouns(input,pronouns,bindings,validReferent).resolved;else if(bindings!==undefined)throw new Error('No unresolved pronouns.');
 const p=painStimulusPlan(input);if(!p)throw new Error('Specify supported actual causation, expectation or tendency explicitly.');
 const person=/^(?:I|me)$/i.test(p.experiencer)?'I':p.experiencer,copula=person==='I'?'am':/^you$/i.test(person)?'are':'is';
 const outcome=await composePainMeaning(`${person} ${copula} in bodily pain.`,{allowDraft:true});
 return createPainStimulus(await contextualContentReference(p.stimulus),outcome,{allowDraft:true,...p});
}
