//
//  FundraiserListItem.swift
//  St Jude
//
//  Created by Ben Cardy on 24/08/2022.
//

import SwiftUI
import Kingfisher

struct ShareURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct FundraiserListItem: View {
    
    let campaign: Campaign
    let sortOrder: FundraiserSortOrder
    var showDisclosureIndicator: Bool = true
    var compact: Bool = false
    var showShareIcon: Bool = false
    @Binding var showShareSheet: Bool
    
    let sortOrdersShowingPercantage: [FundraiserSortOrder] = [.byGoal, .byPercentage]
    
    @State var showShareLinkSheet: ShareURL? = nil
    
    var disclosureIndicatorIcon: String {
        if campaign.isStarred {
            return "star.fill"
        }
        return "chevron.right"
    }
    
    @ViewBuilder
    func image(size: CGFloat = 45) -> some View {
        if let url = URL(string: campaign.avatar?.src ?? "") {
            KFImage.url(url)
                .resizable()
                .placeholder {
                    ProgressView()
                        .frame(width: size, height: size)
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .cornerRadius(5)
        } else {
            EmptyView()
        }
    }
    
    var body: some View {
        GroupBox {
            if compact {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(campaign.title)
                            .lineLimit(1)
                            .font(.headline)
                        if showDisclosureIndicator {
                            Spacer()
                            Image(systemName: disclosureIndicatorIcon)
                                .foregroundColor(campaign.isStarred ? .accentColor : .secondary)
                        }
                    }
                    HStack {
                        if sortOrdersShowingPercantage.contains(sortOrder), let percentageReachedDesc = campaign.percentageReachedDescription {
                            Text("\(percentageReachedDesc) of \(campaign.goalDescription(showFullCurrencySymbol: false))")
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        } else if sortOrder == .byAmountRemaining && campaign.goalNumerical - campaign.totalRaisedNumerical > 0 {
                                Text("\(campaign.amountRemainingDescription) until \(campaign.goalDescription(showFullCurrencySymbol: false))")
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                        } else {
                            Text(campaign.user.name)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(campaign.totalRaisedDescription(showFullCurrencySymbol: false))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .layoutPriority(1)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .top) {
                        image()
                        VStack(alignment: .leading, spacing: 2) {
                            Text(campaign.title)
                                .multilineTextAlignment(.leading)
                                .font(.headline)
                            Text(campaign.user.name)
                                .foregroundColor(.secondary)
                        }
                        if showDisclosureIndicator {
                            Spacer()
                            Image(systemName: disclosureIndicatorIcon)
                                .foregroundColor(campaign.isStarred ? .accentColor : .secondary)
                        } else if showShareIcon {
                            Spacer()
                            Menu {
                                Button(action: {
                                    showShareSheet = true
                                }) {
                                    Label("Share Image", systemImage: "photo")
                                }
                                Button(action: {
                                    showShareLinkSheet = ShareURL(url: campaign.url)
                                }) {
                                    Label("Share Fundraiser Link", systemImage: "link")
                                }
                                Button(action: {
                                    showShareLinkSheet = ShareURL(url: campaign.directDonateURL)
                                }) {
                                    Label("Share Direct Donation Link", systemImage: "dollarsign")
                                }
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                    Text(campaign.totalRaisedDescription(showFullCurrencySymbol: false))
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    if let percentageReached = campaign.percentageReached {
                        ProgressBar(value: .constant(Float(percentageReached)), fillColor: .accentColor)
                            .frame(height: 10)
                    }
                    if sortOrdersShowingPercantage.contains(sortOrder), let percentageReachedDesc = campaign.percentageReachedDescription {
                        Text("\(percentageReachedDesc) of \(campaign.goalDescription(showFullCurrencySymbol: false))")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 2)
                    }
                    if sortOrder == .byAmountRemaining && campaign.goalNumerical - campaign.totalRaisedNumerical > 0 {
                        Text("\(campaign.amountRemainingDescription) until \(campaign.goalDescription(showFullCurrencySymbol: false))")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 2)
                    }
                }
                .sheet(item: $showShareLinkSheet) { url in
                    ShareSheetView(activityItems: [url.url])
                }
            }
        }
        .foregroundColor(.primary)
    }
}

//struct FundraiserListItem_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            FundraiserListItem(campaign: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "Aaron's Campaign for St Jude", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "294.00"), user: TiltifyUser(username: "agmcleod", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), description: "I'm fundraising for St. Jude Children's Research Hospital.")), sortOrder: .byName, showShareSheet: .constant(false))
//            FundraiserListItem(campaign: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "Aaron's Campaign for St Jude", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "294.00"), user: TiltifyUser(username: "agmcleod", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), description: "I'm fundraising for St. Jude Children's Research Hospital.")), sortOrder: .byName, compact: true, showShareSheet: .constant(false))
//        }
//        .padding()
//    }
//}
