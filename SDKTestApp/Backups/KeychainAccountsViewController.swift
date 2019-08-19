//
//  KeychainAccountsViewController.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 30/07/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK

class KeychainAccountsViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    //MARK: - Variables
    var blockchainNetwork:BlockchainNetwork?
    var accountAddress:String?
    var accounts:[String:String] = [:]
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.bringSubviewToFront(emptyView)
        
//        Abstrakt.shared.setDelegate(controller: self)
        self.initTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.restoreAccountSegue.rawValue {
            let dest = segue.destination as! RestoreKeychainVC
            dest.isMnemonic = false
            dest.blockchainNetwork = self.blockchainNetwork
            dest.accountAddress = self.accountAddress
        }
    }
    
    //MARK: - Helper Methods
    func initTableView() {
        tblMain.register(UINib(nibName: "GeneralTableViewCell", bundle: nil), forCellReuseIdentifier: "GeneralTableViewCell")
        tblMain.rowHeight = UITableView.automaticDimension
        tblMain.estimatedRowHeight = 100
        tblMain.tableFooterView = UIView()
        
        fetchAccounts()
    }
    
    func fetchAccounts() {
        self.accounts = Abstrakt.shared.getAccoutBackups()
        self.emptyView.alpha = self.accounts.keys.count > 0 ? 0 : 1
        self.tblMain.reloadData()
    }
}

//MARK: - UITableView Delegate and Datasource Methods

extension KeychainAccountsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(accounts.keys).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTableViewCell", for: indexPath) as! GeneralTableViewCell
        
        let key = Array(accounts.keys)[indexPath.row]
        let name = accounts[key]
        
        cell.lblAccountNumber.isHidden = false
        cell.lblAccountName.text = name
        cell.lblAccountNumber.text = key
        cell.lblAccountType.isHidden = true
        cell.lblAccountBalance.text = ""
        
        let keyAliasComponents = key.components(separatedBy: "|")
        let blockchainId = Int(keyAliasComponents[0])!
        cell.lblAccountValue.text = Constant.coinNames[blockchainId]
        
        Abstrakt.shared.getAccountBalance(accountAddress: keyAliasComponents[1], blockchainNetwork: BlockchainNetwork(rawValue: blockchainId)!) { (accountBalance, accountConversionBalance) in
            cell.lblAccountValue.text = accountBalance.rounded(toPlaces: 8).toString(decimal: 8) + " " + Constant.coinNames[blockchainId]
            cell.lblAccountBalance.text = Constant.getDollarDisplayValue(amount: accountConversionBalance)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let keyAlias = Array(accounts.keys)[indexPath.row]
        let keyAliasComponents = keyAlias.components(separatedBy: "|")
        
        self.blockchainNetwork = BlockchainNetwork(rawValue: Int(keyAliasComponents[0])!)
        self.accountAddress = keyAliasComponents[1]
        
        self.performSegue(withIdentifier: SegueIdentifier.restoreAccountSegue.rawValue, sender: self)
    }
    
    //MARK: - Helper Methods
    
//    func updateAccounts() {
//        Abstrakt.shared.getMyAccounts(blockchainNetworks: Constant.blockchainNetworks) { (accounts) in
//            self.accounts = accounts
//        }
//    }
}

//MARK: - Abstrakt Delegate

//extension KeychainAccountsViewController: AbstraktDelegate {
//    func accountsUpdated() {
//        tblMain.reloadData()
//        emptyView.alpha = self.accounts.count == 0 ? 1 : 0
//    }
//
//    func accountAdded(account: Account) {
//        accounts.append(account)
//        tblMain.reloadData()
//        emptyView.alpha = self.accounts.count == 0 ? 1 : 0
//    }
//
//    func marketValueUpdated(newValue: MarketValue) {
//        fetchAccounts()
//    }
//}
