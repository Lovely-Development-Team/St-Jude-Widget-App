//
//  ScoreEntryView.swift
//  St Jude
//
//  Created by Ben Cardy on 06/09/2023.
//

import SwiftUI
import WidgetKit

struct ScoreEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: ScoreEntry
    
    @State private var mykeWidth: CGSize = .zero
        
    var mykeIsWinning: Bool {
        entry.score.myke.score > entry.score.stephen.score
    }
    
    var stephenIsWinning: Bool {
        entry.score.stephen.score > entry.score.myke.score
    }
    
    func formatNumber(_ num: Double) -> String {
        if num == 0 {
            return "0"
        }
        let str = String(format: "%0.2f", num)
        return str.trimmingCharacters(in: .init(charactersIn: "0")).trimmingCharacters(in: .init(charactersIn: "."))
    }
    
    var spriteScaleModifier: Double {
        switch family {
        case .systemLarge:
            return 1.3
        case .systemSmall:
            return 0.8
        default:
            return 1
        }
    }
    
    var scorePadding: Double {
        switch family {
        case .systemMedium:
            return 10
        default:
            return 20
        }
    }
    
    var scorePaddingBottom: Double {
        switch family {
        case .systemLarge:
            return 40
        case .systemMedium:
            return 5
        default:
            return 10
        }
    }
    
    var scoreFont: Font {
        switch family {
        case .systemLarge:
            return .largeTitle
        default:
            return .title
        }
    }
    
    @ViewBuilder
    var homeScreenWidget: some View {
        ZStack {
            ZStack(alignment: .bottom) {
                Color.skyBackground.preferredColorScheme(.light)
                AdaptiveImage(colorScheme: .light, light: .skyRepeatable, dark: .skyRepeatableNight)
                    .tiledImageAtScale(scale: .spriteScale * spriteScaleModifier, axis: .horizontal)
                    .animation(.none, value: UUID())
            }
            VStack(spacing: 0) {
                Spacer()
                Grid(verticalSpacing: 0) {
                    GridRow {
                        VStack {
                            Spacer()
                            Text(formatNumber(entry.score.stephen.score))
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                            Spacer()
                        }
                        VStack {
                            Spacer()
                            Text(formatNumber(entry.score.myke.score))
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                    .bold()
                    .font(scoreFont)
                    .foregroundStyle(Color.white)
                    GridRow {
                        AdaptiveImage.stephen(colorScheme: .light)
                            .imageAtScale(scale: .spriteScale * spriteScaleModifier)
                            .scaleEffect(x: -1)
                        AdaptiveImage.myke(colorScheme: .light)
                            .imageAtScale(scale: .spriteScale * spriteScaleModifier)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
                .padding(.horizontal, scorePadding)
                AdaptiveImage.groundRepeatable(colorScheme: .light)
                    .tiledImageAtScale(scale: .spriteScale * spriteScaleModifier, axis: .horizontal)
            }
        }
        .dynamicTypeSize(.medium)
    }
    
    @ViewBuilder
    var lockScreenInline: some View {
        Text(Image(systemName: "m.circle")) + Text(" ") + Text(formatNumber(entry.score.myke.score)) + Text("  ") + Text(Image(systemName: "s.circle")) + Text(" ") +
        Text(formatNumber(entry.score.stephen.score))
    }
    
    @ViewBuilder
    var lockScreenRectangular: some View {
        HStack {
            Image(.mykehead)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
                .multilineTextAlignment(.leading)
            Text(formatNumber(entry.score.myke.score))
            Spacer()
            Image(.stephenhead)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
            Text(formatNumber(entry.score.stephen.score))
        }
        .font(.system(.body, design: .rounded))
        .bold()
    }
    
    @ViewBuilder
    var lockScreenCircular: some View {
        Gauge(value: entry.score.myke.score, in: 0...(entry.score.stephen.score + entry.score.myke.score)) {
            Text("L")
        } currentValueLabel: {
            VStack(spacing: -2) {
                Text(formatNumber(entry.score.myke.score))
                Text(formatNumber(entry.score.stephen.score))
            }
            .font(.caption)
            .bold()
        } minimumValueLabel: {
            Text("M")
        } maximumValueLabel: {
            Text("S")
        }
        .gaugeStyle(.accessoryCircular)
        .font(.system(.caption, design: .rounded))
    }
    
    @ViewBuilder
    var content: some View {
        switch family {
        case .accessoryInline:
            lockScreenInline
        case .accessoryRectangular:
            lockScreenRectangular
        case .accessoryCircular:
            lockScreenCircular
        default:
            homeScreenWidget
        }
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(.clear, for: .widget)
                .environment(\.font, Font.body)
        } else {
            content
                .environment(\.font, Font.body)
        }
    }
}

struct CampaignList_Previews: PreviewProvider {
    static var previews: some View {
//        ScoreEntryView(entry: .init(date: .now, score: Score(myke: .init(score: 69), stephen: .init(score: 420))))
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//        ScoreEntryView(entry: .init(date: .now, score: Score(myke: .init(score: 69), stephen: .init(score: 420))))
//            .previewContext(WidgetPreviewContext(family: .accessoryInline))
//        ScoreEntryView(entry: .init(date: .now, score: Score(myke: .init(score: 69), stephen: .init(score: 420))))
//            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        ScoreEntryView(entry: .init(date: .now, score: Score(myke: .init(score: 69), stephen: .init(score: 420))))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
