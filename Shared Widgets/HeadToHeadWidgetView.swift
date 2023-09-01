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
    
    var backgroundColors: [Color] {
        if(entry.campaign1?.id ?? nil == winner.id) {
            return HEAD_TO_HEAD_COLOR_1.backgroundColors
        }
        return HEAD_TO_HEAD_COLOR_2.backgroundColors
    }
    
    func avatarImage(for campaign: TiltifyWidgetData) -> UIImage? {
        guard let data = campaign.avatarImageData else { return nil }
        return UIImage(data: data)
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            content(for: family)
                .containerBackground(LinearGradient(colors: backgroundColors, startPoint: .bottom, endPoint: .top), for: .widget)
        } else {
            content(for: family)
                .background(LinearGradient(colors: backgroundColors, startPoint: .bottom, endPoint: .top))
        }
    }
    
    @ViewBuilder
    func content(for family: WidgetFamily) -> some View {
        switch family {
        case .systemSmall:
            smallSizeContent
        default:
            content
        }
    }
    
    @ViewBuilder
    var smallSizeContent: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                if let image = avatarImage(for: winner) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(ContainerRelativeShape())
                        .overlay(alignment: .topLeading) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.brandYellow)
                                .rotationEffect(Angle(degrees: -10))
                                .offset(CGSize(width: -10, height: -10))
                        }
                }
                Spacer()
                if let image = avatarImage(for: nonWinner) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .opacity(0.5)
                        .scaleEffect(0.75)
                }
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
