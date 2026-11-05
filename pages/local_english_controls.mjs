import {localAdjectivePlan,composeLocalAdjective,localVerbPlan,localVerbCandidates,composeLocalVerb} from './local_compound_english.mjs';
import {expandLocalCompound} from './local_compound_expansion.mjs';
import {contextualContentReference} from './contextual_content.mjs';
export async function mountLocalEnglishControls(container,input,registry,authority,{document=globalThis.document,download,player,isCurrent=()=>true,onError=()=>{},interpretation}={}){
 const adjective=await localAdjectivePlan(input,registry,authority),plan=adjective||await localVerbPlan(input,registry,authority,{interpretation});
 if(!plan){
  const candidates=await localVerbCandidates(input,registry,authority);if(candidates.length<2)return false;
  const prompt=document.createElement('p');prompt.textContent='Choose the intended saved-word reading and time.';container.append(prompt);
  const detail=document.createElement('div');let selection=0;
  for(const candidate of candidates){const option=document.createElement('button'),entry=registry.entries.find(e=>e.compound_id===candidate.compound_id);option.textContent=`${entry.definition.label} — ${candidate.scopes.some(s=>s.operator==='time')?'past':'present'}${candidate.object?' · object: '+candidate.object:''}`;
   option.addEventListener('click',async()=>{if(!isCurrent())return;const version=++selection;player?.stop();detail.replaceChildren();try{await mountLocalEnglishControls(detail,input,registry,authority,{document,download,player,onError,isCurrent:()=>isCurrent()&&version===selection,interpretation:candidate});}catch(e){if(version===selection)onError(e);}});container.append(option);
  }container.append(detail);return true;
 }
 const make=(tag,text)=>{const el=document.createElement(tag);if(text!==undefined)el.textContent=text;return el;};
 const entry=registry.entries.find(e=>e.compound_id===plan.compound_id),expansion=await expandLocalCompound(plan.compound_id,registry,authority),fields=[];
 container.append(make('h3',entry.definition.label),make('p',entry.definition.definition),make('p',`Subject: ${plan.subject}. Time, negation, question and runtime choices come from your sentence.`));
 let subjectRole,objectRole;
 if(!adjective){
  const selector=(title)=>{const label=make('label',title),select=make('select');for(const role of [{role:'',definition:'Choose a role'},...plan.available_roles]){const option=make('option',role.role?`${role.role} — ${role.definition}`:role.definition);option.value=role.role;select.append(option);}select.value='';label.append(select);container.append(label);return select;};
  subjectRole=selector(`What role does ${plan.subject} take?`);if(plan.object)objectRole=selector(`What role does ${plan.object} take?`);
 }
 const supplied=r=>!r.path.length&&!r.slot_path&&(adjective?r.role==='bearer':[subjectRole.value,objectRole?.value].includes(r.role));
 for(const requirement of expansion.role_requirements){
  if(adjective&&supplied(requirement))continue;
  const label=make('label',`Part ${requirement.path.map(n=>n+1).join('.')||'whole'} · ${requirement.role}`),field=make('input');field.placeholder='Name or noun phrase';label.append(field);container.append(label);fields.push({requirement,field,label});
 }
 const generate=make('button','Translate saved meaning'),output=make('div');container.append(generate,output);let revision=0;
 const roleChanged=()=>{revision++;player?.stop();output.replaceChildren();for(const {requirement,field,label} of fields){label.hidden=supplied(requirement);field.disabled=label.hidden;}generate.disabled=!subjectRole.value||(objectRole&&(!objectRole.value||objectRole.value===subjectRole.value));};
 if(subjectRole){subjectRole.addEventListener('change',roleChanged);objectRole?.addEventListener('change',roleChanged);roleChanged();}
 for(const {field} of fields)field.addEventListener('input',()=>{revision++;player?.stop();output.replaceChildren();});
 generate.addEventListener('click',async()=>{
  if(!isCurrent()||generate.disabled)return;const selectedSubject=subjectRole?.value,selectedObject=objectRole?.value;const version=revision,values=fields.map(({field})=>field.value.trim()),current=()=>isCurrent()&&container.isConnected!==false&&version===revision&&subjectRole?.value===selectedSubject&&objectRole?.value===selectedObject&&fields.every(({field},i)=>field.value.trim()===values[i]);
  generate.disabled=true;player?.stop();output.replaceChildren();
  try{
   const bindings=await Promise.all(fields.map(({requirement:r},i)=>({r,i})).filter(({r})=>!supplied(r)).map(async({r,i})=>({path:r.path,...(r.slot_path?{slot_path:r.slot_path}:{}),role:r.role,reference:await contextualContentReference(values[i])})));
   const result=adjective?await composeLocalAdjective(input,registry,authority,{bindings}):await composeLocalVerb(input,registry,authority,{bindings,subjectRole:selectedSubject,objectRole:selectedObject,interpretation});if(!current())return;
   if(player){const play=make('button','Play music'),stop=make('button','Stop');play.addEventListener('click',async()=>{if(!current())return;try{await player.play(result.midi);}catch(e){if(current())onError(e);}});stop.addEventListener('click',()=>player.stop());output.append(play,stop);}
   const midi=make('button','Download MIDI'),meaning=make('button','Save meaning and definitions');
   midi.addEventListener('click',()=>{if(current())download(new Blob([result.midi],{type:'audio/midi'}),'era-zero-saved-sentence.mid');});
   meaning.addEventListener('click',()=>{if(current()){const {midi,...portable}=result;download(new Blob([JSON.stringify(portable,null,2)],{type:'application/json'}),'era-zero-saved-sentence.json');}});output.append(midi,meaning);
  }catch(e){if(current())onError(e);}finally{generate.disabled=!!subjectRole&&(!subjectRole.value||!!objectRole&&(!objectRole.value||objectRole.value===subjectRole.value));}
 });return true;
}
