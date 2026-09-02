//
//  CampaignRewardView.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/10/25.
//

import SwiftUI
import Kingfisher

struct CampaignRewardView: View {
    var reward: Reward
    var campaignUserName: String
    @Binding var showSupporterSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(self.reward.name)
                    .font(.headline)
                Spacer()
                Text(self.reward.amount.description(showFullCurrencySymbol: false))
                    .foregroundColor(Theme.current.accentColor)
            }
            HStack(alignment: .top) {
                if let url = URL(string: self.reward.imageSrc ?? "") {
                    NavigationLink(destination: {
                        FullSizeImageView(imageUrl: url)
                    }, label: {
                        KFImage.url(url)
                            .resizable()
                            .placeholder {
                                ProgressView()
                                    .frame(width: 45, height: 45)
                            }.aspectRatio(contentMode: .fit)
                            .frame(width: 45, height: 45)
                    })
                }
                HStack(alignment: .top) {
                    VStack {
                        Text(self.reward.description)
                            .font(.caption)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        if let quantity = self.reward.quantity,
                           let quantityRemaining = self.reward.quantityRemaining {
                            HStack {
                                Text("\(quantityRemaining) of \(quantity) available!")
                                    .font(.caption)
                                    .foregroundStyle(Theme.current.accentColor)
                                Spacer()
                            }
                        }
                    }
                    if self.campaignUserName == "TheLovelyDevelopers" && self.reward.name.contains("App Supporter") {
                        Spacer()
                        Button(action: {
                            self.showSupporterSheet = true
                        }, label: {
                            Text("Supporters")
                                .font(.headline)
                        })
                        .themedButton(type: .primary, id: "supporters")
                    }
                }
            }
            
        }
    }
}
