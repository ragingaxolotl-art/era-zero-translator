import {canonicalDigest,sha256} from './engine.mjs';
import {validateKnowledgeAcquisition} from './knowledge_acquisition.mjs';
import {renderLexicalOccurrences,lexicalGloss} from './bound_compounds.mjs';
import {midiFromKnowledgeAcquisition} from './knowledge_acquisition_music.mjs';
// Regenerate the result performance from meaning and shared authority. Bundles
// never accept a caller-supplied event list as the authoritative performance.
export async function renderAcquisitionResult(document,authority,{allowDraft=false}={}){
 document=await validateKnowledgeAcquisition(document,{allowDraft});
 const ir=document.result_state,records=document.vocabulary;
 const events=await renderLexicalOccurrences(ir,authority,{foundationRecords:records,allowDraftFoundations:true});
 const structural=ir.edges.slice().sort((a,b)=>a.edge_id<b.edge_id?-1:a.edge_id>b.edge_id?1:0).map(e=>({edge_id:e.edge_id,edge_type:e.type,from:e.from,to:e.to,...(e.role?{role:e.role}:{}),...(e.relation?{relation:e.relation}:{}),boundary:e.type==='fills_role'?'short_gap':'medium_gap',boundary_beats:e.type==='fills_role'?.5:1}));
 const performance={profile:'reference-midi-v1',anchor_midi:60,transposition_semantically_significant:false,primary_contour:'level',contour_relative_semitones:[0,0],secondary_contours:[],lexical_events:events,structural_events:structural,statement_boundary:'long_gap',statement_boundary_beats:2};
 const relative=events.map(({base_midi,family_opening_absolute_midi,address_absolute_midi,...e})=>({...e,runtime_tail:e.runtime_tail?Object.fromEntries(Object.entries(e.runtime_tail).filter(([k])=>k!=='absolute_note')):null}));
 const relativePlan={primary_contour:'level',contour_relative_semitones:[0,0],secondary_contours:[],lexical_events:relative,structural_events:structural,statement_boundary:'long_gap',statement_boundary_beats:2};
 const digest=await canonicalDigest({semantic_digest:ir.serialization.content_digest,relative_plan:relativePlan});
 return {format:'EZF-1',renderer_version:'1.0.0',formal_id:`EZF:${digest.slice(0,24)}`,formal_digest:digest,semantic_digest:ir.serialization.content_digest,semantic_ir:ir,performance,literal_gloss:events.map(e=>e.kind==='foundation'?`${e.occurrence_id}:${records.find(r=>r.foundation_id===e.target_id).display_title}[${e.runtime_tail.code}]`:lexicalGloss([e],authority)).join(' | ')};
}
const authorityDigest=authority=>canonicalDigest({atoms:authority.atoms,compounds:authority.compounds,compound_plans:authority.compound_plans});
export async function createAcquisitionBundle(resolution,authority,{allowDraft=false}={}){
 const acquisition=await validateKnowledgeAcquisition(resolution.acquisition,{allowDraft});
 const formal=await renderAcquisitionResult(acquisition,authority,{allowDraft:true}),midi=await midiFromKnowledgeAcquisition(acquisition,formal,authority,{allowDraft:true});
 const body={format:'EZACQB-1',version:'1.0.0',status:'draft',source:resolution.source_input||'',authority_digest:await authorityDigest(authority),acquisition,midi_sha256:await sha256(midi)};
 return {...body,bundle_digest:await canonicalDigest(body)};
}
export async function verifyAcquisitionBundle(input,authority,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Acquisition bundle verification requires draft opt-in.');
 const bundle=structuredClone(input),fields=['format','version','status','source','authority_digest','acquisition','midi_sha256','bundle_digest'];
 if(!bundle||fields.some(k=>!Object.hasOwn(bundle,k))||Object.keys(bundle).some(k=>!fields.includes(k))||bundle.format!=='EZACQB-1'||bundle.version!=='1.0.0'||bundle.status!=='draft'||typeof bundle.source!=='string')throw new Error('Invalid acquisition bundle.');
 const {bundle_digest,...body}=bundle;
 if(await canonicalDigest(body)!==bundle_digest)throw new Error('Acquisition bundle digest mismatch.');
 if(await authorityDigest(authority)!==bundle.authority_digest)throw new Error('Acquisition bundle authority differs.');
 const regenerated=await createAcquisitionBundle({acquisition:bundle.acquisition,source_input:bundle.source},authority,{allowDraft:true});
 if(regenerated.midi_sha256!==bundle.midi_sha256)throw new Error('Acquisition music differs from regenerated meaning.');
 return {status:'valid',format:'EZACQB-1',grammar_status:'draft',acquisition_id:bundle.acquisition.acquisition_id,midi_sha256:bundle.midi_sha256,limitations:['Source text is descriptive metadata, not independently verified interpretation.','Browser binding/identity validation supplements full Ruby semantic validation.']};
}
