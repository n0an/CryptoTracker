//
//  CoinsData.swift
//  CryptoTracker
//
//  Copyright © 2026 Anton Novoselov. All rights reserved.
//

import Foundation

@Observable
final class CoinsData {
    var coins: [Coin] = []
    var isLoading = false

    init() {
        let symbols = ["BTC", "ETH", "LTC"]
        for symbol in symbols {
            coins.append(Coin(symbol: symbol))
        }
    }

    var netWorth: Double {
        coins.reduce(0) { $0 + ($1.amount * $1.price) }
    }

    var netWorthString: String {
        netWorth.asCurrency
    }

    // MARK: - Networking with async/await

    @MainActor
    func fetchAllPrices() async {
        isLoading = true
        defer { isLoading = false }

        let symbolsString = coins.map(\.symbol).joined(separator: ",")
        let urlString = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(symbolsString)&tsyms=USD"

        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            for coin in coins {
                if let coinData = json?[coin.symbol] as? [String: Double],
                   let price = coinData["USD"] {
                    coin.savePrice(price)
                }
            }
        } catch {
            print("Error fetching prices: \(error.localizedDescription)")
        }
    }

    @MainActor
    func fetchHistoricalData(for coin: Coin) async {
        let urlString = "https://min-api.cryptocompare.com/data/histoday?fsym=\(coin.symbol)&tsym=USD&limit=30"

        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            if let pricesJson = json?["Data"] as? [[String: Any]] {
                var historicalPrices: [Double] = []
                for priceData in pricesJson {
                    if let closePrice = priceData["close"] as? Double {
                        historicalPrices.append(closePrice)
                    }
                }
                coin.saveHistoricalData(historicalPrices)
            }
        } catch {
            print("Error fetching historical data: \(error.localizedDescription)")
        }
    }

    // MARK: - PDF Report

    func generateReportHTML() -> String {
        var html = """
            <h1>My Crypto Report</h1>
            <h2>Net Worth: \(netWorthString)</h2>
            <ul>
            """

        for coin in coins where coin.amount != 0.0 {
            html += "<li>\(coin.symbol) - I own: \(coin.amount) - Valued at: \((coin.amount * coin.price).asCurrency)</li>"
        }

        html += "</ul>"
        return html
    }
}
