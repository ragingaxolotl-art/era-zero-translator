// Surface voice reuses the reviewed transitive predicates and their roles.
// The patient is identified first; story_readings restores canonical role order
// before rendering, so no passive-only musical frame or dictionary alias exists.
const reviewed = new Set([
  'push','displace','lift','lower','fill','empty','close','shut','pull','hold',
  'release','drop','delete','copy','save','store','recall','remember',
  'repeat','notice','spot','find','check','inspect','recheck','request',
  'open','reopen','hear','see','make'
]);
const participles = {see:'seen'};
const lower = value => String(value || '').toLowerCase();

function agreement(subject) {
  const pronoun=lower(subject.pronoun);
  if(['i','me'].includes(pronoun))return {present:'am',past:'was',active:'do'};
  const plural=subject.plural&&!subject.singularAgreement || ['we','us','you','they','them'].includes(pronoun);
  return plural?{present:'are',past:'were',active:'do'}:{present:'is',past:'was',active:'does'};
}

export function passiveClause(tokens,patient,parseNoun,shapes) {
  const by=tokens.findIndex(token=>lower(token)==='by');
  if(by<2||tokens.slice(by+1).some(token=>lower(token)==='by'))return null;
  const agent=parseNoun(tokens,by+1,{guessName:true});
  if(!agent||by+1+agent.length!==tokens.length)return null;
  const phrase=tokens.slice(0,by).map(lower).join(' ');
  const copula=/^(am|is|are|was|were) (not )?(being )?([a-z-]+)$/.exec(phrase);
  const modal=/^(will|might|can|cannot) (not )?be (being )?([a-z-]+)$/.exec(phrase);
  const match=copula||modal;
  if(!match||match[1]==='cannot'&&match[2])return null;
  const [,aux,negative,ongoing,participle]=match;
  const patientAgreement=agreement(patient),agentAgreement=agreement(agent);
  if(copula&&aux!==patientAgreement.present&&aux!==patientAgreement.past)return null;
  const shape=shapes.find(([base,,past,roles])=>reviewed.has(base)&&roles.length===2&&(participles[base]||past)===participle);
  if(!shape||ongoing&&!shape[5])return null;
  const [base,third,past,,,progressive]=shape;
  const neg=negative?'not ':'';
  let verb;
  if(copula){
    const before=['was','were'].includes(aux);
    verb=ongoing?`${before?agentAgreement.past:agentAgreement.present} ${neg}${progressive}`:
      `${before?'did':agentAgreement.active} ${neg}${base}`;
  }else verb=`${aux} ${neg}${ongoing?'be '+progressive:base}`;
  return {agent,verb,base,target:shape[4],participle,forms:[base,third,past,progressive,participle].filter(Boolean)};
}
