// Whole-input browser audit. Intentions are not supplied to the music decoder.
import fs from 'node:fs/promises';
import {createRequire} from 'node:module';
import {createHash} from 'node:crypto';
import {isDeepStrictEqual} from 'node:util';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {expandChordMidi,compactChordPerformance} from '../pages/compact_chords.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {decodeStrictMusicMidi} from '../pages/strict_music_decoder.mjs';

const require=createRequire(import.meta.url);
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8766/',filter='',answerFile='']=process.argv.slice(2);
const read=async path=>JSON.parse(await fs.readFile(new URL('../'+path,import.meta.url),'utf8'));
const inputPath='tests/full_audit_2026_11_22_intentions.json';
const corpus=await read(inputPath),authority=await read('pages/data/index.json');
const records=(await read('pages/data/foundation_preview_candidates.json')).records;
const supplied=answerFile?JSON.parse(await fs.readFile(answerFile,'utf8')):{};
const directory=new URL('../reports/full_audit_2026_11_22/',import.meta.url);
await fs.mkdir(new URL('midi/',directory),{recursive:true});
const allDrafts={allowDraftQuantified:true,allowDraftQuestionContent:true,allowDraftAcquisition:true,
 allowDraftContextualContent:true,allowDraftContextualInquiry:true,allowDraftCuriosity:true,
 allowDraftPain:true,allowDraftPainStimulus:true,allowDraftPainComparison:true,allowDraftPainPreference:true,
 allowDraftDrinking:true,allowDraftDesiredDrinking:true,allowDraftOwnership:true,allowDraftDesiredOwnership:true,
 allowDraftDesiredAvailability:true,allowDraftCustodyOpportunity:true,allowDraftInformationPassage:true};
const hash=bytes=>createHash('sha256').update(bytes).digest('hex');
const facts=bytes=>{
 const p=notesFromMidi(bytes,{allowPolyphony:true}),scale=(p.tempos[0]?.value||500000)/p.division/1e6;
 const attacks=new Map();for(const n of p.notes)attacks.set(n.start_tick,(attacks.get(n.start_tick)||0)+1);
 return {notes:p.notes.length,seconds:Math.max(...p.notes.map(n=>n.end_tick))*scale,
  chord_attacks:[...attacks.values()].filter(n=>n>=3).length,sha256:hash(bytes)};
};
const inspect=page=>page.evaluate(()=>{
 const visible=e=>e&&e.getClientRects().length;
 return {summary:document.querySelector('#decisionSummary')?.textContent,
  text:[...document.querySelectorAll('#candidateList,#output')].filter(visible).map(e=>e.innerText).join('\n').slice(0,6000),
  buttons:[...document.querySelectorAll('#candidateList button,#output button')].filter(visible).map(b=>({text:b.textContent.trim(),disabled:b.disabled})),
  page_width:document.documentElement.scrollWidth,viewport:innerWidth};
});
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
const report={timestamp:new Date().toISOString(),site,viewport:390,
 intentions_sha256:hash(await fs.readFile(new URL('../'+inputPath,import.meta.url))),
 decoder_inputs:'Downloaded MIDI and shared public atom and foundation dictionaries only. No text, expected IR, original event list, hashes or composer metadata.',results:[]};
const selected=filter?new Set(filter.split(',')):null;
try{
 for(const entry of corpus.cases.filter(c=>!selected||selected.has(c.id))){
  const context=await browser.newContext({viewport:{width:390,height:844},acceptDownloads:true});
  const page=await context.newPage();page.setDefaultTimeout(16000);
  const row={id:entry.id,text:entry.text,errors:[]};
  page.on('pageerror',e=>row.errors.push(e.message));
  try{
   await page.goto(site,{waitUntil:'domcontentloaded'});
   await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
   await page.locator('#sourceInput').fill(entry.text);await page.locator('#analyzeButton').click();
   await page.waitForFunction(()=>!document.querySelector('#analyzeButton').disabled);
   row.initial=await inspect(page);row.answers=[];
   for(const action of supplied[entry.id]||[]){
    if(action.button)await page.locator('#candidateList').getByRole('button',{name:action.button,exact:true}).click();
    else if(action.referent){
     await page.locator('#candidateList input:visible').first().fill(action.referent);
     await page.getByRole('button',{name:'Use this referent',exact:true}).click();
    }
    row.answers.push(action);
    await page.waitForTimeout(100);
   }
   row.final=await inspect(page);
   const add=page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true});
   if(await add.count()===1&&await add.isEnabled()){
    await add.click();const bytes={};row.music={};
    for(const mode of ['melody','chords']){
     await page.locator('#songArrangement').selectOption(mode);
     const download=page.waitForEvent('download');await page.locator('#exportSong').click();
     bytes[mode]=new Uint8Array(await fs.readFile(await (await download).path()));
     const name='midi/'+entry.id+'-'+mode+'.mid';await fs.writeFile(new URL(name,directory),bytes[mode]);
     row.music[mode]={path:name,...facts(bytes[mode])};
    }
    const expanded=expandChordMidi(bytes.chords,authority.atoms);
    row.heard=await decodeSupportedMeaningWithDrafts(bytes.melody,authority.atoms,records,{allowDraft:true});
    row.chords_same_meaning=isDeepStrictEqual(row.heard,await decodeSupportedMeaningWithDrafts(expanded,authority.atoms,records,{allowDraft:true}));
    const noteTuples=b=>notesFromMidi(b).notes.map(n=>[n.midi,n.start_tick,n.end_tick]);
    row.chords_same_notes=isDeepStrictEqual(noteTuples(bytes.melody),noteTuples(expanded));
    try{
     const observation=decodeStrictMusicMidi(bytes.melody,authority.atoms,allDrafts);
     const parsed=notesFromMidi(bytes.melody),scale=parsed.tempos[0].value/parsed.division/1e6;
     row.token_seconds={};row.token_counts={};
     for(const t of observation.tokens){
      const kind=t.local_code?'personal_word_frame':t.sound_code!==undefined?'convention_frame':t.kind;
      row.token_seconds[kind]=(row.token_seconds[kind]||0)+(t.end_tick-t.start_tick)*scale;
      row.token_counts[kind]=(row.token_counts[kind]||0)+1;
     }
     row.root_onset_seconds=compactChordPerformance(bytes.melody,authority.atoms,{preview:true}).firstRoot?.atSeconds??null;
    }catch(error){row.observation_error=error.message;}
   }
  }catch(error){row.error=error.message;}
  finally{await context.close();}
  report.results.push(row);
  const output=answerFile?'clarified.json':filter?'subset.json':'initial.json';
  await fs.writeFile(new URL(output,directory),JSON.stringify(report,null,2)+'\n');
  console.log(row.id,row.heard?'scored '+row.music.chords.seconds.toFixed(2)+'s':row.error||row.final?.summary||'no whole score');
 }
}finally{await browser.close();}
