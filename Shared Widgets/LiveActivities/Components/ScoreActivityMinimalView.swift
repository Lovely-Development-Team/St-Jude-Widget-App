//
//  ScoreActivityMinimalView.swift
//  St Jude
//
//  Created by David Stephens on 03/09/2026.
//

import SwiftUI


struct ScoreActivityMinimalView: View {
    let state: ScoreAttributes.ContentState
    
    var body: some View {
        HStack {
            if state.myke > state.stephen {
                VStack {
                    CrownView()
                        .foregroundStyle(WidgetAppearance.mykeRed2026)
                    Image(.mykeHeadIcon2026Tiny)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            } else if state.myke < state.stephen {
                VStack {
                    CrownView()
                        .foregroundStyle(WidgetAppearance.stephenYellow2026.darker(by: 5))
                    Image(.stephenHeadIcon2026Tiny)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            } else {
                HStack(spacing: 0) {
                    Image(.mykeHeadIcon2026Tiny)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(WidgetAppearance.mykeRed2026)
                    Image(.stephenHeadIcon2026Tiny)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(WidgetAppearance.stephenYellow2026.darker(by: 5))
                }
            }
        }
    }
}
