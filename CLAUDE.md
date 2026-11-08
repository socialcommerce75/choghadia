# Claude Code Configuration

## File System Restrictions

Only access files and directories within the project folder:

```
/Users/admin-panda/ios-apps/choghadia/
```

**Do NOT access, read, write, or execute anything outside this directory**, including but not limited to:

- `/Users/admin-panda/` (home directory outside project)
- `/tmp/`, `/var/`, `/etc/`, `/usr/`, `/System/`, `/Library/`
- Any other user directories or system paths
- Shell config files (`.zshrc`, `.bashrc`, `.profile`, etc.)
- SSH keys, credentials, or secrets anywhere on the system

## Allowed Operations

- Read, write, and edit files within `/Users/admin-panda/ios-apps/choghadia/`
- Run Xcode build/test commands scoped to this project
- Use `git` commands within this project repository only

## Build & Test Rule

**After completing each screen, always perform a clean build and clean install in the Simulator so the user can test it.** Use `xcrun simctl` to uninstall the app from the booted simulator before installing the fresh build, ensuring no stale state from previous runs.

---

## App Overview: Choghadia

An iOS-first app showing 8 day slots + 8 night slots for the user's location, labelled **Favourable**, **Neutral**, or **Hold off**, calculated from local sunrise/sunset. Free for timings. **Choghadia Plus** (subscription) adds an AI guide.

**Spec:** `docs/Choghadia Build Spec for Claude Code.md`
**Prototype:** `docs/choghadia-prototype.html` (source of truth for layout/copy/motion)

### Core Principles
- One answer first: current slot + next good window
- Colour is never alone: every band has a text label + icon
- No user-generated content (AI guide has a report flow only)
- Accounts are optional — core app works with no sign-in
- Calm and emotional: warm palette, serif headings, gentle motion

---

## Tech Stack

| Area | Choice |
|---|---|
| Language / UI | Swift 6, SwiftUI |
| Min iOS | iOS 17 (confirm with owner) |
| Navigation | Native `TabView` (3 tabs) — do NOT rebuild Liquid Glass by hand |
| Location | CoreLocation (when-in-use). Manual city search via MapKit as fallback |
| Sun times | NOAA algorithm, computed on-device. Offline. No API key. |
| Storage | SwiftData or UserDefaults. No location sent to server |
| Purchases | StoreKit 2 |
| AI | Backend proxy to LLM. Never ship an API key in the app |
| Analytics | None at launch |
| Glass | `.glassEffect()` (Liquid Glass) on iOS 26+, `.ultraThinMaterial` on earlier |

Slot calculation must be a **pure module with no UI imports** (portable to Android, testable without device).

---

## Navigation Structure

**3 Tabs:** Today · AI Assistance · Settings

No hamburger menu, no profile icon — account lives in Settings.

### Screens in v1
| Screen | Notes |
|---|---|
| **Launch** | Dark surface, sun-over-horizon art, Ganesha illustration, headline, saffron "Get started" CTA, quiet "Sign in" link |
| **Today** | Current slot + full day timeline. See Today Screen detail below |
| **AI Assistance** | Locked: landing + "Try one free". Unlocked: chat + suggestion chips |
| **Settings** | Guest card or signed-in card, Plus row, Saved places, Language, Appearance, Restore purchases, Privacy, Terms, Contact, Sign out, feedback card (signed-in) |
| **Plus Paywall** | Yearly (pre-selected, shows saving) + Monthly. StoreKit payment sheet |
| **Saved places** | Current location + saved cities; selected has a check; saffron outline |
| **Add a place** | Bottom sheet, city/town search |
| **Language** | English (default), Hindi, Marathi, Gujarati with live preview |
| **Sign-in sheet** | Apple, Google, Yahoo |
| **Report this answer** | 3 reasons + thank-you |

**Gating:** No sign-in needed for Today, Saved places, Settings. AI needs Plus (1 free sample allowed). Tapping a slot never opens a new screen — it expands in place.

---

## Today Screen (Top → Bottom)

1. **Header** — Date + place name button (opens Saved places)
2. **Hero card** (glass) — "Right now", time + timezone; 8-segment arc (22.5° each, gaps); current segment thicker; sun marker rotates; centre text: slot name + "until HH:MM"; sunrise/sunset times; status chip (one-line meaning); "Better time to begin" strip (next favourable + countdown)
3. **"Your day at a glance" card** (glass) — 24-hour sky ribbon (dawn→next dawn gradient); Morning/Afternoon/Evening/Night labels; faint slot-boundary ticks; pulsing "Now" marker; dashed midnight line with next date; tapping ribbon glides to that slot; VoiceOver: adjustable slider (16 slots); legend: Favourable/Neutral/Hold off at bottom
4. **Timeline card** — "Show earlier slots" toggle (on by default); full-width slot cards with dotted centre line; pill at each boundary showing next slot's start time; line is solid for past, dotted ahead; dot before current slot pulses
5. **Feedback card** (signed-in only) — 5 stars, optional comment (125 chars), confetti on success

**Slot card anatomy:** Left: slot name (Fraunces 16 pt; current 17 pt). Right: time range + timezone (12 pt, grey). Second row: label chip (check/minus/x icon) + "Now" chip (current). Tapping expands in place (0.3s ease-out): one-line meaning + "Ask the AI guide" button (lock icon if not unlocked). Current slot starts expanded; only one open at a time.

**Motion:** Auto-scroll to current slot after ~0.9s (eased glide 0.6–1.5s). Hero entrance (arc segments draw in, sun sweeps) only on first enter. Reduce Motion: all instant, no pulses, no confetti.

**Background:** Fixed full-screen diya layer (does not scroll). Hero card, ribbon card, slot timeline, feedback card all frosted glass.

---

## Choghadia Calculation Engine

- **Inputs:** lat, lng, date, IANA timezone
- **Sun times:** NOAA algorithm, on-device, offline
- **Slots:** each of day + night period divided into 8 slots
- **Rules source:** `slot-rules.json` (owner to provide — names, weekday order, label, one-line meaning). **Never hardcode in views.**
- **Display:** times in place's timezone + abbreviation (EST, IST). Night slots after midnight show next date.
- **Edge cases:** polar day/night (clear message + fixed 6:00–18:00 fallback if owner approves); DST changes inside a period; saved place in different timezone than phone
- **Tests:** unit-test against published sunrise/sunset for 5+ cities (agree within 1 min); test period boundaries across midnight and DST change days

Prototype uses sample data: Sunday 8 Nov, sunrise 6:29 AM, sunset 4:42 PM, now 11:48 AM, current slot = Kaal. Layout reference only.

---

## Design Tokens

### Colours
| Token | Light | Dark | Use |
|---|---|---|---|
| Ink | `#1F1A3D` | `#241E4A` | Dark surfaces, hero, launch |
| Text | `#231F3B` | `#F2ECE1` | Primary text |
| Background | `#FBF7F0` | `#14102B` | Screens |
| Card | `#FFFFFF` | `#221C46` | Cards |
| Border | `#E6DCCB` | `#342D5E` | Card borders |
| Beige panel | `#F1E9DB` | `#2B2552` | Timeline card |
| Secondary text | `#5B5470` | `#B8AED0` | Captions |
| Saffron | `#F0A25B` | same | CTA buttons, accents |
| Favourable | `#3FBF9F` | same | Tint `#DDF1EC`, text `#0B5F51` |
| Neutral | `#C99A1E` | same | Tint `#F6EAD0`, text `#7A5410` |
| Hold off | `#E26A8D` | same | Tint `#F6DDE5`, text `#8E2346` |

**Sky ribbon gradient (left→right):** `#F7C59F → #FBE6BE → #BFE2F2 → #CFE3F0 → #F5B56E → #E98F72 → #8E67AE → #3A3370 → #1F1A3D → #3A3370 → #F7C59F`

### Typography
- **Headings:** Fraunces 400–500 (hero slot name 28–34 pt, screen titles 28–30, card titles 20)
- **UI/Body:** Inter 400–500 (body 14, captions 12–13, min 11)
- **Indic fonts:** Noto Sans/Serif Devanagari, Noto Sans/Serif Gujarati (variable fonts, subset)

### Shape & Spacing
- Page margin: 18 pt
- Card radius: 22 pt; rows 14–18; chips fully round
- Min tap target: 44 pt
- Buttons: 48 pt high, 14 pt radius

### Buttons
- **Primary:** saffron fill (`#F0A25B`) with ink text
- **Secondary:** outline, thin border, screen colour fill
- **Tertiary:** text only
- **Apple sign-in:** dark fill (required by guidelines)

### Frosted Glass Cards
- Fill: white 7–10% opacity; border: 1 pt cream `#FFE7B5` at 28%; blur ~16 pt (sheets 24 pt)
- Corner radius: cards 18–22 pt, sheets 28 pt top, input bar + toasts fully round
- **SwiftUI mapping:** `.glassEffect()` on iOS 26+, `.ultraThinMaterial` in rounded shape on iOS 17–25
- Text on glass: titles `#FFF6E8`, body white, secondary `#E6DAF0`, small notes `#CFC4E6`
- Current slot card: white 17% glass; passed slots at 60% opacity; each has 5 pt left bar in band colour
- **Reduce Transparency:** swap glass for solid `#2B2552` cards
- **Increase Contrast:** raise glass borders to 60% opacity

### Screen Backgrounds (fixed, `.ignoresSafeArea()`)
Three variants — base `#1F1A3D` with saffron glow circles + bokeh:
- **Diya:** large glowing diya at bottom center → Today, Saved places, Language
- **Ganesha header:** glow at top + Ganesha illustration (130 pt wide, 96 pt on AI chat) scrolls with content → Settings, AI Assistance. Plus paywall uses same glow without illustration
- **Launch:** glow behind Ganesha (~196 pt wide) between logo row and headline

### Motion
| Event | Duration |
|---|---|
| Card expand | 0.3s ease-out |
| Scroll glide | 0.6–1.5s ease-in-out |
| Pulse | 2.2s |
| Hero entrance | ~1s |
| Confetti | ~3s |
All respect Reduce Motion (instant state changes).

### Slot Arc (shared: hero + app icon)
8 rounded pill segments, round line caps, visible gaps (11°), coloured by band. Current slot thicker, past at 45% opacity, sun marker on arc.

---

## App Icon

1024×1024 PNG, no transparency, no text, no rounded corners (iOS applies mask).
- Background: ink `#1F1A3D`
- 8 rounded arc segments centred at (512, 730), radius 340, stroke 52, round caps, 11° gaps
- Segment colours: `#3FBF9F`, `#E26A8D`, `#E26A8D`, `#C99A1E`, `#3FBF9F`, `#3FBF9F`, `#E26A8D`, `#3FBF9F`
- Cream horizon line from (186, 800) to (838, 800), stroke 40, `#FBF7F0`
- Sun on 5th segment at 78.75°: ink halo r104, saffron r84, cream core r54
- Three variants: light (`icon-light.png`), dark (`icon-dark.png`), tinted (`icon-tinted.png`) ✓ already in Assets

---

## Choghadia Plus Subscription

- StoreKit 2, auto-renewable subscription group: Monthly + Yearly
- Proposed prices: $2.99/mo, $19.99/yr (lower for India)
- **Free sample:** 1 AI question per device — track on backend via App Attest or device token (not only locally). After free answer, next question opens paywall.
- Entitlement: `Transaction.currentEntitlements` + `Transaction.updates` listener + backend verification
- **Restore Purchases:** `AppStore.sync()` in Settings and paywall with explanation text

---

## AI Assistant

- App calls backend → backend checks entitlement + rate limits → calls LLM API
- Context sent: place name, local time, today's slot list + labels, user's question, app language
- **Never send** precise coordinates or account identifier to model provider
- Every answer carries "AI-generated. Traditional guidance, not professional advice."
- Report flag (44 pt) on every answer → 3-reason sheet → posts to backend
- Per-user daily cap: suggest 30 questions
- Conversation history stays on device; no question text stored server-side (except reports)

---

## Localization

- **Languages:** English (default), Hindi, Marathi, Gujarati
- **String Catalog** (`.xcstrings`) from day one — no string concatenation
- In-app language override in Settings (Language screen with live preview)
- Indic line height: 1.5–1.6 (English 1.4); no letter-spacing; allow 20–40% more width

---

## Accessibility

- Colour never alone: labels always written + check/minus/x icon
- Text contrast: 4.5:1 min; icons/bands 3.1:1
- Dynamic Type: all text scales; no text below 11 pt at default
- Sky ribbon: single VoiceOver adjustable element (announces slot name + times)
- Slot cards: buttons with expanded/collapsed state
- Min 44×44 pt tap targets

---

## Open Questions (from spec)

- `slot-rules.json` — names, weekday order, labels, meanings (owner to provide)
- Final subscription prices + free trial decision
- Slot names: script only, English letters, or both
- LLM provider + model + daily cap
- Bundle ID, support email, privacy policy URL
- Whether accounts ship in v1 or only Restore Purchases
- Minimum iOS version (17 proposed)

---

## Out of Scope for v1

Explore tab, Vedic Calendars/Festivals, Community Q&A, Web checkout, Android, Widgets, Notifications, Good for/Hold off lists on slots.
