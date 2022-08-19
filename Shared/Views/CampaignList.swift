//
//  CampaignList.swift
//  St Jude
//
//  Created by Ben Cardy on 18/08/2022.
//

import SwiftUI

struct FundraiserListItem: View {
    
    let fundraiser: TiltifyCauseCampaign
    
    var body: some View {
        
        GroupBox {
            VStack(alignment: .leading, spacing: 2) {
                Text(fundraiser.name)
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                Text(fundraiser.user.username)
                    .foregroundColor(.secondary)
                Text(fundraiser.totalAmountRaised.description(showFullCurrencySymbol: false))
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                ProgressBar(value: .constant(Float(fundraiser.percentageReached ?? 0)), fillColor: .accentColor)
                    .frame(height: 10)
            }
        }
        .foregroundColor(.primary)
    }
    
}

struct CampaignList: View {
    
    @State private var causeData: TiltifyCauseData? = nil
    @StateObject private var apiClient = ApiClient.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text(causeData?.cause.name ?? "St. Jude Children's Research Hospital")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    //                            .foregroundColor(.white)
                        .opacity(0.8)
                        .padding(.bottom, 2)
                    Text(causeData?.fundraisingEvent.name ?? "Relay FM for St. Jude 2022")
                        .multilineTextAlignment(.leading)
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 20)
                    if let causeData = causeData {
                        if let percentageReached =  causeData.fundraisingEvent.percentageReached {
                            ProgressBar(value: .constant(Float(percentageReached)), fillColor: causeData.fundraisingEvent.colors.highlightColor)
                                .frame(height: 15)
                                .padding(.bottom, 2)
                        }
                        Text(causeData.fundraisingEvent.amountRaised.description(showFullCurrencySymbol: false))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                        if let percentageReachedDesc = causeData.fundraisingEvent.percentageReachedDescription {
                            Text("\(percentageReachedDesc) of \(causeData.fundraisingEvent.goal.description(showFullCurrencySymbol: false))")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                                .opacity(0.8)
                        }
                    } else {
                        ProgressBar(value: .constant(0), fillColor: .accentColor)
                            .frame(height: 15)
                            .padding(.bottom, 2)
                        Text("$123,000")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .redacted(reason: .placeholder)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Text("0% of $400,000")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .redacted(reason: .placeholder)
                        
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(causeData?.fundraisingEvent.colors.backgroundColor ?? Color(red: 13 / 255, green: 39 / 255, blue: 83 / 255))
                .cornerRadius(10)
                .padding()
                
                Link("Visit the fundraiser!", destination: URL(string: "https://stjude.org/relay")!)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(10)
                    .padding(.horizontal, 20)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                //                        .frame(minHeight: 80)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .padding(.bottom)
                
                HStack {
                    Text("Fundraisers")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    if let causeData = causeData {
                        Text("\(causeData.fundraisingEvent.publishedCampaigns.edges.count)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                if let causeData = causeData {
                    
                    ForEach(causeData.fundraisingEvent.publishedCampaigns.edges, id: \.node.publicId) { campaign in
                        NavigationLink(destination: ContentView(vanity: campaign.node.user.slug, slug: campaign.node.slug, user: campaign.node.user.username).navigationTitle(campaign.node.name)) {
                            FundraiserListItem(fundraiser: campaign.node)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    
                } else {
                    
                    Text("Loading ...")
                        .padding(.vertical, 40)
                    
                }
            }
        }
        .onAppear {
            let dataTask1 = apiClient.fetchCause { result in
                switch result {
                case .failure(let error):
                    dataLogger.error("Request failed: \(error.localizedDescription)")
                case .success(let response):
                    causeData = response.data
                }
            }
        }
        .navigationTitle("Relay FM for St. Jude 2022")
    }
}

struct CampaignList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampaignList()
                .navigationBarTitleDisplayMode(.inline)
        }
        //                FundraiserListItem(fundraiser: TiltifyCauseCampaign(publicId: "a", name: "St. Jude Podcastathon support camp f 2022 Sept", slug: "", goal: TiltifyAmount(currency: "GBP", value: "100000"), totalAmountRaised: TiltifyAmount(currency: "GBP", value: "395"), user: TiltifyUser(username: "Jillian Grembowicz", slug: "")))
        //                    .padding()
    }
}
