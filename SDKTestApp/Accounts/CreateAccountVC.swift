//
//  CreateAccountVC.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 30/07/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK
import DropDown

class CreateAccountVC: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtCoin: UITextField!
    
    //MARK: - Variables
    
    var blockchainNetworkIndex = 0
    let dropDown = DropDown()
    var isPushed = false
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUi()
    }
    
    //MARK: - Helper Methods
    
    func setupUi() {
        
        if isPushed {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        dropDown.anchorView = txtCoin
        dropDown.dataSource = Constant.coinNames
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.blockchainNetworkIndex = index
            self.txtCoin.text = item
        }
        
        txtCoin.text = Constant.coinNames[blockchainNetworkIndex]
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func btnCancel_click(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCreate_Click(_ sender: Any) {
        if let nickName = txtName.text, nickName.count > 0 {
            Abstrakt.shared.createAccount(nickName: nickName, blockchainNetwork: Constant.blockchainNetworks[blockchainNetworkIndex]) { (error, account) in
                if error == nil {
                    
                    Dialog.showMessage("Account created successfully!!!", message: "", viewController: self, completion: {
                        if self.isPushed {
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                } else {
                    Dialog.showMessage("Error", message: "\(String(describing: error))", viewController: self)
                }
            }
        } else {
            Dialog.showMessage("Validation Error", message: "Please enter name of account", viewController: self)
        }
    }
}

extension CreateAccountVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtCoin {
            txtName.resignFirstResponder()
            dropDown.show()
            return false
        }
        return true
    }
}
