import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {analyzeEnglish} from '../pages/english.mjs';
import {VOICE_PROFILES} from '../pages/voices.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const script=JSON.parse(fs.readFileSync(path.join(root,'examples/two_beings_conversation.json'),'utf8'));
const data=JSON.parse(fs.readFileSync(path.join(root,'pages/data/index.json'),'utf8'));
const html=fs.readFileSync(path.join(root,'pages/index.html'),'utf8');
const app=fs.readFileSync(path.join(root,'pages/app.js'),'utf8');
const mp3=fs.readFileSync(path.join(root,'pages/media/two-beings-file-migration.mp3'));
const checks=[];
const check=(name,ok,detail='')=>checks.push({name,ok:Boolean(ok),detail});

check('conversation format',script.format==='EZ-CONVERSATION-1');
check('six alternating turns',script.turns.length===6&&script.turns.every((turn,index)=>turn.speaker===(index%2===0?'Oca':'Orin')));
check('speaker timbres',script.speakers.Oca.voice==='ocarina'&&script.speakers.Orin.voice==='warm_organ'&&VOICE_PROFILES.ocarina&&VOICE_PROFILES.warm_organ);
check('stereo separation',script.speakers.Oca.pan<0&&script.speakers.Orin.pan>0);
check('all scripted targets hosted',script.turns.flatMap(turn=>turn.targets).every(target=>data.resolution_files[target]));
for(const [index,turn] of script.turns.entries()){
  const result=analyzeEnglish(turn.english,data);
  const inferred=result.term_coverage.filter(item=>item.status==='canonical').map(item=>item.matches.find(match=>['atom','compound'].includes(match.route)&&match.target_id&&data.resolution_files[match.target_id])?.target_id).filter(Boolean);
  check(`turn ${index+1} semantic sequence`,JSON.stringify(inferred)===JSON.stringify(turn.targets),`${turn.speaker}: ${inferred.join(' · ')}`);
}
check('MP3 has ID3 or MPEG header',mp3.length>500000&&(mp3.subarray(0,3).toString()==='ID3'||(mp3[0]===0xff&&(mp3[1]&0xe0)===0xe0)),`${mp3.length} bytes`);
check('conversation tab and player present',html.includes('data-app-tab="conversation"')&&html.includes('id="conversationScript"')&&html.includes('two-beings-file-migration.mp3'));
check('editable translator and alternating playback present',app.includes('parseConversation')&&app.includes('conversationTargets')&&app.includes('playConversation')&&app.includes("voice:'ocarina'")&&app.includes("voice:'warm_organ'"));

const failed=checks.filter(item=>!item.ok),passed=checks.length-failed.length;
const lines=['# Two-Beings Conversation Validation','',`Status: **${failed.length?'FAIL':'PASS'}**`,'',`- Checks passed: **${passed}**`,`- Checks failed: **${failed.length}**`,`- Turns: **${script.turns.length}**`,`- MP3 bytes: **${mp3.length}**`,'','## Checks','',...checks.map(item=>`- ${item.ok?'PASS':'FAIL'} — ${item.name}${item.detail?` — ${item.detail}`:''}`),''];
fs.writeFileSync(path.join(root,'reports/conversation_validation.md'),lines.join('\n'));
console.log(`Conversation validation: ${failed.length?'FAIL':'PASS'} · ${passed} passed · ${failed.length} failed · ${script.turns.length} turns`);
if(failed.length){failed.forEach(item=>console.error(`FAIL: ${item.name} — ${item.detail}`));process.exit(1)}
