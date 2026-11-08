// LaunchView.swift
// First screen. Copy and structure sourced from the interactive prototype.

import SwiftUI

struct LaunchView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack(alignment: .topLeading) {

            // ── Full-bleed background ────────────────────────────────────────
            Image("Background-Launch")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // ── Floating planet illustrations ─────────────────────────────────
            FloatingPlanetsLayer()

            // ── Content column ───────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 0) {

                // Flexible gap — pushes all copy into the lower half
                Spacer()

                // 1. Hero headline ────────────────────────────────────────────
                Text("The right moment\nfor what matters")
                    .font(.chHeadingBold(34))
                    .foregroundStyle(Color.chElectricCyan)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Thin saffron accent rule
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.chSaffron.opacity(0.7))
                    .frame(width: 36, height: 2)
                    .padding(.top, 10)

                // 2. Supporting copy ──────────────────────────────────────────
                Text("New business, new vehicle, new job. Timed to your own sunrise and sunset.")
                    .font(.chBody(14))
                    .foregroundStyle(Color.chGlassSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)

                // 3. Feature chips ────────────────────────────────────────────
                HStack(spacing: 8) {
                    LaunchChip(icon: "sparkles",         label: "AI assistance")
                    LaunchChip(icon: "hand.tap",         label: "Easy to use")
                    LaunchChip(icon: "checkmark.circle", label: "No sign-in")
                }
                .padding(.top, 14)

                // 4. CTA section ──────────────────────────────────────────────
                VStack(spacing: 6) {

                    Text("No account needed. Uses your location, or you can type a city.")
                        .font(.chBody(12))
                        .foregroundStyle(Color.chGlassNote)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 2)

                    // Primary — saffron CTA
                    Button {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            appState.screen = .main
                        }
                    } label: {
                        Text("Get started")
                            .font(.chBodyMedium(15))
                            .foregroundStyle(Color.chInk)
                            .frame(maxWidth: .infinity)
                            .frame(height: CH.buttonHeight)
                    }
                    .background(Color.chSaffron)
                    .clipShape(RoundedRectangle(cornerRadius: CH.buttonRadius,
                                               style: .continuous))

                    // Ghost — sign-in link
                    Button {
                        // TODO: open sign-in sheet
                    } label: {
                        Text("Already have an account? Sign in")
                            .font(.chBody(15))
                            .foregroundStyle(Color.chCream)
                            .frame(maxWidth: .infinity)
                            .frame(height: CH.buttonHeight)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 78)   // extra 50 pt lifts the text block up
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Floating planet layer

private struct FloatingPlanetsLayer: View {

    struct PlanetConfig: Identifiable {
        let id = UUID()
        let symbol: String
        let name: String
        let color: Color
        let size: CGFloat
        let startXFrac: CGFloat  // initial x (0…1 of screen width)
        let startYFrac: CGFloat  // initial y (0…1 of screen height)
        let travelTime: Double   // seconds to reach each new destination
        let pauseTime: Double    // seconds to linger before moving again
        let phase: Double        // initial delay before first move (s)
    }

    private let configs: [PlanetConfig] = [
        PlanetConfig(symbol: "☿", name: "Budh",   color: Color(hex: "4ADE80"),
                     size: 34, startXFrac: 0.10, startYFrac: 0.07,
                     travelTime: 1.6, pauseTime: 1.4, phase: 0.0),
        PlanetConfig(symbol: "♃", name: "Guru",   color: Color(hex: "FCD34D"),
                     size: 46, startXFrac: 0.22, startYFrac: 0.21,
                     travelTime: 2.4, pauseTime: 2.0, phase: 0.7),
        PlanetConfig(symbol: "♂", name: "Mangal", color: Color(hex: "F87171"),
                     size: 38, startXFrac: 0.80, startYFrac: 0.04,
                     travelTime: 1.9, pauseTime: 1.6, phase: 1.3),
        PlanetConfig(symbol: "♄", name: "Shani",  color: Color(hex: "818CF8"),
                     size: 44, startXFrac: 0.88, startYFrac: 0.14,
                     travelTime: 2.8, pauseTime: 2.2, phase: 0.4),
        PlanetConfig(symbol: "☊", name: "Rahu",   color: Color(hex: "C084FC"),
                     size: 32, startXFrac: 0.06, startYFrac: 0.42,
                     travelTime: 2.1, pauseTime: 1.8, phase: 1.9),
        PlanetConfig(symbol: "☋", name: "Ketu",   color: Color(hex: "FB923C"),
                     size: 29, startXFrac: 0.91, startYFrac: 0.37,
                     travelTime: 1.5, pauseTime: 1.3, phase: 2.4),
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(configs) { config in
                FloatingPlanet(config: config, bounds: geo.size)
            }
        }
        .ignoresSafeArea()
    }
}

private struct FloatingPlanet: View {
    let config: FloatingPlanetsLayer.PlanetConfig
    let bounds: CGSize

    @State private var position: CGPoint = .zero

    // Keep orbs away from screen edges
    private var margin: CGFloat { config.size * 0.8 }

    private func randomPoint() -> CGPoint {
        CGPoint(
            x: CGFloat.random(in: margin...(bounds.width  - margin)),
            y: CGFloat.random(in: margin...(bounds.height - margin))
        )
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // soft glow
                Circle()
                    .fill(config.color.opacity(0.15))
                    .frame(width: config.size + 14, height: config.size + 14)
                    .blur(radius: 7)
                // orb body
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [config.color.opacity(0.55), config.color.opacity(0.12)],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: config.size * 0.7
                        )
                    )
                    .frame(width: config.size, height: config.size)
                    .overlay(Circle().stroke(config.color.opacity(0.45), lineWidth: 0.75))
                // astrological symbol
                Text(config.symbol)
                    .font(.system(size: config.size * 0.38))
                    .foregroundStyle(config.color.opacity(0.9))
            }
            Text(config.name)
                .font(.system(size: 7, weight: .medium))
                .foregroundStyle(config.color.opacity(0.6))
                .tracking(0.8)
        }
        .opacity(0.75)
        .position(position)
        .onAppear {
            // Snap to starting position before animation begins
            position = CGPoint(
                x: bounds.width  * config.startXFrac,
                y: bounds.height * config.startYFrac
            )
        }
        .task {
            // Stagger start across planets
            try? await Task.sleep(for: .seconds(config.phase))
            while !Task.isCancelled {
                // Spring to a random point anywhere on screen
                withAnimation(
                    .spring(response: config.travelTime, dampingFraction: 0.62)
                ) {
                    position = randomPoint()
                }
                // Linger, then move again
                try? await Task.sleep(
                    for: .seconds(config.travelTime + config.pauseTime)
                )
            }
        }
    }
}

// MARK: - Feature chip

private struct LaunchChip: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
            Text(label)
                .font(.chBodyMedium(11))
        }
        .foregroundStyle(Color.chGlassTitle)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.10))
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(Color.chCream.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    LaunchView()
        .environment(AppState())
}
