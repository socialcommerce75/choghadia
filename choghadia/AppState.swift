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
    /// Selected tab: 0 Today, 1 AI Assistance, 2 Settings.
    var selectedTab: Int = 0

    init() {
        #if DEBUG
        // Debug only: `-startMain` skips the Launch screen for quick testing.
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-startMain") { screen = .main }
        if let i = args.firstIndex(of: "-tab"), i + 1 < args.count, let n = Int(args[i + 1]) { selectedTab = n }
        #endif
    }
}
