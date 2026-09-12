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
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    @Environment(\.widgetRenderingMode) var renderingMode
    
    var poll: Poll?
    var options: [PollOption]
    var parentCampaign: TiltifyWidgetData?
    var appearance: WidgetAppearance
    var showFullCurrencySymbol: Bool
    var showParentCampaignInfo: Bool = true
    var useNormalBackground: Bool = false
    var isForWidget: Bool = true
    
    var overrideWidgetFamily: WidgetFamily? = nil
    
    var sortedOptions: [PollOption] {
        return self.options.sorted(by: {
            return $0.amountRaised.numericalValue >= $1.amountRaised.numericalValue
        })
    }
    
    var widgetFamilyForLayout: WidgetFamily {
        return self.overrideWidgetFamily ?? self.widgetFamily
    }
    
    var minimumScaleFactor: Double {
        switch self.widgetFamilyForLayout {
        case .systemSmall, .systemMedium:
            return 0.7
        default:
            return 1.0
        }
    }
    
    // MARK: Title
    var lineLimitForTitle: Int {
        switch self.widgetFamilyForLayout {
        case .systemSmall, .systemMedium:
            return 2
        default:
            return 3
        }
    }
    
    var fontForTitle: Font {
        switch self.widgetFamilyForLayout {
        case .systemSmall, .systemMedium:
            return .caption
        default:
            return .body
        }
    }
    
    var fontForCampaignName: Font {
        switch self.widgetFamilyForLayout {
        case .systemSmall, .systemMedium:
            return .caption
        default:
            return .subheadline
        }
    }
    
    @ViewBuilder
    func titleView(for poll: Poll, parentCampaign: TiltifyWidgetData?) -> some View {
        VStack(alignment: .leading) {
            Text(poll.name)
                .font(self.fontForTitle)
                .bold()
                .lineLimit(self.lineLimitForTitle)
                .minimumScaleFactor(self.minimumScaleFactor)
            if let parentCampaign, self.showParentCampaignInfo {
                Text(parentCampaign.name)
                    .font(self.fontForCampaignName)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(self.minimumScaleFactor)
            }
        }
    }
    
    // MARK: Options
    var numOptionsToShow: Int {
        switch self.widgetFamilyForLayout {
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
        switch self.widgetFamilyForLayout {
        case .systemSmall:
            return 2
        case .systemMedium:
            return 1
        default:
            return 2
        }
    }
    
    var progressBarHeight: Double {
        switch self.widgetFamilyForLayout {
        case .systemSmall, .systemMedium, .accessoryRectangular:
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
                        if option.isMax(parentPoll: poll, options: self.options) && self.widgetFamilyForLayout == .systemSmall {
                            Image(systemName: "crown.fill")
                                .imageScale(.small)
                                .foregroundStyle(self.appearance.fillColor)
                        }
                    }
                }
                Spacer()
                if option.isMax(parentPoll: poll, options: self.options) && self.widgetFamilyForLayout != .systemSmall {
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
    var actualContent: some View {
        Group {
            if let poll = self.poll {
                VStack(alignment: .leading) {
                    self.titleView(for: poll, parentCampaign: self.parentCampaign)
                    Spacer()
                    if poll.active {
                        ForEach(self.sortedOptions.prefix(self.numOptionsToShow)) { option in
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
    
    @ViewBuilder
    var content: some View {
        if self.appearance.isWildWestTheme {
            GroupBox {
                self.actualContent
            }
            .themedGroupBox(type: .primary, id: "pollWidgetContainer")
        } else {
            self.actualContent
        }
    }
    
    var body: some View {
        switch self.widgetFamilyForLayout {
        case .accessoryInline:
            self.accessoryInlineContent
        case .accessoryRectangular:
            self.accessoryRectangularContent
        default:
            if self.useNormalBackground {
                self.content
                    .padding()
                    .background {
                        self.appearance.background(isForWidget: self.isForWidget)
                    }
            } else {
                self.content
                    .containerBackground(for: .widget) {
                        self.appearance.background(isForWidget: self.isForWidget)
                    }
                    .padding(showsBackground ? [] : .all, 5)
            }
        }
    }
    
    @ViewBuilder
    var placeholderView: some View {
        Text("Select A Poll")
            .bold()
    }
}

// MARK: - Lock Screen Widgets (only .accessoryRectangular and .accessoryInline)
extension PollWidgetEntryView {
    
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
                    ProgressBar(value: .constant(Float(highestOption.percentageOfPoll(parentPoll: poll))), fillColor: self.appearance.fillColor)
                        .frame(height: self.progressBarHeight)
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
