//
//  StandingThrowingView2025.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 7/31/26.
//

import SwiftUI

struct StandingThrowingView2025: View {
    private func getNewCompetitors() {
        // Ensure we don't select either of the current players
        let newCompetitor1 = Player.allCases.filter {
            $0 != self.competitor1 && $0 != self.competitor2
        }.randomElement() ?? .myke
        let newCompetitor2 = Player.allCases.filter {
            $0 != self.competitor1 && $0 != self.competitor2 && $0 != newCompetitor1
        }.randomElement() ?? .stephen
        
        self.competitor1 = newCompetitor1
        self.competitor2 = newCompetitor2
    }
        
    @State private var competitor1: Player = .myke
    @State private var competitor2: Player = .stephen
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                StandingToThrowingView(player: self.competitor1)
                StandingToThrowingView(player: self.competitor2, isMirrored: true)
            }
            .padding(.bottom, 35)
            .padding(.horizontal)
        }
        .zIndex(0)
        .onAppear {
            self.getNewCompetitors()
        }
    }
}
