//
//  LockScreenRectangularView.swift
//  St Jude
//
//  Created by Ben Cardy on 04/09/2022.
//

import SwiftUI
import WidgetKit

struct LockScreenRectangularView: View {
    
    let campaign: TiltifyWidgetData?
    var shouldShowFullCurrencySymbol: Bool = false
    var shouldShowGoalPercentage: Bool = false
    var shouldDisableCombos: Bool = false
    
    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(.clear, for: .widget)
        } else {
            content
        }
    }
    
    @ViewBuilder
    var rawContent: some View {
        VStack(spacing: 4) {
            Spacer()
                .frame(minHeight: 0, maxHeight: .infinity)
            Text(campaign?.totalRaisedDescription(showFullCurrencySymbol: shouldShowFullCurrencySymbol) ?? "Choose a fundraiser")
                .font(.title3)
                .scaledToFill()
                .lineLimit(1)
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .minimumScaleFactor(0.2)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                if campaign?.multiplier ?? 1 > 1 && !shouldDisableCombos {
                    Text("\(campaign?.multiplier ?? 1)x")
                        .font(.caption)
                }
                ProgressBar(value: .constant(Float(campaign?.progressBarAmount(disableCombos: shouldDisableCombos) ?? 0)), fillColor: .white, pixelScale: Double.spriteScale/2)
                    .frame(height: 6)
            }
            if shouldShowGoalPercentage, let campaign = campaign, let percentage = campaign.shortPercentageReachedDescription {
                Text("\(percentage) of \(campaign.goalDescription(showFullCurrencySymbol: shouldShowFullCurrencySymbol))")
                    .font(.caption)
                    .lineLimit(1)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    @ViewBuilder
    var content: some View {
        if let campaign = campaign {
            rawContent
                .widgetURL(URL(string: campaign.widgetURL)!)
        } else {
            rawContent
        }
    }
}

struct LockScreenRectangularView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            LockScreenRectangularView(campaign: sampleCampaign, shouldShowGoalPercentage: true)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        } else {
            // Fallback on earlier versions
        }
    }
}
