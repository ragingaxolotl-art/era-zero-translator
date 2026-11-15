// Independent browser profile for each run. All test-created words and songs are local to it.
import fs from 'node:fs/promises';
import path from 'node:path';
import {createRequire} from 'node:module';
const require=createRequire(import.meta.url);
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const [site,directory]=process.argv.slice(2);
if(!site||!directory)throw Error('Supply SITE and OUTPUT_DIRECTORY.');
await fs.mkdir(directory,{recursive:true});
const browser=await chromium.launch({headless:true,...(process.env.CHROME_PATH?{executablePath:process.env.CHROME_PATH}:{})});
const context=await browser.newContext({viewport:{width:390,height:844},acceptDownloads:true});
const page=await context.newPage(),report={};
async function ready(p){await p.locator('#catalogJump option').nth(50).waitFor({state:'attached'});}
async function open(p){await p.goto(site,{waitUntil:'domcontentloaded'});await ready(p);}
async function type(p,text){await p.locator('#sourceInput').fill(text);await p.locator('#analyzeButton').click();await p.waitForFunction(()=>!document.getElementById('analyzeButton').disabled);}
async function add(p,text){await type(p,text);await p.getByRole('button',{name:'Add to song',exact:true}).click();}
async function song(p){return p.locator('#songLines li span').allTextContents();}
try{
 await open(page);report.layout=[];
 for(const width of [320,390,768,1280]){
   await page.setViewportSize({width,height:844});
   report.layout.push(await page.evaluate(()=>{
     const first=[...document.querySelectorAll('button,select')].find(e=>e.getClientRects().length&&/chord/i.test(e.textContent));
     return {width:innerWidth,page_width:document.documentElement.scrollWidth,first_chord_control_y:first?Math.round(first.getBoundingClientRect().top+scrollY):null};
   }));
 }
 await page.setViewportSize({width:390,height:844});
 await add(page,'The path was open.');await add(page,'The gate reopened.');
 await page.reload();await ready(page);report.after_reload=await song(page);
 await page.getByRole('button',{name:'Remove line 1'}).click();report.after_remove=await song(page);
 await page.getByRole('button',{name:'Remove line 1'}).click();
 const tab=await context.newPage();await open(tab);
 await add(page,'The gate reopened.');await add(tab,'The path was open.');
 await page.reload();await ready(page);report.after_two_tabs_added=await song(page);await tab.close();
 await type(page,'The gate reopened.');
 await page.locator('#sourceInput').fill('Changed but not submitted');
 report.stale_add_visible=await page.getByRole('button',{name:'Add to song',exact:true}).isVisible();
 const translator=page.getByRole('tab',{name:'Translator',exact:true});
 await translator.focus();await page.keyboard.press('ArrowRight');
 report.focus_after_tab_arrow=await page.evaluate(()=>document.activeElement.textContent.trim());
 await page.getByRole('tab',{name:'Dictionary',exact:true}).click();
 await page.locator('#catalogSearch').fill('reopen');
 report.dictionary_reopen_matches=await page.locator('#catalogList').innerText();
 await page.getByRole('tab',{name:'Conversation',exact:true}).click();
 await page.locator('#loadDemoConversation').click();await page.locator('#buildConversation').click();
 await page.waitForFunction(()=>!document.querySelector('#buildConversation').disabled);
 report.conversation={status:await page.locator('#conversationStatus').innerText(),turns:await page.locator('#conversationTurns').innerText(),play_enabled:await page.locator('#playConversation').isEnabled()};
 // A meaningful round trip through the ordinary builder, including a clean second profile.
 await page.goto(new URL('compound-builder.html',site).href,{waitUntil:'domcontentloaded'});
 await page.waitForFunction(()=>document.querySelector('#status')?.textContent.includes('Ready'));
 for(const id of ['REP:110','MIN:011']){
   await page.locator('#search').fill(id);
   await page.locator('#matches article').filter({hasText:id}).first().getByRole('button').click();
 }
 await page.locator('#label').fill('fieldmend');await page.locator('#definition').fill('Repair with awareness of the affected object.');
 await page.locator('#partOfSpeech').selectOption('verb');
 await page.locator('#thirdPerson').fill('fieldmends');await page.locator('#pastForm').fill('fieldmended');
 for(const [role,label] of [['actor','The repairer'],['target','The object being repaired']]){
   await page.locator('#addRole').click();await page.locator('#roles select').last().selectOption(role);await page.locator('#roles input').last().fill(label);
 }
 await page.locator('#save').click();await page.waitForFunction(()=>document.querySelector('#status').textContent.includes('Saved “fieldmend”'));
 await page.reload();await page.waitForFunction(()=>document.querySelector('#library').textContent.includes('fieldmend'));
 const [exported]=await Promise.all([page.waitForEvent('download'),page.locator('#export').click()]);
 const backup=path.join(directory,'fieldmend.json');await exported.saveAs(backup);
 const fresh=await browser.newContext({acceptDownloads:true});const other=await fresh.newPage();await other.goto(new URL('compound-builder.html',site).href);
 await other.waitForFunction(()=>document.querySelector('#status')?.textContent.includes('Ready'));
 await other.locator('input[type=file]').setInputFiles(backup);
 await other.waitForFunction(()=>document.querySelector('#library').textContent.includes('fieldmend'));
 report.builder_imported=await other.locator('#library').innerText();await fresh.close();
}finally{
 await fs.writeFile(path.join(directory,'workflows.json'),JSON.stringify(report,null,2)+'\n');
 await browser.close();
}
