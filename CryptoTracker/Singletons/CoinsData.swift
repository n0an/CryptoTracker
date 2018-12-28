//
//  CoinsData.swift
//  CryptoTracker
//
//  Created by nag on 23/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol CoinDataDelegate: AnyObject {
    @objc optional func newPrices()
    @objc optional func newHistoricalPrices()
}

class CoinsData {
    static let shared = CoinsData()
    var coins = [Coin]()
    weak var delegate: CoinDataDelegate?
    
    private init() {
        let symbols = ["BTC", "ETH", "LTC"]
        
        for symbol in symbols {
            let coin = Coin(symbol: symbol)
            coins.append(coin)
        }
    }
    
    func getPrices() {
        
        let symbolsArray = coins.map { (c) -> String in
            return c.symbol
        }
        
        let symbolsString = symbolsArray.joined(separator: ",")
        
        print(symbolsString)
        
        Alamofire.request("https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(symbolsString)&tsyms=USD").responseJSON { (response) in
            
            if let json = response.result.value as? [String: Any] {
                for coin in self.coins {
                    if let coinJSON = json[coin.symbol] as? [String: Double] {
                        if let price = coinJSON["USD"] {
                            coin.price = price
                        }
                    }
                }
                
                self.delegate?.newPrices?()
            }
        }
    }
    
    func doubleToMoneyString(_ double: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber.init(value: double)) ?? "ERR"
    }
}

