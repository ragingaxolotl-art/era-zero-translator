// Follow-up probes derived from audit-16; these are not held-out cases.
import fs from 'node:fs';
import {storyReading} from '../pages/story_readings.mjs';
import {scoreStory,decodeStoryMidi} from '../pages/story_music.mjs';
const a=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url)));
const rows=[];
for(const linked of [false,true])for(const predicate of ['leave','wait','lift the box'])for(const modal of ['will','can','will not','cannot']){
 const text=(linked?'If Nora opens the hatch, Mira ':'Nora ')+modal+' '+predicate+'.',plan=storyReading(text,a);
 if(!plan?.events){rows.push({text,status:plan?.question?'clarification':'not_composed'});continue;}
 const {midi}=await scoreStory(plan,a),heard=decodeStoryMidi(midi,a.atoms);
 const expected=modal.startsWith('will')?'time_after_speech':'ability';
 const scopes=heard.events.at(-1).scopes;
 rows.push({text,expected_outer_scope:expected,recovered_scopes:scopes,
  preserves_outer_scope:scopes.includes(expected),preserves_negation:scopes.includes('negation')===/not/.test(modal)});
}
fs.writeFileSync(new URL('../reports/full_audit_2026_11_22/scope_followup.json',import.meta.url),JSON.stringify({method:'Directed follow-up, source text goes only to composer; score-only inverse yields the checked scope. These examples are additional to the 58-case denominator.',results:rows},null,2)+'\n');
console.log(JSON.stringify(rows));
