//
//  SendTransactionVC.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 31/07/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK
import DropDown

class SendTransactionVC: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var txtMnemonic: UITextField!
    @IBOutlet weak var txtBlockchain: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtFromAddress: UITextField!
    @IBOutlet weak var txtToAddress: UITextField!
    @IBOutlet weak var txtPrivatekey: UITextField!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblFromAddress: UILabel!
    @IBOutlet weak var lblFromAddressName: UILabel!
    
    //MAKR: - Variables
    let addressDropDown = DropDown()
    var addressIndex = 0
    var isPushed = false
    
    lazy var accounts:[Account] = {
        var dataSource = [Account]()
        
        Abstrakt.shared.getMyAccounts(blockchainNetworks: Constant.blockchainNetworks, completion: { (accounts) in
            dataSource = accounts
        })
        
        return dataSource
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard accounts.count > 0 else {
            Dialog.showMessage("No Account Found", message: "There is no account found. Please create one to send transaction", viewController: self)
            self.navigationController?.popViewController(animated: true)
            return
        }

        setupUi()
    }
    
    //MARK: - Helper Methods
    
    func setupUi() {
        if isPushed {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        addressDropDown.anchorView = txtFromAddress
        addressDropDown.dataSource = accounts.map { $0.address ?? "" }
        addressDropDown.bottomOffset = CGPoint(x: 0, y:(addressDropDown.anchorView?.plainView.bounds.height)!)
        
        addressDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.addressIndex = index
            self.txtFromAddress.text = item
            
            self.setAmountUnit()
        }
        
        txtFromAddress.text = accounts[addressIndex].address ?? ""
        self.setAmountUnit()
    }
    
    func setAmountUnit() {
        let selectedAccount = accounts[addressIndex]
        let blockchainNetwork = selectedAccount.blockchainNetwork!
        
        self.txtBlockchain.text = Constant.coinShortNames[blockchainNetwork.rawValue]
        
        var accountType = ""
        
        if let blockchainNetwork = selectedAccount.blockchainNetwork {
            accountType = Constant.coinShortNames[blockchainNetwork.rawValue] ?? ""
        }
        
        self.lblAmount.text = "Amount in \(Constant.coinNames[selectedAccount.blockchainNetwork!.rawValue])"
        
        Abstrakt.shared.getAccountBalance(accountAddress: selectedAccount.address!, blockchainNetwork: blockchainNetwork) { (accountBalance, accountConversionBalance) in
            let value = accountBalance.rounded(toPlaces: 5).toString(decimal: 4) + " " + accountType
            let currencyBalance = Constant.getDollarDisplayValue(amount: accountConversionBalance)
            self.lblFromAddressName.text = "\(value)  \(currencyBalance)"
            
        }
    }
    
    //MARK: - UIButton Action Methods
    
    //MARK: - UIButton Action Methods
    @IBAction func btnCancel_click(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSend_Click(_ sender: Any) {
        
        guard let fromAddress = txtFromAddress.text, let toAddress = txtToAddress.text, let amount = txtAmount.text else {
            Dialog.showMessage("Validation Error", message: "Please enter details, and try again", viewController: self)
            return
        }
        
        let blockchainNetwork = accounts[addressIndex].blockchainNetwork!
        
        if Abstrakt.shared.hasPrivateKey(blockchainNetwork: blockchainNetwork, accountAddress: fromAddress) {
            Abstrakt.shared.sendTransaction(blockchainNetwork: blockchainNetwork, fromAccountAddress: fromAddress, toAccountAddress: toAddress, userId: Abstrakt.shared.getUserId(), amountToTransfer: amount) { (error) in
                if error == nil {
                    Dialog.showMessage("Success", message: "Transaction sent successfully", viewController: self, completion: {
                        if self.isPushed {
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                } else {
                    Dialog.showMessage("Error", message: "Error while sending transactoin: \(String(describing: error))", viewController: self)
                }
            }
        } else {
            Dialog.showMessage("No Private key found!!", message: "Import mnemonic first to send transaction.", viewController: self)
        }
    }
    
    @IBAction func btnCancel_Click(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITextField Delegate Methods
extension SendTransactionVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtBlockchain {
            return false
        } else if textField == txtFromAddress {
            addressDropDown.show()
            return false
        }
        return true
    }
}

