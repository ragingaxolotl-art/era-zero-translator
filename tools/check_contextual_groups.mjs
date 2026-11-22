import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const {chromium}=createRequire(import.meta.url)(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8776/',output='/tmp/dba-groups-browser-1122']=process.argv.slice(2);
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
await fs.mkdir(output,{recursive:true});
const cases=[
 {text:'The gate was wide, then the board is not narrow.',operator:'sequence',scopes:[[{operator:'time',relation:'before_speech'}],[{operator:'negation'}]]},
 {text:'The gate is wide and the board is narrow.',operator:'all_of'},
 {text:'If the gate is wide [0], then the board is narrow [2].',operator:'conditional',states:[0,2]},
 {text:'The gate is wide or the board is narrow.',operator:'any_of',choice:'any_of'},
 {text:'The gate is wide or the board is narrow.',operator:'exactly_one',choice:'exactly_one'},
 {text:'The gate is wide and the board is hot.',operator:'all_of',norms:['wide','hot'],thermal:true}
];
const report={site,timestamp:new Date().toISOString(),browser:'Chromium viewport emulation; not physical iOS/Safari',layouts:[],exports:[],clarifications:[]};
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
   if(row.choice){
    await page.getByRole('button',{name:'Translate all clauses',exact:true}).click();
    assert.equal(await add().count(),0);await page.getByLabel('Meaning of or',{exact:true}).selectOption(row.choice);
    report.clarifications.push({text:row.text,choice:row.choice,width});
   }
   if(row.thermal)await page.getByLabel('Clause 2 standard type',{exact:true}).selectOption('contextual');
   await page.getByRole('button',{name:'Translate all clauses',exact:true}).click();await add().waitFor();
   assert.match(await page.locator('#sentenceReadiness').innerText(),/Whole sentence ready/);
   const heading=page.locator('#meaningTitle');assert((await heading.innerText()).length<180);
   assert(!/thermodynamic_temperature|physical_width/.test(await heading.innerText()));
   const meaningDetails=page.locator('#meaningDetails');assert.equal(await meaningDetails.getAttribute('open'),null);
   const layout=await page.evaluate(()=>{const el=document.querySelector('#meaningTitle'),r=document.createRange();r.selectNodeContents(el);return {viewport:innerWidth,document:document.documentElement.scrollWidth,headingRight:Math.max(...Array.from(r.getClientRects(),r=>r.right))};});
   assert(layout.headingRight<=width+1,'Actual heading text must not be clipped');
   await meaningDetails.locator('summary').click();assert.match(await page.locator('#meaningExplanation').innerText(),/local contextual/);
   assert(!/thermodynamic_temperature|physical_width/.test(await page.locator('#meaningExplanation').innerText()));
   await meaningDetails.locator('summary').click();
   assert(layout.document<=width+1,JSON.stringify(layout));report.layouts.push({text:row.text,operator:row.operator,...layout});
   if(width===390){
    await add().click();let melodyEnd;
    for(const mode of ['melody','chords']){
     await page.locator('#songArrangement').selectOption(mode);
     const downloading=page.waitForEvent('download');await page.locator('#exportSong').click();const bytes=await fs.readFile(await (await downloading).path());
     const notes=notesFromMidi(bytes,{allowPolyphony:mode==='chords'}).notes,end=Math.max(...notes.map(n=>n.end_tick));
     const simultaneous=new Map();for(const n of notes)simultaneous.set(n.start_tick,(simultaneous.get(n.start_tick)||0)+1);
     if(mode==='melody')melodyEnd=end;else{assert(end<melodyEnd);assert(Math.max(...simultaneous.values())>=3);}
     const heard=await decodeSupportedMeaningWithDrafts(mode==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms,[],{allowDraft:true});
     assert.equal(heard.operator,row.operator);assert.deepEqual(heard.members.map(m=>m.standard.norm),row.norms||['wide','narrow']);
     assert.deepEqual(heard.members.map(m=>m.runtime_state),row.states||[1,1]);assert.deepEqual(heard.members.map(m=>m.scopes),row.scopes||[[],[]]);
     report.exports.push({text:row.text,mode,end_tick:end,max_simultaneous_notes:Math.max(...simultaneous.values()),meaning:heard});
    }
    await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
   }
  }
  await page.locator('#output').scrollIntoViewIfNeeded();await page.screenshot({path:output+'/ready-'+width+'.png'});
  await page.locator('#sourceInput').fill('The gate is very wide.');assert.equal(await add().count(),0);
  assert.deepEqual(errors,[]);await context.close();
 }
 await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
 console.log(`PASS ${report.layouts.length} group layouts, ${report.exports.length} independently decoded exports and ${report.clarifications.length} explicit alternative choices.`);
}finally{await browser.close();}
