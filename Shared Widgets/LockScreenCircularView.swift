//
//  LockScreenCircularView.swift
//  St Jude
//
//  Created by Ben Cardy on 04/09/2022.
//

import SwiftUI
import WidgetKit

struct LockScreenCircularView: View {
    
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
        ZStack {
            if #available(iOSApplicationExtension 16.0, *) {
                Gauge(value: campaign.percentageReached ?? 0, in: 0...1) {
                }
                .gaugeStyle(.accessoryCircularCapacity)
                if campaign.percentageReached ?? 0 >= 1 {
                    Image(systemName: "party.popper.fill")
                } else {
                    Group {
                        if shouldShowGoalPercentage {
                            Text((campaign.shortPercentageReachedDescription ?? "0"))
                        } else {
                            if shouldShowFullCurrencySymbol {
                                VStack(spacing: 0) {
                                    Text("USD")
                                        .font(.system(.footnote, design: .rounded))
                                        .fontWeight(.bold)
                                    Text(campaign.raisedShortRepresentation(showFullCurrencySymbol: true))
                                }
                                .padding(.top, -6)
                            } else {
                                Text("\(campaign.raisedShortRepresentation(showFullCurrencySymbol: false))")
                            }
                        }
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                }
            }
        }
        .widgetURL(URL(string: campaign.widgetURL)!)
    }
}

struct LockScreenCircularView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            LockScreenCircularView(campaign: sampleCampaign, shouldShowFullCurrencySymbol: false)
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        } else {
            // Fallback on earlier versions
        }
    }
}
