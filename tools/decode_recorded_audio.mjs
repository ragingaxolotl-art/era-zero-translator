#!/usr/bin/env node
// A WAV pathname and shared dictionary are the only inputs. No source text/IR.
import fs from 'node:fs';
import {fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';
import {midiFromScheduledEvents} from '../pages/engine.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const path=process.argv[2],allowDraft=process.argv[3]==='--allow-draft';if(!path||process.argv.length>4||(process.argv[3]&&!allowDraft))throw new Error('Usage: node tools/decode_recorded_audio.mjs recording.wav [--allow-draft]');
const observed=JSON.parse(execFileSync('python3',[fileURLToPath(new URL('./acoustic_transport.py',import.meta.url)),'decode',path],{encoding:'utf8',maxBuffer:20_000_000}));
const events=observed.notes.map((n,i)=>({family_opening_absolute_midi:[],address_absolute_midi:[n.midi],note_duration_beats:(n.end_tick-n.start_tick)/480,boundary_after_beats:i+1<observed.notes.length?(observed.notes[i+1].start_tick-n.end_tick)/480:0}));
const bytes=midiFromScheduledEvents(events,60,[]),{atoms}=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const records=allowDraft?JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url))).records:[];
const meaning=await decodeSupportedMeaningWithDrafts(bytes,atoms,records,{allowDraft});
console.log(JSON.stringify({profile:'EZACOUSTIC-MEANING-EXPERIMENT-1',calibration:observed.calibration,checksum:observed.checksum,meaning,limitations:observed.limitations},null,2));
