import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {conversationTargets} from '../pages/conversation_targets.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const source=JSON.parse(fs.readFileSync(path.join(root,'examples/lore_conversation_presets.json'),'utf8'));
const data=JSON.parse(fs.readFileSync(path.join(root,'pages/data/index.json'),'utf8'));
const html=fs.readFileSync(path.join(root,'pages/index.html'),'utf8');
const app=fs.readFileSync(path.join(root,'pages/app.js'),'utf8');
const checks=[];
const check=(name,ok,detail='')=>checks.push({name,ok:Boolean(ok),detail});

check('presentation-only format',source.format==='EZ-LORE-CONVERSATIONS-1'&&source.status==='presentation_only_noncanonical'&&source.semantic_authority_changes===0);
check('five literature moments',source.presets.length===5&&new Set(source.presets.map(item=>item.story)).size===5);
check('expected story keys',JSON.stringify(source.presets.map(item=>item.key))===JSON.stringify(['FEAST-CARRY','CURRENT-LISTEN','ROOMS-BESIDE','ARRIVAL-ASK','TWO-DROPS-WAIT']));
const allKeys=source.presets.flatMap(item=>[item.key,...item.aliases]);
check('unique input keys and aliases',new Set(allKeys).size===allKeys.length&&allKeys.every(key=>/^[A-Z0-9-]+$/.test(key)));

let turns=0,playableConcepts=0;
for(const preset of source.presets){
  const speakers=[...new Set(preset.performance_turns.map(turn=>turn.speaker))];
  check(`${preset.key} complete context`,Boolean(preset.title&&preset.explanation&&preset.performance_note&&preset.source_path&&preset.source_section&&preset.source_excerpt.length>=2));
  check(`${preset.key} two-speaker exchange`,speakers.length===2&&preset.performance_turns.length>=4&&preset.performance_turns.every((turn,index)=>index===0||turn.speaker!==preset.performance_turns[index-1].speaker));
  for(const [index,turn] of preset.performance_turns.entries()){
    turns++;
    const {targets,warnings,curated}=conversationTargets(turn.english,data,{turn,speaker:turn.speaker});
    playableConcepts+=targets.length;
    check(`${preset.key} turn ${index+1} playable`,targets.length>0&&targets.every(target=>data.resolution_files[target.target_id]),`${turn.speaker}: ${turn.english}`);
    if(turn.motif){
      check(`${preset.key} turn ${index+1} scored excerpt and limits`,curated&&targets[0].target_id===turn.motif.target_id&&warnings.includes(turn.motif.limitation));
      check(`${preset.key} turn ${index+1} edited text requires a fresh reading`,!conversationTargets(turn.english+' Later.',data,{turn,speaker:turn.speaker}).curated&&!conversationTargets(turn.english,data,{turn,speaker:'Other'}).curated);
    }else{
      check(`${preset.key} turn ${index+1} honest predicates`,!warnings.some(warning=>warning.includes('unresolved semantic')),`${turn.speaker}: ${turn.english}`);
    }
  }
}

check('lore records embedded in browser data',data.lore_conversations?.format===source.format&&JSON.stringify(data.lore_conversations.presets)===JSON.stringify(source.presets));
check('keyed lore interface present',html.includes('id="lorePresetSelect"')&&html.includes('id="lorePresetKey"')&&html.includes('id="loadLorePreset"')&&html.includes('id="lorePresetDetail"'));
check('key resolution and arbitrary speaker labels present',app.includes('function lorePresetByKey')&&app.includes('function loadLorePreset')&&app.includes('displaySpeaker')&&app.includes('no more than two speakers'));

const failed=checks.filter(item=>!item.ok),passed=checks.length-failed.length;
const lines=['# Lore Conversation Preset Validation','',`Status: **${failed.length?'FAIL':'PASS'}**`,'',`- Checks passed: **${passed}**`,`- Checks failed: **${failed.length}**`,`- Presets: **${source.presets.length}**`,`- Performance turns: **${turns}**`,`- Hosted canonical concept performances found: **${playableConcepts}**`,'','## Checks','',...checks.map(item=>`- ${item.ok?'PASS':'FAIL'} — ${item.name}${item.detail?` — ${item.detail}`:''}`),''];
fs.writeFileSync(path.join(root,'reports/lore_conversation_validation.md'),lines.join('\n'));
console.log(`Lore conversation validation: ${failed.length?'FAIL':'PASS'} · ${passed} passed · ${failed.length} failed · ${source.presets.length} presets · ${turns} turns`);
if(failed.length){failed.forEach(item=>console.error(`FAIL: ${item.name} — ${item.detail}`));process.exit(1)}
