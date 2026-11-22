// Browser acceptance uses actual downloads and an independent score decoder.
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {storyWords} from '../pages/story_words.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8778/',output='/tmp/dba-container-browser-1122']=process.argv.slice(2);
await fs.mkdir(output,{recursive:true});
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const word=name=>storyWords.find(w=>w.word===(name==='empty-action'?'empty container':name)).id;
const cases=[
 {text:'We need to fill the bottle.',verb:'fill',scopes:['modality_necessary']},
 {text:'Mira emptied the box.',verb:'empty-action',scopes:['time_before_speech']},
 {text:'The awake robot is filling the cracked bottle. [2]',verb:'fill',scopes:['aspect_ongoing'],state:2},
 {text:'If Nora empties the box, Mira might not fill it. [0]',verb:'fill',event:1,scopes:['modality_possible','negation'],actor:2,state:0},
 {text:"Please don't empty the box.",verb:'empty-action',scopes:['negation'],act:'command'},
 {text:'The box is empty.',verb:'empty',scopes:[],quality:true},
 {text:'The box was empty before Nora filled it.',verb:'fill',event:1,scopes:['time_before_speech'],actor:1,target:0,before:true}
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
          assert.deepEqual(event.arguments.map(a=>a.entity),row.quality?[0]:[row.actor??0,row.target??1]);
          if(row.event)assert.deepEqual(decoded.relations,[{kind:row.before?'before':'condition',events:[0,1]}]);
          report.exports.push({text:row.text,mode,end_tick:end,max_simultaneous_notes:Math.max(...simultaneous.values()),meaning:decoded});
        }
        await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
      }
    }
    for(const text of ['Nora filled the form.','Nora emptied the file.','Nora filled Mira.']){
      await translate(text);
      const other=page.getByRole('button',{name:'Another meaning',exact:true});await other.waitFor();
      assert.equal(await add().count(),0);await other.click();assert.equal(await add().count(),0);
      report.questions.push({text,width,otherMeaningRemainsUnresolved:true});
    }
    for(const text of ['Nora filled the empty box.','Nora emptied the full box.','Nora filled the bottle with water.','Nora emptied the box into the bin.']){
      await translate(text);assert.equal(await add().count(),0);
      if(text.includes('empty box')||text.includes('full box'))assert.match(await page.locator('#candidateList').innerText(),/before and after/);
      report.unsupported.push({text,width});
    }
    await translate('Mira emptied the cracked box.');await add().waitFor();
    await page.locator('#candidateList').scrollIntoViewIfNeeded();
    await page.screenshot({path:output+'/ready-'+width+'.png'});
    await page.locator('#sourceInput').fill('Nora emptied only the box.');
    assert.equal(await add().count(),0);
    assert.deepEqual(errors,[]);await context.close();
  }
  await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
  console.log(`PASS ${report.layouts.length} sentence layouts, ${report.exports.length} independently decoded exports with shorter polyphonic chords, and ${report.questions.length} ambiguity / ${report.unsupported.length} unsupported checks.`);
}finally{await browser.close();}
