// Exercise the arrangement selector and Play song, as a listener would. Tap the
// oscillator starts without replacing Web Audio. The normal voices, gains and output still run.
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import path from 'node:path';
import {createRequire} from 'node:module';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const require=createRequire(import.meta.url);
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const [url,output]=process.argv.slice(2);
if(!url||!output)throw Error('Supply SITE and OUTPUT_DIRECTORY.');
await fs.mkdir(output,{recursive:true});
const inputs=['The gate reopened. [1]','We need to resolve the redundancy error.','Pip spotted a cracked and faulty bell and repaired it.'];
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
try{
 const page=await browser.newPage({viewport:{width:390,height:844},acceptDownloads:true});
 await page.addInitScript(()=>{
   const pitches=new WeakMap();window.auditNotes=[];
   const set=AudioParam.prototype.setValueAtTime,start=OscillatorNode.prototype.start;
   AudioParam.prototype.setValueAtTime=function(value,time){pitches.set(this,value);return set.call(this,value,time);};
   OscillatorNode.prototype.start=function(time){
     window.auditNotes.push({time,frequency:pitches.get(this.frequency)??this.frequency.value});
     return start.call(this,time);
   };
 });
 await page.goto(url,{waitUntil:'domcontentloaded'});
 await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
 const rows=[];
 for(const input of inputs){
   await page.locator('#sourceInput').fill(input);await page.locator('#analyzeButton').click();
   await page.getByRole('button',{name:'Add to song',exact:true}).click();
   const row={input};
   for(const mode of ['melody','chords']){
     await page.locator('#songArrangement').selectOption(mode);
     await page.evaluate(()=>{window.auditNotes=[];});
     await page.locator('#playSong').click();
     await page.waitForFunction(()=>window.auditNotes.length>0);
     const heard=await page.evaluate(()=>window.auditNotes);
     await page.locator('#stopSong').click();
     const [download]=await Promise.all([page.waitForEvent('download'),page.locator('#exportSong').click()]);
     const bytes=await fs.readFile(await download.path()),{notes,division}=notesFromMidi(bytes,{allowPolyphony:true});
     const t0=heard[0].time;
     const played=heard.map(({time,frequency})=>[Math.round((time-t0)*division*2),Math.round(69+12*Math.log2(frequency/440))]);
     assert.deepEqual(played,notes.map(n=>[n.start_tick,n.midi]),input+' '+mode);
     const groups=Map.groupBy(played,([tick])=>tick);
     const triads=[...groups.values()].filter(g=>g.length===3);
     row[mode]={tones:played.length,seconds:Math.max(...notes.map(n=>n.end_tick))/division/2,
       three_note_attacks:triads.length,first_chord_seconds:triads.length?triads[0][0][0]/division/2:null,
       first_two_chords:triads.slice(0,2).map(g=>g.map(n=>n[1]))};
   }
   await page.getByRole('button',{name:'Remove line 1'}).click();rows.push(row);
 }
 await fs.writeFile(path.join(output,'song-playback.json'),JSON.stringify(rows,null,2)+'\n');
 console.log(JSON.stringify(rows));
}finally{await browser.close();}
