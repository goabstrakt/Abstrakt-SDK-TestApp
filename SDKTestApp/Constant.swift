//
//  Constant.swift
//  SDKTestApp
//
//  Created by Dharmesh Vaghani on 29/07/19.
//  Copyright © 2019 VaultWallet. All rights reserved.
//

import UIKit
import AbstraktSDK

enum SegueIdentifier: String {
    case loginWithUserId = "loginWithUserId"
    case profileSegue
    case accountsSegue
    case transactionsSegue
    case sendTransactionSegue
    case getTransactions
    case importMnemonicSegue
    case connectionSegue
    case accountBalanceSegue
    case createAccountSegue
}

enum StoredValues: String {
    case isLoggedIn = "isLoggedIn"
}

enum StoryboardIds: String {
    case LoginNav = "LoginNav"
    case HomeNav = "HomeNav"
}

public class Constant {
    
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static let coinShortNames: [Int: String] = [0: "AION", 1: "AION Testnet", 2: "ETH", 3: "ETH Testnet", 4: "BTC", 5: "BTC Testnet"]
    
    static let coinNames = ["Aion", "Aion Testnet", "Ethereum", "Ethereum Testnet", "Bitcoin", "Bitcoin Testnet"]
    
    static let blockchainNetworks = [BlockchainNetwork.AionMainnet, BlockchainNetwork.AionTestnet, BlockchainNetwork.EthMainnet, BlockchainNetwork.EthTestnet, BlockchainNetwork.BitcoinMainnet, BlockchainNetwork.BitcoinTestnet]
    
    public static func getDollarDisplayValue(amount: String) -> String {
        if let amount = NumberFormatter().number(from: amount)?.doubleValue {
            return "$" + String(format: "%.2f", amount)
        } else {
            return "$" + amount
        }
    }
    
    public static func getDollarDisplayValue(amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }
}


class Dialog {
    
    static func showAlert(_ title: String, message: String, actions: [String], viewController: UIViewController , handler: [()->()]) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for i in 0..<actions.count {
            alert.addAction(UIAlertAction(title: actions[i], style: .default, handler: { _ in handler[i]()}))
        }
        show(alert: alert, viewController: viewController)
    }
    
    static func showMessage(_ title: String, message: String, viewController: UIViewController, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?()}))
        show(alert: alert, viewController: viewController)
    }
    
    static func showConfirmationWith(message: String, viewController: UIViewController, okTapped: (() -> Void)? = nil, cancelTapped: (() -> Void)? = nil) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in cancelTapped?()}))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in okTapped?()}))
        show(alert: alert, viewController: viewController)
    }
    
    static func show(alert: UIAlertController, viewController: UIViewController) {
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func toString(decimal: Int = 4) -> String {
        let value = decimal < 0 ? 0 : decimal
        return String(format: "%.\(value)f", self)
    }
}

extension Date {
    
    func offsetFrom(date : Date) -> String {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = Calendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);
        
        let secondsSuffix = difference.second ?? 0 > 1 ? "seconds" : "second"
        let minutesSuffix = difference.minute ?? 0 > 1 ? "minutes" : "minute"
        let hoursSuffix = difference.hour ?? 0 > 1 ? "hours" : "hour"
        let daysSuffix = difference.day ?? 0 > 1 ? "days" : "day"
        
        let seconds = "\(difference.second ?? 0) \(secondsSuffix),"
        let minutes = "\(difference.minute ?? 0) \(minutesSuffix)," + " " + seconds
        let hours = "\(difference.hour ?? 0) \(hoursSuffix)," + " " + minutes
        let days = "\(difference.day ?? 0) \(daysSuffix)," + " " + hours
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        return ""
    }
}

