import {properties,isMaterialTarget,isPhysicalContainer,physicalActionLabels} from './story_qualities.mjs?v=information-storage-1';
// Some compounds have multiword English names. Their component words alone can
// suggest unrelated predicates (for example "used" inside "open for use").
import {storyWords} from './story_words.mjs?v=information-storage-1';
import {mentionsOpeningPassage} from './passage_nouns.mjs';
const phraseHeads=new Map(storyWords.filter(w=>w.word.includes(' ')).map(w=>[w.id,w.word]));
const ids=new Map(storyWords.map(w=>[w.word,w.id]));
const opening=ids.get('open');
const physicalVerbs=new Set(Object.keys(physicalActionLabels).map(w=>ids.get(w)));
const contentProperties=new Set(['empty','full'].map(w=>ids.get(w)));
function hasState(words,maintained){
  const verb=maintained?/^(?:keep|keeps|kept|keeping|maintains?|maintained|maintaining)$/:/^(?:stays?|stayed|staying|remains?|remained|remaining)$/;
  return words.some((w,i)=>{
    if(!verb.test(w))return false;
    if(!maintained)return properties.has(words[i+1]);
    // An adjective before the noun (as in “keep the open file”) is not the result state.
    return words.some((quality,j)=>j>i+1 && properties.has(quality) &&
      (j===words.length-1||['and','before','after','if','now','again','for'].includes(words[j+1])));
  });
}
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
  const hasPhysicalObject=words.some(w=>isMaterialTarget(w));
  const hasContainer=words.some(w=>isPhysicalContainer(w));
  const continuing=hasState(words,false),maintaining=hasState(words,true);
  return sense=>{
    if(!sense.target_id||input===sense.lemma.toLowerCase())return true;
    if(sense.target_id===opening&&!physical)return false;
    if(sense.target_id===ids.get('stay')&&!continuing || sense.target_id===ids.get('keep')&&!maintaining)return false;
    if(physicalVerbs.has(sense.target_id)&&!hasPhysicalObject)return false;
    if(contentProperties.has(sense.target_id)&&!hasContainer)return false;
    return !forms.has(sense.target_id)||allowedPhrases.has(sense.target_id);
  };
}
