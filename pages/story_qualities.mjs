import {storyWords} from './story_words.mjs?v=state-adjectives-1';
import {FELT_CONDITIONS} from './felt_conditions.mjs';
import {isPassageHead} from './passage_nouns.mjs';

const ids=new Map(storyWords.map(w=>[w.word,w.id]));
const id=word=>ids.get(word);
export const feltProperties = Object.fromEntries(FELT_CONDITIONS.map(f=>[f.pattern,f.predicate]));
export const properties = new Map(Object.entries({
  ...feltProperties,cracked:id('cracked'), faulty:id('faulty'), broken:id('broken'), sick:'WRN:001',
  passable:id('passable'), open:id('passable'), blocked:id('blocked'), impassable:id('blocked'),
  closed:id('closed'),shut:id('closed'),available:id('available for use'),'available for use':id('available for use'),
  curious:id('curious'),inquisitive:id('curious'),resumed:id('resume'),
  valid:id('valid'), wrong:id('wrong'), mistaken:id('wrong'), awake:'LIF:001', asleep:'LIF:002', well:'REP:001', lost:'MOV:212'
}));

export const isMaterialTarget=head=>isPassageHead(head)||/^(?:gates?|doors?|box(?:es)?|crates?|carts?|stones?|books?|chairs?|tables?|lids?|packages?|handles?|levers?|loads?|bags?|weights?|lamps?|balls?|bottles?|tools?|boards?|shelves|shelf)$/.test(head);
