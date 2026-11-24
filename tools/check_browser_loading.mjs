// Fault injection verifies loading/retry behavior; it does not simulate every
// real network failure. The downloaded scores are decoded without source text.
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
const report={site,timestamp:new Date().toISOString(),method:'Injected delayed, HTTP, malformed JSON and aborted data requests in Chromium.',slow:[],recovery:[],shared:[],downloads:[]};
const add=p=>p.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true});
async function ready(page){await page.waitForFunction(()=>!document.getElementById('analyzeButton').disabled);assert.equal(await page.locator('#serviceStatus').innerText(),'Ready to translate');}
async function layout(page,width){const bounds=await page.evaluate(()=>({scroll:document.documentElement.scrollWidth,buttons:['analyzeButton','retryEngine'].map(id=>document.getElementById(id)).filter(e=>e.getClientRects().length).map(e=>({left:e.getBoundingClientRect().left,right:e.getBoundingClientRect().right}))}));assert(bounds.scroll<=width+1);for(const b of bounds.buttons)assert(b.left>=0&&b.right<=width+1);}
try{
 for(const [runtime,width] of [320,390,768].entries()){
  for(const resource of ['index','documents']){
   const context=await browser.newContext({viewport:{width,height:900},acceptDownloads:true}),page=await context.newPage(),errors=[];
   let release,seen;const blocked=new Promise(r=>release=r),requested=new Promise(r=>seen=r);
   page.on('pageerror',e=>errors.push(e.message));await page.route('**/data/'+resource+'.json',async route=>{seen();await blocked;await route.continue();});
   try{
    await page.goto(site,{waitUntil:'domcontentloaded'});await requested;
    const text='Nora saved the file. ['+runtime+']';await page.locator('#sourceInput').fill(text);
    assert(await page.locator('#analyzeButton').isDisabled());assert.equal(await add(page).count(),0);await layout(page,width);
    await page.locator('#analyzeButton').evaluate(e=>e.click());assert.equal(await add(page).count(),0);
    release();await ready(page);assert.equal(await page.locator('#sourceInput').inputValue(),text);
    await page.locator('#analyzeButton').click();await add(page).waitFor();assert.deepEqual(errors,[]);
    if(resource==='index'){
     await add(page).click();for(const arrangement of ['melody','chords']){
      await page.locator('#songArrangement').selectOption(arrangement);const pending=page.waitForEvent('download');await page.locator('#exportSong').click();const bytes=new Uint8Array(await fs.readFile(await (await pending).path()));
      const m=decodeStoryMidi(arrangement==='chords'?expandChordMidi(bytes,a.atoms):bytes,a.atoms);
      assert.equal(m.events[0].predicate,'CMP:58cfa479709294b9809be1b7');assert.deepEqual(m.events[0].scopes,['time_before_speech']);assert.deepEqual(m.events[0].arguments.map(v=>[v.role,v.entity]),[['actor',0],['target',1]]);assert.equal(m.runtime_state,runtime);
      report.downloads.push({width,runtime,arrangement,sha256:createHash('sha256').update(bytes).digest('hex')});
     }
    }
    report.slow.push({width,resource,status:'pass'});
   }finally{release();await context.close();}
  }
  for(const failure of ['index-http','documents-http','index-json','index-abort']){
   const context=await browser.newContext({viewport:{width,height:900}}),page=await context.newPage(),errors=[];let attempts=0;
   page.on('pageerror',e=>errors.push(e.message));const [resource,kind]=failure.split('-');
   await page.route('**/data/'+resource+'.json',async route=>{
    if(++attempts>1)return route.continue();
    if(kind==='abort')return route.abort('failed');
    return route.fulfill({status:kind==='http'?503:200,contentType:'application/json',body:kind==='json'?'not JSON':'{}'});
   });
   try{
    await page.goto(site,{waitUntil:'domcontentloaded'});await page.locator('#retryEngine').waitFor({state:'visible'});
    const text='Nora saved the file.';await page.locator('#sourceInput').fill(text);assert(await page.locator('#analyzeButton').isDisabled());await layout(page,width);
    if(width===390&&failure==='index-http'){await page.locator('#retryEngine').focus();await page.keyboard.press('Enter');}
    else await page.locator('#retryEngine').evaluate(e=>{e.click();e.click();});
    await ready(page);assert.equal(attempts,2,'Duplicate retry clicks must share one attempt');assert.equal(await page.locator('#sourceInput').inputValue(),text);assert(await page.locator('#retryEngine').isHidden());
    await page.locator('#analyzeButton').click();await add(page).waitFor();assert.deepEqual(errors,[]);report.recovery.push({width,failure,status:'pass'});
   }finally{await context.close();}
  }
  const context=await browser.newContext({viewport:{width,height:900}}),page=await context.newPage();
  try{await page.goto(site+'?text='+encodeURIComponent('Nora saved the file.'),{waitUntil:'domcontentloaded'});await add(page).waitFor();await ready(page);report.shared.push({width,status:'pass'});}finally{await context.close();}
 }
 report.status='pass';
}catch(error){report.status='fail';report.error=error.stack;throw error;}
finally{await browser.close();await fs.writeFile(output,JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({site,status:report.status,slow:report.slow.length,recovery:report.recovery.length,shared:report.shared.length,downloads:report.downloads.length,error:report.error}));}
