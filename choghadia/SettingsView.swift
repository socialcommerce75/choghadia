import SwiftUI

private enum SettingsDestination: String, Identifiable {
    case savedPlaces
    case language
    case signIn
    case privacy
    case terms
    case contact

    var id: String { rawValue }
}

struct SettingsView: View {
    @State private var placesStore = SavedPlacesStore.shared
    @AppStorage("choghadia.preferredLanguage.v1") private var preferredLanguage = "en"
    @AppStorage("choghadia.appearance.v1") private var appearance = "dark"
    @State private var destination: SettingsDestination?
    @State private var showingPlus = false

    private var languageName: String {
        LanguageChoice.all.first(where: { $0.id == preferredLanguage })?.name ?? "English"
    }

    var body: some View {
        ZStack {
            Image("Background-Diya")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    accountCard
                    plusCard

                    SettingsSectionHeading(title: "Preferences", subtitle: "Make Choghadia yours")
                    SettingsGlassPanel {
                        SettingsMenuRow(
                            symbol: "mappin.and.ellipse",
                            title: "Saved places",
                            subtitle: placesStore.places.isEmpty ? "Add a city for local timings" : "\(placesStore.places.count) saved \(placesStore.places.count == 1 ? "place" : "places")",
                            value: placesStore.selectedPlace?.name,
                            action: { destination = .savedPlaces }
                        )
                        SettingsRowDivider()
                        SettingsMenuRow(
                            symbol: "globe",
                            title: "Language",
                            subtitle: "Choose your preferred language",
                            value: languageName,
                            action: { destination = .language }
                        )
                    }
                    appearanceWidget

                    SettingsSectionHeading(title: "About and support", subtitle: "Helpful information")
                    SettingsGlassPanel {
                        SettingsMenuRow(
                            symbol: "arrow.clockwise",
                            title: "Restore Purchases",
                            subtitle: "Restore a previous Plus purchase",
                            action: { }
                        )
                        Text("Already paid for Plus? Tap to get it back on this phone, for example after reinstalling or switching devices.")
                            .font(.chBody(12))
                            .foregroundStyle(Color.chGlassTitle)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, 49)
                            .padding(.top, 2)
                            .padding(.bottom, 8)
                        SettingsRowDivider()
                        SettingsMenuRow(
                            symbol: "hand.raised",
                            title: "Privacy Policy",
                            subtitle: "How your information is handled",
                            action: { destination = .privacy }
                        )
                        SettingsRowDivider()
                        SettingsMenuRow(
                            symbol: "doc.text",
                            title: "Terms of Use",
                            subtitle: "Terms for using Choghadia",
                            action: { destination = .terms }
                        )
                        SettingsRowDivider()
                        SettingsMenuRow(
                            symbol: "bubble.left.and.bubble.right",
                            title: "Contact us",
                            subtitle: "Get help or share feedback",
                            action: { destination = .contact }
                        )
                    }

                    appFooter
                }
                .padding(.horizontal, CH.pagePadding)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .safeAreaPadding(.top, 28)
            .scrollIndicators(.hidden)
        }
        .background(Color.chInk.ignoresSafeArea())
        .sheet(item: $destination) { destination in
            switch destination {
            case .savedPlaces:
                SavedPlacesSheet(store: placesStore)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            case .language:
                LanguagePickerSheet(selection: $preferredLanguage)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            case .signIn:
                SignInOptionsSheet()
                    .presentationDetents([.height(390)])
                    .presentationDragIndicator(.visible)
            case .privacy:
                SettingsInfoSheet(kind: .privacy)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            case .terms:
                SettingsInfoSheet(kind: .terms)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            case .contact:
                SettingsInfoSheet(kind: .contact)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .fullScreenCover(isPresented: $showingPlus) {
            ChoghadiaPlusView()
        }
    }

    private var header: some View {
        VStack(spacing: 0) {
            Image("Ganesha")
                .resizable()
                .scaledToFit()
                .frame(width: 108, height: 108)
                .accessibilityLabel("Ganesha")
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .padding(.top, 34)
    }

    private var plusCard: some View {
        SettingsGlassPanel {
            SettingsMenuRow(
                symbol: "sparkles",
                title: "Choghadia Plus",
                subtitle: "Instant answers from the AI guide",
                action: { showingPlus = true }
            )
        }
    }

    private var appearanceWidget: some View {
        SettingsGlassPanel {
            VStack(alignment: .leading, spacing: 10) {
                Text("Appearance")
                    .font(.chBodySemibold(15))
                    .foregroundStyle(.white)

                HStack(spacing: 7) {
                    appearanceButton("Light", value: "light")
                    appearanceButton("Dark", value: "dark")
                    appearanceButton("Auto", value: "auto")
                }
            }
            .padding(.vertical, 10)
        }
    }

    private func appearanceButton(_ title: String, value: String) -> some View {
        let isSelected = appearance == value
        return Button {
            appearance = value
        } label: {
            Text(title)
                .font(.chBodyMedium(12))
                .foregroundStyle(isSelected ? Color.chInk : Color.white)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    isSelected ? Color.chSaffron : Color.white.opacity(0.08),
                    in: Capsule()
                )
                .overlay(Capsule().stroke(isSelected ? Color.clear : Color.chCream.opacity(0.24), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel("\(title) appearance")
    }

    private var accountCard: some View {
        SettingsGlassPanel {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle().fill(Color.chSaffron.opacity(0.18))
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(Color.chSaffron)
                }
                .frame(width: 46, height: 46)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("You’re using Choghadia as a guest")
                        .font(.chBodySemibold(15))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Your saved places and language stay on this iPhone.")
                        .font(.chBody(12))
                        .foregroundStyle(Color.chGlassTitle)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 6)

            Button {
                destination = .signIn
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.key")
                    Text("Sign in")
                }
                .font(.chBodySemibold(14))
                .foregroundStyle(Color.chInk)
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(Color.chSaffron, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityHint("Choose Apple, Google, or Yahoo sign-in")
            .padding(.top, 12)
            .padding(.bottom, 6)
        }
    }

    private var appFooter: some View {
        SettingsFooterCard {
            VStack(spacing: 5) {
                Image("SettingsAppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .padding(.bottom, 2)
                Text("Choghadia")
                    .font(.chHeadingMedium(20))
                    .foregroundStyle(Color.chGlassTitle)
                Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                    .font(.chBody(12))
                    .foregroundStyle(Color.chGlassNote)
                Text("Timings from your own sunrise and sunset.")
                    .font(.chBody(12))
                    .foregroundStyle(Color.chGlassNote)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 2)
    }
}

private struct SettingsSectionHeading: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.chBodySemibold(15))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.chBody(12))
                .foregroundStyle(Color.chGlassNote)
        }
        .padding(.top, 5)
        .accessibilityElement(children: .combine)
    }
}

private struct SettingsGlassPanel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 5)
        .background {
            let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)
            shape
                .fill(.ultraThinMaterial)
                .overlay {
                    shape.fill(
                        LinearGradient(
                            colors: [Color(hex: "403568").opacity(0.78), Color(hex: "211B45").opacity(0.91)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                .overlay { shape.fill(Color.white.opacity(0.035)) }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.chCream.opacity(0.28), lineWidth: 1)
        }
    }
}

private struct SettingsFooterCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 17)
            .background {
                let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)
                shape
                    .fill(.ultraThinMaterial)
                    .overlay {
                        shape.fill(
                            LinearGradient(
                                colors: [Color(hex: "352A59").opacity(0.70), Color(hex: "17112F").opacity(0.82)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }
                    .overlay { shape.fill(Color.white.opacity(0.045)) }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.chCream.opacity(0.23), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 7)
            .accessibilityElement(children: .combine)
    }
}

private struct SettingsMenuRow: View {
    let symbol: String
    let title: String
    let subtitle: String
    var value: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 11) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.chSaffron)
                    .frame(width: 38, height: 38)
                    .background(Color.chSaffron.opacity(0.13), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.chBodyMedium(14))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.chBody(11))
                        .foregroundStyle(Color.chGlassTitle)
                        .lineLimit(1)
                }
                Spacer(minLength: 2)
                if let value {
                    Text(value)
                        .font(.chBody(11))
                        .foregroundStyle(Color.chGlassTitle)
                        .lineLimit(1)
                        .frame(maxWidth: 96, alignment: .trailing)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.chGlassNote)
            }
            .frame(minHeight: 58)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens \(title)")
    }
}

private struct SettingsRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.chCream.opacity(0.16))
            .frame(height: 1)
            .padding(.leading, 49)
            .accessibilityHidden(true)
    }
}

private struct LanguageChoice: Identifiable {
    let id: String
    let name: String
    let nativeName: String
    let todayPreview: String
    let nowPreview: String

    static let all = [
        LanguageChoice(id: "en", name: "English", nativeName: "English", todayPreview: "Today", nowPreview: "Right now"),
        LanguageChoice(id: "hi", name: "Hindi", nativeName: "हिन्दी", todayPreview: "आज", nowPreview: "अभी"),
        LanguageChoice(id: "mr", name: "Marathi", nativeName: "मराठी", todayPreview: "आज", nowPreview: "आत्ता"),
        LanguageChoice(id: "gu", name: "Gujarati", nativeName: "ગુજરાતી", todayPreview: "આજ", nowPreview: "હમણાં")
    ]
}

private struct LanguagePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: String

    private var selectedChoice: LanguageChoice {
        LanguageChoice.all.first(where: { $0.id == selection }) ?? LanguageChoice.all[0]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(LanguageChoice.all) { choice in
                        Button {
                            selection = choice.id
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(choice.name)
                                        .font(.chBodySemibold(15))
                                        .foregroundStyle(.white)
                                    Text(choice.nativeName)
                                        .font(.chBody(12))
                                        .foregroundStyle(Color.chGlassTitle)
                                }
                                Spacer()
                                if choice.id == selection {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.chSaffron)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(.horizontal, 14)
                            .frame(minHeight: 58)
                            .background(Color.white.opacity(choice.id == selection ? 0.12 : 0.055), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .stroke(choice.id == selection ? Color.chSaffron.opacity(0.72) : Color.chCream.opacity(0.20), lineWidth: 1)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(choice.id == selection ? .isSelected : [])
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Preview")
                            .font(.chBody(11))
                            .foregroundStyle(Color.chGlassNote)
                        Text("\(selectedChoice.todayPreview) · \(selectedChoice.nowPreview)")
                            .font(.chHeadingMedium(22))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(15)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 17).stroke(Color.chCream.opacity(0.22), lineWidth: 1))
                    .padding(.top, 5)

                    Text("Your choice is saved on this iPhone. More translated app content is on the way.")
                        .font(.chBody(12))
                        .foregroundStyle(Color.chGlassTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, CH.pagePadding)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(Color.chInk)
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.chSaffron)
                }
            }
        }
    }
}

private enum SettingsInfoKind {
    case privacy
    case terms
    case contact

    var title: String {
        switch self {
        case .privacy: "Privacy Policy"
        case .terms: "Terms of Use"
        case .contact: "Contact us"
        }
    }

    var symbol: String {
        switch self {
        case .privacy: "hand.raised"
        case .terms: "doc.text"
        case .contact: "bubble.left.and.bubble.right"
        }
    }

    var bodyText: String {
        switch self {
        case .privacy:
            "Saved places and your language preference are stored on this iPhone. Account sign-in and syncing are not connected yet. A complete privacy policy will be published here before release."
        case .terms:
            "The complete terms for using Choghadia will be published here before release."
        case .contact:
            "Support contact details are not configured yet. This drawer will provide a direct way to reach the Choghadia team when support is ready."
        }
    }

    var footnote: String {
        switch self {
        case .privacy: "Your saved places remain on your device unless you choose to use future account sync."
        case .terms: "Please check back when the app is ready for public release."
        case .contact: "For now, use the feedback channel shared with the Choghadia team."
        }
    }
}

private struct SettingsInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    let kind: SettingsInfoKind

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 11) {
                Image(systemName: kind.symbol)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(Color.chSaffron)
                    .frame(width: 42, height: 42)
                    .background(Color.chSaffron.opacity(0.15), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                Text(kind.title)
                    .font(.chHeadingMedium(24))
                    .foregroundStyle(.white)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.chGlassTitle)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.09), in: Circle())
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Close")
            }

            Text(kind.bodyText)
                .font(.chBody(15))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)

            Text(kind.footnote)
                .font(.chBody(12))
                .foregroundStyle(Color.chGlassTitle)
                .fixedSize(horizontal: false, vertical: true)
                .padding(13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.075), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 22)
        .padding(.top, 24)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.chInk.ignoresSafeArea())
    }
}

private struct SignInOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showUnavailableNotice = false
    @State private var selectedProvider = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sign in")
                        .font(.chHeadingMedium(25))
                        .foregroundStyle(.white)
                    Text("Choose an account provider")
                        .font(.chBody(13))
                        .foregroundStyle(Color.chGlassTitle)
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.chGlassTitle)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.09), in: Circle())
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Close sign in")
            }
            .padding(.bottom, 2)

            providerButton("Apple", symbol: "apple.logo", symbolText: nil)
            providerButton("Google", symbol: nil, symbolText: "G")
            providerButton("Yahoo", symbol: nil, symbolText: "Y!")

            Text("Sign-in and account syncing will be connected in a future update. Your places stay on this iPhone for now.")
                .font(.chBody(12))
                .foregroundStyle(Color.chGlassTitle)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .padding(.horizontal, 22)
        .padding(.top, 25)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.chInk.ignoresSafeArea())
        .alert("Sign-in isn’t available yet", isPresented: $showUnavailableNotice) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(selectedProvider) sign-in will be available when account services are connected.")
        }
    }

    private func providerButton(_ title: String, symbol: String?, symbolText: String?) -> some View {
        Button {
            selectedProvider = title
            showUnavailableNotice = true
        } label: {
            HStack(spacing: 12) {
                Group {
                    if let symbol {
                        Image(systemName: symbol)
                            .font(.system(size: 20, weight: .medium))
                    } else {
                        Text(symbolText ?? "")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .frame(width: 26)
                Text("Continue with \(title)")
                    .font(.chBodySemibold(14))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
                    .opacity(0.65)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Color.white.opacity(0.085), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.chCream.opacity(0.24), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
