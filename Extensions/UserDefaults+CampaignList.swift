//
//  UserDefaults+CampaignList.swift
//  St Jude
//
//  Created by Ben Cardy on 26/08/2022.
//

import Foundation

extension UserDefaults {
    static let campaignListSortOrderKey = "campaignListSortOrder"
    
    var campaignListSortOrder: FundraiserSortOrder {
        get {
            FundraiserSortOrder(rawValue: integer(forKey: Self.campaignListSortOrderKey)) ?? .byStarred
        }
        set {
            set(newValue.rawValue, forKey: Self.campaignListSortOrderKey)
        }
    }
}
