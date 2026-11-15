const heads=new Set('path route passage corridor passageway tunnel gate gateway door doorway hatch entrance exit bridge port channel lane road trail opening'.split(' '));
export const isPassageHead=word=>heads.has(word)||heads.has(word?.replace(/s$/,''));

// A physical transition fits a named passage. Copular "open" describes a state.
// With an explicit object, that object is the bearer of the change.
export function mentionsOpeningPassage(words){
  const action=words.findIndex(w=>['open','opens','opening','opened'].includes(w));
  if(action<0||words.length===1)return true;
  if(words[action]==='open'&&/\b(?:is|am|are|was|were|be|been) (?:not )?$/.test(words.slice(0,action).join(' ')+' '))return false;
  let phrase=words.slice(0,action);
  if(['the','a','an','this','that','their','my','our','your'].includes(words[action+1])){
    phrase=words.slice(action+2,action+5);
    const end=phrase.findIndex(w=>['on','at','in','for','with','before','after','from','and','or','to'].includes(w));
    if(end>=0)phrase=phrase.slice(0,end);
  }
  return phrase.some(isPassageHead);
}
