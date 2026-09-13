//
//  PollWidgetEntryView.swift
//  Intents Extension
//
//  Created by Justin Hamilton on 9/12/26.
//

import SwiftUI
import WidgetKit

struct PollLockScreenWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    @Environment(\.widgetRenderingMode) var renderingMode
    
    var poll: Poll?
    var options: [PollOption]
    var parentCampaign: TiltifyWidgetData?
    var showFullCurrencySymbol: Bool
    var showParentCampaignInfo: Bool = true
    var useNormalBackground: Bool = false
    var isForWidget: Bool = true
    
    var sortedOptions: [PollOption] {
        return self.options.sorted(by: {
            return $0.amountRaised.numericalValue >= $1.amountRaised.numericalValue
        })
    }
    
    var body: some View {
        switch self.widgetFamily {
        case .accessoryInline:
            self.accessoryInlineContent
        default:
            self.accessoryRectangularContent
        }
    }
    
    @ViewBuilder
    var placeholderView: some View {
        Text("Select A Poll")
            .bold()
    }
}

// MARK: - Lock Screen Widgets (only .accessoryRectangular and .accessoryInline)
extension PollLockScreenWidgetEntryView {
    
    // Only show crown, percent, and as much visible title as possible
    @ViewBuilder
    var accessoryInlineContent: some View {
        if let poll = self.poll {
            if let highestOption = self.sortedOptions.first {
                Text("\(Image(systemName: "crown.fill")) \(highestOption.percentageOfPoll(parentPoll: poll).formattedAsPercent) • \(highestOption.name)")
            } else {
                Text("\(Image(systemName: "crown.fill")) \(poll.name)")
            }
        } else {
            Text("Select a poll")
        }
    }
    
    @ViewBuilder
    var accessoryRectangularContent: some View {
        if let poll = self.poll {
            if let highestOption = self.sortedOptions.first {
                VStack(alignment: .leading) {
                    HStack {
                        Text(highestOption.name)
                            .font(.caption)
                            .bold()
                            .minimumScaleFactor(0.7)
                        Spacer()
                        Image(systemName: "crown.fill")
                            .imageScale(.small)
                    }
                    Text(highestOption.amountRaised.description(showFullCurrencySymbol: self.showFullCurrencySymbol))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ProgressBar(value: .constant(Float(highestOption.percentageOfPoll(parentPoll: poll))), fillColor: .black)
                        .frame(height: 5)
                }
            } else {
                Text(poll.name)
                    .font(.caption)
                    .bold()
            }
        } else {
            Text("Select a poll")
                .font(.caption)
                .bold()
        }
    }
}
