//
//  CoinsData.swift
//  CryptoTracker
//
//  Created by nag on 23/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import Alamofire

// MARK: - CoinDataDelegate Protocol
@objc protocol CoinsDataDelegate: AnyObject {
    @objc optional func newPrices()
    @objc optional func newHistoricalPrices()
}

class CoinsData {
    
    // MARK: - PROPERTIES
    static let shared = CoinsData()
    var coins = [Coin]()
    weak var delegate: CoinsDataDelegate?
    
    // MARK: - INIT
    private init() {
        let symbols = ["BTC", "ETH", "LTC"]
        
        for symbol in symbols {
            let coin = Coin(symbol: symbol)
            coins.append(coin)
        }
    }
    
    // MARK: - SERVER API METHODS
    func getPricesForAllCoins() {
        
        let symbolsArray = coins.map { (c) -> String in
            return c.symbol
        }
        
        let symbolsString = symbolsArray.joined(separator: ",")
        
        Alamofire.request("https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(symbolsString)&tsyms=USD").responseJSON { (response) in

            if let json = response.result.value as? [String: Any] {
                for coin in self.coins {
                    if let coinJSON = json[coin.symbol] as? [String: Double] {
                        if let price = coinJSON["USD"] {
                            coin.price = price
                            UserDefaults.standard.set(price, forKey: coin.symbol)
                        }
                    }
                }

                self.delegate?.newPrices?()
            }
        }
    }
    
    func getHistoricalData(for coin: Coin, completion: @escaping ([String: Any]) -> ()) {
        Alamofire.request("https://min-api.cryptocompare.com/data/histoday?fsym=\(coin.symbol)&tsym=USD&limit=30").responseJSON { (response) in
            
            
            if let json = response.result.value as? [String: Any] {
                
                completion(json)
            }
        }
    }
    
    // MARK: - HELPER METHODS
    func netWorthAsString() -> String {
        var netWorth = 0.0
        
        for coin in coins {
            netWorth += coin.amount * coin.price
        }
        
        return doubleToMoneyString(netWorth)
    }
    
    func doubleToMoneyString(_ double: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber.init(value: double)) ?? "ERR"
    }
    
    func html() -> String {
        var html = """
                    <h1>My Crypto Report</h1>
                    <h2>Net Worth: \(netWorthAsString())</h2>
                    <ul>
                    """
        
        for coin in coins {
            if coin.amount != 0.0 {
                html += "<li>\(coin.symbol) - I own: \(coin.amount) - Valued at: \(doubleToMoneyString(coin.amount * coin.price))</li>"
            }
        }
        html += "</ul>"
        
        return html
    }
}

