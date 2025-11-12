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
    
    @ViewBuilder
    func listRow(campaign: Campaign, offset: Int) -> some View {
        Button(action: {
            navigateTo(campaign)
        }) {
            HStack {
                Text("\(offset + 1)")
                    .monospacedDigit()
                    .bold()
                Text(campaign.user.name)
                Spacer()
                if offset == 0 {
                    Image(systemName: "trophy")
                        .foregroundStyle(Color.brandYellow)
                } else if campaign.isStarred {
                    Image(systemName: "heart.fill")
                }
                Text(campaign.totalRaisedDescription(showFullCurrencySymbol: false))
                    .monospacedDigit()
                    .foregroundColor(.accentColor)
            }
            .foregroundColor(.primary)
        }
    }
        
    var body: some View {
        List {
            ForEach(Array(sortedCampaigns.enumerated()), id: \.offset) { offset, campaign in
                if offset == 49 {
                    self.listRow(campaign: campaign, offset: offset)
                        .listRowSeparatorTint(Color.accentColor)
                } else {
                    self.listRow(campaign: campaign, offset: offset)
                }
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .navigationTitle("Leaderboard")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}
