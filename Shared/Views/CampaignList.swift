//
//  CampaignList.swift
//  St Jude
//
//  Created by Ben Cardy on 18/08/2022.
//

import SwiftUI

struct CampaignList: View {
    
    @State private var causeData: TiltifyCauseData? = nil
    @StateObject private var apiClient = ApiClient.shared
    
    var body: some View {
        Group {
            if let causeData = causeData {
                List {
                    VStack(spacing: 0) {
                        Text(causeData.cause.name)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            .foregroundColor(.white)
                            .opacity(0.8)
                            .padding(.bottom, 2)
                        Text(causeData.fundraisingEvent.name)
                            .multilineTextAlignment(.leading)
                            .font(.headline)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 20)
                        if let percentageReached =  causeData.fundraisingEvent.percentageReached {
                            ProgressBar(value: .constant(Float(percentageReached)), fillColor: causeData.fundraisingEvent.colors.backgroundColor)
                                .frame(height: 15)
                                .padding(.bottom, 2)
                        }
                        Text(causeData.fundraisingEvent.amountRaised.description(showFullCurrencySymbol: false))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        if let percentageReachedDesc = causeData.fundraisingEvent.percentageReachedDescription {
                            Text("\(percentageReachedDesc) of \(causeData.fundraisingEvent.goal.description(showFullCurrencySymbol: false))")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .opacity(0.8)
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
//                    .background(LinearGradient(colors: [
//                        Color(.sRGB, red: 43 / 255, green: 54 / 255, blue: 61 / 255, opacity: 1),
//                        Color(.sRGB, red: 51 / 255, green: 63 / 255, blue: 72 / 255, opacity: 1)
//                    ], startPoint: .bottom, endPoint: .top))
                    .background(causeData.fundraisingEvent.colors.highlightColor)
                    .cornerRadius(10)
                    
                    Link("Visit the fundraiser!", destination: URL(string: "https://stjude.org/relay")!)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                        .padding(.horizontal, 20)
                        .background(causeData.fundraisingEvent.colors.backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                        .frame(minHeight: 80)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    
                    ForEach(causeData.fundraisingEvent.publishedCampaigns.edges, id: \.node.publicId) { campaign in
                        NavigationLink(destination: ContentView(vanity: campaign.node.user.slug, slug: campaign.node.slug, user: campaign.node.user.username)) {
                            VStack(alignment: .leading) {
                                Text(campaign.node.name)
                                    .font(.headline)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                HStack(alignment: .top) {
                                    Text(campaign.node.user.username)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(campaign.node.totalAmountRaised.description(showFullCurrencySymbol: false))
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
//                .listRowSeparator(.hidden)
            } else {
                Text("Loading...")
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
    }
}

struct CampaignList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampaignList()
        }
    }
}
