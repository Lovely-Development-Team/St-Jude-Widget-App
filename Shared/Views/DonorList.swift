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
                
                VStack(spacing: 0) {
                    Spacer()
                    AdaptiveImage.groundRepeatable(colorScheme: self.colorScheme)
                        .tiledImageAtScale(axis: .horizontal)
                }
                .overlay(alignment: .bottom) {
                    HStack {
                        TappableCoin(easterEggEnabled2024: self.easterEggEnabled2024)
                        TappableCoin(easterEggEnabled2024: self.easterEggEnabled2024)
                        TappableCoin(easterEggEnabled2024: self.easterEggEnabled2024)
                        TappableCoin(easterEggEnabled2024: self.easterEggEnabled2024)
                        TappableCoin(easterEggEnabled2024: self.easterEggEnabled2024)
                        TappableCoin(easterEggEnabled2024: self.easterEggEnabled2024)
                        TappableCoin(easterEggEnabled2024: self.easterEggEnabled2024)
                        TappableCoin(easterEggEnabled2024: self.easterEggEnabled2024)
                        TappableCoin(easterEggEnabled2024: self.easterEggEnabled2024)
                        TappableCoin(easterEggEnabled2024: self.easterEggEnabled2024)
                        TappableCoin(easterEggEnabled2024: self.easterEggEnabled2024)
                    }
                    .padding(.bottom, Double.spriteScale * 100)
                }
                .frame(minHeight: 100)
                .background {
                    SkyView()
                        .mask {
                            LinearGradient(stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .white, location: 0.25),
                                .init(color: .white, location: 1)
                            ], startPoint: .top, endPoint: .bottom)
                        }
                }
                .background {
                    Color(uiColor: .systemBackground)
                }
                
                VStack {
                    
                    Link(destination: URL(string: "https://tiltify.com/@\(campaign.user.slug)/\(campaign.slug)")!) {
                        HStack {
                            Text("View all donors on Tiltify")
                            Spacer()
                            Image(.boxArrowUpRightPixel)
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
            .background {
                GeometryReader { geometry in
                    AdaptiveImage(colorScheme: self.colorScheme, light: .undergroundRepeatable, dark: .undergroundRepeatableNight)
                        .tiledImageAtScale(scale: Double.spriteScale)
                        .frame(height:geometry.size.height + 1000)
                        .animation(.none, value: UUID())
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
