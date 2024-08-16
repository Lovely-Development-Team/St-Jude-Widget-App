//
//  Leaderboard.swift
//  St Jude
//
//  Created by Ben Cardy on 29/08/2023.
//

import SwiftUI

struct Leaderboard: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var campaigns: [Campaign]
    var navigateTo: (_: Campaign) -> Void
    
    var sortedCampaigns: [Campaign] {
        campaigns.filter { !HIDDEN_CAMPAIGN_IDS.contains($0.id) }.sorted { c1, c2 in
            if c1.totalRaisedNumerical == c2.totalRaisedNumerical {
                return c1.user.name < c2.user.name
            }
            return c1.totalRaisedNumerical > c2.totalRaisedNumerical
        }
    }
        
    var body: some View {
        List {
            ForEach(Array(sortedCampaigns.enumerated()), id: \.offset) { offset, campaign in
                Button(action: {
                    navigateTo(campaign)
                }) {
                    HStack {
                        Text("\(offset + 1)")
                            .bold()
                        Text(campaign.user.name)
                        Spacer()
                        if offset == 0 {
                            Image("pixel-trophy")
                                .foregroundStyle(Color.brandYellow)
                        } else if campaign.isStarred {
                            Image("heart.fill.pixel")
                        }
                        Text(campaign.totalRaisedDescription(showFullCurrencySymbol: false))
                            .monospacedDigit()
                            .foregroundColor(.accentColor)
                    }
                    .foregroundColor(.primary)
                }
                .listRowSeparatorTint(offset == 49 ? Color.accentColor : .secondary.opacity(0.5))
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .background(.ultraThinMaterial)
        .background(BrandShapeBackground())
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                }
            }
        }
    }
}
