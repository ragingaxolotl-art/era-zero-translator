# Recorded-audio completion requirement and first transport experiment

User requirement: message → meaning → generated audio → recovered meaning, with
no original English, source IR, expected notes, or hidden semantic metadata given
to the decoder. Physical speaker-to-microphone recordings are required before
claiming that channel works. Existing vocabulary and grammar remain authoritative.

## Existing evidence and gap

`performance_audio.mjs` synthesizes reference PCM and segments tones, but
`verifyPerformancePcm(formal, registry, ...)` compares observations with a supplied
formal performance. This proves score verification for its sampled synthetic
waveforms, not blind semantic recovery. Strict MIDI inverses already reconstruct
roles and scopes; their inputs have exact pitch/timing and bypass the acoustic
channel. Optional recognition phrases supply root-identity checksums, not a
whole-message blind audio decoder.

## Selected experiment

`tools/acoustic_transport.py` reuses the existing strict monophonic MIDI notes and
quarter-beat timing grid. It adds a four-tone audible pitch/clock preamble, 40 ms
articulation gaps, and an eight-tone CRC32 trailer. The trailer checks recovered
pitch, duration and rest tuples. Neither the WAV header nor any sidecar contains
meaning. Decode accepts a WAV pathname only. Shared protocol and dictionary
knowledge are allowed; a particular expected message is not.

- **Rhythm and boundaries:** retain current duration/register/scope meanings.
  Explicit gaps let repeated identical pitches be segmented. Audible long gaps
  separate calibration, payload, and checksum. This is an optional transport
  presentation, not a replacement for current melodies or grammar.
- **Calibration:** estimate tuning, tempo and articulation gap from the audible
  preamble rather than requiring exact playback clock and tuning.
- **Redundancy:** CRC32 provides whole-stream error detection. It is not correction,
  authentication, semantic truth, or a guarantee against every possible collision.
  Reject uncertain or damaged recordings rather than fabricate a likely sentence.
- **Participant motifs:** existing name sounds, registers, role delimiters and
  reference-mode markers are reused. No extra motifs yet; no demonstrated need.
- **Chords:** deferred. Current parser is monophonic; polyphonic separation adds
  a new failure source without evidence of improved message recovery.
- **Additional error correction:** deferred until measured physical channel errors
  establish whether repetitions or a correction code improve reliability enough
  to justify their duration and complexity.

This baseline uses sine tones, not an arbitrary instrument/timbre recognizer.
It does not alter the existing audio player or silently insert checksum notes
into the standard strict MIDI decoder. Optional recognition phrases are not
included in this experimental transport. The recovered strict stream goes through
existing structural and predicate-specific semantic validation.

## End-to-end test and use

Run `node tests/acoustic_transport_test.mjs` with the project's Node binary and
Python containing NumPy/SciPy. The test composes English into existing semantic
IR, renders existing MIDI, generates ordinary mono PCM WAV, launches a separate
WAV-only decoder, reconstructs strict timing, and checks the independently
recovered meaning. It exercises care direction, negation/past, runtime 0/1/2,
swimming, possibility, and permission-over-negation scope. Expected meanings
exist only on the test assertion side. Decoder selection tries supported shared
profiles; it receives no hint naming the source sentence or predicate.

`node tools/decode_recorded_audio.mjs recording.wav` accepts mono 16-bit PCM WAV
and prints recovered meaning or rejects. Current semantic dispatcher reuses 14 existing full-message inverse functions; unsupported predicates reject even if transport
notes decode. This is not broad translator completion.

`reports/acoustic_transport_probe.json` records current generated-audio and
synthetic-channel results. Noise/gain, 2% playback-speed change, weak short echo,
and payload dropout are simulated; they must never be labeled microphone results.
Physical capture is pending an available speaker/microphone workflow. No capture
was performed by this experiment. Playback files are retained at reported temporary
paths for a subsequent physical recording session.

## Completion integration

Keep the original seven completion gates open. Add blind acoustic recovery to
meaning/music validation: supported full messages must preserve participants,
relationships, time, negation, uncertainty, runtime and scope through the channel.
Expand predicate inverse coverage alongside English composition. Maintain a
held-out recording corpus with known source meaning kept on the evaluation side,
multiple devices, distances/levels, noise/reverberation, and explicit rejection
rates and undetected meaning errors. Separate synthetic, cable/loopback and
speaker-to-microphone evidence. Only integrate a transport feature into default
playback after its benefits, costs and compatibility are demonstrated.

## Measured initial result

Ten clean synthetic full-message cases recovered exactly. Thirty channel cases
(three transformations per message) recovered the original note/timing stream
exactly; all ten payload-dropout cases rejected. Physical microphone recordings:
zero. These ten authored examples are not held-out or representative coverage.
The calibration/trailer and gaps increase playback time; compare that cost against
measured physical-channel reliability before choosing default presentation.

The expanded probe also preserves question and command contours, running,
spatial reference modes, and custody acquisition. `tools/audio_capture/` provides
a local browser recording harness which exports mono PCM WAV without uploading
audio. It requests microphone access only after Start is pressed. Its JavaScript
syntax has been checked; live browser/capture behavior remains unverified.

## Cognitive draft audio integration

The same WAV-only command now accepts `--allow-draft` to load the existing
reviewed candidate registry and try the existing foundation/acquisition semantic
inverse. Without that option, draft meanings remain rejected. No new cognitive
root, compound or meaning is introduced by this transport integration.

`tests/cognitive_acoustic_test.mjs` exercises demonstrative preference direction,
desired swimming with an explicit actor, outer and embedded negation in polar
knowledge, and yesterday's learned-whether event. It compares recovered meanings
with the existing independent semantic inverse on the evaluator side; the decoder
receives only a WAV path and the explicit draft flag. Results are recorded in
`reports/cognitive_acoustic_probe.json`. Physical-channel validation remains open.

The first learned-whether clean-audio test failed at a short MIDI-28 grammar
tone: zero-crossing energy dips split the tone into a measured 0.560 timing unit.
The segmenter now bridges only internal energy holes at most 12 ms long, shorter
than the intentional 40 ms articulation gap. Pitch and timing rejection tolerances
were not relaxed. A dedicated 92-case sweep covers MIDI 26–48 at four durations;
all recover exactly. The four cognitive messages subsequently pass clean blind
WAV decoding. Synthetic channel outcomes are recorded separately in their report.
