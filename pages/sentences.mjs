import {canonicalDigest} from './engine.mjs';
import {encodeName, notesForName} from './names.mjs';

// Reviewed constructions use exact process senses, never a generic synonym pool.
const ACTIONS = [
  {pattern:'is moving toward', predicate:'MOV:111', key:'active_target_approach', wording:'is moving toward', targetRole:'destination'},
  {pattern:'is moving away from', predicate:'MOV:101', key:'active_source_departure', wording:'is moving away from', targetRole:'source'},
  {pattern:'is moving relative to', predicate:'MOV:121', key:'active_shared_frame_movement', wording:'is moving relative to', targetRole:'environment'},
  {pattern:'(?:cares for|is caring for)', predicate:'LIF:211', key:'active_care', gloss:'active care', wording:'actively cares for'},
  {pattern:'is awakening', predicate:'LIF:111', key:'active_other_awakening', gloss:'actively awaken another', wording:'is awakening'},
  {pattern:'is restoring', predicate:'REP:111', key:'active_target_restoration', gloss:'active target restoration', wording:'is restoring'},
  {pattern:'is damaging', predicate:'WRN:111', key:'active_target_impairment', gloss:'active target impairment', wording:'is damaging'},
  {pattern:'is physically repairing', predicate:'CMP:2816a7eeb356c2148b26beca', key:'ongoing_physical_repair', wording:'is physically repairing'}
];
const DESCRIPTIONS = [
  {pattern:'conscious', predicate:'LIF:011', key:'conscious_other', wording:'is conscious'},
  {pattern:'dormant', predicate:'LIF:012', key:'dormant_other', wording:'is dormant'}
];
export function parseNamedSentence(input, depth=0) {
  if(depth>16)return null;
  const modal=String(input).trim().match(/^[Ii]t is (not )?(possible|necessary) that (.+)$/);
  if(modal){
    const inner=parseNamedSentence(modal[3],depth+1);
    if(!inner)return null;
    const scopes=[...(inner.scopes||[]),{operator:'modality',mode:modal[2]}];
    if(modal[1])scopes.push({operator:'negation'});
    return {...inner,scopes,construction:`scoped_${inner.construction}`,explicitInterpretation:String(input).trim().replace(/\.$/,'')+'.'};
  }
  const participant='([A-Z][a-z]+|"[A-Za-z]+(?:[ -][A-Za-z]+)*")';
  for(const action of ACTIONS){
    for(const negated of [false,true]){
      const pattern=negated?(action.key==='active_care'?'(?:does not care for|is not caring for)':action.pattern.replace('is ','is not ')):action.pattern;
      const match=String(input).trim().match(new RegExp(`^${participant} ${pattern} ${participant}[.]?$`));
      if(match)return {actor:match[1].replaceAll('"',''),target:match[2].replaceAll('"',''),actorText:match[1],targetText:match[2],...action,negated,construction:`named_${action.key}${negated?'_negated':''}`};
    }
  }
  for(const description of DESCRIPTIONS){
    const match=String(input).trim().match(new RegExp(`^${participant} is (not )?${description.pattern}[.]?$`));
    if(match)return {actor:match[1].replaceAll('"',''),actorText:match[1],...description,role:'bearer',negated:!!match[2],construction:`named_${description.key}${match[2]?'_negated':''}`};
  }
  return null;
}

// Recognize the construction family even when additional meaning makes its
// current complete parser decline. The legacy keyword path may still offer
// dictionary readings, but must not present one as the complete sentence.
export function needsSentenceComposition(input) {
  return /\b(?:it\s+is\s+(?:not\s+)?(?:possible|necessary)\s+that|(?:care|cares|caring)\s+for|awakening|restoring|damaging|repairing|moving|conscious|dormant)\b/i.test(String(input)) && !parseNamedSentence(input);
}

export function parseSentenceSequence(input) {
  const text=String(input).trim().replace(/\.$/,'');
  let quoted=false,start=0;const clauses=[];
  for(let i=0;i<text.length;i++){
    if(text[i]==='"')quoted=!quoted;
    if(!quoted){
      const match=text.slice(i).match(/^(?:,\s*|\s+)then\s+/);
      if(match){clauses.push(text.slice(start,i).trim());i+=match[0].length-1;start=i+1;}
    }
  }
  if(quoted||!clauses.length)return null;
  // Without explicit grouping a leading modal can scope one clause or the
  // entire sequence. Do not guess that attachment.
  if(/^[Ii]t is (?:not )?(?:possible|necessary) that /.test(text))return null;
  clauses.push(text.slice(start).trim());
  if(clauses.length>32||clauses.some(clause=>!parseNamedSentence(clause)))return null;
  return clauses;
}

export async function composeSentenceSequence(input,loadTemplate) {
  const clauses=parseSentenceSequence(input);
  if(!clauses)throw new Error('Every clause in the sequence must have a complete interpretation.');
  const parts=await Promise.all(clauses.map(async clause=>composeNamedSentence(clause,await loadTemplate(parseNamedSentence(clause).predicate))));
  const ir={ir_version:'1.0',root_clause:'c',speech_act:'assertion',nodes:[{node_id:'c',kind:'clause',clause_type:'predication'},{node_id:'sequence',kind:'coordination',operator:'sequence'}],
    edges:[{edge_id:'e0',type:'centers',from:'sequence',to:'c'}],discourse_constraints:{}};
  const events=[],gloss=[];
  parts.forEach((part,index)=>{
    const prefix=`s${String(index).padStart(3,'0')}_`;
    ir.nodes.push(...part.semantic_ir.nodes.map(node=>({...structuredClone(node),node_id:prefix+node.node_id})));
    ir.edges.push(...part.semantic_ir.edges.map(edge=>({...edge,edge_id:prefix+edge.edge_id,from:prefix+edge.from,to:prefix+edge.to})));
    ir.edges.push({edge_id:`member${index}`,type:'member_of',from:prefix+'c',to:'sequence',order:index+1});
    events.push(...part.formal.performance.lexical_events.map(event=>({...structuredClone(event),occurrence_id:prefix+event.occurrence_id})));
    gloss.push(part.formal.literal_gloss.split(' | ').map(value=>prefix+value).join(' | '));
  });
  const digest=await canonicalDigest(ir);
  ir.utterance_id=`UTT:${digest.slice(0,24)}`;ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};
  const structural=ir.edges.slice().sort((a,b)=>a.edge_id<b.edge_id?-1:a.edge_id>b.edge_id?1:0).map(edge=>({edge_id:edge.edge_id,edge_type:edge.type,from:edge.from,to:edge.to,...(edge.role?{role:edge.role}:{}),boundary:edge.type==='fills_role'?'short_gap':'medium_gap',boundary_beats:edge.type==='fills_role'?.5:1}));
  const performance={...structuredClone(parts[0].formal.performance),lexical_events:events,structural_events:structural};
  const relative=events.map(event=>{
    const {base_midi,family_opening_absolute_midi,address_absolute_midi,...copy}=event;
    copy.runtime_tail=event.runtime_tail?Object.fromEntries(Object.entries(event.runtime_tail).filter(([key])=>key!=='absolute_note')):null;
    return copy;
  });
  const relativePlan={primary_contour:performance.primary_contour,contour_relative_semitones:performance.contour_relative_semitones,secondary_contours:performance.secondary_contours,lexical_events:relative,structural_events:structural,statement_boundary:performance.statement_boundary,statement_boundary_beats:performance.statement_boundary_beats};
  const formalDigest=await canonicalDigest({semantic_digest:digest,relative_plan:relativePlan});
  const formal={format:'EZF-1',renderer_version:'1.0.0',formal_id:`EZF:${formalDigest.slice(0,24)}`,formal_digest:formalDigest,semantic_digest:digest,semantic_ir:ir,performance,literal_gloss:gloss.join(' | ')};
  return {source_input:input,target_id:'sequence',sense_id:'construction:explicit_sequence',surface_fidelity:'complete_construction',controlled_input:'',semantic_ir:ir,formal,construction:'explicit_sequence',interpretation:parts.map(part=>part.interpretation.replace(/\.$/,'')).join(', then ')+'.'};
}

export async function composeNamedSentence(input,template) {
  const parsed=parseNamedSentence(input);
  if(!parsed)throw new Error('The complete sentence does not match this construction.');
  const source=template.formal;
  const predicates=source.semantic_ir.nodes.filter(node=>node.kind==='lexical_occurrence');
  if(source.semantic_ir.speech_act!=='assertion' || source.semantic_ir.nodes.length!==2 || source.semantic_ir.edges.length!==1 || source.semantic_ir.edges[0].type!=='centers' || source.performance.anchor_midi!==60 || predicates.length!==1 || predicates[0].target_id!==parsed.predicate || predicates[0].runtime_state?.code!==1)
    throw new Error('Expected the matching canonical action assertion template at anchor 60.');
  const names=await Promise.all([parsed.actor,...(parsed.target?[parsed.target]:[])].map(label=>encodeName(label)));
  const references=names.map((name,index)=>({node_id:index?'b':'a',kind:'phonemic_reference',referent_id:name.name_id,value_type:'entity',name}));
  const ir={ir_version:'1.0',root_clause:'c',speech_act:'assertion',nodes:[{node_id:'c',kind:'clause',clause_type:'predication'},
    {node_id:'p',kind:'lexical_occurrence',target_type:predicates[0].target_type,target_id:parsed.predicate,runtime_state:{code:1}},...references],
    edges:[{edge_id:'e0',type:'centers',from:'p',to:'c'},{edge_id:'e1',type:'fills_role',from:'a',to:'p',role:parsed.role||'actor'},...(parsed.target?[{edge_id:'e2',type:'fills_role',from:'b',to:'p',role:parsed.targetRole||'target'}]:[])],discourse_constraints:{}};
  if(parsed.negated){
    ir.nodes.push({node_id:'neg',kind:'scope_operator',operator:'negation'});
    ir.edges[0].from='neg';
    ir.edges.push({edge_id:'e3',type:'scopes',from:'p',to:'neg'});
  }
  for(const [index,scope] of (parsed.scopes||[]).entries()){
    const id=`scope${String(index).padStart(2,'0')}`;
    ir.nodes.push({node_id:id,kind:'scope_operator',...scope});
    ir.edges.push({edge_id:`zscope${String(index).padStart(2,'0')}`,type:'scopes',from:ir.edges[0].from,to:id});
    ir.edges[0].from=id;
  }
  const digest=await canonicalDigest(ir);
  ir.utterance_id=`UTT:${digest.slice(0,24)}`;
  ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};
  const events=names.map((name,index)=>{
    const role=index?(parsed.targetRole||'target'):(parsed.role||'actor');
    const register=role==='environment'?'sustained_background':role==='bearer'?'middle':['actor','source'].includes(role)?'low':'high';
    const offset={low:-12,middle:0,high:12,sustained_background:-5}[register],notes=notesForName(name);
    return {kind:'phonemic_label',occurrence_id:index?'b':'a',target_id:name.name_id,referent_id:name.name_id,label:name.normalized_label,semantic_claim:false,
      register,base_midi:60+offset,family_qualified_transliteration:name.normalized_label,formal_carrier:'',
      family_opening_relative_semitones:[],family_opening_absolute_midi:[],address_relative_semitones:notes.map(note=>note-60),address_absolute_midi:notes.map(note=>note+offset),note_duration_beats:1};
  });
  events.push(...source.performance.lexical_events.map(event=>({...structuredClone(event),occurrence_id:'p'})));
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
    literal_gloss:`${names.map((name,index)=>`${index?'b':'a'}:name(${name.normalized_label})`).join(' | ')} | ${source.literal_gloss.replaceAll(`${predicates[0].node_id}:`,'p:').replaceAll(`${predicates[0].node_id}.`,'p.')}`};
  return {source_input:input,target_id:parsed.predicate,sense_id:`construction:${parsed.construction}`,surface_fidelity:'complete_construction',controlled_input:'',semantic_ir:ir,formal,
    construction:parsed.construction,interpretation:parsed.explicitInterpretation||`${parsed.actorText} ${parsed.negated?(parsed.key==='active_care'?'does not actively care for':parsed.wording.replace('is ','is not ')):parsed.wording}${parsed.targetText?' '+parsed.targetText:''}.`};
}
