// Some compounds have multiword English names. Their component words alone can
// suggest unrelated predicates (for example "used" inside "open for use").
import {storyWords} from './story_words.mjs?v=field-repairs-1';
import {mentionsOpeningPassage} from './passage_nouns.mjs';
const phraseHeads=new Map(storyWords.filter(w=>w.word.includes(' ')).map(w=>[w.id,w.word]));
const opening=storyWords.find(w=>w.word==='open').id;
const entryCache=new WeakMap();
function phraseForms(senses){
  if(entryCache.has(senses))return entryCache.get(senses);
  const byId=new Map();
  for(const s of senses){
    if(phraseHeads.get(s.target_id)!==s.lemma)continue;
    const forms=byId.get(s.target_id)||new Set();
    for(const f of [s.lemma,...s.surface_forms||[]])forms.add(f.toLowerCase());
    byId.set(s.target_id,forms);
  }
  entryCache.set(senses,byId);return byId;
}
export function contextsForWords(input,senses){
  const words=input.split(' '),padded=' '+input+' ',forms=phraseForms(senses);
  const allowedPhrases=new Set([...forms].filter(([,values])=>[...values].some(f=>padded.includes(' '+f+' '))).map(([id])=>id));
  const physical=mentionsOpeningPassage(words);
  return sense=>{
    if(!sense.target_id||input===sense.lemma.toLowerCase())return true;
    if(sense.target_id===opening&&!physical)return false;
    return !forms.has(sense.target_id)||allowedPhrases.has(sense.target_id);
  };
}
