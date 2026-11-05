const PLURALS={lamps:'lamp',lanterns:'lantern',shelves:'shelf',sensors:'sensor',bells:'bell',archives:'archive',gates:'gate',radios:'radio',machines:'machine',pumps:'pump',stations:'station',records:'record',maps:'map',boxes:'box',teachers:'teacher',children:'child',people:'person',creatures:'creature',robots:'robot',doors:'door',devices:'device',tools:'tool',books:'book',sounds:'sound',trees:'tree',houses:'house',cars:'car',rooms:'room',tables:'table',balls:'ball',dogs:'dog',cats:'cat'};
const SINGULARS=new Set(Object.values(PLURALS));
const WORDS={zero:'0',one:'1',two:'2',three:'3',four:'4',five:'5',six:'6',seven:'7',eight:'8',nine:'9',ten:'10'};
// A definite single-word noun labels a referent; it does not need a semantic dictionary entry.
const NON_HEADS=new Set(['and','or','then','not','is','are','was','were','has','have','to','from','of','for','with','in','on','at','the','a','an','this','that','these','those','he','she','it','they','we','you','me','him','her','them','us','heavy','light','hot','cold','happy','sad','hungry','thirsty','tired','curious','bright','dim','rough','smooth','broken','damaged','active','conscious','dormant']);
const headPattern='(?!(?:'+[...NON_HEADS].join('|')+')\\b)[a-z]+(?:-[a-z]+)*';
const demonstrativeHeadPattern='(?!(?:'+Object.keys(PLURALS).join('|')+')\\b)(?![a-z]+-)'+headPattern;
export const NOMINAL_PATTERN=`(?:[Tt]he (?:${headPattern})|(?:[Tt]his|[Tt]hat) (?:${demonstrativeHeadPattern})|(?:[Ee]xactly|[Aa]t least|[Aa]t most) (?:(?:[0-9]+|${Object.keys(WORDS).join('|')}) (?:${Object.keys(PLURALS).join('|')})|(?:0*1|one) (?:${[...SINGULARS].join('|')})))`;
export function parseNominal(text){
 if(typeof text!=='string'||text.startsWith('"'))return null;
 const demonstrative=text.match(new RegExp(`^([Tt]his|[Tt]hat) (${demonstrativeHeadPattern})$`));
 if(demonstrative){if(Object.hasOwn(PLURALS,demonstrative[2]))return null;return {head:demonstrative[2],mode:demonstrative[1].toLowerCase()==='this'?'proximal_nominal':'distal_nominal'};}
 const definite=text.match(new RegExp(`^[Tt]he (${headPattern})$`));
 if(definite)return {head:definite[1],mode:'definite_nominal'};
 const counted=text.match(/^(exactly|at least|at most) ([0-9]+|zero|one|two|three|four|five|six|seven|eight|nine|ten) ([a-z]+)$/i);
 if(!counted)return null;
 const value=WORDS[counted[2].toLowerCase()]??counted[2].replace(/^0+(?=\d)/,'');
 if(value.length>1024)return null;
 const noun=counted[3].toLowerCase(),head=PLURALS[noun]||(value==='1'&&SINGULARS.has(noun)?noun:null);
 if(!head)return null;
 return {head,mode:'nominal_class',quantifier:{exactly:'exact','at least':'at_least','at most':'at_most'}[counted[1].toLowerCase()],value};
}
