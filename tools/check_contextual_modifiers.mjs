import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8779/',output='/tmp/dba-modifiers-browser-1122']=process.argv.slice(2);
await fs.mkdir(output,{recursive:true});
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const cases=[
 {text:'The wide board fell.',properties:[['wide']],scopes:['time_before_speech']},
 {text:'Nora might not lift the heavy board. [2]',properties:[[],['heavy']],scopes:['modality_possible','negation'],state:2},
 {text:'The heavy robot lifted the light board.',properties:[['heavy'],['light']],scopes:['time_before_speech']},
 {text:'Nora placed the narrow box at the wide gate.',properties:[[],['narrow'],['wide']],scopes:['time_before_speech']},
 {text:'Please lift the rough and wide board. [0]',properties:[[],['rough','wide']],scopes:[],state:0,act:'command'},
 {text:'Nora filled the cold bottle.',properties:[[],['cold']],scopes:['time_before_speech']},
 {text:'Nora lifted the bright board. Mira lowered it.',properties:[[],['bright']],scopes:['time_before_speech'],pronoun:true}
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
    const physical=page.getByRole('button',{name:/relative to the local standard/}).filter({visible:true});
    await physical.or(add()).first().waitFor();
    if(await add().count())break;
    await physical.click();
   }
   await add().waitFor();
  };
  for(const row of cases){
   await translate(row.text);assert.equal(await add().count(),0);await choose();
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
     if(mode==='melody')melodyEnd=end;
     else{assert(end<melodyEnd);assert(Math.max(...simultaneous.values())>=3);}
     const meaning=await decodeSupportedMeaningWithDrafts(mode==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms,[],{allowDraft:true});
     assert.deepEqual(meaning.events[0].arguments.map(a=>a.properties.map(p=>p.contextual_norm)),row.properties);
     assert.deepEqual(meaning.events[0].scopes,row.scopes);assert.equal(meaning.runtime_state,row.state??1);assert.equal(meaning.speech_act,row.act||'assertion');
     if(row.pronoun){assert.equal(meaning.events[1].arguments[1].entity,1);assert.deepEqual(meaning.events[1].arguments[1].properties,[]);}
     report.exports.push({text:row.text,mode,end_tick:end,max_simultaneous_notes:Math.max(...simultaneous.values()),meaning});
    }
    await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
   }
  }
  for(const text of ['Nora lifted the light board.','The wide idea fell.']){
   await translate(text);const other=page.getByRole('button',{name:'Another meaning',exact:true});await other.waitFor();await other.click();
   assert.equal(await add().count(),0);report.questions.push({text,width,otherMeaningRemainsUnresolved:true});
  }
  for(const text of ['Nora lifted the very wide board.','Nora lifted the wider board.','The board stayed wide.']){
   await translate(text);assert.equal(await add().count(),0);report.unsupported.push({text,width});
  }
  await translate('Nora lifted the wide and rough board.');await choose();await page.locator('#candidateList').scrollIntoViewIfNeeded();
  await page.screenshot({path:output+'/ready-'+width+'.png'});
  await page.locator('#sourceInput').fill('Nora lifted only the wide board.');assert.equal(await add().count(),0);
  assert.deepEqual(errors,[]);await context.close();
 }
 await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
 console.log(`PASS ${report.layouts.length} sentence layouts, ${report.exports.length} independently decoded exports, ${report.questions.length} rejected alternate readings, and ${report.unsupported.length} unsupported constructions.`);
}finally{await browser.close();}
