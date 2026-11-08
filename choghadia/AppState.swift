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
}
