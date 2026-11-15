# DBA translator field repairs

The translator recovered the intended meaning of all 51 sentences from the field audit and all 18 fresh examples. The original audit recovered 20 of 51. All nine manuscript lines in this set now produce complete, decodable music. [Original audit](translator_field_audit.md) · [Case-by-case readings and durations](field_repair_acceptance.json)

| Set | Direct reading | After a clarification | Different or incomplete reading |
| --- | ---: | ---: | ---: |
| Original 51 | 43 | 8 | 0 |
| Fresh 18 | 15 | 3 | 0 |

The English and intended reading were recorded before changing the grammar. Each browser trial used the ordinary sentence box, **Add to song**, and both MIDI downloads. The listener received the downloaded music and the public language. The grader independently checked the participants’ sounds, their roles, adjective attachment, scope, time, quantity, requested action, and relations relevant to that input. All 69 compact arrangements expanded to the original pitches and timing. [Original intentions](../tests/field_audit/intentions.json) · [Fresh intentions](../tests/field_audit/repair_reserve.json) · [Grading checks](../tools/grade_field_repairs.mjs)

## Putting a sentence into a song

Enter **We need to resolve the redundancy error.** and analyze it. The whole sentence can go straight into **Your song**. Its recorded meaning says the speaker’s group needs to correct a redundancy fault. Successful correction remains open. The melody lasts 31 seconds and the compact version lasts 25.5 seconds. [Try this sentence](https://ragingaxolotl-art.github.io/era-zero-translator/?text=We%20need%20to%20resolve%20the%20redundancy%20error.)

For **The gate reopened.**, the song starts by identifying the gate. The first root chord enters 16.25 seconds into a 39.125-second compact line. **Hear first root in chords** skips there. Change **Song arrangement** to **Original melody** and use the same button to compare that root. **Hear next root** steps through the actual roots of the song. **Check musical meaning** reads a saved line’s selected arrangement and displays the recovered participants and scopes. Some saved word sketches can play without yielding one sentence meaning. [Try the gate](https://ragingaxolotl-art.github.io/era-zero-translator/?text=The%20gate%20reopened.) · [Hear the gate root in both arrangements](field-audit-gate-comparison.wav)

## What changed

- Each saved line has its own persistent ID. Two tabs can add lines simultaneously or remove an individual line, and both tabs converge after reload. A song saved with the earlier one-list format still opens. The workbench tabs support arrow keys, Home and End.
- A few is a small unspecified group. An explicit plural noun restricts that group, and nobody selects zero people. Names and programs can be discourse participants. When both Latch and a result fit “it,” the author chooses the referent. For a load that could be work, the author can choose physical carrying or handing work onward.
- The displayed reading follows the same nested operators as the music. “We don’t need to delete the program” denies the requirement. “We need to not delete the program” requires refraining from deletion. The software-file and resumed-meeting readings now have their own choices and sounds.
- Questions, actor-caused reopening, repeated inspection, alternatives, open conditions and creation for a recipient reuse earlier words and role markers. In “Then I don’t know what else you want,” the speaker is the knower and the listener is the one who wants something. The embedded question asks for the identity of the additional wanted thing.
- A release check caught the time meaning of *follow* outranking path tracking in “Follow the route.” The dictionary now considers the object of the verb. The partial-word lookup also requires the complete wording of multiword entries such as *open for use*. Using a file and opening a physical passage have distinct readings. “Follow a marked trail” selects tracking and “An adjustment followed” selects temporal sequence.
- The dictionary retains all 324 atoms, all 82 previous compounds and all 509 previous English sense records. Sixteen compounds brought the totals to 98 compounds and 541 senses. Checking precedes checking again, validity precedes remaining valid, and requesting and completion precede requesting completion. The compact arranger still uses one three-note family chord, one three-note address chord, and a moving upper voice for the runtime ending. All 972 root and runtime combinations remain distinct. [Vocabulary batch](../lexicon/story_compound_batch.json) · [Chord checks](../tests/compact_song_chords_test.mjs)

## What the microphone recovered

We rendered the actual bottom **Play song** control using its default Era Zero voice, then played that audio through the MacBook Pro speakers and recorded the built-in microphone at 48 kHz. The listener received a WAV and the public grammar, with no sentence, score, candidate list or semantic metadata. We compared the recovered notes, note timings and meaning with the compact MIDI only after decoding.

| Room recording | Ending | Compact notes recovered exactly | Use |
| --- | ---: | ---: | --- |
| I am not moving. | 1 | 76 | Tuning |
| We need to fix the checksum error. | 1 | 84 | Tuning |
| The gate reopened. | 2 | 216 | Held out |
| I am not moving. | 0 | 76 | Held out |

The first two recordings exposed weak bass through the laptop speakers. The listener uses upper harmonics and measured background noise to recover faint notes. It requires one complete performance under the public grammar. Both held-out recordings were made after the listener was fixed. The four clean browser WAVs also passed. A truncated clip and a silent clip were rejected. The room captures stayed local. [Measurements and note checksums](field_repair_room_audio.json)

These trials cover one laptop, one room, the reference voice, a single song line, and the browser’s fixed tempo. The WAV listener runs from the repository. The website’s **Check musical meaning** reads saved notes. Crowded rooms, other instruments, singers and physical iPhone playback still need separate tests.

The retained implementation suite passed 277 checks, including its clean acoustic tests. The Lore suite passed 176 checks. The four existing choir arrangements also revalidated against the updated translator, covering all 168 phrases and 24 sentence verses across 12 voices. [Implementation checks](field_repair_regression.json) · [Choir validation](https://github.com/ragingaxolotl-art/cyber-pet-lore/blob/main/site/songs/voices-chords/language-validation.json)

## Reproducing the checks

With the site running locally, use a Chromium/Playwright installation for the browser tests and NumPy and SciPy for recorded WAVs.

```sh
FIELD_REPAIR_AUDIT=1 node tools/audit_translator_field.mjs http://127.0.0.1:8000/ /tmp/dba-field-repairs 390
node tools/grade_field_repairs.mjs /tmp/dba-graded.json /tmp/dba-field-repairs/observations.json
node tools/audit_translator_workflows.mjs http://127.0.0.1:8000/ /tmp/dba-workflows
node tests/field_repair_regression.mjs
node tools/decode_compact_recording.mjs recording.wav
node tools/verify_compact_recording.mjs recording.wav exported-compact-line.mid
```

This is a targeted sentence set. Other recorded examples still expose gaps, including “It kept the path open,” “I found Aru in the seventy-third room,” and “Have you seen both versions?” They require result-state maintenance, precise location, and both-version quantification in those constructions. [Earlier corpus and intentions](../tests/story_followup_intentions.json) · [Current initial results](story_followup_current_initial.json) · [Current reserve results](story_followup_current_reserve.json)
