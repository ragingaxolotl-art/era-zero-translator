// Examples demonstrate supported syntax, not an assertion that the described
// event is true or that an authored definition is approved vocabulary.
export function localCompoundExamples(definition){
 const label=definition.label;
 if(definition.part_of_speech==='adjective'&&definition.roles.some(r=>r.role==='bearer'))return [`Nora is ${label}.`,`Was Nora not ${label}?`,`Nora might not be ${label}.`];
 if(definition.part_of_speech==='verb'&&definition.roles.length){
  const object=definition.roles.length>1?' this tea':'';
  return [`Nora does ${label}${object}.`,`Did Nora not ${label}${object}?`,`Nora might ${label}${object}.`,...(definition.english_forms?[`Nora ${definition.english_forms.past}${object}.`]:[])];
 }
 return [];
}
const KEY='era-zero-builder-sentence';
export function queueLocalExample(storage,text){if(typeof text!=='string'||!text.trim()||text.length>5000)throw new Error('Invalid sentence example.');storage.setItem(KEY,text);}
export function takeLocalExample(storage){const text=storage.getItem(KEY);if(text===null)return null;storage.removeItem(KEY);return typeof text==='string'&&text.length<=5000?text:null;}
