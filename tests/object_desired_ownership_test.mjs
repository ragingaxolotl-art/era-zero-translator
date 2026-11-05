import assert from 'node:assert/strict';
import fs from 'node:fs';
import {composeObjectDesiredOwnership} from '../pages/object_desired_ownership.mjs';
import {midiFromDesiredOwnership,decodeDesiredOwnershipMidi} from '../pages/desired_ownership_music.mjs';
const authority=JSON.parse(fs.readFileSync(new URL('../pages/data/index.json',import.meta.url))),options={allowDraft:true,framework:'"Harbor charter"'};
for(const outer of [0,1,2])for(const inner of [0,1,2]){
 const source=`Does Nora not want that tea? [${outer}]`,outcome=`Eli does not own that tea [${inner}].`,d=await composeObjectDesiredOwnership(source,authority,{...options,desiredProposition:outcome}),r=decodeDesiredOwnershipMidi(await midiFromDesiredOwnership(d.meaning,authority,{allowDraft:true}),authority.atoms,{allowDraft:true});
 assert.equal(d.source_input,source);assert.equal(d.object_desire_resolution.relation_source,'explicit_user_clarification');assert.equal(r.runtime_state,outer);assert.equal(r.content.runtime_state,inner);assert.equal(r.speech_act,'question');assert.deepEqual(r.scopes,[{operator:'negation'}]);assert.deepEqual(r.content.scopes,[{operator:'negation'}]);assert.equal(r.content.object.reference_mode,'distal_nominal');assert.notDeepEqual(r.holder,r.content.owner);assert.equal(r.content_status,'intensional');
}
for(const outcome of ['Eli owns this tea.','Eli owns Tea.','Eli owns that water.'])await assert.rejects(composeObjectDesiredOwnership('Nora wants that tea.',authority,{...options,desiredProposition:outcome}),/original object/);
await assert.rejects(composeObjectDesiredOwnership('Nora wants tea.',authority,{...options,desiredProposition:'Eli owns Tea.'}),/original object/);
await assert.rejects(composeObjectDesiredOwnership('Nora wants tea.',authority,{allowDraft:true,desiredProposition:'Eli owns the tea.'}),/framework explicitly/);
await assert.rejects(composeObjectDesiredOwnership('Nora wants tea.',authority,options),/Specify/);
const bare=await composeObjectDesiredOwnership('Nora wants tea.',authority,{...options,desiredProposition:'Eli owns the tea.'});assert.equal(bare.meaning.content.object.reference_mode,'definite_nominal');
const named=await composeObjectDesiredOwnership('Nora wants Tea.',authority,{...options,desiredProposition:'Eli owns Tea.'});assert.equal(named.meaning.content.object.reference_mode,undefined);
console.log('PASS nine object-desire ownership musical scope/runtime pairs; original nominal/name identity, explicit framework and outcome selection enforced.');
