// Negative auxiliary spelling only; this does not supply missing sentence meaning.
// participantPattern must have exactly one capturing group for the subject.
export function expandNegativeContractions(input,participantPattern){
  const contractions={"isn't":"is not","aren't":"are not","wasn't":"was not","weren't":"were not","doesn't":"does not","don't":"do not","didn't":"did not","can't":"cannot","couldn't":"could not","won't":"will not","wouldn't":"would not","shouldn't":"should not","mustn't":"must not","hasn't":"has not","haven't":"have not","hadn't":"had not"};
  const original=String(input),segments=original.split('"');
  const expanded=segments.map((part,index)=>index%2?part:part.replace(/\b(?:isn|aren|wasn|weren|doesn|don|didn|can|couldn|won|wouldn|shouldn|mustn|hasn|haven|hadn)['’]t\b/gi,word=>{
    const value=contractions[word.toLowerCase().replace('’',"'")];
    return /^[A-Z]/.test(word)?value[0].toUpperCase()+value.slice(1):value;
  })).join('"');
  if(expanded===original)return original;
  const inverted=expanded.match(new RegExp(`^([Ii]s|[Aa]re|[Ww]as|[Ww]ere|[Dd]oes|[Dd]o|[Dd]id) not ${participantPattern} (.+[?])$`));
  return inverted?`${inverted[1]} ${inverted[2]} not ${inverted[3]}`:expanded;
}
