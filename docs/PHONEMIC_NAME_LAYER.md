# Experimental phonemic name layer

`EZNAME-0.1` gives an unfamiliar noun or proper name a reproducible sound label without pretending that the label is an approved Era Zero meaning.

The browser estimates a phoneme sequence from the spelling. The user can correct that sequence before generation. Each phoneme has a unique two-note code between an unmistakable start and end frame. The same label, phonemes, and object tag always produce the same sound ID and MIDI bytes.

An optional object tag distinguishes particular referents. For example, two objects both called “zibble” can use `blue-zibble-2` and `red-zibble-1`. This distinction is an identifier supplied by the user, not an assertion that the objects differ in any canonical semantic property.

## Nonsemantic boundary

- An EZNAME label does not create a root, definition, compound, or English-sense entry.
- It does not enter canonical EZF identity or replace canonical semantic MIDI.
- The pronunciation estimator is provisional and editable because spelling does not uniquely determine pronunciation.
- Homophones share phoneme tones unless their optional object tags differ.
- A future standard may compose an EZNAME reference with an approved semantic graph, but version 0.1 keeps the layers separate.

## Browser workflow

1. Enter the unknown word or name.
2. Optionally add an instance tag.
3. Review or edit the estimated sound symbols.
4. Generate the sound ID.
5. Play its framed phoneme tones or download the separate name MIDI file.
