import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8777/',output='/tmp/dba-closing-browser-1122']=process.argv.slice(2);
await fs.mkdir(output,{recursive:true});
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const cause='CMP:3019a12938289fa9f3a23237',change='CMP:9a954f78879ed70ce262bdc5',closed='CMP:82a697e83c845e4a7b38b53e';
const cases=[
 {text:'We need to close the gate.',id:cause,scopes:['modality_necessary']},
 {text:'The gate closed.',id:change,scopes:['time_before_speech'],single:true},
 {text:'The awake robot is closing the wide gate. [2]',id:cause,scopes:['aspect_ongoing'],state:2},
 {text:'If Nora closes the gate, Mira might not open it. [0]',id:cause,scopes:[],state:0,condition:true},
 {text:"Please don't shut the gate.",id:cause,scopes:['negation'],act:'command'},
 {text:'The gate was closed.',id:closed,scopes:['time_before_speech'],single:true},
 {text:'We shut the gate.',id:cause,scopes:[],tense:'Present time'},
 {text:'We shut the gate.',id:cause,scopes:['time_before_speech'],tense:'A past event'},
 {text:'The gate was open before Nora closed it.',id:cause,scopes:['time_before_speech'],event:1,before:true}
];
const report={site,timestamp:new Date().toISOString(),browser:'Chromium viewports; not physical iOS/Safari',layouts:[],exports:[],questions:[],unsupported:[]};
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
try{
 for(const width of [320,390,768]){
  const context=await browser.newContext({viewport:{width,height:844},acceptDownloads:true});
  const page=await context.newPage(),errors=[];page.on('pageerror',error=>errors.push(error.message));
  await page.goto(site,{waitUntil:'domcontentloaded'});await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
  const translate=async text=>{await page.locator('#sourceInput').fill(text);await page.locator('#analyzeButton').click();await page.waitForFunction(()=>!document.querySelector('#analyzeButton').disabled);};
  const add=()=>page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true});
  const choose=async()=>{
   for(let i=0;i<8;i++){
    const physical=page.getByRole('button',{name:/relative to the local standard|^Physical closing of/}).filter({visible:true});
    await physical.or(add()).first().waitFor();if(await add().count())break;await physical.click();
   }
   await add().waitFor();
  };
  for(const row of cases){
   await translate(row.text);
   if(row.tense){assert.equal(await add().count(),0);await page.getByRole('button',{name:row.tense,exact:true}).click();}
   await choose();
   assert.match(await page.locator('#decisionSummary:visible, #sentenceReadiness:visible').first().innerText(),/Whole sentence ready/);
   const layout=await page.evaluate(()=>({viewport:innerWidth,document:document.documentElement.scrollWidth}));
   assert(layout.document<=width+1,JSON.stringify(layout));report.layouts.push({text:row.text,...layout});
   if(width===390){
    await add().click();let melodyEnd;
    for(const mode of ['melody','chords']){
     await page.locator('#songArrangement').selectOption(mode);
     const downloading=page.waitForEvent('download');await page.locator('#exportSong').click();
     const bytes=await fs.readFile(await (await downloading).path());
     const timeline=notesFromMidi(bytes,{allowPolyphony:mode==='chords'}),end=Math.max(...timeline.notes.map(n=>n.end_tick));
     const simultaneous=new Map();for(const n of timeline.notes)simultaneous.set(n.start_tick,(simultaneous.get(n.start_tick)||0)+1);
     if(mode==='melody')melodyEnd=end;else{assert(end<melodyEnd);assert(Math.max(...simultaneous.values())>=3);}
     const meaning=await decodeSupportedMeaningWithDrafts(mode==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms,[],{allowDraft:true});
     const event=meaning.events[row.event||0];assert.equal(event.predicate,row.id);assert.deepEqual(event.scopes,row.scopes);
     assert.equal(meaning.runtime_state,row.state??1);assert.equal(meaning.speech_act,row.act||'assertion');
     assert.deepEqual(event.arguments.map(a=>a.role),row.single?['bearer']:['cause','bearer']);
     assert.deepEqual(event.arguments.map(a=>a.entity),row.single?[0]:row.before?[1,0]:[0,1]);
     if(row.before||row.condition)assert.deepEqual(meaning.relations,[{kind:row.before?'before':'condition',events:[0,1]}]);
     report.exports.push({text:row.text,mode,end_tick:end,max_simultaneous_notes:Math.max(...simultaneous.values()),meaning});
    }
    await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
   }
  }
  for(const text of ['Nora closed the file.','Nora shut the window.','The meeting closed.']){
   await translate(text);const other=page.getByRole('button',{name:'Another meaning',exact:true});await other.waitFor();await other.click();
   assert.equal(await add().count(),0);report.questions.push({text,width,otherMeaningRemainsUnresolved:true});
  }
  for(const text of ['The closed gate closed.','Nora closed the open gate.','Nora closed the gate with a lever.','Nora has closed the gate.']){
   await translate(text);assert.equal(await add().count(),0);
   if(text==='The closed gate closed.'||text==='Nora closed the open gate.')assert.match(await page.locator('#candidateList').innerText(),/before and after/);
   report.unsupported.push({text,width});
  }
  await translate('Nora closed the wide gate.');await choose();await page.locator('#candidateList').scrollIntoViewIfNeeded();
  await page.screenshot({path:output+'/ready-'+width+'.png'});
  await page.locator('#sourceInput').fill('Nora closed only the gate.');assert.equal(await add().count(),0);
  assert.deepEqual(errors,[]);await context.close();
 }
 await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
 console.log(`PASS ${report.layouts.length} sentence layouts, ${report.exports.length} independently decoded exports, ${report.questions.length} rejected alternate readings, and ${report.unsupported.length} unsupported constructions.`);
}finally{await browser.close();}
