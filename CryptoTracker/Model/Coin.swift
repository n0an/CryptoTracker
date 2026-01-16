//
//  Coin.swift
//  CryptoTracker
//
//  Copyright © 2026 Anton Novoselov. All rights reserved.
//

import SwiftUI
import UIKit

@Observable
final class Coin: Identifiable {
    let id: String
    let symbol: String
    let image: Image?
    var price: Double = 0.0
    var amount: Double = 0.0
    var historicalData: [Double] = []

    init(symbol: String) {
        self.id = symbol
        self.symbol = symbol

        if let uiImage = UIImage(named: symbol) {
            self.image = Image(uiImage: uiImage)
        } else {
            self.image = nil
        }

        self.price = UserDefaults.standard.double(forKey: symbol)
        self.amount = UserDefaults.standard.double(forKey: symbol + "amount")

        if let history = UserDefaults.standard.array(forKey: symbol + "history") as? [Double] {
            self.historicalData = history
        }
    }

    var priceString: String {
        if price == 0.0 {
            return "Loading..."
        }
        return price.asCurrency
    }

    var amountValueString: String {
        return (amount * price).asCurrency
    }

    func saveAmount(_ newAmount: Double) {
        amount = newAmount
        UserDefaults.standard.set(newAmount, forKey: symbol + "amount")
    }

    func savePrice(_ newPrice: Double) {
        price = newPrice
        UserDefaults.standard.set(newPrice, forKey: symbol)
    }

    func saveHistoricalData(_ data: [Double]) {
        historicalData = data
        UserDefaults.standard.set(data, forKey: symbol + "history")
    }
}

extension Double {
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}
