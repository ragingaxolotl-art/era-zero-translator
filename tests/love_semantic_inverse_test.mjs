import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {decodeLoveMidi} from '../pages/love_decoder.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {compactChordMidi,expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi,midiFromNoteTimeline} from '../pages/performance_codec.mjs';
import {strictSemanticReader} from '../pages/strict_semantic_reader.mjs';
import {sentenceReadiness} from '../pages/sentence_readiness.mjs';
import {encodeName} from '../pages/names.mjs';

const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const id='CMP:44718c92b66443c0c0f03ad7';
const template={...JSON.parse(fs.readFileSync(new URL('../pages/'+a.resolution_files[id],import.meta.url))).variants['assertion:1'],authority:a};
let count=0,last;
for(const state of [0,1,2])for(const text of ['I love you.','You love me.','Nora loves Eli.','I do not love you.']){
  const composed=await composeNamedSentence(`${text} [${state}]`,template),midi=midiFromFormal(composed.formal);
  const decoded=await decodeSupportedMeaningWithDrafts(midi,a.atoms,[],{allowDraft:true});
  assert.equal((await sentenceReadiness(midi,a.atoms)).score_inverse,'supported');
  assert.equal(decoded.predicate,id);assert.equal(decoded.runtime_state,state);assert.equal(decoded.speech_act,'assertion');
  assert.deepEqual(decoded.scopes,text.includes('not')?[{operator:'negation'}]:[]);
  assert.equal(decoded.meaning.poetic_reading,state===2?'never_finished_becoming':undefined);
  if(text.startsWith('Nora')){
    assert.deepEqual(decoded.participants.actor.phonemes,(await encodeName('Nora')).phonemes);
    assert.deepEqual(decoded.participants.target.phonemes,(await encodeName('Eli')).phonemes);
  }else{
    assert.equal(decoded.participants.actor.role,text.startsWith('You')?'addressee':'speaker');
    assert.equal(decoded.participants.target.role,text.startsWith('You')?'speaker':'addressee');
  }
  assert.deepEqual(await decodeSupportedMeaningWithDrafts(expandChordMidi(compactChordMidi(midi,a.atoms),a.atoms),a.atoms,[],{allowDraft:true}),decoded);
  count++;last=midi;
}
// An altered qualifier or a missing end cannot pass by matching only the head.
const observed=strictSemanticReader(last,a.atoms,'invalid').observed;
const qualifier=observed.tokens.find(t=>t.root_id==='LIF:002');
const score=notesFromMidi(last),note=score.notes.findIndex(n=>n.start_tick===qualifier.start_tick);
score.notes[note+3].midi+=1;
assert.throws(()=>decodeLoveMidi(midiFromNoteTimeline(score.notes,score.division,score.tempos[0].value),a.atoms));
assert.throws(()=>decodeLoveMidi(last.slice(0,last.length-12),a.atoms));
assert.equal((await sentenceReadiness(last.slice(0,last.length-12),a.atoms)).score_inverse,'unavailable');
console.log(`PASS ${count} approved love readings in melody/chords, role reversal, negation, all runtime states and damaged-score rejection.`);
