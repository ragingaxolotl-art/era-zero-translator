#!/usr/bin/env node
import fs from'node:fs/promises';
import path from'node:path';
import{fileURLToPath}from'node:url';
import{pcmFromPerformance,wavFromPerformance,verifyPerformancePcm,notesFromPcm}from'../pages/performance_audio.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..'),data=JSON.parse(await fs.readFile(path.join(root,'pages/data/index.json'),'utf8'));
const failures=[];let assertions=0,performances=0;
const check=(condition,message)=>{assertions++;if(!condition)failures.push(message)};
const targets=data.atoms.filter(atom=>atom.address==='000'||atom.address==='122'||atom.address==='211').map(atom=>atom.canonical_id);
for(const id of targets){
  const document=JSON.parse(await fs.readFile(path.join(root,'pages',data.resolution_files[id]),'utf8'));
  const formal=document.variants['assertion:1'].formal;
  for(const mode of ['strict','recognition','learning']){
    const pcm=pcmFromPerformance(formal,data.recognition_audio,mode),result=verifyPerformancePcm(formal,data.recognition_audio,pcm.samples,pcm.sample_rate);
    performances++;
    check(result.status===(mode==='strict'?'valid_strict_absence':'valid_checksum'),`${id} ${mode} PCM round trip: ${result.status}`);
    check(result.semantic_content===false&&result.semantic_identity_changed===false,`${id} ${mode} semantic boundary`);
    check(result.observed_notes.length===result.expected_note_count,`${id} ${mode} note segmentation`);
  }
}
const id='MOV:101',formal=JSON.parse(await fs.readFile(path.join(root,'pages',data.resolution_files[id]),'utf8')).variants['assertion:1'].formal;
const wav=wavFromPerformance(formal,data.recognition_audio);
check(new TextDecoder().decode(wav.slice(0,4))==='RIFF'&&new TextDecoder().decode(wav.slice(8,12))==='WAVE'&&wav.length>44,'reference WAV header');
if(process.env.ERA_ZERO_AUDIO_FIXTURE){const probe=JSON.parse(await fs.readFile(path.join(root,'pages',data.resolution_files['ORI:211']),'utf8')).variants['assertion:1'].formal;await fs.writeFile(process.env.ERA_ZERO_AUDIO_FIXTURE,wavFromPerformance(probe,data.recognition_audio))}
const corrupted=structuredClone(formal);corrupted.performance.lexical_events[0].family_opening_absolute_midi[0]++;
const damaged=pcmFromPerformance(corrupted,data.recognition_audio);
check(verifyPerformancePcm(formal,data.recognition_audio,damaged.samples,damaged.sample_rate).status==='checksum_or_path_mismatch','changed waveform pitch rejected');
let quietRejected=false;try{notesFromPcm(new Float32Array(22050),22050)}catch{quietRejected=true}
check(quietRejected,'silence rejected');
const status=failures.length?'FAIL':'PASS';
const report=`# Optional recognition waveform validation\n\nStatus: **${status}**\n\n- Sampled roots: **${targets.length}** across all 12 families and three address positions\n- PCM strict/recognition/learning round trips: **${performances}**\n- Assertions: **${assertions}**\n- Corrupted pitch: rejected\n- Silence: rejected\n- Canonical semantic changes: **0**\n- Failures: **${failures.length}**\n${failures.length?'\n'+failures.map(x=>`- ${x}`).join('\n')+'\n':''}`;
await fs.writeFile(path.join(root,'reports/performance_audio_validation.md'),report);
console.log(`Recognition waveform: ${status} · ${performances} performances · ${assertions} assertions`);
if(failures.length){console.error(failures.slice(0,30).join('\n'));process.exit(1)}
