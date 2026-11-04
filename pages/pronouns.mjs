import {parseNamedSentence,composeNamedSentence,parseSentenceConditional} from './sentences.mjs';
import {parseNominal} from './nominals.mjs';

// A referent is supplied by the reader for each occurrence. No gender, identity,
// animacy or coreference is inferred from a name or from another pronoun.
export function pronounInterpretationPlan(input){
 if(typeof input!=='string'||parseNamedSentence(input)||parseSentenceConditional(input))return null;
 const occurrences=[];let quoted=false;
 for(let i=0;i<input.length;){
  if(input[i]==='"'){quoted=!quoted;i++;continue;}
  const match=!quoted&&(i===0||!/[A-Za-z]/.test(input[i-1]))?input.slice(i).match(/^(she|he|her|him|it)\b/i):null;
  if(match&&/^it is (?:(?:not )?(?:possible|necessary) that|not the case that)\b/i.test(input.slice(i))){i+=match[0].length;continue;}
  if(match){occurrences.push({key:`ref${occurrences.length}`,pronoun:match[0],start:i,end:i+match[0].length});i+=match[0].length;}else i++;
 }
 if(quoted||!occurrences.length||occurrences.length>16)return null;
 const substitute=values=>{let text=input;for(const o of [...occurrences].reverse())text=text.slice(0,o.start)+values[o.key]+text.slice(o.end);return text;};
 const placeholders=Object.fromEntries(occurrences.map((o,i)=>[o.key,`"reference ${String.fromCharCode(97+i)}"`]));
 const parsed=parseNamedSentence(substitute(placeholders));
 if(!parsed)return null;
 return {input,occurrences,parsed};
}
export function validReferent(value){
 if(typeof value!=='string'||value.length>200||value!==value.trim())return false;
 if(['I','me','you'].includes(value))return true;
 const nominal=parseNominal(value);if(nominal)return !nominal.quantifier;
 return /^(?!(?:She|He|It|They|We|Her|Him|Them|Us)\b)[A-Z][a-z]+$/.test(value)||/^"[A-Za-z]+(?:[ -][A-Za-z]+)*"$/.test(value);
}
export async function composePronounSentence(input,loadTemplate,bindings,options={}){
 const plan=pronounInterpretationPlan(input);if(!plan)throw new Error('This sentence does not support explicit pronoun resolution yet.');
 if(!bindings||typeof bindings!=='object'||Array.isArray(bindings)||Object.keys(bindings).length!==plan.occurrences.length||plan.occurrences.some(o=>!Object.hasOwn(bindings,o.key)||!validReferent(bindings[o.key]))){
  const e=new Error('Identify every pronoun with a name, a quoted name, a noun reference such as “the robot” or “this lamp”, or I/you.');e.code='pronoun_referents_required';throw e;
 }
 if(!options||typeof options!=='object'||Array.isArray(options)||Object.keys(options).some(key=>!['interpretation','standard','viewpoint','destination'].includes(key)))throw new Error('Invalid sentence interpretation choices.');
 const selectedOptions=structuredClone(options);
 const chosen=Object.fromEntries(plan.occurrences.map(o=>[o.key,bindings[o.key]]));
 let resolved=input;for(const o of [...plan.occurrences].reverse())resolved=resolved.slice(0,o.start)+chosen[o.key]+resolved.slice(o.end);
 // Substitution may expose a forbidden identity (e.g. carrier equals load).
 const parsed=parseNamedSentence(resolved);if(!parsed)throw new Error('These referents do not form a valid interpretation of the whole sentence.');
 const result=await composeNamedSentence(resolved,await loadTemplate(parsed.predicate),selectedOptions);
 return {...result,source_input:input,resolved_input:resolved,resolved_pronouns:plan.occurrences.map(o=>({pronoun:o.pronoun,start:o.start,end:o.end,referent:chosen[o.key]})),semantic_note:[result.semantic_note,'Pronoun referents were explicitly supplied for this sentence. Their names do not assert gender or establish general discourse inference.'].filter(Boolean).join(' ')};
}
