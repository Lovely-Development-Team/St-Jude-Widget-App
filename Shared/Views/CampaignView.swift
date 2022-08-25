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
                                if milestone.amount.numericalValue <= campaign.totalAmountRaised.numericalValue {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                                Text("\(milestone.name)")
                                    .foregroundColor(milestone.amount.numericalValue <= campaign.totalAmountRaised.numericalValue ? .secondary : .primary)
                                Spacer()
                                Text(milestone.amount.description(showFullCurrencySymbol: false))
                                    .foregroundColor(.accentColor)
                                    .opacity(milestone.amount.numericalValue <= campaign.totalAmountRaised.numericalValue ? 0.75 : 1)
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
                                        .font(.headline)
                                    Spacer()
                                    Text(reward.amount.description(showFullCurrencySymbol: false))
                                        .foregroundColor(.accentColor)
                                }
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
            CampaignView(initialCampaign: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "Aaron's Campaign for St Jude", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "294.00"), user: TiltifyUser(username: "agmcleod", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), description: "I'm fundraising for St. Jude Children's Research Hospital."), fundraiserId: UUID()))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Label("Back", systemImage: "chevron.left")
                    }
                }
        }
    }
}
