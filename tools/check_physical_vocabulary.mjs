// Browser acceptance through the public controls and downloaded song MIDI.
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {storyWords} from '../pages/story_words.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8769/',output='/tmp/dba-physical-browser-1122']=process.argv.slice(2);
await fs.mkdir(output,{recursive:true});
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const word=name=>storyWords.find(w=>w.word===name).id;
const cases=[['We need to pull the full box.','pull',['modality_necessary']],
  ['Nora released the rope.','release',['time_before_speech']],['The empty bottle fell.','fall',['time_before_speech']],
  ['Please do not drop the box.','drop',['negation']],['The bottle is not full.','full',['negation']]];
const report={site,timestamp:new Date().toISOString(),browser:'Chromium viewports; not physical iOS/Safari',layouts:[],exports:[],questions:[]};
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
try{
  for(const width of [320,390,768]){
    const context=await browser.newContext({viewport:{width,height:844},acceptDownloads:true});
    const page=await context.newPage(),errors=[];page.on('pageerror',error=>errors.push(error.message));
    await page.goto(site,{waitUntil:'domcontentloaded'});
    await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
    const translate=async text=>{await page.locator('#sourceInput').fill(text);await page.locator('#analyzeButton').click();await page.waitForFunction(()=>!document.querySelector('#analyzeButton').disabled);};
    for(const [text,predicate,scopes] of cases){
      await translate(text);
      const add=page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true});
      await add.waitFor();
      assert.match(await page.locator('#decisionSummary:visible, #sentenceReadiness:visible').first().innerText(),/Whole sentence ready/);
      const layout=await page.evaluate(()=>({viewport:innerWidth,document:document.documentElement.scrollWidth}));
      assert(layout.document<=width+1,JSON.stringify(layout));report.layouts.push({text,...layout});
      if(width===390){
        await add.click();
        for(const mode of ['melody','chords']){
          await page.locator('#songArrangement').selectOption(mode);
          const downloading=page.waitForEvent('download');await page.locator('#exportSong').click();
          const bytes=await fs.readFile(await (await downloading).path());
          const decoded=await decodeSupportedMeaningWithDrafts(mode==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms,[],{allowDraft:true});
          assert.equal(decoded.events[0].predicate,word(predicate));assert.deepEqual(decoded.events[0].scopes,scopes);
          if(text.startsWith('We'))assert.deepEqual(decoded.events[0].arguments[1].properties,[word('full')]);
          if(text.startsWith('The empty'))assert.deepEqual(decoded.events[0].arguments[0].properties,[word('empty')]);
          if(text.startsWith('Please'))assert.equal(decoded.speech_act,'command');
          report.exports.push({text,mode,meaning:decoded});
        }
        await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
      }
    }
    for(const text of ['Nora dropped the subject.','The price fell.','The promise is empty.','I am full.']){
      await translate(text);
      const other=page.getByRole('button',{name:'Another meaning',exact:true});await other.waitFor();
      assert.equal(await page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true}).count(),0);
      await other.click();
      assert.equal(await page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true}).count(),0);
      report.questions.push({text,width,otherMeaningRemainsUnresolved:true});
    }
    await translate('Nora dropped the full box.');
    await page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true}).waitFor();
    await page.locator('#sourceInput').scrollIntoViewIfNeeded();
    await page.screenshot({path:output+'/ready-'+width+'.png'});
    await page.locator('#sourceInput').fill('Nora dropped the subject.');
    assert.equal(await page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true}).count(),0);
    assert.deepEqual(errors,[]);await context.close();
  }
  await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
  console.log(`PASS ${report.layouts.length} sentence layouts, ${report.exports.length} independently decoded exports and ${report.questions.length} ambiguity checks.`);
}finally{await browser.close();}
