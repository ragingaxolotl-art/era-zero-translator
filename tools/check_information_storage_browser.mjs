// Usage: DBA_PLAYWRIGHT=/path/to/playwright/index.mjs DBA_CHROME=/path/to/chrome
// node tools/check_information_storage_browser.mjs SITE_URL REPORT_JSON
// Reads downloaded sound with the local public decoder, without the source text or IR.
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import {decodeStoryMidi} from '../pages/story_music.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const [site,output]=process.argv.slice(2);if(!site||!output)throw Error('Supply site URL and output JSON.');
const {chromium}=await import(process.env.DBA_PLAYWRIGHT?pathToFileURL(process.env.DBA_PLAYWRIGHT):'playwright');
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url),'utf8'));
const save='CMP:58cfa479709294b9809be1b7',keep='CMP:cac584a394535e4912c75b5a';
const cases=[
 {text:'Nora saved the file. [0]',predicate:save,state:0,roles:['actor','target'],scopes:['time_before_speech']},
 {text:'We will not store the records. [2]',predicate:save,state:2,roles:['actor','target'],scopes:['time_after_speech','negation'],plural:true},
 {text:'Can Nora save the record?',predicate:save,state:1,roles:['actor','target'],scopes:['ability'],act:'question'},
 {text:'Please store the file.',predicate:save,state:1,roles:['actor','target'],scopes:[],act:'command'},
 {text:'The file was stored. [2]',predicate:'DAT:000',state:2,roles:['bearer'],scopes:['time_before_speech']},
 {text:'Nora keeps the file stored.',predicate:keep,state:1,roles:['cause','bearer'],scopes:[],condition:'DAT:000'},
 {text:'The file was stored before Nora deleted it. [0]',predicate:'DAT:000',state:0,roles:['bearer'],scopes:['time_before_speech'],before:true}
];
const report={timestamp:new Date().toISOString(),site,layouts:[],downloads:[],choices:[],unsupported:[],keyboard:[],staleCleared:[]};
const browser=await chromium.launch({headless:true,...(process.env.DBA_CHROME?{executablePath:process.env.DBA_CHROME}:{})});
const add=page=>page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true});
const translate=async(page,text)=>{await page.locator('#sourceInput').fill(text);await page.locator('#analyzeButton').click();};
async function layout(page,width){
 const bounds=await page.evaluate(()=>({width:innerWidth,scroll:document.documentElement.scrollWidth,controls:[...document.querySelectorAll('#candidateList button,#candidateList select')].filter(e=>e.getClientRects().length).map(e=>({label:e.textContent,left:e.getBoundingClientRect().left,right:e.getBoundingClientRect().right}))}));
 assert(bounds.scroll<=width+1,JSON.stringify(bounds));for(const c of bounds.controls){assert(c.left>=0&&c.right<=width+1,c.label);}
}
try{
 for(const width of [320,390,768]){
  for(const item of cases){
   const context=await browser.newContext({viewport:{width,height:900},acceptDownloads:true});
   const page=await context.newPage(),errors=[];page.on('pageerror',error=>errors.push(error.message));
   try{
    await page.goto(site,{waitUntil:'networkidle',timeout:60000});await translate(page,item.text);
    await add(page).waitFor({state:'visible',timeout:20000});await layout(page,width);assert.deepEqual(errors,[]);
    report.layouts.push({width,text:item.text,status:'pass'});
    if(width===390){
     await add(page).click();let first,melodyTicks;
     for(const arrangement of ['melody','chords']){
      await page.locator('#songArrangement').selectOption(arrangement);
      const pending=page.waitForEvent('download');await page.locator('#exportSong').click();const download=await pending;
      const bytes=new Uint8Array(await fs.readFile(await download.path()));
      const recovered=decodeStoryMidi(arrangement==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms),event=recovered.events[0];
      assert.equal(event.predicate,item.predicate);assert.equal(recovered.runtime_state,item.state);assert.equal(recovered.speech_act,item.act||'assertion');
      assert.deepEqual(event.scopes,item.scopes);assert.deepEqual(event.arguments.map(a=>a.role),item.roles);assert.deepEqual(event.arguments.map(a=>a.entity),item.roles.map((_,i)=>i));
      assert.equal(event.condition,item.condition);if(item.plural)assert.equal(recovered.entities[1].plural,true);
      assert.equal(recovered.events.length,item.before?2:1);
      if(item.before){assert.deepEqual(recovered.relations,[{kind:'before',events:[0,1]}]);assert.equal(recovered.events[1].predicate,'erase_stored_object');assert.equal(recovered.events[1].arguments[1].entity,0);}
      if(first)assert.deepEqual(recovered,first);else first=recovered;
      const {notes}=notesFromMidi(bytes,{allowPolyphony:true}),ticks=Math.max(...notes.map(n=>n.end_tick));
      if(arrangement==='melody')melodyTicks=ticks;else {assert(ticks<melodyTicks);assert(notes.some((n,i)=>i&&n.start_tick===notes[i-1].start_tick),'Compact export must contain simultaneous notes');}
      report.downloads.push({text:item.text,arrangement,sha256:createHash('sha256').update(bytes).digest('hex'),ticks,...(arrangement==='chords'?{shorterPercent:100*(1-ticks/melodyTicks)}:{})});
     }
    }
   }finally{await context.close();}
  }
  const context=await browser.newContext({viewport:{width,height:900}}),page=await context.newPage();
  try{
   await page.goto(site,{waitUntil:'networkidle'});
   for(const text of ['Nora saved the game.','The box is stored.']){
    await translate(page,text);const choice=page.getByRole('button',{name:'Another meaning',exact:true});await choice.waitFor();await layout(page,width);
    assert.equal(await add(page).count(),0);await choice.click();assert.equal(await add(page).count(),0);report.choices.push({width,text,status:'pass'});
   }
   for(const text of ['Nora saved the file to the folder.','The file was saved by Nora.','Nora deleted the stored file.']){
    await translate(page,text);await page.locator('#candidateList').waitFor();assert.equal(await add(page).count(),0);report.unsupported.push({width,text,status:'pass'});
   }
   await translate(page,'Nora saved the file.');await add(page).waitFor();const disclosure=page.locator('#candidateList details.meaning-explanation');
   assert.equal(await disclosure.evaluate(e=>e.open),false);await disclosure.locator('summary').focus();await page.keyboard.press('Enter');assert.equal(await disclosure.evaluate(e=>e.open),true);
   await page.keyboard.press('Space');assert.equal(await disclosure.evaluate(e=>e.open),false);assert.equal(await add(page).isVisible(),true);report.keyboard.push({width,status:'pass'});
   await page.locator('#sourceInput').fill('Nora rescued the file.');assert.equal(await add(page).count(),0);report.staleCleared.push({width,status:'pass'});
  }finally{await context.close();}
 }
 report.status='pass';
}catch(error){report.status='fail';report.error=error.stack;throw error;}
finally{await browser.close();await fs.writeFile(output,JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({site,status:report.status,layouts:report.layouts.length,downloads:report.downloads.length,choices:report.choices.length,unsupported:report.unsupported.length,keyboard:report.keyboard.length,staleCleared:report.staleCleared.length,error:report.error}));}
