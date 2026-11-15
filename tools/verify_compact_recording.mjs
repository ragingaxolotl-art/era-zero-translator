// Decode the WAV in a separate process before opening its comparison MIDI.
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const [wav,expected]=process.argv.slice(2);
if(!wav||!expected)throw Error('Supply a WAV and its independently exported compact MIDI.');
const heard=JSON.parse(execFileSync(process.execPath,[fileURLToPath(new URL('./decode_compact_recording.mjs',import.meta.url)),wav],{encoding:'utf8'}));
const midi=fs.readFileSync(expected),{notes,division}=notesFromMidi(midi,{allowPolyphony:true});
const timeline=notes.map(n=>[n.start_tick*480/division,n.end_tick*480/division,n.midi]).sort((a,b)=>a[0]-b[0]||a[2]-b[2]||a[1]-b[1]);
assert.equal(heard.note_sha256,createHash('sha256').update(JSON.stringify(timeline)).digest('hex'));
const {atoms}=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const {records}=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url)));
assert.deepEqual(heard.meaning,await decodeSupportedMeaningWithDrafts(expandChordMidi(midi,atoms),atoms,records,{allowDraft:true}));
console.log(JSON.stringify({notes:heard.notes,note_sha256:heard.note_sha256,runtime:heard.meaning.runtime_state,
  exact_compact_notes_and_timing:true,exact_musical_meaning:true}));
