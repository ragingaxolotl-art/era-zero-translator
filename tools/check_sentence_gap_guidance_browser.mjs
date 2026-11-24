import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import {decodeStoryMidi} from '../pages/story_music.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
const [site,output]=process.argv.slice(2);if(!site||!output)throw Error('Supply site and report.');
const {chromium}=await import(process.env.DBA_PLAYWRIGHT?pathToFileURL(process.env.DBA_PLAYWRIGHT):'playwright');
const a=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const browser=await chromium.launch({headless:true,...(process.env.DBA_CHROME?{executablePath:process.env.DBA_CHROME}:{})});
const report={site,timestamp:new Date().toISOString(),cases:[],downloads:[],stale:[]};
const cases=[['Both workers waited.','pair',null],['Three workers waited.','quantity',null],['The box is very heavy.','degree',null],['The gate was still closed.','continues',null],['Three workers zorbled the box.','quantity','zorbled'],['The lamp is very glimmerwise.','degree','glimmerwise']];
const add=p=>p.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true});
async function translate(page,text){await page.locator('#sourceInput').fill(text);await page.locator('#analyzeButton').click();await page.waitForFunction(()=>!document.getElementById('analyzeButton').disabled);}
try{
 for(const width of [320,390,768]){
  const context=await browser.newContext({viewport:{width,height:900},acceptDownloads:true}),page=await context.newPage(),errors=[];page.on('pageerror',e=>errors.push(e.message));
  try{
   await page.goto(site,{waitUntil:'networkidle'});await page.waitForFunction(()=>!document.getElementById('analyzeButton').disabled);
   for(const [text,reason,missing] of cases){
    await translate(page,text);const explanation=page.locator('#candidateList .unsupported-sentence');await explanation.waitFor();assert((await explanation.innerText()).includes(reason));
    assert.equal(await add(page).count(),0);const gaps=page.locator('#phraseCoverage .missing-word-list');
    if(missing){await gaps.getByText(missing,{exact:true}).waitFor();assert((await gaps.innerText()).includes(missing));}
    else assert.equal(await gaps.count(),0,'Known words should not require a new definition');
    assert(!(await page.locator('#decisionSummary').innerText()).includes('“workers” needs a verb'));
    assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));assert.deepEqual(errors,[]);
    report.cases.push({width,text,reason,missing,status:'pass'});
    await page.locator('#sourceInput').fill('Changed sentence');assert.equal(await page.locator('#candidateList .unsupported-sentence').count(),0);report.stale.push({width,text,status:'pass'});
   }
   await translate(page,'Nora saved the file. [2]');await add(page).waitFor();
   if(width===390){await add(page).click();for(const arrangement of ['melody','chords']){
    await page.locator('#songArrangement').selectOption(arrangement);const pending=page.waitForEvent('download');await page.locator('#exportSong').click();const bytes=new Uint8Array(await fs.readFile(await (await pending).path()));
    const m=decodeStoryMidi(arrangement==='chords'?expandChordMidi(bytes,a.atoms):bytes,a.atoms);assert.equal(m.runtime_state,2);assert.equal(m.events[0].predicate,'CMP:58cfa479709294b9809be1b7');assert.deepEqual(m.events[0].scopes,['time_before_speech']);assert.deepEqual(m.events[0].arguments.map(v=>[v.role,v.entity]),[['actor',0],['target',1]]);
    report.downloads.push({arrangement,sha256:createHash('sha256').update(bytes).digest('hex')});
   }}
  }finally{await context.close();}
 }
 report.status='pass';
}catch(error){report.status='fail';report.error=error.stack;throw error;}
finally{await browser.close();await fs.writeFile(output,JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({site,status:report.status,cases:report.cases.length,downloads:report.downloads.length,stale:report.stale.length,error:report.error}));}
