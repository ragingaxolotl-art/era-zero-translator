import {expandNegativeContractions} from './contractions.mjs';
import {personalPronounPlan,resolvePersonalPronouns} from './personal_pronoun_plan.mjs';
import {validReferent} from './pronouns.mjs';
import {contextualContentReference} from './contextual_content.mjs';
import {createMaterialReference} from './material_reference.mjs';
import {createDrinkingMeaning} from './drinking_meaning.mjs';
const REF='(?:I|[Yy]ou|[A-Z][a-z]+|"[^"\\n]+"|(?:[Tt]he|[Tt]his|[Tt]hat) [a-z]+)';
export function drinkingPlan(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),runtimeState=1;const tag=text.match(/\s*\[([012])\]([.!?]?)$/);
 if(tag){runtimeState=Number(tag[1]);text=text.slice(0,tag.index).trim();const p=text.match(/[.!?]$/)?.[0];if(p&&tag[2]&&p!==tag[2])return null;if(!p)text+=tag[2];}
 text=expandNegativeContractions(text,`(${REF})`);
 const question=text.endsWith('?');text=text.replace(/[.!?]$/,'');
 let m,holder,material,verb,negative=false,viewpoint,past=false;
 if(question){
  m=text.match(new RegExp(`^([Aa]m|[Ii]s|[Aa]re|[Ww]as|[Ww]ere) (${REF}) (not )?drinking (.+)$`));
  if(m){verb=m[1].toLowerCase();holder=m[2];negative=!!m[3];material=m[4];viewpoint='ongoing';}
  else {m=text.match(new RegExp(`^([Dd]o|[Dd]oes|[Dd]id) (${REF}) (not )?(habitually )?drink (.+)$`));if(!m)return null;verb=m[1].toLowerCase();holder=m[2];negative=!!m[3];material=m[5];viewpoint=m[4]?'habitual':verb==='did'?'bounded':null;}
 }else{
  m=text.match(new RegExp(`^(${REF}) (am|is|are|was|were) (not )?drinking (.+)$`));
  if(m){holder=m[1];verb=m[2];negative=!!m[3];material=m[4];viewpoint='ongoing';}
  else {m=text.match(new RegExp(`^(${REF}) (?:(do not|does not|did not) )?(habitually )?(drink|drinks|drank) (.+)$`));if(!m)return null;holder=m[1];verb=m[2]?.split(' ')[0]||m[4];negative=!!m[2];material=m[5];if(m[2]&&m[4]!=='drink')return null;viewpoint=m[3]?'habitual':['did','drank'].includes(verb)?'bounded':null;}
 }
 const first=holder==='I',second=/^you$/i.test(holder);
 if(['am','is','are','was','were'].includes(verb)&&!(first?['am','was']:second?['are','were']:['is','was']).includes(verb))return null;
 if(['do','does','drink','drinks'].includes(verb)&&!(first||second?['do','drink']:['does','drinks']).includes(verb))return null;
 past=['was','were','did','drank'].includes(verb);
 return {holder,material,viewpoint,runtimeState,speechAct:question?'question':'assertion',scopes:[...(past?[{operator:'time',relation:'before_speech'}]:[]),...(negative?[{operator:'negation'}]:[])]};
}
export function drinkingPronounPlan(input){let interpretation_plan;const p=personalPronounPlan(input,probe=>(interpretation_plan=drinkingPlan(probe)),{includeNeutral:true});return p?{...p,interpretation_plan}:null;}
export async function composeDrinkingSentence(input,{allowDraft=false,interpretation,viewpoint,materialReading,bindings}={}){
 if(!allowDraft)throw new Error('Drinking requires draft opt-in.');
 const pronouns=drinkingPronounPlan(input);
 if(pronouns)input=resolvePersonalPronouns(input,pronouns,bindings,validReferent).resolved;else if(bindings!==undefined)throw new Error('No unresolved pronouns.');
 const p=drinkingPlan(input);if(!p)throw new Error('Unsupported drinking sentence.');
 if(interpretation!=='literal_drinking')throw new Error('Select literal intake of liquid as drink.');
 if(p.viewpoint&&viewpoint&&viewpoint!==p.viewpoint)throw new Error('Selected viewpoint conflicts with the sentence.');
 return createDrinkingMeaning(await contextualContentReference(p.holder),await createMaterialReference(p.material,{allowDraft:true,reading:materialReading}),{allowDraft:true,viewpoint:p.viewpoint||viewpoint,speechAct:p.speechAct,scopes:p.scopes,runtimeState:p.runtimeState});
}
