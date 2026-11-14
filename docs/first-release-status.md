# DBA translator first release

The browser translator makes music from supported English sentences and from words you build yourself. It includes 324 canonical roots, 63 approved compounds and 471 indexed senses. You can combine earlier compounds in the order you choose, mark the main meaning, and connect participants across the parts. Your definitions stay in your browser and can be exported and imported. [Open the translator](https://ragingaxolotl-art.github.io/era-zero-translator/) · [Open the compound builder](https://ragingaxolotl-art.github.io/era-zero-translator/compound-builder.html)

## Try a sentence

- Enter “I swim.” Choose whether you mean a recurring practice, an unfolding action, or one narrated episode. The choice affects the performed meaning.
- Enter “Pip carries the heavy box to Ada.” Choose the carrying viewpoint, whether Ada is the destination or receives custody, and what standard makes the box heavy.
- Enter “Pip helps Ada.” Select the active-care reading if Pip is protecting, nurturing or sustaining Ada. For a different kind of help, use the builder. Switching Pip and Ada exchanges the two roles in the music.
- Enter “A curious child.” The analyzer singles out the adjective. For the reading in which a particular child wants to know about something, supply a topic, for example “The child is curious about the map.” The translator asks you to confirm that reading.

Nouns and proper names can have phonemic labels. A verb or adjective needs a meaning. Runtime endings [0], [1], and [2] are independent of the trits in the dictionary address. You can negate an assertion at any runtime. Use neutral references with a specified referent in the supported pronoun constructions.

## Make a missing word

1. Enter your sentence and follow **Find or build this meaning** beside the missing word. Search for existing meanings first.
2. Choose the ordered parts and the main meaning. Enter what the new word means. For a verb, enter its base, third-person and past forms.
3. Add the participants the meaning requires. Use **Review participant connections** when an inner part and the whole describe the same participant.
4. Save and choose **Return to your sentence**. Translate, choose any participant roles that need clarification, and play the music. **Download MIDI** saves the performance. **Save meaning and definitions** includes the sentence and vocabulary needed to interpret it.

A saved word also appears as a component for the next word you build. The builder offers example sentences for verbs with participant roles and adjectives with a bearer.

## What was verified

In a browser, a new movement verb survived reloading. A second word reused that verb as an adjective and shared its mover. “Kira patternstrode. [0]” produced 165 scheduled tones with one mover and a past-time frame. “Nora might not be lifestriding. [2]” scheduled 280 tones with the nested adjective, possibility and negation. Editing the sentence cleared the old result. Play and Stop were exercised with Web Audio.

A second browser walkthrough started with “The routine opened the path,” a line from the Still Room manuscript. Its missing verb led to the builder. We defined one communication sense of *open* from completed distinct actualization and active shared channel. Returning to the original sentence preserved the routine as actor, the path as target, and past time. Playback scheduled 160 tones. This was a worked interpretation of one story line. [Story source](https://github.com/ragingaxolotl-art/cyber-pet-lore/blob/main/sources/haven-stories/still/manuscript.md)

Automated checks exercise MIDI note and timing contrasts, role reversal, nested meanings, JSON library export/import and the exact bytes supplied to export controls. The browser declined the download permission during the live session, so saving a file on that device was not verified. [Compound tests](../reports/local_compound_release.json) · [Translator tests](../reports/translator_completion_regression.json)

## Remaining limits

English support is construction-based. New definitions extend the vocabulary available in those constructions. Arbitrary multi-clause prose, unrestricted plural reference, and many adjective–noun fragments still need more grammar. The site shows partial dictionary readings when it cannot compose a whole sentence. The first release covers text to meaning to music. Recovery from a speaker-to-microphone recording and wider independent English testing remain future work. [Project history and original completion plan](translator-completion.md)
