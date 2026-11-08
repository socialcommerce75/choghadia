// Theme.swift
// Choghadia — central design theme.
//
// Colour palette follows the 60-30-10 rule:
//
//   60 %  Dominant  — Dark indigo ink (#1F1A3D)
//                     Backgrounds, surfaces, cards, launch/paywall screens.
//
//   30 %  Secondary — Warm cream & mist tones
//                     Body text, secondary labels, borders, dividers.
//
//   10 %  Accent    — Split between two accent hues:
//                     Saffron     (#F0A25B) — CTA buttons, interactive elements.
//                     Electric Cyan (#00E5FF) — Headline emphasis, active indicators.

import SwiftUI

// MARK: - Colour tokens

extension Color {

    // ── Hex convenience initialiser ───────────────────────────────────────────
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }

    // ── 60 % Dominant — Dark Indigo Ink ──────────────────────────────────────
    /// Launch/paywall/hero surface (always dark).
    static let chInk        = Color(hex: "1F1A3D")
    /// Primary text (light mode).
    static let chText       = Color(hex: "231F3B")
    /// Screen background (light mode).
    static let chBackground = Color(hex: "FBF7F0")
    /// Card background (light mode).
    static let chCard       = Color.white
    /// Card border (light mode).
    static let chBorder     = Color(hex: "E6DCCB")
    /// Beige / timeline panel (light mode).
    static let chBeige      = Color(hex: "F1E9DB")

    // ── 30 % Secondary — Warm Cream & Mist ───────────────────────────────────
    /// Caption / secondary text (light mode).
    static let chSecondary      = Color(hex: "5B5470")
    /// Ghost-button text, glass border highlights.
    static let chCream          = Color(hex: "FFE7B5")
    /// Title text on glass / dark backgrounds.
    static let chGlassTitle     = Color(hex: "FFF6E8")
    /// Primary body text on glass / dark backgrounds.
    static let chGlassBody      = Color.white
    /// Secondary body text on glass / dark backgrounds.
    static let chGlassSecondary = Color(hex: "E6DAF0")
    /// Note / footnote text on glass / dark backgrounds.
    static let chGlassNote      = Color(hex: "CFC4E6")

    // ── 10 % Accent — Saffron & Electric Cyan ────────────────────────────────
    /// CTA buttons, action elements, saffron accent. (5 % of palette)
    static let chSaffron      = Color(hex: "F0A25B")
    /// Headline emphasis, active tab indicators, highlights. (5 % of palette)
    static let chElectricCyan = Color(hex: "00E5FF")

    // ── Semantic slot bands ───────────────────────────────────────────────────
    static let chFavourable     = Color(hex: "3FBF9F")
    static let chFavourableTint = Color(hex: "DDF1EC")
    static let chFavourableText = Color(hex: "0B5F51")
    static let chNeutral        = Color(hex: "C99A1E")
    static let chNeutralTint    = Color(hex: "F6EAD0")
    static let chNeutralText    = Color(hex: "7A5410")
    static let chHoldOff        = Color(hex: "E26A8D")
    static let chHoldOffTint    = Color(hex: "F6DDE5")
    static let chHoldOffText    = Color(hex: "8E2346")
}

// MARK: - Typography
// Target fonts: Fraunces (headings) and Inter (UI / body).
// TODO: Bundle the variable font files and declare them in Info.plist,
//       then swap the .system calls below to .custom("Fraunces-Regular", …).
// Current fallbacks:
//   Headings → New York (.serif) — built-in optical-size serif, closest to Fraunces
//   Body     → SF Pro (.default) — practically identical to Inter for UI text

extension Font {
    static func chHeading(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    static func chHeadingBold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }
    static func chHeadingMedium(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .serif)
    }
    static func chBody(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular)
    }
    static func chBodyMedium(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium)
    }
    static func chBodySemibold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold)
    }
}

// MARK: - Layout constants

enum CH {
    static let pagePadding:  CGFloat = 18
    static let cardRadius:   CGFloat = 22
    static let buttonHeight: CGFloat = 48
    static let buttonRadius: CGFloat = 14
    static let minTarget:    CGFloat = 44
}
