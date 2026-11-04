import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {cognitiveConjunctionPlan,cognitiveClauseChoicePlan,composeCognitiveConjunction} from '../pages/cognitive_conjunction.mjs';
import {midiFromCognitiveConjunction,decodeCognitiveConjunctionMidi} from '../pages/cognitive_conjunction_music.mjs';
import {notesFromMidi} from '../pages/performance_codec.mjs';
const app=fs.readFileSync(new URL('../pages/app.js',import.meta.url),'utf8'),handler=app.slice(app.indexOf('function showCognitiveConjunctionPreview('),app.indexOf('function showCuriosityPreview('));
const element=()=>({children:[],classList:{add(){},remove(){}},append(...n){this.children.push(...n)},addEventListener(t,f){this[t]=f},scrollIntoView(){}});
const elements=Object.fromEntries(['sourceInput','output','phraseCoverage','resolutionPanel','results','candidateList','decisionSummary'].map(id=>[id,element()]));
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),registry=JSON.parse(fs.readFileSync(new URL('../pages/data/foundation_preview_candidates.json',import.meta.url)));
let errors=[],downloads=[],tones=[],calls=0;
const state={mode:'general',data:authority,resolution:{old:true},wordSelections:new Map()};
const context=vm.createContext({state,$:id=>elements[id],document:{createElement:element},cognitiveConjunctionPlan,cognitiveClauseChoicePlan,composeCognitiveConjunction:async(...args)=>{calls++;return composeCognitiveConjunction(...args)},midiFromCognitiveConjunction,Blob,download:(blob,name)=>downloads.push({blob,name}),showError:e=>errors.push(e),notesFromMidi,readyAudio:async()=>({context:{currentTime:0},bus:{}}),playScheduledTone:(...args)=>tones.push(args),fetch:async()=>({ok:true,json:async()=>registry})});
vm.runInContext(handler,context);
const input='They learned this route [0] and Eli understands Nora [2].';
function show(text=input){elements.sourceInput.value=text;vm.runInContext(`showCognitiveConjunctionPreview(${JSON.stringify(text)});`,context);return elements.candidateList.children.at(-1);}
let card=show(),button=card.children.at(-1),route=card.children[1].children[1].children[0],understanding=card.children[2].children[1].children[0],[field,number]=card.children[1].children[2].children;
assert.equal(state.resolution,null);assert.equal(button.disabled,true);await button.click();assert.equal(calls,0);
route.value='navigation';route.change();assert.equal(button.disabled,true);understanding.value='perspective';understanding.change();field.value='Orin';number.value='singular';number.change();await button.click();assert.equal(button.hidden,true);assert.equal(errors.length,0);
const [play,midi,save]=card.children.slice(-3);await play.click();assert(tones.length>0);midi.click();save.click();assert.deepEqual(downloads.map(d=>d.name),['era-zero-cognitive-conjunction.mid','era-zero-cognitive-conjunction.draft.json']);
const meaning=JSON.parse(await downloads[1].blob.text());assert.equal(meaning.members[0].result_state.reading,'navigation');assert.equal(meaning.members[0].result_state.experiencer.name.normalized_label,'orin');assert.equal(meaning.members[0].transition_runtime,0);assert.equal(meaning.members[1].content.content_kind,'perspective');assert.equal(meaning.members[1].runtime_state,2);
const r=await decodeCognitiveConjunctionMidi(new Uint8Array(await downloads[0].blob.arrayBuffer()),authority.atoms,registry.records,{allowDraft:true});assert.equal(r.members.length,2);assert.equal(r.members[0].transition_runtime,0);assert.equal(r.members[1].content.content_kind,'perspective');
route.value='familiarity';route.change();save.click();assert.equal(downloads.length,2);assert.equal(save.hidden,true);await button.click();card.children.at(-1).click();assert.equal(JSON.parse(await downloads.at(-1).blob.text()).members[0].result_state.reading,'familiarity');
const old=card.children.at(-1),before=downloads.length;number.value='plural';number.change();old.click();assert.equal(downloads.length,before);await button.click();assert.equal(errors.at(-1).clause_index,0);errors=[];
for(const outcome of ['success','error']){
 card=show('Orin is curious about the map and Eli understands Nora’s reasons.');button=card.children.at(-1);let finish;context.composeCognitiveConjunction=()=>new Promise((resolve,reject)=>finish=outcome==='success'?resolve:reject);
 const pending=button.click();elements.sourceInput.value='changed';finish(outcome==='success'?meaning:new Error('late'));await pending;assert.equal(card.children.length,4);assert.equal(errors.length,0);
}
context.composeCognitiveConjunction=composeCognitiveConjunction;
card=show('Orin came to understand Nora and Eli is curious about the map.');button=card.children.at(-1);assert.equal(button.disabled,true);const selected=card.children[1].children[1].children[0];selected.value='reasons';selected.change();await button.click();card.children.at(-1).click();assert.equal(JSON.parse(await downloads.at(-1).blob.text()).members[0].result_state.content.content_kind,'reasons');
assert(app.includes('if(cognitiveConjunctionPlan(input)){showCognitiveConjunctionPreview(input);return}'));
console.log('PASS actual conjunction UI: per-clause reading/pronoun choices, complete composition/playback/MIDI/meaning exports, acquisition result choices, independent runtimes and stale-source/binding safeguards. Live layout/listening unverified.');

card=show('It is not true that Orin is curious about the map and Eli understands Nora’s reasons.');assert(card.children[0].textContent.includes('whole conjunction is negated'));await card.children.at(-1).click();card.children.at(-1).click();assert.equal(JSON.parse(await downloads.at(-1).blob.text()).scopes[0].operator,'negation');assert(card.children[0].textContent.includes('Whole-message negation'));
console.log('PASS explicit outer-negation UI explanation and complete scoped meaning export.');
