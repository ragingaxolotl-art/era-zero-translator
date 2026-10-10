export const NAME_FORMAT='EZNAME-0.1';
export const PHONEMES=['AA','AE','AH','AO','AW','AY','B','CH','D','DH','EH','ER','EY','F','G','HH','IH','IY','JH','K','L','M','N','NG','OW','OY','P','R','S','SH','T','TH','UH','UW','V','W','Y','Z','ZH','WB'];
const PHONEME_SET=new Set(PHONEMES);
const START=[48,60,55],END=[55,60,48],INSTANCE_START=[72,65,72];
const DICTIONARY={water:['W','AO','T','ER'],food:['F','UW','D'],home:['HH','OW','M'],friend:['F','R','EH','N','D'],robot:['R','OW','B','AA','T'],data:['D','EY','T','AH'],message:['M','EH','S','IH','JH'],zibble:['Z','IH','B','AH','L'],xenoflirp:['Z','IY','N','OW','F','L','ER','P']};
const RULES=[['tion',['SH','AH','N']],['tch',['CH']],['dge',['JH']],['ch',['CH']],['sh',['SH']],['th',['TH']],['ng',['NG']],['ph',['F']],['wh',['W']],['qu',['K','W']],['ck',['K']],['ee',['IY']],['ea',['IY']],['oo',['UW']],['oa',['OW']],['ai',['EY']],['ay',['EY']],['oi',['OY']],['oy',['OY']],['ow',['AW']],['ou',['AW']],['ar',['AA','R']],['er',['ER']],['ir',['ER']],['ur',['ER']],['or',['AO','R']]];
const SINGLE={a:['AE'],b:['B'],c:['K'],d:['D'],e:['EH'],f:['F'],g:['G'],h:['HH'],i:['IH'],j:['JH'],k:['K'],l:['L'],m:['M'],n:['N'],o:['AA'],p:['P'],q:['K'],r:['R'],s:['S'],t:['T'],u:['UH'],v:['V'],w:['W'],x:['K','S'],y:['Y'],z:['Z']};
const clean=value=>String(value??'').normalize('NFC').toLowerCase().replace(/[^a-z\s-]/g,' ').replace(/[-\s]+/g,' ').trim();

function estimateWord(word){
  if(DICTIONARY[word])return DICTIONARY[word];
  let source=word;
  if(source.length>3&&source.endsWith('e')&&!source.endsWith('ee'))source=source.slice(0,-1);
  const result=[];
  for(let index=0;index<source.length;){
    const rest=source.slice(index),rule=RULES.find(([letters])=>rest.startsWith(letters));
    if(rule){result.push(...rule[1]);index+=rule[0].length;continue}
    const letter=source[index],next=source[index+1]||'';
    if(letter==='c'&&/[eiy]/.test(next))result.push('S');
    else if(letter==='g'&&/[eiy]/.test(next))result.push('JH');
    else result.push(...(SINGLE[letter]||[]));
    index++;
  }
  return result;
}

export function estimatePhonemes(label){const words=clean(label).split(' ').filter(Boolean);return words.flatMap((word,index)=>[...(index?['WB']:[]),...estimateWord(word)])}
export function parsePhonemes(value){const parsed=String(value??'').toUpperCase().split(/[\s,./-]+/).filter(Boolean),invalid=parsed.filter(item=>!PHONEME_SET.has(item));if(invalid.length)throw new Error(`Unknown phoneme symbol: ${invalid.join(', ')}`);return parsed}
export function phonemeNotes(symbol){const code=PHONEMES.indexOf(symbol);if(code<0)throw new Error(`Unknown phoneme symbol: ${symbol}`);return[52+Math.floor(code/8)*3,68+(code%8)]}
async function sha256(text){const digest=await crypto.subtle.digest('SHA-256',new TextEncoder().encode(text));return[...new Uint8Array(digest)].map(byte=>byte.toString(16).padStart(2,'0')).join('')}

export async function encodeName(label,objectTag='',phonemeOverride=''){
  const normalized=clean(label);
  if(!normalized)throw new Error('Enter a word or name to encode.');
  const phonemes=phonemeOverride.trim()?parsePhonemes(phonemeOverride):estimatePhonemes(normalized);
  if(!phonemes.length)throw new Error('No encodable phonemes were found.');
  const tag=String(objectTag??'').normalize('NFC').trim(),digest=await sha256(`${NAME_FORMAT}\n${normalized}\n${phonemes.join(' ')}\n${tag}`);
  const events=phonemes.map((phoneme,index)=>({index,phoneme,notes:phonemeNotes(phoneme),sound_class:/^(?:AA|AE|AH|AO|AW|AY|EH|ER|EY|IH|IY|OW|OY|UH|UW)$/.test(phoneme)?'vowel':'consonant'}));
  const instanceNotes=tag?[...digest.slice(0,8)].map(hex=>76+parseInt(hex,16)):[];
  return{format:NAME_FORMAT,status:'experimental_nonsemantic_label',label,normalized_label:normalized,phonemes,events,frame:{start:START,end:END},object_tag:tag||null,instance_notes:instanceNotes,name_id:`EZNAME:${digest.slice(0,16)}`,semantic_claim:false};
}

export function notesForName(name){return[...name.frame.start,...name.events.flatMap(event=>event.notes),...(name.instance_notes.length?[...INSTANCE_START,...name.instance_notes]:[]),...name.frame.end]}
function variableLength(value){const bytes=[value&0x7f];while((value>>=7)>0)bytes.unshift((value&0x7f)|0x80);return bytes}
const u32=value=>[(value>>>24)&255,(value>>>16)&255,(value>>>8)&255,value&255],u16=value=>[(value>>>8)&255,value&255];
export function midiFromName(name){const notes=notesForName(name),track=[0,0xff,0x51,3,0x07,0xa1,0x20,0,0xc0,11];notes.forEach((note,index)=>{const duration=index<3||index>=notes.length-3?240:360;track.push(...variableLength(index?60:0),0x90,note,88,...variableLength(duration),0x80,note,0)});track.push(0,0xff,0x2f,0);return new Uint8Array([...'MThd'].map(char=>char.charCodeAt(0)).concat(u32(6),u16(0),u16(1),u16(480),[...'MTrk'].map(char=>char.charCodeAt(0)),u32(track.length),track))}
