import {localParticipantGroups} from './local_participant_groups.mjs';
import {composeLocalCompoundSentence} from './local_compound_sentence.mjs';
import {expandLocalCompound} from './local_compound_expansion.mjs';
import {contextualContentReference} from './contextual_content.mjs';
import {localCompoundMusic} from './local_compound_music.mjs';
export async function mountLocalCompoundControls(container,id,registry,authority,{document=globalThis.document,download,player,onError=()=>{}}={}){
 const make=(tag,text)=>{const e=document.createElement(tag);if(text!==undefined)e.textContent=text;return e;};
 const expansion=await expandLocalCompound(id,registry,authority),fields=[];
 for(const requirements of localParticipantGroups(expansion,authority)){
  const requirement=requirements[0];
  const label=make('label',`${requirement.path.length?'Part '+requirement.path.map(n=>n+1).join('.'):'Whole compound'} · ${requirement.role.replaceAll('_',' ')}${requirement.definition?' — '+requirement.definition:''}`),field=make('input');field.placeholder='For example: Nora, this tea, or "named object"';label.append(field);container.append(label);fields.push({requirements,field});
 }
 const runtimeLabel=make('label','Runtime state'),runtime=make('select');for(const value of [0,1,2]){const option=make('option',String(value));option.value=String(value);runtime.append(option);}runtime.value='1';runtimeLabel.append(runtime);container.append(runtimeLabel);
 const sentenceControls=[];
 const choice=(title,options)=>{const label=make('label',title),select=make('select');for(const [value,text] of options){const option=make('option',text);option.value=value;select.append(option);}select.value=options[0][0];label.append(select);container.append(label);sentenceControls.push(select);return select;};
 const definition=registry.entries.find(e=>e.compound_id===id).definition;
 let form,time,polarity;
 if(['verb','adjective'].includes(definition.part_of_speech)){
  form=choice('Use this meaning as',[['word','Compound only'],['assertion','A statement'],['question','A yes/no question']]);
  time=choice('Time',[['','Unspecified'],['before_speech','Before now'],['at_speech','Now'],['after_speech','After now']]);
  polarity=choice('Negation and possibility',[['positive','Affirmative'],['negative','Not'],['possible','Possibly'],['possible_not','Possibly not'],['not_possible','Not possible']]);
  time.disabled=polarity.disabled=true;
 }
 const generate=make('button','Prepare music'),output=make('div');generate.type='button';container.append(generate,output);
 let revision=0;const invalidate=()=>{revision++;player?.stop();output.replaceChildren();};for(const {field} of fields)field.addEventListener('input',invalidate);runtime.addEventListener('change',invalidate);for(const control of sentenceControls)control.addEventListener('change',()=>{if(form)time.disabled=polarity.disabled=form.value==='word';invalidate();});
 generate.addEventListener('click',async()=>{
  const version=revision,values=fields.map(({field})=>field.value.trim()),state=runtime.value,choices=sentenceControls.map(c=>c.value);
  const current=()=>container.isConnected!==false&&revision===version&&runtime.value===state&&sentenceControls.every((c,i)=>c.value===choices[i])&&fields.every(({field},i)=>field.value.trim()===values[i]);
  generate.disabled=true;player?.stop();output.replaceChildren();
  try{
   const bindings=await Promise.all(fields.flatMap(({requirements},i)=>requirements.map(async requirement=>({path:requirement.path,...(requirement.slot_path?{slot_path:requirement.slot_path}:{}),role:requirement.role,reference:await contextualContentReference(values[i])}))));
   let result;
   if(form&&choices[0]!=='word'){
    const neg={operator:'negation'},possible={operator:'modality',mode:'possible'},scopes=[...(choices[1]?[{operator:'time',relation:choices[1]}]:[]),...({positive:[],negative:[neg],possible:[possible],possible_not:[possible,neg],not_possible:[neg,possible]}[choices[2]])];
    result=await composeLocalCompoundSentence(id,registry,authority,bindings,{runtimeState:Number(state),speechAct:choices[0],scopes});
   }else result=await localCompoundMusic(id,registry,authority,bindings,{runtimeState:Number(state)});if(!current())return;
   const midi=make('button','Download MIDI'),bundle=make('button','Download meaning and definitions');midi.type=bundle.type='button';
   midi.addEventListener('click',()=>{if(current())download(new Blob([result.midi],{type:'audio/midi'}),'era-zero-local-compound.mid');});
   bundle.addEventListener('click',()=>{if(current()){const {midi,...portable}=result;download(new Blob([JSON.stringify(portable,null,2)],{type:'application/json'}),'era-zero-local-compound.json');}});
   if(player){const play=make('button','Play music'),stop=make('button','Stop');play.type=stop.type='button';play.addEventListener('click',async()=>{if(!current())return;try{await player.play(result.midi);}catch(error){if(current())onError(error);}});stop.addEventListener('click',()=>player.stop());output.append(play,stop);}
   output.append(midi,bundle);
  }catch(error){if(current())onError(error);}finally{generate.disabled=false;}
 });
}
