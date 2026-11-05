import {createLocalCompoundPlayer} from './local_compound_player.mjs';
import {mountLocalCompoundControls} from './local_compound_controls.mjs';
import {loadLocalCompounds,saveLocalCompounds,addLocalCompound,importLocalCompounds,mergeLocalCompounds} from './local_compounds.mjs';
import {ROLE_ORDER} from './roles.mjs';
const $=id=>document.getElementById(id),node=(tag,text)=>{const e=document.createElement(tag);if(text!==undefined)e.textContent=text;return e;};
let authority,registry,parts=[],busy=false;
const player=createLocalCompoundPlayer();window.addEventListener('pagehide',()=>player.stop());
const status=text=>$('status').textContent=text;
const button=(text,action)=>{const b=node('button',text);b.type='button';b.addEventListener('click',action);return b;};
function catalog(){return [...authority.atoms.map(a=>({id:a.canonical_id,label:a.title,meaning:a.core_definition})),...authority.compounds.filter(c=>c.status==='approved').map(c=>({id:c.compound_id,label:c.display_title,meaning:c.invariant_definition})),...registry.entries.map(e=>({id:e.compound_id,label:e.definition.label,meaning:e.definition.definition}))];}
function renderParts(){
 $('parts').replaceChildren();parts.forEach((part,i)=>{const li=node('li',part.label+' ');li.append(button(part.relation==='head'?'Main meaning ✓':'Make main meaning',()=>{parts.forEach((p,j)=>p.relation=j===i?'head':'qualifies');renderParts();}),button('Move earlier',()=>{if(i){[parts[i-1],parts[i]]=[parts[i],parts[i-1]];renderParts();}}),button('Remove',()=>{parts.splice(i,1);renderParts();}));$('parts').append(li);});
}
function addPart(item){parts.push({...item,relation:parts.length?'qualifies':'head'});renderParts();}
function renderSearch(){
 const q=$('search').value.trim().toLowerCase();$('matches').replaceChildren();if(!q)return;
 const found=catalog().filter(c=>(c.label+' '+c.meaning+' '+c.id).toLowerCase().includes(q));
 $('matches').append(node('p',`${found.length} matches${found.length>30?' · showing the first 30; refine your search':''}`));
 for(const item of found.slice(0,30)){const card=node('article');card.append(node('strong',item.label),node('p',item.meaning),button('Add this part',()=>addPart(item)));$('matches').append(card);}
}
function downloadFile(blob,name){const url=URL.createObjectURL(blob),link=node('a');link.href=url;link.download=name;link.click();setTimeout(()=>URL.revokeObjectURL(url),1000);}
function renderLibrary(){
 player.stop();
 $('library').replaceChildren();for(const e of registry.entries){const card=node('article');card.append(node('strong',e.definition.label),node('p',e.definition.definition),button('Use in a new compound',()=>addPart({id:e.compound_id,label:e.definition.label})));const music=button('Make music',async()=>{music.disabled=true;const controls=node('div');card.append(controls);try{await mountLocalCompoundControls(controls,e.compound_id,registry,authority,{player,download:downloadFile,onError:error=>status(error.message)});}catch(error){status(error.message);music.disabled=false;controls.remove();}});card.append(music);$('library').append(card);}
 $('export').disabled=!registry.entries.length;renderSearch();
}
$('search').addEventListener('input',()=>{if(authority)renderSearch();});
$('addRole').addEventListener('click',()=>{const row=node('div'),select=node('select'),description=node('input');select.setAttribute('aria-label','Participant role');description.setAttribute('aria-label','What this participant does');description.placeholder='What does this participant do?';for(const role of ROLE_ORDER){const option=node('option',role.replaceAll('_',' '));option.value=role;select.append(option);}row.append(select,description,button('Remove role',()=>row.remove()));$('roles').append(row);});
$('save').addEventListener('click',async()=>{
 if(busy||!registry)return;busy=true;$('save').disabled=true;
 try{const definition={label:$('label').value.trim(),definition:$('definition').value.trim(),part_of_speech:$('partOfSpeech').value,components:parts.map(p=>({target_id:p.id,relation:p.relation})),roles:[...$('roles').children].map(r=>({role:r.querySelector('select').value,definition:r.querySelector('input').value.trim()}))};
 if($('thirdPerson').value.trim()||$('pastForm').value.trim())definition.english_forms={third_person:$('thirdPerson').value.trim(),past:$('pastForm').value.trim()};
 const next=await addLocalCompound(registry,definition,authority);registry=await saveLocalCompounds(localStorage,next,authority);renderLibrary();status(`Saved “${definition.label}”. You can reuse it as a part. Sentence integration is still under development.`);
 }catch(e){status(e.message);}finally{busy=false;$('save').disabled=false;}
});
$('export').addEventListener('click',()=>{const url=URL.createObjectURL(new Blob([JSON.stringify(registry,null,2)],{type:'application/json'})),a=node('a');a.href=url;a.download='era-zero-my-compounds.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);});
$('import').addEventListener('change',async()=>{if(busy||!registry)return;busy=true;try{const file=$('import').files[0];if(!file)return;const incoming=await importLocalCompounds(await file.text(),authority),next=await mergeLocalCompounds(registry,incoming,authority);registry=await saveLocalCompounds(localStorage,next,authority);renderLibrary();status('Definitions imported. Existing words were preserved.');}catch(e){status(e.message);}finally{busy=false;}});
try{const response=await fetch('./data/index.json');if(!response.ok)throw new Error('Could not load dictionary.');authority=await response.json();registry=await loadLocalCompounds(localStorage,authority);renderLibrary();$('save').disabled=false;status('Ready. Search existing meanings to begin.');}catch(e){status(`Unable to open the builder: ${e.message}`);}
