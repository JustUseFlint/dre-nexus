# DRE Nexus

A drug reference and impairment-documentation tool for DREs and patrol officers.

- **Live PWA:** https://justuseflint.github.io/dre-nexus/ (source in `/web`). Add it to the home screen to use it offline.
- **iOS app (SwiftUI, iOS 26, Liquid Glass):** `/ios`. It has **not been compiled yet**; see `ios/README.md`.

## Modules
- **Drug Hub:** 64 substances across the 7 DRE categories. The IACP/NHTSA symptomatology matrix (with its footnotes), a matrix match tool, trends, and 25 verified case-law entries.
- **Impairment Tracker:** SFST and ARIDE (HGN, VGN, WAT, OLS, LOC, Modified Romberg, FTN), a DRE 12-step wizard, a live matrix, a Facesheet, and PDF/JSON export.

## Sourcing and limits
- The matrix and clue criteria follow the NHTSA/IACP DEC and SFST curricula.
- Case law includes only cases whose citations were verified. Unverified cases were removed.
- **Trend charts are illustrative**, not official statistics. Street prices are approximate and vary by region.
- The demo case is fictional.
- Web barcode scanning needs `BarcodeDetector`, which Chrome/Android support and iOS Safari does not. On iOS Safari, paste the AAMVA text instead. Web dictation depends on the browser.
- This app is a documentation aid. It does not replace training, agency policy, or the evaluator's own opinion.
