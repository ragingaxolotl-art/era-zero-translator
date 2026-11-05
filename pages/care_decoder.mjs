import {strictSemanticReader} from './strict_semantic_reader.mjs';

// Reads the care relation, its argument structure and scopes from MIDI alone.
export function decodeCareMidi(bytes,atoms){
 const message='Unsupported or malformed care-relation music.',fail=()=>{throw new Error(message);};
 const {observed,marker,exactRoot,role,reference,unwrapScopes}=strictSemanticReader(bytes,atoms,message);
 const {current,scopes}=unwrapScopes(node=>node.kind==='root');
 if(current.length!==3)fail();
 const [actor,target,head]=current,runtime=head?.runtime_state;
 if(![0,1,2].includes(runtime))fail();exactRoot(head,'LIF:211','middle',runtime);
 const caregiver=role(actor,'actor','low');
 if(!marker(target,'role_target_open'))fail();
 let targets,coordination=null;
 if(target.children.length===1&&marker(target.children[0],'coord_all_of_open')){
  const members=[[]];
  for(const node of target.children[0].children){
   if(marker(node,'coord_member'))members.push([]);else members.at(-1).push(node);
  }
  if(members.length<2||members.length>32||members.some(m=>!m.length))fail();
  targets=members.map(nodes=>reference(nodes,'high'));coordination='all_of';
 }else targets=[reference(target.children,'high')];
 return {profile:'EZCARE-INVERSE-1',speech_act:observed.speech_act,scopes,predicate:'active_care',runtime_state:runtime,
  participants:{caregiver,targets},target_coordination:coordination,
  meaning:{target_list_belongs_to_one_relation:true,temporal_order_asserted:false,affection_or_preference_asserted:false},
  limitations:['The care relation remains inside recovered scope and speech act.','A coordinated target list does not encode a sequence of separate care episodes or a temporal order.','Audible reference labels do not resolve external identity, original spelling or general discourse.','This profile reads strict MIDI, not arbitrary recorded audio.']};
}
