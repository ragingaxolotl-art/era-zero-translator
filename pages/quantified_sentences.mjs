import {parseNamedSentence,composeNamedSentence} from './sentences.mjs';
import {NOMINAL_PATTERN,parseNominal} from './nominals.mjs';
import {validateQuantifiedBindings} from './quantified_binding.mjs';
import {canonicalDigest} from './engine.mjs';
const properties='(?:physically energized|damaged|impaired|restored|conscious|dormant)';
export function parseQuantifiedPropertySentence(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),state='';const runtime=text.match(/\s+\[([012])\]([.!?]?)$/);
 if(runtime){const punctuation=text.slice(0,runtime.index).match(/[.!?]$/)?.[0];if(punctuation&&runtime[2]&&punctuation!==runtime[2])return null;state=` [${runtime[1]}]`;text=text.slice(0,runtime.index)+(punctuation?'':runtime[2]);}
 const outer=text.match(/^[Ii]t is not the case that (.+)$/);if(outer)text=outer[1];
 const question=text.endsWith('?');
 const m=text.match(new RegExp(question?`^[Aa]re (${NOMINAL_PATTERN}) (not )?(${properties})[?]$`:`^(${NOMINAL_PATTERN}) (?:is|are) (not )?(${properties})[.]?$`));
 if(!m||!parseNominal(m[1])?.quantifier||outer&&question)return null;
 const baseInput=(question?`Are ${m[1]} ${m[3]}?`:`${m[1]} are ${m[3]}.`)+state,parsed=parseNamedSentence(baseInput);
 if(!parsed||parsed.role!=='bearer'||parsed.compoundSlots)return null;
 return {baseInput,parsed,predicateNegated:!!m[2],propositionNegated:!!outer};
}
export async function composeQuantifiedPropertySentence(input,loadTemplate,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Counted-predicate translation requires explicit draft opt-in.');
 const plan=parseQuantifiedPropertySentence(input);if(!plan)throw new Error('Unsupported counted-property sentence.');
 const base=await composeNamedSentence(plan.baseInput,await loadTemplate(plan.parsed.predicate)),formal=structuredClone(base.formal),ir=formal.semantic_ir;
 const q=ir.nodes.find(n=>n.operator==='quantifier'),role=ir.edges.find(e=>e.from===q.node_id&&e.type==='fills_role'),scope=ir.edges.find(e=>e.to===q.node_id&&e.type==='scopes'),restriction=scope.from;
 q.operator='quantified_predication';role.from='bound';scope.from='p';ir.edges.find(e=>e.type==='centers').from=q.node_id;
 ir.nodes.push({node_id:'bound',kind:'quantified_reference',binder_id:q.node_id,value_type:'entity'});
 ir.edges.push({edge_id:'restriction',type:'restricts',from:restriction,to:q.node_id});
 if(plan.predicateNegated){ir.nodes.push({node_id:'negative_property',kind:'scope_operator',operator:'negation'});scope.from='negative_property';ir.edges.push({edge_id:'negative_property',type:'scopes',from:'p',to:'negative_property'});}
 if(plan.propositionNegated){ir.nodes.push({node_id:'negative_count',kind:'scope_operator',operator:'negation'});ir.edges.find(e=>e.type==='centers').from='negative_count';ir.edges.push({edge_id:'negative_count',type:'scopes',from:q.node_id,to:'negative_count'});}
 validateQuantifiedBindings(ir);
 delete ir.utterance_id;delete ir.serialization;const digest=await canonicalDigest(ir);ir.utterance_id=`UTT:${digest.slice(0,24)}`;ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};
 const structural=ir.edges.slice().sort((a,b)=>a.edge_id<b.edge_id?-1:a.edge_id>b.edge_id?1:0).map(e=>({edge_id:e.edge_id,edge_type:e.type,from:e.from,to:e.to,...e.role?{role:e.role}:{},...e.relation?{relation:e.relation}:{},boundary:e.type==='fills_role'?'short_gap':'medium_gap',boundary_beats:e.type==='fills_role'?.5:1}));
 formal.performance.structural_events=structural;
 const p=formal.performance,relative=p.lexical_events.map(({base_midi,family_opening_absolute_midi,address_absolute_midi,...event})=>({...event,runtime_tail:event.runtime_tail?Object.fromEntries(Object.entries(event.runtime_tail).filter(([key])=>key!=='absolute_note')):null}));
 const relativePlan={primary_contour:p.primary_contour,contour_relative_semitones:p.contour_relative_semitones,secondary_contours:p.secondary_contours,lexical_events:relative,structural_events:structural,statement_boundary:p.statement_boundary,statement_boundary_beats:p.statement_boundary_beats};
 const formalDigest=await canonicalDigest({semantic_digest:digest,relative_plan:relativePlan});Object.assign(formal,{formal_id:`EZF:${formalDigest.slice(0,24)}`,formal_digest:formalDigest,semantic_digest:digest,draft_quantified:true});
 return {...base,source_input:input,status:'draft_quantified_translation',grammar:{profile:'EZCOUNT-BIND-1',music_profile:'EZCOUNT-MUSIC-1',status:'draft'},construction:'counted_property',interpretation:input,semantic_note:(base.semantic_note?base.semantic_note+' ':'')+'Counts members of the contextual noun class satisfying the scoped property. Predicate negation and negation of the whole count are distinct. No real-world count is inferred from the noun label or runtime state.',semantic_ir:ir,formal};
}
