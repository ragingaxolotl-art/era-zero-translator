const PLURALS={archives:'archive',gates:'gate',radios:'radio',machines:'machine',pumps:'pump',stations:'station',records:'record',maps:'map',boxes:'box',teachers:'teacher',children:'child',people:'person',creatures:'creature',robots:'robot',doors:'door',devices:'device',tools:'tool',books:'book',sounds:'sound',trees:'tree',houses:'house',cars:'car',rooms:'room',tables:'table',balls:'ball',dogs:'dog',cats:'cat'};
const WORDS={zero:'0',one:'1',two:'2',three:'3',four:'4',five:'5',six:'6',seven:'7',eight:'8',nine:'9',ten:'10'};
const heads=[...Object.values(PLURALS),'water','food'];
export const NOMINAL_PATTERN=`(?:[Tt]he (?:${heads.join('|')})|(?:[Ee]xactly|[Aa]t least|[Aa]t most) (?:[0-9]+|${Object.keys(WORDS).join('|')}) (?:${Object.keys(PLURALS).join('|')}))`;
export function parseNominal(text){
 if(typeof text!=='string'||text.startsWith('"'))return null;
 const definite=text.match(/^[Tt]he ([a-z]+)$/);
 if(definite&&heads.includes(definite[1]))return {head:definite[1],mode:'definite_nominal'};
 const counted=text.match(/^(exactly|at least|at most) ([0-9]+|zero|one|two|three|four|five|six|seven|eight|nine|ten) ([a-z]+)$/i);
 if(!counted||!PLURALS[counted[3].toLowerCase()])return null;
 const value=WORDS[counted[2].toLowerCase()]??counted[2].replace(/^0+(?=\d)/,'');
 if(value.length>1024)return null;
 return {head:PLURALS[counted[3].toLowerCase()],mode:'nominal_class',quantifier:{exactly:'exact','at least':'at_least','at most':'at_most'}[counted[1].toLowerCase()],value};
}
