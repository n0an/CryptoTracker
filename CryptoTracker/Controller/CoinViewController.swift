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
private let imageSize: CGFloat = 100
private let priceLabelHeight: CGFloat = 25

class CoinViewController: UIViewController {
    
    var coin: Coin!
    var chart = Chart()
    
    var priceLabel = UILabel()
    var youOwnLabel = UILabel()
    var worthLabel = UILabel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = coin.symbol
        
        CoinsData.shared.delegate = self
        
        view.backgroundColor = .white
        edgesForExtendedLayout = []
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        
        chart.frame = .init(x: 0, y: 0, width: view.frame.width, height: chartHeight)
        chart.yLabelsFormatter = { CoinsData.shared.doubleToMoneyString($1) }
        chart.xLabelsFormatter = { String(Int(round(30 - $1))) + "d" }
        chart.xLabels = [30,25,20,15,10,5,0]
            
        view.addSubview(chart)
        
        let imageView = UIImageView(frame: CGRect(x: view.frame.width / 2 - imageSize / 2, y: chartHeight, width: imageSize, height: imageSize))
        imageView.image = coin.image
        
        view.addSubview(imageView)
        
        priceLabel.frame = CGRect(x: 0, y: chartHeight + imageSize, width: view.frame.width, height: priceLabelHeight)
        priceLabel.textAlignment = .center
        view.addSubview(priceLabel)
        
        youOwnLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 2, width: view.frame.width, height: priceLabelHeight)
        youOwnLabel.textAlignment = .center
        youOwnLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        view.addSubview(youOwnLabel)
        
        worthLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 3, width: view.frame.width, height: priceLabelHeight)
        worthLabel.textAlignment = .center
        worthLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        view.addSubview(worthLabel)
        
        coin.getHistoricalData()
        
        newPrices()
    }
    
    func newPrices() {
        priceLabel.text = coin.priceAsString()
        worthLabel.text = coin.amountAsString()
        youOwnLabel.text = "You own: \(coin.amount) \(coin.symbol)"

    }
    
    @objc func editTapped() {
        let alert = UIAlertController(title: "How much \(coin.symbol) do you own?", message: "Specify amount", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "0.5"
            textField.keyboardType = .decimalPad
            
            if self.coin.amount != 0.0 {
                textField.text = "\(self.coin.amount)"
            }
            
        }
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            if let text = alert.textFields?.first?.text, let amount = Double(text) {
                self.coin.amount = amount
                self.newPrices()
            }
        }))
        
        self.present(alert, animated: true)
    }
}

extension CoinViewController: CoinDataDelegate {
    func newHistoricalPrices() {
        
        let series = ChartSeries(coin.historicalData)
        series.area = true
        chart.add(series)
        
    }
}
