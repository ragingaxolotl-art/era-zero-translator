import {composeObjectDesiredOwnership} from '../pages/object_desired_ownership.mjs';
import {desiredOwnershipPlan,desiredOwnershipPronounPlan,composeDesiredOwnership} from '../pages/desired_ownership.mjs';
import {midiFromDesiredOwnership,decodeDesiredOwnershipMidi} from '../pages/desired_ownership_music.mjs';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {ownershipPlan,ownershipPronounPlan,composeOwnershipSentence} from '../pages/ownership_sentences.mjs';
import {midiFromOwnership,decodeOwnershipMidi} from '../pages/ownership_music.mjs';
const app=fs.readFileSync(new URL('../pages/app.js',import.meta.url),'utf8'),handler=app.slice(app.indexOf('function showOwnershipPreview('),app.indexOf('function showDrinkingPreview('));
const element=()=>({children:[],classList:{add(){},remove(){}},append(...n){this.children.push(...n)},addEventListener(t,f){this[t]=f},scrollIntoView(){}}),els=Object.fromEntries(['sourceInput','output','phraseCoverage','resolutionPanel','results','candidateList','decisionSummary'].map(id=>[id,element()]));
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));let downloads=[],errors=[];
const ctx=vm.createContext({composeObjectDesiredOwnership,desiredOwnershipPlan,desiredOwnershipPronounPlan,composeDesiredOwnership,midiFromDesiredOwnership,ownershipPlan,ownershipPronounPlan,composeOwnershipSentence,midiFromOwnership,state:{mode:'general',data:authority,wordSelections:new Map()},$:id=>els[id],document:{createElement:element},Blob,download:blob=>downloads.push(blob),showError:e=>errors.push(e)});vm.runInContext(handler,ctx);
const input="Didn't Nora own this tea? [2]";els.sourceInput.value=input;ctx.showOwnershipPreview(input);
const card=els.candidateList.children.at(-1),framework=card.children[1].children[0],button=card.children.at(-1);assert(button.disabled);await button.click();assert.equal(downloads.length,0);
framework.value='"Harbor charter"';framework.input();await button.click();assert.equal(errors.length,0);const [play,music,save]=card.children.slice(-3);music.click();save.click();const document=JSON.parse(await downloads[1].text()),inverse=decodeOwnershipMidi(new Uint8Array(await downloads[0].arrayBuffer()),authority.atoms,{allowDraft:true});assert.equal(inverse.runtime_state,2);assert.equal(inverse.speech_act,'question');assert.deepEqual(inverse.scopes,[{operator:'time',relation:'before_speech'},{operator:'negation'}]);assert.deepEqual(inverse.framework.phonemes,document.framework.name.phonemes);
framework.value='"Island charter"';framework.input();save.click();assert.equal(downloads.length,2);
let finish,entered;const reached=new Promise(resolve=>entered=resolve);ctx.midiFromOwnership=()=>new Promise(resolve=>{finish=resolve;entered()});const pending=button.click();await reached;framework.value='"Changed charter"';framework.input();finish(new Uint8Array());await pending;assert.equal(button.hidden,false);ctx.midiFromOwnership=midiFromOwnership;
els.sourceInput.value='They own it.';ctx.showOwnershipPreview(els.sourceInput.value);const p=els.candidateList.children.at(-1),f=p.children[1].children[0],person=p.children[2].children[0],number=p.children[2].children[1],object=p.children[3].children[0],go=p.children.at(-1);f.value='"Harbor charter"';f.input();person.value='Nora';object.value='this tea';await go.click();assert.match(errors.at(-1).message,/one individual or a group/);number.value='singular';number.change();errors=[];await go.click();assert.equal(errors.length,0);p.children.at(-1).click();const d=JSON.parse(await downloads.at(-1).text());assert.equal(d.owner.name.normalized_label,'nora');assert.equal(d.object.reference_mode,'proximal_nominal');
assert(app.includes('if(ownershipPlan(input)||ownershipPronounPlan(input)){showOwnershipPreview(input);return;}'));
console.log('PASS ownership preview requires framework, exports full meaning/music, resolves neutral references and discards stale selections/exports.');

for(const clarified of [false,true]){
 const source=clarified?'Does Nora not want that tea? [2]':'Does Nora not want Eli to not own that tea [0]? [2]',outcome='Eli does not own that tea [0].';els.sourceInput.value=source;ctx.showOwnershipPreview(source,{desired:true,...(clarified?{clarification:outcome}:{})});
 const card=els.candidateList.children.at(-1),framework=card.children[1].children[0],button=card.children.at(-1);framework.value='"Harbor charter"';framework.input();errors=[];await button.click();assert.equal(errors.length,0);card.children.at(-2).click();card.children.at(-1).click();
 const saved=JSON.parse(await downloads.at(-1).text()),r=decodeDesiredOwnershipMidi(new Uint8Array(await downloads.at(-2).arrayBuffer()),authority.atoms,{allowDraft:true});assert.equal(r.runtime_state,2);assert.equal(r.content.runtime_state,0);assert.deepEqual(r.scopes,[{operator:'negation'}]);assert.deepEqual(r.content.scopes,[{operator:'negation'}]);assert.equal(r.content.object.reference_mode,'distal_nominal');assert.equal(r.content_status,'intensional');assert.notDeepEqual(r.holder,r.content.owner);
 if(clarified){assert.equal(saved.source_input,source);assert.equal(saved.object_desire_resolution.desired_proposition,outcome.slice(0,-1));assert.equal(saved.meaning.content_status,'intensional');}else assert.equal(saved.content_status,'intensional');
 const previous=downloads.length;framework.value='"Island charter"';framework.input();card.children.at(-1).click();assert.equal(downloads.length,previous);
}
console.log('PASS desired and object-clarified ownership previews export scoped music and provenance, preserving holder/owner separation and stale-export guards.');
