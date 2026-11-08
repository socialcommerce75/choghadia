# Choghadia: Build Spec for Claude Code

Nov 8, 2026 · @Don

## 1. Product summary and principles

Choghadia is an iOS-first app that shows the eight day slots and eight night slots for the user's location, from local sunrise and sunset, each labelled Favourable, Neutral or Hold off. Timings are free. **Choghadia Plus** (subscription) adds an AI guide that answers questions instantly.

The interactive prototype is the source of truth for layout, copy and motion: [Choghadia App, Interactive Prototype](https://claude.ai/artifact/Pf5dYrVAW5rVri3MuogJvA). Where this spec and the prototype differ, ask the owner.

- **One answer first.** Today leads with what the current slot means and when the next good window starts.
- **Colour is never alone.** Every colour band has a text label and an icon.
- **No user-generated content.** There is no community posting. The only generated content is the AI guide, which has a report flow.
- **Accounts are optional.** The core app works with no sign-in.
- **Calm and emotional.** Warm palette, serif headings, gentle motion. People use it for life decisions (a business, a vehicle, a job).

## 2. Platform and tech stack

Build iOS first with native SwiftUI. Android follows later with Kotlin and Jetpack Compose, reusing this spec and the slot-rule data file.

| Area | Choice |
| --- | --- |
| Language / UI | Swift 6, SwiftUI. Build with the current Xcode so the native tab bar gets Liquid Glass on iOS 26 |
| Minimum iOS | iOS 17 (confirm with the owner) |
| Navigation | Native `TabView` with three tabs. Do not rebuild the glass effect by hand |
| Location | CoreLocation, when-in-use only. Manual city search via MapKit as the fallback |
| Sun times | Computed on device (NOAA algorithm). Works offline, no API key. Optional free API only as a cross-check in tests |
| Storage | Saved places and settings in SwiftData or UserDefaults. No location sent to our servers by default |
| Purchases | StoreKit 2 |
| AI | Backend proxy to an LLM API. Never ship an API key in the app |
| Analytics | None at launch, or privacy-preserving counts only |

Keep the slot calculation as a pure module with no UI imports, so Android can port it and tests can run without a device.

## 3. Screens and navigation

The app has three tabs: **Today**, **AI Assistance**, **Settings**. There is no hamburger menu and no profile icon; account lives in Settings.

| Screen | Purpose | Notes |
| --- | --- | --- |
| Launch | First run | Dark single surface, sun-over-horizon art, headline, one saffron "Get started" button, quiet "Already have an account? Sign in" link, note that no account is needed |
| Today (tab) | Current slot and the whole day | See section 4 |
| AI Assistance (tab) | Chat with the AI guide | Not unlocked: landing with sample questions, "Unlock the AI guide" and "Try one question free". Unlocked or in the free sample: chat with suggestion chips |
| Settings (tab) | Account, Plus, preferences, about | Guest card or signed-in card, Plus row, Saved places, Language, Appearance (Light, Dark, Auto), Restore purchases (with a one-line explanation), Privacy policy, Terms of use, Contact us, Sign out, feedback card (signed-in only) |
| Plus paywall | Subscribe | Yearly and Monthly plans, Subscribe button, renewal terms, Restore, Terms and Privacy links. Payment uses Apple's own sheet |
| Saved places | Switch place | Current location plus saved cities, selected one has a check |
| Add a place | Sheet | City or town search |
| Language | Choose language | English (default), Hindi, Marathi, Gujarati, with a small preview |
| Sign-in sheet | Optional | Apple, Google, Yahoo. Used to restore Plus and sync places |
| Report this answer | Sheet | Three reasons, then a thank-you message |

**Gating rules**

- No sign-in is needed to use Today, Saved places or Settings.
- AI Assistance needs Plus, apart from one free sample question.
- Sign-in succeeds to Today unless the user was in the middle of an action, in which case the action continues.
- Tapping a slot never opens a new screen; slots expand in place.

**Screens in v1.** Launch, Today, AI Assistance, Settings, Saved places, Language and the Plus paywall, plus bottom sheets (sign in, payment, report answer, add place). There is no separate slot detail screen: tapping a slot on Today expands its card in place.

- **Launch:** Day arc logo and name at the top, Ganesha illustration centered, headline, then Get started and Sign in.
- **Settings:** Ganesha header (no visible title), glass account card and rows, Appearance, Restore purchases with its explanation, and an About footer with the app logo, name, version and tagline.
- **AI Assistance:** Ganesha header, example questions, a floating glass input bar above the tab bar, saffron bubbles for the user's messages.
- **Saved places and Language:** diya background, glass rows, selected row outlined in saffron.

## 4. Today screen

Today answers "what is it now, and when is the next good time?" Top to bottom:

1. **Header.** Date, and the place name as a button that opens Saved places.
2. **Hero card** (dark). "Right now" with the time and timezone. An eight-segment arc from sunrise to sunset, each 22.5° with a small gap, coloured by label; past segments dimmed, current segment thicker. A sun marker rotates along the arc. Centre text: slot name and "until 12:52 PM". Below: sunrise and sunset times, a status chip with a one-line plain-language meaning, and a "Better time to begin" strip with the next favourable slot and a countdown.
3. **"Your day at a glance" card.** A 24-hour sky ribbon from sunrise to the next sunrise (dawn peach, midday blue, afternoon amber, dusk violet, night navy) with Morning, Afternoon, Evening and Night labels, faint ticks at slot boundaries, a pulsing "Now" marker, and a dashed midnight line labelled with the next date. Tapping the ribbon opens the slot at that position and glides to it. It is exposed to VoiceOver as an adjustable slider (16 slots, announces name and times). A legend sits at the bottom of the card: Favourable, Neutral, Hold off. The ribbon uses muted sky colours so they are not read as advice.
4. **Timeline card** (separate rounded card below). A "Show earlier slots" switch (on by default). Full-width slot cards with a dotted line running down the centre between them; a small pill at each boundary shows the start time of the next slot. The line is solid where time has passed and dotted ahead; the dot before the current slot pulses.
5. **Feedback card** (signed-in users only): see below.

**Slot card.** Left: slot name (serif, 16 pt; current slot 17 pt). Right: time range with timezone, for example 12:52 PM – 2:09 PM EST, smaller (12 pt) and grey. Second row: label chip with icon (check, minus or x) and, on the current slot, a "Now" chip. A tinted background and thicker colour band mark the current slot. Tapping the card expands it in place with an eased animation (about 0.3 s): a one-line meaning and an "Ask the AI guide" button (lock icon when not unlocked). The current slot starts expanded; only one card is open at a time.

**Motion.**

- On entering Today, after about 0.9 s, scroll to the current slot with an eased glide of 0.6 to 1.5 s (longer for longer distances). Touching the screen cancels it.
- Hero entrance (arc segments draw in, sun sweeps to its position) plays only when entering Today, not on every refresh.
- Reduce Motion: no glides, no pulses, no confetti; state changes are instant.

**Feedback card.** Title "How are we doing?", five stars (44 pt targets), optional comment (max 125 characters), "Send feedback". Sending without a rating shows "Pick a star rating first". On success: about 3 s of confetti in the brand colours, then the card shows "Thank you!". The same card sits at the bottom of Settings. Hidden for guests.

**Look of Today.** The screen sits on the diya background. The greeting and place line are cream text on it. The hero card (current slot, countdown, next good time), the Your day at a glance ribbon card, the slot timeline container with its slot cards, and the feedback card are all frosted glass (section 11). The hero arc uses the same rounded-segment pattern as the app icon.

## 5. Choghadia calculation

The owner will supply the slot rules. Until then, build the engine so the rules are data, not code.

- **Inputs:** latitude, longitude, calendar date, the place's IANA timezone.
- **Sun times:** compute sunrise and sunset on device with the NOAA solar algorithm. The day period runs sunrise to sunset; the night period runs sunset to the next sunrise.
- **Slots:** each period is divided into eight slots. The slot names, their order for each weekday, and each name's label (Favourable, Neutral or Hold off) and one-line meaning come from a bundled data file (`slot-rules.json`) that the owner will provide. Do not hardcode any of it in views.
- **Display:** show times in the place's timezone with its abbreviation (EST, IST). Slot cards and the hero show the abbreviation. Night slots after midnight belong to the next calendar date; show that date on the ribbon's midnight marker.
- **Edge cases:** polar day and night (no sunrise or sunset): show a clear message and fall back to a fixed 6:00 to 18:00 split only if the owner approves. Daylight-saving changes inside a period. A saved place in a different timezone from the phone.
- **Tests:** unit-test the module against published sunrise and sunset for at least five cities across hemispheres (agree within one minute), and test period boundaries across midnight and daylight-saving change days.

The prototype uses sample data for Sunday 8 Nov (sunrise 6:29 AM, sunset 4:42 PM, now 11:48 AM, current slot Kaal). Treat it as layout reference only; the slot names and meanings in it are placeholders.

## 6. Accounts and sign-in

An account is optional. A guest can use Today, Saved places, Settings and a purchased Plus subscription.

- **Why sign in:** restore Plus on a new device through the account, sync saved places, and leave feedback.
- **Providers:** Sign in with Apple, Google, Yahoo. Apple is required because other third-party sign-in is offered, and its button follows Apple's guidelines.
- **Entry points:** the quiet link on Launch, the Sign in button in Settings, and the Plus screen when an action needs an account. Sign-in always lands on Today, unless the user was mid-action, in which case the action continues.
- **Settings:** a guest card with an outlined "Sign in" button; a signed-in card ("Plus and saved places follow you across devices") and an outlined "Sign out" button with an exit icon.
- **Delete account:** required in Settings once accounts exist (App Store guideline 5.1.1). It deletes server data and revokes the Sign in with Apple token.
- **Store only** the provider's user ID, an email if given, saved places and feedback. No precise location.

Guests who bought Plus are restored through Restore Purchases and the App Store, with no account.

## 7. Choghadia Plus subscription

Plus unlocks the AI guide. It is sold only through Apple's in-app purchase (guideline 3.1.1). Do not add Apple Pay, Venmo or PayPal buttons for it; Apple charges the payment method on the user's Apple ID.

- **Products:** one auto-renewable subscription group with a monthly and a yearly plan. Prices are set in App Store Connect; proposed launch prices are $2.99 monthly and $19.99 yearly (about 44% less than twelve monthly payments), with lower prices set for India. Treat them as a starting point and adjust after launch.
- **Paywall:** headline "Ask anything. Get an answer in seconds." Yearly is preselected and shows the saving. The Subscribe button names the price and period. Below it: "Renews monthly until cancelled", Restore purchase, Terms, Privacy. Apple's own payment sheet appears on tap; the prototype's mock sheet is only a stand-in.
- **Free sample:** one free AI question per device. After the answer, the next question opens the paywall. The label reads "Free sample" instead of "Plus". Track the sample on the backend with App Attest or a device token, not only locally.
- **Entitlement:** read `Transaction.currentEntitlements`; listen for `Transaction.updates`; verify on the backend before answering AI requests (App Store Server API and server notifications).
- **Restore Purchases:** a row in Settings with a caption ("Already paid for Plus? Tap to get it back on this phone, for example after reinstalling or switching devices.") that calls `AppStore.sync()`. Also on the paywall.
- **After subscribing:** return the user to where they were; from the AI landing, to the chat.
- **Android later:** Google Play Billing, same plan structure.

## 8. AI assistant

The AI guide answers questions about the user's day in seconds. Apple treats generated content like user-generated content (guidelines 1.1 and 1.2), and Google Play requires an in-app report option for AI output, so the safeguards below are required.

- **Architecture:** the app calls our backend, which checks entitlement and rate limits, then calls the LLM API. Context sent: the place name, local time, today's slot list with labels, the user's question, and the app language. Do not send precise coordinates or an account identifier to the model provider.
- **Behaviour:** stay on Choghadia and day-planning topics; present guidance as traditional, not professional advice; never promise outcomes; no medical, legal or financial instructions; decline harmful requests. Reply in the user's language.
- **Filtering:** moderate the user's question and the model's answer before showing the answer. If blocked, show a short neutral message.
- **Label:** every answer carries "AI-generated. Traditional guidance, not professional advice."
- **Report flow:** a flag icon (44 pt target) under every answer opens a "Report this answer" sheet with three reasons (Offensive or inappropriate, Wrong or misleading, Something else). Sending shows "Thanks. We will review this answer." The report posts the question, answer, reason, app version and an anonymous device ID to the backend, which forwards it to a monitored inbox or channel. The owner reviews reports within a few days and adjusts the system prompt or filter when a report is valid. No reply to the reporter is needed.
- **Disclosure:** the AI landing page says questions are sent to a third-party AI provider; the privacy policy says the same (guideline 5.1.2). Link the policy from Settings.
- **Limits:** a per-user daily cap (suggest 30 questions) and a per-device cap for the free sample. Keep conversation history on the device; do not store question text on the server beyond report submissions and short-term abuse logs.
- **Block user:** not applicable, because there are no other users. State this in the App Review notes.

## 9. Localization and fonts

- **Languages:** English (default), Hindi, Marathi, Gujarati. More later. Hindi and Marathi use Devanagari; Gujarati has its own script.
- **Strings:** a String Catalog (`.xcstrings`) from day one. No string concatenation; use full sentences with placeholders and plural rules. Dates and times through locale formatters.
- **Language switch:** follow the system language by default; allow an in-app override in Settings (Language screen with a live preview).
- **Fonts:** iOS and Android ship system fonts for all three scripts, so text renders without extra work. To keep the brand look, bundle Noto Sans Devanagari and Noto Sans Gujarati for body text and Noto Serif Devanagari and Noto Serif Gujarati for headings, as variable fonts, subset to the needed glyphs. Latin text uses Inter (UI) and Fraunces (headings).
- **Layout for Indic text:** line height about 1.5 to 1.6 (English 1.4); no letter-spacing; no fixed-height text boxes; allow 20 to 40% more width (tab labels, chips, slot cards).
- **Slot names:** show the name in the user's script with a small transliteration beneath it (owner to confirm; open question in section 14).
- **AI answers:** pass the app language to the AI so replies match.
- **Review:** have a native speaker review each language before release; machine translation is a first draft only.

## 10. Accessibility

- **Colour never alone.** Labels (Favourable, Neutral, Hold off) are always written, with a check, minus or x icon. The ribbon's sky colours carry no advice.
- **Contrast.** Text at least 4.5:1, icons and bands at least 3:1. Verify the final colours in both light and dark. The Neutral gold is `#C99A1E` so it stands out from white.
- **Dynamic Type.** All text scales with the system text size. No text smaller than 11 pt at default. Layouts must reflow, not truncate, at the largest sizes.
- **VoiceOver and TalkBack.** Every control has a label. The sky ribbon is a single adjustable element (swipe up or down moves between 16 slots) that announces, for example, "Kaal, 11:36 AM to 12:52 PM". Slot cards are buttons with expanded and collapsed state. The report flag reads "Report this answer". Star rating is a radio group.
- **Targets.** At least 44 by 44 pt for every tappable control.
- **Reduce Motion.** Disable glides, pulses, card animations and confetti; show end states instantly.
- **Keyboard and Switch Control.** The ribbon supports arrow-key stepping. All sheets can be dismissed with a clear Close or Cancel.
- **Store.** Fill in Apple's accessibility declarations only for features that pass testing.

**Glass and contrast.** Honor Reduce Transparency by swapping glass fills for solid #2B2552 cards, and Increase Contrast by raising glass borders to 60% opacity. Check that body text keeps at least 4.5:1 contrast over the brightest part of each background glow, especially near the diya.

## 11. Design tokens

Values come from the prototype. Put them in a single asset catalog or theme file with light and dark variants.

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| Ink (hero, launch, paywall) | `#1F1A3D` | `#241E4A` | Dark surfaces |
| Text | `#231F3B` | `#F2ECE1` | Primary text |
| Background | `#FBF7F0` | `#14102B` | Screens |
| Card | `#FFFFFF` | `#221C46` | Cards |
| Border | `#E6DCCB` | `#342D5E` | Card borders |
| Beige panel | `#F1E9DB` | `#2B2552` | Timeline card |
| Secondary text | `#5B5470` | `#B8AED0` | Captions |
| Saffron (primary action) | `#F0A25B` | `#F0A25B` | Main buttons, accents |
| Favourable band | `#3FBF9F` | same | Tint `#DDF1EC`, text `#0B5F51` |
| Neutral band | `#C99A1E` | same | Tint `#F6EAD0`, text `#7A5410` |
| Hold off band | `#E26A8D` | same | Tint `#F6DDE5`, text `#8E2346` |

**Sky ribbon gradient** (left to right, sunrise to next sunrise): `#F7C59F`, `#FBE6BE`, `#BFE2F2`, `#CFE3F0`, `#F5B56E`, `#E98F72`, `#8E67AE`, `#3A3370`, `#1F1A3D`, `#3A3370`, back to `#F7C59F`.

**Type.** Headings: Fraunces 400 to 500 (hero slot name 28 to 34 pt, screen titles 28 to 30, card titles 20). UI and body: Inter 400 to 500 (body 14, captions 12 to 13, minimum 11). Indic scripts: see section 9.

**Shape and spacing.** Page margin 18 pt. Cards 22 pt radius; rows 14 to 18; chips fully round. Minimum target 44 pt. Buttons 48 pt high, 14 pt radius.

**Buttons.** Primary: saffron fill. Secondary: outline with a thin border and the screen colour as fill (Sign in, Sign out). Tertiary: text only. Dark filled buttons only for the Apple sign-in button.

**Motion.** Card expand 0.3 s ease-out; scroll glide 0.6 to 1.5 s ease-in-out; pulse 2.2 s; hero entrance about 1 s; confetti about 3 s. All respect Reduce Motion.

**Frosted glass cards.** Every card on Today, Settings, Saved places, Language, the AI input bar, bottom sheets, toasts and the Plus paywall cards is translucent glass over the screen background. Fill white at 7 to 10% opacity, 1 pt cream (#FFE7B5) border at 28%, blur about 16 pt (sheets 24 pt). Corner radius: cards 18 to 22 pt, sheets 28 pt on top, the input bar and toasts fully rounded. In the prototype this is `rgba(255,255,255,.07)` with `backdrop-filter: blur(16px)`.

- **Native mapping:** SwiftUI `.glassEffect()` (Liquid Glass) on iOS 26 and later, `.ultraThinMaterial` in a rounded shape on earlier versions. The tab bar uses the system TabView glass.
- **Text on glass:** titles #FFF6E8, body white, secondary #E6DAF0, small notes #CFC4E6. Primary actions and selected states are saffron (#F0A25B) with ink text (#1F1A3D).
- **Stay opaque:** small pills such as Now, the time markers and status chips, so they stay readable.
- **Slot cards:** current slot is the brightest glass (white 17%), passed slots at 60% opacity, each with a 5 pt left bar in its band color (#3FBF9F, #C99A1E, #E26A8D). The hero card is glass, not solid dark.
- **Sheets and toasts:** dark glass, indigo at about 80% with blur, cream border.

**Screen backgrounds.** A fixed full-screen layer behind the content that does not scroll. Base #1F1A3D with saffron glow circles (#F0A25B at 5, 8, 14 and 24% opacity) and bokeh dots in saffron, rose and cream at 20 to 60%. Three variants:

- **Diya:** a large glowing diya at the bottom center. Used on Today, Saved places and Language.
- **Ganesha header:** glow centered at the top with the Ganesha illustration centered above the content (130 pt wide, 96 pt on the AI chat). It scrolls with the content. Used on Settings and AI Assistance. The Plus paywall uses the same glow without the illustration.
- **Launch:** glow centered behind the Ganesha illustration (about 196 pt wide), between the logo row and the headline.

Build these as SwiftUI shapes or vector PDF assets (Background-Diya, Background-Header, Background-Launch), placed with `.ignoresSafeArea()`.

**Slot arc.** The Today hero arc and the app icon share one pattern: eight rounded pill segments with round line caps and visible gaps, colored by band. The current slot is thicker, passed slots are at 45% opacity, and the sun marker sits on the arc.

## 12. Backend and data

Keep the backend small: one serverless service (for example on a managed cloud function platform) with these endpoints.

| Endpoint | Purpose | Notes |
| --- | --- | --- |
| `POST /ai` | Answer a question | Verify entitlement or free-sample token, apply rate limits, moderate, call the LLM, return the answer |
| `POST /reports` | AI answer reports | Store question, answer, reason, app version, anonymous device ID; notify the owner's inbox or channel; weekly digest |
| `POST /feedback` | Star rating and comment | Rating 1 to 5, text up to 125 characters, app version; signed-in users only |
| Auth endpoints | Sign in with Apple, Google, Yahoo | Only if accounts ship in v1; includes account deletion |
| App Store notifications | Subscription state | Server notifications from Apple keep entitlement current |

**Data rules.** Location stays on the device. Saved places sync only for signed-in users. No question text is stored except inside a report. Publish a privacy policy that matches this, and answer Apple's privacy questions from it. The AI provider's data handling terms must be linked from the policy.

## 13. App Store submission checklist

| Item | What to do |
| --- | --- |
| Sign in with Apple | Offer it alongside Google and Yahoo (guideline 4.8) |
| Account deletion | In-app delete in Settings; revoke Apple token (5.1.1) |
| In-app purchase | Plus only through StoreKit; no external payment links (3.1.1) |
| Paywall disclosures | Price, period, renewal text, Restore, Terms, Privacy on the paywall (3.1.2) |
| Privacy policy URL | In App Store Connect and in Settings (5.1.1) |
| Privacy labels | Declare location (on device), purchases, identifiers, feedback, diagnostics as applicable |
| Location permission | When-in-use only; clear purpose string; typing a city works without it |
| AI disclosure | Say questions go to a third-party AI provider, and link the policy (5.1.2) |
| AI content safeguards | Filtering, report flag on every answer, published contact, timely review (1.1, 1.2) |
| Contact information | A real, monitored support email and support URL, linked in Settings |
| Age rating | Complete the questionnaire accurately (AI-generated content) |
| Review notes | Explain: no user-to-user content, so no block option; give a demo account with Plus unlocked; describe where the report flag is |
| Metadata | Screenshots for required iPhone sizes in every shipped language; subtitle; keywords; no claims of guaranteed outcomes |
| Export compliance | Standard HTTPS only |
| Accessibility labels | Declare only what has been tested (section 10) |

## 14. Out of scope and open questions

**Out of scope for v1** (leave the code paths out; do not stub screens)

- Explore tab, Vedic Calendars and Festivals (return when they have real content).
- Community Q&A, posting and replying, moderation, block user.
- Web checkout, Venmo, PayPal, Apple Pay for Plus.
- Android, widgets, notifications.
- Good for / Hold off lists on slots (too granular; the AI guide handles specific questions).

**Open questions for the owner**

- [ ] The slot rules: names, weekday order, labels and meanings (`slot-rules.json`).
- [ ] Final subscription prices and whether to offer a free trial.
- [ ] Show slot names in script, English letters, or both (recommended: both).
- [ ] Who translates Hindi, Marathi and Gujarati, and who reviews them.
- [ ] Which LLM provider and model, and the daily question cap.
- [ ] App name, bundle ID, support email, privacy policy and terms URLs.
- [ ] Whether accounts ship in v1 or only Restore Purchases (accounts add Sign in with Apple and account deletion work).
- [ ] Minimum iOS version.

## 15. Branding and assets

**App icon (Day arc).** 1024 x 1024 PNG, no transparency, no text, no rounded corners (iOS applies the mask). Ink #1F1A3D background. Eight rounded arc segments centered at (512, 730) with radius 340, stroke 52, round caps and 11 degree gaps, colored in order #3FBF9F, #E26A8D, #E26A8D, #C99A1E, #3FBF9F, #3FBF9F, #E26A8D, #3FBF9F. A cream (#FBF7F0) round-capped horizon line from (186, 800) to (838, 800), stroke 40. The sun sits on the fifth segment at 78.75 degrees: ink halo radius 104, saffron radius 84, cream core radius 54. Icon Composer in Xcode 26 can be used for layers.

**Logo use.** On Launch, 46 pt beside the Choghadia wordmark. In the Settings footer, 64 pt with the name, "Version 1.0 (1)" read from the bundle, and the line "Timings from your own sunrise and sunset."

**Ganesha illustration.** Cut out and recolored from a free third-party image so it matches the palette: outlines #1F1A3D, fills #FBF7F0, orange #F0A25B, yellow #E9B949, ears #F3B6C8. Ship as an image set (PNG at 1x, 2x, 3x, transparent background, source cutout 720 px wide). Before release, confirm the source license and add attribution if it requires it. The safer long-term option is to commission an original illustration, and the same placement and sizes still apply. Do not redraw or trace the source image.

## 16. Gaps against other Choghadiya apps

Leading apps checked: Drik Panchang Choghadiya, Shubh Panchang, Pocket Pandit and Choghadiya AI.

- **Add to v1:** Home Screen and Lock Screen widget (current slot and countdown, WidgetKit); local notifications for slot starts (Shubh, Amrit, Labh) and Rahu Kaal warnings, each opt-in; a date picker on Today for tomorrow and later dates.
- **v1.1:** Rahu Kaal, Abhijit, Brahma and Yamaganda muhurats; add a slot to the calendar; share a slot.
- **Our edge:** the day ribbon and expandable timeline, a one-line Good for and Hold off on each slot, a free AI sample, accessibility, no ads, and calculation on the device so it works offline.
