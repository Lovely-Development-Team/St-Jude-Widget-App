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
    
    var entry: HeadToHeadProvider.Entry
    
    var campaign1: TiltifyWidgetData {
        entry.campaign1 ?? sampleCampaign
    }
    
    var campaign2: TiltifyWidgetData {
        entry.campaign2 ?? sampleCampaign
    }
    
    var progressBarValue: Float {
        guard let campaign1 = entry.campaign1, let campaign2 = entry.campaign2 else { return 0 }
        
        let denominator = campaign1.totalRaisedNumerical + campaign2.totalRaisedNumerical
        guard denominator > 0 else { return 0.5 }
        return Float(campaign1.totalRaisedNumerical / denominator)
    }

    var highestTotal: Double {
        guard let campaign1 = entry.campaign1, let campaign2 = entry.campaign2 else { return 0 }
        
        return max(campaign1.totalRaisedNumerical, campaign2.totalRaisedNumerical)
    }
    
    var winner: TiltifyWidgetData {
        guard let campaign1 = entry.campaign1, let campaign2 = entry.campaign2 else { return sampleCampaign }
        
        if(campaign1.totalRaisedNumerical == highestTotal) {
            return campaign1
        }
        
        return campaign2
    }
    
    var nonWinner: TiltifyWidgetData {
        guard let campaign1 = entry.campaign1, let campaign2 = entry.campaign2 else { return sampleCampaign }
        
        if(campaign1.totalRaisedNumerical == highestTotal) {
            return campaign2
        }
        
        return campaign1
    }

    func distanceFromWin(for campaign: TiltifyWidgetData) -> Double {
        return highestTotal - campaign.totalRaisedNumerical
    }
    
    @ViewBuilder
    var backgroundView: some View {
        if(family == .systemSmall) {
            LinearGradient(colors: smallBackgroundColors, startPoint: .bottom, endPoint: .top)
        } else if(family == .systemLarge) {
            backgroundRectView(isHorizontal: false, isSkewed: false)
        } else {
            backgroundRectView(isHorizontal: true, isSkewed: true)
        }
    }
    
    @ViewBuilder
    func backgroundRectView(isHorizontal: Bool, isSkewed: Bool) -> some View {
        if(isHorizontal) {
            ZStack {
                HStack(spacing:0) {
                    Rectangle()
                        .fill(HEAD_TO_HEAD_COLOR_1.backgroundColors[0])
                    Rectangle()
                        .fill(HEAD_TO_HEAD_COLOR_2.backgroundColors[0])
                }
                ZStack {
                    HStack(spacing:0) {
                        Rectangle()
                            .fill(HEAD_TO_HEAD_COLOR_1.backgroundColors[0])
                        Rectangle()
                            .fill(HEAD_TO_HEAD_COLOR_2.backgroundColors[0])
                    }
                    Rectangle()
                        .fill(.white)
                        .frame(maxHeight:.infinity)
                        .frame(width:2)
                }
                .transformEffect(CGAffineTransform(a: 1, b: 0, c: isSkewed ? -0.15 : 0, d: 1, tx: 0, ty: 0))
                .offset(x: isSkewed ? 20 : 0)
            }
        } else {
            ZStack {
                VStack(spacing:0) {
                    Rectangle()
                        .fill(HEAD_TO_HEAD_COLOR_1.backgroundColors[0])
                    Rectangle()
                        .fill(HEAD_TO_HEAD_COLOR_2.backgroundColors[0])
                }
                ZStack {
                    VStack(spacing:0) {
                        Rectangle()
                            .fill(HEAD_TO_HEAD_COLOR_1.backgroundColors[0])
                        Rectangle()
                            .fill(HEAD_TO_HEAD_COLOR_2.backgroundColors[0])
                    }
                    Rectangle()
                        .fill(.white)
                        .frame(maxWidth:.infinity)
                        .frame(height:2)
                }
                .transformEffect(CGAffineTransform(a: 1, b: isSkewed ? -0.15 : 0, c: 0, d: 1, tx: 0, ty: 0))
                .offset(y: isSkewed ? 20 : 0)
            }
        }
    }
    
    var smallBackgroundColors: [Color] {
        if(family != .systemSmall) {
            return [.clear]
        }
        if(entry.campaign1?.id ?? nil == winner.id) {
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
        }
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            content(for: family)
                .containerBackground(for: .widget, content: {
                    backgroundView
                })
        } else {
            content(for: family)
                .background {
                    backgroundView
                }
        }
    }
    
    @ViewBuilder
    func content(for family: WidgetFamily) -> some View {
        switch family {
        case .systemSmall:
            smallSizeContent
        case .systemMedium:
            mediumSizeContent
        case .systemLarge:
            largeSizeContent
        case .systemExtraLarge:
            extraLargeContent
        default:
            content
        }
    }
    
    @ViewBuilder
    var smallSizeContent: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                avatarImageView(for: winner)
                    .overlay(alignment: .topLeading) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.brandYellow)
                            .rotationEffect(Angle(degrees: -10))
                            .offset(CGSize(width: -10, height: -10))
                    }
                Spacer()
                avatarImageView(for: nonWinner)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .opacity(0.5)
                    .scaleEffect(0.75)
            }
            Spacer()
            if let username = winner.username {
                Text(username)
                    .font(.headline)
                    .lineLimit(1)
            }
            Text(winner.totalRaisedDescription(showFullCurrencySymbol: false))
                .font(.caption)
            ProgressBar(value: .constant(progressBarValue), barColour: HEAD_TO_HEAD_COLOR_2.backgroundColors[0], fillColor: HEAD_TO_HEAD_COLOR_1.backgroundColors[0], showDivider: true, dividerWidth: 2)
                .frame(height: 15)
                .overlay {
                    Capsule().stroke(.white, style: StrokeStyle(lineWidth: 2))
                }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    var mediumSizeContent: some View {
        VStack {
            HStack {
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            avatarImageView(for: campaign1)
                            if(campaign1.id == winner.id) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color.brandYellow)
                                    .background(Circle().fill(.white).blur(radius: 30))
                            }
                        }
                        Text(campaign1.username ?? "Unknown")
                            .font(.headline)
                            .lineLimit(1)
                        Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: false))
                            .font(.caption)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack(alignment: .top) {
                            if(campaign2.id == winner.id) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color.brandYellow)
                                    .background(Circle().fill(.white).blur(radius: 30))
                            }
                            avatarImageView(for: campaign2)
                        }
                        Text(campaign2.username ?? "Unknown")
                            .font(.headline)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(1)
                        Text(campaign2.totalRaisedDescription(showFullCurrencySymbol: false))
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            ProgressBar(value: .constant(progressBarValue), barColour: HEAD_TO_HEAD_COLOR_2.backgroundColors[0], fillColor: HEAD_TO_HEAD_COLOR_1.backgroundColors[0], showDivider: true, dividerWidth: 2)
                .frame(height: 15)
                .overlay {
                    Capsule().stroke(.white, style: StrokeStyle(lineWidth: 2))
                }
        }
    }
    
    @ViewBuilder
    var largeSizeContent: some View {
        ZStack {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        HStack (alignment: .top) {
                            avatarImageView(for: campaign1)
                            VStack(alignment: .leading) {
                                Text(campaign1.username ?? "Unknown")
                                    .font(.title2)
                                    .bold()
                                Text(campaign1.name)
                                    .font(.body)
                            }
                        }
                        HStack(alignment: .lastTextBaseline) {
                            Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: false))
                                .font(.title)
                                .fontWeight(.bold)
                                .lineLimit(1)
                            Spacer()
                            if(campaign1.id == winner.id) {
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
                            if(campaign2.id == winner.id) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 30))
                                    .imageScale(.large)
                                    .foregroundStyle(Color.brandYellow)
                                    .background(Circle().fill(.white).blur(radius: 30))
                            }
                            Spacer()
                            Text(campaign2.totalRaisedDescription(showFullCurrencySymbol: false))
                                .font(.title)
                                .fontWeight(.bold)
                                .lineLimit(1)
                        }
                        HStack (alignment: .bottom) {
                            VStack(alignment: .trailing) {
                                Text(campaign2.username ?? "Unknown")
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.trailing)
                                Text(campaign2.name)
                                    .font(.body)
                                    .multilineTextAlignment(.trailing)
                            }
                            avatarImageView(for: campaign2)
                        }
                    }
                }
                .padding(.top)
            }
            ProgressBar(value: .constant(progressBarValue), barColour: HEAD_TO_HEAD_COLOR_2.backgroundColors[0], fillColor: HEAD_TO_HEAD_COLOR_1.backgroundColors[0], showDivider: true, dividerWidth: 2)
                .frame(height: 15)
                .overlay {
                    Capsule().stroke(.white, style: StrokeStyle(lineWidth: 2))
                }
        }
    }
    
    @ViewBuilder
    var extraLargeContent: some View {
        ZStack {
            VStack {
                HStack {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                avatarImageView(for: campaign1)
                                    .frame(maxHeight: 100)
                                if(campaign1.id == winner.id) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 30))
                                        .imageScale(.large)
                                        .foregroundStyle(Color.brandYellow)
                                        .background(Circle().fill(.white).blur(radius: 30))
                                }
                            }
                            Spacer()
                            Text(campaign1.username ?? "Unknown")
                                .font(.title2)
                                .bold()
                            Text(campaign1.name)
                                .font(.body)
                            HStack {
                                Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: false))
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                        }
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing) {
                            HStack(alignment: .top) {
                                if(campaign2.id == winner.id) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 30))
                                        .imageScale(.large)
                                        .foregroundStyle(Color.brandYellow)
                                        .background(Circle().fill(.white).blur(radius: 30))
                                }
                                avatarImageView(for: campaign2)
                                    .frame(maxHeight: 100)
                            }
                            Spacer()
                            Text(campaign2.username ?? "Unknown")
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.trailing)
                            Text(campaign2.name)
                                .font(.body)
                                .multilineTextAlignment(.trailing)
                            Text(campaign2.totalRaisedDescription(showFullCurrencySymbol: false))
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    }
                }
                ProgressBar(value: .constant(progressBarValue), barColour: HEAD_TO_HEAD_COLOR_2.backgroundColors[0], fillColor: HEAD_TO_HEAD_COLOR_1.backgroundColors[0], showDivider: true, dividerWidth: 2)
                    .frame(height: 30)
                    .overlay {
                        Capsule().stroke(.white, style: StrokeStyle(lineWidth: 2))
                    }
            }
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
