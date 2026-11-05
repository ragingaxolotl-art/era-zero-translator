import {expandLocalCompound} from './local_compound_expansion.mjs';
import {contextualContentReference} from './contextual_content.mjs';
import {localCompoundMusic} from './local_compound_music.mjs';
export async function mountLocalCompoundControls(container,id,registry,authority,{document=globalThis.document,download,onError=()=>{}}={}){
 const make=(tag,text)=>{const e=document.createElement(tag);if(text!==undefined)e.textContent=text;return e;};
 const expansion=await expandLocalCompound(id,registry,authority),fields=[];
 for(const requirement of expansion.role_requirements){
  const label=make('label',`${requirement.path.length?'Part '+requirement.path.map(n=>n+1).join('.'):'Whole compound'} · ${requirement.role.replaceAll('_',' ')}${requirement.definition?' — '+requirement.definition:''}`),field=make('input');field.placeholder='For example: Nora, this tea, or "named object"';label.append(field);container.append(label);fields.push({requirement,field});
 }
 const runtimeLabel=make('label','Runtime state'),runtime=make('select');for(const value of [0,1,2]){const option=make('option',String(value));option.value=String(value);runtime.append(option);}runtime.value='1';runtimeLabel.append(runtime);container.append(runtimeLabel);
 const generate=make('button','Prepare music'),output=make('div');generate.type='button';container.append(generate,output);
 let revision=0;const invalidate=()=>{revision++;output.replaceChildren();};for(const {field} of fields)field.addEventListener('input',invalidate);runtime.addEventListener('change',invalidate);
 generate.addEventListener('click',async()=>{
  const version=revision,values=fields.map(({field})=>field.value.trim()),state=runtime.value;
  const current=()=>container.isConnected!==false&&revision===version&&runtime.value===state&&fields.every(({field},i)=>field.value.trim()===values[i]);
  generate.disabled=true;output.replaceChildren();
  try{
   const bindings=await Promise.all(fields.map(async({requirement},i)=>({path:requirement.path,...(requirement.slot_path?{slot_path:requirement.slot_path}:{}),role:requirement.role,reference:await contextualContentReference(values[i])})));
   const result=await localCompoundMusic(id,registry,authority,bindings,{runtimeState:Number(state)});if(!current())return;
   const midi=make('button','Download MIDI'),bundle=make('button','Download meaning and definitions');midi.type=bundle.type='button';
   midi.addEventListener('click',()=>{if(current())download(new Blob([result.midi],{type:'audio/midi'}),'era-zero-local-compound.mid');});
   bundle.addEventListener('click',()=>{if(current()){const {midi,...portable}=result;download(new Blob([JSON.stringify(portable,null,2)],{type:'application/json'}),'era-zero-local-compound.json');}});
   output.append(midi,bundle);
  }catch(error){if(current())onError(error);}finally{generate.disabled=false;}
 });
}
