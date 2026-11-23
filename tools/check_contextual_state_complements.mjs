import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8777/',output='/tmp/dba-contextual-states-browser-1122']=process.argv.slice(2);
await fs.mkdir(output,{recursive:true});
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const keep='CMP:cac584a394535e4912c75b5a',stay='CMP:ec3a1fad0ed828279e948372';
const cases=[
 {text:'We need to keep the box cold.',id:keep,norm:'cold',scopes:['modality_necessary']},
 {text:'The light box stayed heavy. [2]',id:stay,norm:'heavy',scopes:['time_before_speech'],single:true,state:2,properties:[['light']]},
 {text:'The heavy robot is keeping the light box cold. [0]',id:keep,norm:'cold',scopes:['aspect_ongoing'],state:0,properties:[['heavy'],['light']]},
 {text:'If Nora keeps the box cold, Mira might not empty it.',id:keep,norm:'cold',scopes:[],condition:true},
 {text:'Do not keep the box cold.',id:keep,norm:'cold',scopes:['negation'],act:'command'},
 {text:'Can the box remain wide?',id:stay,norm:'wide',scopes:['ability'],act:'question',single:true},
 {text:'The box stayed cold before Nora filled it.',id:stay,norm:'cold',scopes:['time_before_speech'],single:true,before:true}
];
const report={site,timestamp:new Date().toISOString(),browser:'Chromium viewports; not physical iOS/Safari',layouts:[],exports:[],questions:[],unsupported:[],details:[]};
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
    await physical.or(add()).first().waitFor();if(await add().count())break;await physical.click();
   }
   await add().waitFor();
  };
  for(const row of cases){
   await translate(row.text);
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
     const event=meaning.events[0];assert.equal(event.predicate,row.id);assert.deepEqual(event.scopes,row.scopes);
     assert.deepEqual(event.condition,{contextual_norm:row.norm});
     if(row.properties)assert.deepEqual(event.arguments.map(a=>a.properties.map(p=>p.contextual_norm)),row.properties);
     assert.equal(meaning.runtime_state,row.state??1);assert.equal(meaning.speech_act,row.act||'assertion');
     assert.deepEqual(event.arguments.map(a=>a.role),row.single?['bearer']:['cause','bearer']);
     assert.deepEqual(event.arguments.map(a=>a.entity),row.single?[0]:[0,1]);
     if(row.before||row.condition)assert.deepEqual(meaning.relations,[{kind:row.before?'before':'condition',events:[0,1]}]);
     report.exports.push({text:row.text,mode,end_tick:end,max_simultaneous_notes:Math.max(...simultaneous.values()),meaning});
    }
    await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
   }
  }
  for(const text of ['Nora keeps the box light.','The idea stays cold.']){
   await translate(text);const other=page.getByRole('button',{name:'Another meaning',exact:true});await other.waitFor();await other.click();
   assert.equal(await add().count(),0);report.questions.push({text,width,otherMeaningRemainsUnresolved:true});
  }
  for(const text of ['Nora keeps the box very cold.','The box has stayed cold.','Nora keeps the box cold for two hours.']){
   await translate(text);assert.equal(await add().count(),0);
   report.unsupported.push({text,width});
  }
  await translate('Nora kept the box cold.');await choose();
  const details=page.locator('#candidateList details.meaning-explanation'),toggle=details.locator('summary');
  assert.equal(await details.evaluate(node=>node.open),false);
  await toggle.focus();await page.keyboard.press('Enter');assert.equal(await details.evaluate(node=>node.open),true);
  const explanation=await details.innerText();assert.match(explanation,/cause\s*=\s*Nora/);assert.match(explanation,/temperature/);
  await page.keyboard.press('Space');assert.equal(await details.evaluate(node=>node.open),false);
  assert(await add().isVisible());assert(await page.getByRole('button',{name:'Play whole passage',exact:true}).isVisible());
  report.details.push({width,keyboardOpenClose:true,meaningRetained:true,actionsOutsideDetails:true});
  await page.locator('#candidateList').scrollIntoViewIfNeeded();
  await page.screenshot({path:output+'/ready-'+width+'.png'});
  await page.locator('#sourceInput').fill('Nora kept only the box cold.');assert.equal(await add().count(),0);
  assert.deepEqual(errors,[]);await context.close();
 }
 await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
 console.log(`PASS ${report.layouts.length} sentence layouts, ${report.exports.length} independently decoded exports, ${report.questions.length} rejected alternate readings, ${report.unsupported.length} unsupported constructions, and ${report.details.length} keyboard disclosures.`);
}finally{await browser.close();}
