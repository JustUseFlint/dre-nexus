# DRE Nexus — iOS (SwiftUI, iOS 26)

**Status: NOT COMPILED.** This source was written without access to Xcode or a Swift toolchain, so it has never been built. Expect a short round of compile fixes in Xcode 26.

## Build
```
brew install xcodegen
cd ios && xcodegen generate
open DRENexus.xcodeproj   # Xcode 26+, iOS 26 SDK
```
Set your signing team, then run on a device. The barcode scanner and Face ID need real hardware.

## What it uses
- Liquid Glass: `glassEffect`, `GlassEffectContainer`, `glassEffectID`, `.glass`/`.glassProminent` buttons, `tabBarMinimizeBehavior`, `tabViewBottomAccessory`, `scrollEdgeEffectStyle`
- SwiftData (`Investigation`, `MediaItem`), with the store set to `NSFileProtectionComplete` and the data-protection entitlement
- Face ID / passcode lock (LocalAuthentication)
- AVSpeechSynthesizer for EN/ES instructions and the Speech framework for dictation
- VisionKit `DataScannerViewController` for PDF417 licenses (AAMVA parsing) and VINs
- PencilKit photo markup, plus PDF (UIGraphicsPDFRenderer) and JSON export
- `Seed/seed.json` is generated from `/web/data.js` by `node tools/export_seed.js`
