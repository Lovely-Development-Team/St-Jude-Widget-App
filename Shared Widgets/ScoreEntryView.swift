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
        case .systemLarge, .systemExtraLarge, .systemMedium:
            return .atSize(60)
        default:
            return .title
        }
    }
    
    var imageHeight: CGFloat {
        switch family {
        case .systemSmall, .systemMedium:
            return 80
        default:
            return 130
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
    var homeScreenWidget: some View {
        VStack(spacing: 0) {
            if family == .systemMedium {
                ZStack {
                    Grid(horizontalSpacing: 0) {
                        GridRow {
                            ZStack(alignment: .bottomLeading) {
                                Color.clear
                                Image(stephenIsWinning ? .stephenFighting : .stephenSuit)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: imageHeight)
                                    .padding()
                            }
                            .overlay(alignment: .topTrailing) {
                                funkyText(of: Text(formatNumber(entry.score.stephen.score))
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .foregroundColor(WidgetAppearance.stephenLights),
                                          color: .black)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .topTrailing)
                                    .padding(4)
                                    .padding(.trailing, 10)
                            }
                            ZStack(alignment: .topTrailing) {
                                Color.clear
                                Image(mykeIsWinning ? .mykeFighting : .mykeSuit)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: imageHeight)
                                    .padding()
                            }
                            .overlay(alignment: .bottomLeading) {
                                funkyText(of: Text(formatNumber(entry.score.myke.score))
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .foregroundColor(WidgetAppearance.mykeLights),
                                          color: .black)
                                    .padding(4)
                                    .padding(.leading, 10)
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: .infinity)
                    }
                    Rectangle()
                        .fill(.white)
                        .frame(minHeight: 0, maxHeight: .infinity)
                        .frame(width: 2)
                        .rotationEffect(.degrees(3))
                }
                .font(scoreFont)
//                HStack(alignment: .top) {
//                    Image(stephenIsWinning ? .stephenFightingSmall : .stephenSuitSmall)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(height: 80)
//                    Spacer()
//                    Group {
//                        funkyText(of: Text(formatNumber(entry.score.stephen.score))
//                            .minimumScaleFactor(0.5)
//                            .multilineTextAlignment(.center)
//                            .lineLimit(1)
//                            .foregroundColor(WidgetAppearance.stephenLights),
//                                  color: .black
//                        )
//                        Spacer()
//                        funkyText(of: Text(formatNumber(entry.score.myke.score))
//                            .minimumScaleFactor(0.5)
//                            .multilineTextAlignment(.center)
//                            .lineLimit(1)
//                            .foregroundColor(WidgetAppearance.mykeLights), color: .black)
//                    }
//                    .offset(y: -30)
//                    Spacer()
//                    Image(mykeIsWinning ? .mykeFightingSmall : .mykeSuitSmall)
//                        .resizable()
//                        .aspectRatio(contentMode: mykeIsWinning ? .fill : .fit)
//                        .frame(height: 80)
//                }
//                .font(scoreFont)
//                .padding(.horizontal)
            } else {
                ZStack {
                    Grid(verticalSpacing: 0) {
                        GridRow {
                            Image(entry.score.stephen.score > entry.score.myke.score ? .stephenFighting : .stephenSuit)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: imageHeight)
                            funkyText(of: Text(formatNumber(entry.score.stephen.score))
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .foregroundColor(WidgetAppearance.stephenLights),
                                      color: .black)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: .infinity)
                        GridRow {
                            funkyText(of: Text(formatNumber(entry.score.myke.score))
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .foregroundColor(WidgetAppearance.mykeLights),
                                      color: .black)
                            Image(entry.score.stephen.score < entry.score.myke.score ? .mykeFighting : .mykeSuit)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: imageHeight)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: .infinity)
                    }
                    Rectangle()
                        .fill(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 2)
                        .rotationEffect(.degrees(-3))
                }
                .font(scoreFont)
            }
        }
        .ignoresSafeArea()
        .background {
            if(self.renderingMode == .fullColor) {
                LinearGradient(colors: WidgetAppearance.stephen.backgroundColors, startPoint: .top, endPoint: .bottom)
            }
        }
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
            Image(systemName: "m.circle")
            Text(formatNumber(entry.score.myke.score))
                .fixedSize(horizontal: true, vertical: false)
            Spacer()
            Image(systemName: "s.circle")
            Text(formatNumber(entry.score.stephen.score))
                .fixedSize(horizontal: true, vertical: false)
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

#Preview(as: .accessoryRectangular, widget: {
    ScoreWidget()
}, timeline: {
    ScoreEntry(date: .now, score: Score(myke: .init(score: 233), stephen: .init(score: 231)))
})
