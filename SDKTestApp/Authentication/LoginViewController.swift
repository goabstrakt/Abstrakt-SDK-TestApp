//
//  LoginViewController.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 30/07/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK

class LoginViewController: UIViewController {

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: - IBOuttlet Action
    @IBAction func btnLoginWithEmail(_ sender: Any) {
        
    }
    
    
    @IBAction func btnLoginWithAuth0(_ sender: Any) {
        Abstrakt.shared.authenticate { (status) in
            if status == "success" {
                DispatchQueue.main.async {
                    Constant.appDelegate.makeRoot()
                }
            } else {
                Dialog.showMessage(status ?? "Failed to login", message: "", viewController: self)
            }
        }
    }
}
