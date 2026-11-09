import CoreLocation
import Observation
import SwiftUI

// MARK: - Replaceable Today data

private enum DemoSlotLabel {
    case favourable
    case mostFavorable
    case neutral
    case holdOff

    var title: String {
        switch self {
        case .favourable: "Favorable"
        case .mostFavorable: "Most favorable"
        case .neutral: "Neutral"
        case .holdOff: "Hold off"
        }
    }

    var symbol: String {
        switch self {
        case .favourable: "checkmark"
        case .mostFavorable: "checkmark"
        case .neutral: "minus"
        case .holdOff: "xmark"
        }
    }

    var color: Color {
        switch self {
        case .favourable: .chFavourable
        case .mostFavorable: Color(hex: "167A4F")
        case .neutral: .chNeutral
        case .holdOff: .chHoldOff
        }
    }

    var tint: Color {
        switch self {
        case .favourable: .chFavourableTint
        case .mostFavorable: Color(hex: "CDEBDD")
        case .neutral: .chNeutralTint
        case .holdOff: .chHoldOffTint
        }
    }

    var darkTint: Color {
        switch self {
        case .favourable: Color(hex: "123B35")
        case .mostFavorable: Color(hex: "103A2B")
        case .neutral: Color(hex: "3D3016")
        case .holdOff: Color(hex: "45172B")
        }
    }

    var textColor: Color {
        switch self {
        case .favourable: .chFavourableText
        case .mostFavorable: Color(hex: "145C3F")
        case .neutral: .chNeutralText
        case .holdOff: .chHoldOffText
        }
    }

    var darkTextColor: Color {
        switch self {
        case .favourable: Color(hex: "7FE0C8")
        case .mostFavorable: Color(hex: "7FE0A7")
        case .neutral: Color(hex: "F2C66D")
        case .holdOff: Color(hex: "FF9DB8")
        }
    }
}

private struct TodaySlot: Identifiable {
    let id: Int
    let name: String
    let start: String
    let end: String
    let startMinutes: Int
    let endMinutes: Int
    let label: DemoSlotLabel
    let meaning: String

    var range: String { "\(start) – \(end)" }
}

private enum TodayDemoData {
    static let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 11, day: 8))!
    static let timeZone = TimeZone(identifier: "America/New_York")!
    static let sunriseMinutes = 6 * 60 + 29
    static let sunsetMinutes = 16 * 60 + 42
    static let nowMinutes = 11 * 60 + 48
    static let currentSlot = 4

    static let slots: [TodaySlot] = [
        .init(id: 0, name: "Udveg", start: "6:29 AM", end: "7:46 AM", startMinutes: 389, endMinutes: 466, label: .holdOff, meaning: "Restless energy. Routine work is fine; fresh starts are better left for later."),
        .init(id: 1, name: "Chal", start: "7:46 AM", end: "9:02 AM", startMinutes: 466, endMinutes: 542, label: .neutral, meaning: "Movement and change. A fair window for travel and errands."),
        .init(id: 2, name: "Labh", start: "9:02 AM", end: "10:19 AM", startMinutes: 542, endMinutes: 619, label: .favourable, meaning: "Gain and progress. A strong window for business and trade."),
        .init(id: 3, name: "Amrit", start: "10:19 AM", end: "11:36 AM", startMinutes: 619, endMinutes: 696, label: .mostFavorable, meaning: "The most supportive window of the day, good for almost anything."),
        .init(id: 4, name: "Kaal", start: "11:36 AM", end: "12:52 PM", startMinutes: 696, endMinutes: 772, label: .holdOff, meaning: "Heavy and slow. Things started here tend to drag."),
        .init(id: 5, name: "Shubh", start: "12:52 PM", end: "2:09 PM", startMinutes: 772, endMinutes: 849, label: .favourable, meaning: "Auspicious and steady. Good for commitments and purchases."),
        .init(id: 6, name: "Rog", start: "2:09 PM", end: "3:25 PM", startMinutes: 849, endMinutes: 925, label: .holdOff, meaning: "Strain and friction. Keep plans light."),
        .init(id: 7, name: "Udveg", start: "3:25 PM", end: "4:42 PM", startMinutes: 925, endMinutes: 1002, label: .holdOff, meaning: "Restless energy. Routine work is fine; fresh starts are better left for later."),
        .init(id: 8, name: "Shubh", start: "4:42 PM", end: "6:26 PM", startMinutes: 1002, endMinutes: 1106, label: .favourable, meaning: "Auspicious and steady. Good for commitments and purchases."),
        .init(id: 9, name: "Amrit", start: "6:26 PM", end: "8:09 PM", startMinutes: 1106, endMinutes: 1209, label: .mostFavorable, meaning: "The most supportive window of the day, good for almost anything."),
        .init(id: 10, name: "Chal", start: "8:09 PM", end: "9:53 PM", startMinutes: 1209, endMinutes: 1313, label: .neutral, meaning: "Movement and change. A fair window for travel and errands."),
        .init(id: 11, name: "Rog", start: "9:53 PM", end: "11:36 PM", startMinutes: 1313, endMinutes: 1416, label: .holdOff, meaning: "Strain and friction. Keep plans light."),
        .init(id: 12, name: "Kaal", start: "11:36 PM", end: "1:20 AM", startMinutes: 1416, endMinutes: 1520, label: .holdOff, meaning: "Heavy and slow. Things started here tend to drag."),
        .init(id: 13, name: "Labh", start: "1:20 AM", end: "3:03 AM", startMinutes: 1520, endMinutes: 1623, label: .favourable, meaning: "Gain and progress. A strong window for business and trade."),
        .init(id: 14, name: "Udveg", start: "3:03 AM", end: "4:47 AM", startMinutes: 1623, endMinutes: 1727, label: .holdOff, meaning: "Restless energy. Routine work is fine; fresh starts are better left for later."),
        .init(id: 15, name: "Shubh", start: "4:47 AM", end: "6:30 AM", startMinutes: 1727, endMinutes: 1830, label: .favourable, meaning: "Auspicious and steady. Good for commitments and purchases.")
    ]

    static func ribbonPosition(for slot: TodaySlot) -> CGFloat {
        CGFloat(slot.startMinutes - sunriseMinutes) / 1440
    }

    static func currentRibbonPosition() -> CGFloat {
        CGFloat(nowMinutes - sunriseMinutes) / 1440
    }
}

@MainActor
@Observable
private final class LocationAccess: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var authorization: CLAuthorizationStatus
    var latitude: Double?
    var longitude: Double?

    override init() {
        authorization = .notDetermined
        super.init()
        manager.delegate = self
        authorization = manager.authorizationStatus
        if authorization == .authorizedAlways || authorization == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }

    var isAuthorized: Bool {
        authorization == .authorizedAlways || authorization == .authorizedWhenInUse
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
        if authorization == .authorizedAlways || authorization == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }
}

// MARK: - Today screen

struct TodayView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(AppState.self) private var appState

    @State private var location = LocationAccess()
    @State private var placesStore = SavedPlacesStore.shared
    #if DEBUG
    @State private var showingPlaces = ProcessInfo.processInfo.arguments.contains("-showPlaces")
    #else
    @State private var showingPlaces = false
    #endif
    @State private var showingLocationAlert = false
    @State private var showingSlot: Int? = TodayDemoData.currentSlot
    @State private var showEarlierSlots = false
    @State private var autoScrolled = false
    @State private var pulse = false
    @State private var arcDrawn = false
    @State private var sunProgress: CGFloat = 0
    @State private var shouldAnimateArcOnEntry = true

    private let pageInset = CH.pagePadding
    private var nowSlot: TodaySlot { TodayDemoData.slots[TodayDemoData.currentSlot] }

    var body: some View {
        ZStack {
            Image("Background-Diya")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityHidden(true)
                .allowsHitTesting(false)

            if colorScheme == .dark {
                Color.chInk.opacity(0.12)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            }

            TodayBackdropTint(minutes: TodayDemoData.nowMinutes)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            header
                            locationPrompt
                                .padding(.horizontal, pageInset)
                                .padding(.top, 12)
                            heroCard
                                .padding(.horizontal, pageInset)
                                .padding(.top, 12)
                            DayRibbonCard(
                                selectedSlot: showingSlot ?? TodayDemoData.currentSlot,
                                pulse: pulse,
                                onSelect: { slot in selectSlot(slot, proxy: proxy) }
                            )
                            .padding(.horizontal, pageInset)
                            .padding(.top, 20)
                            timeline(proxy: proxy)
                                .padding(.horizontal, pageInset)
                                .padding(.top, 20)
                            // Keep the final slot and its boundary above the floating tab bar.
                            Color.clear.frame(height: 120)
                        }
                    }
                    .scrollIndicators(.hidden)
                    .safeAreaPadding(.top, 20)
                    .onAppear {
                        guard !autoScrolled else { return }
                        autoScrolled = true
                        Task { @MainActor in
                            // Let the arc build and sun sweep finish before moving the page.
                            try? await Task.sleep(for: reduceMotion ? .milliseconds(150) : .milliseconds(1_600))
                            guard !Task.isCancelled else { return }
                            await Task.yield()
                            for attempt in 0..<2 {
                                if attempt > 0 {
                                    try? await Task.sleep(for: .milliseconds(300))
                                }
                                if reduceMotion {
                                    proxy.scrollTo(scrollTarget(for: TodayDemoData.currentSlot), anchor: .center)
                                } else {
                                    withAnimation(.easeInOut(duration: 0.8)) {
                                        proxy.scrollTo(scrollTarget(for: TodayDemoData.currentSlot), anchor: .center)
                                    }
                                }
                            }
                        }
                    }
                }
        }
        .background(Color.chInk.ignoresSafeArea())
        .sheet(isPresented: $showingPlaces) {
            SavedPlacesSheet(store: placesStore)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .alert("Turn on Location", isPresented: $showingLocationAlert) {
            Button("Open Settings") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                openURL(url)
            }
            Button("Choose a city") { showingPlaces = true }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choghadia uses your location to show timings for your area. You can also choose a city and keep using the app without location access.")
        }
        .onAppear {
            if shouldAnimateArcOnEntry {
                shouldAnimateArcOnEntry = false
                playArcEntrance()
            }
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { pulse = true }
            }
        }
        .onDisappear { shouldAnimateArcOnEntry = true }
    }

    private func playArcEntrance() {
        let destination = CGFloat(TodayDemoData.nowMinutes - TodayDemoData.sunriseMinutes) /
            CGFloat(TodayDemoData.sunsetMinutes - TodayDemoData.sunriseMinutes)
        arcDrawn = false
        sunProgress = 0
        guard !reduceMotion else {
            arcDrawn = true
            sunProgress = destination
            return
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(80))
            guard !Task.isCancelled else { return }
            arcDrawn = true
            withAnimation(.spring(response: 1.05, dampingFraction: 0.78).delay(0.10)) {
                sunProgress = destination
            }
        }
    }

    private var header: some View {
        let placeName = placesStore.selectedPlace?.name ?? (location.isAuthorized ? "Your location" : "Choose your location")
        return HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(TodayDemoData.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day().year()))
                    .font(.chHeading(18))
                    .foregroundStyle(.white.opacity(0.88))
                Button {
                    showingPlaces = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text(placeName)
                            .font(.chBodyMedium(13))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(Color.chSaffron)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 32)
                    .background(Color.chSaffron.opacity(0.16), in: Capsule())
                    .overlay(Capsule().stroke(Color.chSaffron.opacity(0.55), lineWidth: 1))
                    .frame(minHeight: CH.minTarget)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Location: \(placeName). Change location")
            }
            Spacer()
        }
        .padding(.horizontal, pageInset + 2)
        .padding(.top, 48)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private var locationPrompt: some View {
        if placesStore.selectedPlace == nil && !location.isAuthorized {
            LocationPromptCard(
                isDenied: location.authorization == .denied || location.authorization == .restricted,
                turnOn: {
                    if location.authorization == .notDetermined {
                        location.requestPermission()
                    } else {
                        showingLocationAlert = true
                    }
                },
                chooseCity: { showingPlaces = true }
            )
        }
    }

    private var heroCard: some View {
        GlassCard(cornerRadius: 22, padding: 17, tone: .heroPurple) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Right now")
                        .font(.chBodyMedium(13))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("11:48 AM · EST")
                        .font(.chBody(12))
                        .foregroundStyle(.white)
                }

                SunArcView(
                    currentSlot: TodayDemoData.currentSlot,
                    pulse: pulse,
                    arcDrawn: arcDrawn,
                    sunProgress: sunProgress,
                    reduceMotion: reduceMotion
                )
                    .frame(height: 158)
                    .padding(.top, 2)

                HStack {
                    Label("Sunrise  6:29 AM", systemImage: "sunrise")
                    Spacer(minLength: 8)
                    Label("Sunset  4:42 PM", systemImage: "sunset")
                }
                .font(.chBody(11))
                .foregroundStyle(.white)
                .labelStyle(.titleAndIcon)

                HStack(alignment: .top, spacing: 10) {
                    SlotStatusChip(label: nowSlot.label)
                    Text("Not a good time to begin something new, like signing, buying or launching. Routine tasks are fine.")
                        .font(.chBody(13))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 14)

                HStack(spacing: 9) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.chSaffron)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Better time to begin")
                            .font(.chBody(11))
                            .foregroundStyle(.white)
                        Text("Shubh from 12:52 PM")
                            .font(.chBodySemibold(17))
                            .foregroundStyle(.white)
                    }
                    Spacer(minLength: 2)
                    Text("in 1h 04m")
                        .font(.chBodyMedium(12))
                        .foregroundStyle(Color.chSaffron)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background {
                    let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
                    shape
                        .fill(.ultraThinMaterial)
                        .overlay {
                            shape.fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "75435F").opacity(0.72),
                                        Color(hex: "49304F").opacity(0.84)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.chSaffron.opacity(0.85), lineWidth: 1.5)
                }
                .padding(.top, 12)
            }
        }
    }

    private func timeline(proxy: ScrollViewProxy) -> some View {
        GlassCard(cornerRadius: 24, padding: 11, tone: .heroPurple) {
            VStack(spacing: 0) {
                Toggle(isOn: $showEarlierSlots) {
                    Text(showEarlierSlots ? "Hide earlier time slots" : "Show earlier time slots")
                        .font(.chBody(13))
                        .foregroundStyle(.white)
                }
                .tint(Color.chSaffron)
                .padding(.horizontal, 4)
                .frame(minHeight: 44)

                let visibleSlots = TodayDemoData.slots.filter { showEarlierSlots || $0.id >= TodayDemoData.currentSlot }
                ForEach(visibleSlots) { slot in
                    VStack(spacing: 0) {
                        TimelineBoundary(
                            time: slot.start,
                            dotColor: slot.label.color,
                            isCurrent: slot.id == TodayDemoData.currentSlot,
                            isFirst: slot.id == visibleSlots.first?.id,
                            topIsPast: slot.id <= TodayDemoData.currentSlot,
                            bottomIsPast: slot.id < TodayDemoData.currentSlot
                        )
                        TimelineSlotRow(
                            slot: slot,
                            isCurrent: slot.id == TodayDemoData.currentSlot,
                            isPast: slot.id < TodayDemoData.currentSlot,
                            isExpanded: showingSlot == slot.id,
                            timezone: "EST",
                            toggle: {
                                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) {
                                    showingSlot = showingSlot == slot.id ? nil : slot.id
                                }
                            },
                            askAI: {
                                appState.selectedTab = 1
                            }
                        )
                    }
                    .id(scrollTarget(for: slot.id))
                }
                if let last = visibleSlots.last {
                    TimelineBoundary(
                        time: last.end,
                        dotColor: last.label.color,
                        isCurrent: false,
                        isFirst: false,
                        topIsPast: last.id < TodayDemoData.currentSlot,
                        bottomIsPast: false
                    )
                }
            }
        }
        .accessibilityIdentifier("today.timeline")
    }

    private func selectSlot(_ id: Int, proxy: ScrollViewProxy) {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) {
            showEarlierSlots = id >= TodayDemoData.currentSlot ? showEarlierSlots : true
            showingSlot = id
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if reduceMotion {
                proxy.scrollTo(scrollTarget(for: id), anchor: .center)
            } else {
                withAnimation(.easeInOut(duration: 0.7)) { proxy.scrollTo(scrollTarget(for: id), anchor: .center) }
            }
        }
    }

    private func scrollTarget(for slotID: Int) -> String { "today-slot-\(slotID)" }
}

// MARK: - Background tint and vignette

private struct TodayBackdropTint: View {
    @Environment(\.colorScheme) private var colorScheme
    let minutes: Int
    private var isLight: Bool { colorScheme == .light }

    // Glow colour keyed to minutes since midnight; blended between neighbours.
    private static let keys: [(minute: Int, color: UIColor)] = [
        (0,    UIColor(red: 0.20, green: 0.17, blue: 0.50, alpha: 1)),  // deep indigo
        (330,  UIColor(red: 0.20, green: 0.17, blue: 0.50, alpha: 1)),
        (420,  UIColor(red: 0.96, green: 0.68, blue: 0.40, alpha: 1)),  // dawn gold
        (720,  UIColor(red: 0.98, green: 0.78, blue: 0.45, alpha: 1)),  // midday warm
        (1020, UIColor(red: 0.96, green: 0.58, blue: 0.40, alpha: 1)),  // late afternoon
        (1110, UIColor(red: 0.89, green: 0.42, blue: 0.55, alpha: 1)),  // dusk rose
        (1230, UIColor(red: 0.20, green: 0.17, blue: 0.50, alpha: 1)),  // night
        (1440, UIColor(red: 0.20, green: 0.17, blue: 0.50, alpha: 1))
    ]

    private var glow: Color {
        let m = minutes % 1440
        guard let upper = Self.keys.firstIndex(where: { $0.minute >= m }), upper > 0 else {
            return Color(Self.keys[0].color)
        }
        let a = Self.keys[upper - 1], b = Self.keys[upper]
        let t = CGFloat(m - a.minute) / CGFloat(max(b.minute - a.minute, 1))
        var (r1, g1, b1, r2, g2, b2): (CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0, 0, 0)
        a.color.getRed(&r1, green: &g1, blue: &b1, alpha: nil)
        b.color.getRed(&r2, green: &g2, blue: &b2, alpha: nil)
        return Color(red: r1 + (r2 - r1) * t, green: g1 + (g2 - g1) * t, blue: b1 + (b2 - b1) * t)
    }

    var body: some View {
        ZStack {
            // Time-of-day wash, strongest at the top where the sky would be.
            LinearGradient(colors: [glow.opacity(isLight ? 0.08 : 0.26), glow.opacity(isLight ? 0.02 : 0.06), .clear],
                           startPoint: .top, endPoint: .center)
            // Vignette so cards float above the artwork.
            LinearGradient(colors: [Color.black.opacity(isLight ? 0.10 : 0.38), .clear],
                           startPoint: .top, endPoint: UnitPoint(x: 0.5, y: 0.22))
            LinearGradient(colors: [.clear, Color.black.opacity(isLight ? 0.12 : 0.42)],
                           startPoint: UnitPoint(x: 0.5, y: 0.72), endPoint: .bottom)
        }
    }
}

// MARK: - Reusable glass and status components

private enum GlassTone: Equatable {
    case standard
    case recessed
    case heroWarm
    case heroPurple
}

private struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat
    let padding: CGFloat
    var tone: GlassTone = .standard
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background {
                let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                shape
                    .fill(.ultraThinMaterial)
                    .overlay {
                        shape.fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }
                    .overlay { shape.fill(Color.white.opacity(colorScheme == .dark ? 0 : 0.035)) }
                    .overlay {
                        // Soft saffron light from the upper right on the hero card.
                        if tone == .heroPurple {
                            shape.fill(
                                RadialGradient(
                                    colors: [Color.chSaffron.opacity(0.30), Color.chSaffron.opacity(0.08), .clear],
                                    center: .topTrailing,
                                    startRadius: 4,
                                    endRadius: 300
                                )
                            )
                        }
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.chCream.opacity(0.28), lineWidth: 1)
            }
    }

    private var gradientColors: [Color] {
        if colorScheme == .dark, tone != .heroWarm, tone != .heroPurple {
            // Matches the prototype's dark glass: 7% white tint over a 16pt backdrop blur.
            return [Color.white.opacity(0.07), Color.white.opacity(0.07)]
        }
        switch tone {
        case .standard:
            return [Color(hex: "403568").opacity(0.52), Color(hex: "211B45").opacity(0.62)]
        case .recessed:
            return [Color(hex: "110D29").opacity(0.86), Color(hex: "1B163B").opacity(0.85)]
        case .heroWarm:
            return [Color(hex: "795B27").opacity(0.62), Color(hex: "382847").opacity(0.80)]
        case .heroPurple:
            return [Color(hex: "281F4F").opacity(0.97), Color(hex: "130F2B").opacity(0.98)]
        }
    }
}

private struct SlotStatusChip: View {
    @Environment(\.colorScheme) private var colorScheme
    let label: DemoSlotLabel

    var body: some View {
        Label(label.title, systemImage: label.symbol)
            .font(.chBodyMedium(11))
            .foregroundStyle(colorScheme == .dark ? label.darkTextColor : label.textColor)
            .padding(.horizontal, 9)
            .frame(minHeight: 27)
            .background(colorScheme == .dark ? label.darkTint : label.tint, in: Capsule())
            .accessibilityElement(children: .combine)
    }
}

private struct LocationPromptCard: View {
    let isDenied: Bool
    let turnOn: () -> Void
    let chooseCity: () -> Void

    var body: some View {
        GlassCard(cornerRadius: 18, padding: 13) {
            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.chSaffron)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(isDenied ? "Location is off" : "Set your location")
                            .font(.chBodySemibold(14))
                            .foregroundStyle(.white)
                        Text("Use your location for local timings, or choose a city instead.")
                            .font(.chBody(12))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                HStack(spacing: 8) {
                    Button(action: turnOn) {
                        Text(isDenied ? "Turn on Location" : "Use my location")
                            .font(.chBodyMedium(12))
                            .foregroundStyle(Color.chInk)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.chSaffron, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    Button(action: chooseCity) {
                        Text("Choose a city")
                            .font(.chBodyMedium(12))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.chCream.opacity(0.3), lineWidth: 1))
                    }
                }
            }
        }
    }
}

// MARK: - Arc visualization

private struct SunArcView: View {
    let currentSlot: Int
    let pulse: Bool
    var arcDrawn: Bool
    var sunProgress: CGFloat
    let reduceMotion: Bool

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let center = CGPoint(x: size.width / 2, y: size.height * 0.92)
            let radius = min(size.width * 0.43, size.height * 0.72)

            ZStack {
                Path { horizon in
                    horizon.move(to: CGPoint(x: 12, y: center.y))
                    horizon.addLine(to: CGPoint(x: size.width - 12, y: center.y))
                }
                .stroke(Color.white.opacity(0.08), lineWidth: 1)

                ForEach(0..<8, id: \.self) { index in
                    let slot = TodayDemoData.slots[index]
                    let opacity = index < currentSlot ? 0.42 : 1
                    ArcSegmentShape(index: index)
                        .trim(from: 0, to: arcDrawn ? 1 : 0)
                        .stroke(
                            slot.label.color.opacity(opacity),
                            style: StrokeStyle(lineWidth: index == currentSlot ? 11 : 7, lineCap: .round)
                        )
                        .shadow(color: index == currentSlot ? slot.label.color.opacity(0.75) : .clear,
                                radius: index == currentSlot ? 8 : 0)
                        .animation(
                            reduceMotion ? nil : .easeOut(duration: 0.22).delay(Double(index) * 0.12),
                            value: arcDrawn
                        )
                }

                let angle = CGFloat.pi - sunProgress * CGFloat.pi
                let sun = CGPoint(x: center.x + radius * cos(angle), y: center.y - radius * sin(angle))
                SunTrailShape(progress: sunProgress)
                    .stroke(
                        LinearGradient(colors: [Color.chSaffron.opacity(0), Color.chSaffron.opacity(0.65)],
                                       startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .blur(radius: 1.5)
                    .animation(reduceMotion ? nil : .spring(response: 1.05, dampingFraction: 0.78).delay(0.10), value: sunProgress)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.chSaffron.opacity(pulse ? 0.55 : 0.38), Color.chSaffron.opacity(0)],
                            center: .center, startRadius: 2, endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                    .position(sun)
                    .animation(reduceMotion ? nil : .spring(response: 1.05, dampingFraction: 0.78).delay(0.10), value: sunProgress)
                Circle()
                    .fill(Color.chGlassTitle)
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(Color.chSaffron, lineWidth: 3))
                    .position(sun)
                    .animation(reduceMotion ? nil : .spring(response: 1.05, dampingFraction: 0.78).delay(0.10), value: sunProgress)

                VStack(spacing: 6) {
                    Spacer().frame(height: size.height * 0.56)
                    Text("Kaal")
                        .font(.chHeadingMedium(28))
                        .foregroundStyle(Color.chElectricCyan)
                    Text("until 12:52 PM")
                        .font(.chBody(12))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Daylight slots. Now Kaal, until 12:52 PM")
    }
}

/// Soft trail along the arc from sunrise to the sun's current position.
private struct SunTrailShape: Shape {
    var progress: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.height * 0.92)
        let radius = min(rect.width * 0.43, rect.height * 0.72)
        var path = Path()
        let steps = 48
        for step in 0...steps {
            let angle = CGFloat.pi - (CGFloat(step) / CGFloat(steps)) * progress * CGFloat.pi
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y - radius * sin(angle))
            step == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        return path
    }
}

private struct ArcSegmentShape: Shape {
    let index: Int

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.height * 0.92)
        let radius = min(rect.width * 0.43, rect.height * 0.72)
        let segmentAngle = CGFloat.pi / 8
        let gapAngle: CGFloat = 0.09
        let start = CGFloat.pi - CGFloat(index) * segmentAngle - gapAngle / 2
        let end = CGFloat.pi - CGFloat(index + 1) * segmentAngle + gapAngle / 2
        let pointOnArc: (CGFloat) -> CGPoint = { angle in
            CGPoint(x: center.x + radius * cos(angle), y: center.y - radius * sin(angle))
        }

        var path = Path()
        path.move(to: pointOnArc(start))
        for step in 1...32 {
            let progress = CGFloat(step) / 32
            let angle = start + (end - start) * progress
            path.addLine(to: pointOnArc(angle))
        }
        return path
    }
}

// MARK: - Day ribbon

private struct DayRibbonCard: View {
    let selectedSlot: Int
    let pulse: Bool
    let onSelect: (Int) -> Void

    private let dayWidth = CGFloat(TodayDemoData.sunsetMinutes - TodayDemoData.sunriseMinutes) / 1440
    private let currentPosition = TodayDemoData.currentRibbonPosition()
    private let gradient = LinearGradient(
        stops: [
            .init(color: Color(hex: "F2A273"), location: 0),
            .init(color: Color(hex: "FFD166"), location: 0.10),
            .init(color: Color(hex: "FFD166"), location: 0.16),
            .init(color: Color(hex: "78D0F2"), location: 0.19),
            .init(color: Color(hex: "4DB8E8"), location: 0.34),
            .init(color: Color(hex: "F6AE60"), location: 0.37),
            .init(color: Color(hex: "EF805E"), location: 0.46),
            .init(color: Color(hex: "A77ACF"), location: 0.49),
            .init(color: Color(hex: "6654B8"), location: 0.58),
            .init(color: Color(hex: "292254"), location: 0.62),
            .init(color: Color(hex: "211A49"), location: 0.92),
            .init(color: Color(hex: "D58AB2"), location: 0.96),
            .init(color: Color(hex: "F2A273"), location: 1)
        ], startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        GlassCard(cornerRadius: 22, padding: 15) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Your day at a glance")
                    .font(.chBodyMedium(14))
                    .foregroundStyle(.white)
                Text("Tap the ribbon to jump to a time of day.")
                    .font(.chBody(11))
                    .foregroundStyle(.white)
                    .padding(.top, 3)

                GeometryReader { geometry in
                    ZStack(alignment: .topLeading) {
                        Text("Now")
                            .font(.chBodyMedium(11))
                            .foregroundStyle(.white)
                            .position(x: geometry.size.width * currentPosition, y: 7)
                        Text("Mon 9 Nov")
                            .font(.chBodyMedium(11))
                            .foregroundStyle(.white)
                            .position(x: geometry.size.width * 0.73, y: 7)

                        RoundedRectangle(cornerRadius: 14)
                            .fill(gradient)
                            .frame(height: 28)
                            .overlay {
                                Canvas { context, size in
                                    for slot in TodayDemoData.slots.dropFirst() {
                                        let x = CGFloat(slot.startMinutes - TodayDemoData.sunriseMinutes) / 1440 * size.width
                                        var tick = Path()
                                        tick.move(to: CGPoint(x: x, y: 0))
                                        tick.addLine(to: CGPoint(x: x, y: size.height))
                                        context.stroke(tick, with: .color(Color.white.opacity(0.28)), lineWidth: 1)
                                    }
                                    var sunset = Path()
                                    sunset.move(to: CGPoint(x: size.width * dayWidth, y: 0))
                                    sunset.addLine(to: CGPoint(x: size.width * dayWidth, y: size.height))
                                    context.stroke(sunset, with: .color(Color.white.opacity(0.66)), lineWidth: 1.5)
                                    var midnight = Path()
                                    midnight.move(to: CGPoint(x: size.width * 0.73, y: 0))
                                    midnight.addLine(to: CGPoint(x: size.width * 0.73, y: size.height))
                                    context.stroke(midnight, with: .color(.white.opacity(0.88)), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .offset(y: 20)

                        Circle()
                            .fill(Color.white.opacity(pulse ? 0.20 : 0.08))
                            .frame(width: 20, height: 20)
                            .position(x: geometry.size.width * currentPosition, y: 34)
                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color.chInk, lineWidth: 2))
                            .position(x: geometry.size.width * currentPosition, y: 34)

                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { point in
                                let fraction = min(max(point.x / geometry.size.width, 0), 0.999)
                                let minute = TodayDemoData.sunriseMinutes + Int(fraction * 1440)
                                let slot = TodayDemoData.slots.first(where: { minute >= $0.startMinutes && minute < $0.endMinutes })?.id ?? 15
                                onSelect(slot)
                            }
                            .accessibilityElement()
                            .accessibilityLabel("Time of day")
                            .accessibilityValue("\(TodayDemoData.slots[selectedSlot].name), \(TodayDemoData.slots[selectedSlot].range)")
                            .accessibilityHint("Swipe up or down to move between the sixteen slots")
                            .accessibilityAdjustableAction { direction in
                                let next: Int
                                switch direction {
                                case .increment: next = min(15, selectedSlot + 1)
                                case .decrement: next = max(0, selectedSlot - 1)
                                @unknown default: next = selectedSlot
                                }
                                onSelect(next)
                            }
                    }
                }
                .frame(height: 54)
                .padding(.top, 7)

                GeometryReader { geometry in
                    ZStack {
                        ribbonIcon("sunrise.fill", color: Color(hex: "FFD166")).position(x: geometry.size.width * 0.115, y: 9)
                        ribbonIcon("sun.max.fill", color: Color(hex: "FFD166")).position(x: geometry.size.width * 0.33, y: 9)
                        ribbonIcon("sunset.fill", color: Color(hex: "F6AE60")).position(x: geometry.size.width * 0.495, y: 9)
                        ribbonIcon("moon.fill", color: Color(hex: "E6DAF0")).position(x: geometry.size.width * 0.78, y: 9)
                    }
                }
                .frame(height: 18)

                LazyVGrid(
                    columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)],
                    alignment: .leading,
                    spacing: 9
                ) {
                    legend("Most favorable", color: Color(hex: "167A4F"))
                    legend("Favorable", color: .chFavourable)
                    legend("Neutral", color: .chNeutral)
                    legend("Hold off", color: .chHoldOff)
                }
                .font(.chBody(11))
                .foregroundStyle(.white)
                .padding(.top, 12)
                .padding(.bottom, 2)
            }
        }
    }

    /// Phase-of-day icon under the ribbon. Decorative: the ribbon itself is the VoiceOver element.
    private func ribbonIcon(_ symbol: String, color: Color) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(color)
            .fixedSize()
            .accessibilityHidden(true)
    }

    private func legend(_ title: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Capsule().fill(color).frame(width: 5, height: 13)
            Text(title)
        }
    }
}

// MARK: - Timeline cards

private struct TimelineSlotRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let slot: TodaySlot
    let isCurrent: Bool
    let isPast: Bool
    let isExpanded: Bool
    let timezone: String
    let toggle: () -> Void
    let askAI: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: toggle) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(slot.name)
                                .font(.chHeadingMedium(isCurrent ? 17 : 16))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            Text("\(slot.range) \(timezone)")
                                .font(.chBody(11))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        HStack(spacing: 6) {
                            if isCurrent {
                                Text("Now")
                                    .font(.chBodyMedium(11))
                                    .foregroundStyle(Color.chInk)
                                    .padding(.horizontal, 9)
                                    .frame(height: 22)
                                    .background(Color(hex: "EDE3D3"), in: Capsule())
                            }
                            SlotStatusChip(label: slot.label)
                        }
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 28)
                }
                .padding(.leading, 16)
                .padding(.trailing, 9)
                .padding(.vertical, isCurrent ? 15 : 11)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(slot.name), \(slot.range) \(timezone), \(slot.label.title)\(isCurrent ? ", now" : "")")
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
            .accessibilityHint("Double-tap to \(isExpanded ? "collapse" : "expand") slot details")

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text(slot.meaning)
                        .font(.chBody(14))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(action: askAI) {
                        HStack(spacing: 7) {
                            Image(systemName: "sparkles")
                            Text("Ask the AI guide")
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                        }
                        .font(.chBodyMedium(12))
                        .foregroundStyle(Color.chText)
                        .padding(.horizontal, 13)
                        .frame(minHeight: 44)
                        .background(Color.chGlassTitle, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 13)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background {
            let shape = RoundedRectangle(cornerRadius: 17, style: .continuous)
            let startColor: Color = if isCurrent {
                Color(hex: "574367")
            } else if isPast {
                Color(hex: "302747")
            } else {
                Color(hex: "40365F")
            }
            let endColor: Color = if isCurrent {
                Color(hex: "35284C")
            } else if isPast {
                Color(hex: "241E3C")
            } else {
                Color(hex: "2A2247")
            }

            shape
                .fill(.ultraThinMaterial)
                .overlay {
                    shape.fill(
                        LinearGradient(
                            colors: [startColor.opacity(0.94), endColor.opacity(0.96)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                .overlay {
                    shape.fill(
                        LinearGradient(
                            colors: [Color.white.opacity(isCurrent ? 0.05 : 0.025), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                // Faint wash in the slot's band colour.
                .overlay { shape.fill(slot.label.color.opacity(isCurrent ? 0.10 : 0.065)) }
                // Warm inner glow for the current slot.
                .overlay {
                    if isCurrent {
                        shape
                            .stroke(Color.chSaffron.opacity(0.5), lineWidth: 8)
                            .blur(radius: 9)
                            .clipShape(shape)
                    }
                }
        }
        .overlay(alignment: .leading) {
            UnevenRoundedRectangle(topLeadingRadius: 17, bottomLeadingRadius: 17)
                .fill(slot.label.color)
                .frame(width: 5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(Color.chCream.opacity(isCurrent ? 0.22 : 0.21), lineWidth: 1)
        }
        .padding(.vertical, 2)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

private struct TimelineBoundary: View {
    @Environment(\.colorScheme) private var colorScheme
    let time: String
    let dotColor: Color
    let isCurrent: Bool
    let isFirst: Bool
    let topIsPast: Bool
    let bottomIsPast: Bool

    var body: some View {
        VStack(spacing: 0) {
            if !isFirst { connector(isSolid: topIsPast) }
            HStack(spacing: 5) {
                Circle().fill(dotColor).frame(width: 6, height: 6)
                Text(time)
                    .font(.chBodyMedium(11))
                    .foregroundStyle(colorScheme == .dark ? Color(hex: "F2ECE1") : Color.chText)
            }
            .padding(.horizontal, 10)
            .frame(height: 22)
            .background(colorScheme == .dark ? Color(hex: "221C46") : Color.chGlassTitle, in: Capsule())
            .overlay {
                Capsule().stroke(
                    isCurrent ? Color.chSaffron.opacity(0.55) : (colorScheme == .dark ? Color(hex: "342D5E") : Color.chBorder),
                    lineWidth: 1
                )
            }
            .accessibilityHidden(true)
            connector(isSolid: bottomIsPast)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, isFirst ? 5 : 0)
        .padding(.bottom, 1)
    }

    private func connector(isSolid: Bool) -> some View {
        Rectangle()
            .fill(isSolid ? Color.chCream.opacity(0.55) : Color.clear)
            .overlay {
                if !isSolid {
                    Rectangle().stroke(style: StrokeStyle(lineWidth: 1, dash: [2, 2])).foregroundStyle(Color.chGlassNote.opacity(0.75))
                }
            }
            .frame(width: 1, height: 10)
            .accessibilityHidden(true)
    }
}

// MARK: - City picker

struct SavedPlacesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    let store: SavedPlacesStore
    @State private var search = ""

    private var isLight: Bool { colorScheme == .light }

    private var results: [SavedPlace] {
        let source = SavedPlace.cityDirectory
        guard !search.isEmpty else { return source }
        return source.filter { $0.name.localizedCaseInsensitiveContains(search) || $0.subtitle.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            List {
                if !store.places.isEmpty {
                    Section("Saved places") {
                        ForEach(store.places) { place in
                            placeRow(place, isSaved: true)
                        }
                        .onDelete { offsets in
                            store.remove(at: offsets)
                        }
                    }
                }

                Section("Choose a city") {
                    ForEach(results.filter { place in !store.places.contains(where: { $0.id == place.id }) }) { place in
                        placeRow(place, isSaved: false)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(isLight ? .hidden : .automatic)
            .background {
                if isLight {
                    LinearGradient(
                        colors: [Color(hex: "2B2552"), Color(hex: "1F1A3D"), Color(hex: "14102B")],
                        startPoint: .top, endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }
            }
            .navigationTitle("Saved places")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $search, prompt: "Search cities")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(isLight ? .dark : nil)
    }

    private func placeRow(_ place: SavedPlace, isSaved: Bool) -> some View {
        Button {
            store.select(place, saveIfNeeded: !isSaved)
            dismiss()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSaved ? "bookmark.fill" : "mappin.and.ellipse")
                    .foregroundStyle(Color.chSaffron)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(place.name).foregroundStyle(.primary)
                    Text(place.subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if store.selectedPlace?.id == place.id {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.chFavourable)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(isLight ? Color.white.opacity(0.08) : Color.chInk.opacity(0.65))
        .accessibilityLabel("Use \(place.name), \(place.subtitle)\(isSaved ? "" : ", and save it")")
    }
}
