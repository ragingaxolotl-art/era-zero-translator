# Separate word sounds from sentence translation

Unsupported sentences now show their explanation first and keep individual word sounds in a closed **Optional word sounds · not a sentence translation** section. Missing verb/adjective help stays visible outside that section. Opening it preserves the existing per-word choices, playback and explicitly labeled **Word sketch** song entry. Old songs and saved definitions are unchanged.

Restrictive **only** is marked as unscored scope, rather than becoming a phonemic noun. Its sentence meaning is still unsupported; the change does not silently remove that restriction or claim to implement it. Explicitly quoted names such as “Only” remain names, including beside contractions and Unicode names. The earlier misleading “complete label-only phrase” button now says **Hear individual name sounds**.

## Evidence

- Dedicated checks cover restrictive focus in six constructions, quoted names, repeated tokens and missing verb/adjective help. Existing per-word selection and stale-event tests pass.
- Each local site passes **18 disclosure layouts**, **six visible missing-word actions**, **two independently decoded supported exports**, keyboard opening/closing, explicit sketch opt-in, saved-sketch labeling after reload and clearing stale controls on input edits. The checks use Chromium at 320/390/768 pixels; physical iOS/Safari remain separate.
- Lore’s catalog build and **220 tests** pass.
- The final clean implementation run at `50af32ce1f8e5865bc0086377866726ec0bd0ac5` passes **270 checks**, including the new scope checks. They are also included in deployment. The earlier 269-check run is retained separately. All eight release gates also pass at the final implementation revision.

Evidence and screenshots are retained in [the report directory](partial_word_flow_2026_11_22/). This is a usability and honesty repair. It adds no roots, compounds, sound formats or sentence grammar, and does not finish the broader translator.
