//
//  BackupKeychainVC.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 30/07/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK

class BackupKeychainVC: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblBackupType: UILabel!
    @IBOutlet weak var lblBackupDesc: UILabel!
    
    //MARK: - Variables
    
    var blockchainNetworkIndex = 0
    var isMnemonic = false
    var mnemonicAlias:String?
    var detailText:String?
    var blockchainNetwork:BlockchainNetwork?
    var accountAddress:String?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUi()
    }
    
    //MARK: - Helper Methods
    
    func setupUi() {
        if isMnemonic {
            lblBackupType.text = "Backup Mnemonic"
            lblBackupDesc.text = detailText
        } else {
            lblBackupType.text = "Backup Account Private Key"
            lblBackupDesc.text = "\(blockchainNetwork!.rawValue)|\(accountAddress!)"
        }
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func btnCancel_click(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnBackup_Click(_ sender: Any) {
        if txtPassword.text?.isEmpty ?? true {
            Dialog.showMessage("Please enter password to encrypt with!", message: "", viewController: self)
            return
        }
        
        var backupStatus = false
        if isMnemonic {
            backupStatus = Abstrakt.shared.backupMnemonic(mnemonicKeyAlias: mnemonicAlias!, with: txtPassword.text!)
        } else {
            backupStatus = Abstrakt.shared.backupAccount(blockchainNetwork: blockchainNetwork!, accountAddress: accountAddress!, with: txtPassword.text!)
        }
        
        if backupStatus {
            Dialog.showMessage("Account backed up to keychain successfully!", message: "", viewController: self, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            Dialog.showMessage("Unable to restore account from keychain. Incorrect password, eh?", message: "", viewController: self, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}
