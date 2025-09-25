//
//  LockScreenInlineView.swift
//  St Jude
//
//  Created by Ben Cardy on 04/09/2022.
//

import SwiftUI
import WidgetKit

struct LockScreenInlineView: View {
    
    let campaign: TiltifyWidgetData?
    var shouldShowFullCurrencySymbol: Bool = false
    var shouldShowGoalPercentage: Bool = false
    
    var accessoryInlineText: String {
        if let campaign = campaign {
            var amount = campaign.totalRaisedDescription(showFullCurrencySymbol: shouldShowFullCurrencySymbol)
            if shouldShowGoalPercentage {
                amount = "\(amount) • \(campaign.shortPercentageReachedDescription ?? "0%")"
            }
            return amount
        } else {
            return ""
        }
    }
    
    @ViewBuilder
    func accessoryInlineLabel(title: String) -> some View {
        if campaign?.percentageReached ?? 0 >= 1 {
            Label(title, systemImage: "party.popper.fill")
        } else {
            Label(title, image: "relay.logo")
        }
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(.clear, for: .widget)
        } else {
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        if let campaign = campaign {
            self.accessoryInlineLabel(title: accessoryInlineText)
                .widgetURL(URL(string: campaign.widgetURL)!)
        } else {
            self.accessoryInlineLabel(title: "Choose a fundraiser")
        }
    }
}

struct LockScreenInlineView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            LockScreenInlineView(campaign: sampleCampaign)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
        } else {
            // Fallback on earlier versions
        }
    }
}
