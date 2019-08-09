//
//  AccountsViewController.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 30/07/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK
import Toast_Swift

class AccountsViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    //MARK: - Variables
    
    lazy var accounts:[Account] = {
        var dataSource = [Account]()
        
        Abstrakt.shared.getMyAccounts(blockchainNetworks: Constant.blockchainNetworks, completion: { (accounts) in
            dataSource = accounts
            self.emptyView.alpha = dataSource.count > 0 ? 0 : 1
        })
        
        return dataSource
    }()
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.bringSubviewToFront(emptyView)
        
        Abstrakt.shared.delegate = self
        
        self.initTableView()
    }
    
    //MARK: - Helper Methods
    func initTableView() {
        tblMain.register(UINib(nibName: "GeneralTableViewCell", bundle: nil), forCellReuseIdentifier: "GeneralTableViewCell")
        tblMain.rowHeight = UITableView.automaticDimension
        tblMain.estimatedRowHeight = 100
        tblMain.tableFooterView = UIView()
    }
}

//MARK: - UITableView Delegate and Datasource Methods

extension AccountsViewController : UITableViewDelegate, UITableViewDataSource {
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
        guard let address = account.address else {
            return
        }
        
        UIPasteboard.general.string = address
        self.view.makeToast("Address coppied successfully!!")
    }
    
    //MARK: - Helper Methods
    
    func updateAccounts() {
        Abstrakt.shared.getMyAccounts(blockchainNetworks: Constant.blockchainNetworks) { (accounts) in
            self.accounts = accounts
        }
    }
}

//MARK: - Abstrakt Delegate

extension AccountsViewController: AbstraktDelegate {
    func accountsUpdated() {
        
    }
    
    func accountAdded(account: Account) {
        accounts.append(account)
        tblMain.reloadData()
        emptyView.alpha = self.accounts.count == 0 ? 1 : 0
    }
}
