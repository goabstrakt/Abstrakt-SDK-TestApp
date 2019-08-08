//
//  AuthWithUsername.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 29/07/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK

class AuthWithUsername: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK: - UIButton Action Methods
    
    @IBAction func btnSubmit_Click(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "clean_connection")
        if let email = txtEmail.text, email.count > 0, let password = txtPassword.text, password.count > 0 {
            Abstrakt.shared.authenticateWithEmailAndPassword(email: email, password: password, completion: { (status) in
                if status == "success" {
                    Constant.appDelegate.makeRoot()
                } else {
                    Dialog.showMessage(status ?? "Failed to login", message: "", viewController: self)
                }
            })
        } else {
            Dialog.showMessage("Error", message: "Email or Password is not valid.", viewController: self)
        }
    }
    
    //MARK: - Variables
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setInitialValue()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setInitialValue() {
        self.txtEmail.text = "daniel1@wayne-enterprises.com"
        self.txtPassword.text = "BatmanLaidAnEgg2"
    }
    
    //MARK: - Helper Methods
}
