//
//  ImportMnemonicVC.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 01/08/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK
import DropDown

class ImportMnemonicVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var txtMnemonic: UITextField!
    @IBOutlet weak var txtNickname: UITextField!
    @IBOutlet weak var txtBlockchainNetwork: UITextField!
    @IBOutlet weak var stackNickname: UIStackView!
    @IBOutlet weak var stackBlockchainNetwork: UIStackView!
    
    //MARK: - Variables
    let dropDown = DropDown()
    var importLocalFailed = false
    var blockchainNetworkIndex = 0
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stackBlockchainNetwork.isHidden = true
        self.stackNickname.isHidden = true
    }
    
    //MARK: - Setup UI
    
    func setupUi() {
        
        dropDown.anchorView = txtBlockchainNetwork
        dropDown.dataSource = Constant.coinNames
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.blockchainNetworkIndex = index
            self.txtBlockchainNetwork.text = item
        }
        
        txtBlockchainNetwork.text = Constant.coinNames[blockchainNetworkIndex]
        
        self.stackBlockchainNetwork.isHidden = false
        self.stackNickname.isHidden = false

        importLocalFailed = true
    }
    
    //MARK: - UIButton Action Methods

    @IBAction func btnImport_Click(_ sender: Any) {
        if txtMnemonic.text?.count == 0 {
            Dialog.showMessage("Validation Error", message: "Please enter valid mnemonic.", viewController: self)
        } else if !importLocalFailed {
            let importedAccounts = Abstrakt.shared.importMnemonic(mnemonic: txtMnemonic.text!)
            if importedAccounts > 0 {
                Dialog.showMessage("Imported Successfully", message: "\(importedAccounts) accounts imported using mnemonic successfully!!!", viewController: self, completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                Dialog.showMessage("No Accounts Found", message: "Please enter account name and select blockchain network to import deleted account or to create new one.", viewController: self, completion: {
                    self.setupUi()
                })
            }
        } else if importLocalFailed {
            if txtMnemonic.text?.count == 0, txtNickname.text?.count == 0 {
                Dialog.showMessage("Validation Error", message: "Please enter valid inputs.", viewController: self)
            } else {
                Abstrakt.shared.importMnemonic(mnemonic: txtMnemonic.text!, nickName: txtNickname.text!, blockchainNetwork: Constant.blockchainNetworks[blockchainNetworkIndex]) { (error) in
                    if let error = error {
                        Dialog.showMessage("Error", message: "Error while importing mnemonic \(error)", viewController: self)
                    } else {
                        Dialog.showMessage("Imported Sucessfully", message: "Please check account list to view created account", viewController: self, completion: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }
            }
        }
    }
}

extension ImportMnemonicVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtBlockchainNetwork {
            txtNickname.resignFirstResponder()
            txtMnemonic.resignFirstResponder()
            dropDown.show()
            return false
        }
        return true
    }
}
