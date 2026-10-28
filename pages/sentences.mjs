import {canonicalDigest} from './engine.mjs';
import {encodeName, notesForName} from './names.mjs';

// Reviewed constructions use exact process senses, never a generic synonym pool.
const ACTIONS = [
  {pattern:'(?:cares for|is caring for)', predicate:'LIF:211', key:'active_care', gloss:'active care', wording:'actively cares for'},
  {pattern:'is awakening', predicate:'LIF:111', key:'active_other_awakening', gloss:'actively awaken another', wording:'is awakening'},
  {pattern:'is restoring', predicate:'REP:111', key:'active_target_restoration', gloss:'active target restoration', wording:'is restoring'},
  {pattern:'is damaging', predicate:'WRN:111', key:'active_target_impairment', gloss:'active target impairment', wording:'is damaging'}
];
export function parseNamedSentence(input) {
  for(const action of ACTIONS){
    const match=String(input).trim().match(new RegExp(`^([A-Z][a-z]+) ${action.pattern} ([A-Z][a-z]+)[.]?$`));
    if(match)return {actor:match[1],target:match[2],...action,construction:`named_${action.key}`};
  }
  return null;
}

// Recognize the construction family even when additional meaning makes its
// current complete parser decline. The legacy keyword path may still offer
// dictionary readings, but must not present one as the complete sentence.
export function needsSentenceComposition(input) {
  return /\b(?:(?:care|cares|caring)\s+for|awakening|restoring|damaging)\b/i.test(String(input)) && !parseNamedSentence(input);
}

export async function composeNamedSentence(input,template) {
  const parsed=parseNamedSentence(input);
  if(!parsed)throw new Error('The complete sentence does not match this construction.');
  const source=template.formal;
  if(source.semantic_ir.speech_act!=='assertion' || source.performance.anchor_midi!==60 || source.performance.lexical_events.length!==1 || source.performance.lexical_events[0].target_id!==parsed.predicate || source.performance.lexical_events[0].runtime_tail?.code!==1)
    throw new Error('Expected the matching canonical action assertion template at anchor 60.');
  const names=await Promise.all([encodeName(parsed.actor),encodeName(parsed.target)]);
  const references=names.map((name,index)=>({node_id:index?'b':'a',kind:'phonemic_reference',referent_id:name.name_id,value_type:'entity',name}));
  const ir={ir_version:'1.0',root_clause:'c',speech_act:'assertion',nodes:[{node_id:'c',kind:'clause',clause_type:'predication'},
    {node_id:'p',kind:'lexical_occurrence',target_type:'atom',target_id:parsed.predicate,runtime_state:{code:1}},...references],
    edges:[{edge_id:'e0',type:'centers',from:'p',to:'c'},{edge_id:'e1',type:'fills_role',from:'a',to:'p',role:'actor'},{edge_id:'e2',type:'fills_role',from:'b',to:'p',role:'target'}],discourse_constraints:{}};
  const digest=await canonicalDigest(ir);
  ir.utterance_id=`UTT:${digest.slice(0,24)}`;
  ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};
  const events=names.map((name,index)=>{
    const offset=index?12:-12,notes=notesForName(name);
    return {kind:'phonemic_label',occurrence_id:index?'b':'a',target_id:name.name_id,referent_id:name.name_id,label:name.normalized_label,semantic_claim:false,
      register:index?'high':'low',base_midi:60+offset,family_qualified_transliteration:name.normalized_label,formal_carrier:'',
      family_opening_relative_semitones:[],family_opening_absolute_midi:[],address_relative_semitones:notes.map(note=>note-60),address_absolute_midi:notes.map(note=>note+offset),note_duration_beats:1};
  });
  events.push({...structuredClone(source.performance.lexical_events[0]),occurrence_id:'p'});
  const structural=ir.edges.map(edge=>({edge_id:edge.edge_id,edge_type:edge.type,from:edge.from,to:edge.to,...(edge.role?{role:edge.role}:{}),boundary:edge.type==='fills_role'?'short_gap':'medium_gap',boundary_beats:edge.type==='fills_role'?.5:1}));
  const performance={...structuredClone(source.performance),lexical_events:events,structural_events:structural};
  const relative=events.map(event=>{
    const {base_midi,family_opening_absolute_midi,address_absolute_midi,...copy}=event;
    copy.runtime_tail=event.runtime_tail?Object.fromEntries(Object.entries(event.runtime_tail).filter(([key])=>key!=='absolute_note')):null;
    return copy;
  });
  const relativePlan={primary_contour:performance.primary_contour,contour_relative_semitones:performance.contour_relative_semitones,secondary_contours:performance.secondary_contours,
    lexical_events:relative,structural_events:structural,statement_boundary:performance.statement_boundary,statement_boundary_beats:performance.statement_boundary_beats};
  const formalDigest=await canonicalDigest({semantic_digest:digest,relative_plan:relativePlan});
  const formal={format:'EZF-1',renderer_version:'1.0.0',formal_id:`EZF:${formalDigest.slice(0,24)}`,formal_digest:formalDigest,semantic_digest:digest,semantic_ir:ir,performance,
    literal_gloss:`a:name(${names[0].normalized_label}) | b:name(${names[1].normalized_label}) | p:${parsed.gloss}[1]`};
  return {source_input:input,target_id:parsed.predicate,sense_id:`construction:${parsed.construction}`,surface_fidelity:'complete_construction',controlled_input:'',semantic_ir:ir,formal,
    construction:parsed.construction,interpretation:`${parsed.actor} ${parsed.wording} ${parsed.target}.`};
}
