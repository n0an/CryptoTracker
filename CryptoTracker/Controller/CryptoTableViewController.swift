//
//  CryptoTableViewController.swift
//  CryptoTracker
//
//  Created by nag on 23/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

class CryptoTableViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CoinsData.shared.delegate = self
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CoinsData.shared.delegate = self
        CoinsData.shared.getPrices()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoinsData.shared.coins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let coin = CoinsData.shared.coins[indexPath.row]
        
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(coin.symbol) - \(coin.priceAsString())"
        cell.imageView?.image = coin.image
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coinVC = CoinViewController()
        coinVC.coin = CoinsData.shared.coins[indexPath.row]
        
        navigationController?.pushViewController(coinVC, animated: true)
    }
}

extension CryptoTableViewController: CoinDataDelegate {

    func newPrices() {
        tableView.reloadData()
    }
}
