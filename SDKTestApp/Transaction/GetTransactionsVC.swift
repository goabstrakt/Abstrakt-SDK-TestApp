//
//  GetTransactionsVC.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 01/08/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK
import DropDown

class GetTransactionsVC: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var txtTransactionBy: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtBlockchain: UITextField!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var pendingSwitch: UISwitch!
    
    @IBOutlet weak var addressStack: UIStackView!
    @IBOutlet weak var blockchainStack: UIStackView!
    
    //MARK: - Variables
    lazy var accounts:[Account] = {
        var dataSource = [Account]()
        Abstrakt.shared.getMyAccounts(blockchainNetworks: Constant.blockchainNetworks, completion: { (accounts) in
            dataSource = accounts
        })
        return dataSource
    }()
    
    var transactions = [Transaction]()
    
    let transactionBy = ["All", "Address", "Blockchain Network"]
    
    let transactionByDropDown = DropDown()
    let addressDropDown = DropDown()
    let blockchainDropDown = DropDown()
    
    var transactionByIndex = 0
    var addressIndex = 0
    var blockchainNetworkIndex = 0
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        self.view.bringSubviewToFront(emptyView)
        
        tblMain.tableFooterView = UIView()
        
        transactionByDropDown.anchorView = txtTransactionBy
        transactionByDropDown.dataSource = transactionBy
        transactionByDropDown.bottomOffset = CGPoint(x: 0, y:(transactionByDropDown.anchorView?.plainView.bounds.height)!)
        
        transactionByDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.transactionByIndex = index
            self.txtTransactionBy.text = item
            
            switch index {
            case 0:
                self.addressStack.isHidden = true
                self.blockchainStack.isHidden = true
            case 1:
                self.addressStack.isHidden = false
                self.blockchainStack.isHidden = true
            case 2:
                self.addressStack.isHidden = true
                self.blockchainStack.isHidden = false
            default:
                self.addressStack.isHidden = true
                self.blockchainStack.isHidden = true
            }
            
        }
        
        txtTransactionBy.text = transactionBy[transactionByIndex]
        
        let addresses = accounts.map { $0.address ?? "" }
        
        addressDropDown.anchorView = txtAddress
        addressDropDown.dataSource = addresses
        addressDropDown.bottomOffset = CGPoint(x: 0, y:(addressDropDown.anchorView?.plainView.bounds.height)!)
        
        addressDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.addressIndex = index
            self.txtAddress.text = item
        }
        
        txtAddress.text = addresses[addressIndex]
        
        blockchainDropDown.anchorView = txtBlockchain
        blockchainDropDown.dataSource = Constant.coinNames
        blockchainDropDown.bottomOffset = CGPoint(x: 0, y:(blockchainDropDown.anchorView?.plainView.bounds.height)!)
        
        blockchainDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.blockchainNetworkIndex = index
            self.txtBlockchain.text = item
        }
        
        txtBlockchain.text = Constant.coinNames[blockchainNetworkIndex]
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func btnSend_Click(_ sender: Any) {
        
        if pendingSwitch.isOn {
            switch transactionByIndex {
            case 0:
                Abstrakt.shared.getPendingTransactions(blockchainNetworks: Constant.blockchainNetworks) { (objects) in
                    self.reloadTableView(transactions: objects)
                }
                break
            case 1:
                let selectedAddress = accounts[addressIndex].address ?? ""
                let blockchainNetwork = accounts[addressIndex].blockchainNetwork ?? BlockchainNetwork.AionTestnet
                
                Abstrakt.shared.getPendingTransactionsFromAccount(accountAddress: selectedAddress, blockchainNetwork: blockchainNetwork) { (objects) in
                    self.reloadTableView(transactions: objects)
                }
                break
            case 2:
                let blockchainNetwork = Constant.blockchainNetworks[blockchainNetworkIndex]
                Abstrakt.shared.getPendingTransactions(blockchainNetworks: [blockchainNetwork]) { (objects) in
                    self.reloadTableView(transactions: objects)
                }
                break
                
            default:
                break
            }
        } else {
            switch transactionByIndex {
            case 0:
                Abstrakt.shared.getTransactions(blockchainNetworks: Constant.blockchainNetworks) { (objects) in
                    self.reloadTableView(transactions: objects)
                }
                break
            case 1:
                let selectedAddress = accounts[addressIndex].address ?? ""
                let blockchainNetwork = accounts[addressIndex].blockchainNetwork ?? BlockchainNetwork.AionTestnet
                Abstrakt.shared.getTransactionsFromAccount(accountAddress: selectedAddress, blockchainNetwork: blockchainNetwork) { (objects) in
                    self.reloadTableView(transactions: objects)
                }
                break
            case 2:
                let blockchainNetwork = Constant.blockchainNetworks[blockchainNetworkIndex]
                Abstrakt.shared.getTransactionsFromBlockchainNetwork(blockchainNetwork: blockchainNetwork) { (objects) in
                    self.reloadTableView(transactions: objects)
                }
                break
                
            default:
                break
            }
        }
    }
    
    func reloadTableView(transactions: [Transaction]) {
        self.transactions = transactions.sorted(by: { (first, second) -> Bool in
            first.blockTimestamp!.compare(second.blockTimestamp!) == .orderedDescending
        })
        emptyView.alpha = transactions.count == 0 ? 1 : 0
        tblMain.reloadData()
    }
}

//MARK: - Tableview delegate & datasource methods

extension GetTransactionsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountListCell", for: indexPath) as! AccountListCell
        
        let transaction = transactions[indexPath.row]
        
        cell.setTransactionDetails(transaction: transaction)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UITextfield Delegate
extension GetTransactionsVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtTransactionBy {
            transactionByDropDown.show()
            return false
        } else if textField == txtBlockchain {
            blockchainDropDown.show()
            return false
        } else if textField == txtAddress {
            addressDropDown.show()
            return false
        }
        return true
    }
}
