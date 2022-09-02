//
//  FundraisingWidgetEntryView.swift
//  St Jude
//
//  Created by David Stephens on 30/08/2022.
//

import SwiftUI
import WidgetKit

struct FundraisingWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    
    var entry: FundraisingProvider.Entry
    
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
    
    var shouldShowMilestones: Bool {
        entry.configuration.showMilestones?.boolValue == true
    }
    
    var preferFutureMilestones: Bool {
        entry.configuration.preferFutureMilestones?.boolValue == true
    }
    
    var shouldShouldFullCurrencySymbol: Bool {
        entry.configuration.showFullCurrencySymbol?.boolValue == false
    }
    
    var shouldShowGoalPercentage: Bool {
        entry.configuration.showGoalPercentage?.boolValue == true
    }
    
    var shouldShowMilestonePercentage: Bool {
        entry.configuration.showMilestonePercentage?.boolValue == true
    }
    
    var entryView: some View {
        EntryView(campaign: .constant(entry.campaign), showMilestones: shouldShowMilestones, preferFutureMilestones: preferFutureMilestones, showFullCurrencySymbol: entry.configuration.showFullCurrencySymbol?.boolValue ?? false, showGoalPercentage: shouldShowGoalPercentage, showMilestonePercentage: shouldShowMilestonePercentage, appearance: entry.configuration.appearance)
            .widgetURL(URL(string: entry.campaign.widgetURL)!)
    }
    
    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            if family == .accessoryInline || family == .accessoryRectangular {
                Text(entry.campaign.totalRaisedDescription(showFullCurrencySymbol: false))
            } else if family == .accessoryCircular {
                ZStack {
                    ProgressBar(value: .constant(Float(entry.campaign.percentageReached ?? 0)), fillColor: .white, circularShape: true, circleStrokeWidth: 6)
                    Text(entry.campaign.shortPercentageReachedDescription ?? "0%")
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
