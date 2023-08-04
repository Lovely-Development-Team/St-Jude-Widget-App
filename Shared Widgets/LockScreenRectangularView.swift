//
//  LockScreenRectangularView.swift
//  St Jude
//
//  Created by Ben Cardy on 04/09/2022.
//

import SwiftUI
import WidgetKit

struct LockScreenRectangularView: View {
    
    let campaign: TiltifyWidgetData
    var shouldShowFullCurrencySymbol: Bool = false
    var shouldShowGoalPercentage: Bool = false
    
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
        VStack(spacing: 4) {
            Spacer()
                .frame(minHeight: 0, maxHeight: .infinity)
            Text(campaign.totalRaisedDescription(showFullCurrencySymbol: shouldShowFullCurrencySymbol))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .scaledToFill()
                .minimumScaleFactor(0.2)
                .lineLimit(1)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            ProgressBar(value: .constant(Float(campaign.percentageReached ?? 0)), fillColor: .white)
                .frame(height: 6)
            if shouldShowGoalPercentage, let percentage = campaign.shortPercentageReachedDescription {
                Text("\(percentage) of \(campaign.goalDescription(showFullCurrencySymbol: shouldShowFullCurrencySymbol))")
                    .font(.caption)
                    .lineLimit(1)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
        }
        .widgetURL(URL(string: campaign.widgetURL)!)
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
