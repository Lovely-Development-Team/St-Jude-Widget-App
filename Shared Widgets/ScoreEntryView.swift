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
    
    @ViewBuilder
    var homeScreenWidget: some View {
        Grid {
            GridRow {
                Image(.mykehead)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(family == .systemLarge ? 10 : 0)
                Image(.stephenhead)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(family == .systemLarge ? 10 : 0)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            GridRow {
                Text(formatNumber(entry.score.myke.score))
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                Text(formatNumber(entry.score.stephen.score))
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
            }
        }
        .font(.system(.largeTitle, design: .rounded))
        .bold()
        .foregroundColor(.white)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
//        .background {
//            Image(.bannersmol)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//        }
        .background(.black)
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
        } else {
            content
        }
    }
}

struct CampaignList_Previews: PreviewProvider {
    static var previews: some View {
        ScoreEntryView(entry: .init(date: .now, score: Score(myke: .init(score: 69), stephen: .init(score: 420))))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
