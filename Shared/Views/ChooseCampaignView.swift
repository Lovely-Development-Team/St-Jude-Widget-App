//
//  ChooseCampaignView.swift
//  St Jude
//
//  Created by Ben Cardy on 31/08/2023.
//

import SwiftUI

struct ChooseCampaignView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var campaigns: [Campaign] = []
    
    @State private var searchText: String = ""
    
    var filteredCampaigns: [Campaign] {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return campaigns
        } else {
            return campaigns.filter { $0.title.lowercased().contains(query) || $0.user.username.lowercased().contains(query) }
        }
    }
    
    var done: (_: Campaign) -> Void
    
    var body: some View {
        List(filteredCampaigns, id: \.self) { campaign in
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                done(campaign)
            }) {
                HStack(alignment: .firstTextBaseline) {
                    VStack {
                        Text(campaign.name)
                            .fullWidth()
                        Text(campaign.user.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fullWidth()
                    }
                    Spacer()
                    Text(campaign.totalRaisedDescription(showFullCurrencySymbol: false))
                        .foregroundStyle(Color.accentColor)
                }
                .foregroundColor(.primary)
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Choose a Fundraiser")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                }
            }
        }
        .task {
            do {
                campaigns = try await AppDatabase.shared.fetchAllCampaigns().filter { !HIDDEN_CAMPAIGN_IDS.contains($0.id) }.sorted { $0.totalRaisedNumerical > $1.totalRaisedNumerical }
            } catch {
                dataLogger.error("Could not fetch campaigns: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChooseCampaignView() { campaign in
        }
    }
}
