import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {curiosityInterpretationPlan,curiosityPronounPlan,composeCuriosity} from '../pages/curiosity.mjs';
import {midiFromCuriosity,decodeCuriosityMidi} from '../pages/curiosity_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const app=fs.readFileSync(new URL('../pages/app.js',import.meta.url),'utf8'),handler=app.slice(app.indexOf('function showCuriosityPreview('),app.indexOf('function showRouteLearningPreview('));
const element=()=>({children:[],classList:{add(){},remove(){}},append(...n){this.children.push(...n)},addEventListener(t,f){this[t]=f},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','phraseCoverage','resolutionPanel','results','candidateList','decisionSummary'].map(id=>[id,element()]));
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),registry=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url)));
let errors=[],downloads=[],tones=[],loads=0;
const state={mode:'general',data:authority,resolution:{old:true},wordSelections:new Map()};
const context=vm.createContext({state,$:id=>elements[id],document:{createElement:element},curiosityInterpretationPlan,curiosityPronounPlan,composeCuriosity,midiFromCuriosity,Blob,download:(blob,name)=>downloads.push({blob,name}),showError:e=>errors.push(e),notesFromMidi,readyAudio:async()=>({context:{currentTime:0},bus:{}}),playScheduledTone:(...args)=>tones.push(args),fetch:async()=>{loads++;return {ok:true,json:async()=>registry}}});
vm.runInContext(handler,context);
function show(text='Orin is curious about the map.'){elements.sourceInput.value=text;vm.runInContext(`showCuriosityPreview(${JSON.stringify(text)});`,context);return elements.candidateList.children.at(-1);}
let card=show(),button=card.children.at(-1);assert.equal(state.resolution,null);assert.equal(loads,0);await button.click();assert.equal(loads,1);assert.equal(button.hidden,true);
const [play,midi,save]=card.children.slice(-3);await play.click();assert(tones.length>0);midi.click();save.click();assert.deepEqual(downloads.map(d=>d.name),['era-zero-curiosity.mid','era-zero-curiosity.draft.json']);
const meaning=JSON.parse(await downloads[1].blob.text()),recovered=await decodeCuriosityMidi(new Uint8Array(await downloads[0].blob.arrayBuffer()),authority.atoms,registry.records,{allowDraft:true});assert.equal(recovered.criterion,meaning.criterion);assert.equal(recovered.outcome_commitment,'desired_not_asserted');
elements.sourceInput.value='changed';save.click();assert.equal(downloads.length,2);
card=show('They are curious about this map.');button=card.children.at(-1);const [field,number]=card.children[1].children;field.value='Nora';await button.click();assert.equal(errors.at(-1).code,'pronoun_referents_required');errors=[];
number.value='singular';number.change();await button.click();card.children.at(-1).click();assert.equal(JSON.parse(await downloads.at(-1).blob.text()).experiencer.name.normalized_label,'nora');
const stale=card.children.at(-1),before=downloads.length;number.value='plural';number.change();stale.click();assert.equal(downloads.length,before);await button.click();assert.equal(errors.at(-1).code,'pronoun_referents_required');errors=[];
for(const outcome of ['success','error']){
 card=show();button=card.children.at(-1);let finish;
 context.composeCuriosity=()=>new Promise((resolve,reject)=>finish=outcome==='success'?resolve:reject);
 const pending=button.click();elements.sourceInput.value='changed';finish(outcome==='success'?meaning:new Error('late'));await pending;assert.equal(card.children.length,2);assert.equal(errors.length,0);
}
context.composeCuriosity=composeCuriosity;
card=show('Was Orin not curious about that map?');button=card.children.at(-1);let finish;
context.fetch=()=>new Promise(resolve=>finish=resolve);const pending=button.click();while(!finish)await new Promise(resolve=>setTimeout(resolve,0));elements.sourceInput.value='changed';finish({ok:true,json:async()=>registry});await pending;assert.equal(card.children.length,2);
context.fetch=async()=>({ok:false});card=show();await card.children.at(-1).click();assert.equal(errors.at(-1).message,'Draft vocabulary could not be loaded.');assert.equal(card.children.length,2);
assert(app.includes('if(curiosityInterpretationPlan(input)||curiosityPronounPlan(input)){showCuriosityPreview(input);return}'));
console.log('PASS actual curiosity UI: draft opt-in, real playback scheduling and meaning/MIDI exports, explicit singular they, plural rejection, stale source/binding/async/fetch guards and vocabulary-load failure. Live layout/listening unverified.');
