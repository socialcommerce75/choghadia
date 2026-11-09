// MainTabView.swift
// Root tab container. Each tab will be fleshed out screen-by-screen.

import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState
        return TabView(selection: $appState.selectedTab) {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max") }
                .tag(0)

            AIAssistanceView()
                .tabItem { Label("AI Assistance", systemImage: "sparkles") }
                .tag(1)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(2)
        }
    }
}
