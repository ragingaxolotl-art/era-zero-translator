import {scoreKnownValue} from './known_value.mjs?v=field-repairs-1';
import {composeFaultCorrection,describeFaultCorrection} from './fault_correction.mjs?v=field-repairs-1';
import {describeClaim,describeRuntime} from './meaning_readback.mjs?v=field-repairs-1';
import {everydayMeaning} from './everyday.mjs';
import {scoreRoleReference,readRoleReference} from './dictionary_clause_music.mjs?v=field-repairs-1';
import {informationMusic} from './information_music.mjs?v=field-repairs-1';
import {strictSemanticReader} from './strict_semantic_reader.mjs?v=field-repairs-1';
import {midiFromFormal,midiFromScheduledEvents} from './engine.mjs';
import {storyWords,storyDependencies} from './story_words.mjs?v=field-repairs-1';
import {storyRoles,storyPropertyIds} from './story_readings.mjs?v=field-repairs-1';

const catalog = new Map([...storyWords,...storyDependencies].map(w=>[w.id,w]));
const byCode = new Map([...catalog.values()].map(w=>[w.code,w]));
const scopes = new Set(['time_before_speech','time_at_speech','time_after_speech','time_previous_day','time_current_day','time_next_day','modality_necessary','modality_possible','negation','aspect_ongoing']);
const message = (entities,events,relations,runtime_state,speech_act) => ({
  profile:'EZ-STORY-1',status:'draft',entities,events,relations,runtime_state,speech_act
});

export async function scoreStory(plan,authority) {
  if(plan.valueKnowledge)return scoreKnownValue(plan,authority);
  if(plan.faultPlan)return {...await composeFaultCorrection(plan.faultPlan,authority),label:'Fault correction',description:describeFaultCorrection(plan.faultPlan)};
  if(plan.physicalInput){
    const {composeNamedSentence,parseNamedSentence}=await import('./sentences.mjs');
    const {decodePhysicalCarryingMidi}=await import('./carrying_decoder.mjs?v=field-repairs-1');
    const parsed=parseNamedSentence(plan.physicalInput);
    if(!parsed||parsed.key!=='ongoing_physical_carrying')throw Error('This physical carrying construction needs a complete carrier and load.');
    const scored=await composeNamedSentence(plan.physicalInput,{authority});
    const midi=midiFromFormal(scored.formal);
    const meaning=decodePhysicalCarryingMidi(midi,authority.atoms);
    return {midi,meaning,label:'Physical carrying',description:plan.physicalInput+' '+parsed.semanticNote};
  }
  const music=informationMusic(authority,plan.runtime);
  const {anchor,wrap,marker,lexical}=music;
  const draft=(name,events)=>wrap(name,events,true);
  const number=n=>[...String(n)].map(d=>marker('digit_'+d));
  const notes=[],entities=[];
  for(const e of plan.entities){
    const ref=e.domain?{identity:{kind:'domain',domain:e.domain},notes:draft('story_'+e.domain+'_set',[])}:
      await scoreRoleReference(e.reference,'content',music,e.referenceKind);
    entities.push({identity:ref.identity,plural:e.plural,owner:e.owner});
    const value=e.plural?draft('story_plural',ref.notes):[...ref.notes];
    if(e.owner!==null)value.push(...draft('story_owner',number(e.owner)));
    notes.push(...draft('story_entity',value));
  }
  const qualityMusic=informationMusic(authority,1);
  for(const e of plan.events){
    let body=await lexical(e.predicate);
    for(const argument of e.arguments){
      const values=[];
      for(const option of [argument,...argument.alternatives||[]]){
        if(values.length)values.push(marker('coord_member'));
        values.push(...number(option.entity));
        for(const p of option.properties)values.push(...draft('story_property',await qualityMusic.lexical(p)));
      }
      const bodyNotes=argument.coordination==='any_of'?wrap('coord_any_of',values):values;
      body.push(...wrap('role_'+argument.role,bodyNotes));
    }
    for(const scope of [...e.scopes].reverse())body=scope==='ability'?draft('story_ability',body):wrap(scope,body);
    if(e.quantifier)body=e.quantifier==='few'?draft('story_few',body):wrap('quantifier_'+e.quantifier,body);
    if(e.negated_quantifier)body=wrap('negation',body);
    notes.push(...draft('story_event',body));
  }
  for(const relation of plan.relations){
    const members=[...number(relation.events[0]),marker(relation.kind==='condition'?'conditional_then':'coord_member'),...number(relation.events[1])];
    if(relation.kind==='condition')notes.push(...wrap('conditional_open',members));
    else notes.push(...draft(relation.kind==='before'?'story_before':'story_together',members));
  }
  const contour=plan.act==='command'?[0,-4]:plan.act==='question'?[0,2]:[0,0];
  return {midi:midiFromScheduledEvents(draft('story',notes),anchor,contour),
    meaning:message(entities,plan.events,plan.relations,plan.runtime,plan.act),label:'Story reading',description:describeStory(plan,authority)};
}

export function describeStory(plan,authority){
  const label=key=>everydayMeaning(authority,key) || catalog.get(key)?.word || authority.atoms.find(a=>a.canonical_id===key)?.title || key;
  const names=plan.events.map(e=>e.arguments.map(a=>plan.entities[a.entity].label).join(' / '));
  const lines=plan.events.map((e,i)=>{
    const name=a=>plan.entities[a.entity].label+(a.properties.length?' ('+a.properties.map(label).join(', ')+')':'');
    const binding=e.arguments.map(a=>a.role+' = '+[a,...a.alternatives||[]].map(name).join(' or ')).join(', ');
    const conditional=plan.relations.find(r=>r.kind==='condition'&&r.events.includes(i));
    const claim=describeClaim(label(e.predicate),e.scopes,plan.act,e.quantifier,e.negated_quantifier);
    const reading=conditional?(conditional.events[0]===i?'Condition considered · ':'Consequence if the condition holds · ')+claim:claim;
    return 'Action '+(i+1)+' · '+reading+' '+binding+'.';
  });
  for(const r of plan.relations){
    const [a,b]=r.events;
    if(r.kind==='before')lines.push('Action '+(a+1)+' ('+names[a]+') happens before action '+(b+1)+' ('+names[b]+').');
    else if(r.kind==='condition')lines.push('Action '+(b+1)+' depends on action '+(a+1)+'. The condition is left open.');
    else lines.push('Both actions are included. Their timing is unspecified.');
  }
  return [...lines,...new Set(plan.notes),describeRuntime(plan.runtime)].join(' ');
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
  if(!['assertion','command','question'].includes(act))invalid();
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
      const content=plural?list[0].children:list;
      const domain=content.length===1&&/^story_(contextual|people|things)_set_open$/.exec(content[0].marker||'');
      if(domain&&(!plural||content[0].children.length))invalid();
      const identity=domain?{kind:'domain',domain:domain[1]}:readRoleReference(content,'content',reader);
      entities.push({identity,plural,owner});
    }else if(node.marker==='story_event_open' && entities.length && !relations.length && events.length<16){
      let quantifier=null,negated_quantifier=false;
      if(list.length===1 && list[0].marker==='negation_open' && list[0].children[0]?.marker==='quantifier_all_open'){
        negated_quantifier=true;list=list[0].children;
      }
      if(list.length===1 && /^quantifier_(all|none)_open$/.test(list[0].marker)){
        quantifier=list[0].marker.split('_')[1];list=list[0].children;
      }
      if(list.length===1&&list[0].marker==='story_few_open'){quantifier='few';list=list[0].children;}
      const modifiers=[];
      while(list.length===1 && (list[0].marker==='story_ability_open'||scopes.has(list[0].marker?.replace(/_open$/,'')))){
        modifiers.push(list[0].marker==='story_ability_open'?'ability':list[0].marker.slice(0,-5));list=list[0].children;
      }
      const [head,...roles]=list,word=readWord(head);
      if(runtime!==null&&runtime!==word.state)invalid();runtime=word.state;
      const args=roles.map(n=>{
        const role=/^role_(.+)_open$/.exec(n.marker)?.[1];if(!role)invalid();
        const member=children=>{
          const propertyStart=children.findIndex(c=>c.marker==='story_property_open');
          const digits=propertyStart<0?children:children.slice(0,propertyStart);
          const entity=number(digits);if(!entities[entity])invalid();
          const properties=children.slice(digits.length).map(p=>{
            if(p.marker!=='story_property_open'||p.children.length!==1)invalid();
            const w=readWord(p.children[0]);if(!storyPropertyIds.has(w.id)||w.state!==1)invalid();return w.id;
          });
          return {entity,properties};
        };
        if(n.children.length===1&&n.children[0].marker==='coord_any_of_open'){
          const members=[[]];
          for(const child of n.children[0].children){
            if(child.marker==='coord_member')members.push([]);else members.at(-1).push(child);
          }
          if(members.length<2||members.length>48)invalid();
          const [first,...alternatives]=members.map(member);
          return {role,...first,coordination:'any_of',alternatives};
        }
        return {role,...member(n.children)};
      });
      if(!storyRoles(word.id).some(signature=>signature.join('/')===args.map(a=>a.role).join('/')))invalid();
      if(quantifier&&!entities[args[0].entity].plural)invalid();
      events.push({predicate:word.id,arguments:args,scopes:modifiers,quantifier,negated_quantifier});
    }else if(['story_before_open','story_together_open','conditional_open_open'].includes(node.marker)){
      const conditional=node.marker==='conditional_open_open';
      const split=list.findIndex(n=>n.marker===(conditional?'conditional_then':'coord_member'));
      if(split<1)invalid();
      const pair=[number(list.slice(0,split)),number(list.slice(split+1))];
      if(pair[0]===pair[1]||pair.some(k=>!events[k]))invalid();
      relations.push({kind:conditional?'condition':node.marker==='story_before_open'?'before':'and',events:pair});
    }else invalid();
  }
  if(!events.length || entities.some((_,i)=>!entities.some(e=>e.owner===i)&&!events.some(e=>e.arguments.some(a=>a.entity===i||a.alternatives?.some(o=>o.entity===i)))))invalid();
  return message(entities,events,relations,runtime,act);
}
