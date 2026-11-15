// Browser diagnostic. Install Playwright, or set PLAYWRIGHT_MODULE to its module path.
import fs from 'node:fs/promises';
import {createRequire} from 'node:module';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {isDeepStrictEqual} from 'node:util';
import {createHash} from 'node:crypto';
import {notesFromMidi} from '../pages/performance_codec.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';

const [site,outDirectory,width='390',filter='']=process.argv.slice(2);
if(!site||!outDirectory)throw Error('Usage: node tools/audit_translator_field.mjs SITE OUTPUT_DIRECTORY [VIEWPORT_WIDTH] [COMMA_SEPARATED_IDS]');
const require=createRequire(import.meta.url);
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const repo=fileURLToPath(new URL('..',import.meta.url));
const readJson=async name=>JSON.parse(await fs.readFile(path.join(repo,name),'utf8'));
const intentions=await readJson('tests/field_audit/intentions.json');
const {atoms}=await readJson('pages/data/index.json');
const {records}=await readJson('pages/data/foundation_preview_candidates.json');
await fs.mkdir(outDirectory,{recursive:true});

async function inspectPage(page) {
  return page.evaluate(()=>{
    const visible=id=>{const e=document.getElementById(id);return e&&e.getClientRects().length?e:null;};
    const list=visible('candidateList'),output=visible('output');
    const content=(list?.innerText||output?.innerText||'').trim();
    const paragraph=list?.querySelector('article p');
    return {summary:visible('decisionSummary')?.innerText||visible('resultScope')?.innerText||'',
      explanation:paragraph?.innerText||visible('meaningTitle')?.innerText||'',
      detail:content.slice(0,950),
      controls:[...document.querySelectorAll('#results button, #output button')].filter(b=>b.getClientRects().length).map(b=>b.textContent.trim()).slice(0,23),
      alternatives:list?.querySelector('select')?.options.length||0,
      width:document.documentElement.scrollWidth};
  });
}
async function answer(page,action) {
  const list=page.locator('#candidateList');
  if(action.button){
    const option=list.getByRole('button',{name:action.button,exact:true});
    if(await option.isVisible()){await option.click();return action.button;}
    return null;
  }
  const input=list.locator('input[type=text]:visible,input:not([type]):visible').first();
  if(!await input.isVisible())return null;
  await input.fill(action.referent);
  const number=list.locator('select').filter({has:page.locator('option[value=plural]')});
  if(await number.count())await number.first().selectOption('plural');
  const submit=list.getByRole('button',{name:/Use this referent|Translate with these referents|resolve (?:and |& )?render|compose.*(?:sentence|meaning)|use (?:these|the) referents/i}).first();
  if(!await submit.isVisible()||!await submit.isEnabled())return null;
  await submit.click();
  await page.waitForFunction(()=>!Array.from(document.querySelectorAll('#candidateList button')).some(button=>button.disabled&&button.textContent==='Translate with these referents'));
  return action.referent;
}
async function downloadArrangement(page,mode,filename) {
  await page.locator('#songArrangement').selectOption(mode);
  const [download]=await Promise.all([page.waitForEvent('download'),page.locator('#exportSong').click()]);
  await download.saveAs(filename);
  return new Uint8Array(await fs.readFile(filename));
}
function measure(bytes) {
  const {notes,division,tempos}=notesFromMidi(bytes,{allowPolyphony:true});
  const tempo=tempos[0]?.value||500000;
  const starts=new Map();
  for(const note of notes)starts.set(note.start_tick,(starts.get(note.start_tick)||0)+1);
  return {notes:notes.length,three_note_attacks:[...starts.values()].filter(n=>n===3).length,
    seconds:Number((Math.max(...notes.map(n=>n.end_tick))/division*tempo/1e6).toFixed(3)),
    sha256:createHash('sha256').update(bytes).digest('hex')};
}
// The listener receives the downloaded music and shared public language only.
async function listen(bytes) {
  try{return {meaning:await decodeSupportedMeaningWithDrafts(bytes,atoms,records,{allowDraft:true})};}
  catch(error){return {decoder_error:error.message};}
}
async function auditCase(page,test) {
  await page.locator('#sourceInput').fill(test.text);
  await page.locator('#analyzeButton').click();
  await page.waitForFunction(()=>!document.getElementById('analyzeButton').disabled);
  const start=await inspectPage(page),supplied=[];
  for(const action of test.answers||[]){
    const value=await answer(page,action);
    if(value)supplied.push(value);
  }
  const final=await inspectPage(page);
  const row={id:test.id,start,answers:supplied,final};
  const add=page.getByRole('button',{name:'Add to song',exact:true});
  if(await add.count()!==1||!await add.isEnabled())return row;
  await add.click();
  const songLine=page.locator('#songLines li');
  if(await songLine.count()!==1)throw Error('Expected exactly one song line after Add to song.');
  row.song_label=await songLine.first().locator('span').innerText();
  const melody=await downloadArrangement(page,'melody',path.join(outDirectory,test.id+'-melody.mid'));
  const chords=await downloadArrangement(page,'chords',path.join(outDirectory,test.id+'-chords.mid'));
  row.melody=measure(melody);
  row.chords=measure(chords);
  Object.assign(row,await listen(melody));
  try{
    const expanded=expandChordMidi(chords,atoms);
    const n=bytes=>notesFromMidi(bytes).notes.map(note=>[note.midi,note.start_tick,note.end_tick]);
    row.chords_restore_melody=isDeepStrictEqual(n(melody),n(expanded));
    row.chords_restore_reading=isDeepStrictEqual(await listen(expanded),row.meaning?{meaning:row.meaning}:{decoder_error:row.decoder_error});
  }catch(error){row.chord_error=error.message;}
  await songLine.getByRole('button',{name:'Remove line 1'}).click();
  return row;
}
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
try{
  const page=await browser.newPage({viewport:{width:Number(width),height:844},acceptDownloads:true});
  const errors=[];page.on('pageerror',error=>errors.push(error.message));
  page.setDefaultTimeout(18000);await page.goto(site,{waitUntil:'domcontentloaded'});
  await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
  const results=[];
  const selected=filter?new Set(filter.split(',')):null;
  for(const test of intentions.cases.filter(t=>!selected||selected.has(t.id))){
    const result=await auditCase(page,test);
    results.push(result);
    console.log(test.id,result.meaning?'decoded':result.melody?'score without unique decoding':result.final.summary);
    await fs.writeFile(path.join(outDirectory,'observations.json'),JSON.stringify({site,width:Number(width),errors,results},null,2)+'\n');
  }
}finally{await browser.close();}
