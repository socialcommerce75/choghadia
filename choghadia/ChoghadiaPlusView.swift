import SwiftUI

private enum PlusPlan: String, CaseIterable, Identifiable {
    case yearly
    case monthly

    var id: String { rawValue }
    var title: String { self == .yearly ? "Yearly" : "Monthly" }
    var billing: String { self == .yearly ? "a year" : "a month" }
    var storePlan: PlusStore.Plan { self == .yearly ? .yearly : .monthly }
    /// Shown only until the App Store prices load.
    var fallbackPrice: String { self == .yearly ? "$19.99" : "$2.99" }
}

struct ChoghadiaPlusView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlusPlan = .yearly
    @State private var store = PlusStore.shared
    @State private var alertMessage: String?
    @State private var infoKind: SettingsInfoKind?

    private func price(_ plan: PlusPlan) -> String { store.displayPrice(for: plan.storePlan) ?? plan.fallbackPrice }
    private func detail(_ plan: PlusPlan) -> String {
        guard plan == .yearly else { return "Cancel anytime" }
        return store.yearlySavingPercent.map { "Save \($0)%" } ?? "Best value"
    }

    private func subscribe() {
        Task {
            switch await store.purchase(selectedPlan.storePlan) {
            case .success: dismiss()
            case .pending: alertMessage = "Your purchase is waiting for approval. Plus will turn on as soon as it is approved."
            case .cancelled: break
            case .failed(let message): alertMessage = message
            }
        }
    }

    private func restore() {
        Task {
            switch await store.restore() {
            case .restored: dismiss()
            case .nothingToRestore: alertMessage = "We couldn't find a previous Plus purchase for this Apple ID."
            case .failed(let message): alertMessage = message
            }
        }
    }

    var body: some View {
        ZStack {
            Color.chInk.ignoresSafeArea()
            RadialGradient(
                colors: [Color(hex: "49386D").opacity(0.58), .clear],
                center: .topTrailing,
                startRadius: 12,
                endRadius: 390
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    Text("Ask anything. Get an answer in seconds.")
                        .font(.chHeadingMedium(32))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 16)
                    Text("Instant answers about your day, any hour.")
                        .font(.chBody(14))
                        .foregroundStyle(Color.chGlassTitle)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 8)

                    conversationPreview
                        .padding(.top, 18)
                    comparisonCards
                        .padding(.top, 13)
                    planPicker
                        .padding(.top, 17)
                    Text("Choghadia Plus renews automatically at \(price(selectedPlan)) \(selectedPlan.billing) unless you cancel at least 24 hours before the end of the current period. Payment is charged to your Apple ID when you confirm the purchase. You can manage or cancel your subscription any time in your Apple ID account settings.")
                        .font(.chBody(11))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 11)
                        .padding(.bottom, 24)

                }
                .padding(.horizontal, 22)
                .padding(.top, 12)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 5) {
                Button(action: subscribe) {
                    Group {
                        if store.isWorking {
                            ProgressView().tint(Color.chInk)
                        } else {
                            Text(store.isPlus ? "Plus is active" : "Subscribe for \(price(selectedPlan)) \(selectedPlan.billing)")
                        }
                    }
                    .font(.chBodySemibold(15))
                    .foregroundStyle(Color.chInk)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.chSaffron.opacity(store.isPlus ? 0.5 : 1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(store.isWorking || store.isPlus)

                Button("Maybe later") { dismiss() }
                    .font(.chBodyMedium(14))
                    .foregroundStyle(Color.chSaffron)
                    .frame(maxWidth: .infinity, minHeight: 40)

                HStack(spacing: 14) {
                    Button("Restore purchase", action: restore)
                    Text("·").accessibilityHidden(true)
                    Button("Terms") { infoKind = .terms }
                    Text("·").accessibilityHidden(true)
                    Button("Privacy") { infoKind = .privacy }
                }
                .font(.chBody(12))
                .foregroundStyle(.white)
                .buttonStyle(.plain)
                .frame(minHeight: 36)
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .background(alignment: .top) { Color.chInk.ignoresSafeArea(edges: .bottom) }
            .overlay(alignment: .top) {
                // Soft fade so scrolling content doesn't end on a hard edge.
                LinearGradient(colors: [Color.chInk.opacity(0), Color.chInk], startPoint: .top, endPoint: .bottom)
                    .frame(height: 20)
                    .offset(y: -20)
                    .allowsHitTesting(false)
            }
        }
        .preferredColorScheme(.dark)
        .alert("Choghadia Plus", isPresented: Binding(get: { alertMessage != nil }, set: { if !$0 { alertMessage = nil } })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
        .sheet(item: $infoKind) { kind in
            SettingsInfoSheet(kind: kind)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .task { await store.loadProducts() }
    }

    private var header: some View {
        HStack {
            Label("Choghadia Plus", systemImage: "sparkles")
                .font(.chBodySemibold(12))
                .foregroundStyle(Color.chSaffron)
                .padding(.horizontal, 11)
                .frame(minHeight: 30)
                .background(Color(hex: "342B5C"), in: Capsule())
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color(hex: "342B5C"), in: Circle())
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Close Choghadia Plus")
        }
    }

    private var conversationPreview: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                Spacer(minLength: 20)
                Text("Is 2 PM okay to sign my lease?")
                    .font(.chBody(13))
                    .foregroundStyle(Color.chInk)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Color.chCream, in: UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 4, bottomTrailingRadius: 16, topTrailingRadius: 16))
            }

            HStack(spacing: 8) {
                plusGlyph(size: 29)
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle().fill(Color.chGlassNote).frame(width: 5, height: 5)
                    }
                }
                .accessibilityHidden(true)
                Spacer()
            }

            HStack(alignment: .top, spacing: 8) {
                plusGlyph(size: 29)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Yes. 2:00 PM is inside Shubh, which runs until 2:09 PM. Aim a little earlier to be safe.")
                        .font(.chBody(13))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(11)
                        .background(Color(hex: "3A3270"), in: UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 16, bottomTrailingRadius: 16, topTrailingRadius: 4))
                    Label("Answered in 2 seconds", systemImage: "bolt.fill")
                        .font(.chBodySemibold(13))
                        .foregroundStyle(Color.chElectricCyan)
                        .shadow(color: Color.chElectricCyan.opacity(0.45), radius: 6)
                        .padding(.leading, 4)
                }
            }
        }
        .padding(14)
        .background(plusGlass(cornerRadius: 20))
    }

    private var comparisonCards: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Label("Asking around", systemImage: "clock")
                    .font(.chBody(11))
                    .foregroundStyle(Color.chGlassNote)
                Text("Hours")
                    .font(.chBodySemibold(19))
                    .foregroundStyle(.white)
                Text("of waiting and guessing")
                    .font(.chBody(11))
                    .foregroundStyle(Color.chGlassNote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(plusGlass(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Label("AI guide", systemImage: "bolt.fill")
                    .font(.chBody(11))
                    .foregroundStyle(Color.chInk)
                Text("Seconds")
                    .font(.chBodySemibold(19))
                    .foregroundStyle(Color.chInk)
                Text("for every question")
                    .font(.chBody(11))
                    .foregroundStyle(Color.chInk)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.chSaffron, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var planPicker: some View {
        HStack(spacing: 10) {
            ForEach(PlusPlan.allCases) { plan in
                let isSelected = plan == selectedPlan
                Button { selectedPlan = plan } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.title)
                            .font(.chBody(12))
                            .foregroundStyle(Color.chGlassTitle)
                        Text(price(plan))
                            .font(.chBodySemibold(20))
                            .foregroundStyle(.white)
                        Text(detail(plan))
                            .font(.chBody(11))
                            .foregroundStyle(Color.chSaffron)
                    }
                    .frame(maxWidth: .infinity, minHeight: 78, alignment: .leading)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Color.chSaffron : Color.chCream.opacity(0.28), lineWidth: isSelected ? 2 : 1)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }

    private func plusGlyph(size: CGFloat) -> some View {
        Image(systemName: "sparkles")
            .font(.system(size: size * 0.48, weight: .semibold))
            .foregroundStyle(Color.chInk)
            .frame(width: size, height: size)
            .background(Color.chSaffron, in: Circle())
            .accessibilityHidden(true)
    }

    private func plusGlass(cornerRadius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return shape
            .fill(
                LinearGradient(
                    colors: [Color(hex: "3B2E68").opacity(0.95), Color(hex: "241C48").opacity(0.97)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay { shape.stroke(Color.chCream.opacity(0.28), lineWidth: 1) }
    }
}
