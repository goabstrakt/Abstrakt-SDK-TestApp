//
//  ConnectionsVC.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 01/08/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK

class ConnectionsVC: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {

    //MARK: - IBOutlets
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var searchViewBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var lblContactName: UILabel!
    @IBOutlet weak var imgContactAvatar: UIImageView!
    
    //MARK: - Variables
    lazy var connections: [UserConnection] = {
        var dataSource = [UserConnection]()
        Abstrakt.shared.getConnections(completion: { (object) in
            dataSource = object
        })
        
        return dataSource
    }()
    
    lazy var pendingConnections: [PendingConnectionRequest] = {
        var dataSource = [PendingConnectionRequest]()
        Abstrakt.shared.getPendingConnectionRequests(completion: { (object) in
            dataSource = object
        })
        
        return dataSource
    }()
    
    var searchController: UISearchController!
    var searchResult = [SearchedContact]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Abstrakt.shared.delegate = self
        
        searchViewBottomSpace.constant = -searchView.frame.height
        self.view.layoutIfNeeded()

        tblMain.tableFooterView = UIView()
        addSearchBar()
    }

    //MARK: - Helper Methods
    func addSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = searchController
    }
    
    func showSearchView() {
        if searchResult.count > 0 {
            let searchedContact = searchResult.first
            searchViewBottomSpace.constant = 0
            lblContactName.text = searchedContact?.name ?? ""
            
            if let avatar = searchedContact?.avatar, let avatarUrl = URL(string: avatar) {
                imgContactAvatar.sd_setImage(with: avatarUrl, placeholderImage: nil)
            }
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func btnCancel_Click(_ sender: Any) {
        searchViewBottomSpace.constant = -searchView.frame.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnSendRequest_Click(_ sender: Any) {
        searchViewBottomSpace.constant = -searchView.frame.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        guard searchResult.count > 0, let searchedConnection = searchResult.first, let userId = searchedConnection.userId else {
            return
        }
        Abstrakt.shared.requestConnection(userId: userId)
    }
}

//MARK: - SearchResults Updating

extension ConnectionsVC {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.lowercased(), text.count > 0 else { return }
        
        Abstrakt.shared.searchContact(email: text) { (error, result) in
            if error != nil {
                self.searchController.isActive = false
                Dialog.showMessage("Error", message: "Error while fetching contact info \(String(describing: error))", viewController: self)
            } else if result.count == 0 {
                self.searchController.isActive = false
                Dialog.showMessage("No Contact Found!!!", message: "", viewController: self)
            } else {
                self.searchResult = result
                self.showSearchView()
            }
        }
    }
    
}

//MARK: - UITableView Delegate & Datasource methods

extension ConnectionsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return pendingConnections.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if pendingConnections.count > 0, section == 0 {
            return "Pending Connections"
        } else {
            return "Connections"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pendingConnections.count > 0, section == 0 {
            return pendingConnections.count
        } else {
            return connections.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionCell", for: indexPath) as! ConnectionCell
        
        if pendingConnections.count > 0, indexPath.section == 0 {
            let connectionRequest = pendingConnections[indexPath.row]
            
            guard let sender = connectionRequest.receiver else {
                
                cell.imgAvatar.image = nil
                cell.lblUser.text = "Unnamed"
                
                return cell
            }
            
            cell.imgAvatar.image = nil
            cell.imgAvatar.sd_setImage(with: URL(string: sender.avatar), placeholderImage: nil)
            cell.lblUser.text = sender.name
            
        } else {
            let connection = connections[indexPath.row]
            
            cell.imgAvatar.image = nil
            if let avatar = connection.otherUserId?.avatar {
                cell.imgAvatar.sd_setImage(with: URL(string: avatar), placeholderImage: nil)
            }
            
            cell.lblUser.text = connection.otherUserId?.name ?? ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Abstrakt Delegate Methods

extension ConnectionsVC: AbstraktDelegate {
    func connectionRequestSent(connectionRequest: PendingConnectionRequest) {
        pendingConnections.append(connectionRequest)
        tblMain.reloadData()
    }
}
