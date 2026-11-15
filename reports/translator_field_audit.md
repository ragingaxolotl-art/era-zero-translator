# What happens when you put an English line into a DBA song?

The subsequent repair release retested these 51 inputs and 18 fresh examples and played four recordings through a speaker and microphone. [Repair results](translator_field_repairs.md)

The bottom song selector had a playback bug. In 13 of 26 test lines that produced a whole score, choosing **Compact chords** played exactly the same pitches at the same times as **Original melody**. Some approved compounds join multiple roots without a rest. The chord arranger used the rests to find roots and skipped those joins. It now reads the boundaries already present in the musical grammar.

## Hear the difference

Add “The gate reopened.” to **Your song**. Choose **Original melody** and press **Hear first root as a melody**. Then choose **Compact chords** and press **Hear first root in chords**. The button plays the first dictionary root of your own song immediately. Use **Play song** to hear the selected arrangement from the beginning. The whole line introduces the gate before reaching its first root. A second pair of buttons by the text box compares the root for “care” on an empty song. [Try the gate sentence](https://ragingaxolotl-art.github.io/era-zero-translator/?text=The%20gate%20reopened.) · [Hear care](https://ragingaxolotl-art.github.io/era-zero-translator/#chord-preview)

| Whole song played through the bottom menu | Original melody | Previous compact | Corrected compact | First chord now | Three-note attacks now |
| --- | ---: | ---: | ---: | ---: | ---: |
| The gate reopened. [1] | 51.625 s | 51.625 s | 39.125 s | 16.250 s | 10 |
| We need to resolve the redundancy error. | 31 s | 25.5 s | 25.5 s | 5.250 s | 4 |
| Pip spotted a cracked and faulty bell and repaired it. | 108 s | 105 s | 82 s | 26.250 s | 20 |

The actual browser oscillator onsets and pitches matched both downloaded arrangements for these three lines. We also rendered the browser synthesizer to audio samples. The first root of the gate example started with C4 alone in the melody and C4, F4 and G4 together in chords. Its second attack was F4 alone versus C4, G4 and C5 together. The complete isolated root sounded for 3.655 seconds in melody and 1.159 seconds in chords. The first chord of “care” was C4, E4 and G4. The short audio clip plays the gate root as a melody, pauses, and plays the same root in chords. [Hear the comparison](field-audit-gate-comparison.wav)

The first three-note group carries the family and the second group carries the dictionary address. A moving upper voice carries the runtime ending. All 324 roots in all three runtime states yielded 972 distinct performances. Each expanded to its original notes and timing. Compact mode shortened 20 of the 26 whole scores compared with the previous compact version. All 26 now contain chords and recover their original melodic events. Names and grammatical markers can still take up much of a sentence. [Musical regression](../tests/compact_song_chords_test.mjs) · [Measurements and recovered meanings](translator_field_audit.json)

## What the translator understood

We wrote down the intended participants, action, time and scope before entering each line. We tested the public translator in a 390-pixel Chrome viewport, repeated 14 inputs on the Lore version at 1280 pixels, and repeated all 51 inputs against the corrected translator. We used the actual **Add to song** and **Download song MIDI** controls. An independent decode step received the musical notes and shared public language only. We compared recovered meaning with the written intention, including cases where we explicitly answered a question. Word sketches counted as incomplete. These inputs were chosen to expose specific problems. Their proportions describe this test set. [Recorded intentions](../tests/field_audit/intentions.json) · [Case-by-case results and manuscript citations](translator_field_audit.json)

| Inputs | Meaning recovered directly | Recovered after a question | Wrong meaning selected | Other score without a unique inverse | No complete score for this meaning |
| --- | ---: | ---: | ---: | ---: | ---: |
| 6 buttons on the home page and 3 earlier failures | 2 | 0 | 3 | 1 | 3 |
| 33 targeted variations | 17 | 1 | 0 | 2 | 13 |
| 9 additional lines from 3 manuscripts | 0 | 0 | 0 | 0 | 9 |
| **All 51** | **19** | **1** | **3** | **3** | **25** |

The chord fix preserved the outcome of every musical reading. Of 26 whole scores, four had no unique interpretation in the general MIDI listener. One of those four, “Latch carried the handoffs,” also chose physical transport for an intended work handoff. The table counts it once under wrong meaning. Two declined readings, opening a file and resuming a meeting, correctly allowed the author to reject a passage becoming traversable. All nine fresh story lines lacked a complete score for their intended meaning, including “The worker requested completion” and “The result remained valid.” [Manuscript passage](https://github.com/ragingaxolotl-art/cyber-pet-lore/blob/d54de4961f6ec5462beab6a17ae99ba29bdad0e5/sources/haven-stories/interval/manuscript.md#L53)

Gender-neutral participants, paired adjectives, a name with a number, the distinction between *before* and *after*, and all three runtime endings survived in tested constructions. The MIDI distinguished “We don’t need to delete the program” from “We need to not delete the program.” Their on-screen summaries used the same action label. The negative reopening case also failed its separate requirement that the screen show the denial. The table grades the recovered music.

## Fixes in priority order

| Priority | Reproduction and impact | Next change and acceptance test |
| --- | --- | --- |
| 1. Protect saved songs | Open the translator in two tabs. Add “The gate reopened” in the first and “The path was open” in the second. Reload. Only the second line survives. | Give lines persistent IDs and merge saved edits across tabs. Test concurrent adds, removals, old saves and a reload. Keep both additions exactly once and honor a deliberate removal. |
| 2. Prevent wrong translations | “A few waited” scored a single participant named *few*. “Latch found the result. It found the context” made the result the second finder. Computational handoffs became a physical load. | Recognize small unnumbered groups, offer the plausible referents for *it*, and ask about physical versus computational carrying. Until a sense has a score, allow an explicit gap. Test the contrasting readings on new subjects and objects. |
| 3. Make the explanation trustworthy | “Pip did not spot a cracked bell” and “Pip might not spot a cracked bell” both display “Noticed something by sight.” A changed modal or negation can reverse the author’s message. | Generate the explanation from the scoped meaning the composer sends to music. Test positive, negative, uncertain, nested-necessity and past readings against both the displayed wording and the decoded score. |
| 4. Connect the composer to the general listener | “Mira repaired Pip,” the reverse, and “She arrived at the station” after identifying Mira can be added to a song. The general listener gives no unique interpretation. | Inspect what the existing note grammar can distinguish. Cover both role orders, arrival, and genuine ambiguity using only exported notes. Show separately when a score is playable and when its meaning has been recovered. |
| 5. Use familiar words in more sentence forms | A pasted newline breaks the two-sentence routine example. Lowercase “pip” loses a reading. “Did Pip spot the gate?” offers 22 suggestions while the visual-sighting meaning already works in a statement. “The pilot reopened the gate” lacks its two-participant change. | Normalize harmless whitespace, ask about a lowercase name when needed, and apply existing predicates across questions and actor/target forms. Test statement, question and negation on the same unfamiliar subject. Offer only senses that can fill the required roles. |
| 6. Extend the story vocabulary from simpler meanings | The new manuscript lines expose missing continuation, repeated checking, validity, requesting completion and an ability with a recipient. The similar “fix the duplicate error” also fails where the redundancy example succeeds. | Establish checking, validity, completion and requesting first. Reuse them for *check again*, *remain valid* and *request completion*. Compare each with existing entries before proposing a root. Reserve fresh story lines for the subsequent test. |

## Editing and listening

On one tab a two-line song survived reload in order, removing a line worked, and changing the input hid the previous **Add to song** action. We built a two-part verb with participant roles, reloaded it, exported it and imported it in a fresh browser profile. Dictionary lookup returned the approved reopening compound. The six-turn conversation demo identified its prepared lines as dictionary motifs and enabled playback. The app tabs still lack left/right arrow navigation. The mobile layout now fits both 320- and 390-pixel viewports. It previously extended to 494 pixels on both. [Workflow checks](../tools/audit_translator_workflows.mjs)

Two small additions would directly help authors. A **next dictionary root** playback control could let someone hear successive words inside a long passage. A **who does “it” refer to?** choice could show the named participants next to the sentence before an author adds it to a song. Neither requires changing the language’s pitches.

The four compact choir arrangements were regenerated. Verification covered 168 phrases across 12 voices, including 24 sentence verses. Each solo phrase expanded to its original translator performance, and every ensemble MIDI track matched its solo. Spectral checks on the lossless voice recordings tested pitches, rests and clipping. The 16 AAC files opened with the expected durations. [Hear the four songs](https://ragingaxolotl-art.github.io/cyber-pet-lore/songs/?edition=chords) · [Music verification](https://github.com/ragingaxolotl-art/cyber-pet-lore/blob/main/site/songs/voices-chords/language-validation.json) · [Voice audio checks](https://github.com/ragingaxolotl-art/cyber-pet-lore/blob/main/site/songs/voices-chords/audio-validation.json)

The retained implementation suite passed all 250 checks on the corrected runtime. Five additional clean synthesized monophonic WAV fixtures recovered their intended story meaning. The browser waveform test measured chord pitches. Blind recognition of a polyphonic recording, recovery from a speaker and microphone, and physical iPhone Safari playback remain unverified. [Release tests](translator_completion_regression.json) · [Clean-WAV cases](../tests/story_acoustic_test.mjs) · [Browser waveform diagnostic](../tools/audit_chord_waveform.mjs)

## Reproduce

Serve the generated pages from a local web server. Use Node 22 or newer and Playwright with a Chromium browser. The browser diagnostics accept PLAYWRIGHT_MODULE and CHROME_PATH for installations outside the project. Supply a new output directory for each run.

```sh
node tools/audit_translator_field.mjs http://127.0.0.1:8000/ /tmp/dba-english-field 390
node tools/audit_song_playback.mjs http://127.0.0.1:8000/ /tmp/dba-song-playback
node tools/audit_chord_waveform.mjs http://127.0.0.1:8000/ /tmp/dba-waveforms
node tools/audit_translator_workflows.mjs http://127.0.0.1:8000/ /tmp/dba-workflows
node tests/compact_song_chords_test.mjs
```
