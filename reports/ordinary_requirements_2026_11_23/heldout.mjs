import fs from 'node:fs';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const base=process.argv[2],{storyReading}=await import(pathToFileURL(base+'/pages/story_readings.mjs')),{scoreStory,decodeStoryMidi}=await import(pathToFileURL(base+'/pages/story_music.mjs')),{compactChordMidi,expandChordMidi}=await import(pathToFileURL(base+'/pages/compact_chords.mjs'));
const a=JSON.parse(fs.readFileSync(base+'/pages/data/index.json'));
const save='CMP:58cfa479709294b9809be1b7',copy='CMP:9ea919967152aa85bc1c7169',O='modality_obligated',N='negation';
const cases=[
 {text:'Nora must not put the box at the gate. [2]',p:'CMP:64574c1a25d72a89aafc46ef',roles:['actor','target','destination'],scopes:[O,N],state:2},
 {text:'We do not have to copy the record. [0]',p:copy,scopes:[N,O],state:0},
 {text:'The routines have to save the records.',p:save,scopes:[O],plural:[0,1]},
 {text:'Tomorrow, Nora will have to keep the file stored.',p:'CMP:cac584a394535e4912c75b5a',roles:['cause','bearer'],scopes:['time_after_speech',O,'time_next_day'],answers:{timeScope0:'event'},condition:'DAT:000'},
 {text:'No worker must not save the file.',p:save,scopes:[O,N],q:'none'},
 {text:'Does every program have to store the file?',p:save,scopes:[O],q:'all',act:'question'},
 {text:'Nora must lower the box.',p:'CMP:92464b1ea3c632b343340a05',roles:['actor','target'],scopes:[O]},
 {text:'The record must be stored. Nora does not need to save it.',p:'DAT:000',roles:['bearer'],scopes:[O],next:{predicate:save,scopes:[N,'modality_necessary'],entities:[1,0]}}
];
const report={revision:'c5cfd46d4522d5cb1a7e51141307c3ee93431a08',note:'Eight combinations selected after implementation; independently specified expectations, not a representative language benchmark.',cases:[]};
for(const c of cases){try{
 const plan=storyReading(c.text,a,{answers:{requirement0:'obligated',...c.answers}});assert(plan?.events,JSON.stringify(plan));
 const {midi}=await scoreStory(plan,a),m=decodeStoryMidi(midi,a.atoms),e=m.events[0],roles=c.roles||['actor','target'];
 assert.equal(e.predicate,c.p);assert.deepEqual(e.scopes,c.scopes);assert.deepEqual(e.arguments.map(v=>v.role),roles);assert.deepEqual(e.arguments.map(v=>v.entity),roles.map((_,i)=>i));
 assert.equal(m.runtime_state,c.state??1);assert.equal(m.speech_act,c.act||'assertion');assert.equal(e.quantifier,c.q||null);assert.equal(e.negated_quantifier,false);assert.deepEqual(e.condition,c.condition);
 for(const i of c.plural||[])assert(m.entities[i].plural);
 if(c.next){assert.equal(m.events[1].predicate,c.next.predicate);assert.deepEqual(m.events[1].scopes,c.next.scopes);assert.deepEqual(m.events[1].arguments.map(a=>a.entity),c.next.entities);}
 assert.deepEqual(decodeStoryMidi(expandChordMidi(compactChordMidi(midi,a.atoms),a.atoms),a.atoms),m);
 report.cases.push({text:c.text,status:'pass',meaning:m});
}catch(e){report.cases.push({text:c.text,status:'fail',error:e.stack});}}
report.passed=report.cases.every(c=>c.status==='pass');fs.writeFileSync('/tmp/dba-requirement-heldout-1123.json',JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({passed:report.passed,cases:report.cases.map(c=>({text:c.text,status:c.status,error:c.error}))}));if(!report.passed)process.exitCode=1;
