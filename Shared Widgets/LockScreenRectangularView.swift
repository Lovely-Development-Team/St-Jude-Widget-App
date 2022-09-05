//
//  LockScreenRectangularView.swift
//  St Jude
//
//  Created by Ben Cardy on 04/09/2022.
//

import SwiftUI

struct LockScreenRectangularView: View {
    
    let campaign: TiltifyWidgetData
    var shouldShowFullCurrencySymbol: Bool = false
    var shouldShowGoalPercentage: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            Spacer()
            Text(campaign.totalRaisedDescription(showFullCurrencySymbol: shouldShowFullCurrencySymbol))
                .font(.system(.headline, design: .rounded))
                .minimumScaleFactor(0.2)
                .lineLimit(1)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            ProgressBar(value: .constant(Float(campaign.percentageReached ?? 0)), fillColor: .white)
                .frame(height: 6)
            if shouldShowGoalPercentage, let percentage = campaign.shortPercentageReachedDescription {
                Text("\(percentage) of \(campaign.goalDescription(showFullCurrencySymbol: shouldShowFullCurrencySymbol))")
                    .font(.caption)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
        }
        .widgetURL(URL(string: campaign.widgetURL)!)
    }
}

struct LockScreenRectangularView_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenRectangularView(campaign: sampleCampaign)
    }
}
