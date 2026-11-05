import {localAdjectivePlan,composeLocalAdjective} from './local_compound_english.mjs';
import {expandLocalCompound} from './local_compound_expansion.mjs';
import {contextualContentReference} from './contextual_content.mjs';
export async function mountLocalEnglishControls(container,input,registry,authority,{document=globalThis.document,download,player,isCurrent=()=>true,onError=()=>{}}={}){
 const plan=await localAdjectivePlan(input,registry,authority);if(!plan)return false;
 const make=(tag,text)=>{const el=document.createElement(tag);if(text!==undefined)el.textContent=text;return el;};
 const entry=registry.entries.find(e=>e.compound_id===plan.compound_id),expansion=await expandLocalCompound(plan.compound_id,registry,authority),fields=[];
 container.append(make('h3',entry.definition.label),make('p',entry.definition.definition),make('p',`Subject: ${plan.subject}. Time, negation, question and runtime choices come from your sentence.`));
 for(const requirement of expansion.role_requirements){
  if(!requirement.path.length&&requirement.role==='bearer'&&!requirement.slot_path)continue;
  const label=make('label',`Part ${requirement.path.map(n=>n+1).join('.')||'whole'} · ${requirement.role}`),field=make('input');field.placeholder='Name or noun phrase';label.append(field);container.append(label);fields.push({requirement,field});
 }
 const generate=make('button','Translate saved meaning'),output=make('div');container.append(generate,output);let revision=0;
 for(const {field} of fields)field.addEventListener('input',()=>{revision++;player?.stop();output.replaceChildren();});
 generate.addEventListener('click',async()=>{
  if(!isCurrent())return;const version=revision,values=fields.map(({field})=>field.value.trim()),current=()=>isCurrent()&&container.isConnected!==false&&version===revision&&fields.every(({field},i)=>field.value.trim()===values[i]);
  generate.disabled=true;player?.stop();output.replaceChildren();
  try{
   const bindings=await Promise.all(fields.map(async({requirement:r},i)=>({path:r.path,...(r.slot_path?{slot_path:r.slot_path}:{}),role:r.role,reference:await contextualContentReference(values[i])})));
   const result=await composeLocalAdjective(input,registry,authority,{bindings});if(!current())return;
   if(player){const play=make('button','Play music'),stop=make('button','Stop');play.addEventListener('click',async()=>{if(!current())return;try{await player.play(result.midi);}catch(e){if(current())onError(e);}});stop.addEventListener('click',()=>player.stop());output.append(play,stop);}
   const midi=make('button','Download MIDI'),meaning=make('button','Save meaning and definitions');
   midi.addEventListener('click',()=>{if(current())download(new Blob([result.midi],{type:'audio/midi'}),'era-zero-saved-sentence.mid');});
   meaning.addEventListener('click',()=>{if(current()){const {midi,...portable}=result;download(new Blob([JSON.stringify(portable,null,2)],{type:'application/json'}),'era-zero-saved-sentence.json');}});output.append(midi,meaning);
  }catch(e){if(current())onError(e);}finally{generate.disabled=false;}
 });return true;
}
