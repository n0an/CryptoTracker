//
//  CoinViewController.swift
//  CryptoTracker
//
//  Created by nag on 28/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import SwiftChart

private let chartHeight: CGFloat = 300

class CoinViewController: UIViewController {
    
    var coin: Coin!
    var chart = Chart()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinsData.shared.delegate = self
        
        view.backgroundColor = .white
        edgesForExtendedLayout = []
        
        chart.frame = .init(x: 0, y: 0, width: view.frame.width, height: chartHeight)
        chart.yLabelsFormatter = { CoinsData.shared.doubleToMoneyString($1) }
        chart.xLabelsFormatter = { String(Int(round(30 - $1))) + "d" }
        chart.xLabels = [30,25,20,15,10,5,0]
            
        view.addSubview(chart)
        
        coin.getHistoricalData()
    }
}

extension CoinViewController: CoinDataDelegate {
    func newHistoricalPrices() {
        
        let series = ChartSeries(coin.historicalData)
        series.area = true
        chart.add(series)
        
    }
}
