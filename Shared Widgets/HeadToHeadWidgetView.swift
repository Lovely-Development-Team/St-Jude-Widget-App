//
//  HeadToHeadWidgetView.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/31/23.
//

import SwiftUI
import WidgetKit
import Kingfisher

let HEAD_TO_HEAD_COLOR_1 = WidgetAppearance.red
let HEAD_TO_HEAD_COLOR_2 = WidgetAppearance.purple

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
    
    var showColorBackground: Bool {
        entry.configuration.showColorBackground?.boolValue ?? true
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
        if(showColorBackground) {
            return .white
        }
        return .label
    }
    
    @ViewBuilder
    var backgroundView: some View {
        if(family == .systemSmall) {
            LinearGradient(colors: smallBackgroundColors, startPoint: .bottom, endPoint: .top)
        } else if(family == .systemLarge) {
            backgroundRectView(isHorizontal: false, isSkewed: false)
        } else if(family == .systemExtraLarge || family == .systemMedium) {
            backgroundRectView(isHorizontal: true, isSkewed: true)
        }
    }
    
    @ViewBuilder
    func backgroundRectView(isHorizontal: Bool, isSkewed: Bool) -> some View {
        if(isHorizontal) {
            ZStack {
                if(showColorBackground) {
                    HStack(spacing:0) {
                        Rectangle()
                            .fill(HEAD_TO_HEAD_COLOR_1.backgroundColors[0])
                        Rectangle()
                            .fill(HEAD_TO_HEAD_COLOR_2.backgroundColors[0])
                    }
                }
                ZStack {
                    if(showColorBackground) {
                        HStack(spacing:0) {
                            Rectangle()
                                .fill(HEAD_TO_HEAD_COLOR_1.backgroundColors[0])
                            Rectangle()
                                .fill(HEAD_TO_HEAD_COLOR_2.backgroundColors[0])
                        }
                    }
                    Rectangle()
                        .fill(labelColor)
                        .frame(maxHeight:.infinity)
                        .frame(width:2)
                }
                .scaleEffect(y: isSkewed ? 1.5 : 1)
                .rotationEffect(Angle(degrees: isSkewed ? 15 : 0))
            }
        } else {
            ZStack {
                if(showColorBackground) {
                    VStack(spacing:0) {
                        Rectangle()
                            .fill(HEAD_TO_HEAD_COLOR_1.backgroundColors[0])
                        Rectangle()
                            .fill(HEAD_TO_HEAD_COLOR_2.backgroundColors[0])
                    }
                }
                ZStack {
                    if(showColorBackground) {
                        VStack(spacing:0) {
                            Rectangle()
                                .fill(HEAD_TO_HEAD_COLOR_1.backgroundColors[0])
                            Rectangle()
                                .fill(HEAD_TO_HEAD_COLOR_2.backgroundColors[0])
                        }
                    }
                    Rectangle()
                        .fill(labelColor)
                        .frame(maxWidth:.infinity)
                        .frame(height:2)
                }
                .scaleEffect(x: isSkewed ? 1.5 : 1)
                .rotationEffect(Angle(degrees: isSkewed ? 15 : 0))
            }
        }
    }
    
    var smallBackgroundColors: [Color] {
        if(family != .systemSmall || !showColorBackground) {
            return [.clear]
        }
        if(entry.campaign1?.id ?? nil == winner?.id) {
            return HEAD_TO_HEAD_COLOR_1.backgroundColors
        }
        return HEAD_TO_HEAD_COLOR_2.backgroundColors
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
                .clipShape(ContainerRelativeShape())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .imageScale(.large)
                .clipShape(ContainerRelativeShape())
                .foregroundStyle(labelColor)
        }
    }
    
    var headToHeadEnabled: Bool {
        entry.headToHeadEnabled
    }
    
    @ViewBuilder
    var disabledBackground: some View {
        if(!isLockScreen(family: family)) {
            LinearGradient(colors: WidgetAppearance.stjude.backgroundColors, startPoint: .bottom, endPoint: .top)
        }
    }
    
    @ViewBuilder
    func disabledContent(padded: Bool = false) -> some View {
        if(isLockScreen(family: family)) {
            if(family == .accessoryCircular) {
                Gauge(value: 0, label: {
                    Image(systemName: "lock.fill")
                })
                .gaugeStyle(.accessoryCircularCapacity)
            } else {
                Image(systemName: "lock.fill")
                if(family == .accessoryInline) {
                    Text("Get us to $500!")
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Get TLD to $500 to unlock!")
                        .multilineTextAlignment(.center)
                }
            }
        } else {
            VStack {
                Spacer()
                HStack {
                    Image(.mykesmol)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Spacer()
                    Text("vs")
                        .bold()
                        .padding(.all, 4)
                        .background(Circle().fill(Color.white))
                        .foregroundColor(.black)
                    Spacer()
                    Image(.stephensmol)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                Spacer()
                Text("Head To Head")
                    .foregroundStyle(.white)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text("Get TLD to $500 to unlock!")
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(padded ? .all : [])
        }
    }
    
    var h2hWidgetUrl: URL? {
        guard let urlString = entry.widgetUrlString, let url = URL(string: urlString),  openToHeadToHead else { return nil }
        return url
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            if(headToHeadEnabled) {
                content(for: family)
                    .containerBackground(for: .widget, content: {
                        backgroundView
                    })
                    .padding(showsBackground ? [] : .all)
                    .widgetURL(h2hWidgetUrl)
            } else {
                disabledContent()
                    .containerBackground(for: .widget, content: {
                        disabledBackground
                    })
                    .widgetURL(URL(string: "relay-fm-for-st-jude://campaign?id=65563296-EEC2-45D5-BB7B-E77203D6AB08")!)
            }
        } else {
            if(headToHeadEnabled) {
                content(for: family, padded: true)
                    .background {
                        backgroundView
                    }
                    .widgetURL(h2hWidgetUrl)
            } else {
                disabledContent(padded: true)
                    .background(disabledBackground)
                    .widgetURL(URL(string: "relay-fm-for-st-jude://campaign?id=65563296-EEC2-45D5-BB7B-E77203D6AB08")!)
            }
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
                    .overlay(alignment: .topLeading) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.brandYellow)
                            .rotationEffect(Angle(degrees: -10))
                            .offset(CGSize(width: -10, height: -10))
                    }
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
            ProgressBar(value: .constant(progressBarValue), barColour: progressBarBackgroundColor, fillColor: progressBarFillColor, showDivider: true, dividerColor: labelColor, dividerWidth: 2)
                .frame(height: 15)
                .overlay {
                    Capsule().stroke(labelColor, style: StrokeStyle(lineWidth: 2))
                }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: Medium Widget
extension HeadToHeadWidgetView {
    @ViewBuilder
    var mediumSizeContent: some View {
        VStack {
            HStack {
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            avatarImageView(for: campaign1 ?? sampleCampaign)
                            if(campaign1?.id == winner?.id) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color.brandYellow)
                                    .background(Circle().fill(.white).blur(radius: 30))
                            }
                        }
                        if let campaign1 = campaign1 {
                            Text(campaign1.username ?? "Unknown")
                                .foregroundStyle(labelColor)
                                .font(.headline)
                                .lineLimit(1)
                            Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                .foregroundStyle(labelColor)
                                .font(.caption)
                        } else {
                            Text("Username")
                                .foregroundStyle(labelColor)
                                .font(.headline)
                                .lineLimit(1)
                                .redacted(reason: .placeholder)
                            Text("$123,456.00")
                                .foregroundStyle(labelColor)
                                .font(.caption)
                                .redacted(reason: .placeholder)
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack(alignment: .top) {
                            if(campaign2?.id == winner?.id) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color.brandYellow)
                                    .background(Circle().fill(.white).blur(radius: 30))
                            }
                            avatarImageView(for: campaign2 ?? sampleCampaign)
                        }
                        if let campaign2 = campaign2 {
                            Text(campaign2.username ?? "Unknown")
                                .foregroundStyle(labelColor)
                                .font(.headline)
                                .multilineTextAlignment(.trailing)
                                .lineLimit(1)
                            Text(campaign2.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                .foregroundStyle(labelColor)
                                .font(.caption)
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
                                .redacted(reason: .placeholder)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            ProgressBar(value: .constant(progressBarValue), barColour: progressBarBackgroundColor, fillColor: progressBarFillColor, showDivider: true, dividerColor: labelColor, dividerWidth: 2)
                .frame(height: 15)
                .overlay {
                    Capsule().stroke(labelColor, style: StrokeStyle(lineWidth: 2))
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
                HStack {
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
                            Spacer()
                            if(campaign1?.id == winner?.id) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 30))
                                    .imageScale(.large)
                                    .foregroundStyle(Color.brandYellow)
                                    .background(Circle().fill(.white).blur(radius: 30))
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.bottom)
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack(alignment: .lastTextBaseline) {
                            if(campaign2?.id == winner?.id) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 30))
                                    .imageScale(.large)
                                    .foregroundStyle(Color.brandYellow)
                                    .background(Circle().fill(.white).blur(radius: 30))
                            }
                            Spacer()
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
                .padding(.top)
            }
            ProgressBar(value: .constant(progressBarValue), barColour: progressBarBackgroundColor, fillColor: progressBarFillColor, showDivider: true, dividerColor: labelColor, dividerWidth: 2)
                .frame(height: 15)
                .overlay {
                    Capsule().stroke(labelColor, style: StrokeStyle(lineWidth: 2))
                }
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
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 30))
                                    .imageScale(.large)
                                    .foregroundStyle(Color.brandYellow)
                                    .background(Circle().fill(.white).blur(radius: 30))
                            }
                        }
                        Spacer()
                        if let campaign1 = campaign1 {
                            Text(campaign1.username ?? "Unknown")
                                .foregroundStyle(labelColor)
                                .font(.title2)
                                .bold()
                            Text(campaign1.name)
                                .foregroundStyle(labelColor)
                                .font(.body)
                            HStack {
                                Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                                    .foregroundStyle(labelColor)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
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
                        }
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack(alignment: .top) {
                            if(campaign2?.id == winner?.id) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 30))
                                    .imageScale(.large)
                                    .foregroundStyle(Color.brandYellow)
                                    .background(Circle().fill(.white).blur(radius: 30))
                            }
                            avatarImageView(for: campaign2 ?? sampleCampaign)
                                .frame(maxHeight: 100)
                        }
                        Spacer()
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
                        }
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
