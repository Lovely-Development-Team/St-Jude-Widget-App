//
//  CampaignView.swift
//  St Jude
//
//  Created by Ben Cardy on 25/08/2022.
//

import SwiftUI

struct CampaignView: View {
    
    let initialCampaign: Campaign
    @State private var campaign: TiltifyCampaign? = nil
    
    var fundraiserURL: URL {
        URL(string: "https://tiltify.com/@\(initialCampaign.user.slug)/\(initialCampaign.slug)")!
    }
    
    var sortedRewards: [TiltifyCampaignReward] {
        campaign?.rewards.sorted {
            $0.amount.numericalValue < $1.amount.numericalValue
        } ?? []
    }
    
    var sortedMilestones: [TiltifyMilestone] {
        campaign?.milestones.sorted {
            $0.amount.numericalValue < $1.amount.numericalValue
        } ?? []
    }
    
    var body: some View {
        ScrollView {
            
            ScrollViewReader { scrollViewReader in
                
                FundraiserListItem(campaign: initialCampaign, sortOrder: .byGoal, showDisclosureIndicator: false)
                
                if let campaign = campaign, !campaign.milestones.isEmpty && !campaign.rewards.isEmpty {
                    
                    LazyVGrid(columns: [GridItem(.flexible()),
                                        GridItem(.flexible())]) {
                        Button(action: {
                            withAnimation {
                                scrollViewReader.scrollTo("Milestones", anchor: .top)
                            }
                        }) {
                            GroupBox {
                                HStack {
                                    Spacer()
                                    Text("\(campaign.milestones.count) Milestones")
                                    Spacer()
                                }
                            }
                        }
                        Button(action: {
                            withAnimation {
                                scrollViewReader.scrollTo("Rewards", anchor: .top)
                            }
                        }) {
                            GroupBox {
                                HStack {
                                    Spacer()
                                    Text("\(campaign.rewards.count) Rewards")
                                    Spacer()
                                }
                            }
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    
                }
                
                Link("Visit the fundraiser!", destination: fundraiserURL)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(10)
                    .padding(.horizontal, 20)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .padding(.top)
                
                if let campaign = campaign {
                    
                    Text(campaign.description)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical)
                    
                    if !campaign.milestones.isEmpty {
                        Text("Milestones")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .id("Milestones")
                        
                        ForEach(sortedMilestones, id: \.id) { milestone in
                            HStack(alignment: .top) {
                                Text(milestone.name)
                                Spacer()
                                Text(milestone.amount.description(showFullCurrencySymbol: false))
                                    .foregroundColor(.accentColor)
                            }
                            .padding(.vertical, 8)
                            Divider()
                        }
                        
                    }
                    
                    if !campaign.rewards.isEmpty {
                        
                        Text("Rewards")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.top, campaign.milestones.isEmpty ? 0 : 10)
                            .id("Rewards")
                        
                        ForEach(sortedRewards, id: \.id) { reward in
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    Text(reward.name)
                                    Spacer()
                                    Text(reward.amount.description(showFullCurrencySymbol: false))
                                        .foregroundColor(.accentColor)
                                }
                                .font(.headline)
                                HStack(alignment: .top) {
                                    if let url = URL(string: reward.image?.src ?? "") {
                                        AsyncImage(
                                            url: url,
                                            content: { image in
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 45, height: 45)
                                            },
                                            placeholder: {
                                                ProgressView()
                                                    .frame(width: 45, height: 45)
                                            }
                                        )
                                        .cornerRadius(5)
                                    }
                                    Text(reward.description)
                                        .font(.caption)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(.vertical, 8)
                            Divider()
                        }
                        
                    }
                    
                } else {
                    
                    ProgressView()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                        .padding(.bottom, 10)
                    Text("Loading ...")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 40)
                    
                }
                
            }
            .padding()
        }
        .onAppear {
            ApiClient.shared.fetchCampaign(vanity: initialCampaign.user.slug, slug: initialCampaign.slug) { result in
                switch result {
                case .failure(let error):
                    dataLogger.error("Request failed: \(error.localizedDescription)")
                case .success(let response):
                    self.campaign = response.data.campaign
                }
            }
        }
        .navigationTitle(initialCampaign.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CampaignView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampaignView(initialCampaign: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "Relay FM for St. Jude 2022", slug: "relay-fm-for-st-jude-2022", goal: TiltifyAmount(currency: "USD", value: "444444.44"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "6023.06"), user: TiltifyUser(username: "Relay FM", slug: "relay-fm", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/uploads/user/thumbnail/152503/c931ec4a-7f09-4048-b6d5-01875c6d618a.jpeg", height: nil, width: nil)), description: "Every September, the Relay FM community of podcasters and listeners rallies together to support the lifesaving mission of St. Jude Children’s Research Hospital during Childhood Cancer Awareness Month. Throughout the month, Relay FM will introduce ways to support St. Jude through entertaining donation challenges and other mini-fundraising events that will culminate in the third annual Relay for St. Jude Podcastathon on September 16th beginning at 12pm Eastern at twitch.tv/relayfm."), fundraiserId: UUID()))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Label("Back", systemImage: "chevron.left")
                    }
                }
        }
    }
}
