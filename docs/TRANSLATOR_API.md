# Translator API 1.0

The local API is served at `http://127.0.0.1:8787/api`. JSON requests must be objects and are limited to 1 MiB. Errors use:

```json
{"status":"error","error":{"code":"stable_code","message":"Human explanation","details":{}}}
```

## Health and metadata

- `GET /api/health`
- `GET /api/meta`

## Analyze general English

`POST /api/analyze`

```json
{"input":"go [1]","limit":8}
```

The response contains ranked candidates, scores, confidence, evidence, candidate IR alternatives where safe, and a decision explaining whether clarification is required.

## Resolve a selected reading

`POST /api/resolve`

```json
{
  "input":"leave",
  "sense_id":"ENS:723b76515108bf4a17e07bb7",
  "runtime_state":1,
  "speech_act":"assertion",
  "roles":{}
}
```

Roles use canonical controlled labels:

```json
{"source":{"label":"conscious other","state":1}}
```

The successful response contains controlled input, canonical Semantic IR, EZF-1, and `round_trip_equal: true`.

## Compile controlled English

`POST /api/controlled`

```json
{"input":"QUESTION \"active destination\" [1]."}
```

## Presentation

- `POST /api/svg` with `{"formal": <EZF-1 object>}` returns `image/svg+xml`.
- `POST /api/midi` with the same body returns Standard MIDI type 0.

Both endpoints validate the EZF document through the inverse decoder before output.

## EZB-1 exchange bundles

- `POST /api/bundle/export` with `{"source":"…","resolution":<successful resolution>}`.
- `POST /api/bundle/import` with `{"bundle":<EZB-1 object>}`.

Import verifies format/version, bundle SHA-256, exact IR/EZF round trip, and SVG/MIDI presentation hashes. A bundle does not modify lexical authority.

## Security boundary

The default listener is `127.0.0.1`; no CORS header is emitted, there is no remote dependency, and API failures omit exception messages and stack traces. This release is intended for one local user. Do not expose it directly to an untrusted network without authentication, TLS, origin validation, request-rate limits, and process isolation.
