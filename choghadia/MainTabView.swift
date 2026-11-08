// MainTabView.swift
// Root tab container. Each tab will be fleshed out screen-by-screen.

import SwiftUI

struct MainTabView: View {
    #if DEBUG
    // Debug only: `-tab N` opens a given tab at launch.
    @State private var selection: Int = {
        let a = ProcessInfo.processInfo.arguments
        if let i = a.firstIndex(of: "-tab"), i + 1 < a.count, let n = Int(a[i + 1]) { return n }
        return 0
    }()
    #else
    @State private var selection = 0
    #endif

    var body: some View {
        TabView(selection: $selection) {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max") }
                .tag(0)

            Text("AI Assistance – coming soon")
                .tabItem { Label("AI Assistance", systemImage: "sparkles") }
                .tag(1)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(2)
        }
    }
}
