//
//  ViewController.swift
//  SDKTestApp
//
//  Created by macintosh on 01/06/2019.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - IBOutlet
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var viewMqttStatus: UIView!
    @IBOutlet weak var lblMqttStatus: UILabel!
    
    //MARK: - Variables
    
    var sections = ["Sample Screens", "Test Functions"]
    var rows = [[0:"Profile",
                 1:"Account Management",
                 2:"Transactions",
                 3:"Contacts"],
                [0:"Create Account",
                 1:"Import Mnemonic",
                 2:"Get Local Mnemonics",
                 3:"Send Transaction",
                 4:"Get Transaction",
                 5:"Get Account Balance"]]
//        , "Get Local Mnemonic" , "Backup Mnemonic", "Backup Account"]]
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tblMain.reloadData()
        tblMain.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Abstrakt.shared.delegate = self
        
        guard let selectedIndexPath = tblMain.indexPathForSelectedRow else {
            return
        }
        
        tblMain.deselectRow(at: selectedIndexPath, animated: true)
        setMqttConnectionStatus()
    }
    
    //MARK: - UIButton Action Methods
    
    @IBAction func btnLogout_Click(_ sender: Any) {
        Dialog.showAlert("Are you sure?", message: "Do you really want to logout?", actions: ["Yes", "No"], viewController: self, handler: [{ Abstrakt.shared.logout()
            Constant.appDelegate.makeRoot() }, {}])
    }
    
    // MARK: - UITableView Data Source Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = rows[indexPath.section][indexPath.row]
        return cell
    }
    
    // MARK: - UITableView Delegate Functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: SegueIdentifier.profileSegue.rawValue, sender: self)
                break
            case 1:
                self.performSegue(withIdentifier: SegueIdentifier.accountsSegue.rawValue, sender: self)
                break
            case 2:
                self.performSegue(withIdentifier: SegueIdentifier.transactionsSegue.rawValue, sender: self)
                break
            case 3:
                self.performSegue(withIdentifier: SegueIdentifier.connectionSegue.rawValue, sender: self)
            default:
                Dialog.showMessage("wtf!", message: "", viewController: self)
                break
            }
        }  else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: SegueIdentifier.createAccountSegue.rawValue, sender: self)
                break
            case 1:
                self.performSegue(withIdentifier: SegueIdentifier.importMnemonicSegue.rawValue, sender: self)
                break
            case 2:
                self.performSegue(withIdentifier: SegueIdentifier.getMnemonicsSegue.rawValue, sender: self)
                break
            case 3:
                self.performSegue(withIdentifier: SegueIdentifier.sendTransactionSegue.rawValue, sender: self)
                break
            case 4:
                self.performSegue(withIdentifier: SegueIdentifier.getTransactions.rawValue, sender: self)
                break
            case 5:
                self.performSegue(withIdentifier: SegueIdentifier.accountBalanceSegue.rawValue, sender: self)
                break
            
            default:
                Dialog.showMessage("wtf!", message: "", viewController: self)
                break
            }
        }
    }
    
    func plistValues(bundle: Bundle) -> (clientId: String, domain: String)? {
        guard
            let path = bundle.path(forResource: "Auth0", ofType: "plist"),
            let values = NSDictionary(contentsOfFile: path) as? [String: Any]
            else {
                print("Missing Auth0.plist file with 'ClientId' and 'Domain' entries in main bundle!")
                return nil
        }
        
        guard
            let clientId = values["ClientId"] as? String,
            let domain = values["Domain"] as? String
            else {
                print("Auth0.plist file at \(path) is missing 'ClientId' and/or 'Domain' entries!")
                print("File currently has the following entries: \(values)")
                return nil
        }
        return (clientId: clientId, domain: domain)
    }
    
    //MARK: - Navigation Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.createAccountSegue.rawValue {
            let dest = segue.destination as! CreateAccountVC
            dest.isPushed = true
        } else if segue.identifier == SegueIdentifier.sendTransactionSegue.rawValue {
            let dest = segue.destination as! SendTransactionVC
            dest.isPushed = true
        }
    }
}

extension ViewController: AbstraktDelegate {
    
    func didConnected() {
        setMqttConnectionStatus()
    }
    
    func didDisconnected() {
        setMqttConnectionStatus()
    }
    
    //MARK: - Helper Method
    func setMqttConnectionStatus() {
        let connectionStatus = Abstrakt.shared.getConnectionStatus()
        viewMqttStatus.backgroundColor = connectionStatus ? UIColor(red: 100/255, green: 135/255, blue: 239/255, alpha: 1) : UIColor(red: 230/255, green: 125/255, blue: 69/255, alpha: 1)
        lblMqttStatus.text = connectionStatus ? "MQTT Connected" : "MQTT Disconnected"
    }
}
