//
//  ContentView.swift
//  choghadia
//
//  Created by Admin Panda on 11/8/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("choghadia.appearance.v1") private var appearance = "dark"
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var preferredScheme: ColorScheme? {
        switch appearance {
        case "light": .light
        case "dark": .dark
        default: nil
        }
    }

    var body: some View {
        Group {
            switch appState.screen {
            case .launch:
                LaunchView()
            case .main:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.screen)
        .preferredColorScheme(preferredScheme)
        // Fonts are sized once per render, so rebuild the tree when the text size changes.
        .id(dynamicTypeSize)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
