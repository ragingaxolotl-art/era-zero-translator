import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {decodeSupportedMeaningWithDrafts} from '../pages/semantic_music_dispatch.mjs';
import {expandChordMidi} from '../pages/compact_chords.mjs';

const require=createRequire(import.meta.url),{chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site='http://127.0.0.1:8767/',output='/tmp/dba-sentence-flow-1122']=process.argv.slice(2);
await fs.mkdir(output,{recursive:true});
const authority=JSON.parse(await fs.readFile(new URL('../pages/data/index.json',import.meta.url)));
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
const report={site,browser:'Chromium; viewport checks are not physical iOS/Safari tests',timestamp:new Date().toISOString(),layouts:[],meanings:[]};
const missing=['Nora twisted the rope.','Nora stacked the box.','Nora copied the file.','Nora archived the file.',
  'Nora remembers Mira.','Nora zorbled the box.','The lamp is glimmerwise.'];
try{
  for(const width of [320,390,768]){
    const context=await browser.newContext({viewport:{width,height:844},acceptDownloads:true}),page=await context.newPage(),errors=[];
    page.on('pageerror',e=>errors.push(e.message));
    await page.goto(site,{waitUntil:'domcontentloaded'});
    await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
    const translate=async text=>{await page.locator('#sourceInput').fill(text);await page.locator('#analyzeButton').click();await page.waitForFunction(()=>!document.querySelector('#analyzeButton').disabled);};
    for(const text of missing){
      await translate(text);
      assert.match(await page.locator('#decisionSummary').innerText(),/Missing definition/,text);
      const details=page.locator('.definition-alias-options');
      assert.equal(await details.getAttribute('open'),null);
      assert.equal(await page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true}).count(),0);
      await details.locator('summary').focus();await page.keyboard.press('Enter');
      await details.locator('select').waitFor({state:'visible'});
      const measured=await page.evaluate(()=>({viewport:innerWidth,document:document.documentElement.scrollWidth,
        select:document.querySelector('.dictionary-clause select').getBoundingClientRect().width}));
      assert(measured.document<=width+1,`${width}: ${text}: ${JSON.stringify(measured)}`);
      report.layouts.push({text,...measured});
    }
    await page.locator('.dictionary-clause').scrollIntoViewIfNeeded();
    await page.screenshot({path:output+`/picker-${width}.png`,fullPage:false});
    await translate('Nora pushed Mira.');
    assert(await page.getByRole('button',{name:'Physical pushing',exact:true}).isVisible());
    await page.getByRole('button',{name:'Physical pushing',exact:true}).click();
    await page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true}).waitFor();
    // Editing the input invalidates old controls immediately.
    await page.locator('#sourceInput').fill('Nora zorbled Mira.');
    assert.equal(await page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true}).count(),0);
    if(width===390){
      for(const text of ['If Nora opens the hatch, Mira will not leave.','I love you. [2]','Nora loves Eli.']){
        await translate(text);
        const status=page.locator('#decisionSummary:visible, #sentenceReadiness:visible').first();
        assert.match(await status.innerText(),/Whole sentence ready/);
        await page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true}).click();
        for(const mode of ['melody','chords']){
          await page.locator('#songArrangement').selectOption(mode);
          const pending=page.waitForEvent('download');await page.locator('#exportSong').click();const download=await pending;
          const bytes=await fs.readFile(await download.path());
          const decoded=await decodeSupportedMeaningWithDrafts(mode==='chords'?expandChordMidi(bytes,authority.atoms):bytes,authority.atoms,[],{allowDraft:true});
          if(text.startsWith('If'))assert.deepEqual(decoded.events[1].scopes,['time_after_speech','negation']);
          else{assert.equal(decoded.predicate,'CMP:44718c92b66443c0c0f03ad7');assert.equal(decoded.runtime_state,text.includes('[2]')?2:1);}
          report.meanings.push({text,mode,profile:decoded.profile});
        }
        await page.getByRole('button',{name:'Remove line 1',exact:true}).click();
      }
      // The builder must return to exactly the original sentence, even unsaved.
      const text='The lamp is glimmerwise.';await translate(text);
      await page.getByRole('link',{name:'Find or build this meaning',exact:true}).click();
      await page.locator('#returnSentence').waitFor({state:'visible'});
      for(const root of ['MAT:000','LIF:001']){
        await page.locator('#search').fill(root);
        await page.locator('#matches').getByRole('button',{name:'Add this part',exact:true}).first().click();
      }
      await page.locator('#parts li').nth(1).getByRole('button',{name:'Make main meaning',exact:true}).click();
      await page.locator('#label').fill('glimmerwise');
      await page.locator('#definition').fill('A material bearer with an active conscious self-state.');
      await page.locator('#addRole').click();
      await page.locator('#roles select').selectOption('bearer');
      await page.locator('#roles input').fill('The material bearer of the self-state');
      await page.locator('#save').click();
      await page.waitForFunction(()=>document.querySelector('#status').textContent.startsWith('Saved “glimmerwise”'));
      await page.locator('#returnSentence').click();
      await page.locator('#catalogJump option').nth(50).waitFor({state:'attached'});
      assert.equal(await page.locator('#sourceInput').inputValue(),text);
      await page.locator('#analyzeButton').click();
      await page.getByRole('button',{name:'Add to song',exact:true}).filter({visible:true}).waitFor();
    }
    assert.deepEqual(errors,[]);await context.close();
  }
  await fs.writeFile(output+'/results.json',JSON.stringify(report,null,2)+'\n');
  console.log(`PASS ${report.layouts.length} picker layouts, keyboard controls, stale-input invalidation, builder return and ${report.meanings.length} independent exported meanings.`);
}finally{await browser.close();}
