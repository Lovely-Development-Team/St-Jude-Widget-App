//
//  FundraisingLockScreenWidgetView.swift
//  St Jude
//
//  Created by Ben Cardy on 04/09/2022.
//

import SwiftUI
import WidgetKit

struct FundraisingLockScreenWidgetView : View {
    @Environment(\.widgetFamily) var family
    
    var entry: FundraisingLockScreenProvider.Entry
    
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
    
    var shouldShouldFullCurrencySymbol: Bool {
        entry.configuration.showFullCurrencySymbol?.boolValue == false
    }
    
    var entryView: some View {
        EntryView(campaign: .constant(entry.campaign), showMilestones: false, preferFutureMilestones: false, showFullCurrencySymbol: shouldShouldFullCurrencySymbol, showGoalPercentage: false, showMilestonePercentage: false, appearance: .relay)
            .widgetURL(URL(string: entry.campaign.widgetURL)!)
    }
    
    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            if family == .accessoryInline || family == .accessoryRectangular {
                Text(entry.campaign.totalRaisedDescription(showFullCurrencySymbol: shouldShouldFullCurrencySymbol))
            } else if family == .accessoryCircular {
                ZStack {
                    ProgressBar(value: .constant(Float(entry.campaign.percentageReached ?? 0)), fillColor: .white, circularShape: true, circleStrokeWidth: 6)
                    Text(entry.campaign.shortPercentageReachedDescription ?? "0%")
                        .font(.system(.headline, design: .rounded))
                    VStack {
                        Spacer()
                        Image("l2culogosvg")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.secondary)
                            .frame(height: 15)
                            .accessibility(hidden: true)
                    }
                }
            } else {
                entryView
            }
        } else {
            entryView
        }
    }
}
