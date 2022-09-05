//
//  CampaignLockScreenWidgetView.swift
//  St Jude
//
//  Created by Ben Cardy on 05/09/2022.
//

import SwiftUI
import WidgetKit

struct CampaignLockScreenWidgetView : View {
    @Environment(\.widgetFamily) var family
    
    var entry: CampaignLockScreenProvider.Entry
    
    var showPreviousMilestone: Bool {
        return isExtraLargeSize(family: family) || entry.campaign.nextMilestone == nil
    }
    
    var titleFont: Font {
        switch family {
        case .systemSmall:
            return .headline
        case .systemMedium:
            return .title2
        default:
            return .largeTitle
        }
    }
    
    var raisedAmountFont: Font {
        switch family {
        case .systemSmall:
            return .headline
        default:
            return .largeTitle
        }
    }
    
    var shouldShowGoalPercentage: Bool {
        entry.configuration.showGoalPercentage?.boolValue == true
    }
    
    var shouldShouldFullCurrencySymbol: Bool {
        entry.configuration.showFullCurrencySymbol?.boolValue == true
    }

    var accessoryInlineText: String {
        var amount = entry.campaign.totalRaisedDescription(showFullCurrencySymbol: shouldShouldFullCurrencySymbol)
        if shouldShowGoalPercentage {
            amount = "\(amount) • \(entry.campaign.shortPercentageReachedDescription ?? "0%")"
        }
        return amount
    }
    
    var accessoryInlineLabel: String {
        entry.campaign.percentageReached ?? 0 >= 1 ? "flag.checkered" : ""
    }
    
    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            switch family {
            case .accessoryRectangular:
                LockScreenRectangularView(campaign: entry.campaign, shouldShowFullCurrencySymbol: shouldShouldFullCurrencySymbol, shouldShowGoalPercentage: shouldShowGoalPercentage)
            case .accessoryCircular:
                LockScreenCircularView(campaign: entry.campaign, shouldShowGoalPercentage: shouldShowGoalPercentage)
            default:
                LockScreenInlineView(campaign: entry.campaign, shouldShowFullCurrencySymbol: shouldShouldFullCurrencySymbol, shouldShowGoalPercentage: shouldShowGoalPercentage)
            }
        } else {
            Text("Not available")
        }
    }
}
