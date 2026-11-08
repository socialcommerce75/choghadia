// AppState.swift
// App-wide navigation and session state.

import Observation
import SwiftUI

@Observable
final class AppState {
    enum Screen {
        case launch
        case main
    }
    var screen: Screen = .launch

    init() {
        #if DEBUG
        // Debug only: `-startMain` skips the Launch screen for quick testing.
        if ProcessInfo.processInfo.arguments.contains("-startMain") { screen = .main }
        #endif
    }
}
