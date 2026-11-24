// Ordinary comparative forms select the existing material-property grammar.
// They do not rename the hot/cold/heavy/light contextual-standard meanings.
const readings=Object.freeze({
  temperature_comparison:{label:'Physical temperature',description:'Compare the participants’ thermodynamic temperatures. No measured value or hot/cold threshold is required. Felt warmth, spiciness and figurative meanings need a different interpretation.'},
  mass_comparison:{label:'Physical mass',description:'Compare the participants’ masses. No measured value or heavy/light threshold is required. Weight force, carrying effort, brightness and figurative meanings need a different interpretation.'}
});
export const physicalComparativeMeaning=key=>Object.hasOwn(readings,key)?readings[key]:null;
const forms=Object.freeze({
  hotter:['a higher temperature than','temperature_pair_comparison','temperature_comparison'],
  colder:['a lower temperature than','temperature_pair_comparison','temperature_comparison'],
  heavier:['more mass than','mass_pair_comparison','mass_comparison'],
  lighter:['less mass than','mass_pair_comparison','mass_comparison']
});
export function parsePhysicalComparative(input,participant,parseInner){
  const match=String(input).trim().match(new RegExp(`^${participant} (is|am|are|was|were|will be|will not be) (not )?(hotter|colder|heavier|lighter) than ${participant}[.]?$`));
  if(!match)return null;
  if(match[2]==='will not be'&&match[3])return null;
  const [phrase,key,interpretation]=forms[match[4]];
  const inner=parseInner(`${match[1]} ${/^(?:I|you)$/i.test(match[1])?'have':'has'} ${phrase} ${match[5]}.`);
  if(!inner||inner.key!==key)return null;
  return {...inner,adjective:match[4],requiredInterpretation:interpretation,
    semanticNote:inner.semanticNote+(match[2].startsWith('will ')?' Will places this comparison after speech time; no promise, intention or willingness is inferred.':''),
    ...(['was','were'].includes(match[2])?{speechTime:'before'}:match[2].startsWith('will ')?{speechTime:'after'}:{}),
    scopes:[...inner.scopes,...(match[3]||match[2]==='will not be'?[{operator:'negation'}]:[])],
    construction:'physical_adjective_comparison',explicitInterpretation:String(input).trim()};
}
