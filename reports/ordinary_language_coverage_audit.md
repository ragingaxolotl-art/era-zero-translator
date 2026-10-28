# Ordinary-language, story, and game corpus audit

Status: **PASS**

- Curated new phrases: **53**
- Existing game/story phrases: **69**
- Lore performance turns: **22**
- Total audited phrases: **144**
- Canonical roots / indexed and profile senses: **324 / 485**
- Automatic single-target readings: **85** (not full sentence translations)
- Phrases with documented gaps: **30**
- Phrases with unresolved predicates/descriptors: **20**
- Assertion failures: **0**

## What this audit proves

It checks conservative lexical routing and word-level classifications over three independent in-repository corpora. A candidate root is a semantic center, not a complete translation of participants, tense, object roles, or clauses. An automatic single-target reading may omit unsupported detail. Gaps and structural routes are expected, not hidden. The site must show these limitations.

## Domain coverage

| Domain | Phrases | Auto single-target | With gap | With unresolved semantic word | With structural word |
|---|---:|---:|---:|---:|---:|
| care | 13 | 4 | 8 | 4 | 0 |
| computer | 21 | 6 | 0 | 8 | 3 |
| game_story | 69 | 48 | 17 | 3 | 5 |
| lore | 22 | 18 | 3 | 0 | 2 |
| motion | 7 | 3 | 1 | 1 | 3 |
| story | 12 | 6 | 1 | 4 | 4 |

## High-priority unrepresented actions and descriptors

These require either a defensible reviewed surface route to an existing meaning, a compound/IR design, or an explicit future vocabulary decision. They are not silently given new roots.

| Term | Corpus mentions | Classification |
|---|---:|---|
| throw | 2 | verb |
| carry | 1 | verb |
| pick | 1 | verb |
| curious | 1 | descriptor |
| open | 1 | verb |
| save | 1 | verb |
| copy | 1 | verb |
| back | 1 | verb |
| corrupted | 1 | verb |
| crashed | 1 | verb |
| compile | 1 | verb |
| delivered | 1 | verb |
| rising | 1 | verb |
| blocked | 1 | verb |
| warn | 1 | verb |
| open | 1 | descriptor |
| talking | 1 | verb |
| glarpy | 1 | descriptor |
| frobnates | 1 | verb |

## Documented vocabulary gaps

| Term | Corpus mentions |
|---|---:|
| toy | 4 |
| home | 3 |
| want | 2 |
| happy | 2 |
| ball | 2 |
| scared | 2 |
| medicine | 2 |
| food | 2 |
| play | 1 |
| safe | 1 |
| game | 1 |
| friend | 1 |
| sad | 1 |
| angry | 1 |
| play | 1 |
| ate | 1 |
| drink | 1 |
| water | 1 |
| dirty | 1 |
| energy | 1 |
| low | 1 |
| full | 1 |
| meals | 1 |
| safe | 1 |

## Phrase-by-phrase results

| Source / domain | English phrase | Primary route | Auto | Non-function word routes | Result |
|---|---|---|---:|---|---|
| curated / care | I love you. | affection_or_preference | no | love:canonical | PASS |
| curated / care | I want to play. | desire | no | want:documented_gap, play:documented_gap | PASS |
| curated / care | Please feed the pet. | LIF:211 | yes | feed:canonical, pet:phonemic_label | PASS |
| curated / care | The pet slept. | LIF:002 | yes | pet:phonemic_label, slept:canonical | PASS |
| curated / care | The pet is happy. | positive_affect | no | pet:phonemic_label, happy:documented_gap | PASS |
| curated / care | The pet is hungry. | ORI:211 | yes | pet:phonemic_label, hungry:canonical | PASS |
| curated / care | Carry the toy. | game_object_referent | no | carry:unresolved_semantic, toy:documented_gap | PASS |
| curated / care | Throw the ball. | game_object_referent | no | throw:unresolved_semantic, ball:documented_gap | PASS |
| curated / care | Pick up the toy. | game_object_referent | no | pick:unresolved_semantic, toy:documented_gap | PASS |
| curated / care | The pet is scared. | fear_affect | no | pet:phonemic_label, scared:documented_gap | PASS |
| curated / care | The pet needs medicine. | ORI:211 | yes | pet:phonemic_label, needs:canonical, medicine:documented_gap | PASS |
| curated / care | The child is curious. | none | no | child:phonemic_label, curious:unresolved_semantic | PASS |
| curated / care | We are safe. | acceptable_risk | no | safe:documented_gap | PASS |
| curated / computer | I found the file. | MIN:110 | yes | found:canonical, file:canonical | PASS |
| curated / computer | Open the folder. | STR:020 | no | open:unresolved_semantic, folder:canonical | PASS |
| curated / computer | Close the folder. | STR:020 | yes | close:canonical, folder:canonical | PASS |
| curated / computer | Save the file. | DAT:000 | no | save:unresolved_semantic, file:canonical | PASS |
| curated / computer | Delete the file. | requested_information_deletion | no | delete:structural, file:canonical | PASS |
| curated / computer | Copy the file. | DAT:000 | no | copy:unresolved_semantic, file:canonical | PASS |
| curated / computer | Move the file. | MOV:121 | no | move:canonical, file:canonical | PASS |
| curated / computer | Send the file. | DAT:111 | yes | send:canonical, file:canonical | PASS |
| curated / computer | Receive the file. | DAT:110 | yes | receive:canonical, file:canonical | PASS |
| curated / computer | Migrate the file. | DAT:111 | yes | migrate:canonical, file:canonical | PASS |
| curated / computer | Back up the file. | DAT:000 | no | back:unresolved_semantic, file:canonical | PASS |
| curated / computer | The file is corrupted. | DAT:000 | no | file:canonical, corrupted:unresolved_semantic | PASS |
| curated / computer | Repair the data. | REP:110 | yes | repair:canonical, data:canonical | PASS |
| curated / computer | The program crashed. | CMP:2f350e7d8e5dfba4a802d82d | no | program:canonical, crashed:unresolved_semantic | PASS |
| curated / computer | Run the program. | program_execution | no | run:structural, program:canonical | PASS |
| curated / computer | Compile the code. | none | no | compile:unresolved_semantic, code:phonemic_label | PASS |
| curated / computer | The file changed. | MAT:100 | no | file:canonical, changed:canonical | PASS |
| curated / computer | The file is changing. | STR:101 | no | file:canonical, changing:canonical | PASS |
| curated / computer | Change the file. | DAT:101 | no | change:canonical, file:canonical | PASS |
| curated / computer | The files are being deleted. | active_information_deletion | no | files:canonical, deleted:structural | PASS |
| curated / computer | The package was delivered. | none | no | package:phonemic_label, delivered:unresolved_semantic | PASS |
| curated / motion | The traveler arrived. | MOV:110 | yes | traveler:phonemic_label, arrived:canonical | PASS |
| curated / motion | Wait here. | deferred_action | no | wait:structural, here:canonical | PASS |
| curated / motion | Cross the bridge. | boundary_traversal | no | cross:structural, bridge:phonemic_label | PASS |
| curated / motion | We moved together. | MOV:120 | yes | moved:canonical, together:canonical | PASS |
| curated / motion | Return home. | movement_to_prior_position | no | return:structural, home:documented_gap | PASS |
| curated / motion | The storm is coming. | MOV:111 | yes | storm:phonemic_label, coming:canonical | PASS |
| curated / motion | The river is rising. | none | no | river:phonemic_label, rising:unresolved_semantic | PASS |
| curated / story | Remember the route. | MOV:020 | yes | remember:structural, route:canonical | PASS |
| curated / story | The route is blocked. | MOV:020 | no | route:canonical, blocked:unresolved_semantic | PASS |
| curated / story | Warn the others. | LIF:010 | no | warn:unresolved_semantic, others:canonical | PASS |
| curated / story | The door is open. | none | no | door:phonemic_label, open:unresolved_semantic | PASS |
| curated / story | I do not know. | MIN:010 | no | not:structural, know:canonical | PASS |
| curated / story | Can you help me? | LIF:211 | yes | help:canonical | PASS |
| curated / story | We are talking. | none | no | talking:unresolved_semantic | PASS |
| curated / story | Stop the game. | game_object_referent | no | stop:structural, game:documented_gap | PASS |
| curated / story | Please listen. | CON:111 | yes | listen:canonical | PASS |
| curated / story | I need a key. | ORI:211 | yes | need:canonical, key:phonemic_label | PASS |
| curated / story | Build a wall. | CRE:111 | yes | build:structural, wall:phonemic_label | PASS |
| curated / story | Place the wall here. | MOV:001 | yes | place:canonical, wall:phonemic_label, here:canonical | PASS |
| game_story / game_story | The programmer found us. | MIN:110 | yes | programmer:labeled_entity, found:canonical | PASS |
| game_story / game_story | Pip found the toy. | MIN:110 | yes | pip:phonemic_label, found:canonical, toy:documented_gap | PASS |
| game_story / game_story | Find the missing pet. | MIN:110 | yes | find:canonical, missing:canonical, pet:phonemic_label | PASS |
| game_story / game_story | Search for Zibble. | MIN:211 | yes | search:canonical, zibble:phonemic_label | PASS |
| game_story / game_story | I see you. | MIN:011 | yes | see:canonical | PASS |
| game_story / game_story | I noticed Pip. | MIN:011 | yes | noticed:canonical, pip:phonemic_label | PASS |
| game_story / game_story | I need food. | ORI:211 | yes | need:canonical, food:documented_gap | PASS |
| game_story / game_story | The pet needs rest. | ORI:211 | yes | pet:phonemic_label, needs:canonical, rest:canonical | PASS |
| game_story / game_story | I am hungry. | ORI:211 | yes | hungry:canonical | PASS |
| game_story / game_story | I am thirsty. | ORI:211 | yes | thirsty:canonical | PASS |
| game_story / game_story | I am tired. | ORI:211 | yes | tired:canonical | PASS |
| game_story / game_story | Please help me. | LIF:211 | yes | help:canonical | PASS |
| game_story / game_story | Feed Pip. | LIF:211 | yes | feed:canonical, pip:phonemic_label | PASS |
| game_story / game_story | Care for the pet. | LIF:211 | yes | care:canonical, pet:phonemic_label | PASS |
| game_story / game_story | Support your friend. | LIF:211 | yes | support:canonical, friend:documented_gap | PASS |
| game_story / game_story | I am resting. | REP:101 | yes | resting:canonical | PASS |
| game_story / game_story | I am recovering. | REP:101 | yes | recovering:canonical | PASS |
| game_story / game_story | My injury is healing. | REP:101 | yes | injury:canonical, healing:canonical | PASS |
| game_story / game_story | Clean the pet. | REP:111 | yes | clean:canonical, pet:phonemic_label | PASS |
| game_story / game_story | Treat the injury. | REP:111 | yes | treat:canonical, injury:canonical | PASS |
| game_story / game_story | I am asleep. | LIF:002 | yes | asleep:canonical | PASS |
| game_story / game_story | I am awake. | LIF:001 | yes | awake:canonical | PASS |
| game_story / game_story | Wake up. | LIF:101 | no | wake:canonical, up:phonemic_label | PASS |
| game_story / game_story | Wake the pet. | LIF:111 | no | wake:canonical, pet:phonemic_label | PASS |
| game_story / game_story | I am well. | REP:001 | yes | well:canonical | PASS |
| game_story / game_story | The pet recovered. | REP:001 | yes | pet:phonemic_label, recovered:canonical | PASS |
| game_story / game_story | The pet is sick. | WRN:001 | yes | pet:phonemic_label, sick:canonical | PASS |
| game_story / game_story | I am hurt. | CMP:f1abd5eccdf06d92d5690a32 | yes | hurt:canonical | PASS |
| game_story / game_story | The pet is injured. | CMP:f1abd5eccdf06d92d5690a32 | yes | pet:phonemic_label, injured:canonical | PASS |
| game_story / game_story | Pip is lost. | MOV:212 | yes | pip:phonemic_label, lost:canonical | PASS |
| game_story / game_story | Hello. | CON:100 | yes | hello:canonical | PASS |
| game_story / game_story | Thank you. | CON:100 | yes | thank:canonical | PASS |
| game_story / game_story | Go home. | MOV:121 | yes | go:canonical, home:documented_gap | PASS |
| game_story / game_story | Leave now. | MOV:101 | yes | leave:canonical | PASS |
| game_story / game_story | Approach the bridge. | MOV:111 | yes | approach:canonical, bridge:phonemic_label | PASS |
| game_story / game_story | We arrived. | MOV:110 | yes | arrived:canonical | PASS |
| game_story / game_story | Danger is near. | MOV:210 | yes | danger:canonical, near:canonical | PASS |
| game_story / game_story | I am happy. | positive_affect | no | happy:documented_gap | PASS |
| game_story / game_story | I am sad. | negative_affect | no | sad:documented_gap | PASS |
| game_story / game_story | I am angry. | anger_affect | no | angry:documented_gap | PASS |
| game_story / game_story | I am scared. | fear_affect | no | scared:documented_gap | PASS |
| game_story / game_story | I love you. | affection_or_preference | no | love:canonical | PASS |
| game_story / game_story | I want the toy. | desire | no | want:documented_gap, toy:documented_gap | PASS |
| game_story / game_story | Let us play. | recreational_activity | no | let:structural, play:documented_gap | PASS |
| game_story / game_story | I ate the food. | ingestion | no | ate:documented_gap, food:documented_gap | PASS |
| game_story / game_story | Drink water. | ingestion | no | drink:documented_gap, water:documented_gap | PASS |
| game_story / game_story | The pet is dirty. | cleanliness_deficit | no | pet:phonemic_label, dirty:documented_gap | PASS |
| game_story / game_story | My energy is low. | game_measure_level | no | energy:documented_gap, low:documented_gap | PASS |
| game_story / game_story | The pet is full. | satisfied_game_status | no | pet:phonemic_label, full:documented_gap | PASS |
| game_story / game_story | Throw the ball. | game_object_referent | no | throw:unresolved_semantic, ball:documented_gap | PASS |
| game_story / game_story | I am glarpy. | none | no | glarpy:unresolved_semantic | PASS |
| game_story / game_story | Zibble frobnates quux. | none | no | zibble:phonemic_label, frobnates:unresolved_semantic, quux:phonemic_label | PASS |
| game_story / game_story | The programmer is here. | MOV:001 | yes | programmer:labeled_entity, here:canonical | PASS |
| game_story / game_story | Alice helps Zibble. | LIF:211 | yes | alice:phonemic_label, helps:canonical, zibble:phonemic_label | PASS |
| game_story / game_story | The developer discovered Pip. | MIN:110 | yes | developer:labeled_entity, discovered:canonical, pip:phonemic_label | PASS |
| game_story / game_story | The pet requires medicine. | ORI:211 | yes | pet:phonemic_label, requires:canonical, medicine:documented_gap | PASS |
| game_story / game_story | Rest now. | REP:101 | yes | rest:canonical | PASS |
| game_story / game_story | The pet is responsive. | LIF:001 | yes | pet:phonemic_label, responsive:canonical | PASS |
| game_story / game_story | The pet is unwell. | WRN:001 | yes | pet:phonemic_label, unwell:canonical | PASS |
| game_story / game_story | Goodbye. | CON:100 | yes | goodbye:canonical | PASS |
| game_story / game_story | I need the file inside the folder. | ORI:211 | yes | need:canonical, file:canonical, inside:canonical, folder:canonical | PASS |
| game_story / game_story | I need the file that is inside the folder. | ORI:211 | yes | need:canonical, file:canonical, inside:canonical, folder:canonical | PASS |
| game_story / game_story | I used the file. | instrumental_use_relation | no | used:structural, file:canonical | PASS |
| game_story / game_story | Delete the file. | requested_information_deletion | no | delete:structural, file:canonical | PASS |
| game_story / game_story | The files are being deleted. | active_information_deletion | no | files:canonical, deleted:structural | PASS |
| game_story / game_story | The files were deleted. | completed_information_deletion | no | files:canonical, deleted:structural | PASS |
| game_story / game_story | We need to migrate. | DAT:112 | yes | need:canonical, migrate:canonical | PASS |
| game_story / game_story | The files are migrating. | DAT:111 | yes | files:canonical, migrating:canonical | PASS |
| game_story / game_story | We migrated the files. | DAT:110 | yes | migrated:canonical, files:canonical | PASS |
| FEAST-CARRY / lore | Somebody has to begin. | ORI:100 | yes | somebody:phonemic_label, has:canonical, begin:canonical | PASS |
| FEAST-CARRY / lore | Please help the people who carry the meals. | LIF:211 | yes | help:canonical, people:canonical, who:phonemic_label, carry:phonemic_label, meals:documented_gap | PASS |
| FEAST-CARRY / lore | We are here together. | MOV:001 | yes | here:canonical, together:canonical | PASS |
| FEAST-CARRY / lore | I will help. | LIF:112 | yes | help:canonical | PASS |
| CURRENT-LISTEN / lore | I need the present route. | ORI:211 | yes | need:canonical, present:canonical, route:canonical | PASS |
| CURRENT-LISTEN / lore | The present route is here. | MOV:001 | yes | present:canonical, route:canonical, here:canonical | PASS |
| CURRENT-LISTEN / lore | We are moving together. | MOV:121 | yes | moving:canonical, together:canonical | PASS |
| CURRENT-LISTEN / lore | Keep listening for living people. | CON:111 | yes | keep:canonical, listening:canonical, living:canonical, people:canonical | PASS |
| ROOMS-BESIDE / lore | I preserved the objection. | LIF:120 | yes | preserved:canonical, objection:phonemic_label | PASS |
| ROOMS-BESIDE / lore | Keep my objection beside yours. | DAT:121 | no | keep:canonical, objection:phonemic_label, beside:phonemic_label, yours:phonemic_label | PASS |
| ROOMS-BESIDE / lore | I will keep it. | DAT:122 | no | keep:canonical | PASS |
| ROOMS-BESIDE / lore | Help me place this wall. | LIF:211 | yes | help:canonical, place:canonical, wall:phonemic_label | PASS |
| ARRIVAL-ASK / lore | I need the low-water gate. | ORI:211 | yes | need:canonical, low-water:phonemic_label, gate:phonemic_label | PASS |
| ARRIVAL-ASK / lore | You are at your destination. | MOV:010 | yes | destination:canonical | PASS |
| ARRIVAL-ASK / lore | No. My current position is your station. We need a live receiving exchange. | ORI:211 | yes | no:phonemic_label, current:canonical, position:canonical, station:phonemic_label, need:canonical, live:canonical, receiving:canonical, exchange:phonemic_label | PASS |
| ARRIVAL-ASK / lore | I will stay until you answer. | LIF:201 | no | stay:canonical, until:phonemic_label, answer:phonemic_label | PASS |
| TWO-DROPS-WAIT / lore | I found your home. | MIN:110 | yes | found:canonical, home:documented_gap | PASS |
| TWO-DROPS-WAIT / lore | Please do not clean it. | REP:111 | yes | not:structural, clean:canonical | PASS |
| TWO-DROPS-WAIT / lore | We need a safe route. | ORI:211 | yes | need:canonical, safe:documented_gap, route:canonical | PASS |
| TWO-DROPS-WAIT / lore | Wait and listen for the answer. | deferred_action | no | wait:structural, and:structural, listen:canonical, answer:phonemic_label | PASS |
| TWO-DROPS-WAIT / lore | The nursery arrived. | MOV:110 | yes | nursery:phonemic_label, arrived:canonical | PASS |
| TWO-DROPS-WAIT / lore | We are here. | MOV:001 | yes | here:canonical | PASS |

## Review decisions

- Preserve all 324 canonical root meanings and all 28 approved compounds. No automatic vocabulary expansion follows from corpus frequency alone.
- Keep affect, desire, ingestion, game measurements, and safety as documented gaps pending semantic design.
- Treat data deletion, waiting, crossing, return, and program execution as structural/IR routes until complete templates and role binding exist.
- Treat `pick up`, `back up`, file opening/saving/copying, and other unrepresented predicates as semantic gaps, never phonemic nouns.
- Block automatic interpretation of underspecified file change/movement across Matter, Data, Motion, and Structure; ask for context.
- User-reviewed local surface mappings can improve recognition but remain noncanonical and need explicit entailment and collision review.

## Failures

None.
