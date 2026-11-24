// Scope order comes from the musical meaning. Keep two forms so outer negation
// can distinguish "not required" from a requirement that the event does not occur.
const timeLabels={
  time_before_speech:'in the past',time_at_speech:'at the time of speaking',time_after_speech:'in the future',
  time_previous_day:'yesterday',time_current_day:'today',time_next_day:'tomorrow'
};
const modes={modality_possible:'possible',modality_necessary:'required',modality_predicted:'predicted',modality_obligated:'required by a rule, duty or commitment'};
const runtimeLabels=['inactive, ended or unavailable','active, valid or executing','dormant, pending or unresolved'];
export const describeRuntime=state=>'Runtime ['+state+'] · '+runtimeLabels[state]+'.';

export function describeClaim(label,scopes,act='assertion',quantifier=null,negatedQuantifier=false){
  const event='the event or condition “'+label+'”';
  let yes=event+' holds',no=event+' does not hold';
  for(const scope of [...scopes].reverse()){
    if(scope==='negation'){[yes,no]=[no,yes];continue;}
    if(timeLabels[scope]){yes=timeLabels[scope]+', '+yes;no=timeLabels[scope]+', '+no;continue;}
    let prefix;
    if(modes[scope])prefix='it is '+modes[scope]+' that ';
    if(scope==='aspect_ongoing')prefix='the following is in progress — ';
    if(scope==='ability')prefix='the participant is able to bring this about — ';
    if(!prefix)throw Error('Unknown scope in reading: '+scope);
    no=prefix.replace(' is ',' is not ')+yes;
    yes=prefix+yes;
  }
  if(quantifier==='none')yes='there are no members for whom '+yes;
  if(quantifier==='all')yes=(negatedQuantifier?'it is not true for every member that ':'for every member, ')+yes;
  if(quantifier==='few')yes='for a small, unspecified number of members, '+yes;
  if(act==='question')return 'The speaker asks whether '+yes+'.';
  if(act==='command')return 'The listener is asked to bring this about — '+yes+'.';
  return yes[0].toUpperCase()+yes.slice(1)+'.';
}
