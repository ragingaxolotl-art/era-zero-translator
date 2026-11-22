import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {encodeName} from '../pages/names.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8774/',output='/tmp/dba-width-browser-1122']=process.argv.slice(2);
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
await fs.mkdir(output,{recursive:true});
const report={site,timestamp:new Date().toISOString(),browser:'Chromium viewports; not physical iOS/Safari',layouts:[],exports:[],boundaries:[]};
const cases=[
  {text:'The board is wide.',norm:'wide',bearer:'board',scopes:[]},
  {text:'The gate is not narrow. [0]',norm:'narrow',bearer:'gate',state:0,scopes:[{operator:'negation'}]},
  {text:'The box was wide. [2]',norm:'wide',bearer:'box',state:2,scopes:[{operator:'time',relation:'before_speech'}]},
  {text:'Is the board narrow?',norm:'narrow',bearer:'board',act:'question',scopes:[]}
];
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
try{
  for(const width of [320,390,768]){
    const context=await browser.newContext({viewport:{width,height:844},acceptDownloads:true}),page=await context.newPage(),errors=[];
    page.on('pageerror',e=>errors.push(e.message));
    await page.goto(site,{waitUntil:'domcontentloaded'});await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
    const translate=async text=>{await page.locator('#sourceInput').fill(text);await page.locator('#analyzeButton').click();await page.waitForFunction(()=>!document.querySelector('#analyzeButton').disabled);};
    const add=()=>page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true});
    for(const row of cases){
      await translate(row.text);assert.equal(await add().count(),0);
      await page.getByRole('button',{name:'Use physical width',exact:true}).click();
      await add().waitFor();assert.match(await page.locator('#sentenceReadiness').innerText(),/Whole sentence ready/);
      const layout=await page.evaluate(()=>{const range=document.createRange();range.selectNodeContents(document.querySelector('#resultTitle'));return {viewport:innerWidth,document:document.documentElement.scrollWidth,headingRight:range.getBoundingClientRect().right};});
      assert(layout.document<=width+1&&layout.headingRight<=width+1,JSON.stringify(layout));report.layouts.push({text:row.text,...layout});
      if(width===390){
        await add().click();let melodyEnd;
        for(const mode of ['melody','chords']){
          await page.locator('#songArrangement').selectOption(mode);
          const downloading=page.waitForEvent('download');await page.locator('#exportSong').click();
          const bytes=await fs.readFile(await (await downloading).path());
          const timeline=notesFromMidi(bytes,{allowPolyphony:mode==='chords'}),end=Math.max(...timeline.notes.map(n=>n.end_tick));
          const simultaneous=new Map();for(const n of timeline.notes)simultaneous.set(n.start_tick,(simultaneous.get(n.start_tick)||0)+1);
          if(mode==='melody')melodyEnd=end;else{assert(end<melodyEnd);assert(Math.max(...simultaneous.values())>=3);}
          const d=await decodeSupportedMeaningWithDrafts(mode==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms,[],{allowDraft:true});
          assert.equal(d.dimension,'physical_width');assert.equal(d.standard.norm,row.norm);
          assert.deepEqual(d.scopes,row.scopes);assert.equal(d.runtime_state,row.state??1);assert.equal(d.speech_act,row.act||'assertion');
          assert.deepEqual(d.bearer.phonemes,(await encodeName(row.bearer)).phonemes);
          report.exports.push({text:row.text,mode,end_tick:end,max_simultaneous_notes:Math.max(...simultaneous.values()),meaning:d});
        }
        await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
      }
    }
    for(const text of ['The board is wider than the gate.','The board is very wide.','The narrow gate opened.']){
      await translate(text);assert.equal(await add().count(),0,text);report.boundaries.push({text,width,wholeSentenceUnavailable:true});
    }
    await translate('The gate is wide, then the board is narrow.');
    await page.getByRole('button',{name:'Translate all clauses',exact:true}).click();
    await page.locator('#sentenceReadiness').waitFor();
    assert.match(await page.locator('#sentenceReadiness').innerText(),/Whole sentence ready/);
    report.boundaries.push({text:'The gate is wide, then the board is narrow.',width,inverseSupported:true});
    await translate('The board is wide.');await page.locator('#candidateList').scrollIntoViewIfNeeded();
    await page.screenshot({path:output+'/choice-'+width+'.png'});
    await page.getByRole('button',{name:'Use physical width',exact:true}).click();await add().waitFor();
    await page.locator('#sourceInput').fill('The board is very wide.');assert.equal(await add().count(),0);
    assert.deepEqual(errors,[]);await context.close();
  }
  await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
  console.log(`PASS ${report.layouts.length} selected-width layouts, ${report.exports.length} independently decoded exports and ${report.boundaries.length} honest scope boundaries.`);
}finally{await browser.close();}
