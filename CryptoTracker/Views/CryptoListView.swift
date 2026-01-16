//
//  CryptoListView.swift
//  CryptoTracker
//
//  Copyright © 2026 Anton Novoselov. All rights reserved.
//

import SwiftUI
import UIKit
import LocalAuthentication

struct CryptoListView: View {
    @Environment(CoinsData.self) private var coinsData
    @State private var showingShareSheet = false
    @State private var pdfData: Data?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 8) {
                        Text("My Crypto Net Worth:")
                            .font(.subheadline)
                        Text(coinsData.netWorthString)
                            .font(.system(size: 50, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                Section {
                    ForEach(coinsData.coins) { coin in
                        NavigationLink(destination: CoinDetailView(coin: coin)) {
                            CoinRowView(coin: coin)
                        }
                    }
                }
            }
            .navigationTitle("CryptoTracker")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Report") {
                        generatePDF()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                        Button(isSecure ? "Unsecure App" : "Secure App") {
                            toggleSecurity()
                        }
                    }
                }
            }
            .task {
                await coinsData.fetchAllPrices()
            }
            .refreshable {
                await coinsData.fetchAllPrices()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfData {
                    ShareSheet(activityItems: [pdfData])
                }
            }
        }
    }

    private var isSecure: Bool {
        UserDefaults.standard.bool(forKey: "secure")
    }

    private func toggleSecurity() {
        UserDefaults.standard.set(!isSecure, forKey: "secure")
    }

    private func generatePDF() {
        let formatter = UIMarkupTextPrintFormatter(markupText: coinsData.generateReportHTML())
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)

        let page = CGRect(x: 0, y: 0, width: 595.2, height: 814.8)
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")

        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, .zero, nil)

        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage()
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }

        UIGraphicsEndPDFContext()

        pdfData = data as Data
        showingShareSheet = true
    }
}

struct CoinRowView: View {
    let coin: Coin

    var body: some View {
        HStack {
            if let image = coin.image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading) {
                Text(coin.symbol)
                    .font(.headline)
                Text(coin.priceString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if coin.amount != 0 {
                Text("\(coin.amount, specifier: "%.4f")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CryptoListView()
        .environment(CoinsData())
}
