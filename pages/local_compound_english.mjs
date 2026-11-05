import {validateLocalCompounds} from './local_compounds.mjs';
import {contextualContentReference} from './contextual_content.mjs';
import {composeLocalCompoundSentence} from './local_compound_sentence.mjs';
import {expandNegativeContractions} from './contractions.mjs';
const REF='(?:I|you|[A-Z][a-z]+|"[^"\\n]+"|(?:the|this|that) [a-z]+)';
export async function localAdjectivePlan(input,registry,authority){
 const checked=await validateLocalCompounds(registry,authority);if(typeof input!=='string')return null;
 let text=input.trim(),runtimeState=1;const tag=text.match(/\s*\[([012])\]([.!?]?)$/);
 if(tag){runtimeState=Number(tag[1]);text=text.slice(0,tag.index).trim();const end=text.match(/[.!?]$/)?.[0];if(end&&tag[2]&&end!==tag[2])return null;if(!end)text+=tag[2];}
 text=expandNegativeContractions(text,`(${REF})`);const question=text.endsWith('?');text=text.replace(/[.!?]$/,'');
 const m=question?text.match(new RegExp(`^(Is|Was|Am|Are|Were) (${REF}) (not )?(.+)$`)):text.match(new RegExp(`^(${REF}) (is|was|am|are|were) (not )?(.+)$`));if(!m)return null;
 const subject=question?m[2]:m[1],verb=(question?m[1]:m[2]).toLowerCase(),past=['was','were'].includes(verb);
 const correct=subject==='I'?(past?'was':'am'):subject==='you'?(past?'were':'are'):(past?'was':'is');if(verb!==correct)return null;
 const entry=checked.entries.find(e=>e.definition.part_of_speech==='adjective'&&e.definition.label.toLowerCase()===m[4].toLowerCase());if(!entry)return null;
 // A syntactic subject is the bearer of a quality. Other role choices require
 // a separately declared construction and must not be guessed from labels.
 if(!entry.definition.roles.some(r=>r.role==='bearer'))return null;
 return {compound_id:entry.compound_id,subject,runtime_state:runtimeState,speech_act:question?'question':'assertion',scopes:[...(past?[{operator:'time',relation:'before_speech'}]:[]),...(m[3]?[{operator:'negation'}]:[])]};
}
export async function composeLocalAdjective(input,registry,authority,{bindings=[],anchor=60}={}){
 const plan=await localAdjectivePlan(input,registry,authority);if(!plan)throw new Error('No supported saved adjective construction matches this sentence.');
 if(!Array.isArray(bindings)||bindings.some(b=>Array.isArray(b.path)&&b.path.length===0&&b.role==='bearer'))throw new Error('The sentence already supplies its bearer.');
 const bearer={path:[],role:'bearer',reference:await contextualContentReference(plan.subject)};
 const result=await composeLocalCompoundSentence(plan.compound_id,registry,authority,[bearer,...bindings],{runtimeState:plan.runtime_state,speechAct:plan.speech_act,scopes:plan.scopes,anchor});
 return {...result,source_input:input,construction:'local_adjective_predication'};
}
