//
//  DonorList.swift
//  St Jude
//
//  Created by Ben Cardy on 16/09/2022.
//

import SwiftUI

struct DonorList: View {
    
    let campaign: Campaign
    @Binding var donations: [TiltifyDonorsForCampaignDonation]
    @Binding var topDonor: TiltifyDonorsForCampaignDonation?
    
    @State private var isRefreshing: Bool = false
    
    var body: some View {
        ScrollView {
            
            Link(destination: URL(string: "https://tiltify.com/@\(campaign.user.slug)/\(campaign.slug)")!) {
                GroupBox {
                    HStack {
                        Text("View all donors on Tiltify")
                        Spacer()
                        Image(systemName: "safari")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            
//            Link("Visit the fundraiser", destination: URL(string: "https://tiltify.com/@\(campaign.user.slug)/\(campaign.slug)")!)
//                .font(.headline)
//                .foregroundColor(.white)
//                .padding(10)
//                .padding(.horizontal, 20)
//                .background(Color.accentColor)
//                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                .padding(.top)
            
            ForEach(donations, id: \.id) { donation in
                GroupBox {
                    VStack(spacing: 5) {
                        HStack(alignment: .top) {
                            Text(donation.donorName)
                                .multilineTextAlignment(.leading)
                                .font(.headline)
                            Spacer()
                            if !donation.incentives.isEmpty {
                                Image(systemName: "star")
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
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        await refresh()
                    }
                }) {
                    ZStack {
                        if isRefreshing {
                            ProgressView()
                        }
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .opacity(isRefreshing ? 0 : 1)
                    }
                }
            }
        }
        .refreshable {
            await refresh()
        }
        .navigationTitle("Recent Donations")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func refresh() async {
        if !isRefreshing {
            isRefreshing = true
            do {
                let apiDonorsResponse = try await ApiClient.shared.fetchDonorsForCampaign(publicId: campaign.id.uuidString)
                withAnimation {
                    donations = apiDonorsResponse.data.campaign.donations.edges.map { $0.node }
                    topDonor = apiDonorsResponse.data.campaign.topDonation
                    isRefreshing = false
                }
            } catch {
                dataLogger.error("Failed to load donors: \(error.localizedDescription)")
            }
        }
    }
    
}
