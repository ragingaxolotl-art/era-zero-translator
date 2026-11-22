import {storyWords} from './story_words.mjs?v=physical-placement-1';
import {FELT_CONDITIONS} from './felt_conditions.mjs';
import {isPassageHead} from './passage_nouns.mjs';

const ids=new Map(storyWords.map(w=>[w.word,w.id]));
const id=word=>ids.get(word);
export const feltProperties = Object.fromEntries(FELT_CONDITIONS.map(f=>[f.pattern,f.predicate]));
export const properties = new Map(Object.entries({
  ...feltProperties,cracked:id('cracked'), faulty:id('faulty'), broken:id('broken'), sick:'WRN:001',
  passable:id('passable'), open:id('passable'), blocked:id('blocked'), impassable:id('blocked'),
  closed:id('closed'),shut:id('closed'),available:id('available for use'),'available for use':id('available for use'),
  curious:id('curious'),inquisitive:id('curious'),resumed:id('resume'),empty:id('empty'),full:id('full'),
  valid:id('valid'), wrong:id('wrong'), mistaken:id('wrong'), awake:'LIF:001', asleep:'LIF:002', well:'REP:001', lost:'MOV:212'
}));

export const isPhysicalContainer=head=>/^(?:box(?:es)?|crates?|bottles?|cups?|bowls?|buckets?|baskets?|bags?|jars?|cans?|tanks?|containers?|barrels?)$/.test(head);
export const isMaterialTarget=head=>isPassageHead(head)||isPhysicalContainer(head)||/^(?:gates?|doors?|carts?|stones?|rocks?|books?|chairs?|tables?|lids?|packages?|handles?|levers?|loads?|weights?|lamps?|balls?|tools?|boards?|ropes?|cords?|cables?|chains?|shelves|shelf)$/.test(head);
export const isPhysicalPlace=head=>isMaterialTarget(head)||/^(?:rooms?|stations?|gardens?|parks?|houses?|homes?|buildings?|entrances?|exits?|corners?|desks?|benches?|workshops?|warehouses?)$/.test(head);
export const physicalActionLabels=Object.freeze({push:'Physical pushing',lift:'Physical lifting',lower:'Controlled physical lowering',displace:'Physical displacement',
  put:'Physical placement at the destination',place:'Physical placement at the destination',
  hold:'Maintaining a grip, restraint or physical support',pull:'Pulling through a grip or tension',release:'Ending a physical hold',drop:'Releasing the object and causing it to fall',fall:'Downward movement under gravity'});
