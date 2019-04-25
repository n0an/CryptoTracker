//
//  CryptoTableViewController.swift
//  CryptoTracker
//
//  Created by nag on 23/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import LocalAuthentication

private let headerHeight: CGFloat = 100.0
private let netWorthHeight: CGFloat = 45.0

class CryptoTableViewController: UITableViewController {
    
    var amountLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoinsData.shared.delegate = self
        
        CoinsData.shared.getPrices()
        
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            updateSecureButton()
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Report", style: .plain, target: self, action: #selector(reportTapped))
    }
    
    @objc func reportTapped() {
        let formatter = UIMarkupTextPrintFormatter(markupText: CoinsData.shared.html())
        let render = UIPrintPageRenderer()
        
        render.addPrintFormatter(formatter, startingAtPageAt: 0)
        
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 814.8)
        
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        
        for i in 0 ..< render.numberOfPages {
            UIGraphicsBeginPDFPage()
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        let shareVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        present(shareVC, animated: true)
        
    }
    
    func updateSecureButton() {
        var title: String
        if UserDefaults.standard.bool(forKey: "secure") == true {
            title = "Unsecure App"
        } else {
            title = "Secure App"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(secureTapped))
    }
    
    @objc func secureTapped(button: UIButton) {
        if UserDefaults.standard.bool(forKey: "secure") == true {
            UserDefaults.standard.set(false, forKey: "secure")
        } else {
            UserDefaults.standard.set(true, forKey: "secure")
        }
        updateSecureButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CoinsData.shared.delegate = self
        tableView.reloadData()
        displayNetWorth()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderView()
    }
    
    func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: headerHeight))
        headerView.backgroundColor = .white
        
        let netWorthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: netWorthHeight))
        netWorthLabel.text = "My Crypto Net Worth: "
        netWorthLabel.textAlignment = .center
        
        headerView.addSubview(netWorthLabel)
        
        amountLabel.frame = CGRect(x: 0, y: netWorthHeight, width: view.frame.width, height: headerHeight - netWorthHeight)
        amountLabel.textAlignment = .center
        
        amountLabel.font = UIFont.boldSystemFont(ofSize: 60)
        
        headerView.addSubview(amountLabel)
        
        displayNetWorth()
        
        return headerView
    }
    
    func displayNetWorth() {
        amountLabel.text = CoinsData.shared.netWorthAsString()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoinsData.shared.coins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        let coin = CoinsData.shared.coins[indexPath.row]
        
        if coin.amount != 0 {
            cell.textLabel?.text = "\(coin.symbol) - \(coin.priceAsString()) - \(coin.amount)"
        } else {
            cell.textLabel?.text = "\(coin.symbol) - \(coin.priceAsString())"
        }
        
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
        displayNetWorth()
    }
}
