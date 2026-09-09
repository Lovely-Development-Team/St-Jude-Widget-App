//
//  HeadToHeadWidgetView.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/31/23.
//

import SwiftUI
import WidgetKit
import Kingfisher

let HEAD_TO_HEAD_COLOR_1: WidgetAppearance = .yellow
let HEAD_TO_HEAD_COLOR_2: WidgetAppearance = .stjude

struct HeadToHeadWidgetView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    @Environment(\.widgetRenderingMode) var renderingMode
    
    var entry: HeadToHeadProvider.Entry
    
    var campaign1: TiltifyWidgetData? {
        entry.campaign1
    }
    
    var campaign2: TiltifyWidgetData? {
        entry.campaign2
    }
    
    var showFullCurrencySymbol: Bool {
        entry.configuration.showFullCurrencySymbol?.boolValue ?? false
    }
    
    var openToHeadToHead: Bool {
        entry.configuration.openToHeadToHead?.boolValue ?? true
    }
    
    var progressBarFillColor: Color {
        return renderingMode == .vibrant ? .white : Theme.current.accentColor
    }
    
    var progressBarBackgroundColor: Color {
        return renderingMode == .vibrant ? .black : Theme.current.alternateAccentColor
    }
    
    var progressBarValue: Float {
        guard let campaign1 = campaign1, let campaign2 = campaign2 else { return 0.5 }
        let denominator = campaign1.totalRaisedNumerical + campaign2.totalRaisedNumerical
        guard denominator > 0 else { return 0.5 }
        return Float(campaign1.totalRaisedNumerical / denominator)
    }
    
    var highestTotal: Double {
        guard let campaign1 = campaign1, let campaign2 = campaign2 else { return 0 }
        return max(campaign1.totalRaisedNumerical, campaign2.totalRaisedNumerical)
    }
    
    var winner: TiltifyWidgetData? {
        guard let campaign1 = campaign1, let campaign2 = campaign2 else { return nil }
        if(campaign1.totalRaisedNumerical == highestTotal) {
            return campaign1
        }
        
        return campaign2
    }
    
    var nonWinner: TiltifyWidgetData? {
        guard let campaign1 = campaign1, let campaign2 = campaign2 else { return nil }
        if(campaign1.totalRaisedNumerical == highestTotal) {
            return campaign2
        }
        
        return campaign1
    }
    
    func labelColor(isWinner: Bool = false) -> Color {
        if (family == .systemSmall) {
            return isWinner ? Theme.current.contentColorForAccent : .black
        }
        return isWinner ? Theme.current.contentColorForAccent : .label
    }
    
    
    
    @ViewBuilder
    var backgroundView: some View {
        if(family == .systemSmall) {
            Image(.woodbackground2026Small)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if(family == .systemLarge) {
            backgroundRectView(isHorizontal: false, isSkewed: false)
        } else if(family == .systemMedium || family == .systemSmall) {
            backgroundRectView(isHorizontal: true, isSkewed: true)
        } else if (family == .systemExtraLarge) {
            Image(.sky2026)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
    
    @ViewBuilder
    func backgroundRectView(isHorizontal: Bool, isSkewed: Bool) -> some View {
        if(isHorizontal) {
            Image(.woodbackground2026Small)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            ZStack {
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Image(.sky2026Small)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.frame(in: .local).size.width, height: geo.frame(in: .local).size.height / 2)
                        Image(.woodBackground2026)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                Rectangle()
                    .fill(.black)
                    .frame(maxHeight: 2)
            }
        }
    }
    
    func avatarImage(for campaign: TiltifyWidgetData) -> UIImage? {
        guard let data = campaign.avatarImageData else { return nil }
        return UIImage(data: data)
    }
    
    @ViewBuilder
    func avatarImageView(for campaign: TiltifyWidgetData) -> some View {
        if let image = avatarImage(for: campaign) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .imageScale(.large)
                .clipShape(ContainerRelativeShape())
                .foregroundStyle(labelColor(isWinner: false))
        }
    }
    
    var shouldHaveExtraPadding: Bool {
        return !showsBackground && !isLockScreen(family: family)
    }
    
    var h2hWidgetUrl: URL? {
        guard let urlString = entry.widgetUrlString, let url = URL(string: urlString),  openToHeadToHead else { return nil }
        return url
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            content(for: family)
                .containerBackground(for: .widget, content: {
                    backgroundView
                })
                .padding(shouldHaveExtraPadding ? .all : [], 5)
                .widgetURL(h2hWidgetUrl)
                .containerShape(.rect)
                .dynamicTypeSize(.medium)
        } else {
            content(for: family, padded: true)
                .background {
                    backgroundView
                }
                .widgetURL(h2hWidgetUrl)
                .dynamicTypeSize(.medium)
        }
    }
    
    @ViewBuilder
    func content(for family: WidgetFamily, padded: Bool = false) -> some View {
        Group {
            switch family {
            case .systemSmall:
                smallSizeContent
                    .padding(padded ? .all : [], 0)
            case .systemMedium:
                mediumSizeContent
                    .padding(padded ? .all : [])
            case .systemLarge:
                largeSizeContent
                    .padding(padded ? .all : [])
            case .systemExtraLarge:
                extraLargeContent
                    .padding(padded ? .all : [])
            case .accessoryCircular:
                circularLockScreenContent
            case .accessoryRectangular:
                rectangularLockScreenContent
            case .accessoryInline:
                inlineLockScreenContent
            default:
                content
            }
        }
        .preferredColorScheme(.light)
    }
    
    @ViewBuilder
    var content: some View {
        VStack {
            if let campaign1 = entry.campaign1, let image = avatarImage(for: campaign1) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            Text(entry.campaign1?.name ?? "Unknown")
            Text("VS")
            if let campaign2 = entry.campaign2, let image = avatarImage(for: campaign2) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            Text(entry.campaign2?.name ?? "Unknown")
        }
    }
}

// MARK: Small Widget
extension HeadToHeadWidgetView {
    @ViewBuilder
    var smallSizeContent: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    avatarImageView(for: winner ?? sampleCampaign)
                    Spacer()
                    avatarImageView(for: nonWinner ?? sampleCampaign)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .opacity(0.5)
                        .scaleEffect(0.75)
                }
                Spacer()
                if let username = winner?.username {
                    Text(username)
                        .foregroundStyle(labelColor(isWinner: false))
                        .font(.headline)
                        .lineLimit(1)
                } else {
                    Text("Username")
                        .foregroundStyle(labelColor(isWinner: false))
                        .font(.headline)
                        .lineLimit(1)
                        .redacted(reason: .placeholder)
                }
                if let winner = winner {
                    Text(winner.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                        .foregroundStyle(labelColor(isWinner: false))
                        .font(.caption)
                } else {
                    Text("$123,456.00")
                        .foregroundStyle(labelColor(isWinner: false))
                        .font(.caption)
                        .redacted(reason: .placeholder)
                }
                ProgressBar(value: .constant(progressBarValue), barColour: progressBarBackgroundColor, fillColor: progressBarFillColor, showDivider: true, dividerColor: labelColor(isWinner: false), dividerWidth: 2, stroke: true)
                    .frame(height: 10)
            }
            .frame(maxWidth: .infinity)
        }
        .themedGroupBox(type: .primary)
    }
}

// MARK: Medium Widget
extension HeadToHeadWidgetView {
    @ViewBuilder
    var mediumSizeContent: some View {
        VStack {
            HStack(spacing: 10) {
                GroupBox {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            avatarImageView(for: campaign1 ?? sampleCampaign)
                            Spacer()
//                            if(campaign1?.id == winner?.id) {
//                                Group {
//                                    if let token = Theme.current.headToHeadWinnerToken1 {
//                                        Image(token)
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                    } else {
//                                        Image(systemName: "crown.fill")
//                                            .font(.system(size: 30))
//                                            .imageScale(.large)
//                                            .foregroundStyle(Theme.current.accentColor)
//                                            .background(Circle().fill(.white).blur(radius: 30))
//                                    }
//                                }
//                                .frame(height: 40)
//                            }
                        }
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                if let campaign1 = campaign1 {
                                    Text(campaign1.username ?? "Unknown")
                                        .foregroundStyle(labelColor(isWinner: campaign1.id == winner?.id))
                                        .font(.headline)
                                        .lineLimit(1)
                                    Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                        .foregroundStyle(labelColor(isWinner: campaign1.id == winner?.id))
                                        .font(.caption)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text("Username")
                                        .foregroundStyle(labelColor(isWinner: false))
                                        .font(.headline)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                        .redacted(reason: .placeholder)
                                    Text("$123,456.00")
                                        .foregroundStyle(labelColor(isWinner: false))
                                        .font(.caption)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .redacted(reason: .placeholder)
                                }
                            }
                        }
                    }
                }
                .themedGroupBox(type: .primary, primaryColor: campaign1?.id == winner?.id ? Theme.current.accentColor : nil, id: "h2h-widget-left")
                .frame(maxWidth: .infinity)
                GroupBox {
                    VStack(alignment: .trailing) {
                        HStack(alignment: .top) {
//                            if(campaign2?.id == winner?.id) {
//                                Group {
//                                    if let token = Theme.current.headToHeadWinnerToken2 {
//                                        Image(token)
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                    } else if let token = Theme.current.headToHeadWinnerToken1 {
//                                        Image(token)
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                    } else {
//                                        Image(systemName: "crown.fill")
//                                            .font(.system(size: 30))
//                                            .imageScale(.large)
//                                            .foregroundStyle(Theme.current.accentColor)
//                                            .background(Circle().fill(.white).blur(radius: 30))
//                                    }
//                                }
//                                .frame(height: 40)
//                            }
                            Spacer()
                            avatarImageView(for: campaign2 ?? sampleCampaign)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 0) {
                            if let campaign2 = campaign2 {
                                Text(campaign2.username ?? "Unknown")
                                    .foregroundStyle(labelColor(isWinner: campaign2.id == winner?.id))
                                    .font(.headline)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                                    .multilineTextAlignment(.trailing)
                                    .lineLimit(1)
                                Text(campaign2.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                    .foregroundStyle(labelColor(isWinner: campaign2.id == winner?.id))
                                    .font(.caption)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                            } else {
                                Text("Username")
                                    .foregroundStyle(labelColor(isWinner: false))
                                    .font(.headline)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                                    .multilineTextAlignment(.trailing)
                                    .lineLimit(1)
                                    .redacted(reason: .placeholder)
                                Text("$123,456.00")
                                    .foregroundStyle(labelColor(isWinner: false))
                                    .font(.caption)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                                    .redacted(reason: .placeholder)
                            }
                        }
                    }
                }
                .themedGroupBox(type: .primary, primaryColor: campaign2?.id == winner?.id ? Theme.current.accentColor : nil,  id: "h2h-widget-right")
                .frame(maxWidth: .infinity)
            }
            .overlay {
            Text("vs")
                .bold()
                .padding(8)
                .foregroundColor(.invertedPrimary)
                .background {
                    Circle()
                        .foregroundStyle(Color.primary)
                }
                .shadow(radius: 10)
            }
        }
    }
}

// MARK: Large Widget
extension HeadToHeadWidgetView {
    @ViewBuilder
    var largeSizeContent: some View {
        ZStack {
            VStack {
                GroupBox {
                    VStack(alignment: .leading) {
                        HStack (alignment: .top) {
                            avatarImageView(for: campaign1 ?? sampleCampaign)
                            VStack(alignment: .leading) {
                                if let campaign1 = campaign1 {
                                    Text(campaign1.username ?? "Unknown")
                                        .foregroundStyle(labelColor(isWinner: campaign1.id == winner?.id))
                                        .font(.title2)
                                        .bold()
                                    Text(campaign1.name)
                                        .foregroundStyle(labelColor(isWinner: campaign1.id == winner?.id))
                                        .font(.body)
                                } else {
                                    Text("Username")
                                        .foregroundStyle(labelColor(isWinner: false))
                                        .font(.title2)
                                        .bold()
                                        .redacted(reason: .placeholder)
                                    Text("Some Campaign for St. Jude")
                                        .foregroundStyle(labelColor(isWinner: false))
                                        .font(.body)
                                        .redacted(reason: .placeholder)
                                }
                            }
                            Spacer()
                        }
                        HStack(alignment: .lastTextBaseline) {
                            if let campaign1 = campaign1 {
                                Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                    .foregroundStyle(labelColor(isWinner: campaign1.id == winner?.id))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                            } else {
                                Text("$123,456.00")
                                    .foregroundStyle(labelColor(isWinner: false))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .redacted(reason: .placeholder)
                            }
                        }
                    }
                }
                .themedGroupBox(type: .primary,
                                primaryColor: campaign1?.id == winner?.id ? Theme.current.accentColor : nil,
                                id: "h2hLargeWidgetCampaign1")
                .padding(.bottom)
                GroupBox {
                    VStack(alignment: .trailing) {
                        HStack(alignment: .lastTextBaseline) {
                            if let campaign2 = campaign2 {
                                Text(campaign2.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                    .foregroundStyle(labelColor(isWinner: campaign2.id == winner?.id))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                            } else {
                                Text("$123,456.00")
                                    .foregroundStyle(labelColor(isWinner: false))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .redacted(reason: .placeholder)
                            }
                        }
                        HStack (alignment: .bottom) {
                            Spacer()
                            VStack(alignment: .trailing) {
                                if let campaign2 = campaign2 {
                                    Text(campaign2.username ?? "Unknown")
                                        .foregroundStyle(labelColor(isWinner: campaign2.id == winner?.id))
                                        .font(.title2)
                                        .bold()
                                        .multilineTextAlignment(.trailing)
                                    Text(campaign2.name)
                                        .foregroundStyle(labelColor(isWinner: campaign2.id == winner?.id))
                                        .font(.body)
                                        .multilineTextAlignment(.trailing)
                                } else {
                                    Text("Username")
                                        .foregroundStyle(labelColor(isWinner: false))
                                        .font(.title2)
                                        .bold()
                                        .multilineTextAlignment(.trailing)
                                        .redacted(reason: .placeholder)
                                    Text("Some Campaign for St. Jude")
                                        .foregroundStyle(labelColor(isWinner: false))
                                        .font(.body)
                                        .multilineTextAlignment(.trailing)
                                        .redacted(reason: .placeholder)
                                }
                            }
                            avatarImageView(for: campaign2 ?? sampleCampaign)
                        }
                    }
                }
                .themedGroupBox(type: .primary,
                                primaryColor: campaign2?.id == winner?.id ? Theme.current.accentColor : nil,
                                id: "h2hLargeWidgetCampaign2")
                .padding(.top)
            }
            ProgressBar(value: .constant(progressBarValue), barColour: progressBarBackgroundColor, fillColor: progressBarFillColor, showDivider: true, dividerColor: .black, dividerWidth: 2, stroke: true)
                .frame(height: 15)
        }
    }
}

// MARK: XL Widget
extension HeadToHeadWidgetView {
    @ViewBuilder
    var extraLargeContent: some View {
        VStack {
            HStack {
                GroupBox {
                    HStack {
                        VStack(alignment: .leading) {
                            avatarImageView(for: campaign1 ?? sampleCampaign)
                            //                            .frame(maxHeight: 100)
                            VStack(alignment: .leading) {
                                if let campaign1 = campaign1 {
                                    Text(campaign1.username ?? "Unknown")
                                        .foregroundStyle(labelColor(isWinner: campaign1.id == winner?.id))
                                        .font(.title2)
                                        .bold()
                                    Text(campaign1.name)
                                        .foregroundStyle(labelColor(isWinner: campaign1.id == winner?.id))
                                        .font(.body)
                                    Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                        .foregroundStyle(labelColor(isWinner: campaign1.id == winner?.id))
                                        .font(.title)
                                        .fontWeight(.bold)
                                } else {
                                    Text("Username")
                                        .foregroundStyle(labelColor(isWinner: false))
                                        .font(.title2)
                                        .bold()
                                        .redacted(reason: .placeholder)
                                    Text("Some Campaign for St. Jude")
                                        .foregroundStyle(labelColor(isWinner: false))
                                        .font(.body)
                                        .redacted(reason: .placeholder)
                                    Text("$123,456.00")
                                        .foregroundStyle(labelColor(isWinner: false))
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .redacted(reason: .placeholder)
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .themedGroupBox(type: .primary, primaryColor: campaign1?.id == winner?.id ? Theme.current.accentColor : nil, id: "h2hXLWidgetCampaignBoxLeft")
                GroupBox {
                    HStack {
                        VStack(alignment: .trailing) {
                            avatarImageView(for: campaign2 ?? sampleCampaign)
                            //                            .frame(maxHeight: 100)
                            if let campaign2 = campaign2 {
                                Text(campaign2.username ?? "Unknown")
                                    .foregroundStyle(labelColor(isWinner: campaign2.id == winner?.id))
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.trailing)
                                Text(campaign2.name)
                                    .foregroundStyle(labelColor(isWinner: campaign2.id == winner?.id))
                                    .font(.body)
                                    .multilineTextAlignment(.trailing)
                                Text(campaign2.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                    .foregroundStyle(labelColor(isWinner: campaign2.id == winner?.id))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                            } else {
                                Text("Username")
                                    .foregroundStyle(labelColor(isWinner: false))
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.trailing)
                                    .redacted(reason: .placeholder)
                                Text("Some Campaign for St. Jude")
                                    .foregroundStyle(labelColor(isWinner: false))
                                    .font(.body)
                                    .multilineTextAlignment(.trailing)
                                    .redacted(reason: .placeholder)
                                Text("$123,456.00")
                                    .foregroundStyle(labelColor(isWinner: false))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .redacted(reason: .placeholder)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        Spacer()
                    }
                }
            }
            .themedGroupBox(type: .primary, primaryColor: campaign2?.id == winner?.id ? Theme.current.accentColor : nil, id: "h2hXLWidgetCampaignBoxRight")
            ProgressBar(value: .constant(progressBarValue), barColour: progressBarBackgroundColor, fillColor: progressBarFillColor, showDivider: true, dividerColor: labelColor(isWinner: false), dividerWidth: 2)
                .frame(height: 30)
                .overlay {
                    Capsule().stroke(labelColor(isWinner: false), style: StrokeStyle(lineWidth: 2))
                }
        }
    }
}

// MARK: Lock Screen Widgets
extension HeadToHeadWidgetView {
    @ViewBuilder
    var circularLockScreenContent: some View {
        ZStack {
            Gauge(value: progressBarValue, in: 0...1, label: {
                Image(.coin2024)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(y: 5)
            }) {
                avatarImageView(for: winner ?? sampleCampaign)
                    .clipShape(Circle())
                    .padding(6)
            }
            .gaugeStyle(.accessoryCircular)
        }
    }
    
    @ViewBuilder
    var rectangularLockScreenContent: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(.crownPixel)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                Text(winner?.username ?? "Unknown")
                    .font(.body)
            }
            Text(winner?.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol) ?? "$0")
                .font(.footnote)
            ProgressBar(value: .constant(Float(progressBarValue)), fillColor: .white, pixelScale: Theme.current.imageScale/2)
                .frame(height: 6)
        }
    }
    
    var inlineTextString: String {
        return "\(winner?.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol) ?? "$0") • \(winner?.username ?? "Unknown")"
    }
    
    @ViewBuilder
    var inlineLockScreenContent: some View {
        HStack {
            Image(systemName: "crown.fill")
            Text(inlineTextString)
        }
    }
}

#Preview(as: .systemSmall, widget: {
    HeadToHeadWidget()
}, timeline: {
    HeadToHeadEntry(date: .now, configuration: .init(), headToHeadId: nil, campaign1: sampleCampaign, campaign2: sampleCampaign2)
})

#Preview(as: .systemMedium, widget: {
    HeadToHeadWidget()
}, timeline: {
    HeadToHeadEntry(date: .now, configuration: .init(), headToHeadId: nil, campaign1: sampleCampaign, campaign2: sampleCampaign2)
})

#Preview(as: .systemLarge, widget: {
    HeadToHeadWidget()
}, timeline: {
    HeadToHeadEntry(date: .now, configuration: .init(), headToHeadId: nil, campaign1: sampleCampaign, campaign2: sampleCampaign2)
})

#Preview(as: .systemExtraLarge, widget: {
    HeadToHeadWidget()
}, timeline: {
    HeadToHeadEntry(date: .now, configuration: .init(), headToHeadId: nil, campaign1: sampleCampaign, campaign2: sampleCampaign2)
})

#Preview(as: .accessoryInline, widget: {
    HeadToHeadWidget()
}, timeline: {
    HeadToHeadEntry(date: .now, configuration: .init(), headToHeadId: nil, campaign1: sampleCampaign, campaign2: sampleCampaign2)
})

#Preview(as: .accessoryCircular, widget: {
    HeadToHeadWidget()
}, timeline: {
    HeadToHeadEntry(date: .now, configuration: .init(), headToHeadId: nil, campaign1: sampleCampaign, campaign2: sampleCampaign2)
})

#Preview(as: .accessoryRectangular, widget: {
    HeadToHeadWidget()
}, timeline: {
    HeadToHeadEntry(date: .now, configuration: .init(), headToHeadId: nil, campaign1: sampleCampaign, campaign2: sampleCampaign2)
})
