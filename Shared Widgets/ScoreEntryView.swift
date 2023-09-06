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
    
    var content: some View {
        HStack {
            VStack {
                Image(.mykehead)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(family == .systemLarge ? 10 : 0)
                Text("\(entry.score.myke.score)")
                    .minimumScaleFactor(0.5)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            VStack {
                Image(.stephenhead)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(family == .systemLarge ? 10 : 0)
                Text("\(entry.score.stephen.score)")
                    .minimumScaleFactor(0.5)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .font(.system(.largeTitle, design: .rounded))
        .bold()
        .foregroundColor(.white)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .padding()
                .background {
                    Image(.bannerBackground)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .containerBackground(.black, for: .widget)
        } else {
            content
                .padding()
                .background {
                    Image(.bannerBackground)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .background(.black)
        }
    }
}
