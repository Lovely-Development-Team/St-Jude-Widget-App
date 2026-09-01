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
            return 80
        case .systemExtraLarge:
            return 200
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
            if family == .systemMedium || family == .systemExtraLarge {
                ZStack {
                    Grid(horizontalSpacing: 0) {
                        GridRow {
                            ZStack(alignment: .bottomLeading) {
                                Color.clear
                                VStack{
                                    Spacer()
                                    Spacer()
                                    HStack{
                                        Spacer()
                                        Spacer()
                                        Image(.myke2026)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: imageHeight)
                                            .padding()
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                funkyText(of:Text(formatNumber(entry.score.myke.score))
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .foregroundColor(WidgetAppearance.mykeRed2026),
                                          color:.black)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .topTrailing)
                                    .padding(4)
                                    .padding(.trailing, 10)
                            }
                            ZStack(alignment: .bottomTrailing) {
                                Color.clear
                                VStack{
                                    Spacer()
                                    HStack{
                                        Spacer()
                                        Image(.stephen2026)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: imageHeight)
                                            .padding()
                                        Spacer()
                                        Spacer()
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                            .overlay(alignment: .topLeading) {
                                funkyText(of: Text(formatNumber(entry.score.stephen.score))
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .foregroundColor(WidgetAppearance.stephenYellow),
                                          color: .black)
                                    .padding(4)
                                    .padding(.leading, 10)
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: .infinity)
                    }
                    if Theme.current != .campaign2026{
                        Rectangle()
                            .fill(.white)
                            .frame(minHeight: 0, maxHeight: .infinity)
                            .frame(width: 2)
                            .rotationEffect(.degrees(3))
                    }
                }
                .font(scoreFont)
                .background {
                    if(self.renderingMode == .fullColor) {
                        Image(.sky2026)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        Image(.building2026)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
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
                            VStack{
                                Spacer()
                                funkyText(of: Text(formatNumber(entry.score.myke.score))
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .foregroundColor(WidgetAppearance.mykeRed2026),
                                          color: .black)
                            }
                            Image(.myke2026)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: imageHeight)
                                .scaleEffect(x:-1)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: .infinity)
                        GridRow {
                            Image(.stephen2026)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: imageHeight)
                                .scaleEffect(x:-1)
                            funkyText(of: Text(formatNumber(entry.score.stephen.score))
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .foregroundColor(WidgetAppearance.stephenYellow),
                                      color: .black)
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
                .background {
                    if(self.renderingMode == .fullColor) {
                            VStack(spacing:0){
                                GeometryReader { proxy in
                                    ZStack{
                                        Image(.sky2026)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                        Image(.building2026)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    .onAppear(){
                                        print(proxy.size)
                                    }
                                    .scaleEffect(x:1.75,y:1.75)
                                    .offset(x:proxy.size.width*0.25,y:proxy.size.height * -0.25)
                                    .mask{
                                        Rectangle()
                                            .fill(.red)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .offset(x:-proxy.size.width*0.03)
                                            .frame(height: proxy.size.height*1.10)
                                            .rotationEffect(.degrees(-3))
                                    }
                                }
                                GeometryReader { proxy in
                                    ZStack{
                                        Image(.sky2026)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                        Image(.building2026)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    .scaleEffect(x:1.75,y:1.75)
                                    .offset(x:proxy.size.width * -0.3,y:proxy.size.height * 0.0)
                                    .mask{
                                        Rectangle()
                                            .fill(.red)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .offset(x:-proxy.size.width*0.03,y:proxy.size.height*0.04)
                                            .frame(height: proxy.size.height*1.10)
                                            .rotationEffect(.degrees(-3))
                                    }
                                }
                        }
                    }
                }
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
