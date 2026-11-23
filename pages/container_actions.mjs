import {storyWords} from './story_words.mjs?v=information-storage-1';

const id=word=>storyWords.find(entry=>entry.word===word)?.id;
const actions=new Map([[id('fill'),'fill'],[id('empty container'),'empty']]);
const changingStates=new Set([id('empty'),id('full')]);
export const containerAction=predicate=>actions.get(predicate);

// The old adjective sounds say which property describes the object, but do not
// mark an initial or result phase of a change. Do not invent that attachment.
export function containerPropertyNeedsPhase(property,adjectives){
  if(typeof property==='string')return changingStates.has(property);
  return adjectives?.byId.get(property.local_id)?.canonicalTargets?.some(id=>changingStates.has(id))??false;
}
