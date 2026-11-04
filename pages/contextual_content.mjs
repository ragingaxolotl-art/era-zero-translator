// Contextual content is a reference, never proof of a cognitive predicate.
import {canonicalDigest} from './engine.mjs';
import {encodeName} from './names.mjs';
import {parseNominal} from './nominals.mjs';
import {deicticReference,NOMINAL_MODES} from './references.mjs';
import {CONTEXTUAL_CONTENT_KINDS} from './contextual_content_frames.mjs';
const exact=(v,fields)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===fields.length&&fields.every(k=>Object.hasOwn(v,k));
const fail=()=>{throw new Error('Invalid contextual content document or reference.');};
export async function contextualContentReference(text){
 if(typeof text!=='string')fail();text=text.trim();
 if(/^(?:I|me|you)$/i.test(text))return deicticReference(/^you$/i.test(text)?'addressee':'speaker','anchor');
 if(/^(?:he|she|it|they|we|him|her|them|us|this|that|these|those)$/i.test(text))fail();
 const nominal=parseNominal(text),quoted=/^"[^"\n]+"$/.test(text),proper=/^[A-Z][a-z]+$/.test(text);
 if((!nominal&&!quoted&&!proper)||nominal?.quantifier||nominal?.mode==='nominal_class')fail();
 const name=await encodeName(nominal?.head||(quoted?text.slice(1,-1):text)),mode=nominal?.mode;
 return {node_id:'anchor',kind:'phonemic_reference',value_type:'entity',name,referent_id:mode?`nominal:${NOMINAL_MODES[mode].id}:${name.name_id}`:`name:${name.name_id}`,...(mode?{reference_mode:mode}:{})};
}
export async function validateContextualContent(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Contextual content requires explicit draft opt-in.');
 document=structuredClone(document);
 if(!exact(document,['profile','status','content_kind','anchor','resolution_scope','assertion_commitment','content_id','content_digest']))fail();
 const {content_id,content_digest,...body}=document,r=body.anchor;
 if(body.profile!=='EZCONTEXTUAL-CONTENT-1'||body.status!=='draft'||!CONTEXTUAL_CONTENT_KINDS.includes(body.content_kind)||body.resolution_scope!=='local_context'||body.assertion_commitment!=='none'||r?.node_id!=='anchor'||r.value_type!=='entity')fail();
 if(r.kind==='deictic_reference'){
  if(!exact(r,['node_id','kind','value_type','deictic_role','referent_id'])||await canonicalDigest(r)!==await canonicalDigest(deicticReference(r.deictic_role,'anchor')))fail();
 }else if(r.kind==='phonemic_reference'){
  if(!exact(r,['node_id','kind','value_type','name','referent_id',...(Object.hasOwn(r,'reference_mode')?['reference_mode']:[])]))fail();
  const n=r.name;if(!n||!Array.isArray(n.phonemes)||n.phonemes.length===0)fail();
  const expected=await encodeName(n.label,n.object_tag||'',n.phonemes.join(' '));
  if(await canonicalDigest(n)!==await canonicalDigest(expected))fail();
  if(Object.hasOwn(r,'reference_mode')){
   const mode=NOMINAL_MODES[r.reference_mode];
   if(!mode||r.reference_mode==='nominal_class'||!/^[a-z]+$/.test(n.normalized_label)||r.referent_id!==`nominal:${mode.id}:${n.name_id}`)fail();
  }else if(r.referent_id!==`name:${n.name_id}`)fail();
 }else fail();
 const digest=await canonicalDigest(body);
 if(content_digest!==digest||content_id!==`EZCTX:${digest.slice(0,24)}`)fail();
 return document;
}
export async function createContextualContent(kind,anchor,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Contextual content requires explicit draft opt-in.');
 const body={profile:'EZCONTEXTUAL-CONTENT-1',status:'draft',content_kind:kind,anchor:structuredClone(anchor),resolution_scope:'local_context',assertion_commitment:'none'},digest=await canonicalDigest(body);
 return validateContextualContent({...body,content_digest:digest,content_id:`EZCTX:${digest.slice(0,24)}`},{allowDraft:true});
}
