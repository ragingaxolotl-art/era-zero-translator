import {everydayMeaning} from './everyday.mjs';
import {scoreRoleReference,readRoleReference} from './dictionary_clause_music.mjs';
import {informationMusic} from './information_music.mjs';
import {strictSemanticReader} from './strict_semantic_reader.mjs';
import {midiFromScheduledEvents} from './engine.mjs';
import {storyWords,storyDependencies} from './story_words.mjs?v=story-passages-1';
import {storyRoles,storyPropertyIds} from './story_readings.mjs?v=story-passages-1';

const catalog = new Map([...storyWords,...storyDependencies].map(w=>[w.id,w]));
const byCode = new Map([...catalog.values()].map(w=>[w.code,w]));
const scopes = new Set(['time_before_speech','time_previous_day','time_current_day','time_next_day','modality_necessary','modality_possible','negation','aspect_ongoing']);
const message = (entities,events,relations,runtime_state,speech_act) => ({
  profile:'EZ-STORY-1',status:'draft',entities,events,relations,runtime_state,speech_act
});

export async function scoreStory(plan,authority) {
  const music=informationMusic(authority,plan.runtime);
  const {anchor,wrap,marker,lexical}=music;
  const draft=(name,events)=>wrap(name,events,true);
  const number=n=>[...String(n)].map(d=>marker('digit_'+d));
  const notes=[],entities=[];
  for(const e of plan.entities){
    const ref=await scoreRoleReference(e.reference,'content',music);
    entities.push({identity:ref.identity,plural:e.plural,owner:e.owner});
    const value=e.plural?draft('story_plural',ref.notes):[...ref.notes];
    if(e.owner!==null)value.push(...draft('story_owner',number(e.owner)));
    notes.push(...draft('story_entity',value));
  }
  const qualityMusic=informationMusic(authority,1);
  for(const e of plan.events){
    let body=await lexical(e.predicate);
    for(const argument of e.arguments){
      const value=number(argument.entity);
      for(const p of argument.properties)value.push(...draft('story_property',await qualityMusic.lexical(p)));
      body.push(...wrap('role_'+argument.role,value));
    }
    for(const scope of [...e.scopes].reverse())body=wrap(scope,body);
    if(e.quantifier)body=wrap('quantifier_'+e.quantifier,body);
    if(e.negated_quantifier)body=wrap('negation',body);
    notes.push(...draft('story_event',body));
  }
  for(const relation of plan.relations){
    const members=[...number(relation.events[0]),marker('coord_member'),...number(relation.events[1])];
    notes.push(...draft(relation.kind==='before'?'story_before':'story_together',members));
  }
  const contour=plan.act==='command'?[0,-4]:[0,0];
  return {midi:midiFromScheduledEvents(draft('story',notes),anchor,contour),
    meaning:message(entities,plan.events,plan.relations,plan.runtime,plan.act),label:'Story reading',description:describeStory(plan,authority)};
}

export function describeStory(plan,authority){
  const label=key=>everydayMeaning(authority,key) || catalog.get(key)?.word || authority.atoms.find(a=>a.canonical_id===key)?.title || key;
  const names=plan.events.map(e=>e.arguments.map(a=>plan.entities[a.entity].label).join(' / '));
  const lines=plan.events.map((e,i)=>{
    const binding=e.arguments.map(a=>a.role+' = '+plan.entities[a.entity].label+
      (a.properties.length?' ('+a.properties.map(label).join(', ')+')':'')).join(', ');
    return 'Action '+(i+1)+' · '+label(e.predicate)+' · '+binding+'.';
  });
  for(const r of plan.relations){
    const [a,b]=r.events;
    if(r.kind==='before')lines.push('Action '+(a+1)+' ('+names[a]+') happens before action '+(b+1)+' ('+names[b]+').');
    else lines.push('Both actions are asserted. Their timing is unspecified.');
  }
  return [...lines,...new Set(plan.notes)].join(' ');
}

// Match the entire nested dictionary sound. The last part is the semantic
// head and carries the occurrence ending. Qualifying roots have no ending.
function readWord(node){
  const fail=()=>{throw Error('Invalid story vocabulary sound.');};
  function part(n,id,head){
    const item=catalog.get(id);
    if(!item){
      if(n.kind!=='root'||n.root_id!==id||n.register!=='middle'||
        (head?![0,1,2].includes(n.runtime_state):n.runtime_state!==null))fail();
      return n.runtime_state;
    }
    if(n.marker!=='convention_'+item.code+'_open'||n.children.length!==item.parts.length)fail();
    const endings=item.parts.map((p,i)=>part(n.children[i],p,head&&i===item.parts.length-1));
    return endings.at(-1);
  }
  const id=node?.kind==='root'?node.root_id:byCode.get(node?.sound_code)?.id;
  if(!id)fail();
  return {id,state:part(node,id,true)};
}
export function decodeStoryMidi(bytes,atoms) {
  const invalid=()=>{throw Error('Invalid story reading.');};
  const reader=strictSemanticReader(bytes,atoms,'Invalid story reading.',{allowDraftInformationPassage:true});
  const tree=reader.readTree();
  if(tree.length!==1||tree[0].marker!=='story_open')invalid();
  const act=reader.observed.speech_act;
  if(!['assertion','command'].includes(act))invalid();
  const number=list=>{
    const digits=list.map(n=>/^digit_([0-9])$/.exec(n.marker)?.[1]??'x').join('');
    if(!/^(0|[1-9][0-9]?)$/.test(digits))invalid();
    return Number(digits);
  };
  const entities=[],events=[],relations=[];
  let runtime=null;
  for(const node of tree[0].children){
    let list=node.children;
    if(node.marker==='story_entity_open' && !events.length && entities.length<48){
      let owner=null;
      if(list.at(-1)?.marker==='story_owner_open'){
        owner=number(list.at(-1).children);if(!entities[owner])invalid();list=list.slice(0,-1);
      }
      const plural=list.length===1&&list[0].marker==='story_plural_open';
      entities.push({identity:readRoleReference(plural?list[0].children:list,'content',reader),plural,owner});
    }else if(node.marker==='story_event_open' && entities.length && !relations.length && events.length<16){
      let quantifier=null,negated_quantifier=false;
      if(list.length===1 && list[0].marker==='negation_open' && list[0].children[0]?.marker==='quantifier_all_open'){
        negated_quantifier=true;list=list[0].children;
      }
      if(list.length===1 && /^quantifier_(all|none)_open$/.test(list[0].marker)){
        quantifier=list[0].marker.split('_')[1];list=list[0].children;
      }
      const modifiers=[];
      while(list.length===1 && scopes.has(list[0].marker?.replace(/_open$/,''))){
        modifiers.push(list[0].marker.slice(0,-5));list=list[0].children;
      }
      const [head,...roles]=list,word=readWord(head);
      if(runtime!==null&&runtime!==word.state)invalid();runtime=word.state;
      const args=roles.map(n=>{
        const role=/^role_(.+)_open$/.exec(n.marker)?.[1];if(!role)invalid();
        const propertyStart=n.children.findIndex(c=>c.marker==='story_property_open');
        const digits=propertyStart<0?n.children:n.children.slice(0,propertyStart);
        const entity=number(digits);if(!entities[entity])invalid();
        const properties=n.children.slice(digits.length).map(p=>{
          if(p.marker!=='story_property_open'||p.children.length!==1)invalid();
          const w=readWord(p.children[0]);if(!storyPropertyIds.has(w.id)||w.state!==1)invalid();return w.id;
        });
        return {role,entity,properties};
      });
      if(!storyRoles(word.id).some(signature=>signature.join('/')===args.map(a=>a.role).join('/')))invalid();
      if(quantifier&&!entities[args[0].entity].plural)invalid();
      events.push({predicate:word.id,arguments:args,scopes:modifiers,quantifier,negated_quantifier});
    }else if(['story_before_open','story_together_open'].includes(node.marker)){
      const split=list.findIndex(n=>n.marker==='coord_member');
      if(split<1)invalid();
      const pair=[number(list.slice(0,split)),number(list.slice(split+1))];
      if(pair[0]===pair[1]||pair.some(k=>!events[k]))invalid();
      relations.push({kind:node.marker==='story_before_open'?'before':'and',events:pair});
    }else invalid();
  }
  if(!events.length || entities.some((_,i)=>!entities.some(e=>e.owner===i)&&!events.some(e=>e.arguments.some(a=>a.entity===i))))invalid();
  return message(entities,events,relations,runtime,act);
}
