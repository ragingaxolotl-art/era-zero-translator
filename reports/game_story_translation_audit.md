# Game and Story Translation Audit

Status: **PASS**

- Checks passed: **77**
- Checks failed: **0**
- Phrase cases: **62**
- Prevalidated Cyber Pet intents: **13**
- Canonically renderable generalized/direct predicates: **47**
- Honest vocabulary-gap phrases: **13**
- Phrases blocked by unknown semantic content: **3**
- Phrases preserving one or more noun labels: **25**
- Canonical root changes: **0**

## Phrase matrix

| Phrase | Primary route | Word handling | Automatic | Result |
|---|---|---|---:|---|
| The programmer found us. | MIN:110 | the:function_word, programmer:labeled_entity, found:canonical, us:participant_reference | yes | PASS |
| Pip found the toy. | MIN:110 | pip:phonemic_label, found:canonical, the:function_word, toy:documented_gap | yes | PASS |
| Find the missing pet. | MIN:110 | find:canonical, the:function_word, missing:canonical, pet:phonemic_label | yes | PASS |
| Search for Zibble. | MIN:211 | search:canonical, for:function_word, zibble:phonemic_label | yes | PASS |
| I see you. | MIN:011 | i:participant_reference, see:canonical, you:participant_reference | yes | PASS |
| I noticed Pip. | MIN:011 | i:participant_reference, noticed:canonical, pip:phonemic_label | yes | PASS |
| I need food. | ORI:211 | i:participant_reference, need:canonical, food:documented_gap | yes | PASS |
| The pet needs rest. | ORI:211 | the:function_word, pet:phonemic_label, needs:canonical, rest:canonical | no | PASS |
| I am hungry. | ORI:211 | i:participant_reference, am:structural, hungry:canonical | yes | PASS |
| I am thirsty. | ORI:211 | i:participant_reference, am:structural, thirsty:canonical | yes | PASS |
| I am tired. | ORI:211 | i:participant_reference, am:structural, tired:canonical | yes | PASS |
| Please help me. | LIF:211 | please:function_word, help:canonical, me:participant_reference | yes | PASS |
| Feed Pip. | LIF:211 | feed:canonical, pip:phonemic_label | yes | PASS |
| Care for the pet. | LIF:211 | care:canonical, for:function_word, the:function_word, pet:phonemic_label | yes | PASS |
| Support your friend. | LIF:211 | support:canonical, your:participant_reference, friend:documented_gap | yes | PASS |
| I am resting. | REP:101 | i:participant_reference, am:structural, resting:canonical | yes | PASS |
| I am recovering. | REP:101 | i:participant_reference, am:structural, recovering:canonical | yes | PASS |
| My injury is healing. | REP:101 | my:participant_reference, injury:canonical, is:structural, healing:canonical | yes | PASS |
| Clean the pet. | REP:111 | clean:canonical, the:function_word, pet:phonemic_label | yes | PASS |
| Treat the injury. | REP:111 | treat:canonical, the:function_word, injury:canonical | yes | PASS |
| I am asleep. | LIF:002 | i:participant_reference, am:structural, asleep:canonical | yes | PASS |
| I am awake. | LIF:001 | i:participant_reference, am:structural, awake:canonical | yes | PASS |
| Wake up. | LIF:101 | wake:canonical, up:phonemic_label | no | PASS |
| Wake the pet. | LIF:111 | wake:canonical, the:function_word, pet:phonemic_label | no | PASS |
| I am well. | REP:001 | i:participant_reference, am:structural, well:canonical | yes | PASS |
| The pet recovered. | REP:001 | the:function_word, pet:phonemic_label, recovered:canonical | yes | PASS |
| The pet is sick. | WRN:001 | the:function_word, pet:phonemic_label, is:structural, sick:canonical | yes | PASS |
| I am hurt. | CMP:f1abd5eccdf06d92d5690a32 | i:participant_reference, am:structural, hurt:canonical | yes | PASS |
| The pet is injured. | CMP:f1abd5eccdf06d92d5690a32 | the:function_word, pet:phonemic_label, is:structural, injured:canonical | yes | PASS |
| Pip is lost. | MOV:212 | pip:phonemic_label, is:structural, lost:canonical | yes | PASS |
| Hello. | CON:100 | hello:canonical | yes | PASS |
| Thank you. | CON:100 | thank:canonical, you:participant_reference | yes | PASS |
| Go home. | MOV:121 | go:canonical, home:documented_gap | yes | PASS |
| Leave now. | MOV:101 | leave:canonical, now:function_word | yes | PASS |
| Approach the bridge. | MOV:111 | approach:canonical, the:function_word, bridge:phonemic_label | yes | PASS |
| We arrived. | MOV:110 | we:participant_reference, arrived:canonical | yes | PASS |
| Danger is near. | MOV:210 | danger:canonical, is:structural, near:canonical | yes | PASS |
| I am happy. | positive_affect | i:participant_reference, am:structural, happy:documented_gap | no | PASS |
| I am sad. | negative_affect | i:participant_reference, am:structural, sad:documented_gap | no | PASS |
| I am angry. | anger_affect | i:participant_reference, am:structural, angry:documented_gap | no | PASS |
| I am scared. | fear_affect | i:participant_reference, am:structural, scared:documented_gap | no | PASS |
| I love you. | affection_or_preference | i:participant_reference, love:documented_gap, you:participant_reference | no | PASS |
| I want the toy. | desire | i:participant_reference, want:documented_gap, the:function_word, toy:documented_gap | no | PASS |
| Let us play. | recreational_activity | let:structural, us:participant_reference, play:documented_gap | no | PASS |
| I ate the food. | ingestion | i:participant_reference, ate:documented_gap, the:function_word, food:documented_gap | no | PASS |
| Drink water. | ingestion | drink:documented_gap, water:documented_gap | no | PASS |
| The pet is dirty. | cleanliness_deficit | the:function_word, pet:phonemic_label, is:structural, dirty:documented_gap | no | PASS |
| My energy is low. | game_measure_level | my:participant_reference, energy:documented_gap, is:structural, low:documented_gap | no | PASS |
| The pet is full. | satisfied_game_status | the:function_word, pet:phonemic_label, is:structural, full:documented_gap | no | PASS |
| Throw the ball. | game_object_referent | throw:unresolved_semantic, the:function_word, ball:documented_gap | no | PASS |
| I am glarpy. | none | i:participant_reference, am:structural, glarpy:unresolved_semantic | no | PASS |
| Zibble frobnates quux. | none | zibble:phonemic_label, frobnates:unresolved_semantic, quux:phonemic_label | no | PASS |
| The programmer is here. | MOV:001 | the:function_word, programmer:labeled_entity, is:structural, here:canonical | yes | PASS |
| Alice helps Zibble. | LIF:211 | alice:phonemic_label, helps:canonical, zibble:phonemic_label | yes | PASS |
| The developer discovered Pip. | MIN:110 | the:function_word, developer:labeled_entity, discovered:canonical, pip:phonemic_label | yes | PASS |
| The pet requires medicine. | ORI:211 | the:function_word, pet:phonemic_label, requires:canonical, medicine:documented_gap | yes | PASS |
| Rest now. | REP:101 | rest:canonical, now:function_word | yes | PASS |
| The pet is responsive. | LIF:001 | the:function_word, pet:phonemic_label, is:structural, responsive:canonical | yes | PASS |
| The pet is unwell. | WRN:001 | the:function_word, pet:phonemic_label, is:structural, unwell:canonical | yes | PASS |
| Goodbye. | CON:100 | goodbye:canonical | yes | PASS |
| I need the file inside the folder. | ORI:211 | i:participant_reference, need:canonical, the:function_word, file:canonical, inside:canonical, the:function_word, folder:canonical | yes | PASS |
| I need the file that is inside the folder. | ORI:211 | i:participant_reference, need:canonical, the:function_word, file:canonical, that:function_word, is:structural, inside:canonical, the:function_word, folder:canonical | yes | PASS |

## Interpretation boundary

A PASS means the analyzer handled the phrase according to the declared policy. It does not mean every English detail entered canonical Era Zero. Generalized routes preserve only the entailed canonical center and display the lost detail. Participant references are grammatical. EZNAME preserves noun identity only. Gap routes remain untranslated. Unknown verbs and descriptors block automatic translation.

## Cyber Pet integration recommendation

Use stable game-state intent keys rather than re-parsing display prose at runtime. For example, low Fullness may select the tested `hungry`/operative-dependence route, low Energy may select `tired`/operative-dependence, an injury may select the approved physical-injury compound, and a care request may select active living care. Keep the English subtitle beside the Era Zero performance so the disclosed generalization remains visible during development.
