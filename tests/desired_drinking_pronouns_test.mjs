import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeDesiredDrinking,desiredDrinkingPronounPlan} from '../pages/desired_drinking.mjs';
import {midiFromDesiredDrinking} from '../pages/desired_drinking_music.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),options={allowDraft:true,interpretation:'literal_drinking',materialReading:'contextual_portion',viewpoint:'bounded'};
for(const [text,named,bindings] of [
 ['They want to drink it.','Nora wants to drink this tea.',{ref0:{referent:'Nora',number:'singular'},ref1:'this tea'}],
 ['Do they not want him to drink it?','Does Nora not want Eli to drink this tea?',{ref0:{referent:'Nora',number:'singular'},ref1:'Eli',ref2:'this tea'}],
 ['She wants them to not drink it.','Nora wants Eli to not drink this tea.',{ref0:'Nora',ref1:{referent:'Eli',number:'singular'},ref2:'this tea'}]
])for(const runtime of [0,1,2]){
 const input=text+` [${runtime}]`;assert(desiredDrinkingPronounPlan(input));const d=await composeDesiredDrinking(input,{...options,bindings}),e=await composeDesiredDrinking(named+` [${runtime}]`,options);assert.deepEqual(d,e);assert.deepEqual(await midiFromDesiredDrinking(d,authority,{allowDraft:true}),await midiFromDesiredDrinking(e,authority,{allowDraft:true}));
 await assert.rejects(composeDesiredDrinking(input,options),/Identify/);
}
await assert.rejects(composeDesiredDrinking('They want to drink it.',{...options,bindings:{ref0:{referent:'Nora',number:'plural'},ref1:'this tea'}}),/Group/);
console.log('PASS nine desired-drinking pronoun cases preserve subject control and distinct participants without gender assumptions; unbound/plural references reject.');
