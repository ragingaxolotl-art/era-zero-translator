import {FELT_CONDITIONS} from './felt_conditions.mjs';
import {readFeltConditionTree} from './felt_decoder.mjs?v=partial-word-flow-1';
import {renderLexicalOccurrences} from './bound_compounds.mjs?v=partial-word-flow-1';
import {deicticReference} from './references.mjs';
import {validStorySlots,savedQualityLabel} from './story_saved_adjectives.mjs?v=container-actions-1';
import {notesFromMidi} from './performance_codec.mjs?v=partial-word-flow-1';
import {scoreKnownValue} from './known_value.mjs?v=physical-closing-1';
import {composeFaultCorrection,describeFaultCorrection} from './fault_correction.mjs?v=physical-closing-1';
import {describeClaim,describeRuntime} from './meaning_readback.mjs?v=field-repairs-1';
import {everydayMeaning} from './everyday.mjs?v=partial-word-flow-1';
import {scoreRoleReference,readRoleReference} from './dictionary_clause_music.mjs?v=physical-closing-1';
import {informationMusic} from './information_music.mjs?v=partial-word-flow-1';
import {strictSemanticReader} from './strict_semantic_reader.mjs?v=partial-word-flow-1';
import {midiFromFormal,midiFromScheduledEvents} from './engine.mjs?v=partial-word-flow-1';
import {storyWords,storyDependencies} from './story_words.mjs?v=physical-closing-1';
import {storyRoles,storyPropertyIds,needsState} from './story_readings.mjs?v=physical-closing-1';
import {ERASURE,erasureLabel,scoreErasure,readErasure} from './information_operations.mjs?v=information-operations-1';
import {containerAction,containerPropertyNeedsPhase} from './container_actions.mjs?v=physical-closing-1';
import {contextualProperty,contextualPropertyNorm,contextualPropertyLabel} from './story_contextual_properties.mjs?v=contextual-modifiers-1';
import {readContextualStandard} from './contextual_standard_decoder.mjs?v=contextual-modifiers-1';
import {closingAction,closingPropertyNeedsPhase} from './physical_closing.mjs?v=physical-closing-1';

const feltTargets=new Map(FELT_CONDITIONS.map(f=>[f.predicate,f]));
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
    const {composeNamedSentence,parseNamedSentence}=await import('./sentences.mjs?v=partial-word-flow-1');
    const {decodePhysicalCarryingMidi}=await import('./carrying_decoder.mjs?v=partial-word-flow-1');
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
  async function propertySound(value,bearer){
    const norm=contextualPropertyNorm(value);
    if(norm)return draft('story_property',wrap('contextual_'+norm,[...wrap('role_bearer',number(bearer)),...await qualityMusic.lexical('MAT:010')]));
    if(value&&typeof value==='object'&&Object.hasOwn(value,'contextual_norm'))throw Error('A contextual property must contain exactly one supported norm.');
    const felt=feltTargets.get(value);
    if(felt){
      const slot=felt.compoundSlots.experiencer;
      const node={node_id:'quality',kind:'lexical_occurrence',target_type:'compound',target_id:value,runtime_state:{code:1},
        compound_bindings:[{slot_path:slot,role:'experiencer',argument_id:'bearer'}]};
      const events=await renderLexicalOccurrences({nodes:[node,deicticReference('speaker','bearer')],edges:[]},authority,{anchor});
      // Inside a story the bound reference is the existing numbered entity.
      // Replace the reference sound in its experiencer role, keeping the dictionary performance.
      return draft('story_property',events.flatMap(e=>e.kind==='deictic_reference'?wrap('role_experiencer',number(bearer)):[e]));
    }
    if(typeof value==='string')return draft('story_property',await qualityMusic.lexical(value));
    const entry=plan.adjectives.byId.get(value.local_id);
    const slots=value.bindings.flatMap((entity,i)=>wrap('role_'+entry.slots[i].role,number(entity)));
    return draft('story_property',[...slots,...entry.events]);
  }
  for(const e of plan.events){
    let body=e.predicate===ERASURE?await scoreErasure(music):await lexical(e.predicate);
    if(e.condition)body.push(...await propertySound(e.condition,e.arguments.find(a=>a.role==='bearer').entity));
    for(const argument of e.arguments){
      const values=[];
      for(const option of [argument,...argument.alternatives||[]]){
        if(values.length)values.push(marker('coord_member'));
        values.push(...number(option.entity));
        for(const p of option.properties)values.push(...await propertySound(p,option.entity));
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
  const label=key=>contextualPropertyLabel(key)||(typeof key==='object'?savedQualityLabel(key,plan.adjectives,i=>plan.entities[i].label):key===ERASURE?erasureLabel:everydayMeaning(authority,key) || catalog.get(key)?.word || authority.atoms.find(a=>a.canonical_id===key)?.title || key);
  const names=plan.events.map(e=>e.arguments.map(a=>plan.entities[a.entity].label).join(' / '));
  const lines=plan.events.map((e,i)=>{
    const name=a=>plan.entities[a.entity].label+(a.properties.length?' ('+a.properties.map(label).join(', ')+')':'');
    const binding=e.arguments.map(a=>a.role+' = '+[a,...a.alternatives||[]].map(name).join(' or ')).join(', ');
    const conditional=plan.relations.find(r=>r.kind==='condition'&&r.events.includes(i));
    const claim=describeClaim(label(e.predicate)+(e.condition?' · '+label(e.condition):''),e.scopes,plan.act,e.quantifier,e.negated_quantifier);
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
function readWord(node,reader){
  const operation=readErasure(node,reader);if(operation)return operation;
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
export function decodeStoryMidi(bytes,atoms,adjectives) {
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
  let clock;
  function readProperty(node,bearer){
    if(node?.marker!=='story_property_open'||!node.children.length)invalid();
    const content=node.children,word=content.at(-1);
    if(word.marker?.startsWith('contextual_')){
      if(content.length!==1)invalid();
      const value=readContextualStandard(reader,content,invalid,children=>{
        const entity=number(children);if(entity!==bearer)invalid();return {kind:'story_entity',entity};
      });
      if(value.scopes.length||value.material_root!=='MAT:010'||value.runtime_state!==1)invalid();
      return contextualProperty(value.standard.norm);
    }
    if(!word.local_code){
      if(content.length!==1)invalid();
      if([13,15,16,17,19].includes(word.sound_code)){
        const quality=readFeltConditionTree(word,reader,participant=>{
          if(participant.marker!=='role_experiencer_open'||number(participant.children)!==bearer)invalid();
          return bearer;
        });
        const target=FELT_CONDITIONS.find(f=>f.key===quality.predicate);
        if(!target||quality.runtime_state!==1)invalid();
        return target.predicate;
      }
      const value=readWord(word,reader);
      if(value.state!==1||!storyPropertyIds.has(value.id))invalid();
      return value.id;
    }
    const entry=adjectives?.byCode.get(word.local_code);
    if(!entry || word.local_relation!=='head' || content.length!==entry.slots.length+1)invalid();
    const bindings=content.slice(0,-1).map((slot,i)=>{
      if(slot.marker!=='role_'+entry.slots[i].role+'_open')invalid();
      return number(slot.children);
    });
    if(!validStorySlots(entry,bindings,bearer,entities.length))invalid();
    clock??=notesFromMidi(bytes);
    const close=reader.observed.tokens[word.closing_token];
    const played=clock.notes.filter(n=>n.start_tick>=word.start_tick&&n.start_tick<close.end_tick);
    if(played.length!==entry.pattern.length || !entry.pattern.every(([pitch,start,end],i)=>
      played[i].midi===reader.observed.anchor_midi+pitch && played[i].start_tick===word.start_tick+start*clock.division &&
      played[i].end_tick===word.start_tick+end*clock.division))invalid();
    return {local_id:entry.id,bindings};
  }
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
      const [head,...roles]=list,word=readWord(head,reader);
      if(runtime!==null&&runtime!==word.state)invalid();runtime=word.state;
      const stateNode=needsState(word.id)?roles.shift():null;
      if(needsState(word.id)&&!stateNode)invalid();
      const args=roles.map(n=>{
        const role=/^role_(.+)_open$/.exec(n.marker)?.[1];if(!role)invalid();
        const member=children=>{
          const propertyStart=children.findIndex(c=>c.marker==='story_property_open');
          const digits=propertyStart<0?children:children.slice(0,propertyStart);
          const entity=number(digits);if(!entities[entity])invalid();
          const properties=children.slice(digits.length).map(p=>readProperty(p,entity));
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
      if(catalog.get(word.id)?.word==='put' && [args[1],...args[1].alternatives||[]].some(a=>a.entity===args[0].entity||a.entity===args[2].entity))invalid();
      if(containerAction(word.id)&&[args[1],...args[1].alternatives||[]].some(a=>a.entity===args[0].entity||a.properties.some(p=>containerPropertyNeedsPhase(p,adjectives))))invalid();
      if(closingAction(word.id)){
        const bearer=args.find(a=>a.role==='bearer');
        if([bearer,...bearer.alternatives||[]].some(a=>a.properties.some(p=>closingPropertyNeedsPhase(p,adjectives))||
          closingAction(word.id)==='caused'&&a.entity===args.find(a=>a.role==='cause').entity))invalid();
      }
      const condition=stateNode?readProperty(stateNode,args.find(a=>a.role==='bearer').entity):null;
      if(quantifier&&!entities[args[0].entity].plural)invalid();
      events.push({predicate:word.id,arguments:args,scopes:modifiers,quantifier,negated_quantifier,...(condition?{condition}:{})});
    }else if(['story_before_open','story_together_open','conditional_open_open'].includes(node.marker)){
      const conditional=node.marker==='conditional_open_open';
      const split=list.findIndex(n=>n.marker===(conditional?'conditional_then':'coord_member'));
      if(split<1)invalid();
      const pair=[number(list.slice(0,split)),number(list.slice(split+1))];
      if(pair[0]===pair[1]||pair.some(k=>!events[k]))invalid();
      relations.push({kind:conditional?'condition':node.marker==='story_before_open'?'before':'and',events:pair});
    }else invalid();
  }
  const referenced=new Set();
  for(const e of entities)if(e.owner!==null)referenced.add(e.owner);
  for(const event of events){
    for(const entity of event.condition?.bindings||[])referenced.add(entity);
    for(const arg of event.arguments)for(const option of [arg,...arg.alternatives||[]]){
      referenced.add(option.entity);
      for(const p of option.properties)for(const entity of p.bindings||[])referenced.add(entity);
    }
  }
  if(!events.length || referenced.size!==entities.length)invalid();
  return message(entities,events,relations,runtime,act);
}
