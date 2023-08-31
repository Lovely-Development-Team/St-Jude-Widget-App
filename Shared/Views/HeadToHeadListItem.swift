//
//  HeadToHeadListItem.swift
//  St Jude
//
//  Created by Ben Cardy on 31/08/2023.
//

import SwiftUI
import Kingfisher

struct HeadToHeadListItem: View {
    
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
                    .foregroundColor(WidgetAppearance.red.foregroundColor)
                Text("vs")
                    .bold()
                    .padding(.all, 4)
                    .background(Circle().fill(Color.white))
                    .foregroundColor(.black)
                    Text(headToHead.campaign2.name)
                        .bold()
                        .multilineTextAlignment(.center)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .foregroundColor(WidgetAppearance.purple.foregroundColor)
            }
            Image(systemName: "crown.fill")
                .imageScale(.large)
                .foregroundColor(.brandYellow)
                .offset(x: leading ? -10 : 10, y: -10)
                .rotationEffect(.degrees(leading ? -10 : 10))
        }
        .padding()
        .background(
            HStack(spacing: 2) {
                Color.brandRed
                Color.brandPurple
            }
            .background(Color.white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    HeadToHeadListItem(headToHead: HeadToHeadWithCampaigns(headToHead: HeadToHead(id: UUID(), campaignId1: nil, campaignId2: nil), campaign1: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "The Lovely Developers for St. Jude 2023", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "160.00"), user: TiltifyUser(username: "TheLovelyDevelopers", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/uploads/user/thumbnail/447696/blob-59ba2e8f-8d1a-4037-bce2-515075a7f6aa.png", height: nil, width: nil), description: "I'm fundraising for St. Jude Children's Research Hospital.")), campaign2: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "Support the Research of Relay FM's Official Historian 📜", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "460.00"), user: TiltifyUser(username: "rhl__", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/uploads/user/thumbnail/312463/blob-d2e2dc23-8ea5-4632-b63b-9ed3a2cdf374.jpeg", height: nil, width: nil), description: "I'm fundraising for St. Jude Children's Research Hospital."))))
}
