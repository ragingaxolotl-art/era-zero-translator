import {storyReading} from './story_readings.mjs?v=ordinary-time-1';
import {scoreStory} from './story_music.mjs?v=ordinary-time-1';
import {dictionaryClausePlan} from './dictionary_clauses.mjs?v=information-storage-1';
import {scoreDictionaryClause} from './dictionary_clause_music.mjs?v=ordinary-comparatives-1';
import {midiFromFormal,midiFromScheduledEvents} from './engine.mjs?v=ordinary-comparatives-1';
import {notesFromMidi} from './performance_codec.mjs?v=ordinary-comparatives-1';
import {composeNamedSentence,parseNamedSentence,parseSentenceConjunction,composeSentenceConjunction,
  parseSentenceSequence,composeSentenceSequence,parseSentenceConditional,composeSentenceConditional} from './sentences.mjs?v=ordinary-comparatives-1';
import {faultCorrectionPlan,composeFaultCorrection,describeFaultCorrection} from './fault_correction.mjs?v=ordinary-comparatives-1';
import {informationPassagePlan,composeInformationPassage} from './information_passage.mjs?v=ordinary-comparatives-1';

export function songMidi(lines) {
  if (!lines.length) throw Error('Add a translated line to your song first.');
  const events=[];
  for (const {midi} of lines) {
    const {notes,division}=notesFromMidi(midi);
    if (!notes.length || notes[0].start_tick!==0) throw Error('A song line needs a complete performance.');
    for (const [i,note] of notes.entries()) {
      const next=notes[i+1];
      events.push({family_opening_absolute_midi:[],address_absolute_midi:[note.midi],
        note_duration_beats:(note.end_tick-note.start_tick)/division,
        boundary_after_beats:next?(next.start_tick-note.end_tick)/division:2});
    }
  }
  return midiFromScheduledEvents(events,60,[]);
}

// Use sentence composition before consulting isolated dictionary readings.
export async function scoreSongText(text,authority,loadTemplate,preferences=[],adjectives) {
  if (informationPassagePlan(text)) {
    const {midi,meaning}=await composeInformationPassage(text,authority);
    return {midi,meaning,label:'Draft discovery and required erasure'};
  }
  const correction=faultCorrectionPlan(text);
  if (correction) {
    const result=await composeFaultCorrection(correction,authority);
    return {...result,label:'Draft fault correction',description:describeFaultCorrection(correction)};
  }
  const story=storyReading(text,authority,{preferences,adjectives});
  if(story)return story.question||story.unsupported?null:scoreStory(story,authority);
  const parts=text.match(/[^.!?]+(?:[.!?](?:\s*\[[012]\])?|$)/g);
  if (!parts || parts.join('')!==text) return null;
  const lines=[];
  for (const part of parts) {
    const input=part.trim(), correction=faultCorrectionPlan(input);
    if (correction) {
      lines.push(await composeFaultCorrection(correction,authority));
      continue;
    }
    const parsed=parseNamedSentence(input);
    let r;
    if (parsed && !(parsed.requiredInterpretation||parsed.requiredViewpoint||parsed.requiredDestination)) r=await composeNamedSentence(input,await loadTemplate(parsed.predicate));
    else if (parseSentenceConjunction(input)) r=await composeSentenceConjunction(input,loadTemplate);
    else if (parseSentenceSequence(input)) r=await composeSentenceSequence(input,loadTemplate);
    else if (parseSentenceConditional(input)) r=await composeSentenceConditional(input,loadTemplate);
    else {
      if(parsed)return null;
      const dictionary=dictionaryClausePlan(input,authority,{preferences});
      if(!dictionary||dictionary.preferred<0&&dictionary.readings.length!==1)return null;
      const scored=await scoreDictionaryClause(dictionary,Math.max(0,dictionary.preferred),authority);
      if(parts.length===1)return scored;
      lines.push(scored);continue;
    }
    lines.push({midi:midiFromFormal(r.formal),meaning:r.semantic_ir});
  }
  const includesDraft=lines.some(line=>line.meaning.status==='draft');
  return {midi:lines.length===1?lines[0].midi:songMidi(lines),meaning:lines.map(l=>l.meaning),label:includesDraft?'Sentences with draft grammar':lines.length===1?'Complete sentence':'Complete sentences in order'};
}

export function needsWholeReading(input,result) {
  const words=value=>String(value||'').toLowerCase().replace(/\s*\[[012]\]\s*[.]?$/,'').replace(/[.!?]/g,'').trim().replace(/\s+/g,' ');
  const phrase=words(input);
  if (!phrase.includes(' ')) return false;
  return !result.candidates.some(c=>c.match_type==='exact_surface'||c.match_type==='exact_lemma'||words(c.lemma)===phrase);
}
