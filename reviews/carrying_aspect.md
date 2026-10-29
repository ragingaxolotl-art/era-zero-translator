# Carrying viewpoint, tense and runtime

The semantic IR already declared aspect independently of time and lexical state,
but sound rendering rejected every aspect operator. The new EZASPECT-1 profile
implements bounded, ongoing and habitual viewpoint using paired ±22 grammar
frames. No root, family or compound definition changes.

“Pip is carrying the box” now explicitly uses ongoing viewpoint. “Pip was carrying
the box” adds past time to that same viewpoint. “Pip carried the box” instead
presents a bounded episode before speech time. It does not assert arrival,
delivery, successful completion of a goal, or that carrying never continued in
another episode. The existing carrying process is interpreted within the episode;
MOV:121 is not silently replaced with completed arrival MOV:110.

“Pip habitually carries the box” describes a recurring practice, without inventing
a count, cadence, schedule, or actual carrying at this instant. “Pip does not
habitually carry the box” negates the habit; it is distinct from habitual refraining.
Past habitual statements and the corresponding did/do/does questions use the same
compositional representation. Supported toward-destinations and a single explicitly
standardized heavy/light noun restriction remain attached to their participants.

All three runtime states remain independent. In particular, habitual is not runtime
2, past is not runtime 0, and bounded is not the third lexical trit 0. The numerical
codes inside a grammar frame are local frame identifiers, not state conversions.
Ordinary carry commands do not become grammatically progressive merely because
the parser internally reuses a progressive verb template.

The new English progressive frame deliberately changes newly composed utterance
identities and audio. Existing IR still renders as before, and the static dictionary
forms and root melodies remain unchanged. This migration is documented rather than
represented as byte-compatible new English output.

Tests cover 45 sentence/state combinations, Ruby/browser formal and MIDI parity,
questions, past time, modality, noun restrictions, inverse scope observation and
negation/habitual order contrasts. Nine controlled aspect/state combinations ensure
aspect is audible even without participant roles. Invalid aspect fields and aspect
over a noun reference are rejected. General semantic inverse and listening review
remain separate completion requirements.

Bare “carries” is still unresolved: it may be habitual or a single narrated event.
“Carried … to Ada” additionally needs destination culmination semantics. Perfect,
prospective, scheduled repetition and broad ordinary tense coverage remain open.
These requirements still belong to the mandatory carrying milestone.
