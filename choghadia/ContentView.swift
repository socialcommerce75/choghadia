//
//  ContentView.swift
//  choghadia
//
//  Created by Admin Panda on 11/8/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

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
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
