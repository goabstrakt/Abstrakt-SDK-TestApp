//
//  ConnectionCell.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 01/08/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit

class ConnectionCell: UITableViewCell {
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblUser: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
