//
//  WidgetEntryView.swift
//  WidgetEntryView
//
//  Created by David on 23/08/2021.
//

import SwiftUI

struct EntryView: View {
    @Environment(\.widgetFamily) var family
    
    @Binding var campaign: TiltifyWidgetData
    let showMilestones: Bool
    let preferFutureMilestones: Bool
    let showFullCurrencySymbol: Bool
    let showGoalPercentage: Bool
    let showMilestonePercentage: Bool
    let appearance: WidgetAppearance
    var forceHidePreviousMilestone: Bool = false
    var useNormalBackgroundOniOS17: Bool = false

    
    var showTwoMilestones: Bool {
        if self.forceHidePreviousMilestone { return false }
        return (isLargeSize(family: family) || !DeviceType.isInWidget()) || campaign.nextMilestone == nil
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
    
    var backgroundColors: [Color] {
        return appearance.backgroundColors
    }
    
    var fillColor: Color {
        return appearance.fillColor
    }
    
    var foregroundColor: Color {
        return appearance.foregroundColor
    }
    
    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                if useNormalBackgroundOniOS17 {
                    content
                        .padding()
                        .background(LinearGradient(colors: backgroundColors, startPoint: .bottom, endPoint: .top))
                } else {
                    content
                        .containerBackground(LinearGradient(colors: backgroundColors, startPoint: .bottom, endPoint: .top), for: .widget)
                }
            } else {
                content
                    .padding()
                    .background(LinearGradient(colors: backgroundColors, startPoint: .bottom, endPoint: .top))
            }
        }
    }
    
    @ViewBuilder
    var content: some View {
        
        VStack(alignment: .leading, spacing: 5) {
           
            CampaignTitle(name: campaign.name, showingTwoMilestones: showMilestones)
             
            Spacer()
            
            if let percentageReached = campaign.percentageReached {
                ProgressBar(value: .constant(Float(percentageReached)), fillColor: fillColor)
                    .frame(height: 15)
            }
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    
                    Text(campaign.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                        .font(raisedAmountFont)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .accessibility(label: Text(campaign.totalRaisedAccessibilityDescription(showFullCurrencySymbol: showFullCurrencySymbol)))
                    
                    if showGoalPercentage && DeviceType.isInWidget() && (family == .systemMedium || (family == .systemLarge && showMilestones)) {
                        VStack(alignment: .leading) {
                            Text("\(campaign.percentageReachedDescription ?? "Unknown") of")
                            Text(campaign.goalDescription(showFullCurrencySymbol: showFullCurrencySymbol, trimDecimalPlaces: true))
                        }
                        .font(.caption)
                    }
                    if #available(iOS 15.0, *), showGoalPercentage, isExtraLargeSize(family: family) && DeviceType.isInWidget() {
                            Spacer()
                            Text("\(campaign.percentageReachedDescription ?? "Unknown") of \(campaign.goalDescription(showFullCurrencySymbol: showFullCurrencySymbol, trimDecimalPlaces: true))")
                    }
                }
                
                if showGoalPercentage,
                   (family == .systemLarge && !showMilestones) || !DeviceType.isInWidget() {
                    Text("\(campaign.percentageReachedDescription ?? "Unknown") of \(campaign.goalDescription(showFullCurrencySymbol: showFullCurrencySymbol, trimDecimalPlaces: true))")
                }
                
                if showGoalPercentage,
                   family == .systemSmall && DeviceType.isInWidget() {
                    Text(campaign.percentageReachedDescription ?? "Unknown")
                        .font(.caption)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text(campaign.totalRaisedAccessibilityDescription(showFullCurrencySymbol: showFullCurrencySymbol)))
            
            if showMilestones && family != .systemSmall {
                if showTwoMilestones,
                   !preferFutureMilestones || campaign.futureMilestones.count <= 1,
                   let milestone = campaign.previousMilestone {
                    MilestoneView(title: "Previous milestone", data: campaign, milestone: milestone, showFullCurrencySymbol: showFullCurrencySymbol, showMilestonePercentage: showMilestonePercentage, fillColor: fillColor)
                }
                
                if let milestone = campaign.nextMilestone {
                    MilestoneView(title: "Upcoming milestones", data: campaign, milestone: milestone, showFullCurrencySymbol: showFullCurrencySymbol, showMilestonePercentage: showMilestonePercentage, fillColor: fillColor)
                }
                
                if showTwoMilestones,
                   preferFutureMilestones && campaign.futureMilestones.count > 1,
                   1 < campaign.futureMilestones.endIndex {
                    MilestoneView(data: campaign, milestone: campaign.futureMilestones[1], showFullCurrencySymbol: showFullCurrencySymbol, showMilestonePercentage: showMilestonePercentage, fillColor: fillColor)
                }
            }
            
        }
        .foregroundColor(foregroundColor)
        .frame(maxWidth: .infinity)
    }
}

struct EntryViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            EntryView(campaign: .constant(sampleCampaignSingleMilestone), showMilestones: true, preferFutureMilestones: true, showFullCurrencySymbol: false, showGoalPercentage: true, showMilestonePercentage: true, appearance: .red)
                .frame(width: 300, height: 378)
                .cornerRadius(15)
            EntryView(campaign: .constant(sampleCampaignTwoMilestones), showMilestones: true, preferFutureMilestones: true, showFullCurrencySymbol: false, showGoalPercentage: true, showMilestonePercentage: true, appearance: .stjude)
                .frame(width: 300, height: 378)
                .cornerRadius(15)
            EntryView(campaign: .constant(sampleCampaignThreeMilestones), showMilestones: true, preferFutureMilestones: true, showFullCurrencySymbol: false, showGoalPercentage: true, showMilestonePercentage: true, appearance: .stjude)
                .frame(width: 300, height: 378)
                .cornerRadius(15)
            EntryView(campaign: .constant(sampleCampaign), showMilestones: true, preferFutureMilestones: true, showFullCurrencySymbol: false, showGoalPercentage: true, showMilestonePercentage: true, appearance: .stjude)
                .frame(width: 300, height: 378)
                .cornerRadius(15)
            EntryView(campaign: .constant(sampleCampaign), showMilestones: true, preferFutureMilestones: false, showFullCurrencySymbol: false, showGoalPercentage: true, showMilestonePercentage: true, appearance: .stjude)
                .frame(width: 300, height: 378)
                .cornerRadius(15)
        }
    }
}
