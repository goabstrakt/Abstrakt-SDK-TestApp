//
//  LocalAccountsViewController.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 30/07/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK
import Toast_Swift

class LocalAccountsViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    //MARK: - Variables
    var blockchainNetwork:BlockchainNetwork?
    var accountAddress:String?
    var accounts = [Account]()
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.bringSubviewToFront(emptyView)
        
        Abstrakt.shared.setDelegate(controller: self)
        self.initTableView()
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
        Abstrakt.shared.getLocalAccounts(blockchainNetworks: Constant.blockchainNetworks, completion: { (accounts) in
            self.accounts = accounts
            self.emptyView.alpha = self.accounts.count > 0 ? 0 : 1
            self.tblMain.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.backupAccountSegue.rawValue {
            let dest = segue.destination as! BackupKeychainVC
            dest.isMnemonic = false
            dest.blockchainNetwork = self.blockchainNetwork
            dest.accountAddress = self.accountAddress
        }
    }
}

//MARK: - UITableView Delegate and Datasource Methods

extension LocalAccountsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTableViewCell", for: indexPath) as! GeneralTableViewCell
        
        let account = accounts[indexPath.row]
        
        cell.setAccountDetails(account: account)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "Are you sure?", message: "Do you really want to delete this account?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
                let account = self.accounts[indexPath.row]
                
                guard let accountAddress = account.address, let blockchainNetwork = account.blockchainNetwork else {
                    return
                }
                
                Abstrakt.shared.removeAccount(blockchainNetwork: blockchainNetwork , accountAddress: accountAddress) { (error, address) in
                    if error == nil {
                        self.accounts.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                        self.emptyView.alpha = self.accounts.count == 0 ? 1 : 0
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let account = accounts[indexPath.row]
        self.blockchainNetwork = account.blockchainNetwork
        self.accountAddress = account.address
        
        self.performSegue(withIdentifier: SegueIdentifier.backupAccountSegue.rawValue, sender: self)
    }
    
    //MARK: - Helper Methods
    
    func updateAccounts() {
        Abstrakt.shared.getLocalAccounts(blockchainNetworks: Constant.blockchainNetworks) { (accounts) in
            self.accounts = accounts
        }
    }
}

//MARK: - Abstrakt Delegate

extension LocalAccountsViewController: AbstraktDelegate {
    func accountsUpdated() {
        tblMain.reloadData()
        emptyView.alpha = self.accounts.count == 0 ? 1 : 0
    }
    
    func accountAdded(account: Account) {
        accounts.append(account)
        tblMain.reloadData()
        emptyView.alpha = self.accounts.count == 0 ? 1 : 0
    }
    
    func marketValueUpdated(newValue: MarketValue) {
        fetchAccounts()
    }
}
