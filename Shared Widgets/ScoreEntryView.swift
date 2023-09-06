//
//  ScoreEntryView.swift
//  St Jude
//
//  Created by Ben Cardy on 06/09/2023.
//

import SwiftUI
import WidgetKit

struct ScoreEntryView: View {
    var entry: ScoreEntry
    
    var content: some View {
        HStack {
            VStack {
                Image(.mykehead)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text("\(entry.score.myke.score)")
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            VStack {
                Image(.stephenhead)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text("\(entry.score.stephen.score)")
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .font(.system(.largeTitle, design: .rounded))
        .bold()
        .foregroundColor(.white)
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(.black, for: .widget)
        } else {
            content
                .padding()
                .background(.black)
        }
    }
}
