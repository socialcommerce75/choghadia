import SwiftUI

private enum PlusPlan: String, CaseIterable, Identifiable {
    case yearly
    case monthly

    var id: String { rawValue }
    var title: String { self == .yearly ? "Yearly" : "Monthly" }
    var price: String { self == .yearly ? "$19.99" : "$2.99" }
    var detail: String { self == .yearly ? "Save 44%" : "Cancel anytime" }
    var billing: String { self == .yearly ? "a year" : "a month" }
}

struct ChoghadiaPlusView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlusPlan = .yearly
    @State private var showingUnavailable = false

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
                    Text("The AI guide answers questions about your day in seconds, at any hour.")
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
                    Text("Sample pricing from the prototype. Subscriptions are not connected yet.")
                        .font(.chBody(11))
                        .foregroundStyle(Color.chGlassNote)
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
                Button { showingUnavailable = true } label: {
                    Text("Subscribe for \(selectedPlan.price) \(selectedPlan.billing)")
                        .font(.chBodySemibold(15))
                        .foregroundStyle(Color.chInk)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.chSaffron, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                Button("Maybe later") { dismiss() }
                    .font(.chBodyMedium(14))
                    .foregroundStyle(Color.chSaffron)
                    .frame(maxWidth: .infinity, minHeight: 42)
            }
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .background(.ultraThinMaterial)
            .background(Color.chInk.opacity(0.82))
        }
        .preferredColorScheme(.dark)
        .alert("Subscriptions are not connected yet", isPresented: $showingUnavailable) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Choghadia Plus will be available when App Store purchases are connected.")
        }
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
                        .font(.chBody(11))
                        .foregroundStyle(Color.chSaffron)
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
                        Text(plan.price)
                            .font(.chBodySemibold(20))
                            .foregroundStyle(.white)
                        Text(plan.detail)
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
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.075))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.chCream.opacity(0.28), lineWidth: 1)
            }
    }
}
