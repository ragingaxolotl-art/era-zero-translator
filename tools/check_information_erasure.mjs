// Public browser controls -> downloaded MIDI -> independent meaning decoder.
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {ERASURE} from '../pages/information_operations.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8770/',output='/tmp/dba-erasure-browser-1122']=process.argv.slice(2);
await fs.mkdir(output,{recursive:true});
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const cases=[
  {text:'Nora deleted the file.',scopes:['time_before_speech']},
  {text:'We found the program. We deleted it.',event:1,scopes:['time_before_speech'],actor:0,target:1},
  {text:'If Nora finds the file, Mira will not delete it.',event:1,scopes:['time_after_speech','negation'],actor:2,target:1,condition:true},
  {text:'We cannot delete the backup. [0]',scopes:['negation','ability'],state:0},
  {text:'Please do not delete the log.',scopes:['negation'],act:'command'},
  {text:'The routine is deleting the records. [2]',scopes:['aspect_ongoing'],state:2,plural:true}
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
      await translate(row.text);await add().waitFor();
      assert.match(await page.locator('#decisionSummary:visible, #sentenceReadiness:visible').first().innerText(),/Whole sentence ready/);
      const layout=await page.evaluate(()=>({viewport:innerWidth,document:document.documentElement.scrollWidth}));
      assert(layout.document<=width+1,JSON.stringify(layout));report.layouts.push({text:row.text,...layout});
      if(width===390){
        await add().click();
        for(const mode of ['melody','chords']){
          await page.locator('#songArrangement').selectOption(mode);
          const downloading=page.waitForEvent('download');await page.locator('#exportSong').click();
          const bytes=await fs.readFile(await (await downloading).path());
          const decoded=await decodeSupportedMeaningWithDrafts(mode==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms,[],{allowDraft:true});
          const event=decoded.events[row.event||0];
          assert.equal(event.predicate,ERASURE);assert.deepEqual(event.scopes,row.scopes);
          assert.equal(decoded.runtime_state,row.state??1);assert.equal(decoded.speech_act,row.act||'assertion');
          assert.deepEqual(event.arguments.map(a=>a.entity),[row.actor??0,row.target??1]);
          if(row.condition)assert.deepEqual(decoded.relations,[{kind:'condition',events:[0,1]}]);
          if(row.plural)assert.equal(decoded.entities[1].plural,true);
          report.exports.push({text:row.text,mode,meaning:decoded});
        }
        await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
      }
    }
    for(const text of ['Nora deleted Mira.','Nora deleted the file or the child.']){
      await translate(text);
      const other=page.getByRole('button',{name:'Another meaning',exact:true});await other.waitFor();
      assert.equal(await add().count(),0);await other.click();assert.equal(await add().count(),0);
      report.questions.push({text,width,otherMeaningRemainsUnresolved:true});
    }
    await translate('Nora deleted Mira.');
    await page.getByRole('button',{name:'Remove the stored information item',exact:true}).click();
    await add().waitFor();
    await translate('We found the program. We deleted it.');await add().waitFor();
    await page.locator('#candidateList').scrollIntoViewIfNeeded();
    await page.screenshot({path:output+'/ready-'+width+'.png'});
    await page.locator('#sourceInput').fill('Nora deleted only the file.');
    assert.equal(await add().count(),0);
    await page.locator('#analyzeButton').click();
    await page.waitForFunction(()=>!document.querySelector('#analyzeButton').disabled);
    assert.equal(await add().count(),0);
    assert.deepEqual(errors,[]);await context.close();
  }
  await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
  console.log(`PASS ${report.layouts.length} sentence layouts, ${report.exports.length} independently decoded exports and ${report.questions.length} ambiguity checks.`);
}finally{await browser.close();}
