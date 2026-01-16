//
//  CryptoTrackerApp.swift
//  CryptoTracker
//
//  Copyright © 2026 Anton Novoselov. All rights reserved.
//

import SwiftUI

@main
struct CryptoTrackerApp: App {
    @State private var coinsData = CoinsData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(coinsData)
        }
    }
}
