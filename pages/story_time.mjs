// These are the published day/instant frames, not new vocabulary. A leading
// time word needs its comma; a capitalized or quoted final name stays a name.
const scopes={yesterday:'time_previous_day',today:'time_current_day',tomorrow:'time_next_day',now:'time_at_speech'};
const modal=scope=>scope==='ability'||scope.startsWith('modality_');
export function storyTime(body){
  const leading=/^(yesterday|today|tomorrow|now),\s+(.+)$/i.exec(body);
  const rest=leading?leading[2]:body;
  const trailing=/\s+(yesterday|today|tomorrow|now)$/.exec(rest);
  if(!leading&&!trailing)return null;
  const word=(leading?.[1]||trailing[1]).toLowerCase();
  const text=trailing?rest.slice(0,trailing.index):rest;
  if(leading&&trailing||/\s+(yesterday|today|tomorrow|now)$/.test(text))return {unsupported:true,
    reason:'This sentence has more than one time expression. Use one time expression per sentence so neither is silently lost.'};
  return {body:text,word,scope:scopes[word]};
}

export function timeScopeChoice(time,orderedScopes,index,answer){
  if(!time||!orderedScopes.some(modal))return {scopes:orderedScopes};
  if(orderedScopes.filter(modal).length>1)return {unsupported:true,
    reason:'This sentence combines time with more than one ability, possibility or need. Their nested time scopes need a more explicit construction; none has been silently selected.'};
  if(answer==='other')return {unsupported:true,reason:'This time relationship needs another construction. Keep the intended relationship explicit; it has not been turned into a song.'};
  if(!['event','claim'].includes(answer))return {question:{key:'timeScope'+index,
    prompt:'What does “'+time.word+'” locate in time?',options:[
      {value:'event',label:'When the action or state happens'},
      {value:'claim',label:orderedScopes.includes('modality_obligated')?'When the obligation applies':'When the ability, possibility or need holds'},
      {value:'other',label:'Another time relationship'}]}};
  if(answer==='claim')return {scopes:orderedScopes};
  // The day was placed outside the clause. Move just that frame inside the
  // modal, keeping negation, tense and aspect in their original relative order.
  const inner=orderedScopes.slice(1),last=inner.findLastIndex(modal);
  inner.splice(last+1,0,time.scope);
  return {scopes:inner};
}
