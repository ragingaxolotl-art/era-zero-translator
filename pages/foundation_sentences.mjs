import {canonicalDigest} from './engine.mjs';
import {encodeName} from './names.mjs';
import {deicticReference} from './references.mjs';
import {parseNominal} from './nominals.mjs';
import {parseNamedSentence,composeNamedSentence} from './sentences.mjs';
import {validateFoundations} from './foundations.mjs';
import {renderLexicalOccurrences,lexicalGloss} from './bound_compounds.mjs';
const HOLDER='(?:I|[Yy]ou|[A-Z][a-z]+|"[^"\\n]+"|[Tt]he [a-z]+)';
export function parseFoundationSentence(input){
 if(typeof input!=='string')return null;
 let text=input.trim(),state=1;const question=text.endsWith('?');const runtime=text.match(/\s*\[([012])\][.!?]?$/);
 if(runtime){state=Number(runtime[1]);text=text.slice(0,runtime.index).trim();}
 text=text.replace(/[.!?]$/,'').trim();
 let m=text.match(new RegExp(`^(${HOLDER}) (prefers|prefer|does not prefer|do not prefer) (.+) to (.+)$`));
 if(!m&&question){const q=text.match(new RegExp(`^(?:Does|Do) (${HOLDER}) (not )?prefer (.+) to (.+)$`));if(q)m=[q[0],q[1],q[2]?'does not prefer':'prefer',q[3],q[4]];}
 if(m)return {type:'preference',holder:m[1],target:m[3],standard:m[4],negated:m[2].includes('not'),speechAct:question?'question':'assertion',state};
 m=text.match(new RegExp(`^(${HOLDER}) (wants|want|does not want|do not want) (?:that )?(.+)$`));
 if(!m&&question){const q=text.match(new RegExp(`^(?:Does|Do) (${HOLDER}) (not )?want (.+)$`));if(q)m=[q[0],q[1],q[2]?'does not want':'want',q[3]];}
 if(m)return {type:'desire',holder:m[1],content:m[3],negated:m[2].includes('not'),speechAct:question?'question':'assertion',state};
 return null;
}
async function reference(text,id,allowKind=false){
 if(['I','me'].includes(text))return deicticReference('speaker',id);
 if(/^[Yy]ou$/.test(text))return deicticReference('addressee',id);
 const nominal=parseNominal(text),quoted=/^"[^"\n]+"$/.test(text),proper=/^[A-Z][a-z]+$/.test(text);
 const kind=allowKind&&/^[a-z]+$/.test(text)&&parseNominal('the '+text);
 if(!quoted&&!proper&&!nominal&&!kind)throw new Error('This participant needs a supported noun label or explicit referent.');
 if(nominal?.quantifier)throw new Error('Quantified alternatives require additional interpretation.');
 const mode=nominal?.mode||(kind?'nominal_class':null),name=await encodeName(nominal?.head||(quoted?text.slice(1,-1):text));
 return {node_id:id,kind:'phonemic_reference',value_type:'entity',name,referent_id:mode?`nominal:${mode==='nominal_class'?'class':'definite'}:${name.name_id}`:`name:${name.name_id}`,...(mode?{reference_mode:mode}:{})};
}
export async function composeFoundationSentence(input,authority,records,loadTemplate,{allowDraft=false}={}){
 records=await validateFoundations(records,{allowDraft});const parsed=parseFoundationSentence(input);
 if(!parsed)throw new Error('Unsupported foundation sentence.');
 const definition=records.find(r=>r.sound_code===(parsed.type==='desire'?0:1));
 if(!definition)throw new Error('Missing reviewed foundation definition.');
 const ir={ir_version:'1.0.0',root_clause:'c',speech_act:parsed.speechAct,nodes:[{node_id:'c',kind:'clause',clause_type:'simple'},{node_id:'p',kind:'lexical_occurrence',target_type:'foundation',target_id:definition.foundation_id,foundation_version:definition.definition_version,runtime_state:{code:parsed.state}},await reference(parsed.holder,'holder')],edges:[{edge_id:'center',type:'centers',from:'p',to:'c'},{edge_id:'holder',type:'fills_role',from:'holder',to:'p',role:'experiencer'}],discourse_constraints:{}};
 if(parsed.type==='preference'){
  ir.nodes.push(await reference(parsed.target,'preferred',true),await reference(parsed.standard,'standard',true));
  for(const [id,role] of [['preferred','target'],['standard','comparison_standard']])ir.edges.push({edge_id:id,type:'fills_role',from:id,to:'p',role});
 }else{
  const infinitive=parsed.content.match(new RegExp(`^(${HOLDER}) to care for (.+)$`));
  const content=infinitive?`${infinitive[1]} ${/^(?:I|[Yy]ou)$/.test(infinitive[1])?'care':'cares'} for ${infinitive[2]}`:parsed.content;
  const inner=parseNamedSentence(content);
  if(!inner||inner.speechAct==='question'||inner.speechAct==='command')throw new Error('Specify the desired proposition; an object alone does not determine whether you mean drinking, possessing, or something else.');
  const composed=await composeNamedSentence(content,await loadTemplate(inner.predicate));
  const source=composed.semantic_ir;
  for(const n of source.nodes){const copy=structuredClone(n);copy.node_id='desired:'+n.node_id;if(copy.compound_bindings)copy.compound_bindings=copy.compound_bindings.map(b=>({...b,argument_id:'desired:'+b.argument_id}));if(n.node_id===source.root_clause)Object.assign(copy,{clause_type:'content',content_status:'intensional',value_type:'proposition'});ir.nodes.push(copy);}
  for(const e of source.edges)ir.edges.push({...e,edge_id:'desired:'+e.edge_id,from:'desired:'+e.from,to:'desired:'+e.to});
  ir.edges.push({edge_id:'content',type:'fills_role',from:'desired:'+source.root_clause,to:'p',role:'content'});
 }
 if(parsed.negated){ir.nodes.push({node_id:'neg',kind:'scope_operator',operator:'negation'});ir.edges[0].from='neg';ir.edges.push({edge_id:'neg',type:'scopes',from:'p',to:'neg'});}
 const digest=await canonicalDigest(ir);ir.utterance_id='UTT:'+digest.slice(0,24);ir.serialization={canonical_format:'EZIR-JSON-1',content_digest:digest};
 const events=await renderLexicalOccurrences(ir,authority,{foundationRecords:records,allowDraftFoundations:allowDraft});
 const structural=ir.edges.slice().sort((a,b)=>a.edge_id<b.edge_id?-1:a.edge_id>b.edge_id?1:0).map(e=>({edge_id:e.edge_id,edge_type:e.type,from:e.from,to:e.to,...(e.role?{role:e.role}:{}),...(e.relation?{relation:e.relation}:{}),boundary:e.type==='fills_role'?'short_gap':'medium_gap',boundary_beats:e.type==='fills_role'?.5:1}));
 const performance={profile:'reference-midi-v1',anchor_midi:60,transposition_semantically_significant:false,primary_contour:parsed.speechAct==='question'?'rising':'level',contour_relative_semitones:parsed.speechAct==='question'?[0,2]:[0,0],secondary_contours:[],lexical_events:events,structural_events:structural,statement_boundary:'long_gap',statement_boundary_beats:2};
 const relative=events.map(e=>{const {base_midi,family_opening_absolute_midi,address_absolute_midi,...copy}=e;copy.runtime_tail=e.runtime_tail?Object.fromEntries(Object.entries(e.runtime_tail).filter(([k])=>k!=='absolute_note')):null;return copy;});
 const relativePlan={primary_contour:performance.primary_contour,contour_relative_semitones:performance.contour_relative_semitones,secondary_contours:[],lexical_events:relative,structural_events:structural,statement_boundary:'long_gap',statement_boundary_beats:2};
 const formalDigest=await canonicalDigest({semantic_digest:digest,relative_plan:relativePlan});
 const gloss=events.map(e=>e.kind==='foundation'?`${e.occurrence_id}:${definition.display_title}[${e.runtime_tail.code}]`:lexicalGloss([e],authority)).join(' | ');
 return {vocabulary:{profile:'EZFOUND-1',status:definition.status,records},source_input:input,target_id:definition.foundation_id,construction:'foundation_'+parsed.type,sense_id:'foundation:'+parsed.type,controlled_input:'',status:definition.status==='candidate'?'candidate_translation':'translated',semantic_ir:ir,formal:{format:'EZF-1',renderer_version:'1.0.0',formal_id:'EZF:'+formalDigest.slice(0,24),formal_digest:formalDigest,semantic_digest:digest,semantic_ir:ir,performance,literal_gloss:gloss}};
}
