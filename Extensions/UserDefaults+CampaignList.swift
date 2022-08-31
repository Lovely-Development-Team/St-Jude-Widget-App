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
    
    var campaignListSortOrder: FundraiserSortOrder {
        get {
            FundraiserSortOrder(rawValue: integer(forKey: Self.campaignListSortOrderKey)) ?? .byStarred
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
            WidgetAppearance(rawValue: integer(forKey: Self.shareScreenshotInitialAppearanceKey)) ?? .stjude
        }
        set {
            set(newValue.rawValue, forKey: Self.shareScreenshotInitialAppearanceKey)
        }
    }
    
}
