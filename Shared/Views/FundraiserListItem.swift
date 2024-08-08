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
    var showBackground: Bool = true
    @Binding var showShareSheet: Bool
    
    let sortOrdersShowingPercentage: [FundraiserSortOrder] = [.byGoal, .byPercentage]
    
    @State var showShareLinkSheet: ShareURL? = nil
    
    @ViewBuilder
    var disclosureIndicator: some View {
        if(campaign.isStarred) {
            Image(systemName: "star.fill")
        } else {
            Image(.pixelChevronRight)
        }
    }
    
//    var disclosureIndicatorIcon: String {
//        if campaign.isStarred {
//            return "star.fill"
//        }
//        return "chevron.right"
//    }
    
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
//                .cornerRadius(5)
                .modifier(PixelRounding())
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var contents: some View {
        Group {
            if compact {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(campaign.title)
                            .lineLimit(1)
                            .font(.headline)
                        if showDisclosureIndicator {
                            Spacer()
//                            Image(systemName: disclosureIndicatorIcon)
                            self.disclosureIndicator
                                .foregroundColor(campaign.isStarred ? .accentColor : .secondary)
                        }
                    }
                    HStack {
                        if sortOrdersShowingPercentage.contains(sortOrder), let percentageReachedDesc = campaign.percentageReachedDescription {
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
//                            Image(systemName: disclosureIndicatorIcon)
                            self.disclosureIndicator
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
                    if sortOrdersShowingPercentage.contains(sortOrder), let percentageReachedDesc = campaign.percentageReachedDescription {
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
    }
    
    var body: some View {
        if(self.showBackground) {
            GroupBox {
                self.contents
            }
                .groupBoxStyle(BlockGroupBoxStyle())
        } else {
            self.contents
        }
    }
}
