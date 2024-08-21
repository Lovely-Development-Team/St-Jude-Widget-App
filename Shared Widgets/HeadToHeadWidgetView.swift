//
//  HeadToHeadWidgetView.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/31/23.
//

import SwiftUI
import WidgetKit
import Kingfisher

let HEAD_TO_HEAD_COLOR_1 = WidgetAppearance.blue
let HEAD_TO_HEAD_COLOR_2 = WidgetAppearance.green

struct HeadToHeadWidgetView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    @Environment(\.widgetRenderingMode) var renderingMode
    @Environment(\.colorScheme) var colorScheme
    
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
        return renderingMode == .vibrant ? .white : HEAD_TO_HEAD_COLOR_1.backgroundColors[0]
    }
    
    var progressBarBackgroundColor: Color {
        return renderingMode == .vibrant ? .black : HEAD_TO_HEAD_COLOR_2.backgroundColors[0]
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
    
    var labelColor: Color {
        return .label
    }
    
    @ViewBuilder
    var backgroundView: some View {
        if(family == .systemSmall) {
            if campaign2 == winner {
                AdaptiveImage.undergroundRepeatable(colorScheme: self.colorScheme)
                    .tiledImageAtScale()
            } else {
                SkyView()
            }
        } else if(family == .systemExtraLarge || family == .systemLarge) {
            backgroundRectView(isHorizontal: false, isSkewed: false)
        } else if(family == .systemMedium || family == .systemSmall) {
            backgroundRectView(isHorizontal: true, isSkewed: true)
        }
    }
    
    @ViewBuilder
    func backgroundRectView(isHorizontal: Bool, isSkewed: Bool) -> some View {
        if(isHorizontal) {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    SkyView()
                        .frame(width: geo.frame(in: .local).size.width * min(0.9, max(0.1, CGFloat(self.progressBarValue))), height: geo.frame(in: .local).size.height)
                    Rectangle().fill(.black).frame(width: 2)
                    AdaptiveImage.undergroundRepeatable(colorScheme: self.colorScheme)
                        .tiledImageAtScale()
                }
            }
        } else {
            ZStack {
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        SkyView()
                            .frame(width: geo.frame(in: .local).size.width, height: geo.frame(in: .local).size.height / 2)
                        AdaptiveImage.undergroundRepeatable(colorScheme: self.colorScheme)
                            .tiledImageAtScale()
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
                .foregroundStyle(labelColor)
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
        switch family {
        case .systemSmall:
            smallSizeContent
                .padding(padded ? .all : [])
        case .systemMedium:
            mediumSizeContent
                .padding(padded ? .all : [])
        case .systemLarge, .systemExtraLarge:
            largeSizeContent
                .padding(padded ? .all : [])
            //        case .systemExtraLarge:
            //            extraLargeContent
            //                .padding(padded ? .all : [])
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
                    .foregroundStyle(labelColor)
                    .font(.headline)
                    .lineLimit(1)
            } else {
                Text("Username")
                    .foregroundStyle(labelColor)
                    .font(.headline)
                    .lineLimit(1)
                    .redacted(reason: .placeholder)
            }
            if let winner = winner {
                Text(winner.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                    .foregroundStyle(labelColor)
                    .font(.caption)
            } else {
                Text("$123,456.00")
                    .foregroundStyle(labelColor)
                    .font(.caption)
                    .redacted(reason: .placeholder)
            }
            ProgressBar(value: .constant(progressBarValue), barColour: progressBarBackgroundColor, fillColor: progressBarFillColor, showDivider: true, dividerColor: labelColor, dividerWidth: 2, stroke: true)
                .frame(height: 10)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: Medium Widget
extension HeadToHeadWidgetView {
    @ViewBuilder
    var mediumSizeContent: some View {
        VStack {
            HStack(spacing: 10) {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        avatarImageView(for: campaign1 ?? sampleCampaign)
                        if(campaign1?.id == winner?.id) {
                            AdaptiveImage.coin(colorScheme: .light)
                                .imageAtScale(scale: Double.spriteScale * 1.2)
                                .foregroundStyle(Color.brandYellow)
                        }
                    }
                    GroupBox {
                        VStack(alignment: .leading, spacing: 0) {
                            if let campaign1 = campaign1 {
                                Text(campaign1.username ?? "Unknown")
                                    .foregroundStyle(labelColor)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                    .foregroundStyle(labelColor)
                                    .font(.caption)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("Username")
                                    .foregroundStyle(labelColor)
                                    .font(.headline)
                                    .lineLimit(1)
                                    .redacted(reason: .placeholder)
                                Text("$123,456.00")
                                    .foregroundStyle(labelColor)
                                    .font(.caption)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .redacted(reason: .placeholder)
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                    }
                    .groupBoxStyle(BlockGroupBoxStyle(padding: false))
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .trailing) {
                    HStack(alignment: .top) {
                        if(campaign2?.id == winner?.id) {
                            AdaptiveImage.coin(colorScheme: .light)
                                .imageAtScale(scale: Double.spriteScale * 1.2)
                                .foregroundStyle(Color.brandYellow)
                        }
                        avatarImageView(for: campaign2 ?? sampleCampaign)
                    }
                    GroupBox {
                        VStack(alignment: .leading, spacing: 0) {
                            if let campaign2 = campaign2 {
                                Text(campaign2.username ?? "Unknown")
                                    .foregroundStyle(labelColor)
                                    .font(.headline)
                                    .multilineTextAlignment(.trailing)
                                    .lineLimit(1)
                                Text(campaign2.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                    .foregroundStyle(labelColor)
                                    .font(.caption)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                            } else {
                                Text("Username")
                                    .foregroundStyle(labelColor)
                                    .font(.headline)
                                    .multilineTextAlignment(.trailing)
                                    .lineLimit(1)
                                    .redacted(reason: .placeholder)
                                Text("$123,456.00")
                                    .foregroundStyle(labelColor)
                                    .font(.caption)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                                    .redacted(reason: .placeholder)
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                    }
                    .groupBoxStyle(BlockGroupBoxStyle(padding: false))
                }
                .frame(maxWidth: .infinity)
            }
            //            ProgressBar(value: .constant(progressBarValue), barColour: progressBarBackgroundColor, fillColor: progressBarFillColor, showDivider: true, dividerColor: labelColor, dividerWidth: 2)
            //                .frame(height: 15)
            //                .overlay {
            //                    Capsule().stroke(labelColor, style: StrokeStyle(lineWidth: 2))
            //                }
        }
    }
}

// MARK: Large Widget
extension HeadToHeadWidgetView {
    @ViewBuilder
    var largeSizeContent: some View {
        ZStack {
            VStack {
                ZStack(alignment: .bottomTrailing) {
                    HStack(spacing: 0) {
                        GroupBox {
                            VStack(alignment: .leading) {
                                HStack (alignment: .top) {
                                    avatarImageView(for: campaign1 ?? sampleCampaign)
                                    VStack(alignment: .leading) {
                                        if let campaign1 = campaign1 {
                                            Text(campaign1.username ?? "Unknown")
                                                .foregroundStyle(labelColor)
                                                .font(.title2)
                                                .bold()
                                            Text(campaign1.name)
                                                .foregroundStyle(labelColor)
                                                .font(.body)
                                        } else {
                                            Text("Username")
                                                .foregroundStyle(labelColor)
                                                .font(.title2)
                                                .bold()
                                                .redacted(reason: .placeholder)
                                            Text("Some Campaign for St. Jude")
                                                .foregroundStyle(labelColor)
                                                .font(.body)
                                                .redacted(reason: .placeholder)
                                        }
                                    }
                                    //                                Spacer()
                                }
                                HStack(alignment: .lastTextBaseline) {
                                    if let campaign1 = campaign1 {
                                        Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                            .foregroundStyle(labelColor)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .lineLimit(1)
                                    } else {
                                        Text("$123,456.00")
                                            .foregroundStyle(labelColor)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .lineLimit(1)
                                            .redacted(reason: .placeholder)
                                    }
                                }
                            }
                            //                        .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .groupBoxStyle(BlockGroupBoxStyle())
                        Spacer()
                    }
                    if(campaign1?.id == winner?.id) {
                        AdaptiveImage.coin(colorScheme: .light)
                            .imageAtScale(scale: Double.spriteScale * 1.6)
                            .foregroundStyle(Color.brandYellow)
                            .offset(x: 5, y: 5)
                    }
                }
                .padding(.bottom)
                //                .padding(.bottom, 15)
                ZStack(alignment: .topLeading) {
                    HStack(spacing: 0) {
                        Spacer()
                        GroupBox {
                            VStack(alignment: .trailing) {
                                HStack(alignment: .lastTextBaseline) {
                                    if let campaign2 = campaign2 {
                                        Text(campaign2.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                            .foregroundStyle(labelColor)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .lineLimit(1)
                                    } else {
                                        Text("$123,456.00")
                                            .foregroundStyle(labelColor)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .lineLimit(1)
                                            .redacted(reason: .placeholder)
                                    }
                                }
                                HStack (alignment: .bottom) {
                                    VStack(alignment: .trailing) {
                                        if let campaign2 = campaign2 {
                                            Text(campaign2.username ?? "Unknown")
                                                .foregroundStyle(labelColor)
                                                .font(.title2)
                                                .bold()
                                                .multilineTextAlignment(.trailing)
                                            Text(campaign2.name)
                                                .foregroundStyle(labelColor)
                                                .font(.body)
                                                .multilineTextAlignment(.trailing)
                                        } else {
                                            Text("Username")
                                                .foregroundStyle(labelColor)
                                                .font(.title2)
                                                .bold()
                                                .multilineTextAlignment(.trailing)
                                                .redacted(reason: .placeholder)
                                            Text("Some Campaign for St. Jude")
                                                .foregroundStyle(labelColor)
                                                .font(.body)
                                                .multilineTextAlignment(.trailing)
                                                .redacted(reason: .placeholder)
                                        }
                                    }
                                    avatarImageView(for: campaign2 ?? sampleCampaign)
                                }
                            }
                        }
                        .groupBoxStyle(BlockGroupBoxStyle())
                    }
                    
                    if(campaign2?.id == winner?.id) {
                        AdaptiveImage.coin(colorScheme: .light)
                            .imageAtScale(scale: Double.spriteScale * 1.6)
                            .foregroundStyle(Color.brandYellow)
                            .offset(x: -5, y: -5)
                    }
                }
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
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            avatarImageView(for: campaign1 ?? sampleCampaign)
                                .frame(maxHeight: 100)
                            if(campaign1?.id == winner?.id) {
                                AdaptiveImage.coin(colorScheme: .light)
                                    .imageAtScale(scale: Double.spriteScale * 2)
                                    .foregroundStyle(Color.brandYellow)
                            }
                        }
                        Spacer()
                        GroupBox {
                            VStack(alignment: .leading) {
                                if let campaign1 = campaign1 {
                                    Text(campaign1.username ?? "Unknown")
                                        .foregroundStyle(labelColor)
                                        .font(.title2)
                                        .bold()
                                    Text(campaign1.name)
                                        .foregroundStyle(labelColor)
                                        .font(.body)
                                    Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                        .foregroundStyle(labelColor)
                                        .font(.title)
                                        .fontWeight(.bold)
                                    //                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text("Username")
                                        .foregroundStyle(labelColor)
                                        .font(.title2)
                                        .bold()
                                        .redacted(reason: .placeholder)
                                    Text("Some Campaign for St. Jude")
                                        .foregroundStyle(labelColor)
                                        .font(.body)
                                        .redacted(reason: .placeholder)
                                    Text("$123,456.00")
                                        .foregroundStyle(labelColor)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .redacted(reason: .placeholder)
                                    //                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            //                            .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .groupBoxStyle(BlockGroupBoxStyle())
                        .padding(.trailing, 4)
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack(alignment: .top) {
                            if(campaign2?.id == winner?.id) {
                                AdaptiveImage.coin(colorScheme: .light)
                                    .imageAtScale(scale: Double.spriteScale * 2)
                                    .foregroundStyle(Color.brandYellow)
                                //                                Image(systemName: "crown.fill")
                                //                                    .font(.system(size: 30))
                                //                                    .imageScale(.large)
                                //                                    .foregroundStyle(Color.brandYellow)
                                //                                    .background(Circle().fill(.white).blur(radius: 30))
                            }
                            avatarImageView(for: campaign2 ?? sampleCampaign)
                                .frame(maxHeight: 100)
                        }
                        Spacer()
                        GroupBox { VStack(alignment: .trailing) {
                            if let campaign2 = campaign2 {
                                Text(campaign2.username ?? "Unknown")
                                    .foregroundStyle(labelColor)
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.trailing)
                                Text(campaign2.name)
                                    .foregroundStyle(labelColor)
                                    .font(.body)
                                    .multilineTextAlignment(.trailing)
                                Text(campaign2.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                    .foregroundStyle(labelColor)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                            } else {
                                Text("Username")
                                    .foregroundStyle(labelColor)
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.trailing)
                                    .redacted(reason: .placeholder)
                                Text("Some Campaign for St. Jude")
                                    .foregroundStyle(labelColor)
                                    .font(.body)
                                    .multilineTextAlignment(.trailing)
                                    .redacted(reason: .placeholder)
                                Text("$123,456.00")
                                    .foregroundStyle(labelColor)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .redacted(reason: .placeholder)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                            }
                        }.frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .groupBoxStyle(BlockGroupBoxStyle())
                        .padding(.leading, 4)
                    }
                }
            }
            ProgressBar(value: .constant(progressBarValue), barColour: progressBarBackgroundColor, fillColor: progressBarFillColor, showDivider: true, dividerColor: labelColor, dividerWidth: 2)
                .frame(height: 30)
                .overlay {
                    Capsule().stroke(labelColor, style: StrokeStyle(lineWidth: 2))
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
                Image(systemName: "crown.fill")
                    .offset(y: 3)
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
                Image(systemName: "crown.fill")
                    .aspectRatio(contentMode: .fit)
                Text(winner?.username ?? "Unknown")
                    .bold()
            }
            Text(winner?.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol) ?? "$0")
            ProgressBar(value: .constant(Float(progressBarValue)), fillColor: .white)
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
