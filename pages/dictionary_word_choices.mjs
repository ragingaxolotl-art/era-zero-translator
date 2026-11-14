// Personal defaults only. A stored choice must still match a current dictionary
// reading, its English word form, its part of speech and its participant roles.
const key='era-zero-sentence-word-choices-v1';
export function readWordChoices(storage) {
  const raw=storage.getItem(key);if(raw===null)return [];
  const rows=JSON.parse(raw);
  if(!Array.isArray(rows)||rows.some(r=>!r || typeof r.word!=='string'||!Array.isArray(r.forms)||r.forms.some(f=>typeof f!=='string')||typeof r.roles!=='string'||typeof r.target!=='string'||typeof r.quality!=='boolean'))throw Error('Saved word choices could not be read.');
  return rows;
}
export function matchingChoice(rows,reading){
  const word=reading.word.toLowerCase(), roles=reading.participants.map(p=>p.role).join('/');
  return rows.find(row=>row.quality===reading.quality&&row.roles===roles&&row.forms.includes(word));
}
export function updateWordChoice(storage,reading,forms,forget=false) {
  const rows=readWordChoices(storage),previous=matchingChoice(rows,reading);
  const next=rows.filter(row=>row!==previous);
  if(!forget)next.push({word:reading.word.toLowerCase(),forms:previous?.forms||forms,roles:reading.participants.map(p=>p.role).join('/'),quality:reading.quality,target:reading.sense.target_id});
  storage.setItem(key,JSON.stringify(next));return next;
}
