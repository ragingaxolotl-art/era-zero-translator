// Draft reference prerequisite for consumption. No drinking or liquid assertion.
import {canonicalDigest} from './engine.mjs';
import {encodeName} from './names.mjs';
import {parseNominal} from './nominals.mjs';
import {NOMINAL_MODES} from './references.mjs';
const CONTRACT=Object.freeze({material_kind_commitment:'label_not_classification',quantity:'unspecified',whole_amount_consumption:'not_asserted',existence_commitment:'governed_by_enclosing_content'});
export async function createMaterialReference(text,{allowDraft=false,reading}={}){
 if(!allowDraft)throw new Error('Material references require draft opt-in.');
 if(typeof text!=='string')throw new Error('Supply a material noun label.');text=text.trim();
 const nominal=parseNominal(text);
 let head,mode;
 if(reading==='kind'&&/^[a-z]+$/.test(text)&&parseNominal(`the ${text}`)){head=text;mode='nominal_class';}
 else if(reading==='contextual_portion'&&nominal&&!nominal.quantifier&&['definite_nominal','proximal_nominal','distal_nominal'].includes(nominal.mode)){head=nominal.head;mode=nominal.mode;}
 else throw new Error('Choose a kind from a bare noun, or a contextual portion with the/this/that. No amount or portion is inferred.');
 const name=await encodeName(head),reference={node_id:'material',kind:'phonemic_reference',value_type:reading==='kind'?'kind':'entity',name,referent_id:`nominal:${NOMINAL_MODES[mode].id}:${name.name_id}`,reference_mode:mode};
 const body={profile:'EZMATERIAL-REFERENCE-1',status:'draft',reading,...CONTRACT,reference},hash=await canonicalDigest(body);
 return {...body,content_digest:hash,content_id:`EZMATREF:${hash.slice(0,24)}`};
}
export async function validateMaterialReference(document,{allowDraft=false}={}){
 if(!allowDraft)throw new Error('Material references require draft opt-in.');
 const d=structuredClone(document),keys=['profile','status','reading',...Object.keys(CONTRACT),'reference','content_digest','content_id'];
 if(!d||typeof d!=='object'||Array.isArray(d)||Object.keys(d).length!==keys.length||keys.some(k=>!Object.hasOwn(d,k))||d.profile!=='EZMATERIAL-REFERENCE-1'||d.status!=='draft'||Object.entries(CONTRACT).some(([k,v])=>d[k]!==v))throw new Error('Invalid material-reference contract.');
 const ref=d.reference,label=ref?.name?.normalized_label,prefix={definite_nominal:'the ',proximal_nominal:'this ',distal_nominal:'that ',nominal_class:''}[ref?.reference_mode];
 if(prefix===undefined||typeof label!=='string')throw new Error('Invalid material-reference identity.');
 const expected=await createMaterialReference(prefix+label,{allowDraft:true,reading:d.reading});
 if(await canonicalDigest(d)!==await canonicalDigest(expected))throw new Error('Material reference or digest differs from its declared reading.');return d;
}
