//
//  choghadiaApp.swift
//  choghadia
//
//  Created by Admin Panda on 11/8/26.
//

import SwiftUI

@main
struct choghadiaApp: App {
    @State private var appState = AppState()

    init() {
        FontRegistry.register()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}
