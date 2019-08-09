//
//  GetAccountBalanceVC.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 01/08/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK
import DropDown

class GetAccountBalanceVC: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var txtAddress: UITextField!
    
    //MARK: - Variables
    lazy var accounts:[Account] = {
        var dataSource = [Account]()
        Abstrakt.shared.getMyAccounts(blockchainNetworks: Constant.blockchainNetworks, completion: { (accounts) in
            dataSource = accounts
        })
        return dataSource
    }()
    
    let dropDown = DropDown()
    var selectedIndex = 0
    var accountsArray = [Account]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        initTableView()
    }
    
    func initTableView() {
        tblMain.register(UINib(nibName: "GeneralTableViewCell", bundle: nil), forCellReuseIdentifier: "GeneralTableViewCell")
        tblMain.rowHeight = UITableView.automaticDimension
        tblMain.estimatedRowHeight = 100
        tblMain.tableFooterView = UIView()
    }
    
    func setupUI() {
        if accounts.count == 0 {
            Dialog.showMessage("No Accounts Found!!!", message: "", viewController: self, completion: {
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            txtAddress.text = accounts[selectedIndex].address ?? ""
            
            dropDown.anchorView = txtAddress
            dropDown.dataSource = accounts.map { $0.address ?? "" }
            dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
            
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                self.selectedIndex = index
                self.txtAddress.text = item
            }
            
            txtAddress.text = accounts[selectedIndex].address ?? ""
        }
    }
    
    
    //MARK: - UIButton Action Methods
    @IBAction func btnGet_Click(_ sender: Any) {
        if let address = txtAddress.text, address.count > 0 {
            let account = accounts[selectedIndex]
            
            accountsArray = [account]
            tblMain.reloadData()
        }
    }
}

//MARK: - UITableview Delegaet & Datasource Methods
extension GetAccountBalanceVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTableViewCell", for: indexPath) as! GeneralTableViewCell
        
        let account = accountsArray[indexPath.row]
        
        cell.setAccountDetails(account: account)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UITextField Delegate
extension GetAccountBalanceVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtAddress {
            dropDown.show()
            return false
        }
        return true
    }
}
