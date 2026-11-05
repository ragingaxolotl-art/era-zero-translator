import assert from 'node:assert/strict';
import {availabilityPlan,composeAvailabilitySentence} from '../pages/availability_sentences.mjs';
import {createCustodyOpportunity} from '../pages/custody_opportunity.mjs';
import {contextualContentReference} from '../pages/contextual_content.mjs';
const options={allowDraft:true,interpretation:'practical_custody_opportunity',accessContext:'"Pantry access"'},holder=await contextualContentReference('Nora'),resource=await contextualContentReference('this tea'),context=await contextualContentReference(options.accessContext);
for(const state of [0,1,2])for(const [phrase,past,negative,question] of [
 ['This tea is available to Nora.',false,false,false],['This tea is not available to Nora.',false,true,false],['This tea was available to Nora.',true,false,false],["This tea wasn't available to Nora.",true,true,false],['Is this tea available to Nora?',false,false,true],["Wasn't this tea available to Nora?",true,true,true]
]){
 const actual=await composeAvailabilitySentence(phrase+` [${state}]`,options),expected=await createCustodyOpportunity(holder,resource,context,{allowDraft:true,runtimeState:state,speechAct:question?'question':'assertion',scopes:[...(past?[{operator:'time',relation:'before_speech'}]:[]),...(negative?[{operator:'negation'}]:[])]});assert.deepEqual(actual,expected);
}
const explicit=await composeAvailabilitySentence('This tea is available to Nora.',options);assert.deepEqual(await composeAvailabilitySentence('This tea is available.',{...options,prospectiveHolder:'Nora'}),explicit);
assert.deepEqual(await composeAvailabilitySentence('It is available to them.',{...options,bindings:{ref0:'this tea',ref1:{referent:'Nora',number:'singular'}}}),explicit);
await assert.rejects(composeAvailabilitySentence('This tea is available.',options),/who has/);
await assert.rejects(composeAvailabilitySentence('This tea is available to Nora.',{...options,prospectiveHolder:'Eli'}),/already specifies/);
await assert.rejects(composeAvailabilitySentence('This tea is available to Nora.',{...options,interpretation:undefined}),/Select/);
await assert.rejects(composeAvailabilitySentence('This tea is available to Nora.',{...options,accessContext:undefined}),/context explicitly/);
for(const phrase of ['This tea is available for sale.','Nora is available tomorrow.','This tea is available for Nora to drink.','This tea are available to Nora.'])assert.equal(availabilityPlan(phrase),null);
console.log('PASS 18 full availability meaning comparisons plus explicit missing-holder and neutral-reference resolution; reading/context conflicts reject. No musical availability coverage claimed.');
