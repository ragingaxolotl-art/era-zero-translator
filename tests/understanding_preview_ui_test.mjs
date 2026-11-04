import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {understandingInterpretationPlan,understandingPronounPlan,composeUnderstandingContent} from '../pages/understanding_content.mjs';
import {midiFromUnderstanding,decodeUnderstandingMidi} from '../pages/understanding_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const app=fs.readFileSync(new URL('../pages/app.js',import.meta.url),'utf8'),handler=app.slice(app.indexOf('function showUnderstandingPreview('),app.indexOf('function showAcquisitionPreview('));
const element=()=>({children:[],classList:{add(){},remove(){}},append(...nodes){this.children.push(...nodes)},addEventListener(t,f){this[t]=f},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','phraseCoverage','resolutionPanel','results','candidateList','decisionSummary'].map(id=>[id,element()])),authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
let calls=0,errors=[],downloads=[],tones=[];const input='Eli understands Nora.';elements.sourceInput.value=input;
const state={mode:'general',data:authority,resolution:{old:true},wordSelections:new Map()};
const context=vm.createContext({state,$:id=>elements[id],document:{createElement:element},understandingInterpretationPlan,understandingPronounPlan,composeUnderstandingContent:async(...args)=>{calls++;return composeUnderstandingContent(...args)},midiFromUnderstanding,Blob,download:(blob,name)=>downloads.push({blob,name}),showError:e=>errors.push(e),notesFromMidi,readyAudio:async()=>({context:{currentTime:0},bus:{}}),playScheduledTone:(...args)=>tones.push(args)});
vm.runInContext(handler,context);
function show(text=input){elements.sourceInput.value=text;vm.runInContext(`showUnderstandingPreview(${JSON.stringify(text)});`,context);return elements.candidateList.children.at(-1);}
let card=show(),select=card.children[1].children[0],button=card.children.at(-1);
assert.equal(state.resolution,null);assert.equal(button.disabled,true);await button.click();assert.equal(calls,0);
select.value='reasons';select.change();await button.click();assert.equal(calls,1);assert.equal(button.hidden,true);
const [play,midi,save]=card.children.slice(-3);await play.click();assert(tones.length>0);midi.click();save.click();assert.deepEqual(downloads.map(d=>d.name),['era-zero-understanding.mid','era-zero-understanding.draft.json']);
const meaning=JSON.parse(await downloads[1].blob.text());assert.equal(meaning.content.content_kind,'reasons');
const recovered=await decodeUnderstandingMidi(new Uint8Array(await downloads[0].blob.arrayBuffer()),authority.atoms,{allowDraft:true});assert.equal(recovered.content.content_kind,'reasons');
select.value='perspective';select.change();save.click();assert.equal(downloads.length,2);assert.equal(button.hidden,false);assert.equal(save.hidden,true);
await button.click();card.children.at(-1).click();assert.equal(JSON.parse(await downloads.at(-1).blob.text()).content.content_kind,'perspective');
for(const outcome of ['success','error']){
 card=show();select=card.children[1].children[0];button=card.children.at(-1);select.value='reasons';select.change();let finish;
 context.composeUnderstandingContent=()=>new Promise((resolve,reject)=>finish=outcome==='success'?resolve:reject);
 const pending=button.click();select.value='perspective';select.change();finish(outcome==='success'?meaning:new Error('late'));await pending;assert.equal(card.children.length,3);assert.equal(errors.length,0);
}
context.composeUnderstandingContent=composeUnderstandingContent;
card=show('Eli understands Nora’s perspective.');button=card.children.at(-1);assert.equal(button.disabled,false);await button.click();assert.equal(card.children.length,5);
elements.sourceInput.value='changed';card.children.at(-1).click();assert.equal(downloads.length,3);
assert(app.includes('if(understandingInterpretationPlan(input)||understandingPronounPlan(input)){showUnderstandingPreview(input);return}'));
console.log('PASS actual understanding UI handler: required choice, real composition/play scheduling/MIDI and meaning exports, explicit readings, changed-choice/source and late-result protection. Live browser layout/listening unverified.');

card=show('They understand them.');select=card.children[1].children[0];button=card.children.at(-1);select.value='perspective';select.change();
const refFields=card.children.slice(2,-1).map(label=>label.children);assert.equal(refFields.length,2);
refFields[0][0].value='Nora';refFields[1][0].value='Eli';
await button.click();assert.equal(errors.at(-1).code,'pronoun_referents_required');errors=[];
for(const [field,number] of refFields){number.value='singular';number.change();}
await button.click();const saved=card.children.at(-1);saved.click();const neutral=JSON.parse(await downloads.at(-1).blob.text());assert.equal(neutral.experiencer.name.normalized_label,'nora');
refFields[0][1].value='plural';refFields[0][1].change();const before=downloads.length;saved.click();assert.equal(downloads.length,before);await button.click();assert.equal(errors.at(-1).code,'pronoun_referents_required');
console.log('PASS neutral pronoun UI: per-occurrence references and explicit number, singular composition, plural rejection and stale export invalidation.');
