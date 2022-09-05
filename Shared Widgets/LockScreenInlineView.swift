//
//  LockScreenInlineView.swift
//  St Jude
//
//  Created by Ben Cardy on 04/09/2022.
//

import SwiftUI

struct LockScreenInlineView: View {
    
    let campaign: TiltifyWidgetData
    var shouldShowFullCurrencySymbol: Bool = false
    var shouldShowGoalPercentage: Bool = false
    
    var accessoryInlineText: String {
        var amount = campaign.totalRaisedDescription(showFullCurrencySymbol: shouldShowFullCurrencySymbol)
        if shouldShowGoalPercentage {
            amount = "\(amount) • \(campaign.shortPercentageReachedDescription ?? "0%")"
        }
        return amount
    }
    
    var accessoryInlineLabel: String {
        campaign.percentageReached ?? 0 >= 1 ? "party.popper.fill" : ""
    }
    
    var body: some View {
        Label(accessoryInlineText, systemImage: accessoryInlineLabel)
            .widgetURL(URL(string: campaign.widgetURL)!)
    }
}

struct LockScreenInlineView_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenInlineView(campaign: sampleCampaign)
    }
}
