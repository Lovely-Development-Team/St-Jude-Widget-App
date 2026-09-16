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
    
    var foregroundColor: Color {
        if self.appearance.isWildWestTheme && !self.isForWidget {
            return .black
        }
        return appearance.foregroundColor
    }
    
    var colorScheme: ColorScheme? {
        if self.appearance.isWildWestTheme && !self.isForWidget {
            return .light
        }
        return nil
    }
    
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
        case .systemSmall:
            return 0.4
        case .systemMedium:
            return 0.2
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
        case .systemMedium, .systemLarge, .systemExtraLarge:
            if self.appearance.isWildWestTheme {
                return .headline
            }
            return .title
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
    func pollName(for poll: Poll) -> some View {
        Text(poll.name)
            .font(self.fontForTitle)
            .bold()
            .lineLimit(self.lineLimitForTitle)
            .minimumScaleFactor(self.minimumScaleFactor)
    }
    
    @ViewBuilder
    func titleView(for poll: Poll, parentCampaign: TiltifyWidgetData?) -> some View {
        VStack(alignment: .leading) {
            pollName(for: poll)
            if let parentCampaign, self.showParentCampaignInfo && self.widgetFamilyForLayout != .systemSmall {
                Text(parentCampaign.name)
                    .font(self.fontForCampaignName)
                    .lineLimit(2)
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
            return 3
        case .systemMedium:
            return 1
        default:
            return 2
        }
    }
    
    var fontForOptionNames: Font {
        switch self.widgetFamilyForLayout {
        case .systemSmall:
            return .caption
        case .systemMedium:
            return .caption
        default:
            return .body
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
    
    var crownImageScale: Image.Scale {
        switch self.widgetFamilyForLayout {
        case .systemSmall, .systemMedium:
            return .small
        default:
            return .medium
        }
    }
    
    func crownForSmallWidget(for option: PollOption) -> Text {
        if option.isMax(options: self.options) && self.widgetFamilyForLayout == .systemSmall {
            return Text(" \(Image(systemName: "crown.fill"))")
        }
        return Text("")
    }
    
    @ViewBuilder
    func crownAndOptionName(for option: PollOption) -> some View {
        if option.isMax(options: self.options) {
            Image(systemName: "crown.fill")
                .foregroundStyle(self.appearance.fillColor)
                .minimumScaleFactor(self.minimumScaleFactor)
                .font(fontForOptionNames)
        }
        Text(option.name)
            .minimumScaleFactor(self.minimumScaleFactor)
            .font(fontForOptionNames)
            .lineLimit(self.lineLimitForOptionNames)
    }
    
    @ViewBuilder
    func optionView(for option: PollOption, poll: Poll) -> some View {
        VStack(alignment: .leading) {
            if self.widgetFamilyForLayout == .systemSmall {
                VStack(alignment: .leading, spacing: 5) {
                    if !self.appearance.isWildWestTheme {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(self.appearance.fillColor)
                            .minimumScaleFactor(self.minimumScaleFactor)
                            .font(fontForOptionNames)
                    }
                    Text(option.name)
                        .minimumScaleFactor(self.minimumScaleFactor)
                        .font(fontForOptionNames)
                        .lineLimit(self.lineLimitForOptionNames)
                    if self.appearance.isWildWestTheme {
                        HStack {
                            Text(option.amountRaised.description(showFullCurrencySymbol: self.showFullCurrencySymbol))
                                .font(fontForOptionNames)
                                .foregroundStyle(.secondary)
                                .minimumScaleFactor(self.minimumScaleFactor)
                            Spacer()
                            Image(systemName: "crown.fill")
                                .foregroundStyle(self.appearance.fillColor)
                                .minimumScaleFactor(self.minimumScaleFactor)
                                .font(fontForOptionNames)
                        }
                    } else {
                        Text(option.amountRaised.description(showFullCurrencySymbol: self.showFullCurrencySymbol))
                            .font(fontForOptionNames)
                            .foregroundStyle(.secondary)
                            .minimumScaleFactor(self.minimumScaleFactor)
                    }
                }
            } else {
            
                HStack(alignment: .bottom) {
                    
                    ViewThatFits {
                        VStack(alignment: .leading) {
                            Text(option.name)
                                .minimumScaleFactor(self.minimumScaleFactor)
                                .font(fontForOptionNames)
                                .lineLimit(self.lineLimitForOptionNames)
                            Text(option.amountRaised.description(showFullCurrencySymbol: self.showFullCurrencySymbol))
                                .font(fontForOptionNames)
                                .foregroundStyle(.secondary)
                                .minimumScaleFactor(self.minimumScaleFactor)
                        }
                        Group {
                            Text(option.name) + Text(" ") + Text(option.amountRaised.description(showFullCurrencySymbol: self.showFullCurrencySymbol)).foregroundStyle(.secondary)
                        }
                        .font(fontForOptionNames)
                        .minimumScaleFactor(self.minimumScaleFactor)
                    }
                    if option.isMax(options: self.options) {
                        Spacer()
                        Image(systemName: "crown.fill")
                            .imageScale(self.crownImageScale)
                            .foregroundStyle(self.appearance.fillColor)
                    }
                    
                }
            }
            if self.widgetFamilyForLayout == .systemLarge && self.sortedOptions.count == 5 && option != self.sortedOptions.first {
                Spacer()
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
                        if self.numOptionsToShow == 1, let option = self.sortedOptions.first {
                            self.optionView(for: option, poll: poll)
                        } else {
                            if self.widgetFamilyForLayout == .systemLarge && self.sortedOptions.count == 5 {
                                VStack(alignment: .leading) {
                                    self.optionView(for: self.sortedOptions.first!, poll: poll)
                                }
                                LazyVGrid(columns: [.init(), .init()]) {
                                    ForEach(self.sortedOptions.dropFirst()) { option in
                                        VStack(alignment: .leading) {
                                            Spacer()
                                            self.optionView(for: option, poll: poll)
                                        }
                                    }
                                }
                            } else {
                                ForEach(self.sortedOptions.prefix(self.numOptionsToShow)) { option in
                                    VStack(alignment: .leading) {
                                        self.optionView(for: option, poll: poll)
                                    }
                                }
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
        .foregroundStyle(self.foregroundColor)
    }
    
    @ViewBuilder
    var content: some View {
        if self.appearance.isWildWestTheme && self.renderingMode == .fullColor {
            GroupBox {
                self.actualContent
            }
            .themedGroupBox(type: .primary, primaryColor: self.isForWidget ? .secondarySystemBackground : .white, id: "pollWidgetContainer")
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
