//
//  UserDefaults.swift
//  UserDefaults
//
//  Created by David on 24/08/2021.
//

import Foundation

extension UserDefaults {
    // Type-safe access to UserDefaults shared with the extension
    static let shared = UserDefaults(suiteName: "group.com.rosemaryorchard.stjude")!
    
    @objc var relayData: Data? {
        get { data(forKey: "relayData") }
        set { set(newValue, forKey: "relayData") }
    }
    
    @objc var inAppShowMilestones: Bool {
        get { bool(forKey: "inAppShowMilestones") }
        set { set(newValue, forKey: "inAppShowMilestones") }
    }
    
    @objc var inAppShowFullCurrencySymbol: Bool {
        get { bool(forKey: "inAppShowFullCurrencySymbol") }
        set { set(newValue, forKey: "inAppShowFullCurrencySymbol") }
    }

}
