//
//  DonorList.swift
//  St Jude
//
//  Created by Ben Cardy on 16/09/2022.
//

import SwiftUI

struct DonorList: View {
    let campaignId: UUID
    let campaignLink: URL
    @Binding var donations: [TiltifyDonorsForCampaignDonation]
    @Binding var topDonor: TiltifyTopDonor?
    
    @State private var isRefreshing: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                Link(destination: campaignLink) {
                    HStack {
                        Text("View all donors on Tiltify")
                        Image(systemName: "square.and.arrow.up")
                    }
                    .fullWidth()
                }
                .themedButton(type: .primary, id: "donors")
                
                ForEach(donations, id: \.id) { donation in
                    GroupBox {
                        VStack {
                            HStack(alignment: .top) {
                                Text(donation.donorName)
                                    .multilineTextAlignment(.leading)
                                    .font(.headline)
                                Spacer()
                                if !(donation.rewardClaims?.isEmpty ?? true) {
                                    Image(systemName: "gift")
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
                    .themedGroupBox(type: .primary, id: donation.id)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Recent Donations")
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
            Task {
                await refresh()
                isRefreshing = false   
            }
        }
    }
    
    func refresh() async {
        if !isRefreshing {
            isRefreshing = true
            let apiTopDonor = await TiltifyAPIClient.shared.getCampaignTopDonor(forId: campaignId)
            let apiDonations = await TiltifyAPIClient.shared.getCampaignDonations(forId: campaignId)
            withAnimation {
                topDonor = apiTopDonor
                donations = apiDonations
                isRefreshing = false
            }
        }
    }
}
