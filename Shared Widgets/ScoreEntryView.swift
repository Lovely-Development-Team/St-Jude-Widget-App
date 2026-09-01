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
    @Environment(\.widgetRenderingMode) var renderingMode
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
        case .systemLarge, .systemExtraLarge:
            return 1
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
        case .systemMedium:
            return .title3
        case .systemLarge,.systemExtraLarge:
            return .largeTitle
        default:
            return .title
        }
    }
    
    var imageHeight: CGFloat {
        switch family {
        case .systemSmall, .systemMedium:
            return 100
        case .systemExtraLarge:
            return 200
        default:
            return 130
        }
    }
    
    var textScaleFactor: CGFloat {
        switch family {
        case .systemSmall:
            return 0.8
        case .systemLarge, .systemExtraLarge:
            return 1.5
        default:
            return 1.0
        }
    }
        
    @ViewBuilder
    func funkyText(of text: some View, color: Color = .red) -> some View {
        text
            .shadow(color: color, radius: 0.4)
            .shadow(color: color, radius: 0.4)
            .shadow(color: color, radius: 0.4)
            .shadow(color: color, radius: 0.4)
            .shadow(color: color, radius: 0.4)
            .shadow(color: color, radius: 0.4)
            .shadow(color: color, radius: 0.4)
            .shadow(color: color, radius: 0.4)
            .compositingGroup()
    }
    
    @ViewBuilder
    var scoreGroupBoxView: some View{
            GroupBox {
                HStack {
                    VStack {
                        Text("Myke")
                            .bold()
                            .font(.footnote)
                        Text(self.formatNumber(self.entry.score.myke.score))
                            .bold()
                            .foregroundStyle(WidgetAppearance.mykeRed2026)
                            .font(.title)
                    }
                    .padding(.trailing, 5)
                    VStack {
                        Text("Stephen")
                            .bold()
                            .font(.footnote)
                        Text(self.formatNumber(self.entry.score.stephen.score))
                            .bold()
                            .foregroundStyle(WidgetAppearance.stephenYellow2026.darker(by: 5))
                            .font(.title)
                    }
                    .padding(.leading, 5)
                }
            }
            .themedGroupBox(type: .primary, id: "scoreWidgetScoreBox")
    }
    
    @ViewBuilder
    var smallScoreWidgetView: some View {
        ZStack {
            // Fill out the whole space
            VStack {
                self.scoreGroupBoxView
                    .scaleEffect(x: self.textScaleFactor, y: self.textScaleFactor)
                    .padding(.top, 10)
                Rectangle()
                    .foregroundColor(.clear)
                    .overlay(alignment: .top) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .overlay(alignment: .topTrailing) {
                                    Image(.myke2026)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: self.imageHeight * 1.5)
                                        .shadow(radius: 10)
                                }
                            Rectangle()
                                .foregroundStyle(.clear)
                                .overlay(alignment: .topLeading) {
                                    Image(.stephen2026)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: self.imageHeight * 1.5)
                                        .shadow(radius: 10)
                                }
                        }
                        .offset(y: -self.imageHeight / 4)
                    }
            }
            .background {
                Image.tiledImageAtScale(.woodBackground2026)
            }
        }
    }
    
    @ViewBuilder
    var mediumScoreWidgetView: some View {
        ZStack {
            // Fill out the whole space
            Rectangle()
                .foregroundStyle(.clear)
            
            HStack {
                Spacer()
                    .overlay(alignment: .trailing) {
                        Image(.myke2026)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: self.imageHeight * 2)
                            .padding(.top, self.imageHeight)
                            .offset(x: 10)
                            .shadow(radius: 10)
                    }
                    .zIndex(2)
                self.scoreGroupBoxView
                    .padding(.bottom, self.imageHeight / 3)
                    .zIndex(1)
                Spacer()
                    .overlay {
                        Image(.stephen2026)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: self.imageHeight * 2)
                            .padding(.top, self.imageHeight)
                            .offset(x: -10)
                            .shadow(radius: 10)
                    }
                    .zIndex(2)
            }
        }
        .background {
            Group {
                if(self.renderingMode == .fullColor) {
                    Image(.sky2026)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    Image(.building2026)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, self.imageHeight / 3)
                }
            }
            .scaleEffect(x: 1.5, y: 1.5)
            .padding(.bottom, self.imageHeight / 3)
        }
        
    }
    
    @ViewBuilder
    var largeScoreWidgetView: some View {
        ZStack {
            VStack {
                Rectangle()
                    .foregroundStyle(.clear)
                    .overlay(alignment: .bottom) {
                        self.scoreGroupBoxView
                        .scaleEffect(x: self.textScaleFactor, y: self.textScaleFactor)
                        .padding(.bottom)
                    }
                Rectangle()
                    .foregroundStyle(.clear)
                    .overlay(alignment: .top) {
                        HStack {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .overlay(alignment: .trailing){
                                Image(.myke2026)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: self.imageHeight * 2)
                                    .padding(.trailing)
                                    .shadow(radius: 10)
                                }
                            Rectangle()
                                .foregroundStyle(.clear)
                                .overlay(alignment: .leading) {
                                    Image(.stephen2026)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: self.imageHeight * 2)
                                        .padding(.leading)
                                        .shadow(radius: 10)
                                }
                        }
                        .padding(.top)
                    }
            }
            .background {
                Image.tiledImageAtScale(.woodBackground2026)
            }
        }
    }
    
    @ViewBuilder
    var homeScreenWidget: some View {
        VStack(spacing: 0) {
            switch self.family {
            case .systemSmall:
                self.smallScoreWidgetView
            case .systemLarge:
                self.largeScoreWidgetView
            default:
                self.mediumScoreWidgetView
            }
        }
        .ignoresSafeArea()
        .dynamicTypeSize(.medium)
        .mask {
            if(self.renderingMode == .fullColor) {
                Rectangle()
            } else {
                RoundedRectangle(cornerRadius: 10)
            }
        }
    }
    
    @ViewBuilder
    var lockScreenInline: some View {
        Text(Image(systemName: "m.circle")) + Text(" ") + Text(formatNumber(entry.score.myke.score)) + Text("  ") + Text(Image(systemName: "s.circle")) + Text(" ") +
        Text(formatNumber(entry.score.stephen.score))
    }
    
    @ViewBuilder
    var lockScreenRectangular: some View {
        HStack {
            Image(.mykeHeadIcon2026)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text(formatNumber(entry.score.myke.score))
                .fixedSize(horizontal: true, vertical: false)
            Spacer()
            Text(formatNumber(entry.score.stephen.score))
                .fixedSize(horizontal: true, vertical: false)
            Image(.stephenHeadIcon2026)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
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
                .font(.caption)
        } maximumValueLabel: {
            Text("S")
                .font(.caption)
        }
        .gaugeStyle(.accessoryCircular)
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

#Preview(as:.systemMedium, widget: {
    ScoreWidget()
}, timeline: {
    ScoreEntry(date: .now, score: Score(myke: .init(score: 233), stephen: .init(score: 231)))
})
#Preview(as: .systemSmall, widget: {
    ScoreWidget()
}, timeline: {
    ScoreEntry(date: .now, score: Score(myke: .init(score: 233), stephen: .init(score: 231)))
})
#Preview(as: .systemLarge, widget: {
    ScoreWidget()
}, timeline: {
    ScoreEntry(date: .now, score: Score(myke: .init(score: 233), stephen: .init(score: 231)))
})
#Preview(as: .systemExtraLarge, widget: {
    ScoreWidget()
}, timeline: {
    ScoreEntry(date: .now, score: Score(myke: .init(score: 233), stephen: .init(score: 231)))
})
#Preview(as: .accessoryCircular, widget: {
    ScoreWidget()
}, timeline: {
    ScoreEntry(date: .now, score: Score(myke: .init(score: 233), stephen: .init(score: 231)))
})
#Preview(as: .accessoryInline, widget: {
    ScoreWidget()
}, timeline: {
    ScoreEntry(date: .now, score: Score(myke: .init(score: 233), stephen: .init(score: 231)))
})
