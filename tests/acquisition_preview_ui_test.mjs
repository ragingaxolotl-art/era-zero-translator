import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
const app=fs.readFileSync(new URL('../pages/app.js',import.meta.url),'utf8'),handler=app.slice(app.indexOf('function showAcquisitionPreview('),app.indexOf('function showQuantifiedPreview('));
const element=()=>({children:[],classList:{add(){},remove(){}},append(...n){this.children.push(...n)},addEventListener(t,f){this[t]=f},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','phraseCoverage','resolutionPanel','results','candidateList','decisionSummary'].map(id=>[id,element()]));
const input='Nora learned whether Eli is conscious.';elements.sourceInput.value=input;
const state={mode:'general',data:{},resolution:{old:true},wordSelections:new Map()};let calls=0,downloads=[],errors=[];
const context=vm.createContext({state,$:id=>elements[id],document:{createElement:element},fetch:async()=>({ok:true,json:async()=>({records:[]})}),sentenceTemplate(){},composeLearnedWhether:async(...args)=>{calls++;assert.equal(args[4].allowDraft,true);return {acquisition:{},result_formal:{}}},midiFromKnowledgeAcquisition:async()=>new Uint8Array([1,2,3]),createAcquisitionBundle:async()=>({format:'EZACQB-1',status:'draft'}),download:(b,n)=>downloads.push(n),Blob,showError:e=>errors.push(e)});
vm.runInContext(handler+`;showAcquisitionPreview(${JSON.stringify(input)});`,context);
assert.equal(state.resolution,null);assert.equal(calls,0);
let card=elements.candidateList.children.at(-1),button=card.children[1];elements.sourceInput.value='changed';await button.click();assert.equal(calls,0);
elements.sourceInput.value=input;await button.click();assert.equal(calls,1);assert.equal(button.hidden,true);assert.equal(state.resolution,null);
assert.deepEqual(card.children.slice(-3).map(n=>n.textContent),['Play draft music','Download MIDI','Save meaning bundle']);
card.children.at(-2).click();card.children.at(-1).click();assert.deepEqual(downloads,['era-zero-learning.mid','era-zero-learning.ezacqb.json']);
elements.sourceInput.value='changed';card.children.at(-1).click();assert.equal(downloads.length,2);
for(const outcome of ['success','error']){
 elements.sourceInput.value=input;vm.runInContext(`showAcquisitionPreview(${JSON.stringify(input)});`,context);card=elements.candidateList.children.at(-1);button=card.children[1];let finish;
 context.composeLearnedWhether=()=>new Promise((resolve,reject)=>finish=outcome==='success'?resolve:reject);
 const pending=button.click();await new Promise(r=>setImmediate(r));card.isConnected=false;finish(outcome==='success'?{acquisition:{},result_formal:{}}:new Error('late'));await pending;assert.equal(card.children.length,2);assert.equal(errors.length,0);
}
assert(app.includes('if(parseLearnedWhether(input)){showAcquisitionPreview(input);return}'));
assert(app.includes("imported.format==='EZACQB-1'?await verifyAcquisitionBundle(imported,state.data,{allowDraft:true})"));
console.log('PASS acquisition UI: explicit preview, separate full-acquisition downloads, stale results/download rejection, cleared ordinary result and acquisition-specific import verification. Playback layout/listening not verified.');
