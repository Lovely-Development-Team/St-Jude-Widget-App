//
//  HeadToHeadListItem.swift
//  St Jude
//
//  Created by Ben Cardy on 31/08/2023.
//

import SwiftUI
import Kingfisher

struct HeadToHeadListItem: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024 = false
    
    var headToHead: HeadToHeadWithCampaigns
    
    var leading: Bool {
        headToHead.campaign1.totalRaisedNumerical > headToHead.campaign2.totalRaisedNumerical
    }
    
    var body: some View {
        ZStack(alignment: leading ? .topLeading : .topTrailing) {
            HStack {
                    Text(headToHead.campaign1.name)
                        .bold()
                        .multilineTextAlignment(.center)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .foregroundColor(HEAD_TO_HEAD_COLOR_1.foregroundColor)
                Text("vs")
                    .bold()
                    .padding(8)
                    .foregroundColor(.white)
                    .background {
                        Color.black
                            .clipShape(.capsule)
                    }
                    Text(headToHead.campaign2.name)
                        .bold()
                        .multilineTextAlignment(.center)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .foregroundColor(HEAD_TO_HEAD_COLOR_2.foregroundColor)
            }
            
            Image(systemName:"crown.fill")
                .foregroundStyle(Color.brandYellow)
                .padding([.all], 5)
                .background {
                    Color.black
                        .clipShape(.capsule)
                }
                .offset(x: leading ? -23 : 23, y: -25)
        }
        .compositingGroup()
        .padding()
        .background(
            HStack(spacing: 4) {
                Rectangle().fill(HEAD_TO_HEAD_COLOR_1.backgroundColors[0])
                Rectangle().fill(HEAD_TO_HEAD_COLOR_2.backgroundColors[0])
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        )
    }
}

#Preview {
    Button(action: {}, label: {
        HeadToHeadListItem(headToHead: HeadToHeadWithCampaigns(headToHead: HeadToHead(id: UUID(), campaignId1: nil, campaignId2: nil), campaign1: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "The Lovely Developers for St. Jude 2023", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "160.00"), user: TiltifyUser(username: "TheLovelyDevelopers", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/uploads/user/thumbnail/447696/blob-59ba2e8f-8d1a-4037-bce2-515075a7f6aa.png", height: nil, width: nil), description: "I'm fundraising for St. Jude Children's Research Hospital.")), campaign2: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "Support the Research of Relay's Official Historian 📜", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "460.00"), user: TiltifyUser(username: "rhl__", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/uploads/user/thumbnail/312463/blob-d2e2dc23-8ea5-4632-b63b-9ed3a2cdf374.jpeg", height: nil, width: nil), description: "I'm fundraising for St. Jude Children's Research Hospital."))))
            .padding()
    })
}
