//
//  LocalMnemonicsVC.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 08/08/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK

class LocalMnemonicsVC: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    //MARK: - Variables
    var keyAlias:String?
    var detailText:String?
    
    lazy var mnemonics: [String: String] = {
        var dataSource = [String: String]()
        
        Abstrakt.shared.getLocalMnemonics { (objects) in
            dataSource = objects
            self.emptyView.isHidden = objects.count > 0 ? true : false
        }
        
        return dataSource
    }()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bringSubviewToFront(emptyView)
        tblMain.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.backupMnemonicSegue.rawValue {
            let dest = segue.destination as! BackupKeychainVC
            dest.isMnemonic = true
            dest.mnemonicAlias = self.keyAlias
            dest.detailText = self.detailText
        }
    }
}

//MARK: - UITableView Delegate & Datasource

extension LocalMnemonicsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  Array(mnemonics.keys).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let key = Array(mnemonics.keys)[indexPath.row]
        let name = mnemonics[key]
        
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        keyAlias = Array(mnemonics.keys)[indexPath.row]
        detailText = mnemonics[keyAlias!]
        
        self.performSegue(withIdentifier: SegueIdentifier.backupMnemonicSegue.rawValue, sender: self)
    }
}
