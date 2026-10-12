# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

Android first (high-end devices, Android 13+). Keep the Flutter code iOS-compatible wherever that costs nothing; iOS is not a release target yet.

## Stack
Flutter (stable, Dart 3), Material 3 themed far away from stock Material. Riverpod for state, go_router for navigation, shared_preferences for settings and the onboarding flag. Fonts bundled as assets (offline). No backend, no accounts.

## Users
Primarily people furnishing their own home (renters and homeowners) who want to know whether a piece fits and suits a room before buying it. They are standing in that room, phone in hand, often mid-decision. Interior designers and stagers showing clients options in the client's space are a secondary audience the product should not block.

## Product Purpose
Genie lets you point your phone at a real room, browse furniture, and place true-to-scale 3D pieces into the space, then walk around them. An optional AI mode reads the room (light, colours, empty corners) and suggests pieces that fit. Success means a user can confidently answer "will this fit, and will it look right here?" in under a minute, without signing up for anything.

## Positioning
A utility, not a store: it opens straight to the camera, needs no account, and treats the room you are standing in as the canvas. True scale and real dimensions are the core promise; AI suggestions are an assistant you can switch off.

## Operating Context
Used on a phone held up at a room, often one-handed, in varied indoor lighting. Sessions are short and direct: open, scan the floor, add a piece, look around it, maybe capture a shot. The camera permission is the only hard requirement; photo-library access is optional and asked later.

## Capabilities and Constraints
- No login, no accounts, no backend for now.
- Screens: splash, 4-page onboarding (first launch only), Home (AR camera), furniture sheet, furniture detail (3D turntable, fabric swatches, dimensions), settings.
- Settings: AI suggestions, floor grid, units (cm/in), haptics, saved designs, clear saved designs, replay intro, privacy. All persist locally and apply live.
- AR package not chosen yet (Phase 6, after research). Until then Home uses a placeholder camera background.
- 3D viewer package not chosen yet (research in Phase 4).
- **Prices are undecided. Never show or invent prices.**
- Catalog is local JSON seeded with mockup pieces (Lune armchair, Nord dining chair, 3-seat sofa, Arc floor lamp, Orbit side table, fiddle-leaf fig).

## Brand Commitments
- Name: Genie. Wordmark: thin geometric "GENIE" (ink version at `assets/brand/genie-logo-ink.png`, white version for dark/camera backgrounds).
- Tagline: "Design the room you're in".
- Voice: calm, short, plain, second person ("Point your camera at any space…", "Spin it, swap the fabric…"). No hype.
- Light theme only for now.
- Mockups in `design/` are the visual source of truth.

## Evidence on Hand
- Mockups: `design/00-overview.png` (all screens) and full-size `design/01-splash.png`, `02`–`05` onboarding, `09-settings.png`. Home, furniture sheet and detail exist only in the overview at reduced size.
- Legacy .glb models and images in `assets/model/` and `assets/images/` (sources and licences unknown; do not ship as final without confirming).
- No testimonials, ratings, press, prices or user counts exist. Do not fabricate any.

## Product Principles
1. The room is the interface: get to the camera fast and keep chrome out of the way.
2. True scale is a promise: dimensions are always real and visible when they matter.
3. AI assists, never insists: it is optional, explained, and easy to switch off.
4. Nothing asks for more than it needs: one permission up front, no account, ever.
5. Quiet, physical, quick: motion and feedback feel like objects, not effects.

## Accessibility & Inclusion
Body text contrast at least 4.5:1; every touch target at least 48dp; semantic labels on icon-only controls; respect the system reduce-motion setting with simple fades.
