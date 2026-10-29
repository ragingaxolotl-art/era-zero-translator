# Commands for spatial destination carrying

“Carry the heavy box to Ada” now reuses the completed spatial carrying event type
under a command speech act. The addressee is the carrier, the box is the shared
supported/moving load, and Ada supplies a selected contextual spatial destination.
The command requests that event; it does not assert that carrying or arrival has
occurred. “Do not carry … to …” prohibits that whole event type rather than
asserting failed approach or converting runtime 0 into negation.

Destination interpretation remains explicit. Receipt/delivery is not silently
chosen. A heavy/light noun still requires its own mass standard. An imperative
does not receive the simple-present viewpoint question, an ongoing aspect merely
because the parser uses a progressive intermediate, or an inferred tense. Its
endpoint belongs to the requested event type through the existing completed
carrying convention. Existing commands with “toward” retain their earlier meaning
and performance; moving toward a destination does not require reaching it.

The implementation adds no root, compound, musical code or new runtime meaning.
The command contour and any negation surround the existing event convention,
independently of all three runtime endings. The carrier remains the addressee even
when the destination is “me”; role direction is not inferred from name order alone.

`tests/destination_command_test.mjs` checks 18 state/negation/property/participant
cases against Ruby formal and MIDI output. The MIDI-only carrying inverse recovers
the command speech act, addressee, destination, mass restriction and runtime;
it confirms that no tense or aspect was invented. The actual form handler requires
destination and mass choices without a viewpoint question. Unsupported quantities,
manner, extra participants, self-carrying and recipient readings remain rejected.

Remaining work includes per-clause interpretation choices, conditional commands
using these choices, broader references and quantities, receipt/custody and delivery,
and the remaining original acceptance variants. This is additional gate-4 evidence,
not a claim that the vertical slice or full translator is complete.
