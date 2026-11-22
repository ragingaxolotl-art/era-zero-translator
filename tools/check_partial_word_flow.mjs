import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8775/',output='/tmp/dba-partial-browser-1122']=process.argv.slice(2);
await fs.mkdir(output,{recursive:true});
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const report={site,timestamp:new Date().toISOString(),browser:'Chromium viewport emulation; not physical iOS/Safari',layouts:[],missing:[],exports:[],sketches:[]};
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
try{
 for(const width of [320,390,768]){
  const context=await browser.newContext({viewport:{width,height:844},acceptDownloads:true}),page=await context.newPage(),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  await page.goto(site,{waitUntil:'domcontentloaded'});await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
  const translate=async text=>{await page.locator('#sourceInput').fill(text);await page.locator('#analyzeButton').click();await page.waitForFunction(()=>!document.querySelector('#analyzeButton').disabled);};
  const add=()=>page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true});
  for(const text of ['Nora copied only the file.','The file was deleted.','Nora copied the file to the folder.',
   'Nora repaired the gate with a tool.','The box is full of water.','Nora holds only the rope.']){
   await translate(text);assert.equal(await add().count(),0);
   assert.match(await page.locator('#decisionSummary').innerText(),/Sentence structure not yet supported/);
   const details=page.locator('.partial-word-details');await details.waitFor();
   assert.equal(await details.getAttribute('open'),null);
   assert.equal(await page.getByRole('button',{name:'Add word sketch to song',exact:true}).isVisible(),false);
   const summary=details.locator('summary');assert.match(await summary.innerText(),/not a sentence translation/);
   await summary.focus();await page.keyboard.press('Enter');
   await details.locator('#wordScore').waitFor();
   assert.match(await details.locator('#wordScore').innerText(),/Participants, relationships and scope are not translated/);
   if(text.includes('only')){
    const only=details.locator('.phrase-term').filter({has:page.locator('b',{hasText:/^only$/})});
    assert.match(await only.innerText(),/Scope word · not represented/);
    assert.equal(await only.locator('button').count(),0);
    assert(!/only \(name\)/.test(await details.innerText()));
   }
   const layout=await page.evaluate(()=>({viewport:innerWidth,document:document.documentElement.scrollWidth}));
   assert(layout.document<=width+1,JSON.stringify(layout));report.layouts.push({text,...layout});
   await summary.focus();await page.keyboard.press('Space');
   assert.equal(await details.getAttribute('open'),null);
  }
  await page.locator('.unsupported-sentence').scrollIntoViewIfNeeded();
  await page.screenshot({path:output+'/unsupported-'+width+'.png'});
  for(const text of ['Nora zorbled the file.','The lamp is glimmerwise.']){
   await translate(text);assert.equal(await add().count(),0);
   const link=page.getByRole('link',{name:'Find or build this meaning',exact:true});await link.waitFor();
   assert.equal(await link.evaluate(el=>!!el.closest('.partial-word-details')),false);
   report.missing.push({text,width,definitionHelpVisible:true});
  }
  if(width===390){
   await translate('Nora copied only the file.');await page.locator('.partial-word-details summary').click();
   await page.getByRole('button',{name:'Add word sketch to song',exact:true}).click();
   await page.getByRole('button',{name:'Remove line 1',exact:true}).waitFor();
   assert.match(await page.locator('#songLines').innerText(),/Word sketch/);
   await page.reload();await page.getByRole('button',{name:'Remove line 1',exact:true}).waitFor();
   assert.match(await page.locator('#songLines').innerText(),/Word sketch/);
   report.sketches.push({explicitOptIn:true,persistedLabel:'Word sketch'});
   await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
   await translate('Nora will not copy the file.');await add().click();
   for(const mode of ['melody','chords']){
    await page.locator('#songArrangement').selectOption(mode);
    const downloading=page.waitForEvent('download');await page.locator('#exportSong').click();
    const bytes=await fs.readFile(await (await downloading).path());
    const heard=await decodeSupportedMeaningWithDrafts(mode==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms,[],{allowDraft:true});
    assert.equal(heard.events[0].predicate,'CMP:9ea919967152aa85bc1c7169');
    assert.deepEqual(heard.events[0].scopes,['time_after_speech','negation']);report.exports.push({mode,meaning:heard});
   }
   await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
  }
  await translate('Nora copied only the file.');await page.locator('.partial-word-details summary').click();
  await page.locator('#sourceInput').fill('Nora copied the file.');
  assert.equal(await page.getByRole('button',{name:'Add word sketch to song',exact:true}).isVisible(),false);
  assert.deepEqual(errors,[]);await context.close();
 }
 await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
 console.log(`PASS ${report.layouts.length} disclosure layouts, ${report.missing.length} visible missing-word actions, ${report.exports.length} decoded exports and saved opt-in sketch.`);
}finally{await browser.close();}
