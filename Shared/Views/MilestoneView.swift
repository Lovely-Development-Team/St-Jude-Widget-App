//
//  MilestoneView.swift
//  MilestoneView
//
//  Created by David on 23/08/2021.
//

import SwiftUI
import WidgetKit

struct LargeMilestoneTitle: View {
    let title: String?
    let name: String
    let disablePixelFont: Bool
    var body: some View {
        if let title = title {
            Text(title)
                .font(.caption(disablePixelFont: disablePixelFont))
                .opacity(0.8)
        }
        Text(name)
            .fontWeight(.bold)
            .minimumScaleFactor(0.4)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct MilestoneView: View {
    @Environment(\.widgetFamily) private var family
    
    let title: String?
    let data: TiltifyWidgetData
    let milestone: Milestone
    let showFullCurrencySymbol: Bool
    let percentageReached: Double?
    let showMilestonePercentage: Bool
    let fillColor: Color
    let disablePixelFont: Bool
    let progressBarHeight: CGFloat
    
    init(title: String? = nil, data: TiltifyWidgetData, milestone: Milestone, showFullCurrencySymbol: Bool, showMilestonePercentage: Bool, fillColor: Color, disablePixelFont: Bool, progressBarHeight: CGFloat = 10) {
        self.title = title
        self.data = data
        self.milestone = milestone
		self.showFullCurrencySymbol = showFullCurrencySymbol
        self.percentageReached = data.percentage(ofMilestone: milestone)
        self.showMilestonePercentage = showMilestonePercentage
        self.fillColor = fillColor
        self.disablePixelFont = disablePixelFont
        self.progressBarHeight = 10
    }
    
    var accessibilityLabel: String {
        "\(title ?? "Milestone"): \(milestone.name). \(data.percentageDescription(for: milestone)) of \(formatCurrency(amount: milestone.amount, showFullCurrencySymbol: showFullCurrencySymbol)) raised."
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if isLargeSize(family: family) || !DeviceType.isInWidget(){
                Spacer().fixedSize()
                LargeMilestoneTitle(title: title, name: milestone.name, disablePixelFont: disablePixelFont)
                    .accessibility(hidden: true)
            }
            
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading) {
                    if isLargeSize(family: family) || !DeviceType.isInWidget() {
                        Text(formatCurrency(amount: milestone.amount, showFullCurrencySymbol: showFullCurrencySymbol))
                    } else {
                        Text(milestone.name)
                            .fontWeight(.bold)
                    }
                }
                Spacer()
                if showMilestonePercentage,
                   let percentageToMilestone = percentageReached,
                   percentageToMilestone <= 1 {
                    Text(data.percentageDescription(for: milestone))
                }
            }
            .accessibility(hidden: true)
            
            if showMilestonePercentage,
               isLargeSize(family: family) || !DeviceType.isInWidget(),
               let percentageToMilestone = percentageReached,
               percentageToMilestone <= 1 {
                ProgressBar(value: .constant(Float(percentageToMilestone)), fillColor: fillColor)
                    .frame(height: progressBarHeight)
                    .accessibility(hidden: true)
                    .padding(.top, -5)
            }
        }
        .accessibilityElement()
        .accessibility(label: Text(accessibilityLabel))
        .environment(\.font, Font.body(disablePixelFont: disablePixelFont))
    }
}

//struct MilestoneView_Previews: PreviewProvider {
//    static var previews: some View {
//        MilestoneView()
//    }
//}
