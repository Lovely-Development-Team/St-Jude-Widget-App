//
//  ChooseCampaignView.swift
//  St Jude
//
//  Created by Ben Cardy on 31/08/2023.
//

import SwiftUI

struct ChooseCampaignView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismissSearch) private var dismissSearch
    
    @State private var campaigns: [Campaign] = []
    
    @State private var searchText: String = ""
    var otherCampaign: Campaign? = nil
    
    var filteredCampaigns: [Campaign] {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return campaigns
        } else {
            return campaigns.filter { $0.title.lowercased().contains(query) || $0.user.username.lowercased().contains(query) }
        }
    }
    
    var titleText: String {
        if otherCampaign != nil {
            return "Choose a contender!"
        }
        return "Choose a campaign"
    }
    
    var done: (_: Campaign) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: .infinity), alignment: .top)]) {
                if filteredCampaigns.count > 0 {
                    ForEach(filteredCampaigns, id: \.self) { campaign in
                        Button(action: {
                            dismissSearch()
                            searchText = ""
                            presentationMode.wrappedValue.dismiss()
                            done(campaign)
                        }) {
                            GroupBox {
                                FundraiserListItem(campaign: campaign, sortOrder: .byAmountRaised, showDisclosureIndicator: false, compact: true, showBackground: false, showShareSheet: .constant(false))
                            }
                            .themedGroupBox(type: .primary, id: campaign.id)
                        }
                        .themedButton(type: .plain, id: campaign.id)
                    }
                } else {
                    GroupBox {
                        Label(title: {
                            Text("No search results")
                        }, icon: {
                            Image(systemName: "exclamationmark.triangle")
                        })
                        .fullWidth(alignment: .center)
                    }
                    .themedGroupBox(type: .secondary, id: "no-search-results")
                }
            }
            .padding()
            .searchable(text: $searchText)
        }
        .background {
            Theme.current.backgroundView
        }
        .navigationTitle(titleText)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
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
