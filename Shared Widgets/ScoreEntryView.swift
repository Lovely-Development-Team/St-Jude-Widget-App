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
        case .systemLarge, .systemExtraLarge, .systemMedium:
            return .atSize(60)
        default:
            return .title
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
            Spacer()
            if family == .systemMedium {
                HStack(alignment: .top) {
                    AdaptiveImage(colorScheme: .light, light: entry.score.stephen.score > entry.score.myke.score ? .stephenWalk1 : .stephenIdle)
                        .imageAtScale(scale: .spriteScale * spriteScaleModifier)
                        .scaleEffect(x: -1)
                    Spacer()
                    Group {
                        funkyText(of: Text(formatNumber(entry.score.stephen.score))
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .foregroundColor(WidgetAppearance.stephenYellow),
                                  color: .black
                        )
                        Spacer()
                        funkyText(of: Text(formatNumber(entry.score.myke.score))
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .foregroundColor(WidgetAppearance.mykeBlue.lighter(by: 10)), color: .black)
                    }
                    .offset(y: -30)
                    Spacer()
                    AdaptiveImage(colorScheme: .light, light: entry.score.stephen.score < entry.score.myke.score ? .mykeWalk1 : .mykeIdle)
                        .imageAtScale(scale: .spriteScale * spriteScaleModifier)
                }
                .font(scoreFont)
                .padding(.horizontal)
            } else {
                Grid(verticalSpacing: 0) {
                    GridRow {
                        VStack {
                            Spacer()
                            funkyText(of: Text(formatNumber(entry.score.stephen.score))
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .foregroundColor(WidgetAppearance.stephenYellow),
                                      color: .black
                            )
                            Spacer()
                        }
                        VStack {
                            Spacer()
                            funkyText(of: Text(formatNumber(entry.score.myke.score))
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .foregroundColor(WidgetAppearance.mykeBlue.lighter(by: 10)), color: .black)
                            Spacer()
                        }
                    }
                    .bold()
                    .font(scoreFont)
                    .foregroundStyle(Color.white)
                    GridRow {
                        AdaptiveImage(colorScheme: .light, light: entry.score.stephen.score > entry.score.myke.score ? .stephenWalk1 : .stephenIdle)
                            .imageAtScale(scale: .spriteScale * spriteScaleModifier)
                            .scaleEffect(x: -1)
                        AdaptiveImage(colorScheme: .light, light: entry.score.stephen.score < entry.score.myke.score ? .mykeWalk1 : .mykeIdle)
                            .imageAtScale(scale: .spriteScale * spriteScaleModifier)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
                .padding(.horizontal, scorePadding)
            }
            AdaptiveImage.groundRepeatable(colorScheme: .light)
                .tiledImageAtScale(scale: .spriteScale * spriteScaleModifier, axis: .horizontal)
        }
        .ignoresSafeArea()
        .background(alignment: .bottom) {
            if(self.renderingMode == .fullColor) {
                ZStack(alignment: .bottom) {
                    AdaptiveImage(colorScheme: .light, light: .skyBackgroundRepeatable)
                        .tiledImageAtScale(scale: .spriteScale * spriteScaleModifier, axis: .none)
                        .animation(.none, value: UUID())
                        .frame(minWidth: 0, maxWidth: .infinity)
                    AdaptiveImage(colorScheme: .light, light: .skyRepeatable, dark: .skyRepeatableNight)
                        .tiledImageAtScale(scale: .spriteScale * spriteScaleModifier, axis: .horizontal)
                        .animation(.none, value: UUID())
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
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
            Image(.mykehead)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 10, maxWidth: 30)
                .multilineTextAlignment(.leading)
                .scaleEffect(x: -1)
            Text(formatNumber(entry.score.myke.score))
                .fixedSize(horizontal: true, vertical: false)
            Spacer()
            Image(.stephenhead)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 10, maxWidth: 30)
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

struct CampaignList_Previews: PreviewProvider {
    static var previews: some View {
        //        ScoreEntryView(entry: .init(date: .now, score: Score(myke: .init(score: 69), stephen: .init(score: 420))))
        //            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        //        ScoreEntryView(entry: .init(date: .now, score: Score(myke: .init(score: 69), stephen: .init(score: 420))))
        //            .previewContext(WidgetPreviewContext(family: .accessoryInline))
        //        ScoreEntryView(entry: .init(date: .now, score: Score(myke: .init(score: 69), stephen: .init(score: 420))))
        //            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        ScoreEntryView(entry: .init(date: .now, score: Score(myke: .init(score: 69), stephen: .init(score: 420))))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
