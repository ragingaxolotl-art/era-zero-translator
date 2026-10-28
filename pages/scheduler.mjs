// Counted-scope scheduling shared by browser sound, notation and MIDI export.
export function scheduledLexicalEvents(formal, maxEvents = 100000) {
  const events = formal.performance.lexical_events;
  const ir = formal.semantic_ir;
  if (!ir.nodes.some(node => ['repetition','sequence','negation'].includes(node.operator))) return events;
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
      if (node.operator !== 'negation' && (node.operator !== 'repetition' || node.mode !== 'count' || !Number.isSafeInteger(node.count) || node.count < 1))
        throw new Error('Counted repetition requires a positive count and supported nested scopes.');
      const scoped = edges.filter(edge => edge.type === 'scopes');
      if (scoped.length !== 1) throw new Error('Repetition must have exactly one scope.');
      const phrase = walk(scoped[0].from);
      if (!phrase.length) throw new Error('Repetition scope has no sound events.');
      if(node.operator==='negation')result=[grammarMarker(formal,id,'negation_open'),...phrase,grammarMarker(formal,id,'negation_close')];
      else{
        if (phrase.length * node.count > maxEvents) throw new Error(`Repetition exceeds event limit ${maxEvents}.`);
        result = [];
        for (let i = 0; i < node.count; i++) result.push(...phrase);
      }
    } else if (node.kind === 'clause') {
      const centers = edges.filter(edge => edge.type === 'centers');
      if (centers.length !== 1) throw new Error('Repetition clause requires one center.');
      result = walk(centers[0].from);
    } else if (node.kind === 'coordination') {
      if (node.operator !== 'sequence') throw new Error('Repeated parallel or alternative coordination requires a voice scheduler.');
      const members = edges.filter(edge => edge.type === 'member_of');
      if (members.some(edge => !Number.isSafeInteger(edge.order)) || new Set(members.map(edge => edge.order)).size !== members.length)
        throw new Error('Repeated sequence requires distinct explicit member order.');
      result = members.sort((a,b) => a.order-b.order).flatMap((edge,index) => {const phrase=walk(edge.from);if(index<members.length-1&&phrase.length)phrase[phrase.length-1]={...phrase.at(-1),boundary_after_beats:1};return phrase;});
    } else if (['lexical_occurrence','phonemic_reference'].includes(node.kind)) {
      result = edges.filter(edge => ['fills_role','qualifies'].includes(edge.type))
        .sort((a,b) => a.edge_id < b.edge_id ? -1 : a.edge_id > b.edge_id ? 1 : 0)
        .flatMap(edge => walk(edge.from)).concat(events.filter(event => event.occurrence_id === id));
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

function grammarMarker(formal,scopeId,marker){
  const relative=marker==='negation_open'?[0,-1,-1,0]:[0,1,1,0],base=formal.performance.anchor_midi;
  return {kind:'grammar_marker',grammar_profile:'EZGRAM-1',marker,occurrence_id:scopeId,target_id:`EZGRAM:${marker}`,register:'middle',base_midi:base,
    family_qualified_transliteration:marker,formal_carrier:'',family_opening_relative_semitones:[],family_opening_absolute_midi:[],
    address_relative_semitones:relative,address_absolute_midi:relative.map(note=>base+note),note_duration_beats:.25,boundary_after_beats:.5};
}
