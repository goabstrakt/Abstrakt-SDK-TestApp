//
//  TransactionsViewController.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 30/07/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK

class TransactionsVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    //MARK: - Variables
    
    lazy var transactions:[Transaction] = {
        var dataSource = [Transaction]()

        Abstrakt.shared.getTransactions(blockchainNetworks: Constant.blockchainNetworks, completion: { (transactions) in
            dataSource = transactions
            dataSource = dataSource.sorted(by: { (first, second) -> Bool in
                first.blockTimestamp!.compare(second.blockTimestamp!) == .orderedDescending
            })
            self.emptyView.alpha = dataSource.count > 0 ? 0 : 1
        })
        
        return dataSource
    }()
    
    lazy var marketValues: [MarketValue] = {
        var dataSource = [MarketValue]()
        
        Abstrakt.shared.getMarketValue(completion: { (object) in
            dataSource = object
        })
        
        return dataSource
    }()
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bringSubviewToFront(emptyView)
        
        tblMain.tableFooterView = UIView()
        
        Abstrakt.shared.delegate = self
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func btnAdd_Click(_ sender: Any) {
        
    }
}

//MARK: - UITableView Delegate and Datasource Methods

extension TransactionsVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountListCell", for: indexPath) as! AccountListCell
        
        let transaction = transactions[indexPath.row]
        
        cell.setTransactionDetails(transaction: transaction)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Abstrakt Delegate

extension TransactionsVC: AbstraktDelegate {
    func newTransaction(transaction: Transaction) {
        transactions.append(transaction)
        tblMain.reloadData()
    }
}
