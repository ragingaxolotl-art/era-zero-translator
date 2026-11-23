import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const p=process.env.DBA_ROOT;
const {chromium}=await import(pathToFileURL(process.env.DBA_PLAYWRIGHT));
const {decodeStoryMidi}=await import(pathToFileURL(p+'/pages/story_music.mjs'));
const {expandChordMidi}=await import(pathToFileURL(p+'/pages/compact_chords.mjs'));
const authority=JSON.parse(await fs.readFile(p+'/pages/data/index.json'));
const browser=await chromium.launch({headless:true,executablePath:process.env.DBA_CHROME}),cases=[];
try{
 for(const site of process.argv.slice(2))for(const width of [320,390,768]){
  const c=await browser.newContext({acceptDownloads:true,viewport:{width,height:900}}),page=await c.newPage();
  try{
   await page.goto(site,{waitUntil:'networkidle'});await page.locator('#sourceInput').fill('Nora saved the game. [2]');await page.locator('#analyzeButton').click();
   const add=page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true});assert.equal(await add.count(),0);
   await page.getByRole('button',{name:'Commit the information to a retained record',exact:true}).click();await add.waitFor();await add.click();
   const versions=[];
   for(const arrangement of ['melody','chords']){
    await page.locator('#songArrangement').selectOption(arrangement);const pending=page.waitForEvent('download');await page.locator('#exportSong').click();const d=await pending;
    const bytes=new Uint8Array(await fs.readFile(await d.path())),meaning=decodeStoryMidi(arrangement==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms);
    assert.equal(meaning.runtime_state,2);assert.equal(meaning.events[0].predicate,'CMP:58cfa479709294b9809be1b7');assert.deepEqual(meaning.events[0].arguments.map(a=>a.entity),[0,1]);assert.deepEqual(meaning.events[0].scopes,['time_before_speech']);versions.push(meaning);
   }
   assert.deepEqual(...versions);cases.push({site,width,status:'pass',downloads:2});
  }finally{await c.close();}
 }
}finally{await browser.close();await fs.writeFile('/tmp/dba-storage-positive-choices-1123.json',JSON.stringify({cases},null,2)+'\n');console.log(JSON.stringify(cases));}
