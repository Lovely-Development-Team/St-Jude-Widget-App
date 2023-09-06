//
//  WidgetEntryView.swift
//  WidgetEntryView
//
//  Created by David on 25/08/2021.
//

import SwiftUI
import WidgetKit

struct WidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    
    var entry: Provider.Entry
    
    var showPreviousMilestone: Bool {
        return isExtraLargeSize(family: family) || entry.campaign?.nextMilestone == nil
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
    
    @ViewBuilder
    var entryView: some View {
        if let campaign = entry.campaign {
            EntryView(campaign: .constant(campaign), showMilestones: shouldShowMilestones, preferFutureMilestones: preferFutureMilestones, showFullCurrencySymbol: entry.configuration.showFullCurrencySymbol?.boolValue ?? false, showGoalPercentage: shouldShowGoalPercentage, showMilestonePercentage: shouldShowMilestonePercentage, appearance: entry.configuration.appearance)
                .widgetURL(URL(string: campaign.widgetURL)!)
        } else {
            if #available(iOS 17.0, *) {
                placeholderView
                    .containerBackground(LinearGradient(colors: entry.configuration.appearance.backgroundColors, startPoint: .bottom, endPoint: .top), for: .widget)
                    .padding(showsBackground ? [] : .all)
            } else {
                placeholderView
                    .padding()
                    .background(LinearGradient(colors: entry.configuration.appearance.backgroundColors, startPoint: .bottom, endPoint: .top))
            }
        }
    }
    
    @ViewBuilder
    var placeholderView: some View {
        VStack(alignment: .leading, spacing: 5) {
            CampaignTitle(name: "Choose a fundraiser")
            Spacer()
            ProgressBar(value: .constant(0), fillColor: entry.configuration.appearance.fillColor)
                .frame(height: 15)
            Text("$123,400")
                .redacted(reason: .placeholder)
        }
        .foregroundColor(entry.configuration.appearance.foregroundColor)
    }
    
    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            if family == .accessoryInline {
                if let campaign = entry.campaign {
                    Text(campaign.totalRaisedDescription(showFullCurrencySymbol: false))
                } else {
                    Text("Choose a fundraiser")
                }
            } else if family == .accessoryCircular {
                ProgressBar(value: .constant(Float(entry.campaign?.percentageReached ?? 0)), fillColor: .white, circularShape: true)
            } else {
                entryView
            }
        } else {
            entryView
        }
    }
}
