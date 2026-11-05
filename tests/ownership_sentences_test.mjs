import assert from 'node:assert/strict';
import {composeOwnershipSentence,ownershipPlan} from '../pages/ownership_sentences.mjs';
import {createOwnershipMeaning} from '../pages/ownership_meaning.mjs';
import {contextualContentReference} from '../pages/contextual_content.mjs';
const options={allowDraft:true,framework:'"Harbor charter"'},owner=await contextualContentReference('Nora'),object=await contextualContentReference('this tea'),framework=await contextualContentReference(options.framework);
for(const state of [0,1,2])for(const [text,past,negative,question] of [
 ['Nora owns this tea.',false,false,false],['Nora does not own this tea.',false,true,false],['Nora owned this tea.',true,false,false],["Nora didn’t own this tea.",true,true,false],['Does Nora own this tea?',false,false,true],["Didn't Nora own this tea?",true,true,true]
]){
 const actual=await composeOwnershipSentence(text+` [${state}]`,options),expected=await createOwnershipMeaning(owner,object,framework,{allowDraft:true,runtimeState:state,speechAct:question?'question':'assertion',scopes:[...(past?[{operator:'time',relation:'before_speech'}]:[]),...(negative?[{operator:'negation'}]:[])]});assert.deepEqual(actual,expected);
}
for(const [text,named] of [['They own it.','Nora owns this tea.'],['Do they own it?','Does Nora own this tea?'],["They don't own it.",'Nora does not own this tea.']]){
 const bindings={ref0:{referent:'Nora',number:'singular'},ref1:'this tea'};assert.deepEqual(await composeOwnershipSentence(text,{...options,bindings}),await composeOwnershipSentence(named,options));
 await assert.rejects(composeOwnershipSentence(text,{...options,bindings:{...bindings,ref0:{referent:'Nora',number:'plural'}}}),/Group/);
}
await assert.rejects(composeOwnershipSentence('Nora owns this tea.',{allowDraft:true}),/framework explicitly/);
await assert.rejects(composeOwnershipSentence('Nora owns this tea.',{framework:options.framework}),/draft opt-in/);
for(const text of ['Nora own this tea.','I owns this tea.','Nora owns tea.','Nora owns this tea. [3]','Nora has this tea.','Nora owns this tea? [2].'])assert.equal(ownershipPlan(text),null,text);
assert.notDeepEqual(await composeOwnershipSentence('Nora owns this tea.',options),await composeOwnershipSentence('Nora owns this tea.',{...options,framework:'"Island charter"'}));
console.log('PASS 18 full ownership sentence meanings, three explicit neutral-reference cases, framework distinction and unresolved/invalid reading rejection. Music remains unimplemented.');
