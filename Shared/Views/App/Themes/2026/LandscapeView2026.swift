//
//  LandscapeView2026.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/19/26.
//

import SwiftUI

struct LandscapeView2026: View {
    @State private var forMainScreen: Bool
    
    var body: some View {
        if self.forMainScreen {
            ZStack {
                Image(.building2026)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(x: 1.1, y: 1.1)
                    .offset(y: -10)
                    .padding(.top)
                HStack {
                    Spacer()
                    EasterEggImage(content: {
                        Image(.myke2026)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                    }, onTap: {
                        SoundEffectHelper.shared.play(.mykeRandom)
                    })
                    .shadow(radius: 10)
                    Spacer()
                    EasterEggImage(content: {
                        Image(.stephen2026)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                    }, onTap: {
                        SoundEffectHelper.shared.play(.stephenRandom)
                    })
                    .shadow(radius: 10)
                    Spacer()
                }
            }
        }
    }
    
    init(forMainScreen: Bool = true) {
        self.forMainScreen = forMainScreen
    }
}

#Preview {
    LandscapeView2026()
}
