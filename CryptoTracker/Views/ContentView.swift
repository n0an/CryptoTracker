//
//  ContentView.swift
//  CryptoTracker
//
//  Copyright © 2026 Anton Novoselov. All rights reserved.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var isCheckingAuth = true

    private var requiresAuth: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            && UserDefaults.standard.bool(forKey: "secure")
    }

    var body: some View {
        Group {
            if isCheckingAuth {
                ProgressView("Loading...")
            } else if requiresAuth && !isAuthenticated {
                AuthView(isAuthenticated: $isAuthenticated)
            } else {
                CryptoListView()
            }
        }
        .onAppear {
            checkAuthentication()
        }
    }

    private func checkAuthentication() {
        if requiresAuth {
            isCheckingAuth = false
        } else {
            isAuthenticated = true
            isCheckingAuth = false
        }
    }
}

struct AuthView: View {
    @Binding var isAuthenticated: Bool
    @State private var authError: String?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("CryptoTracker")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Authentication Required")
                .font(.headline)
                .foregroundStyle(.secondary)

            if let error = authError {
                Text(error)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Button {
                authenticate()
            } label: {
                Label("Authenticate", systemImage: "faceid")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .onAppear {
            authenticate()
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Biometrics protection"
            ) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isAuthenticated = true
                    } else if let error = authenticationError {
                        authError = error.localizedDescription
                    }
                }
            }
        } else {
            authError = error?.localizedDescription ?? "Biometric authentication not available"
        }
    }
}

#Preview {
    ContentView()
        .environment(CoinsData())
}
