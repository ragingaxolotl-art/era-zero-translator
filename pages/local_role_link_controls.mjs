import {addLocalCompound} from './local_compounds.mjs';
import {expandLocalCompound} from './local_compound_expansion.mjs';
import {localParticipantGroups} from './local_participant_groups.mjs';
export async function mountRoleLinkControls(container,definition,registry,authority,{document=globalThis.document}={}){
 const draft=await addLocalCompound(registry,definition,authority),id=draft.entries.at(-1).compound_id,expansion=await expandLocalCompound(id,draft,authority),fields=[];
 for(const group of localParticipantGroups(expansion,authority)){
  const target=group[0];if(!target.path.length)continue;
  const label=document.createElement('label'),select=document.createElement('select');label.textContent=`Part ${target.path.map(i=>i+1).join('.')} · ${target.role}${target.definition?' — '+target.definition:''}`;
  for(const role of [{role:'',definition:'Keep this participant separate'},...definition.roles]){const option=document.createElement('option');option.value=role.role;option.textContent=role.role?`Same as outer ${role.role} — ${role.definition}`:role.definition;select.append(option);}select.value='';label.append(select);container.append(label);fields.push({target,select});
 }
 if(!fields.length){const note=document.createElement('p');note.textContent='These parts have no participant roles to connect.';container.append(note);}
 return ()=>fields.filter(({select})=>select.value).map(({target,select})=>({outer_role:select.value,component_path:target.path,role:target.role,...(target.slot_path?{slot_path:target.slot_path}:{})}));
}
