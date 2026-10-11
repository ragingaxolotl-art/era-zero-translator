#!/usr/bin/env node
import fs from'node:fs/promises';
import path from'node:path';
import{fileURLToPath}from'node:url';
import{analyzeEnglish}from'../pages/english.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const read=async relative=>JSON.parse(await fs.readFile(path.join(root,relative),'utf8'));
const data=await read('pages/data/index.json'),curated=await read('tests/ordinary_language_coverage.json'),game=await read('tests/game_story_translation_cases.json'),lore=await read('examples/lore_conversation_presets.json');
const cases=[...curated.cases.map(test=>({...test,source:'curated'})),...game.cases.map(test=>({...test,expected_terms:test.statuses,source:'game_story'})),...lore.presets.flatMap(preset=>preset.performance_turns.map(turn=>({domain:'lore',phrase:turn.english,source:preset.key})))];
const failures=[],rows=[],termTally=new Map(),domainCounts=new Map();
for(const test of cases){
  const result=analyzeEnglish(test.phrase,data),top=result.candidates[0],terms=result.term_coverage||[];
  const target=top?.target_id||null,route=top?.route||null,checks=[];
  if(test.target)checks.push([target===test.target,`expected ${test.target}; got ${target||route||'none'}`]);
  if(test.route)checks.push([route===test.route,`expected ${test.route}; got ${route||'none'}`]);
  if(test.sense_key)checks.push([top?.sense_key===test.sense_key,`expected sense ${test.sense_key}; got ${top?.sense_key||'none'}`]);
  if(test.must_not_auto)checks.push([!result.decision.auto_resolution_allowed,'unsafe automatic resolution']);
  for(const[word,status]of Object.entries(test.expected_terms||{}))checks.push([terms.some(item=>item.term===word&&item.status===status),`${word} must be ${status}; got ${terms.find(item=>item.term===word)?.status||'absent'}`]);
  const failuresHere=checks.filter(([ok])=>!ok).map(([,message])=>message);
  if(failuresHere.length)failures.push(`${test.source}: ${test.phrase} — ${failuresHere.join('; ')}`);
  for(const term of terms){
    const key=`${term.term}|${term.status}|${term.semantic_kind||''}`;
    termTally.set(key,(termTally.get(key)||0)+1);
  }
  const domain=test.domain||'game_story',stats=domainCounts.get(domain)||{phrases:0,auto:0,gap:0,unresolved:0,structural:0};
  stats.phrases++;if(result.decision.auto_resolution_allowed)stats.auto++;
  if(terms.some(x=>x.status==='documented_gap'))stats.gap++;
  if(terms.some(x=>x.status==='unresolved_semantic'))stats.unresolved++;
  if(terms.some(x=>x.status==='structural'))stats.structural++;
  domainCounts.set(domain,stats);
  rows.push({test,result,top,terms,failuresHere});
}
const lexical=data.lexical_pos_audit;
if(lexical.roots.length!==324||lexical.senses.length!==data.senses.length+data.game_story_senses.length)failures.push('Root/POS audit does not match browser senses.');
if(rows.some(row=>row.terms.some(item=>item.status==='phonemic_label'&&item.semantic_kind)))failures.push('A known semantic verb/descriptor was replaced with a phonemic label.');
const unresolved=[...termTally].filter(([key])=>key.includes('|unresolved_semantic|')).sort((a,b)=>b[1]-a[1]);
const gaps=[...termTally].filter(([key])=>key.includes('|documented_gap|')).sort((a,b)=>b[1]-a[1]);
const status=failures.length?'FAIL':'PASS';
const escape=value=>String(value??'').replaceAll('|','\\|').replaceAll('\n',' ');
const lines=['# Ordinary-language, story, and game corpus audit','',`Status: **${status}**`,'',`- Curated new phrases: **${curated.cases.length}**`,`- Existing game/story phrases: **${game.cases.length}**`,`- Lore performance turns: **${lore.presets.reduce((n,p)=>n+p.performance_turns.length,0)}**`,`- Total audited phrases: **${rows.length}**`,`- Canonical roots / indexed and profile senses: **${lexical.roots.length} / ${lexical.senses.length}**`,`- Automatic single-target readings: **${rows.filter(row=>row.result.decision.auto_resolution_allowed).length}** (not full sentence translations)`,`- Phrases with documented gaps: **${rows.filter(row=>row.terms.some(t=>t.status==='documented_gap')).length}**`,`- Phrases with unresolved predicates/descriptors: **${rows.filter(row=>row.terms.some(t=>t.status==='unresolved_semantic')).length}**`,`- Assertion failures: **${failures.length}**`,'','## What this audit proves','','It checks conservative lexical routing and word-level classifications over three independent in-repository corpora. A candidate root is a semantic center, not a complete translation of participants, tense, object roles, or clauses. An automatic single-target reading may omit unsupported detail. Gaps and structural routes are expected, not hidden. The site must show these limitations.','','## Domain coverage','','| Domain | Phrases | Auto single-target | With gap | With unresolved semantic word | With structural word |','|---|---:|---:|---:|---:|---:|'];
for(const[domain,stats]of [...domainCounts].sort((a,b)=>a[0].localeCompare(b[0])))lines.push(`| ${domain} | ${stats.phrases} | ${stats.auto} | ${stats.gap} | ${stats.unresolved} | ${stats.structural} |`);
lines.push('','## High-priority unrepresented actions and descriptors','','These require either a defensible reviewed surface route to an existing meaning, a compound/IR design, or an explicit future vocabulary decision. They are not silently given new roots.','','| Term | Corpus mentions | Classification |','|---|---:|---|');
for(const[key,count]of unresolved){const[word,,kind]=key.split('|');lines.push(`| ${escape(word)} | ${count} | ${kind||'semantic content'} |`)}
lines.push('','## Documented vocabulary gaps','','| Term | Corpus mentions |','|---|---:|');
for(const[key,count]of gaps){const[word]=key.split('|');lines.push(`| ${escape(word)} | ${count} |`)}
lines.push('','## Phrase-by-phrase results','','| Source / domain | English phrase | Primary route | Auto | Non-function word routes | Result |','|---|---|---|---:|---|---|');
for(const row of rows)lines.push(`| ${escape(row.test.source)} / ${escape(row.test.domain||'game_story')} | ${escape(row.test.phrase)} | ${escape(row.top?.target_id||row.top?.sense_key||'none')} | ${row.result.decision.auto_resolution_allowed?'yes':'no'} | ${escape(row.terms.filter(t=>!['function_word','participant_reference'].includes(t.status)).map(t=>`${t.term}:${t.status}`).join(', '))} | ${row.failuresHere.length?'FAIL':'PASS'} |`);
lines.push('','## Review decisions','','- Preserve all 324 canonical root meanings and all 28 approved compounds. No automatic vocabulary expansion follows from corpus frequency alone.','- Keep affect, desire, ingestion, game measurements, and safety as documented gaps pending semantic design.','- Treat data deletion, waiting, crossing, return, and program execution as structural/IR routes until complete templates and role binding exist.','- Treat `pick up`, `back up`, file opening/saving/copying, and other unrepresented predicates as semantic gaps, never phonemic nouns.','- Block automatic interpretation of underspecified file change/movement across Matter, Data, Motion, and Structure; ask for context.','- User-reviewed local surface mappings can improve recognition but remain noncanonical and need explicit entailment and collision review.','','## Failures','');
lines.push(...(failures.length?failures.map(f=>`- ${f}`):['None.']));
await fs.writeFile(path.join(root,'reports/ordinary_language_coverage_audit.md'),`${lines.join('\n')}\n`);
console.log(`Ordinary-language corpus: ${status} · ${rows.length} phrases · ${failures.length} failures`);
if(failures.length){console.error(failures.slice(0,30).join('\n'));process.exit(1)}
