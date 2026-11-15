// One key per addition keeps independent writes from two tabs from overwriting each other.
const legacyKey='era-zero-song-lines-v1';
const prefix='era-zero-song-v2:';
const linePrefix=prefix+'line:';
const removedPrefix=prefix+'removed:';
export const isSongStorageKey=key=>key===null||key===legacyKey||key.startsWith(prefix);
const uniqueId=()=>crypto.getRandomValues(new Uint32Array(4)).join('-');

function decodeLine({text,label,bytes},id,order){
  if(typeof text!=='string'||typeof label!=='string'||typeof bytes!=='string')throw Error('Invalid saved song line.');
  return {text,label,midi:Uint8Array.from(atob(bytes),c=>c.charCodeAt(0)),id,order};
}

export function readSongLines(storage){
  const removed=new Set(), additions=[];
  for(let i=0;i<storage.length;i++){
    const key=storage.key(i);
    if(!key?.startsWith(prefix))continue;
    const value=storage.getItem(key);
    if(value===null)continue;
    if(key.startsWith(removedPrefix))removed.add(value);
    if(key.startsWith(linePrefix)){
      const record=JSON.parse(value);
      if(!Number.isSafeInteger(record.order)||record.order<1)throw Error('Invalid saved song order.');
      additions.push(decodeLine(record,key,record.order));
    }
  }
  // An older tab may still write the original list. Identify equal lines by occurrence
  // within that content, so deleting an earlier, different line cannot shift their IDs.
  const occurrences=new Map(), legacy=[];
  for(const row of JSON.parse(storage.getItem(legacyKey)||'[]')){
    const signature=JSON.stringify([row.text,row.label,row.bytes]);
    const occurrence=occurrences.get(signature)||0;
    occurrences.set(signature,occurrence+1);
    const id=occurrence+' '+signature;
    if(!removed.has(id))legacy.push(decodeLine(row,id,0));
  }
  additions.sort((a,b)=>a.order-b.order||(a.id<b.id?-1:a.id>b.id?1:0));
  return legacy.concat(additions);
}

export function newSongLine(text,label,midi,lines){
  const order=Math.max(Date.now(),(lines.at(-1)?.order||0)+1);
  return {id:linePrefix+uniqueId(),order,text,label,midi:new Uint8Array(midi)};
}

export function saveSongLine(storage,line){
  const bytes=btoa(Array.from(line.midi,b=>String.fromCharCode(b)).join(''));
  storage.setItem(line.id,JSON.stringify({order:line.order,text:line.text,label:line.label,bytes}));
}

export function removeSongLine(storage,id){
  if(id.startsWith(linePrefix))storage.removeItem(id);
  else storage.setItem(removedPrefix+uniqueId(),id);
}
