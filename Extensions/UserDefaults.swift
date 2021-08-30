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
    
    static let inAppShowMilestonesKey = "inAppShowMilestones"
    static let inAppShowFullCurrencySymbolKey = "inAppShowFullCurrencySymbol"
    static let inAppShowGoalPercentageKey = "inAppShowGoalPercentage"
    static let inAppShowMilestonePercentageKey = "inAppShowMilestonePercentage"
    
    @objc var relayData: Data? {
        get { data(forKey: "relayData") }
        set { set(newValue, forKey: "relayData") }
    }
    
    @objc var inAppShowMilestones: Bool {
        get { bool(forKey: Self.inAppShowMilestonesKey) }
        set { set(newValue, forKey: Self.inAppShowMilestonesKey) }
    }
    
    @objc var inAppShowFullCurrencySymbol: Bool {
        get { bool(forKey: Self.inAppShowFullCurrencySymbolKey) }
        set { set(newValue, forKey: Self.inAppShowFullCurrencySymbolKey) }
    }
    
    @objc var inAppShowGoalPercentage: Bool {
        get { bool(forKey: Self.inAppShowGoalPercentageKey) }
        set { set(newValue, forKey: Self.inAppShowGoalPercentageKey) }
    }
    
    @objc var inAppShowMilestonePercentage: Bool {
        get { bool(forKey: Self.inAppShowMilestonePercentageKey) }
        set { set(newValue, forKey: Self.inAppShowMilestonePercentageKey) }
    }

}
