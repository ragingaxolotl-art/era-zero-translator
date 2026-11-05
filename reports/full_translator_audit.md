# Full Translator Phrase, Dictionary, and Document Audit

Status: **PASS**

- Checks passed: **93**
- Checks failed: **0**
- Phrase cases: **75**
- Dictionary roots: **324**
- Compounds: **32**
- Indexed senses: **440**
- Public document records: **350**

## Phrase matrix

| Phrase | Primary result | Auto | Runtime | Speech act | Word handling | Status |
|---|---|---:|---:|---|---|---|
| Go home. | MOV:121 | yes | 1 | command | go:canonical, home:documented_gap | PASS |
| Go offline. | abstract_transition | no | 1 | command | go:canonical, offline:phonemic_label | PASS |
| Send the file. | DAT:111 | yes | 1 | command | send:canonical, the:function_word, file:canonical | PASS |
| Send the message. | CON:101 | yes | 1 | command | send:canonical, the:function_word, message:canonical | PASS |
| Receive the data. | DAT:110 | yes | 1 | command | receive:canonical, the:function_word, data:canonical | PASS |
| Receive the warning. | CON:111 | yes | 1 | command | receive:canonical, the:function_word, warning:phonemic_label | PASS |
| Change my mind. | MIN:101 | yes | 1 | command | change:canonical, my:participant_reference, mind:phonemic_label | PASS |
| Change the file. | DAT:101 | no | 1 | command | change:canonical, the:function_word, file:canonical | PASS |
| Change the layout. | STR:101 | yes | 1 | command | change:canonical, the:function_word, layout:canonical | PASS |
| Run the program. | program_execution | no | 1 | assertion | run:structural, the:function_word, program:canonical | PASS |
| Run the engine. | machine_operation | no | 1 | assertion | run:structural, the:function_word, engine:phonemic_label | PASS |
| Run home. | locomotion | no | 1 | assertion | run:structural, home:documented_gap | PASS |
| Return a value. | function_result | no | 1 | command | return:structural, a:function_word, value:phonemic_label | PASS |
| Return home. | movement_to_prior_position | no | 1 | command | return:structural, home:documented_gap | PASS |
| I am leaving home now. | MOV:101 | yes | 1 | assertion | i:participant_reference, am:function_word, leaving:canonical, home:documented_gap, now:function_word | PASS |
| I left home. | MOV:100 | yes | 1 | assertion | i:participant_reference, left:canonical, home:documented_gap | PASS |
| Approach the bridge. | MOV:111 | yes | 1 | command | approach:canonical, the:function_word, bridge:phonemic_label | PASS |
| She arrived at the station. | MOV:110 | yes | 1 | assertion | she:participant_reference, arrived:canonical, at:function_word, the:function_word, station:phonemic_label | PASS |
| Create a tool. | CRE:111 | yes | 1 | command | create:canonical, a:function_word, tool:canonical | PASS |
| Break the machine. | WRN:111 | yes | 1 | assertion | break:canonical, the:function_word, machine:canonical | PASS |
| Fix the machine. | REP:111 | yes | 1 | command | fix:canonical, the:function_word, machine:canonical | PASS |
| Repair the machine. | REP:110 | yes | 1 | command | repair:canonical, the:function_word, machine:canonical | PASS |
| Are they approaching the bridge? | MOV:111 | yes | 1 | question | are:function_word, they:participant_reference, approaching:canonical, the:function_word, bridge:phonemic_label | PASS |
| I am not moving. | MOV:121 | yes | 0 | assertion | i:participant_reference, am:function_word, not:structural, moving:canonical | PASS |
| Maybe go home. | MOV:121 | yes | 1 | possibility | maybe:function_word, go:canonical, home:documented_gap | PASS |
| Wait here. | deferred_action | no | 1 | command | wait:structural, here:canonical | PASS |
| Stop moving. | MOV:121 | yes | 1 | command | stop:structural, moving:canonical | PASS |
| Continue moving. | MOV:121 | yes | 1 | command | continue:structural, moving:canonical | PASS |
| Cross the bridge. | boundary_traversal | no | 1 | command | cross:structural, the:function_word, bridge:phonemic_label | PASS |
| Follow the route. | trajectory_tracking | no | 1 | command | follow:structural, the:function_word, route:canonical | PASS |
| Transport the box. | caused_target_movement | no | 1 | assertion | transport:structural, the:function_word, box:phonemic_label | PASS |
| Zibble frobnates quux. | phonemic labels only | no | 1 | assertion | zibble:phonemic_label, frobnates:unresolved_semantic, quux:phonemic_label | PASS |
| Go home with zibble. | MOV:121 | yes | 1 | command | go:canonical, home:documented_gap, with:function_word, zibble:phonemic_label | PASS |
| Please send the data. | DAT:111 | yes | 1 | command | please:function_word, send:canonical, the:function_word, data:canonical | PASS |
| Could you send the message? | CON:101 | yes | 1 | question | could:function_word, you:participant_reference, send:canonical, the:function_word, message:canonical | PASS |
| The route is active. | MOV:020 | yes | 1 | assertion | the:function_word, route:canonical, is:function_word, active:canonical | PASS |
| A dormant machine. | CMP:e152ea538409460a93b99b90 | no | 1 | assertion | a:function_word, dormant:canonical, machine:canonical | PASS |
| A physical tool. | CMP:111b772027accab2054f0415 | yes | 1 | assertion | a:function_word, physical:canonical, tool:canonical | PASS |
| A message datum. | CMP:608ecb4f3c515a9c9a3443ec | yes | 1 | assertion | a:function_word, message:canonical, datum:canonical | PASS |
| A backup dataset. | CMP:33c135410b0deef525b6770d | yes | 1 | assertion | a:function_word, backup:canonical, dataset:canonical | PASS |
| A shared knowledge base. | CMP:44173561806bc8f334a0b7c9 | yes | 1 | assertion | a:function_word, shared:canonical, knowledge:canonical, base:canonical | PASS |
| A material hazard. | CMP:cb0812face56f90b7ba139c5 | yes | 1 | assertion | a:function_word, material:canonical, hazard:canonical | PASS |
| Food. | nutritive_material | no | 1 | assertion | food:documented_gap | PASS |
| Water. | chemical_substance | no | 1 | assertion | water:documented_gap | PASS |
| Friend. | social_friendship | no | 1 | assertion | friend:documented_gap | PASS |
| Safe. | acceptable_risk | no | 1 | assertion | safe:documented_gap | PASS |
| Think. | generic_cognition | no | 1 | command | think:documented_gap | PASS |
| True. | truth_value | no | 1 | assertion | true:documented_gap | PASS |
| Know. | truth_entailing_knowledge | no | 1 | assertion | know:canonical | PASS |
| Have. | perfect_auxiliary | no | 1 | question | have:canonical | PASS |
| Change. | generic_state_transition | no | 1 | command | change:canonical | PASS |
| Send. | DAT:111 | no | 1 | command | send:canonical | PASS |
| Receive. | CON:111 | no | 1 | command | receive:canonical | PASS |
| Share. | DAT:121 | no | 1 | command | share:canonical | PASS |
| Return. | function_result | no | 1 | command | return:structural | PASS |
| Run. | locomotion | no | 1 | assertion | run:structural | PASS |
| What is a route? | MOV:020 | yes | 1 | question | what:canonical, is:function_word, a:function_word, route:canonical | PASS |
| A route means an ordered path. | MOV:020 | no | 1 | definition | a:function_word, route:canonical, means:unresolved_semantic, an:function_word, ordered:phonemic_label, path:canonical | PASS |
| They may approach the destination. | MOV:112 | yes | 1 | possibility | they:participant_reference, may:function_word, approach:canonical, the:function_word, destination:canonical | PASS |
| Go home [0]. | MOV:121 | yes | 0 | command | go:canonical, home:documented_gap | PASS |
| Go home [1]. | MOV:121 | yes | 1 | command | go:canonical, home:documented_gap | PASS |
| Go home [2]. | MOV:121 | yes | 2 | command | go:canonical, home:documented_gap | PASS |
| Go, home! | MOV:121 | yes | 1 | command | go:canonical, home:documented_gap | PASS |
| GO HOME. | MOV:121 | yes | 1 | command | go:canonical, home:documented_gap | PASS |
| Send the file to zibble. | DAT:111 | yes | 1 | command | send:canonical, the:function_word, file:canonical, to:function_word, zibble:phonemic_label | PASS |
| Change the data and send the message. | CON:101 | no | 1 | command | change:canonical, the:function_word, data:canonical, and:structural, send:canonical, the:function_word, message:canonical | PASS |
| Zibble zibble. | phonemic labels only | no | 1 | assertion | zibble:phonemic_label, zibble:phonemic_label | PASS |
| The zibble is moving. | MOV:121 | yes | 1 | assertion | the:function_word, zibble:phonemic_label, is:function_word, moving:canonical | PASS |
| Do not send the message. | CON:101 | yes | 0 | question | do:function_word, not:structural, send:canonical, the:function_word, message:canonical | PASS |
| Will they arrive? | MOV:110 | yes | 1 | question | will:function_word, they:participant_reference, arrive:canonical | PASS |
| Create the material artifact. | CRE:111 | yes | 1 | command | create:canonical, the:function_word, material:canonical, artifact:canonical | PASS |
| Restore the backup dataset. | CMP:33c135410b0deef525b6770d | yes | 1 | assertion | restore:canonical, the:function_word, backup:canonical, dataset:canonical | PASS |
| Move the object. | MOV:121 | yes | 1 | command | move:canonical, the:function_word, object:canonical | PASS |
| The program is dormant. | CMP:9e8b36f50570a0c3c362a968 | yes | 1 | assertion | the:function_word, program:canonical, is:function_word, dormant:canonical | PASS |
| The body is active. | CMP:3122dedcff0f85ad293e2580 | yes | 1 | assertion | the:function_word, body:canonical, is:function_word, active:canonical | PASS |

## Non-phrase checks

- **PASS** — underspecified file change requires domain clarification
- **PASS** — 324 canonical dictionary roots
- **PASS** — 12 complete 27-root families
- **PASS** — all generated root fields available
- **PASS** — complete compound records
- **PASS** — complete indexed dictionary options
- **PASS** — document manifest count is exact: 350 records
- **PASS** — every document path exists
- **PASS** — required authority documents are public
- **PASS** — all evidence categories available
- **PASS** — conversation and integrated document linked
- **PASS** — three-view workbench
- **PASS** — word match selectors and overrides
- **PASS** — dictionary inspector exposes generated fields
- **PASS** — document browser is searchable
- **PASS** — audio engine resumes before playback
- **PASS** — phonemic labels deterministic
- **PASS** — phonemic label has audible framed sequence

## Boundary

A word-level recommendation is not a new canonical meaning. Grammar and Semantic-IR routes remain structural, explicit gaps remain gaps, English-only function words make no lexical claim, and EZNAME remains a nonsemantic label channel.
