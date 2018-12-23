//
//  CoinsData.swift
//  CryptoTracker
//
//  Created by nag on 23/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

class CoinData {
    static let shared = CoinData()
    
    var coins = [Coin]()
    
    private init() {
        let symbols = ["BTC", "ETH", "LTC"]
        
        for symbol in symbols {
            let coin = Coin(symbol: symbol)
            coins.append(coin)
        }
    }
}

struct Coin {
    let symbol: String
    let image: UIImage?
    let price = 0.0
    var amount = 0.0
    
    var historicalData = [Double]()
    
    init(symbol: String) {
        self.symbol = symbol
        self.image = UIImage(named: symbol)
    }
}
