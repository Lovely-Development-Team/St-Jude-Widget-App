//
//  PollWidgetEntryView.swift
//  Intents Extension
//
//  Created by Justin Hamilton on 9/12/26.
//

import SwiftUI
import WidgetKit

struct PollWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var poll: Poll?
    var options: [PollOption]
    var parentCampaign: TiltifyWidgetData?
    var appearance: WidgetAppearance
    var showFullCurrencySymbol: Bool
    
    var minimumScaleFactor: Double {
        return self.widgetFamily == .systemSmall ? 0.7 : 1.0
    }
    
    // MARK: Title
    var lineLimitForTitle: Int {
        switch self.widgetFamily {
        case .systemSmall, .systemMedium:
            return 2
        default:
            return 3
        }
    }
    
    var fontForTitle: Font {
        switch self.widgetFamily {
        case .systemSmall, .systemMedium:
            return .caption
        default:
            return .body
        }
    }
    
    var fontForCampaignName: Font {
        switch self.widgetFamily {
        case .systemSmall, .systemMedium:
            return .caption
        default:
            return .subheadline
        }
    }
    
    @ViewBuilder
    func titleView(for poll: Poll, parentCampaign: TiltifyWidgetData) -> some View {
        VStack(alignment: .leading) {
            Text(poll.name)
                .font(self.fontForTitle)
                .bold()
                .lineLimit(self.lineLimitForTitle)
                .minimumScaleFactor(self.minimumScaleFactor)
            Text(parentCampaign.name)
                .font(self.fontForCampaignName)
                .lineLimit(1)
                .foregroundStyle(.secondary)
                .minimumScaleFactor(self.minimumScaleFactor)
        }
    }
    
    // MARK: Options
    var numOptionsToShow: Int {
        switch self.widgetFamily {
        case .systemSmall:
            return 1
        case .systemMedium:
            return 2
        case .systemLarge:
            return 4
        default:
            // Show all
            return self.options.count
        }
    }
    
    var lineLimitForOptionNames: Int {
        switch self.widgetFamily {
        case .systemSmall:
            return 2
        case .systemMedium:
            return 1
        default:
            return 2
        }
    }
    
    var progressBarHeight: Double {
        switch self.widgetFamily {
        case .systemSmall, .systemMedium:
            return 5
        default:
            return 10
        }
    }
    
    @ViewBuilder
    func optionView(for option: PollOption, poll: Poll) -> some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(option.name)
                        .minimumScaleFactor(self.minimumScaleFactor)
                        .font(.caption)
                        .lineLimit(self.lineLimitForOptionNames)
                    HStack {
                        Text(option.amountRaised.description(showFullCurrencySymbol: self.showFullCurrencySymbol))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .minimumScaleFactor(self.minimumScaleFactor)
                        if option.isMax(parentPoll: poll, options: self.options) && self.widgetFamily == .systemSmall {
                            Image(systemName: "crown.fill")
                                .imageScale(.small)
                                .foregroundStyle(self.appearance.fillColor)
                        }
                    }
                }
                Spacer()
                if option.isMax(parentPoll: poll, options: self.options) && self.widgetFamily != .systemSmall {
                    Image(systemName: "crown.fill")
                        .imageScale(.small)
                        .foregroundStyle(self.appearance.fillColor)
                }
            }
            ProgressBar(value: .constant(Float(option.percentageOfPoll(parentPoll: poll))), fillColor: self.appearance.fillColor)
                .frame(height: self.progressBarHeight)
        }
    }
    
    @ViewBuilder
    var content: some View {
        Group {
            if let poll = self.poll,
               let parentCampaign = self.parentCampaign {
                    VStack(alignment: .leading) {
                        self.titleView(for: poll, parentCampaign: parentCampaign)
                        Spacer()
                        if poll.active {
                            ForEach(self.options.prefix(self.numOptionsToShow)) { option in
                                VStack(alignment: .leading) {
                                    self.optionView(for: option, poll: poll)
                                }
                            }
                        } else {
                            Text("This poll has ended.")
                        }
                    }
            } else {
                self.placeholderView
            }
        }
        .foregroundStyle(self.appearance.foregroundColor)
    }
    
    var body: some View {
        if self.appearance.isWildWestTheme {
            GroupBox {
                self.content
            }
            .themedGroupBox(type: .primary, id: "pollWidgetContainer")
            .containerBackground(for: .widget, content: {
                self.appearance.background(isForWidget: true)
            })
        } else {
            self.content
                .containerBackground(for: .widget, content: {
                    self.appearance.background(isForWidget: true)
                })
        }
    }
    
    @ViewBuilder
    var placeholderView: some View {
        Text("Select A Poll")
    }
}

#Preview(as: .systemSmall, widget: {
    PollWidget()
}, timeline: {
    PollWidgetEntry(date: Date(), configuration: .init(), poll: Poll.samplePoll, options: PollOption.samplePollOptions(count: 2, poll: Poll.samplePoll), parentCampaign: sampleCampaign)
})

#Preview(as: .systemMedium, widget: {
    PollWidget()
}, timeline: {
    PollWidgetEntry(date: Date(), configuration: .init(), poll: Poll.samplePoll, options: PollOption.samplePollOptions(count: 2, poll: Poll.samplePoll), parentCampaign: sampleCampaign)
})

#Preview(as: .systemLarge, widget: {
    PollWidget()
}, timeline: {
    PollWidgetEntry(date: Date(), configuration: .init(), poll: Poll.samplePoll, options: PollOption.samplePollOptions(count: 3, poll: Poll.samplePoll), parentCampaign: sampleCampaign)
})

#Preview(as: .systemExtraLarge, widget: {
    PollWidget()
}, timeline: {
    PollWidgetEntry(date: Date(), configuration: .init(), poll: Poll.samplePoll, options: PollOption.samplePollOptions(count: 3, poll: Poll.samplePoll), parentCampaign: sampleCampaign)
})

