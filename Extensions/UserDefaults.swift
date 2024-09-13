//
//  UserDefaults.swift
//  UserDefaults
//
//  Created by David on 24/08/2021.
//

import Foundation
import UserNotifications

extension UserDefaults {
    // Type-safe access to UserDefaults shared with the extension
    static let shared = UserDefaults(suiteName: "group.dev.snailedit.stjude")!
    
    static let inAppShowMilestonesKey = "inAppShowMilestones"
    static let inAppPreferFutureMilestonesKey = "inAppShowPreferFutureMilestones"
    static let inAppShowFullCurrencySymbolKey = "inAppShowFullCurrencySymbol"
    static let inAppShowGoalPercentageKey = "inAppShowGoalPercentage"
    static let inAppShowMilestonePercentageKey = "inAppShowMilestonePercentage"
    static let inAppUseTrueBlackBackgroundKey = "inAppUseTrueBlackBackground"
    static let showMilestoneNotificationKey = "showMilestoneNotification"
    static let showSignificantAmountNotificationKey = "showSignificantAmountNotification"
    static let showGoalNotificationKey = "showGoalNotification"
    static let showMilestoneAddedNotificationKey = "showMilestoneAddedNotification"
    static let enableCustomAmountNotificationKey = "enableCustomAmountNotification"
    static let customNotificationAmountKey = "customNotificationAmount"
    
    static let shouldShowHeadToHeadKey = "shouldShowHeadToHead"
    static let expandHeadToHeadSectionKey = "expandHeadToHeadSection"
    static let easterEggEnabled2024Key = "easterEggEnabled2024"
    static let iconsUnlockedKey = "iconsUnlocked"
    
    static let disablePixelFontKey = "disablePixelFont"
    static let playSoundsEvenWhenMutedKey = "playSoundsEvenWhenMuted"
    static let coinCountKey = "coinCount"
    static let appAppearanceKey = "appAppearance"
    static let disableCombosKey = "disableCombos"
    
    @objc var iconsUnlocked: Bool {
        get { bool(forKey: Self.iconsUnlockedKey) }
        set { set(newValue, forKey: Self.iconsUnlockedKey) }
    }
    
    @objc var coinCount: Int {
        get { integer(forKey: Self.coinCountKey) }
        set { set(newValue, forKey: Self.coinCountKey) }
    }
    
    @objc var playSoundsEvenWhenMuted: Bool {
        get { bool(forKey: Self.playSoundsEvenWhenMutedKey) }
        set { set(newValue, forKey: Self.playSoundsEvenWhenMutedKey) }
    }
    
    @objc var disablePixelFont: Bool {
        get { bool(forKey: Self.disablePixelFontKey) }
        set { set(newValue, forKey: Self.disablePixelFontKey) }
    }
    
    @objc var shouldShowHeadToHead: Bool {
        get { bool(forKey: Self.shouldShowHeadToHeadKey) }
        set { set(newValue, forKey: Self.shouldShowHeadToHeadKey) }
    }
    
    @objc var expandHeadToHeadSection: Bool {
        get { bool(forKey: Self.expandHeadToHeadSectionKey) }
        set { set(newValue, forKey: Self.expandHeadToHeadSectionKey) }
    }
    
    @objc var relayData: Data? {
        get { data(forKey: "relayData") }
        set { set(newValue, forKey: "relayData") }
    }
    
    @objc var inAppShowMilestones: Bool {
        get { bool(forKey: Self.inAppShowMilestonesKey) }
        set { set(newValue, forKey: Self.inAppShowMilestonesKey) }
    }
    
    @objc var inAppPreferFutureMilestones: Bool {
        get { bool(forKey: Self.inAppPreferFutureMilestonesKey) }
        set { set(newValue, forKey: Self.inAppPreferFutureMilestonesKey) }
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
    
    @objc var inAppUseTrueBlackBackground: Bool {
        get { bool(forKey: Self.inAppUseTrueBlackBackgroundKey) }
        set { set(newValue, forKey: Self.inAppUseTrueBlackBackgroundKey) }
    }
    
    @objc var showMilestoneNotification: Bool {
        get { return bool(forKey: Self.showMilestoneNotificationKey) }
        set { setNotificationPreference(newValue: newValue, for: Self.showMilestoneNotificationKey) }
    }
    
    @objc var showGoalNotification: Bool {
        get { bool(forKey: Self.showGoalNotificationKey) }
        set { setNotificationPreference(newValue: newValue, for: Self.showGoalNotificationKey) }
    }
    
    @objc var showSignificantAmountNotification: Bool {
        get { bool(forKey: Self.showSignificantAmountNotificationKey) }
        set { setNotificationPreference(newValue: newValue, for: Self.showSignificantAmountNotificationKey) }
    }
    
    @objc var showMilestoneAddedNotification: Bool {
        get { bool(forKey: Self.showMilestoneAddedNotificationKey) }
        set { setNotificationPreference(newValue: newValue, for: Self.showMilestoneAddedNotificationKey) }
    }
    
    @objc var enableCustomAmountNotification: Bool {
        get { bool(forKey: Self.enableCustomAmountNotificationKey) }
        set { setNotificationPreference(newValue: newValue, for: Self.enableCustomAmountNotificationKey) }
    }
    
    @objc var customNotificationAmount: Double {
        get { double(forKey: Self.customNotificationAmountKey) }
        set { UserDefaults.shared.set(newValue, forKey: Self.customNotificationAmountKey) }
    }
    
    @objc var easterEggEnabled2024: Bool {
        get { bool(forKey: Self.easterEggEnabled2024Key) }
        set { UserDefaults.shared.set(newValue, forKey: Self.easterEggEnabled2024Key) }
    }
    
    @objc var appAppearance: Int {
        get { object(forKey: Self.appAppearanceKey) as? Int ?? 2 }
        set { UserDefaults.shared.set(newValue, forKey: Self.appAppearanceKey) }
    }
    
    @objc var disableCombos: Bool {
        get { bool(forKey: Self.disableCombosKey) }
        set { UserDefaults.shared.set(newValue, forKey: Self.disableCombosKey) }
    }
}
