//
//  FundraiserListItem.swift
//  St Jude
//
//  Created by Ben Cardy on 24/08/2022.
//

import SwiftUI

struct FundraiserListItem: View {
    
    let campaign: Campaign
    let sortOrder: FundraiserSortOrder
    var showDisclosureIndicator: Bool = true
    
    var disclosureIndicatorIcon: String {
        if campaign.title == "Relay FM" {
            return "pin"
        }
        if campaign.isStarred {
            return "star.fill"
        }
        return "chevron.right"
    }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .top) {
                    if let url = URL(string: campaign.avatar?.src ?? "") {
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
                            .foregroundColor(.secondary)
                    }
                }
                Text(campaign.totalRaised.description(showFullCurrencySymbol: false))
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                if let percentageReached = campaign.percentageReached {
                    ProgressBar(value: .constant(Float(percentageReached)), fillColor: .accentColor)
                        .frame(height: 10)
                }
                if sortOrder == .byGoal || sortOrder == .byPercentage, let percentageReachedDesc = campaign.percentageReachedDescription {
                    Text("\(percentageReachedDesc) of \(campaign.goal.description(showFullCurrencySymbol: false))")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 2)
                }
            }
        }
        .foregroundColor(.primary)
    }
}
