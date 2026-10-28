import fs from 'node:fs';
import {createHash} from 'node:crypto';
import {parseSentenceConditional,composeSentenceConditional,parseNamedSentence,composeNamedSentence,parseSentenceSequence,composeSentenceSequence,parseSentenceConjunction,composeSentenceConjunction} from '../pages/sentences.mjs';
import {midiFromFormal} from '../pages/engine.mjs';
const root=new URL('..',import.meta.url);
const read=path=>JSON.parse(fs.readFileSync(new URL(path,root)));
const corpus=read('tests/ordinary_phrase_audit.json'),data=read('pages/data/index.json');
const load=async target=>read(`pages/${data.resolution_files[target]}`).variants['assertion:1'];
const equal=(a,b)=>JSON.stringify([...a].sort())===JSON.stringify([...b].sort());
const results=[];
for(const item of corpus.cases){
 let result=null,error=null;
 try{
  if(parseSentenceConditional(item.input))result=await composeSentenceConditional(item.input,load);
  else if(parseNamedSentence(item.input))result=await composeNamedSentence(item.input,await load(parseNamedSentence(item.input).predicate));
  else if(parseSentenceSequence(item.input))result=await composeSentenceSequence(item.input,load);
  else if(parseSentenceConjunction(item.input))result=await composeSentenceConjunction(item.input,load);
 }catch(caught){error=String(caught)}
 const failures=[];
 if(result&&item.expected){
  const ir=result.semantic_ir,actual={
   speech_acts:[ir.speech_act],
   condition_statuses:ir.edges.filter(e=>e.type==='condition_of').map(e=>e.condition_status),
   role_labels:ir.edges.filter(e=>e.type==='fills_role').map(e=>`${e.role}:${ir.nodes.find(n=>n.node_id===e.from)?.name?.normalized_label||''}`),
   reference_modes:ir.nodes.filter(n=>n.reference_mode).map(n=>n.reference_mode),
   calendar_days:ir.nodes.filter(n=>n.kind==='time_anchor').map(n=>[n.anchor_type,n.calendar_unit,n.relative_to,n.day_offset].join(':')),
   time_relations:ir.edges.filter(e=>e.type==='time_relation').map(e=>e.relation),
   deictic_roles:ir.nodes.filter(n=>n.kind==='deictic_reference').map(n=>n.deictic_role),
   targets:ir.nodes.filter(n=>n.kind==='lexical_occurrence').map(n=>n.target_id),
   roles:ir.edges.filter(e=>e.type==='fills_role').map(e=>e.role),
   labels:ir.nodes.filter(n=>n.kind==='phonemic_reference').map(n=>n.name.normalized_label),
   operators:ir.nodes.filter(n=>n.operator).map(n=>n.operator),
   strengths:ir.nodes.filter(n=>n.strength!==undefined).map(n=>n.strength)
  };
  for(const [key,expected] of Object.entries(item.expected))if(!equal(actual[key]||[],expected))failures.push(key);
  if(ir.speech_act!==(item.expected.speech_acts?.[0]||'assertion'))failures.push('speech_act');
  if(ir.nodes.some(n=>n.kind==='lexical_occurrence'&&n.runtime_state.code!==1))failures.push('runtime');
  if(item.id==='conditional'){
   const edge=ir.edges.find(e=>e.type==='condition_of');
   const center=id=>ir.edges.find(e=>e.type==='centers'&&e.to===id)?.from;
   const target=id=>ir.nodes.find(n=>n.node_id===id)?.target_id;
   if(!edge||target(center(edge.from))!=='WRN:001'||target(center(edge.to))!=='REP:111')failures.push('conditional_direction');
   const reference=role=>ir.nodes.find(n=>n.node_id===ir.edges.find(e=>e.type==='fills_role'&&e.role===role)?.from)?.referent_id;
   if(!reference('bearer')||reference('bearer')!==reference('target'))failures.push('conditional_coreference');
  }
  if(item.id==='modal_negation'){
   const center=ir.edges.find(e=>e.type==='centers'&&e.to===ir.root_clause).from;
   const outer=ir.nodes.find(n=>n.node_id===center),inside=ir.edges.find(e=>e.type==='scopes'&&e.to===center)?.from;
   if(outer.operator!=='modality'||ir.nodes.find(n=>n.node_id===inside)?.operator!=='negation')failures.push('scope_order');
  }
 }
 results.push({...item,status:error?'error':!result?'not_composed':!item.expected?'composed_needs_semantic_review':failures.length?'semantic_check_failed':'verified_for_declared_checks',failures,...(error?{error}:{}),...(result?{midi_sha256:createHash('sha256').update(midiFromFormal(result.formal)).digest('hex')}: {})});
}
const counts={};for(const result of results)counts[result.status]=(counts[result.status]||0)+1;
const areas={};for(const result of results){const area=areas[result.area]??={total:0,verified:0};area.total++;if(result.status==='verified_for_declared_checks')area.verified++}
const report={scope:corpus.purpose,completion_proven:false,case_count:results.length,counts,areas,results};
fs.writeFileSync(new URL('reports/ordinary_phrase_coverage.json',root),JSON.stringify(report,null,2)+'\n');
fs.writeFileSync(new URL('reports/ordinary_phrase_coverage.md',root),`# Ordinary phrase coverage audit\n\n${corpus.purpose}\n\nFull translator completion: **not established**. ${counts.verified_for_declared_checks||0} of ${results.length} cases pass their declared semantic checks; ${counts.not_composed||0} have no complete composition. These counts do not estimate coverage of English generally.\n\n| Area | Checked compositions | Cases |\n|---|---:|---:|\n${Object.entries(areas).map(([name,area])=>`| ${name} | ${area.verified} | ${area.total} |`).join('\n')}\n\n## Unfinished cases\n\n${results.filter(r=>r.status!=='verified_for_declared_checks').map(r=>`- **${r.input}** — ${r.requirements.join('; ')} (${r.status})`).join('\n')}\n`);
console.log(JSON.stringify({case_count:results.length,counts,completion_proven:false}));
if(results.some(r=>r.status==='error'||r.status==='semantic_check_failed'))process.exitCode=1;
