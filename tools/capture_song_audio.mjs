// Render the actual Play song graph to a mono PCM WAV. A recording can be given
// to the independent listener without the source sentence or a MIDI sidecar.
import {createRequire} from 'node:module';
import fs from 'node:fs/promises';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site,text,file,arrangement='chords']=process.argv.slice(2);
if(!site||!text||!file)throw Error('Supply SITE, a sentence with a direct whole score, and OUTPUT.wav.');
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
try{
  const page=await browser.newPage();
  await page.addInitScript(()=>{
    window.AudioContext=class{
      constructor(){this.graph=new OfflineAudioContext(1,24000*180,24000);window.captureGraph=this.graph;}
      get currentTime(){return this.graph.currentTime;} get state(){return 'running';}
      get destination(){return this.graph.destination;}
      createGain(){return this.graph.createGain();} createDynamicsCompressor(){return this.graph.createDynamicsCompressor();}
      createOscillator(){return this.graph.createOscillator();} createBiquadFilter(){return this.graph.createBiquadFilter();}
    };
  });
  await page.goto(site);await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
  await page.locator('#sourceInput').fill(text);await page.locator('#analyzeButton').click();
  await page.getByRole('button',{name:'Add to song',exact:true}).click();
  await page.locator('#songArrangement').selectOption(arrangement);await page.locator('#playSong').click();
  await page.waitForFunction(()=>document.querySelector('#toast')?.textContent?.startsWith('Playing'));
  const base64=await page.evaluate(async()=>{
    const buffer=await window.captureGraph.startRendering(),signal=buffer.getChannelData(0);
    let last=signal.length-1;
    while(last>0&&Math.abs(signal[last])<.0001)last--;
    if(last+2400>=signal.length)throw Error('Song exceeds capture window');
    const frames=last+2400,pcm=new DataView(new ArrayBuffer(frames*2));
    for(let i=0;i<frames;i++)pcm.setInt16(i*2,Math.round(Math.max(-1,Math.min(1,signal[i]))*32767),true);
    const bytes=new Uint8Array(pcm.buffer),chunks=[];
    for(let i=0;i<bytes.length;i+=8192)chunks.push(String.fromCharCode(...bytes.subarray(i,i+8192)));
    return btoa(chunks.join(''));
  });
  const pcm=Buffer.from(base64,'base64'),h=Buffer.alloc(44);
  h.write('RIFF');h.writeUInt32LE(36+pcm.length,4);h.write('WAVEfmt ',8);h.writeUInt32LE(16,16);
  h.writeUInt16LE(1,20);h.writeUInt16LE(1,22);h.writeUInt32LE(24000,24);h.writeUInt32LE(48000,28);
  h.writeUInt16LE(2,32);h.writeUInt16LE(16,34);h.write('data',36);h.writeUInt32LE(pcm.length,40);
  await fs.writeFile(file,Buffer.concat([h,pcm]));console.log(file,pcm.length/48000,'seconds');
}finally{await browser.close();}
