# Choghadia project context: Today screen

This note preserves the product and code context for future work on the main Today screen. It summarizes the product spec, the local HTML prototype, and the SwiftUI implementation as of the first app implementation commit, plus decisions clarified by the owner.

## Product in one paragraph

Choghadia is an iOS-first Choghadiya timing app. It divides local daylight (sunrise to sunset) and nighttime (sunset to the next sunrise) into eight slots each. Today should answer first: what slot is active, what it means, and when the next favorable time begins. Timings are free and should work offline; Choghadia Plus adds an AI guide. Accounts are optional. The tone is calm and warm, and color is always paired with a text label and icon.

**Owner decisions:** Today is the main screen of the app. Frosted Glass cards are the app-wide card treatment, including Today. For the first Today implementation, use dummy sunrise/sunset and slot data matching the prototype. The owner will provide a free sunrise/sunset API later; do not integrate or invent an API now. If location is unavailable or off, offer a clear choice to enable location or select and save a city. Saved places should be kept in local phone storage, subject to the privacy design below.

## Source of truth

- Product rules, requirements, and open questions: [`Choghadia Build Spec for Claude Code.md`](Choghadia%20Build%20Spec%20for%20Claude%20Code.md). The most relevant sections are 1–5 (product and Today), 10–11 (accessibility and visual system), and 14 (scope and owner questions).
- Visual/copy/motion reference: [`choghadia-prototype.html`](choghadia-prototype.html), especially its `home()`, `ribbon()`, and `timeline()` implementations (around lines 192–250 and 271–278).
- When the spec and prototype disagree, the spec says to ask the owner. In practice, the HTML contains prototype-era Explore, community, calendar and other screens that are out of scope for v1. Do not infer that those belong in the iOS app.
- Prototype data is illustrative, not production calculation or slot-rule data. The sample is Sunday 8 Nov 2026, sunrise 6:29 AM, sunset 4:42 PM, current time 11:48 AM EST, and current slot Kaal. It uses placeholder slot names, labels and meanings. No `slot-rules.json` has been supplied yet.

## Today screen requirements

The screen uses a fixed, full-bleed diya background with scrollable content, in this order:

1. **Header:** date and a tappable place name that opens Saved places. Prototype copy varies by account state; date/place are the key requirements.
2. **Dark glass hero card:** “Right now”, current local time and timezone; an eight-segment daylight arc with 22.5° segments and small gaps; segments colored by slot label, past segments dimmed, active segment thicker, sun marker positioned on the arc. Center the current slot name and its end time. Show sunrise/sunset, a status chip with icon and plain-language meaning, then “Better time to begin” with the next favorable slot and countdown.
3. **“Your day at a glance” glass card:** 24-hour dawn-to-next-dawn sky ribbon, Morning/Afternoon/Evening/Night labels, slot boundary ticks, current-time marker, dashed midnight boundary and next date, plus the Most Favorable/Favorable/Neutral/Hold off legend. Tapping/seeking the ribbon selects a slot and glides to it. Expose it accessibly as one adjustable control across 16 slots, announcing slot and time range. Ribbon sky colors are decorative, not advice colors.
4. **Timeline glass container:** “Show earlier slots” switch (on by default). Slot cards have a left colour band, slot name, local time range and timezone, label chip with icon, and “Now” chip for the current slot. Past slots are dimmed. Show boundary-time pills and a centre connector line that is solid through elapsed time and dotted ahead, with a pulse before the current slot. Current slot starts expanded; only one card can be open. Expansion shows a one-line meaning and “Ask the AI guide” (lock when unavailable), with about 0.3s ease-out motion.
5. **Feedback card:** only signed-in users see it. Five 44pt-target stars, optional comment up to 125 characters, Send feedback; require a rating and show a thank-you state after success.

On entry, after about 0.9s, glide to the current timeline card over 0.6–1.5s; touching cancels the glide. Animate hero arc/sun entrance only when entering Today. Respect Reduce Motion: no glide, pulse, card animation or confetti; state changes become instant.

### Location and saved cities

- Location selects the place whose sunrise/sunset determines the slots. Ask for when-in-use permission only when needed and explain the purpose.
- If the app does not have usable location (permission not requested, denied/restricted, or location unavailable), keep Today usable by offering two actions: enable location, or choose a city. When permission is denied, provide a route to iOS Settings; when it has not been requested, use the system permission prompt at the appropriate moment.
- City search/manual selection is a first-class fallback, not a dead end. Allow the selected city to be saved and later chosen from Saved places.
- Persist saved place selections on device (e.g. UserDefaults/SwiftData). Do not require account sign-in or send the saved list to a server. Only sync or transmit it if the owner later decides that explicitly and the privacy disclosures are updated.
- Apple’s current App Review Guidelines (5.1.1) explicitly give manual address entry as an alternative when someone declines Location. Apple’s privacy-details guidance says data processed only on device and never sent to a server is not “collected” for App Privacy answers. Location access still needs a clear purpose and consent; if coordinates or a selected city are sent to the future sunrise API, assess what that provider receives, disclose it, and update the privacy policy/App Privacy answers as applicable. References: [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) and [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/).

### Sunrise/sunset data plan

- First visual/functional pass: explicitly marked prototype fixtures based on the HTML sample (Sunday 8 Nov 2026, sunrise 6:29 AM, sunset 4:42 PM, now 11:48 AM EST, current slot Kaal). Keep sample data isolated from production behavior and replaceable.
- Later: integrate the free sunrise/sunset API the owner will provide. No endpoint, key, SDK, or networking behavior should be assumed in advance. Keep data acquisition behind a small interface so fixtures can be replaced by the API source without rewriting the SwiftUI screen.
- The written spec currently proposes an on-device NOAA algorithm and says no location is sent to servers by default. The owner’s later API plan may change that; decide how coordinates/place are handled and update the spec/privacy language when API details are available. Keep Choghadiya slot ordering and labels in a separate rules/data layer either way.

## Visual/accessibility system

- Colors are centralized in `Theme.swift` as `Color.ch…` extensions. Main spec values include ink `#1F1A3D`, cream background `#FBF7F0`, saffron `#F0A25B`; semantic bands: favorable teal `#3FBF9F`, neutral gold `#C99A1E`, hold-off pink `#E26A8D`. The ribbon legend also includes Most Favorable in dark green `#187A4B`. Tints and text colors are also in `Theme.swift`.
- Use the prototype’s frosted glass treatment: white at 7–10% opacity, cream border `#FFE7B5` at about 28%, roughly 16pt blur, 18–22pt rounded cards. Reduce Transparency should use solid cards; Increase Contrast should strengthen borders.
- The current SwiftUI Today cards tint `.ultraThinMaterial` with a dark purple gradient (`#403568` to `#211B45`) to keep the glass from reading gray. The Kaal hero is being trialed with a warmer saffron-to-plum glass gradient (`#795B27` to `#382847`), while its Hold off chip remains rose. The slot timeline container uses a deep indigo gradient (`#110D29` to `#1B163B`), with lighter purple, status-tinted gradient slot cards to distinguish the hierarchy. The diya background must ignore safe areas and cover the entire screen, including behind the tab bar. The hero arc uses eight sampled semicircle shapes with rounded strokes and staggered trim animations on Today entry; the sun sweeps to the current sample position. “Kaal” is Electric Cyan (`#00E5FF`) with clear separation from its end time.
- Today scroll content reserves 120pt after the last timeline boundary so it can scroll above the floating tab bar. The scroll content adds top safe-area padding before the header, which has additional spacing for Dynamic Island clearance; the date includes weekday, month, day and year. The hero time displays the timezone abbreviation separately (for example, `11:48 AM · EST`). On entry, the current slot card should be centered after the arc animation. The earlier-slots switch defaults on and its action label toggles between “Hide earlier time slots” and “Show earlier time slots.” Primary and secondary light copy on dark Today surfaces is pure white; status chips retain their semantic colors. The sky ribbon uses visibly distinct warm dawn, gold morning, blue afternoon, orange/violet evening and indigo night colors.
- Fraunces-style serif headings and Inter-style UI are intended. `Theme.swift` currently uses system serif and SF fallbacks; bundled brand fonts are not present.
- 18pt page inset, card radius around 22pt, 44pt minimum controls. Dynamic Type, VoiceOver semantics, 4.5:1 text contrast and “colour never alone” are requirements.
- The project contains `Background-Diya`, `Background-Header`, `Background-Launch`, and `Ganesha` image sets in `choghadia/Assets.xcassets`. Use the diya asset for Today rather than rebuilding its artwork. `DayArcLogo.swift` draws the shared eight-segment app mark; the hero arc is a separate, larger stateful visualization.

## Existing implementation and project structure

- SwiftUI app entry: `choghadia/choghadiaApp.swift` injects the observable `AppState`.
- Navigation: `ContentView.swift` switches between `.launch` and `.main`.
- `AppState.swift` only has those two root states; extend only as the screen needs.
- `LaunchView.swift` is implemented. Get started moves to `.main`; sign-in is still a TODO.
- `MainTabView.swift` has native `TabView` tabs for Today, AI Assistance and Settings. Today is implemented in `choghadia/TodayView.swift`; the AI and Settings tabs remain placeholders.
- Today currently uses a fixed prototype fixture and a small built-in city directory. City selections are stored locally in `UserDefaults`. Sunrise/sunset values and the timezone are still demo-only; selecting a city does not yet recalculate them.
- The Today hero and timeline use an animated eight-segment semicircle arc, sky ribbon, centered boundary pills, expandable full-width slot cards, and Frosted Glass styling. Keep the detailed reference in sections above; prototype fidelity matters, especially arc segment spacing, ribbon boundaries, and timeline hierarchy.
- `Theme.swift` holds colors, system-font helpers and `CH` spacing/shape constants. `DayArcLogo.swift` provides an existing Canvas-based arc reference.
- Xcode project uses filesystem-synchronized groups, so new Swift files placed under `choghadia/` should be discovered automatically. Current project settings say iOS 26.4, Swift language mode 5, and iPhone/iPad/visionOS families. The product spec says minimum iOS 17 is an open question; resolve/confirm before relying on APIs newer than the actual target. The existing `CLAUDE.md` mentions glass API fallbacks, while app target presently requires iOS 26.4.
- Unit and UI test target files exist, but no Today-specific behavior exists. Do not treat the prototype’s inline JavaScript sample data as calculation logic.

## Important implementation boundary

The product spec requires a pure calculation module (no UI imports), driven by latitude, longitude, local date and IANA timezone. It originally proposed NOAA sunrise/sunset calculation on-device and offline; the owner now plans to provide a free sunrise/sunset API later. First use replaceable prototype fixtures; defer API integration until its details are provided. Each daylight/night period has eight slots; actual weekday ordering, names, labels and meanings must be loaded from owner-provided `slot-rules.json`, never hardcoded in views. Display time in the selected place’s timezone, including abbreviation; night slots crossing midnight belong to the next date. Account for DST and places in a different timezone from the phone. Polar day/night needs an explicit message; the proposed 6:00–18:00 fallback still needs owner approval.

Keep this boundary in mind when building Today: presentation can use explicit demo fixtures, but production time/slot data belongs behind replaceable data/calculation interfaces and rule resources. Clearly identify sample fixtures so they cannot be mistaken for live results. The city fallback and local saved places are part of the intended screen flow.

## Decisions still needed from the owner

- The actual slot rules JSON: weekday order, names, labels and meanings.
- Whether translated slot names should show in native script, Latin transliteration, or both (spec recommendation: both).
- Confirm minimum supported iOS; current Xcode target and written spec disagree (26.4 vs proposed 17).
- Polar day/night fallback behavior.
- Whether accounts ship in v1 (the Today feedback card only appears for signed-in users).
- Final subscription/free-trial policy is unrelated to the first Today layout pass but remains unresolved.
