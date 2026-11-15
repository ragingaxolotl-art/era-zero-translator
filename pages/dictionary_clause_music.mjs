import {dictionaryRoles} from './dictionary_clauses.mjs';
import {contextualContentReference} from './contextual_content.mjs';
import {informationMusic} from './information_music.mjs';
import {informationFrame} from './information_passage_frames.mjs?v=story-1';
import {midiFromScheduledEvents} from './engine.mjs';
import {registerFor} from './roles.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs?v=story-1';

const semantic=(root,participants,scopes,runtime_state,speech_act)=>({
  profile:'EZ-DICTIONARY-CLAUSE-1',status:'draft',predicate:root,participants,scopes,runtime_state,speech_act
});
const supportedScopes=new Set(['modality_necessary','modality_possible','negation','aspect_ongoing','time_before_speech','time_previous_day','time_current_day','time_next_day']);

function framed(name,events,anchor) {
  return [informationFrame(name+'_open',anchor),...events,informationFrame(name+'_close',anchor)];
}
export async function scoreRoleReference(text,role,{anchor,reference}) {
  const indefinite=/^an? (.+)$/.exec(text),group=text==='we';
  const ref=await contextualContentReference(group?'I':indefinite?'"'+indefinite[1]+'"':text);
  const identity=ref.kind==='deictic_reference'?{kind:'deictic',role:group?'speaker_group':ref.deictic_role}:
    {kind:'phonemic',reference_mode:indefinite?'indefinite_singular':ref.reference_mode||'name',phonemes:ref.name.phonemes,instance_code:null};
  const notes=await reference(ref,role);
  return {identity,notes:group?framed('speaker_group',notes,anchor):indefinite?framed('indefinite_singular',notes,anchor):notes};
}
export function readRoleReference(nodes,role,reader) {
  const fail=()=>{throw Error('Invalid role reference.');};
  const register=registerFor('argument',{nodes:[],edges:[{type:'fills_role',from:'argument',role}]});
  const frame=nodes.length===1?nodes[0].marker:undefined,group=frame==='speaker_group_open',indefinite=frame==='indefinite_singular_open';
  const ref=reader.reference(group||indefinite?nodes[0].children:nodes,register);
  if(group){if(ref.kind!=='deictic'||ref.role!=='speaker')fail();ref.role='speaker_group';}
  if(indefinite){if(ref.kind!=='phonemic'||ref.reference_mode!=='name')fail();ref.reference_mode='indefinite_singular';}
  if(ref.kind!=='deictic'&&(ref.kind!=='phonemic'||ref.instance_code!==null))fail();
  return ref;
}

export async function scoreDictionaryClause(plan,index,authority) {
  const reading=plan.readings[index];
  if(!reading)throw Error('Choose the intended word meaning.');
  const {anchor,wrap,reference,lexical}=informationMusic(authority,plan.runtime);
  const participants=[];
  let events=reading.root==='erase_stored_object' ? framed('erase_stored_object',[
    ...await lexical('ORI:110'),...wrap('role_result',wrap('negation',await lexical('DAT:000')))
  ],anchor) : await lexical(reading.root);
  for(const {role,text} of reading.participants){
    const {identity,notes}=await scoreRoleReference(text,role,{anchor,reference});
    participants.push({role,reference:identity});
    events.push(...wrap('role_'+role,notes));
  }
  events=framed('dictionary_clause',events,anchor);
  for(const scope of [...reading.scopes].reverse())events=wrap(scope,events);
  const contour=plan.speechAct==='command'?[0,-4]:plan.speechAct==='question'?[0,2]:[0,0];
  return {midi:midiFromScheduledEvents(events,anchor,contour),
    meaning:semantic(reading.root,participants,reading.scopes,plan.runtime,plan.speechAct),label:plan.needsDefinition?'Sentence with your word meaning':'Dictionary sentence'};
}

// Only the music and public vocabulary enter the inverse. Validate the role
// signature, register, scopes, runtime, and the complete enclosure.
export function decodeDictionaryClauseMidi(bytes,atoms) {
  const fail=()=>{throw Error('Invalid dictionary clause.');};
  const reader=strictSemanticReader(bytes,atoms,'Invalid dictionary clause.',{allowDraftInformationPassage:true});
  let nodes=reader.readTree();const scopes=[];
  while(nodes.length===1 && nodes[0].marker!=='dictionary_clause_open'){
    const scope=nodes[0].marker?.replace(/_open$/,'');
    if(!supportedScopes.has(scope)||!nodes[0].children||scopes.length>=8)fail();
    scopes.push(scope);nodes=nodes[0].children;
  }
  if(nodes.length!==1||nodes[0].marker!=='dictionary_clause_open')fail();
  const [head,...args]=nodes[0].children,act=reader.observed.speech_act;
  if(!head||!['assertion','question','command'].includes(act))fail();
  let root=head.root_id,runtime=head.runtime_state;
  if(head.marker==='erase_stored_object_open'){
    const [transition,result]=head.children;
    if(head.children.length!==2||!scopes.includes('modality_necessary')||result?.marker!=='role_result_open'||result.children.length!==1)fail();
    const negative=result.children[0];
    if(negative.marker!=='negation_open'||negative.children.length!==1)fail();
    root='erase_stored_object';runtime=transition.runtime_state;
    reader.exactRoot(transition,'ORI:110','middle',runtime);reader.exactRoot(negative.children[0],'DAT:000','middle',runtime);
  }else if(head.kind!=='root'||head.register!=='middle')fail();
  if(![0,1,2].includes(runtime))fail();
  const roles=args.map(n=>/^role_(.+)_open$/.exec(n.marker)?.[1]);
  if(!dictionaryRoles(root).some(signature=>signature.join()===roles.join()))fail();
  const participants=args.map((n,i)=>{
    return {role:roles[i],reference:readRoleReference(n.children,roles[i],reader)};
  });
  return semantic(root,participants,scopes,runtime,act);
}
