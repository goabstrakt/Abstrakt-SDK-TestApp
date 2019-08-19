//
//  KeychainMnemonicsViewController.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 30/07/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK
import Toast_Swift

class KeychainMnemonicsViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    //MARK: - Variables
    var mnemonics:[String:String] = [:]
    var keyAlias:String?
    var detailText:String?
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bringSubviewToFront(emptyView)
        
        //        Abstrakt.shared.setDelegate(controller: self)
        self.initTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.restoreMnemonicSegue.rawValue {
            let dest = segue.destination as! RestoreKeychainVC
            dest.isMnemonic = true
            dest.mnemonicAlias = self.keyAlias
            dest.detailText = self.detailText
        }
    }
    
    //MARK: - Helper Methods
    func initTableView() {
        tblMain.tableFooterView = UIView()
        
        fetchAccounts()
    }
    
    func fetchAccounts() {
        self.mnemonics = Abstrakt.shared.getMnemonicBackups()
        self.emptyView.alpha = self.mnemonics.keys.count > 0 ? 0 : 1
        self.tblMain.reloadData()
    }
}

//MARK: - UITableView Delegate and Datasource Methods

extension KeychainMnemonicsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(mnemonics.keys).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let key = Array(mnemonics.keys)[indexPath.row]
        let name = mnemonics[key]
        
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        keyAlias = Array(mnemonics.keys)[indexPath.row]
        detailText = mnemonics[keyAlias!]
        
        self.performSegue(withIdentifier: SegueIdentifier.restoreMnemonicSegue.rawValue, sender: self)
    }
    
    //MARK: - Helper Methods
    
//    func updateAccounts() {
//        Abstrakt.shared.getMyAccounts(blockchainNetworks: Constant.blockchainNetworks) { (accounts) in
//            self.accounts = accounts
//        }
//    }
}

//MARK: - Abstrakt Delegate

//extension KeychainMnemonicsViewController: AbstraktDelegate {
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
