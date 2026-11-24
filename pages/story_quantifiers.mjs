// A common-noun class is not a newly introduced individual. Reuse the same
// class reference and all/none frames already used by the story language.
export function ordinaryQuantifiedSubject(tokens,parseNoun){
  const first=tokens[0]?.toLowerCase(),second=tokens[1]?.toLowerCase();
  const negativeEvery=first==='not'&&second==='every';
  if(!negativeEvery&&!['every','each','no'].includes(first)||first==='no'&&second==='one')return null;
  const prefix=negativeEvery?2:1,nominal=parseNoun(['the',...tokens.slice(prefix)],0);
  if(!nominal||nominal.owner||nominal.pronoun)return null;
  const length=prefix+nominal.length-1;
  if(length>=tokens.length)return null;
  const all=first!=='no';
  if(all&&nominal.plural)return {unsupported:true,reason:'Every and each need one singular class name here, such as “every worker”. No quantity has been replaced.'};
  if(nominal.qualities.length)return {unsupported:true,
    reason:'A description inside this quantified subject needs an explicit restricted group. That construction is not supported yet; the description has not been dropped.'};
  return {q:all?'all':'none',outsideNegation:negativeEvery,ordinaryQuantifier:true,
    subject:{...nominal,text:tokens.slice(0,length).join(' '),length,reference:nominal.head,
      referenceKind:'nominal_class',plural:true,singularAgreement:!nominal.plural}};
}

export function quantifiedNegationChoice(clause,scopes,index,answer){
  const result={scopes,negatedQuantifier:clause.outsideNegation};
  if(!clause.ordinaryQuantifier||clause.q!=='all'||clause.outsideNegation)return result;
  const first=scopes.findIndex(scope=>!scope.startsWith('time_'));
  if(first<0||scopes[first]!=='negation')return result;
  if(answer==='other')return {unsupported:true,reason:'This quantity and negative need another scope relationship. No partial meaning has been added to the song.'};
  if(answer==='each')return result;
  if(answer==='not_all')return {scopes:scopes.filter((_,i)=>i!==first),negatedQuantifier:true};
  return {question:{key:'quantityScope'+index,prompt:'How does the negative apply to “'+clause.subject.text+'”?',options:[
    {value:'each',label:'The negative holds for every member'},
    {value:'not_all',label:'Not every member satisfies the statement without the negative'},
    {value:'other',label:'Another quantity relationship'}]}};
}
