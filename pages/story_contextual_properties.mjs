import {CONTEXTUAL_NORMS} from './contextual_standards.mjs';

// These values reuse the published dimensions and local standards. Shared frozen
// objects also keep repeated noun descriptions stable during reference resolution.
const values=new Map(Object.keys(CONTEXTUAL_NORMS).map(norm=>[norm,Object.freeze({contextual_norm:norm})]));
export const contextualProperty=word=>values.get(word);
export function contextualPropertyNorm(value){
  return value&&typeof value==='object'&&!Array.isArray(value)&&Object.keys(value).length===1&&
    Object.hasOwn(value,'contextual_norm')&&values.has(value.contextual_norm)?value.contextual_norm:null;
}
const dimensions={thermodynamic_temperature:'temperature',mass:'mass',luminance:'surface luminance',surface_texture:'surface texture',physical_width:'physical width'};
export function contextualPropertyLabel(value){
  const norm=contextualPropertyNorm(value),definition=CONTEXTUAL_NORMS[norm];
  return definition?norm+' ('+dimensions[definition.dimension]+', relative to the local standard)':null;
}
