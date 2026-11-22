// Render listening examples with the deployed reference-voice/player code.
import fs from 'node:fs/promises';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const base=process.argv[2]||'http://127.0.0.1:8766/';
const directory=new URL('../reports/full_audit_2026_11_22/',import.meta.url);
await fs.mkdir(new URL('audio/',directory),{recursive:true});
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
const rendered=[];
try{
 const page=await browser.newPage({viewport:{width:390,height:844}});
 await page.goto(base,{waitUntil:'domcontentloaded'});
 await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
 await page.locator('#sourceInput').fill('Nora pulled the box.');await page.locator('#analyzeButton').click();
 await page.waitForFunction(()=>!document.getElementById('analyzeButton').disabled);
 await page.screenshot({path:fileURLToPath(new URL('mobile-picker.png',directory)),fullPage:true});
 const layout=await page.evaluate(()=>({width:innerWidth,documentWidth:document.documentElement.scrollWidth,
  overflowing:[...document.querySelectorAll('main *')].filter(e=>e.getBoundingClientRect().right>innerWidth+1).slice(-12).map(e=>({tag:e.tagName,id:e.id,className:e.className,width:e.getBoundingClientRect().width,text:e.textContent.slice(0,120)}))}));
 await fs.writeFile(new URL('mobile-layout.json',directory),JSON.stringify(layout,null,2)+'\n');
 for(const variant of ['melody','chords','frame-16th']){
  const bytes=new Uint8Array(await fs.readFile(new URL('midi/audit-01-'+variant+'.mid',directory)));
  const parsed=notesFromMidi(bytes,{allowPolyphony:true}),duration=Math.max(...parsed.notes.map(n=>n.end_tick))*.5/parsed.division;
  const audio=await page.evaluate(async({bytes,duration})=>{
   const {createLocalCompoundPlayer}=await import('./local_compound_player.mjs');
   const rate=24000,graph=new OfflineAudioContext(1,Math.ceil((duration+1)*rate),rate);
   const context={currentTime:0,state:'running',destination:graph.destination,
    createGain:()=>graph.createGain(),createDynamicsCompressor:()=>graph.createDynamicsCompressor(),
    createOscillator:()=>graph.createOscillator(),createBiquadFilter:()=>graph.createBiquadFilter()};
   const player=createLocalCompoundPlayer({audioContextFactory:()=>context});
   await player.play(new Uint8Array(bytes),{chords:true});
   const buffer=await graph.startRendering(),samples=buffer.getChannelData(0);player.stop();
   let peak=0;const pcm=new DataView(new ArrayBuffer(samples.length*2));
   for(let i=0;i<samples.length;i++){peak=Math.max(peak,Math.abs(samples[i]));pcm.setInt16(i*2,Math.round(Math.max(-1,Math.min(1,samples[i]))*32767),true);}
   const raw=new Uint8Array(pcm.buffer),parts=[];for(let i=0;i<raw.length;i+=8192)parts.push(String.fromCharCode(...raw.slice(i,i+8192)));
   return {rate,peak,pcm:btoa(parts.join(''))};
  },{bytes:Array.from(bytes),duration});
  const pcm=Buffer.from(audio.pcm,'base64'),header=Buffer.alloc(44);
  header.write('RIFF');header.writeUInt32LE(pcm.length+36,4);header.write('WAVEfmt ',8);header.writeUInt32LE(16,16);
  header.writeUInt16LE(1,20);header.writeUInt16LE(1,22);header.writeUInt32LE(audio.rate,24);header.writeUInt32LE(audio.rate*2,28);
  header.writeUInt16LE(2,32);header.writeUInt16LE(16,34);header.write('data',36);header.writeUInt32LE(pcm.length,40);
  const path='audio/hatch-'+variant+'.wav';await fs.writeFile(new URL(path,directory),Buffer.concat([header,pcm]));
  rendered.push({variant,path,music_seconds:duration,wav_seconds:pcm.length/(audio.rate*2),peak:audio.peak,
   provenance:'Offline Web Audio rendering using the current Era Zero reference voice and player. This is not a speaker-to-microphone recording. Uniform chord gain used for level-consistent comparison.'});
 }
 await fs.writeFile(new URL('audio_rendering.json',directory),JSON.stringify(rendered,null,2)+'\n');console.log(JSON.stringify(rendered));
}finally{await browser.close();}
