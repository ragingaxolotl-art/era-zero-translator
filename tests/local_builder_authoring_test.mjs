import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import * as registryAPI from '../pages/local_compounds.mjs';
import * as examples from '../pages/local_compound_examples.mjs';
import {ROLE_ORDER} from '../pages/roles.mjs';
import {mountRoleLinkControls} from '../pages/local_role_link_controls.mjs';
import {composeLocalAdjective} from '../pages/local_compound_english.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
class Element {
 constructor(tag='div'){this.tag=tag;this.children=[];this.value='';this.textContent='';this.listeners={};}
 append(...items){for(const item of items){item.parent=this;this.children.push(item);}}
 replaceChildren(...items){this.children=[];this.append(...items);}
 remove(){this.parent.children=this.parent.children.filter(x=>x!==this);}
 setAttribute(){}
 addEventListener(event,fn){this.listeners[event]=fn;}
 async fire(event='click'){await this.listeners[event]?.();}
 querySelector(tag){return this.children.find(x=>x.tag===tag);}
}
const ids=Object.fromEntries([...fs.readFileSync(new URL('../pages/compound-builder.html',import.meta.url),'utf8').matchAll(/id="([^"]+)"/g)].map(m=>[m[1],new Element()]));
const document={getElementById:id=>ids[id],createElement:tag=>new Element(tag)};
const memory=new Map(),storage={getItem:key=>memory.get(key)??null,setItem:(key,value)=>memory.set(key,value)};
const context=vm.createContext({...registryAPI,...examples,ROLE_ORDER,document,localStorage:storage,sessionStorage:storage,window:{addEventListener(){}},fetch:async()=>({ok:true,json:async()=>authority}),createLocalCompoundPlayer:()=>({stop(){}}),mountLocalCompoundControls:()=>{},mountRoleLinkControls:(...args)=>mountRoleLinkControls(...args,{document})});
const script=fs.readFileSync(new URL('../pages/compound-builder.mjs',import.meta.url),'utf8').replace(/^import .*;\n/gm,'');
await vm.runInContext(`(async()=>{${script}\n})()`,context);
assert.match(ids.status.textContent,/Ready/);
async function addPart(id){ids.search.value=id;await ids.search.fire('input');const card=ids.matches.children.find(x=>x.tag==='article');assert(card);await card.children.find(x=>x.tag==='button').fire();}
await addPart(authority.compounds.find(c=>c.display_title==='ongoing bodily locomotor activity').compound_id);
await addPart(authority.atoms[0].canonical_id);
ids.label.value='stridebright';ids.definition.value='Test-only quality using locomotion.';ids.partOfSpeech.value='adjective';
await ids.addRole.fire();ids.roles.children[0].querySelector('select').value='bearer';ids.roles.children[0].querySelector('input').value='Bearer of this quality.';
await ids.connectRoles.fire();ids.roleLinks.children[0].children[0].value='bearer';
// Editing after reviewing connections must not silently apply outdated links.
ids.definition.value+=' Revised.';await ids.save.fire();assert.match(ids.status.textContent,/Review participant connections again/);assert.equal(memory.size,0);
await ids.connectRoles.fire();ids.roleLinks.children[0].children[0].value='bearer';await ids.save.fire();assert.match(ids.status.textContent,/Saved/);
const restored=await registryAPI.loadLocalCompounds(storage,authority);assert.equal(restored.entries.length,1);assert.equal(restored.entries[0].definition.role_links[0].outer_role,'bearer');
const music=await composeLocalAdjective('Nora might not be stridebright.',restored,authority);assert(music.midi.length>0);assert.equal(music.meaning.bindings.length,2);assert(music.meaning.bindings.every(b=>b.reference.name.normalized_label==='nora'));
assert.deepEqual(music.meaning.scopes.map(s=>s.operator),['modality','negation']);
console.log('PASS actual builder handlers: search, ordered parts, role connection, stale-edit rejection, save/reload, and saved adjective sentence to music (DOM adapter, not live browser).');

// Build a compound of the saved compound through the same authoring handlers.
await ids.newCompound.fire();assert.equal(ids.parts.children.length,0);assert.equal(ids.roles.children.length,0);assert.equal(ids.label.value,'');assert.equal(ids.library.children.length,1);
await addPart(restored.entries[0].compound_id);await addPart(authority.atoms[1].canonical_id);
ids.label.value='stridecalm';ids.definition.value='Test-only nested quality.';ids.partOfSpeech.value='adjective';
await ids.addRole.fire();ids.roles.children[0].querySelector('select').value='bearer';ids.roles.children[0].querySelector('input').value='Bearer of the nested quality.';
await ids.connectRoles.fire();assert.equal(ids.roleLinks.children.length,1);ids.roleLinks.children[0].children[0].value='bearer';await ids.save.fire();assert.match(ids.status.textContent,/Saved/);
const nested=await registryAPI.importLocalCompounds(JSON.stringify(await registryAPI.loadLocalCompounds(storage,authority)),authority);
assert.equal(nested.entries.length,2);assert.equal(nested.entries[1].definition.components[0].target_id,restored.entries[0].compound_id);
const nestedMusic=await composeLocalAdjective('Nora might not be stridecalm.',nested,authority);assert.equal(nestedMusic.meaning.bindings.length,3);assert(nestedMusic.meaning.bindings.every(b=>b.reference.name.normalized_label==='nora'));
assert.deepEqual(nestedMusic.meaning.scopes,music.meaning.scopes);assert(nestedMusic.midi.length>music.midi.length);
const frames=nestedMusic.events.filter(e=>e.grammar_profile==='EZLOCAL-COMPOUND-MUSIC-1');assert.equal(frames.length,4);const stack=[];for(const frame of frames){if(frame.marker.endsWith('_open'))stack.push(frame.target_id);else assert.equal(stack.pop(),frame.target_id);}assert.equal(stack.length,0);
console.log('PASS new draft preserves saved words; nested compound authoring, export/import, transitive participants and nested musical frames.');
