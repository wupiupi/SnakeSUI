//
//  SnakeSUIApp.swift
//  SnakeSUI
//
//  Created by Paul Makey on 28.04.24.
//

import SwiftUI

@main
struct SnakeSUIApp: App {
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView().id(appState.gameID)
        }
    }
}

final class AppState: ObservableObject {
    @Published var gameID = UUID()
    
    static let shared = AppState()
    private init() {}
}
