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
                                Text("\(Int(option.percentageOfPoll(parentPoll: poll) * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(isMax ? Color.accentColor : .white)
                                Text(option.amountRaised.description(showFullCurrencySymbol: false))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        ProgressBar(value: .constant(Float(option.percentageOfPoll(parentPoll: poll))), fillColor: .accentColor)
                    }
                }
            }
            .padding()
        }
        .groupBoxStyle(BlockGroupBoxStyle(tint: .tertiarySystemBackground, padding: false, shadowColor: nil))
    }
}

struct PollViewPreview: View {
    @State private var option1Value: Double = 20
    @State private var option2Value: Double = 10
    @State private var option3Value: Double = 5
    
    var totalValue: Double {
        return self.option1Value + self.option2Value + self.option3Value
    }
    
    var body: some View {
        VStack {
            PollView(poll: TiltifyCampaignPoll(active: true, amountRaised: .init(currency: "USD", value: "\(self.totalValue)"), id: UUID(), insertedAt: "", name: "Poll Name", options: [
                .init(amountRaised: .init(currency: "USD", value: "\(self.option1Value)"), id: UUID(), insertedAt: "", name: "Option 1", updatedAt: ""),
                .init(amountRaised: .init(currency: "USD", value: "\(self.option2Value)"), id: UUID(), insertedAt: "", name: "Option 2", updatedAt: ""),
                .init(amountRaised: .init(currency: "USD", value: "\(self.option3Value)"), id: UUID(), insertedAt: "", name: "Option 3", updatedAt: "")
            ], updatedAt: ""), campaignId: UUID())
                .frame(height: 300)
            
        }
        
        GroupBox {
            Text("Option 1")
            Slider(value: self.$option1Value, in: 0...100)
        }
        
        GroupBox {
            Text("Option 2")
            Slider(value: self.$option2Value, in: 0...100)
        }
        
        GroupBox {
            Text("Option 3")
            Slider(value: self.$option3Value, in: 0...100)
        }
    }
}

#Preview {
    PollViewPreview()
}
