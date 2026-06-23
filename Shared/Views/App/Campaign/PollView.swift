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
                HStack(alignment: .center) {
                    Text(poll.name)
                        .bold()
                    Spacer()
                    Link(destination: URL(string: "https://donate.tiltify.com/\(campaignId.uuidString)/incentives?pollPublicId=\(poll.id.uuidString.lowercased())")!, label: {
                        Text("Vote!")
                            .font(.caption)
                    })
                    // TODO: padding?
                    .themedButton(type: .primary)
                    .padding(.bottom, 4)
                }
                ForEach(poll.options, id: \.id) { option in
                    VStack {
                        HStack(alignment: .center) {
                            let isMax = option.isMax(parentPoll: poll)
                            Text(option.name)
                                .font(.caption)
                                .foregroundStyle(isMax ? Theme.current.accentColor : .primary)
                            
                            if isMax {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(Theme.current.accentColor)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("\(Int(option.percentageOfPoll(parentPoll: poll) * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(isMax ? Theme.current.accentColor : .primary)
                                Text(option.amountRaised.description(showFullCurrencySymbol: false))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        ProgressBar(value: .constant(Float(option.percentageOfPoll(parentPoll: poll))), fillColor: Theme.current.accentColor)
                            .frame(height: 10)
                    }
                }
            }
        }
        .themedGroupBox(type: .primary)
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
