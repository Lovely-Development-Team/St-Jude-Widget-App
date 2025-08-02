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
    
    @State private var showShareLinkSheet: ShareURL? = nil
    @AppStorage(UserDefaults.disableCombosKey, store: UserDefaults.shared) var disableCombos: Bool = false
    
    @ViewBuilder
    var disclosureIndicator: some View {
        if(campaign.isStarred) {
            Image(systemName: "heart.fill")
        } else {
            Image(systemName: "chevron.right")
        }
    }
    
//    var disclosureIndicatorIcon: String {
//        if campaign.isStarred {
//            return "star.fill"
//        }
//        return "chevron.right"
//    }
    
    
    var barColor: Color {
        if(self.campaign.multiplier % 2 == 0) {
            return .accentColor
        } else {
            return .brandYellow
        }
    }
    
    var fillColor: Color {
        if(self.campaign.multiplier % 2 == 0) {
            return .brandYellow
        } else {
            return .accentColor
        }
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
    
    @ViewBuilder
    var contents: some View {
        Group {
            if compact {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(campaign.title)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .font(.headline)
                        if showDisclosureIndicator {
                            Spacer()
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
                            .foregroundStyle(.primary)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .top) {
                        image()
                        VStack(alignment: .leading, spacing: 2) {
                            // TODO: [DETHEMING] Why is some of the text in this view set to the accent color??
                            Text(campaign.title)
                                .multilineTextAlignment(.leading)
                                .font(.headline)
                            Text(campaign.user.name)
                                .foregroundColor(.secondary)
                        }
                        if showDisclosureIndicator {
                            Spacer()
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
                    if let progressBarAmount = campaign.progressBarAmount {
                        HStack {
                            if self.campaign.multiplier > 1 && !UserDefaults.shared.disableCombos {
                                Text("\(self.campaign.multiplier)x")
                                    .font(.headline)
                                ProgressBar(value: .constant(Float(progressBarAmount)), barColour: barColor, fillColor: fillColor)
                                    .frame(height: 10)
                            } else {
                                ProgressBar(value: .constant(Float(progressBarAmount)), fillColor: .accentColor)
                                    .frame(height: 10)
                            }
                        }
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
        } else {
            self.contents
        }
    }
}
