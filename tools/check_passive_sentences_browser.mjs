// DBA_PLAYWRIGHT=/path/to/index.mjs DBA_CHROME=/path/to/chrome node tools/check_passive_sentences_browser.mjs URL REPORT
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import {decodeStoryMidi} from '../pages/story_music.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const [site,output]=process.argv.slice(2);if(!site||!output)throw Error('Supply site URL and report path.');
const {chromium}=await import(process.env.DBA_PLAYWRIGHT?pathToFileURL(process.env.DBA_PLAYWRIGHT):'playwright');
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const save='CMP:58cfa479709294b9809be1b7',copy='CMP:9ea919967152aa85bc1c7169';
const cases=[
 {text:'The file was saved by Nora. [0]',predicate:save,state:0,scopes:['time_before_speech']},
 {text:'The records will not be copied by the routine. [2]',predicate:copy,state:2,scopes:['time_after_speech','negation'],plural:true},
 {text:'Was the gate not closed by Nora?',predicate:'CMP:3019a12938289fa9f3a23237',state:1,scopes:['time_before_speech','negation'],roles:['cause','bearer'],act:'question'},
 {text:'The box is being lifted by the robot. [2]',predicate:'CMP:e1d0059daad4093d8a5ce05c',state:2,scopes:['aspect_ongoing']},
 {text:'We were seen by you. [0]',predicate:'CMP:b937ee54b7c000fafe11d338',state:0,scopes:['time_before_speech'],roles:['experiencer','source'],deictic:true},
 {text:'The file was stored.',predicate:'DAT:000',state:1,scopes:['time_before_speech'],roles:['bearer'],stateOnly:true},
 {text:'The file was saved by Nora. They copied it. [2]',predicate:save,state:2,scopes:['time_before_speech'],chain:true},
 {text:'It was copied by the program.',predicate:copy,state:1,scopes:['time_before_speech'],referent:'the file'}
];
const report={timestamp:new Date().toISOString(),site,layouts:[],downloads:[],choices:[],unsupported:[],keyboard:[],staleCleared:[],queueCleared:[]};
const browser=await chromium.launch({headless:true,...(process.env.DBA_CHROME?{executablePath:process.env.DBA_CHROME}:{})});
const add=page=>page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true});
async function translate(page,text){
 await page.locator('#sourceInput').fill(text);assert.equal(await add(page).count(),0);
 await page.locator('#analyzeButton').click();await page.waitForFunction(()=>!document.getElementById('analyzeButton').disabled);
}
async function layout(page,width){
 const bounds=await page.evaluate(()=>({scroll:document.documentElement.scrollWidth,controls:[...document.querySelectorAll('#candidateList input,#candidateList select,#candidateList button')].filter(e=>e.getClientRects().length).map(e=>({label:e.textContent,left:e.getBoundingClientRect().left,right:e.getBoundingClientRect().right}))}));
 assert(bounds.scroll<=width+1,JSON.stringify(bounds));for(const c of bounds.controls)assert(c.left>=0&&c.right<=width+1,c.label);
}
try{
 for(const width of [320,390,768]){
  // Repeated translations share one page, as in actual use. Exported lines are
  // removed through the visible editor so each next download contains one line.
  const context=await browser.newContext({viewport:{width,height:900},acceptDownloads:true}),page=await context.newPage(),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  try{
   await page.goto(site,{waitUntil:'networkidle',timeout:60000});
   for(const item of cases){
    await translate(page,item.text);
    if(item.referent){await page.locator('#candidateList input').fill(item.referent);await page.getByRole('button',{name:'Use this referent',exact:true}).click();}
    await add(page).waitFor({state:'visible',timeout:30000});await layout(page,width);
    assert.equal(await page.locator('#sourceInput').inputValue(),item.text);assert.deepEqual(errors,[]);report.layouts.push({width,text:item.text,status:'pass'});
    if(width===390){
     await add(page).click();let first,melodyTicks;
     for(const arrangement of ['melody','chords']){
      await page.locator('#songArrangement').selectOption(arrangement);const pending=page.waitForEvent('download');await page.locator('#exportSong').click();const file=await pending;
      const bytes=new Uint8Array(await fs.readFile(await file.path())),meaning=decodeStoryMidi(arrangement==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms),event=meaning.events[0];
      assert.equal(event.predicate,item.predicate);assert.equal(meaning.runtime_state,item.state);assert.equal(meaning.speech_act,item.act||'assertion');assert.deepEqual(event.scopes,item.scopes);
      assert.deepEqual(event.arguments.map(a=>a.role),item.roles||['actor','target']);assert.deepEqual(event.arguments.map(a=>a.entity),item.stateOnly?[0]:[1,0]);
      if(item.plural)assert(meaning.entities[0].plural);if(item.deictic)assert.deepEqual(meaning.entities.map(e=>e.identity),[{kind:'deictic',role:'speaker_group'},{kind:'deictic',role:'addressee'}]);
      assert.equal(meaning.events.length,item.chain?2:1);if(item.chain){assert.equal(meaning.events[1].predicate,copy);assert.deepEqual(meaning.events[1].arguments.map(a=>a.entity),[1,0]);}
      if(first)assert.deepEqual(meaning,first);else first=meaning;
      const {notes}=notesFromMidi(bytes,{allowPolyphony:true}),ticks=Math.max(...notes.map(n=>n.end_tick));
      if(arrangement==='melody')melodyTicks=ticks;else {assert(ticks<melodyTicks);assert(notes.some((n,i)=>i&&n.start_tick===notes[i-1].start_tick));}
      report.downloads.push({text:item.text,arrangement,sha256:createHash('sha256').update(bytes).digest('hex'),ticks,...(arrangement==='chords'?{shorterPercent:100*(1-ticks/melodyTicks)}:{})});
     }
     await page.getByRole('button',{name:'Remove line 1',exact:true}).click();assert.equal(await page.getByRole('button',{name:'Remove line 1',exact:true}).count(),0);report.queueCleared.push({text:item.text,status:'pass'});
    }
    await page.locator('#sourceInput').fill('Changed sentence');assert.equal(await add(page).count(),0);report.staleCleared.push({width,text:item.text,status:'pass'});
   }
   for(const [text,label] of [['The file was saved by the river.','A location or another meaning'],['The game was saved by Nora.','Another meaning']]){
    await translate(page,text);await page.getByRole('button',{name:label,exact:true}).click();assert.equal(await add(page).count(),0);report.choices.push({width,text,status:'pass'});
   }
   for(const text of ['The file has been saved by Nora.','The box was put by Nora.','The full box was emptied by Nora.']){
    await translate(page,text);assert.equal(await add(page).count(),0);report.unsupported.push({width,text,status:'pass'});
   }
   await translate(page,'The file was saved by Nora.');await add(page).waitFor();
   const disclosure=page.locator('#candidateList details.meaning-explanation');assert.equal(await disclosure.evaluate(e=>e.open),false);
   await disclosure.locator('summary').focus();await page.keyboard.press('Enter');assert.equal(await disclosure.evaluate(e=>e.open),true);await page.keyboard.press('Space');assert.equal(await disclosure.evaluate(e=>e.open),false);
   assert(await add(page).isVisible());report.keyboard.push({width,status:'pass'});
  }finally{await context.close();}
 }
 report.status='pass';
}catch(error){report.status='fail';report.error=error.stack;throw error;}
finally{await browser.close();await fs.writeFile(output,JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({site,status:report.status,layouts:report.layouts.length,downloads:report.downloads.length,choices:report.choices.length,unsupported:report.unsupported.length,keyboard:report.keyboard.length,staleCleared:report.staleCleared.length,queueCleared:report.queueCleared.length,error:report.error}));}
