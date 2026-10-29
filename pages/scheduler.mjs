const PROPERTY_COMPARISONS=['equal','greater_than','less_than','at_least','at_most','not_equal'];
const MEASURE_COMPARISONS=['greater_than','less_than','at_least','at_most','not_equal'];
const CONDITION_STATUSES=['open','satisfied','unsatisfied','counterfactual'];
import {ROLE_ORDER} from './roles.mjs';
const QUANTIFIERS=['exact','at_least','at_most','all','some','none'];
const MEASUREMENT_UNITS=['1','second','minute','hour','day','meter','kilometer','gram','kilogram','degree','radian','bit','byte','kelvin'];
const MODAL_MODES = ['possible','necessary','permitted','obligated','intended','predicted','counterfactual'];
// Counted-scope scheduling shared by browser sound, notation and MIDI export.
export function scheduledLexicalEvents(formal, maxEvents = 100000) {
  const events = frameBoundArguments(formal, maxEvents);
  const ir = formal.semantic_ir;
  for (const node of ir.nodes) {
    if(node.kind==='scope_operator'&&node.operator==='comparison')validatePropertyComparison(node,ir);
    if(['variable','reference'].includes(node.kind))throw new Error('Unsupported musical discourse variable/reference.');
    if ((node.kind === 'scope_operator' && !['negation','repetition','modality','quantifier','comparison'].includes(node.operator)) ||
        (node.kind === 'coordination' && !['sequence','all_of','any_of','exactly_one'].includes(node.operator)))
      throw new Error(`Unsupported musical operator: ${node.operator}.`);
  }
  for (const node of ir.nodes.filter(node=>node.operator==='modality')) {
    if (!MODAL_MODES.includes(node.mode) || (node.strength !== undefined && (!['possible','necessary','predicted'].includes(node.mode) || typeof node.strength!=='string' || node.strength.length>1024 || !/^(?:0|1|0\.[0-9]*[1-9])$/.test(node.strength))))
      throw new Error('Unsupported musical modality mode or confidence strength.');
  }
  validateTimeRelations(ir);
  for(const edge of ir.edges.filter(edge=>edge.type==='condition_of')){
    if(!CONDITION_STATUSES.includes(edge.condition_status)||ir.nodes.find(n=>n.node_id===edge.from)?.kind!=='clause'||ir.nodes.find(n=>n.node_id===edge.to)?.kind!=='clause'||Object.keys(edge).some(key=>!['edge_id','type','from','to','condition_status'].includes(key)))throw new Error('Unsupported musical condition.');
  }
  if (!ir.edges.some(edge=>edge.type==='condition_of') && !ir.edges.some(edge=>edge.type==='fills_role') && !ir.nodes.some(node=>node.kind==='measurement') && !ir.edges.some(edge=>edge.type==='time_relation') && !ir.nodes.some(node => ['repetition','sequence','negation','modality','quantifier','all_of','any_of','exactly_one'].includes(node.operator))) return events;
  const nodes = new Map(ir.nodes.map(node => [node.node_id, node]));
  const incoming = new Map();
  for (const edge of ir.edges) {
    if (!incoming.has(edge.to)) incoming.set(edge.to, []);
    incoming.get(edge.to).push(edge);
  }
  const active = new Set();
  function walk(id) {
    if (active.has(id)) throw new Error('Cyclic repetition scope.');
    if (active.size >= 128) throw new Error('Performance scope exceeds nesting limit 128.');
    active.add(id);
    const node = nodes.get(id);
    if (!node) throw new Error(`Unknown performance scope ${id}.`);
    const edges = incoming.get(id) || [];
    let result;
    if (node.kind === 'scope_operator') {
      if (!['negation','modality','quantifier','comparison'].includes(node.operator) && (node.operator !== 'repetition' || node.mode !== 'count' || !Number.isSafeInteger(node.count) || node.count < 1))
        throw new Error('Counted repetition requires a positive count and supported nested scopes.');
      const scoped = edges.filter(edge => edge.type === 'scopes');
      if (scoped.length !== 1) throw new Error('Repetition must have exactly one scope.');
      const phrase = walk(scoped[0].from);
      if (!phrase.length) throw new Error('Repetition scope has no sound events.');
      if(node.operator==='comparison'){validatePropertyComparison(node,ir);result=[grammarMarker(formal,id,`property_${node.dimension}_${node.relation}_open`),...phrase,grammarMarker(formal,id,`property_${node.dimension}_${node.relation}_close`)];}
      else if(node.operator==='negation')result=[grammarMarker(formal,id,'negation_open'),...phrase,grammarMarker(formal,id,'negation_close')];
      else if(node.operator==='quantifier')result=[...quantifierMarkers(formal,node),...phrase,grammarMarker(formal,id,`quantifier_${node.quantifier}_close`)];
      else if(node.operator==='modality')result=[grammarMarker(formal,id,`modality_${node.mode}_open`),...confidenceMarkers(formal,id,node.strength),...phrase,grammarMarker(formal,id,`modality_${node.mode}_close`)];
      else{
        if (phrase.length * node.count > maxEvents) throw new Error(`Repetition exceeds event limit ${maxEvents}.`);
        result = [];
        for (let i = 0; i < node.count; i++) result.push(...phrase);
      }
    } else if (node.kind === 'clause') {
      const centers = edges.filter(edge => edge.type === 'centers');
      if (centers.length !== 1) throw new Error('Repetition clause requires one center.');
      result = walk(centers[0].from);
      const times=edges.filter(edge=>edge.type==='time_relation').sort((a,b)=>a.edge_id<b.edge_id?-1:a.edge_id>b.edge_id?1:0);
      for(const time of times.slice().reverse())result=[grammarMarker(formal,id,`${timeFrame(time,nodes)}_open`),...result,grammarMarker(formal,id,`${timeFrame(time,nodes)}_close`)];
      const conditions=edges.filter(edge=>edge.type==='condition_of');
      if(conditions.length>1)throw new Error('Unsupported musical multiple conditions; use explicit coordination.');
      if(conditions.length){const condition=conditions[0];result=[grammarMarker(formal,id,`conditional_${condition.condition_status}_open`),...walk(condition.from),grammarMarker(formal,id,'conditional_then'),...result,grammarMarker(formal,id,`conditional_${condition.condition_status}_close`)];}
    } else if (node.kind === 'measurement') {
      result=measurementMarkers(formal,node);
    } else if (node.kind === 'coordination') {
      const members = edges.filter(edge => edge.type === 'member_of');
      if(members.length<2)throw new Error('Coordination requires at least two members.');
      if(node.operator==='sequence'){
      if (members.some(edge => !Number.isSafeInteger(edge.order)) || new Set(members.map(edge => edge.order)).size !== members.length)
        throw new Error('Repeated sequence requires distinct explicit member order.');
      result = members.sort((a,b) => a.order-b.order).flatMap((edge,index) => {const phrase=walk(edge.from);if(index<members.length-1&&phrase.length)phrase[phrase.length-1]={...phrase.at(-1),boundary_after_beats:1};return phrase;});
      }else{
        if(members.some(edge=>edge.order!==undefined))throw new Error('Unordered coordination cannot declare sequence order.');
        result=[grammarMarker(formal,id,`coord_${node.operator}_open`)];
        members.sort((a,b)=>a.edge_id<b.edge_id?-1:a.edge_id>b.edge_id?1:0).forEach((edge,index)=>{
          if(index)result.push(grammarMarker(formal,id,'coord_member'));
          result.push(...walk(edge.from));
        });
        result.push(grammarMarker(formal,id,`coord_${node.operator}_close`));
      }
    } else if (['lexical_occurrence','phonemic_reference','deictic_reference'].includes(node.kind)) {
      const argumentsInOrder=edges.filter(edge=>['fills_role','qualifies'].includes(edge.type)).sort((a,b)=>a.edge_id<b.edge_id?-1:a.edge_id>b.edge_id?1:0),seenArguments=new Map();
      result=argumentsInOrder.flatMap(edge=>{
        if(edge.type!=='fills_role')return walk(edge.from);
        const previousRole=seenArguments.get(edge.from);
        if(previousRole&&argumentsInOrder.filter(e=>e.type==='fills_role'&&e.role===previousRole).length!==1)throw new Error('Ambiguous musical role reference.');
        const phrase=previousRole?[grammarMarker(formal,edge.edge_id,`role_reference_${previousRole}`)]:walk(edge.from);
        if(!previousRole)seenArguments.set(edge.from,edge.role);
        return [grammarMarker(formal,edge.edge_id,`role_${edge.role}_open`),...phrase,grammarMarker(formal,edge.edge_id,`role_${edge.role}_close`)];
      }).concat(events.filter(event=>event.occurrence_id===id));
    } else throw new Error(`Unsupported node in repetition scope: ${node.kind}.`);
    active.delete(id);
    if (result.length > maxEvents) throw new Error(`Repetition exceeds event limit ${maxEvents}.`);
    return result;
  }
  const scheduled = walk(ir.root_clause);
  const ids = values => [...new Set(values.map(event => event.occurrence_id))].sort().join('\n');
  if (ids(scheduled.filter(event=>event.kind!=='grammar_marker')) !== ids(events)) throw new Error('Repetition schedule would omit lexical occurrences.');
  return scheduled;
}

function quantifierMarkers(formal,node){
  const counted=['exact','at_least','at_most'].includes(node.quantifier);
  if(!QUANTIFIERS.includes(node.quantifier)||Object.keys(node).some(key=>!['node_id','kind','operator','quantifier',...(counted?['value']:[])].includes(key))||(counted&&(typeof node.value!=='string'||node.value.length>1024||!/^(?:0|[1-9][0-9]*)$/.test(node.value))))throw new Error('Unsupported musical quantifier.');
  return [`quantifier_${node.quantifier}_open`,...(counted?Array.from(node.value,char=>`digit_${char}`):[])].map(marker=>grammarMarker(formal,node.node_id,marker));
}
function measurementMarkers(formal,node){
  const value=node.magnitude,unit=MEASUREMENT_UNITS.indexOf(node.unit);
  if(node.comparison!==undefined&&!MEASURE_COMPARISONS.includes(node.comparison))throw new Error('Unsupported musical measurement comparison.');
  if(typeof value!=='string'||value.length>1024||value==='-0'||!/^-?(?:0|[1-9][0-9]*)(?:\.[0-9]*[1-9])?$/.test(value)||unit<0||Object.keys(node).some(key=>!['node_id','kind','magnitude','unit','comparison'].includes(key)))throw new Error('Unsupported musical measurement.');
  const markers=['measurement_open',...Array.from(value,char=>char==='-'?'measurement_negative':char==='.'?'decimal_point':`digit_${char}`),`measurement_unit_${unit+1}`,'measurement_close'];
  if(node.comparison)markers.unshift(`measure_compare_${node.comparison}_open`);
  if(node.comparison)markers.push(`measure_compare_${node.comparison}_close`);
  return markers.map(marker=>grammarMarker(formal,node.node_id,marker));
}
function timeFrame(edge,nodes){
  const anchor=nodes.get(edge.from),clause=nodes.get(edge.to);
  if(anchor?.kind==='time_anchor'&&clause?.kind==='clause'){
    if(anchor.anchor_type==='speech_time'&&Object.keys(anchor).every(key=>['node_id','kind','anchor_type'].includes(key))&&['before','at','after'].includes(edge.relation))return `time_${edge.relation}_speech`;
    const days={'-1':'previous_day','0':'current_day','1':'next_day'};
    if(anchor.anchor_type==='interval'&&anchor.calendar_unit==='day'&&anchor.relative_to==='speech_date'&&typeof anchor.day_offset==='string'&&Object.hasOwn(days,anchor.day_offset)&&Object.keys(anchor).every(key=>['node_id','kind','anchor_type','calendar_unit','relative_to','day_offset'].includes(key))&&edge.relation==='during')return `time_${days[anchor.day_offset]}`;
  }
  throw new Error('Unsupported musical time relation or anchor.');
}
function validateTimeRelations(ir){
  const nodes=new Map(ir.nodes.map(node=>[node.node_id,node]));
  for(const edge of ir.edges.filter(edge=>edge.type==='time_relation'))timeFrame(edge,nodes);
}
function confidenceMarkers(formal,id,strength){
  if(strength===undefined)return [];
  return ['confidence_open',...Array.from(strength,char=>char==='.'?'decimal_point':`digit_${char}`),'confidence_close'].map(marker=>grammarMarker(formal,id,marker));
}
function grammarMarker(formal,scopeId,marker){
  const modal=marker.match(/^modality_(.+)_(open|close)$/);
  const distance=modal?MODAL_MODES.indexOf(modal[1])+2:0;
  let relative=modal?[0,modal[2]==='open'?-distance:distance,modal[2]==='open'?-distance:distance,0]:(marker==='negation_open'?[0,-1,-1,0]:[0,1,1,0]);
  if(marker==='confidence_open')relative=[0,9,0,9];
  else if(marker==='confidence_close')relative=[0,-9,0,-9];
  else if(marker==='decimal_point')relative=[0,10,-1,0];
  else if(/^digit_[0-9]$/.test(marker)){const digit=Number(marker.slice(-1));relative=[0,10,Math.floor(digit/4),digit%4,0]}
  const coordination=marker.match(/^coord_(all_of|any_of|exactly_one)_(open|close)$/);
  if(coordination){const code=['all_of','any_of','exactly_one'].indexOf(coordination[1])+1,sign=coordination[2]==='open'?-1:1;relative=[0,11*sign,code*sign,0]}
  else if(marker==='coord_member')relative=[0,11,0,11];
  const time=marker.match(/^time_(before|at|after)_speech_(open|close)$/);
  if(time){const code={before:-1,at:0,after:1}[time[1]],sign=time[2]==='open'?-1:1;relative=[0,12*sign,code,12*sign,0]}
  const day=marker.match(/^time_(previous_day|current_day|next_day)_(open|close)$/);
  if(day){const code={previous_day:-2,current_day:2,next_day:3}[day[1]],sign=day[2]==='open'?-1:1;relative=[0,12*sign,code,12*sign,0]}
  const property=marker.match(/^property_(mass|thermodynamic_temperature)_(equal|greater_than|less_than|at_least|at_most|not_equal)_(open|close)$/);
  if(property)relative=[0,property[3]==='open'?-18:18,({mass:1,thermodynamic_temperature:2})[property[1]],PROPERTY_COMPARISONS.indexOf(property[2]),0];
  const comparison=marker.match(/^measure_compare_(greater_than|less_than|at_least|at_most|not_equal)_(open|close)$/);
  if(comparison)relative=[0,comparison[2]==='open'?-17:17,MEASURE_COMPARISONS.indexOf(comparison[1])+1,0];
  if(marker==='measurement_open')relative=[0,-13,-1,0];
  if(marker==='measurement_close')relative=[0,13,1,0];
  if(marker==='measurement_negative')relative=[0,-13,0,-13];
  const unit=marker.match(/^measurement_unit_(\d+)$/);
  if(unit)relative=[0,13,Number(unit[1]),13,0];
  const quantifier=marker.match(/^quantifier_(exact|at_least|at_most|all|some|none)_(open|close)$/);
  if(quantifier)relative=[0,quantifier[2]==='open'?-14:14,QUANTIFIERS.indexOf(quantifier[1])+1,0];
  const role=marker.match(/^role_(.+)_(open|close)$/);
  if(role){
    const code=ROLE_ORDER.indexOf(role[1]);if(code<0)throw new Error('Unsupported musical role.');
    const digits=code.toString(3).padStart(3,'0').split('').map(trit=>[0,1,-1][Number(trit)]);
    relative=[0,role[2]==='open'?-15:15,...digits,0];
  }
  const reference=marker.match(/^role_reference_(.+)$/);
  if(reference){const code=ROLE_ORDER.indexOf(reference[1]);if(code<0)throw new Error('Unsupported musical role reference.');relative=[0,-20,...code.toString(3).padStart(3,'0').split('').map(d=>[0,1,-1][Number(d)]),0]}
  const conditional=marker.match(/^conditional_(open|satisfied|unsatisfied|counterfactual)_(open|close)$/);
  if(conditional)relative=[0,conditional[2]==='open'?-16:16,CONDITION_STATUSES.indexOf(conditional[1]),0];
  if(marker==='conditional_then')relative=[0,16,0,16];
  const base=formal.performance.anchor_midi;
  return {kind:'grammar_marker',grammar_profile:'EZGRAM-1',marker,occurrence_id:scopeId,target_id:`EZGRAM:${marker}`,register:'middle',base_midi:base,
    family_qualified_transliteration:marker,formal_carrier:'',family_opening_relative_semitones:[],family_opening_absolute_midi:[],
    address_relative_semitones:relative,address_absolute_midi:relative.map(note=>base+note),note_duration_beats:.25,boundary_after_beats:.5};
}

// A bound argument may itself contain bound arguments. Keep the outer frame
// open across its entire payload, opening/closing inner frames at path changes.
function frameBoundArguments(formal,maxEvents){
  const output=[];let previous=[];let occurrence=null;
  const key=b=>JSON.stringify([b.compound_occurrence_id,b.slot_path,b.argument_id,b.role,b.predicate_path]);
  const emit=(binding,side,id)=>output.push(grammarMarker(formal,id,`role_${binding.role}_${side}`));
  for(const event of formal.performance.lexical_events){
    const chain=event.binding_chain||[];
    if(!Array.isArray(chain)||chain.some(b=>!b||!ROLE_ORDER.includes(b.role)||!Array.isArray(b.slot_path)||!Array.isArray(b.predicate_path)))throw new Error('Unsupported musical compound binding chain.');
    let shared=0;
    if(occurrence===event.occurrence_id)while(shared<previous.length&&shared<chain.length&&key(previous[shared])===key(chain[shared]))shared++;
    for(let i=previous.length-1;i>=shared;i--)emit(previous[i],'close',occurrence);
    for(let i=shared;i<chain.length;i++)emit(chain[i],'open',event.occurrence_id);
    output.push(event);previous=chain;occurrence=event.occurrence_id;
    if(output.length>maxEvents)throw new Error(`Compound binding exceeds event limit ${maxEvents}.`);
  }
  for(let i=previous.length-1;i>=0;i--)emit(previous[i],'close',occurrence);
  if(output.length>maxEvents)throw new Error(`Compound binding exceeds event limit ${maxEvents}.`);
  return output;
}

function validatePropertyComparison(node,ir){
 const scopes=ir.edges.filter(e=>e.type==='scopes'&&e.to===node.node_id),predicate=scopes.length===1?ir.nodes.find(n=>n.node_id===scopes[0].from):null;
 const roles=predicate?ir.edges.filter(e=>e.type==='fills_role'&&e.to===predicate.node_id):[];
 if(!['mass','thermodynamic_temperature'].includes(node.dimension)||!PROPERTY_COMPARISONS.includes(node.relation)||Object.keys(node).some(k=>!['node_id','kind','operator','dimension','relation'].includes(k))||predicate?.kind!=='lexical_occurrence'||predicate?.target_type!=='atom'||!['MAT:000','MAT:010'].includes(predicate?.target_id)||roles.map(e=>e.role).sort().join(',')!=='bearer,comparison_standard'||!roles.every(e=>ir.nodes.some(n=>n.node_id===e.from&&['phonemic_reference','deictic_reference'].includes(n.kind)&&n.reference_mode!=='nominal_class')))throw new Error('Unsupported musical property comparison.');
}
