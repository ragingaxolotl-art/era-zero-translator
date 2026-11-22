// Browser acceptance uses actual downloads and an independent score decoder.
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {storyWords} from '../pages/story_words.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8773/',output='/tmp/dba-holding-browser-1122']=process.argv.slice(2);
await fs.mkdir(output,{recursive:true});
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const word=name=>storyWords.find(w=>w.word===(name==='hold'?'physical holding foundation':name)).id;
const cases=[
  {text:'We need to hold the rope.',verb:'hold',scopes:['modality_necessary']},
  {text:'Nora held the box.',verb:'hold',scopes:['time_before_speech']},
  {text:'The awake robot is holding the full box.',verb:'hold',scopes:['aspect_ongoing']},
  {text:'If Nora holds the rope, Mira will not release it.',verb:'release',event:1,scopes:['time_after_speech','negation'],actor:2},
  {text:"Please don't hold the box.",verb:'hold',scopes:['negation'],act:'command'}
];
const report={site,timestamp:new Date().toISOString(),browser:'Chromium viewports; not physical iOS/Safari',layouts:[],exports:[],questions:[]};
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
          const event=decoded.events[row.event||0];
          assert.equal(event.predicate,word(row.verb));assert.deepEqual(event.scopes,row.scopes);
          assert.equal(decoded.runtime_state,row.state??1);assert.equal(decoded.speech_act,row.act||'assertion');
          assert.deepEqual(event.arguments.map(a=>a.entity),[row.actor??0,1]);
          if(row.event)assert.deepEqual(decoded.relations,[{kind:'condition',events:[0,1]}]);
          report.exports.push({text:row.text,mode,end_tick:end,max_simultaneous_notes:Math.max(...simultaneous.values()),meaning:decoded});
        }
        await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
      }
    }
    for(const text of ['Nora holds Mira.','Nora holds the box or the opinion.','Nora holds the file.']){
      await translate(text);
      const other=page.getByRole('button',{name:'Another meaning',exact:true});await other.waitFor();
      assert.equal(await add().count(),0);await other.click();assert.equal(await add().count(),0);
      report.questions.push({text,width,otherMeaningRemainsUnresolved:true});
    }
    await translate('Nora holds the box.');await add().waitFor();
    await page.locator('#candidateList').scrollIntoViewIfNeeded();
    await page.screenshot({path:output+'/ready-'+width+'.png'});
    await page.locator('#sourceInput').fill('Nora holds only the box.');
    assert.equal(await add().count(),0);
    assert.deepEqual(errors,[]);await context.close();
  }
  await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
  console.log(`PASS ${report.layouts.length} sentence layouts, ${report.exports.length} independently decoded exports with shorter polyphonic chords, and ${report.questions.length} ambiguity checks.`);
}finally{await browser.close();}
