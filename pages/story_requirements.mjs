// Reuse the existing predicate grammar after a strictly matched requirement
// phrase. Its modal meaning remains an explicit choice, not a lexical alias.
export function requirementVerb(verb,anchor){
  const third=!['I','we','you'].includes(anchor);
  let match=/^must (not )?(.+)$/i.exec(verb);
  if(match)return (third?'needs':'need')+' to '+(match[1]?'not ':'')+match[2];
  match=/^(have|has|had) to (not )?(.+)$/i.exec(verb);
  if(match){
    const aux=match[1].toLowerCase();
    if(aux!=='had'&&(aux==='has')!==third)return null;
    return (aux==='had'?'did need':third?'needs':'need')+' to '+(match[2]?'not ':'')+match[3];
  }
  match=/^(do|does|did|will|might) (not )?have to (not )?(.+)$/i.exec(verb);
  return match?match[1].toLowerCase()+' '+(match[2]?'not ':'')+'need to '+(match[3]?'not ':'')+match[4]:null;
}

export function requirementMeaning(reading,index,answer){
  if(!reading.requirement)return {scopes:reading.scopes};
  if(answer==='other')return {unsupported:true,
    reason:'This requirement has another intended meaning. It remains unresolved; no obligation or necessity has been silently substituted.'};
  if(!['obligated','necessary'].includes(answer))return {question:{key:'requirement'+index,
    prompt:'What does this requirement mean?',options:[
      {value:'obligated',label:'A rule, duty or commitment'},
      {value:'necessary',label:'A practical or logical necessity'},
      {value:'other',label:'Another meaning'}]}};
  const position=reading.scopes.lastIndexOf('modality_necessary');
  if(position<0)throw Error('A requirement needs its original modal scope.');
  return {scopes:reading.scopes.map((scope,i)=>i===position?'modality_'+answer:scope)};
}
