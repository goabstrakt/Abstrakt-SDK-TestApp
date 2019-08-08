//
//  ProfileViewController.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 30/07/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK
import SDWebImage

class ProfileViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserId: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    
    //MARK: - Variables
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    //MARK: - Helper Methods
    func initView() {
        lblUserId.text = Abstrakt.shared.getUserId()
        lblEmail.text = Abstrakt.shared.getUserEmail()
        lblUsername.text = Abstrakt.shared.getUserName()
        
        let avatar = Abstrakt.shared.getUserAvatar()
        
        if let avatarUrl = URL(string: avatar)  {
            imgProfile.sd_setImage(with: avatarUrl, placeholderImage: nil)
        }
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func btnLogout_Click(_ sender: Any) {
        Abstrakt.shared.logout()
        Constant.appDelegate.makeRoot()
    }

}
