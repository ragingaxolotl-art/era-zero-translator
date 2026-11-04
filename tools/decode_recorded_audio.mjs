#!/usr/bin/env node
// A WAV pathname and shared dictionary are the only inputs. No source text/IR.
import fs from 'node:fs';
import {fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';
import {midiFromScheduledEvents} from '../pages/engine.mjs';
import {decodeCareMidi} from '../pages/care_decoder.mjs';
import {decodeSwimmingMidi} from '../pages/swimming_decoder.mjs';
import {decodePhysicalEntryMidi} from '../pages/physical_entry_decoder.mjs';
const path=process.argv[2];if(!path)throw new Error('Usage: node tools/decode_recorded_audio.mjs recording.wav');
const observed=JSON.parse(execFileSync('python3',[fileURLToPath(new URL('./acoustic_transport.py',import.meta.url)),'decode',path],{encoding:'utf8',maxBuffer:20_000_000}));
const events=observed.notes.map((n,i)=>({family_opening_absolute_midi:[],address_absolute_midi:[n.midi],note_duration_beats:(n.end_tick-n.start_tick)/480,boundary_after_beats:i+1<observed.notes.length?(observed.notes[i+1].start_tick-n.end_tick)/480:0}));
const bytes=midiFromScheduledEvents(events,60,[]),{atoms}=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const accepted=[];
for(const decoder of [decodeCareMidi,decodeSwimmingMidi,decodePhysicalEntryMidi]){try{accepted.push(decoder(bytes,atoms));}catch{}}
if(accepted.length!==1)throw new Error('Audio recovered, but no unique supported predicate interpretation; refusing to guess.');
console.log(JSON.stringify({profile:'EZACOUSTIC-MEANING-EXPERIMENT-1',calibration:observed.calibration,checksum:observed.checksum,meaning:accepted[0],limitations:observed.limitations},null,2));
