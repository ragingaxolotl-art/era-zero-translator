import {midiFromFormal} from './engine.mjs';
import {decodeSupportedMeaningWithDrafts} from './semantic_music_dispatch.mjs';
// Resolve an object-directed desire only through an explicit desired proposition.
// Reuses the existing intensional desire grammar and all its musical conventions.
import {parseFoundationSentence,composeFoundationSentence} from './foundation_sentences.mjs';
import {parseNominal} from './nominals.mjs';
import {encodeName} from './names.mjs';
export function objectDesirePlan(input){
 const parsed=parseFoundationSentence(input);if(parsed?.type!=='desire')return null;
 const object=parsed.content,nominal=parseNominal(object);
 const bare=/^[a-z]+$/.test(object)&&! /^(it|them|him|her|us|me|this|that|something|nothing|everything)$/.test(object);
 const name=/^[A-Z][a-z]+$/.test(object)||/^"[^"\n]+"$/.test(object);
 if((!nominal&&!bare&&!name)||nominal?.quantifier)return null;
 return {parsed,object,reference_mode:nominal?.mode||(name?'name':'unspecified_nominal'),head:nominal?.head||(object.startsWith('"')?object.slice(1,-1):object),required:'explicit_desired_proposition',automatic_relation:null};
}
export async function composeObjectDesire(input,authority,records,loadTemplate,{allowDraft=false,desiredProposition}={}){
 if(!allowDraft)throw new Error('Object desire requires draft opt-in.');
 const plan=objectDesirePlan(input);if(!plan)throw new Error('Unsupported object desire.');
 if(typeof desiredProposition!=='string'||!desiredProposition.trim())throw new Error('Specify what is desired to happen concerning this object. No drinking or ownership reading is assumed.');
 const content=desiredProposition.trim().replace(/\.$/,'');
 if(/[!?\n]/.test(content))throw new Error('Supply a declarative desired proposition.');
 // Replace only the object span; preserve the outer question, negation, time and runtime.
 const source=input.trim().replace(/\s*\[[012]\][.!?]?$/,'').replace(/[.!?]$/,'').trim();
 const at=source.lastIndexOf(plan.object);
 const resolved=source.slice(0,at)+content+source.slice(at+plan.object.length)+` [${plan.parsed.state}]`+(plan.parsed.speechAct==='question'?'?':'.');
 const outer=parseFoundationSentence(resolved);
 for(const key of ['holder','state','speechAct','negated','speechTime','calendarDay'])if(outer?.[key]!==plan.parsed[key])throw new Error('Clarification changed the outer desire scope.');
 const result=await composeFoundationSentence(resolved,authority,records,loadTemplate,{allowDraft:true});
 const expected=(await encodeName(plan.head)).normalized_label;
 const mentions=result.semantic_ir.nodes.filter(n=>n.node_id.startsWith('desired:')&&n.kind==='phonemic_reference'&&n.name?.normalized_label===expected&&(plan.reference_mode==='unspecified_nominal'?Boolean(n.reference_mode):(n.reference_mode||'name')===plan.reference_mode));
 if(!mentions.length)throw new Error('The desired proposition must explicitly identify the original object; unrelated outcomes cannot silently replace it.');
 try{await decodeSupportedMeaningWithDrafts(midiFromFormal(result.formal),authority.atoms,records,{allowDraft:true});}
 catch(cause){throw new Error('The selected outcome can be encoded but its complete musical meaning cannot yet be recovered. This translation remains unfinished.',{cause});}
 return {...result,source_input:input,resolved_input:resolved,object_desire_resolution:{object:plan.object,desired_proposition:content,relation_source:'explicit_user_clarification',matching_content_references:mentions.map(n=>n.node_id)}};
}
