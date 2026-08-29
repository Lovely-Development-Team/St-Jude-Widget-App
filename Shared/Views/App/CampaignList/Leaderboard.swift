//
//  Leaderboard.swift
//  St Jude
//
//  Created by Ben Cardy on 29/08/2023.
//

import SwiftUI

struct Leaderboard: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var campaigns: [Campaign] = []
    var navigateTo: (_: Campaign) -> Void
    
    // Marker place for "top X campaigns"
    @State private var leaderboardMarkerCutoff = 50
    
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
                    Image(systemName: "star.fill")
                }
                Text(campaign.totalRaisedDescription(showFullCurrencySymbol: false))
                    .monospacedDigit()
                    .foregroundColor(offset == 0 ? .white : Theme.current.accentColor)
            }
            .foregroundColor(offset == 0 ? .white : .primary)
        }
        .themedButton(type: offset == 0 ? .primary : .secondary, id: campaign.id)
    }
        
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    Theme.current.skyView(forMainScreen: false)
                    
                    VStack {
                        
                        Text("Leaderboard")
                            .font(.largeTitle.weight(.bold))
                            .fullWidth(alignment: .center)
                        
                        Spacer()
                        
                        if let first = sortedCampaigns.first {
                            self.listRow(campaign: first, offset: 0)
                        }
                        
                    }
                    .padding()
                    
                }
                VStack {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: .infinity), alignment: .top)]) {
                        ForEach(Array(sortedCampaigns.dropFirst().enumerated()), id: \.offset) { offset, campaign in
                            self.listRow(campaign: campaign, offset: offset + 1)
                        }
                    }
                    .padding(.top)
                }
                .padding(.top)
                .padding(.horizontal)
                .background {
                    VStack(spacing: 0) {
                        Theme.current.landscapeToBackgroundTransition
                        Theme.current.backgroundView
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
        .onAppear {
            Task {
                await self.fetch()
            }
        }
    }
    
    func fetch() async {
        do {
            dataLogger.notice("Fetched stored fundraiser")
            try Task.checkCancellation()
            self.campaigns = try await AppDatabase.shared.fetchAllCampaigns().filter { !HIDDEN_CAMPAIGN_IDS.contains($0.id) }
        } catch {
            dataLogger.error("Failed to fetch stored fundraisers: \(error.localizedDescription)")
        }
    }
}
