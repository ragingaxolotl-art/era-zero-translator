export function validAcquisitionScopes(scopes){
 if(!Array.isArray(scopes))return false;
 return [[],['negation'],['before_speech'],['before_speech','negation'],['previous_day'],['previous_day','negation'],['current_day'],['current_day','negation'],['current_day','before_speech'],['current_day','before_speech','negation']].some(s=>JSON.stringify(s)===JSON.stringify(scopes));
}
export const acquisitionScopeMarker=(scope,side)=>scope==='negation'?`negation_${side}`:`time_${scope}_${side}`;
