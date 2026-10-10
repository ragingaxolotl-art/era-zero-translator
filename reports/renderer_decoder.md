# Deterministic Renderer and Inverse Decoder 1.0

Status: **CANONICAL — CONTROLLED-ENGLISH GATE MAY BEGIN**

This release implements canonical semantic IR to `EZF-1` formal notation and exact inverse decoding. It emits family-qualified transliteration, formal carrier, family opening, relative and absolute note paths, runtime ending, role register, speech-act contour, secondary repetition/parallel/dependency contours, boundary timing, and literal gloss.

Absolute pitch is a transposable presentation profile. The default anchor is MIDI 60, with low, middle, high, and sustained-background register offsets. Formal identity uses only semantic content and the relative performance plan. Tests at anchors 48, 60, and 72 prove that transposition shifts absolute notes without changing relative intervals, UTT meaning, or EZF identity.

Runtime state 2 is rendered as the fixed `num` ending: rise a perfect fifth and sustain. It has no invented numeric parameter. Compounds expand their approved root graphs; only the compound head receives the occurrence runtime ending.

The inverse decoder regenerates the expected performance from the embedded canonical IR and rejects any mismatch instead of repairing or guessing. It returns the original IR exactly. English parsing remains outside this gate.
