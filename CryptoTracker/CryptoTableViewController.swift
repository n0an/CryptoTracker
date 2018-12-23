//
//  CryptoTableViewController.swift
//  CryptoTracker
//
//  Created by nag on 23/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

class CryptoTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoinData.shared.coins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let coin = CoinData.shared.coins[indexPath.row]
        
        let cell = UITableViewCell()
        cell.textLabel?.text = coin.symbol
        cell.imageView?.image = coin.image
        
        return cell
    }

}
