import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8772/',output='/tmp/dba-diagnostics-browser-1122']=process.argv.slice(2);
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
await fs.mkdir(output,{recursive:true});
const report={site,timestamp:new Date().toISOString(),browser:'Chromium viewports; not physical iOS/Safari',unsupported:[],missing:[],exports:[]};
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
try{
  for(const width of [320,390,768]){
    const context=await browser.newContext({viewport:{width,height:844},acceptDownloads:true}),page=await context.newPage(),errors=[];
    page.on('pageerror',e=>errors.push(e.message));
    await page.goto(site,{waitUntil:'domcontentloaded'});
    await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
    const translate=async text=>{await page.locator('#sourceInput').fill(text);await page.locator('#analyzeButton').click();await page.waitForFunction(()=>!document.querySelector('#analyzeButton').disabled);};
    const add=()=>page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true});
    for(const text of ['The file was deleted.','Nora deleted the file from the folder.','Nora copied the file to the folder.',
      'Nora recalls.','Nora repaired the gate with a tool.','The box is full of water.','Nora copied only the file.']){
      await translate(text);
      assert.match(await page.locator('#decisionSummary').innerText(),/Sentence structure not yet supported/,text);
      const card=page.locator('.unsupported-sentence');assert.equal(await card.locator('h3').innerText(),text);
      if(!text.includes('only'))assert.match(await card.locator('p').innerText(),/already has a dictionary meaning/,text);
      assert.equal(await page.locator('.definition-alias-options').count(),0,text);
      assert.equal(await add().count(),0,text);
      const layout=await page.evaluate(()=>({viewport:innerWidth,document:document.documentElement.scrollWidth}));
      assert(layout.document<=width+1,JSON.stringify(layout));report.unsupported.push({text,...layout});
    }
    await page.locator('.unsupported-sentence').scrollIntoViewIfNeeded();
    await page.screenshot({path:output+'/unsupported-'+width+'.png'});
    for(const text of ['Nora zorbled the file.','The lamp is glimmerwise.','Nora copieded the file.']){
      await translate(text);assert.match(await page.locator('#decisionSummary').innerText(),/Missing definition/,text);
      assert.equal(await add().count(),0);await page.getByRole('link',{name:'Find or build this meaning',exact:true}).waitFor();
      report.missing.push({text,width});
    }
    if(width===390)for(const [text,predicate,scopes] of [
      ['Nora will not copy the file.','CMP:9ea919967152aa85bc1c7169',['time_after_speech','negation']],
      ['Mira might delete the record.','erase_stored_object',['modality_possible']]
    ]){
      await translate(text);await add().click();
      for(const mode of ['melody','chords']){
        await page.locator('#songArrangement').selectOption(mode);
        const downloading=page.waitForEvent('download');await page.locator('#exportSong').click();
        const bytes=await fs.readFile(await (await downloading).path());
        const decoded=await decodeSupportedMeaningWithDrafts(mode==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms,[],{allowDraft:true});
        assert.equal(decoded.events[0].predicate,predicate);assert.deepEqual(decoded.events[0].scopes,scopes);
        assert.deepEqual(decoded.events[0].arguments.map(a=>a.entity),[0,1]);report.exports.push({text,mode,meaning:decoded});
      }
      await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
    }
    await translate('Nora copied the file.');await add().waitFor();
    await page.locator('#sourceInput').fill('Nora copied only the file.');assert.equal(await add().count(),0);
    assert.deepEqual(errors,[]);await context.close();
  }
  await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
  console.log(`PASS ${report.unsupported.length} unsupported-structure layouts, ${report.missing.length} missing-word checks, and ${report.exports.length} independently decoded supported exports.`);
}finally{await browser.close();}
