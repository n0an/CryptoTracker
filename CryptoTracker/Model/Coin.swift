//
//  Coin.swift
//  CryptoTracker
//
//  Created by nag on 28/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import Alamofire

class Coin {
    let symbol: String
    let image: UIImage?
    var price = 0.0
    var amount = 0.0
    
    var historicalData = [Double]()
    
    init(symbol: String) {
        self.symbol = symbol
        self.image = UIImage(named: symbol)
    }
    
    func priceAsString() -> String {
        if price == 0.0 {
            return "Loading"
        }
        
        return CoinsData.shared.doubleToMoneyString(price)
    }
    
    func amountAsString() -> String {
        return CoinsData.shared.doubleToMoneyString(amount * price)
    }
    
    func getHistoricalData() {
        Alamofire.request("https://min-api.cryptocompare.com/data/histoday?fsym=\(symbol)&tsym=USD&limit=30").responseJSON { (response) in
            
            if let json = response.result.value as? [String: Any] {
                if let pricesJson = json["Data"] as? [[String: Double]] {
                    self.historicalData = []
                    for priceJson in pricesJson {
                        if let closePrice = priceJson["close"] {
                            self.historicalData.append(Double(closePrice) ?? 0.0)
                        }
                    }
                    
                    CoinsData.shared.delegate?.newHistoricalPrices?()
                }
            }
        }
    }
}
