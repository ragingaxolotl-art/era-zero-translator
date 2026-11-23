import {storyWords} from './story_words.mjs?v=information-storage-1';
const id=word=>storyWords.find(entry=>entry.word===word)?.id;
const actions=new Map([[id('close'),'transition'],[id('caused closing'),'caused']]);
const changingStates=new Set([id('closed'),id('passable'),id('blocked')]);
export const closingAction=predicate=>actions.get(predicate);
// A bare window or file may be software. Unknown labels remain phonemic and need
// a selected physical interpretation; the list is only a narrow English default.
export const isPhysicalClosure=head=>/^(?:gates?|doors?|hatch(?:es)?|lids?|shutters?|valves?|boxes|box|closures?)$/.test(head);
export function closingPropertyNeedsPhase(property,adjectives){
  if(typeof property==='string')return changingStates.has(property);
  return adjectives?.byId.get(property.local_id)?.canonicalTargets?.some(id=>changingStates.has(id))??false;
}
