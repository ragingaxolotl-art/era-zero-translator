// Render the same oscillator, gain, filtering and limiter graph used by the
// bottom preview button. The offline audio context runs faster than real time.
import {createRequire} from 'node:module';
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import path from 'node:path';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site,dir]=process.argv.slice(2);
if(!site||!dir)throw Error('Supply SITE and OUTPUT_DIRECTORY.');
await fs.mkdir(dir,{recursive:true});
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
try{
 const rows=[], gateClips=[];
 for(const which of ['song-melody','song-chords','care-melody','care-chords']){
   const page=await browser.newPage({viewport:{width:390,height:844}});
   await page.addInitScript(()=>{
     window.AudioContext=class {
       constructor(){this.graph=new OfflineAudioContext(1,24000*8,24000);window.auditGraph=this.graph;}
       get currentTime(){return this.graph.currentTime;} get state(){return 'running';}
       get destination(){return this.graph.destination;}
       createGain(){return this.graph.createGain();} createDynamicsCompressor(){return this.graph.createDynamicsCompressor();}
       createOscillator(){return this.graph.createOscillator();} createBiquadFilter(){return this.graph.createBiquadFilter();}
     };
   });
   await page.goto(site,{waitUntil:'domcontentloaded'});await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
   if(which.startsWith('song')){
     await page.locator('#sourceInput').fill('The gate reopened. [1]');await page.locator('#analyzeButton').click();
     await page.getByRole('button',{name:'Add to song',exact:true}).click();
     await page.locator('#songArrangement').selectOption(which.split('-')[1]);await page.locator('#previewSongRoot').click();
   }else await page.locator(which==='care-chords'?'#hearCareChords':'#hearCareMelody').click();
   await page.waitForFunction(()=>Boolean(window.auditGraph));
   // Let the event handler finish scheduling, including the async dictionary fetch.
   await page.waitForFunction(()=>document.querySelector('#toast')?.textContent?.startsWith('Playing'));
   const result=await page.evaluate(async recordClip=>{
     const buffer=await window.auditGraph.startRendering(),signal=buffer.getChannelData(0),rate=buffer.sampleRate;
     const spectral=(from,to)=>{
       const first=Math.round(from*rate),last=Math.round(to*rate),len=last-first;
       const pitches=[];
       for(let midi=45;midi<84;midi++){
         const omega=2*Math.PI*440*2**((midi-69)/12)/rate;let cosine=0,sine=0;
         for(let i=0;i<len;i++){
           const value=signal[first+i]*(.5-.5*Math.cos(2*Math.PI*i/(len-1)));
           cosine+=value*Math.cos(omega*i);sine+=value*Math.sin(omega*i);
         }
         pitches.push({midi,power:cosine*cosine+sine*sine});
       }
       const maximum=Math.max(...pitches.map(p=>p.power));
       return pitches.filter(p=>p.power>maximum*.20).map(p=>p.midi);
     };
     let peak=0,lastSound=0;
     for(let i=0;i<signal.length;i++){peak=Math.max(peak,Math.abs(signal[i]));if(Math.abs(signal[i])>.001)lastSound=i/rate;}
     const measurements={first_pitches:spectral(.18,.5),second_pitches:spectral(.68,1),peak:Number(peak.toFixed(4)),audible_seconds:Number(lastSound.toFixed(3))};
     if(recordClip){
       const frames=Math.min(signal.length,Math.ceil((lastSound+.05)*rate));
       const pcm=new DataView(new ArrayBuffer(frames*2));
       for(let i=0;i<frames;i++)pcm.setInt16(i*2,Math.round(Math.max(-1,Math.min(1,signal[i]))*32767),true);
       const bytes=new Uint8Array(pcm.buffer),chunks=[];
       for(let i=0;i<bytes.length;i+=8192)chunks.push(String.fromCharCode(...bytes.subarray(i,i+8192)));
       measurements.pcm=btoa(chunks.join(''));
     }
     return measurements;
   },which.startsWith('song'));
   if(result.pcm){gateClips.push(Buffer.from(result.pcm,'base64'));delete result.pcm;}
   rows.push({which,...result});await page.close();
 }
 // Record the two actual previews back to back so a listener can make the same comparison.
 const [melody,chords,careMelody,careChords]=rows;
 assert.deepEqual([melody.first_pitches,melody.second_pitches],[[60],[65]]);
 assert.deepEqual([chords.first_pitches,chords.second_pitches],[[60,65,67],[60,67,72]]);
 assert.deepEqual([careMelody.first_pitches,careMelody.second_pitches],[[60],[64]]);
 assert.deepEqual([careChords.first_pitches,careChords.second_pitches],[[60,64,67],[58,67,74]]);
 assert(chords.audible_seconds<melody.audible_seconds && careChords.audible_seconds<careMelody.audible_seconds);
 const sampleRate=24000,pcm=Buffer.concat([gateClips[0],Buffer.alloc(sampleRate),gateClips[1]]);
 const header=Buffer.alloc(44);
 header.write('RIFF');header.writeUInt32LE(pcm.length+36,4);header.write('WAVEfmt ',8);
 header.writeUInt32LE(16,16);header.writeUInt16LE(1,20);header.writeUInt16LE(1,22);
 header.writeUInt32LE(sampleRate,24);header.writeUInt32LE(sampleRate*2,28);
 header.writeUInt16LE(2,32);header.writeUInt16LE(16,34);header.write('data',36);header.writeUInt32LE(pcm.length,40);
 await fs.writeFile(path.join(dir,'gate-comparison.wav'),Buffer.concat([header,pcm]));
 await fs.writeFile(path.join(dir,'waveforms.json'),JSON.stringify(rows,null,2)+'\n');console.log(JSON.stringify(rows));
}finally{await browser.close();}
