// AIAssistanceView.swift
// AI Assistance tab: locked landing, chat, and "Report this answer" sheet.
// Layout and copy follow docs/choghadia-prototype.html. The answer source is a local stub
// until the backend proxy exists (never ship an API key in the app).

import Observation
import SwiftUI

// MARK: - Model

private struct AIMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let text: String
}

@MainActor
@Observable
private final class AIConversation {
    /// Plus entitlement from StoreKit.
    var isPlus: Bool { PlusStore.shared.isPlus }
    var trialStarted = false
    var messages: [AIMessage] = []
    var isTyping = false

    private static let usedFreeKey = "choghadia.ai.usedFree.v1"
    var usedFreeSample: Bool {
        get { UserDefaults.standard.bool(forKey: Self.usedFreeKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.usedFreeKey) }
    }

    var isUnlocked: Bool { isPlus || trialStarted }

    /// Returns false when the question needs the paywall instead.
    func send(_ question: String) -> Bool {
        let text = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isTyping else { return true }
        if !isPlus && usedFreeSample { return false }
        messages.append(AIMessage(isUser: true, text: text))
        isTyping = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(700))
            // Stub answer. The backend will answer from today's slot list and the question.
            messages.append(AIMessage(
                isUser: false,
                text: "It is Kaal until 12:52 PM, so I would wait. The next favourable window is Shubh, 12:52 to 2:09 PM."
            ))
            isTyping = false
            if !isPlus { usedFreeSample = true }
        }
        return true
    }
}

// MARK: - Screen

struct AIAssistanceView: View {
    @State private var chat = AIConversation()
    @State private var showingPlus = false
    @State private var reportTarget: UUID?
    @State private var toast: String?
    @State private var draft = ""
    @FocusState private var inputFocused: Bool

    private let examples = [
        "Is 2 PM okay to sign my lease?",
        "When should I pick up my new car?",
        "Can I start my new job on Monday morning?"
    ]
    private let suggestions = ["Is now a good time to start a job?", "When should I buy a car today?"]

    init() {
        #if DEBUG
        // Debug only: `-aiDemo` opens the chat with a sample exchange; `-aiReport` also opens the report sheet.
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-aiDemo") || args.contains("-aiReport") {
            let chat = AIConversation()
            chat.trialStarted = true
            let answer = AIMessage(isUser: false, text: "It is Kaal until 12:52 PM, so I would wait. The next favourable window is Shubh, 12:52 to 2:09 PM.")
            chat.messages = [AIMessage(isUser: true, text: "Is now a good time to sign something?"), answer]
            _chat = State(initialValue: chat)
            if args.contains("-aiReport") { _reportTarget = State(initialValue: answer.id) }
        }
        #endif
    }

    var body: some View {
        ZStack {
            Color.chInk.ignoresSafeArea()
            // Saffron glow behind the Ganesha header (the illustration scrolls with the content).
            RadialGradient(
                colors: [Color.chSaffron.opacity(0.28), Color(hex: "5A48A8").opacity(0.14), .clear],
                center: UnitPoint(x: 0.5, y: 0.08),
                startRadius: 10,
                endRadius: 380
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)
            .allowsHitTesting(false)

            if chat.isUnlocked {
                chatView
            } else {
                landing
            }

            if let toast {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.chBodyMedium(13))
                        .foregroundStyle(Color.chInk)
                        .padding(.horizontal, 18)
                        .frame(minHeight: 44)
                        .background(Color.chGlassTitle, in: Capsule())
                        .padding(.bottom, 170)
                }
                .transition(.opacity)
                .allowsHitTesting(false)
            }
        }
        .background(Color.chInk.ignoresSafeArea())
        .fullScreenCover(isPresented: $showingPlus) { ChoghadiaPlusView() }
        .sheet(isPresented: Binding(get: { reportTarget != nil }, set: { if !$0 { reportTarget = nil } })) {
            ReportAnswerSheet { sent in
                reportTarget = nil
                if sent { show("Thanks. We will review this answer.") }
            }
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.visible)
        }
    }

    private func show(_ text: String) {
        withAnimation { toast = text }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(1800))
            withAnimation { toast = nil }
        }
    }

    // MARK: Landing (locked)

    private var landing: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image("Ganesha")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .padding(.top, 34)
                    .accessibilityHidden(true)

                Text("Ask anything about your day")
                    .font(.chHeadingMedium(28))
                    .foregroundStyle(Color.chGlassTitle)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 6)
                Text("The AI guide answers in seconds, any time. No waiting for replies.")
                    .font(.chBody(14))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("People ask things like")
                        .font(.chBody(12))
                        .foregroundStyle(.white)
                    ForEach(examples, id: \.self) { example in
                        HStack(spacing: 10) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.chSaffron)
                            Text(example)
                                .font(.chBody(14))
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .aiPanel(cornerRadius: 14)
                    }
                }
                .padding(.top, 22)

                VStack(spacing: 6) {
                    Button { showingPlus = true } label: {
                        Text("Unlock the AI guide")
                            .font(.chBodySemibold(15))
                            .foregroundStyle(Color.chInk)
                            .frame(maxWidth: .infinity, minHeight: CH.buttonHeight)
                            .background(Color.chSaffron, in: RoundedRectangle(cornerRadius: CH.buttonRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    if !chat.usedFreeSample {
                        Button { chat.trialStarted = true } label: {
                            Text("Try one question free")
                                .font(.chBodyMedium(15))
                                .foregroundStyle(Color.chCream)
                                .frame(maxWidth: .infinity, minHeight: CH.buttonHeight)
                        }
                        .buttonStyle(.plain)
                    }

                    Text("Answers are AI-generated. Questions are sent to a third-party AI provider. See our Privacy policy in Settings.")
                        .font(.chBody(11))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 6)
                }
                .padding(.top, 24)
                .padding(.bottom, 120)
            }
            .padding(.horizontal, CH.pagePadding)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: Chat

    private var chatView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Image("Ganesha")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 26)
                        .accessibilityHidden(true)

                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.chInk)
                            .frame(width: 32, height: 32)
                            .background(Color.chSaffron, in: Circle())
                            .accessibilityHidden(true)
                        Text("Ask the AI guide")
                            .font(.chHeadingMedium(20))
                            .foregroundStyle(Color.chGlassTitle)
                        Spacer()
                        Text(chat.isPlus ? "Plus" : "Free sample")
                            .font(.chBodyMedium(11))
                            .foregroundStyle(Color.chSaffron)
                            .padding(.horizontal, 10)
                            .frame(minHeight: 26)
                            .background(Color.chSaffron.opacity(0.16), in: Capsule())
                            .overlay(Capsule().stroke(Color.chSaffron.opacity(0.5), lineWidth: 1))
                    }
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        if chat.messages.isEmpty {
                            Text("Ask about today's timings. Your first question is free.")
                                .font(.chBody(14))
                                .foregroundStyle(.white)
                                .padding(.top, 6)
                        }
                        ForEach(chat.messages) { message in
                            bubble(message)
                        }
                        if chat.isTyping {
                            HStack(spacing: 8) {
                                avatar
                                Text("AI guide is thinking…")
                                    .font(.chBody(13))
                                    .foregroundStyle(.white)
                            }
                            .accessibilityElement(children: .combine)
                        }
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, CH.pagePadding)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: chat.messages.count) { _, _ in
                withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
            }
            .onChange(of: chat.isTyping) { _, _ in
                withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { inputBar }
    }

    private var avatar: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.chInk)
            .frame(width: 30, height: 30)
            .background(Color.chSaffron, in: Circle())
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func bubble(_ message: AIMessage) -> some View {
        if message.isUser {
            HStack {
                Spacer(minLength: 48)
                Text(message.text)
                    .font(.chBody(14))
                    .foregroundStyle(Color.chInk)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Color.chSaffron,
                        in: UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 18, bottomTrailingRadius: 4, topTrailingRadius: 18, style: .continuous)
                    )
            }
            .accessibilityLabel("You asked: \(message.text)")
        } else {
            HStack(alignment: .top, spacing: 8) {
                avatar
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI guide")
                        .font(.chBodyMedium(12))
                        .foregroundStyle(.white)
                        .padding(.leading, 2)
                    Text(message.text)
                        .font(.chBody(14))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Color(hex: "3A3270"),
                            in: UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 18, bottomTrailingRadius: 18, topTrailingRadius: 18, style: .continuous)
                        )
                    HStack(spacing: 2) {
                        Text("AI-generated. Traditional guidance, not professional advice.")
                            .font(.chBody(11))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                        Button { reportTarget = message.id } label: {
                            Image(systemName: "flag")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.chGlassNote)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Report this answer")
                    }
                    .padding(.leading, 2)
                }
            }
        }
    }

    private var inputBar: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button { submit(suggestion) } label: {
                            Text(suggestion)
                                .font(.chBody(12))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .frame(minHeight: 36)
                                .background(Color.white.opacity(0.1), in: Capsule())
                                .overlay(Capsule().stroke(Color.chCream.opacity(0.3), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)

            HStack(spacing: 8) {
                TextField("", text: $draft, prompt: Text("Is today good to sign a lease?").foregroundStyle(Color.chGlassNote))
                    .font(.chBody(14))
                    .foregroundStyle(.white)
                    .tint(Color.chSaffron)
                    .padding(.horizontal, 18)
                    .frame(height: 48)
                    .background(Color.white.opacity(0.12), in: Capsule())
                    .overlay(Capsule().stroke(Color.chCream.opacity(0.3), lineWidth: 1))
                    .focused($inputFocused)
                    .submitLabel(.send)
                    .onSubmit { submit(draft) }
                    .accessibilityLabel("Your question")

                Button { submit(draft) } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.chInk)
                        .frame(width: 48, height: 48)
                        .background(Color.chSaffron, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Send")
            }
        }
        .padding(12)
        .background {
            let shape = RoundedRectangle(cornerRadius: 26, style: .continuous)
            shape
                .fill(Color(hex: "181330").opacity(0.96))
                .overlay { shape.stroke(Color.chCream.opacity(0.28), lineWidth: 1) }
        }
        .padding(.horizontal, 14)
        // Clear the floating tab bar; sit just above the keyboard while typing.
        .padding(.bottom, inputFocused ? 8 : 88)
    }

    private func submit(_ text: String) {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            show("Type a question first")
            return
        }
        if chat.send(text) {
            draft = ""
        } else {
            showingPlus = true
        }
    }
}

// MARK: - Report sheet

private struct ReportAnswerSheet: View {
    let finish: (_ sent: Bool) -> Void

    private let reasons = ["Offensive or inappropriate", "Wrong or misleading", "Something else"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Report this answer")
                .font(.chHeadingMedium(22))
                .foregroundStyle(.white)
            Text("Tell us what is wrong. We review every report.")
                .font(.chBody(13))
                .foregroundStyle(.white)

            ForEach(reasons, id: \.self) { reason in
                Button { finish(true) } label: {
                    HStack {
                        Text(reason)
                            .font(.chBodyMedium(14))
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.chGlassNote)
                    }
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .aiPanel(cornerRadius: 14)
                }
                .buttonStyle(.plain)
            }

            Button { finish(false) } label: {
                Text("Cancel")
                    .font(.chBodyMedium(15))
                    .foregroundStyle(Color.chSaffron)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .padding(.top, 26)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.chInk.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

// MARK: - Panel style

private extension View {
    /// Deep-purple gradient panel shared with the Settings and Plus screens.
    func aiPanel(cornerRadius: CGFloat) -> some View {
        background {
            let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            shape
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "33285D").opacity(0.97), Color(hex: "181330").opacity(0.98)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay { shape.stroke(Color.chCream.opacity(0.28), lineWidth: 1) }
        }
    }
}
