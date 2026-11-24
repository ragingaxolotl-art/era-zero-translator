// DBA_PLAYWRIGHT=/path/to/index.mjs DBA_CHROME=/path/to/chrome node tools/check_ordinary_comparatives_browser.mjs URL REPORT
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import {decodeSupportedMeaningMidi} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const [site,output]=process.argv.slice(2);if(!site||!output)throw Error('Supply site URL and report path.');
const {chromium}=await import(process.env.DBA_PLAYWRIGHT?pathToFileURL(process.env.DBA_PLAYWRIGHT):'playwright');
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const cases=[
 {text:'The cup is hotter than the plate. [0]',choice:'Physical temperature',dimension:'thermodynamic_temperature',relation:'greater_than',state:0,scopes:[]},
 {text:'Was the cup not colder than the plate? [1]',choice:'Physical temperature',dimension:'thermodynamic_temperature',relation:'less_than',state:1,act:'question',scopes:[{operator:'time',relation:'before_speech'},{operator:'negation'}]},
 {text:'Nora will not be heavier than Mira. [2]',choice:'Physical mass',dimension:'mass',relation:'greater_than',state:2,scopes:[{operator:'time',relation:'after_speech'},{operator:'negation'}]},
 {text:'You are lighter than me. [2]',choice:'Physical mass',dimension:'mass',relation:'less_than',state:2,scopes:[],deictic:true},
 {text:'The cup was not hotter than the plate [0] and Nora is conscious [2].',group:['temperature_comparison'],operator:'all_of',states:[0,2]},
 {text:'If the cup is heavier than the plate [1], then the plate is lighter than the cup [2].',group:['mass_comparison','mass_comparison'],operator:'conditional',states:[1,2]},
 {text:'It is colder than that plate. [2]',pronoun:true,dimension:'thermodynamic_temperature',relation:'less_than',state:2,scopes:[]}
];
const report={timestamp:new Date().toISOString(),site,layouts:[],downloads:[],otherMeanings:[],unsupported:[],staleCleared:[]};
const browser=await chromium.launch({headless:true,...(process.env.DBA_CHROME?{executablePath:process.env.DBA_CHROME}:{})});
const add=page=>page.locator('#addSentenceToSong');
async function translate(page,text){await page.locator('#sourceInput').fill(text);await page.locator('#analyzeButton').click();await page.waitForFunction(()=>!document.getElementById('analyzeButton').disabled);}
async function layout(page,width){
 const bounds=await page.evaluate(()=>({scroll:document.documentElement.scrollWidth,controls:[...document.querySelectorAll('#candidateList input,#candidateList select,#candidateList button,#output button')].filter(e=>e.getClientRects().length).map(e=>({label:e.textContent,left:e.getBoundingClientRect().left,right:e.getBoundingClientRect().right}))}));
 assert(bounds.scroll<=width+1,JSON.stringify(bounds));for(const c of bounds.controls)assert(c.left>=0&&c.right<=width+1,c.label);
}
try{
 for(const width of [320,390,768]){
  for(const item of cases){
   const context=await browser.newContext({viewport:{width,height:900},acceptDownloads:true}),page=await context.newPage(),errors=[];
   page.on('pageerror',e=>errors.push(e.message));
   try{
    await page.goto(site,{waitUntil:'networkidle',timeout:60000});await translate(page,item.text);await layout(page,width);
    assert.equal(await add(page).isVisible(),false);
    if(item.group){
     for(const [i,value] of item.group.entries())await page.getByLabel(`Clause ${i+1} comparison meaning`,{exact:true}).selectOption(value);
     await page.getByRole('button',{name:'Translate all clauses',exact:true}).click();
    }else if(item.pronoun){
     await page.locator('#candidateList input').fill('the cup');
     await page.getByLabel('comparison meaning',{exact:true}).selectOption('temperature_comparison');
     await page.getByRole('button',{name:'Translate with these referents',exact:true}).click();
    }else await page.getByRole('button',{name:item.choice,exact:true}).click();
    await add(page).waitFor({state:'visible',timeout:30000});assert.match(await page.locator('#sentenceReadiness').innerText(),/Whole sentence ready/);
    assert.equal(await page.locator('#sourceInput').inputValue(),item.text);await layout(page,width);assert.deepEqual(errors,[]);
    report.layouts.push({width,text:item.text,status:'pass'});
    if(width===390){
     await add(page).click();let first,melodyTicks;
     for(const arrangement of ['melody','chords']){
      await page.locator('#songArrangement').selectOption(arrangement);const pending=page.waitForEvent('download');await page.locator('#exportSong').click();const file=await pending;
      const bytes=new Uint8Array(await fs.readFile(await file.path())),meaning=decodeSupportedMeaningMidi(arrangement==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms);
      if(item.group){assert.equal(meaning.operator,item.operator);assert.deepEqual(meaning.members.map(m=>m.runtime_state),item.states);if(item.operator==='all_of'){assert.equal(meaning.members[0].dimension,'thermodynamic_temperature');assert.deepEqual(meaning.members[0].scopes,[{operator:'time',relation:'before_speech'},{operator:'negation'}]);assert.equal(meaning.members[1].predicate,'LIF:011');}else{assert.equal(meaning.members[0].relation,'greater_than');assert.equal(meaning.members[1].relation,'less_than');}}
      else {assert.equal(meaning.dimension,item.dimension);assert.equal(meaning.relation,item.relation);assert.equal(meaning.runtime_state,item.state);assert.equal(meaning.speech_act,item.act||'assertion');assert.deepEqual(meaning.scopes,item.scopes);if(item.deictic)assert.deepEqual(Object.values(meaning.participants).map(p=>p.role),['addressee','speaker']);}
      if(first)assert.deepEqual(meaning,first);else first=meaning;
      const {notes}=notesFromMidi(bytes,{allowPolyphony:true}),ticks=Math.max(...notes.map(n=>n.end_tick));
      if(arrangement==='melody')melodyTicks=ticks;else {assert(ticks<melodyTicks);assert(notes.some((n,i)=>i&&n.start_tick===notes[i-1].start_tick));}
      report.downloads.push({text:item.text,arrangement,sha256:createHash('sha256').update(bytes).digest('hex'),ticks,...(arrangement==='chords'?{shorterPercent:100*(1-ticks/melodyTicks)}:{})});
     }
    }
    await page.locator('#sourceInput').fill('Changed sentence');assert.equal(await add(page).isVisible(),false);report.staleCleared.push({width,text:item.text,status:'pass'});
   }finally{await context.close();}
  }
  const context=await browser.newContext({viewport:{width,height:900}}),page=await context.newPage();
  try{
   await page.goto(site,{waitUntil:'networkidle'});
   for(const text of ['The lamp is lighter than the lantern.','Nora is hotter than Mira.']){
    await translate(page,text);await page.getByRole('button',{name:'Another meaning',exact:true}).click();
    assert.equal(await add(page).isVisible(),false);assert.equal(await page.locator('#sourceInput').inputValue(),text);report.otherMeanings.push({width,text,status:'pass'});
   }
   for(const text of ['The cup is much hotter than the plate.','The cup is heavier than the plate by two kilograms.']){
    await translate(page,text);assert.equal(await add(page).isVisible(),false);assert.equal(await page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true}).count(),0);report.unsupported.push({width,text,status:'pass'});
   }
  }finally{await context.close();}
 }
 report.status='pass';
}catch(error){report.status='fail';report.error=error.stack;throw error;}
finally{await browser.close();await fs.writeFile(output,JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({site,status:report.status,layouts:report.layouts.length,downloads:report.downloads.length,otherMeanings:report.otherMeanings.length,unsupported:report.unsupported.length,staleCleared:report.staleCleared.length,error:report.error}));}
