import {midiFromFormal} from './engine.mjs?v=partial-word-flow-1';
import {encodeName,midiFromName} from './names.mjs';
import {songMidi} from './song_lines.mjs?v=information-storage-1';

export function selectedWordMatch(item,selections) {
  const id = selections.get(item.token_index) ?? item.recommended_sense_id;
  return item.matches.find(match => match.sense_id === id) || item.matches[0];
}

// A sketch represents individual entries in order. No grammatical binding is inferred here.
export function wordScorePlan(coverage,selections,authority) {
  const playable = [], omitted = [];
  for (const item of coverage) {
    const match = selectedWordMatch(item,selections);
    if (['participant_reference','function_word','unresolved_semantic'].includes(item.status)) {
      omitted.push(item.term);
    } else if (['labeled_entity','phonemic_label'].includes(item.status) || (match?.route === 'gap' && match.noun_label_allowed)) {
      playable.push({term:item.term, kind:'name'});
    } else if (['atom','compound'].includes(match?.route) && authority.resolution_files[match.target_id] && !authority.required_roles[match.target_id]?.length) {
      playable.push({term:item.term, kind:'entry', target:match.target_id});
    } else {
      omitted.push(item.term);
    }
  }
  return {playable,omitted};
}

export async function scoreSelectedWords(plan,runtime,loadResolution) {
  if (![0,1,2].includes(runtime) || !plan.playable.length) throw Error('Choose a playable word meaning first.');
  const lines = await Promise.all(plan.playable.map(async word => {
    if (word.kind === 'name') return {midi:midiFromName(await encodeName(word.term))};
    const document = await loadResolution(word.target);
    const variant = document.variants['assertion:'+runtime];
    if (!variant) throw Error('The selected dictionary performance is unavailable.');
    return {midi:midiFromFormal(variant.formal)};
  }));
  return lines.length === 1 ? lines[0].midi : songMidi(lines);
}
