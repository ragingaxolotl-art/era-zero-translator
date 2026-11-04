// Each choice includes the physical-entry sense. No choice asserts occurrence.
export const ENTRY_MODAL_CHOICES={
 positive:[['entry_possible','Physical entry is possible'],['entry_permitted','Physical entry is permitted']],
 negative:[['entry_possible_not','It is possible that physical entry does not occur'],['entry_not_permitted','Physical entry is not permitted'],['entry_permitted_not','Not entering is permitted']]
};
export function entryModalChoices(negative,ongoing=false){
 const choices=ENTRY_MODAL_CHOICES[negative?'negative':'positive'];
 if(!ongoing)return choices;
 const labels={entry_possible:'Physical entry may be in progress',entry_permitted:'Physical entry in progress is permitted',entry_possible_not:'It is possible that physical entry is not in progress',entry_not_permitted:'Physical entry in progress is not permitted',entry_permitted_not:'Not being in the process of entering is permitted'};
 return choices.map(([key])=>[key,labels[key]]);
}
export function entryModalScopes(choice,negative){
 if(!entryModalChoices(negative).some(([key])=>key===choice)){
  const error=new Error('Choose the physical-entry reading of may, including the intended scope of not.');error.code='entry_modality_required';throw error;
 }
 const neg={operator:'negation'},modal=mode=>({operator:'modality',mode});
 return {entry_possible:[modal('possible')],entry_permitted:[modal('permitted')],entry_possible_not:[neg,modal('possible')],entry_not_permitted:[modal('permitted'),neg],entry_permitted_not:[neg,modal('permitted')]}[choice];
}
