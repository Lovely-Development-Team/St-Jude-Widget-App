//
//  UserDefaults+CampaignList.swift
//  St Jude
//
//  Created by Ben Cardy on 26/08/2022.
//

import Foundation

extension UserDefaults {
    static let campaignListSortOrderKey = "campaignListSortOrder"
    static let campaignListCompactViewKey = "campaignListCompactView"
    
    static let shareScreenshotInitialAppearanceKey = "shareScreenshotInitialAppearance"
    static let shareScreenshotClipCornersKey = "shareScreenshotClipCorners"
    static let shareScreenshotShowMilestonesKey = "shareScreenshotShowMilestones"
    static let shareScreenshotShowMilestonePercentageKey = "shareScreenshotShowMilestonePercentage"
    static let shareScreenshotPreferFutureMilestonesKey = "shareScreenshotPreferFutureMilestones"
    static let shareScreenshotShowFullCurrencySymbolKey = "shareScreenshotShowFullCurrencySymbol"
    static let shareScreenshotShowMainGoalPercentageKey = "shareScreenshotShowMainGoalPercentage"
    static let shareScreenshotDisablePixelThemeKey = "shareScreenshotDisablePixelTheme"
    
    @objc var shareDisablePixelTheme: Bool {
        get { bool(forKey: Self.shareScreenshotDisablePixelThemeKey) }
        set { set(newValue, forKey: Self.shareScreenshotDisablePixelThemeKey) }
    }
    
    var campaignListSortOrder: FundraiserSortOrder {
        get {
            FundraiserSortOrder(rawValue: integer(forKey: Self.campaignListSortOrderKey)) ?? .byName
        }
        set {
            set(newValue.rawValue, forKey: Self.campaignListSortOrderKey)
        }
    }
    
    @objc var campaignListCompactView: Bool {
        get { bool(forKey: Self.campaignListCompactViewKey) }
        set { set(newValue, forKey: Self.campaignListCompactViewKey) }
    }
    
    var shareScreenshotInitialAppearance: WidgetAppearance {
        get {
            var intValue = integer(forKey: Self.shareScreenshotInitialAppearanceKey)
            if intValue == 0 {
                intValue = WidgetAppearance.stjude.rawValue
            }
            return WidgetAppearance(rawValue: intValue) ?? .stjude
        }
        set {
            set(newValue.rawValue, forKey: Self.shareScreenshotInitialAppearanceKey)
        }
    }
    
    var shareScreenshotClipCorners: Bool {
        get { bool(forKey: Self.shareScreenshotClipCornersKey) }
        set { set(newValue, forKey: Self.shareScreenshotClipCornersKey) }
    }
    
}
