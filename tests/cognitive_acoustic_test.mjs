import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {composeFoundationSentence} from '../pages/foundation_sentences.mjs';
import {composeLearnedWhether} from '../pages/learned_whether.mjs';
import {midiFromKnowledgeAcquisition} from '../pages/knowledge_acquisition_music.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
const read=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url))),authority=read('pages/data/index.json'),records=read('pages/data/foundation_preview_candidates.json').records;
const load=id=>authority.compound_plans[id]?.expanded.nodes.some(n=>n.kind==='slot')?{authority}:{...read('pages/'+authority.resolution_files[id]).variants['assertion:1'],authority};
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'era-zero-cognitive-audio-')),cases=[];
for(const phrase of ['Nora prefers this tea to that tea [0].','Nora wants Eli to swim [2].','Nora does not know whether Eli is not conscious.','Yesterday, Nora learned whether Eli is conscious.']){
 let bytes;
 if(phrase.includes('learned')){const r=await composeLearnedWhether(phrase,authority,records,load,{allowDraft:true});bytes=await midiFromKnowledgeAcquisition(r.acquisition,r.result_formal,authority,{allowDraft:true});}
 else {const r=await composeFoundationSentence(phrase,authority,records,load,{allowDraft:true,allowCognitive:true});bytes=midiFromFormal(r.formal);}
 const expected=await decodeSupportedMeaningWithDrafts(bytes,authority.atoms,records,{allowDraft:true});
 await assert.rejects(()=>decodeSupportedMeaningWithDrafts(bytes,authority.atoms,records));
 const notes=notesFromMidi(bytes).notes.map(({midi,start_tick,end_tick})=>({midi,start_tick,end_tick})),file=path.join(dir,`case-${cases.length}.wav`);
 const generated=JSON.parse(execFileSync('python3',['tools/acoustic_transport.py','synth',file],{input:JSON.stringify(notes),encoding:'utf8'}));
 // Decoder process has only WAV + explicit draft permission, never expected IR.
 const decoded=JSON.parse(execFileSync(process.execPath,['tools/decode_recorded_audio.mjs',file,'--allow-draft'],{encoding:'utf8'}));
 assert.deepEqual(decoded.meaning,expected);
 const channels=JSON.parse(execFileSync('python3',['tools/acoustic_channel_probe.py',file],{encoding:'utf8'}));
 for(const channel of channels)if(channel.accepted)assert.deepEqual(channel.result.notes,notes);
 assert.equal(channels.find(c=>c.channel==='dropout').accepted,false);
 cases.push({phrase,audio_seconds:generated.seconds,wav:file,meaning:decoded.meaning,channels:channels.map(c=>({channel:c.channel,accepted:c.accepted,...(!c.accepted?{reason:c.result}:{})}))});
}
const result={status:'PASS',scope:'Four authored cognitive draft messages through synthetic audio only; physical recording unverified',original_text_or_ir_supplied_to_decoder:false,physical_recordings:0,cases};
fs.writeFileSync(new URL('../reports/cognitive_acoustic_probe.json',import.meta.url),JSON.stringify(result,null,2)+'\n');
console.log('PASS four draft cognitive WAV-only meaning round trips, default rejection, and channel probes.');
