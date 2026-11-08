// MainTabView.swift
// Root tab container. Each tab will be fleshed out screen-by-screen.

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max") }

            Text("AI Assistance – coming soon")
                .tabItem { Label("AI Assistance", systemImage: "sparkles") }

            Text("Settings – coming soon")
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
