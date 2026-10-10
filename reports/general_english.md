# General-English Candidate Translator 1.0

Status: **CANONICAL — CORE TRANSLATOR PIPELINE COMPLETE**

The translator analyzes unrestricted surface phrases conservatively against the 436-sense canonical English index. It returns deterministic ranked candidates with match type, numerical score, confidence, selection evidence, route, target where applicable, candidate Semantic IR runtime alternatives, and explicit clarification questions.

It auto-resolves only a unique exact lemma with an explicit runtime state, a direct lexical route, and no missing compound roles. Polysemy, close scores, structural or grammar routes, gaps, missing runtime state, nonexact matches, and open slots require clarification. Explicit resolution passes through controlled English, canonical Semantic IR, EZF-1 rendering, and exact inverse decoding.

This is a safe core translator rather than a statistical language model. It does not claim complete English coverage. The existing 11 vocabulary gaps and all indexed ambiguity remain visible.
