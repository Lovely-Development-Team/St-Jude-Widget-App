//
//  PollView.swift
//  St Jude
//
//  Created by Ben Cardy on 23/08/2025.
//

import SwiftUI

struct PollView: View {
    
    let poll: TiltifyCampaignPoll
    let campaignId: UUID
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(poll.name)
                    Spacer()
                    Link(destination: URL(string: "https://donate.tiltify.com/\(campaignId.uuidString)/incentives?pollPublicId=\(poll.id.uuidString.lowercased())")!, label: {
                        Text("Vote!")
                            .foregroundStyle(.black)
                            .font(.caption)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                    })
                    .buttonStyle(BlockButtonStyle(tint: .accentColor, padding: false))
                    .padding(.bottom, 4)
                }
                ForEach(poll.options, id: \.id) { option in
                    VStack {
                        HStack(alignment: .center) {
                            let isMax = option.isMax(parentPoll: poll)
                            
                            Text(option.name)
                                .font(.caption)
                                .foregroundStyle(isMax ? Color.accentColor : .white)
                            
                            if isMax {
                                Image(.crownPixel)
                                    .foregroundStyle(Color.accentColor)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("\(Int(option.percentageOfPoll(parentPoll: poll)))%")
                                    .font(.caption)
                                    .foregroundStyle(isMax ? Color.accentColor : .white)
                                Text(option.amountRaised.description(showFullCurrencySymbol: false))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        ProgressBar(value: option.percentageOfPollBinding(parentPoll: poll, defaultValue: 0.0), fillColor: .accentColor)
                    }
                }
            }
            .padding()
        }
        .groupBoxStyle(BlockGroupBoxStyle(tint: .tertiarySystemBackground, padding: false, shadowColor: nil))
    }
}

#Preview {
    PollView(poll: TiltifyCampaignPoll(active: true, amountRaised: .init(currency: "USD", value: "20"), id: UUID(), insertedAt: "", name: "Poll Name", options: [.init(amountRaised: .init(currency: "USD", value: "0"), id: UUID(), insertedAt: "", name: "Option 1", updatedAt: "")], updatedAt: ""), campaignId: UUID())
}
