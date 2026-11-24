# Dictionary loading and retry — November 23, 2026

A valid sentence could fail simply because Translate was clicked before the dictionary finished loading. A controlled delayed-request [reproduction](browser_loading_2026_11_23/original-race.json) showed an enabled button, a null-data error, and no automatic translation when loading later finished. The sentence itself was retained. This is a startup defect, separate from whether its words or grammar are supported.

The generated browser page now starts with Translate disabled. The application enables it after both dictionary and document data have loaded and its controls are initialized. A second guard prevents direct analysis from touching unloaded data. A failed fetch or malformed response keeps translation disabled and exposes Retry loading. Retrying preserves the typed sentence and prevents duplicate simultaneous requests. Shared-link examples translate only after readiness, without replacing an existing draft. The status is announced accessibly, and mode switching keeps the loading barrier.

The local server HTML remains unchanged; its separate server flow is not disabled by the browser build. Lore retains its existing notebook/save adapter, imports, backup controls and navigation. Its loading integration was reviewed manually because its startup function differs from the main translator. Repeated initialization reuses the existing Lore attachment so subscriptions are not duplicated.

## Verification

The clean [full regression](browser_loading_2026_11_23/implementation-regression.json) passes **290 checks**, and all [eight release gates](browser_loading_2026_11_23/release-gates.json) pass at `fce1d189f216d62178b96bafaacdeffb1c018959`. Subsequent source merges add already verified requirement documentation, the frozen-intention replay and browser-check readiness; the semantic runtime remains unchanged. The [focused test](browser_loading_2026_11_23/focused-tests.txt) executes the actual loading function for delayed resources, duplicate starts, failed HTTP/JSON, retry, retained drafts, shared links and unavailable local storage. The [Lore suite](browser_loading_2026_11_23/lore-tests.txt) passes **323 tests**, including its save-adapter loading test.

Both [local translator](browser_loading_2026_11_23/browser-primary.json) and [local Lore](browser_loading_2026_11_23/browser-lore.json) pass:

- Six delayed-resource cases: dictionary or document loading at 320, 390 and 768 pixels.
- Twelve failure-and-retry cases: HTTP failures for either resource, malformed JSON and an aborted dictionary request, at all three widths.
- Three shared-link cases and keyboard retry interaction.
- Six actual melody/chord downloads spanning runtime 0/1/2. All hashes match between sites, and independent decoding preserves the expected predicate, participants and time.

These are controlled fault injections in Chromium. They do not establish recovery from every network or module-loading failure, nor physical iPhone/Safari behavior. A failure before the application module runs may still need a page reload. Two earlier public checks had one-off loading timeouts whose causes were not established; this reproduced early-click defect should not be asserted as their cause.

No dictionary meaning, compound, grammar frame or musical performance changed. The [58-case follow-up](goal_followup_2026_11_23.md) still leaves 27 whole meanings unsupported; clearer startup behavior does not finish the translator.

Published on both sites on November 24 (UTC): [primary deployment](https://github.com/ragingaxolotl-art/era-zero-translator/actions/runs/45317871505), [Lore deployment](https://github.com/ragingaxolotl-art/cyber-pet-lore/actions/runs/45318361238). Both completed successfully. The [public translator check](browser_loading_2026_11_23/public-primary.json) and [public Lore check](browser_loading_2026_11_23/public-lore.json) each pass the same six delayed-resource cases, twelve failure/retry cases, three shared links and six decoded exports. All six MIDI hashes match across both local and both public sites. This verifies this release and these cases, not general sentence coverage or recorded-audio recovery.
