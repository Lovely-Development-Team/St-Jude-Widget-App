//
//  LandscapeView2026.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/19/26.
//

import SwiftUI

struct LandscapeView2026: View {
    @State private var forMainScreen: Bool
    @State private var showMyke: Bool
    @State private var showStephen: Bool
    @State private var showBuildings: Bool
    
    var body: some View {
        if self.forMainScreen {
            ZStack {
                if showBuildings {
                    Image(.building2026)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(x: 1.1, y: 1.1)
                        .offset(y: -10)
                        .padding(.top)
                }
                HStack {
                    Spacer()
                    EasterEggImage(content: {
                        Image(.myke2026)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                    }, onTap: {
                        if showMyke {
                            SoundEffectHelper.shared.play(.mykeRandom)
                        }
                    })
                    .shadow(radius: 10)
                    .opacity(showMyke ? 1 : 0)
                    Spacer()
                    EasterEggImage(content: {
                        Image(.stephen2026)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                    }, onTap: {
                        if showStephen {
                            SoundEffectHelper.shared.play(.stephenRandom)
                        }
                    })
                    .shadow(radius: 10)
                    .opacity(showStephen ? 1 : 0)
                    Spacer()
                }
            }
        }
    }
    
    init(forMainScreen: Bool = true, showMyke: Bool = true, showStephen: Bool = true, showBuildings: Bool = true) {
        self.forMainScreen = forMainScreen
        self.showMyke = showMyke
        self.showStephen = showStephen
        self.showBuildings = showBuildings
    }
}

#Preview {
    LandscapeView2026()
}
