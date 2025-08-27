//
//  DonorList.swift
//  St Jude
//
//  Created by Ben Cardy on 16/09/2022.
//

import SwiftUI

struct DonorList: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024 = false
    
    let campaign: Campaign
    @Binding var donations: [TiltifyDonorsForCampaignDonation]
    @Binding var topDonor: TiltifyTopDonor?
    
    @State private var isRefreshing: Bool = false
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 0) {
                
                VStack {
                    
                    Link(destination: URL(string: "https://tiltify.com/@\(campaign.user.slug)/\(campaign.slug)")!) {
                        HStack {
                            Text("View all donors on Tiltify")
                                .fontWeight(.bold)
                            Spacer()
                            Image(.boxArrowUpRightPixel)
                        }
                    }
                    .foregroundColor(.black)
                    .buttonStyle(BlockButtonStyle(tint: .accentColor))
                    .padding()
                    
                    ForEach(donations, id: \.id) { donation in
                        GroupBox {
                            VStack(spacing: 5) {
                                HStack(alignment: .top) {
                                    Text(donation.donorName)
                                        .multilineTextAlignment(.leading)
                                        .font(.headline)
                                    Spacer()
//                                    if !donation.incentives?.isEmpty ?? false {
//                                        Image(.heartPixel)
//                                            .foregroundColor(.secondary)
//                                    }
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
                        .groupBoxStyle(BlockGroupBoxStyle(shadowColor: nil))
                        .padding(.horizontal)
                        .padding(.bottom, donation.id == donations.last?.id ? 10 : 0)
                    }
                    
                }
                Spacer()
            }
            .background {
                    GeometryReader { geometry in
                        Color.arenaFloor
                            .frame(height:geometry.size.height + 1000)
                            .mask {
                                LinearGradient(stops: [
                                    .init(color: .clear, location: 0),
                                    .init(color: .white, location: 0.05),
                                    .init(color: .white, location: 1)
                                ], startPoint: .top, endPoint: .bottom)
                            }
                    }
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
                        Image(.pixelRefresh)
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
            let apiTopDonor = await TiltifyAPIClient.shared.getCampaignTopDonor(forId: campaign.id)
            let apiDonations = await TiltifyAPIClient.shared.getCampaignDonations(forId: campaign.id)
            withAnimation {
                topDonor = apiTopDonor
                donations = apiDonations
                isRefreshing = false
            }
        }
    }
}
