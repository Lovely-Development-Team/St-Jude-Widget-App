//
//  DonorList.swift
//  St Jude
//
//  Created by Ben Cardy on 16/09/2022.
//

import SwiftUI

// TODO: [DETHEMING] Detheme this once the donor lists are showing on campaigns
struct DonorList: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024 = false
    
    let campaign: Campaign
    @Binding var donations: [TiltifyDonorsForCampaignDonation]
    @Binding var topDonor: TiltifyDonorsForCampaignDonation?
    
    @State private var isRefreshing: Bool = false
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 0) {
                                
                VStack {
                    
                    Link(destination: URL(string: "https://tiltify.com/@\(campaign.user.slug)/\(campaign.slug)")!) {
                        HStack {
                            Text("View all donors on Tiltify")
                            Spacer()
                            Image(systemName: "safari")
                        }
                    }
                    .padding()
                    
                    ForEach(donations, id: \.id) { donation in
                        GroupBox {
                            VStack(spacing: 5) {
                                HStack(alignment: .top) {
                                    Text(donation.donorName)
                                        .multilineTextAlignment(.leading)
                                        .font(.headline)
                                    Spacer()
                                    if !donation.incentives.isEmpty {
                                        Image(.heartPixel)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(donation.amount.description(showFullCurrencySymbol: false))
                                }
                                if let comment = donation.donorComment {
                                    Text(comment)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.secondary)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, donation.id == donations.last?.id ? 10 : 0)
                    }
                    
                }
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        await refresh()
                        isRefreshing = false
                    }
                }) {
                    ZStack {
                        if isRefreshing {
                            ProgressView()
                        }
                        Image(systemName: "arrow.clockwise")
                            .opacity(isRefreshing ? 0 : 1)
                    }
                }
            }
        }
        .refreshable {
            await refresh()
            isRefreshing = false
        }
        .navigationTitle("Recent Donations")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func refresh() async {
        if !isRefreshing {
            isRefreshing = true
            do {
                let apiDonorsResponse = try await ApiClient.shared.fetchDonorsForCampaign(id: campaign.id)
                withAnimation {
                    donations = apiDonorsResponse.data.fact.donations.edges.map { $0.node }
                    topDonor = apiDonorsResponse.data.fact.topDonation
                    isRefreshing = false
                }
            } catch {
                dataLogger.error("Failed to load donors: \(error.localizedDescription)")
            }
        }
    }
    
}
