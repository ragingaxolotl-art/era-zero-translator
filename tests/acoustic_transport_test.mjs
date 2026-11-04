import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeNamedSentence,parseNamedSentence} from '../pages/sentences.mjs';
import {midiFromFormal,midiFromScheduledEvents} from '../pages/engine.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {decodeSupportedMeaningMidi} from '../pages/semantic_music_dispatch.mjs';
import {strictSemanticReader} from '../pages/strict_semantic_reader.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:{...JSON.parse(fs.readFileSync(new URL('../pages/'+authority.resolution_files[id],import.meta.url))).variants['assertion:1'],authority};
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'era-zero-acoustic-'));
function clean(v){if(Array.isArray(v))return v.map(clean);if(v&&typeof v==='object')return Object.fromEntries(Object.entries(v).filter(([k])=>!['start_tick','end_tick','opening_token','closing_token','enclosing_scopes'].includes(k)).map(([k,x])=>[k,clean(x)]));return v;}
const report=[];
const meaning=bytes=>decodeSupportedMeaningMidi(bytes,authority.atoms);
for(const phrase of ['Nora cares for Eli.','Eli cares for Nora.','Nora did not care for Eli [0].','Eli is swimming [2].','Nora is permitted not to physically enter the archive.','It is possible that Nora is swimming.','Is Eli running?','The box is inside this room.','Ada acquired physical custody of the box.','Do not acquire physical custody of the box.']){
 const parsed=parseNamedSentence(phrase),r=await composeNamedSentence(phrase,await load(parsed.predicate)),midi=midiFromFormal(r.formal),observed=notesFromMidi(midi);
 const file=path.join(dir,`case-${report.length}.wav`),notes=observed.notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick}));
 const generated=JSON.parse(execFileSync('python3',['tools/acoustic_transport.py','synth',file],{input:JSON.stringify(notes),encoding:'utf8'}));
 // Independent process gets only WAV pathname. No text, formal, IR or note input.
 const recovered=JSON.parse(execFileSync('python3',['tools/acoustic_transport.py','decode',file],{encoding:'utf8'}));
 assert.deepEqual(recovered.notes,notes);
 
 // Rebuild generic SMF from recovered timing; contour remains part of observed data.
 const events=recovered.notes.map((n,i)=>({family_opening_absolute_midi:[],address_absolute_midi:[n.midi],note_duration_beats:(n.end_tick-n.start_tick)/480,boundary_after_beats:i+1<recovered.notes.length?(recovered.notes[i+1].start_tick-n.end_tick)/480:0}));
 const reconstructed=midiFromScheduledEvents(events,60,[]);
 const reader=strictSemanticReader(reconstructed,authority.atoms,'Acoustic semantic structure invalid');
 assert.deepEqual(clean(reader.readTree()),clean(strictSemanticReader(midi,authority.atoms,'Original invalid').readTree()));
 assert.equal(reader.observed.speech_act,r.semantic_ir.speech_act);
 const independent=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',file],{encoding:'utf8'}));
 const semantic=meaning(reconstructed);assert.deepEqual(independent.meaning,semantic);
 assert.deepEqual(semantic,meaning(midi));
 const channels=JSON.parse(execFileSync('python3',['tools/acoustic_channel_probe.py',file],{encoding:'utf8'}));
 for(const channel of channels){if(channel.accepted)assert.deepEqual(channel.result.notes,notes);}
 assert.equal(channels.find(c=>c.channel==='dropout').accepted,false);
 report.push({phrase,audio_seconds:generated.seconds,meaning:semantic,channels:channels.map(c=>({channel:c.channel,accepted:c.accepted,...(!c.accepted?{reason:c.result}:{})})),notes:notes.length,status:'exact_audio_notes_structure_and_supported_predicate_meaning_recovery',wav:file});
}
const result={status:'PASS',scope:'Synthetic PCM, blind audio decoding to supported predicate meanings; not general semantic interpretation or microphone evidence',evaluation:{clean_audio_cases:report.length,synthetic_channel_exact_recoveries:report.flatMap(c=>c.channels).filter(c=>c.accepted).length,damaged_payload_rejections:report.filter(c=>c.channels.find(p=>p.channel==='dropout'&&!p.accepted)).length,physical_microphone_recordings:0,original_text_or_ir_supplied_to_decoder:false,hidden_semantic_metadata:false,scope:'Authored message probe; not held-out or broad coverage'},cases:report};
fs.writeFileSync(new URL('../reports/acoustic_transport_probe.json',import.meta.url),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
