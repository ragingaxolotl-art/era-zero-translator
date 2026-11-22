// Browser acceptance uses actual downloads and an independent score decoder.
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {storyWords} from '../pages/story_words.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8777/',output='/tmp/dba-placement-browser-1122']=process.argv.slice(2);
await fs.mkdir(output,{recursive:true});
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const placement=storyWords.find(w=>w.word==='put').id;
const cases=[
 {text:'We need to put the box at the gate.',scopes:['modality_necessary']},
 {text:'Nora put the box at the gate.',scopes:['time_before_speech']},
 {text:'The awake robot is placing the full box at the closed gate. [2]',scopes:['aspect_ongoing'],state:2},
 {text:'If Nora places the box at the gate, Mira will not hold the rope. [0]',scopes:[],state:0,condition:true},
 {text:"Please don't put the box at the gate.",scopes:['negation'],act:'command'},
 {text:'We put the box at the gate.',scopes:[],tense:'Present time'},
 {text:'We put the box at the gate.',scopes:['time_before_speech'],tense:'A past event'}
];
const report={site,timestamp:new Date().toISOString(),browser:'Chromium viewports; not physical iOS/Safari',layouts:[],exports:[],questions:[],unsupported:[]};
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
try{
  for(const width of [320,390,768]){
    const context=await browser.newContext({viewport:{width,height:844},acceptDownloads:true});
    const page=await context.newPage(),errors=[];page.on('pageerror',error=>errors.push(error.message));
    await page.goto(site,{waitUntil:'domcontentloaded'});
    await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
    const translate=async text=>{await page.locator('#sourceInput').fill(text);await page.locator('#analyzeButton').click();await page.waitForFunction(()=>!document.querySelector('#analyzeButton').disabled);};
    const add=()=>page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true});
    for(const row of cases){
      await translate(row.text);
      if(row.tense){assert.equal(await add().count(),0);await page.getByRole('button',{name:row.tense,exact:true}).click();}
      await add().waitFor();
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
          else{assert(end<melodyEnd,'Compact export must actually be shorter');assert(Math.max(...simultaneous.values())>=3,'Compact export must contain simultaneous voices');}
          const decoded=await decodeSupportedMeaningWithDrafts(mode==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms,[],{allowDraft:true});
          const event=decoded.events[0];
          assert.equal(event.predicate,placement);assert.deepEqual(event.scopes,row.scopes);
          assert.equal(decoded.runtime_state,row.state??1);assert.equal(decoded.speech_act,row.act||'assertion');
          assert.deepEqual(event.arguments.map(a=>a.role),['actor','target','destination']);
          assert.deepEqual(event.arguments.map(a=>a.entity),[0,1,2]);
          if(row.condition){assert.deepEqual(decoded.relations,[{kind:'condition',events:[0,1]}]);assert.deepEqual(decoded.events[1].scopes,['time_after_speech','negation']);}
          report.exports.push({text:row.text,mode,end_tick:end,max_simultaneous_notes:Math.max(...simultaneous.values()),meaning:decoded});
        }
        await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
      }
    }
    for(const text of ['Nora placed Mira at the gate.','Nora put the file at the gate.','Nora placed the box at the folder.']){
      await translate(text);
      const other=page.getByRole('button',{name:'Another meaning',exact:true});await other.waitFor();
      assert.equal(await add().count(),0);await other.click();assert.equal(await add().count(),0);
      report.questions.push({text,width,otherMeaningRemainsUnresolved:true});
    }
    for(const text of ['Nora put the box on the table.','Nora put only the box at the gate.','The box was put at the gate.']){
      await translate(text);assert.equal(await add().count(),0);report.unsupported.push({text,width});
    }
    await translate('Nora put the full box at the closed gate.');await add().waitFor();
    await page.locator('#candidateList').scrollIntoViewIfNeeded();
    await page.screenshot({path:output+'/ready-'+width+'.png'});
    await page.locator('#sourceInput').fill('Nora put only the box at the gate.');
    assert.equal(await add().count(),0);
    assert.deepEqual(errors,[]);await context.close();
  }
  await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
  console.log(`PASS ${report.layouts.length} sentence layouts, ${report.exports.length} independently decoded exports with shorter polyphonic chords, and ${report.questions.length} ambiguity / ${report.unsupported.length} unsupported checks.`);
}finally{await browser.close();}
