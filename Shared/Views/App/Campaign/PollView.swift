//
//  PollView.swift
//  St Jude
//
//  Created by Ben Cardy on 23/08/2025.
//

import SwiftUI

struct PollView: View {
    
    let poll: Poll
    @State private var pollOptions: [PollOption] = []
    let campaignId: UUID?
    var showParentCampaignInfo: Bool = false
    @State private var parentCampaign: Campaign? = nil
    @State private var parentTeamEvent: TeamEvent? = nil
    @State private var showShareView: Bool = false
    @State private var shareLinkActivityItems: [Any]? = nil
    
    var body: some View {
        Group {
            if let campaignId = self.campaignId {
                GroupBox {
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                if self.showParentCampaignInfo {
                                    if let parentCampaign = self.parentCampaign {
                                        Text(parentCampaign.name)
                                            .font(.title3)
                                            .bold()
                                    } else if let parentTeamEvent = self.parentTeamEvent {
                                        Text(parentTeamEvent.name)
                                            .font(.title3)
                                            .bold()
                                    }
                                }
                                Text(poll.name)
                                    .bold()
                            }
                            Spacer()
                            Menu {
                                Button(action: {
                                    self.showShareView = true
                                }) {
                                    Label("Share Image", systemImage: "photo")
                                }
                                if let url = self.poll.pollURL {
                                    Button(action: {
                                        shareLinkActivityItems = [url]
                                    }) {
                                        Label("Share Poll Link", systemImage: "link")
                                    }
                                }
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .labelStyle(.iconOnly)
                            }
                            .background {
                                ShareSheetPresenter(activityItems: $shareLinkActivityItems)
                            }
                        }
                        ForEach(self.pollOptions) { option in
                            VStack {
                                HStack(alignment: .center) {
                                    let isMax = option.isMax(parentPoll: poll, options: self.pollOptions)
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
                        if let url = self.poll.pollURL {
                            Link(destination: url, label: {
                                Text("Vote!")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                            })
                            .themedButton(type: .primary, id: "pollVoteButton-\(campaignId.uuidString)")
                            .padding(.top)
                        }
                    }
                }
                .themedGroupBox(type: .primary, id: poll.id)
            }
        }
        .sheet(isPresented: self.$showShareView) {
            SharePollView(poll: self.poll, options: self.pollOptions, parentCampaign: self.parentCampaign, parentTeamEvent: self.parentTeamEvent)
                .forSheet()
        }
        .task {
            do {
                let fetchedPollOptions = try await AppDatabase.shared.fetchPollOptions(for: self.poll)
                withAnimation {
                    self.pollOptions = fetchedPollOptions
                }
                
            } catch {
                dataLogger.error("Could not fetch poll options for poll id \(self.poll.id): \(error.localizedDescription)")
            }
            
            do {
                // Attempt to get the parent campaign, fallback to team event
                if let parentCampaign = try await AppDatabase.shared.fetchParentCampaign(for: self.poll) {
                    self.parentCampaign = parentCampaign
                } else if let parentTeamEvent = try await AppDatabase.shared.fetchParentTeamEvent(for: self.poll) {
                    self.parentTeamEvent = parentTeamEvent
                }
            } catch {
                dataLogger.error("Failed to fetch parent campaign of poll: \(self.poll.name): \(error.localizedDescription)")
            }
        }
    }
}

// im too tired to add this back
//struct PollViewPreview: View {
//    @State private var option1Value: Double = 20
//    @State private var option2Value: Double = 10
//    @State private var option3Value: Double = 5
//    
//    var totalValue: Double {
//        return self.option1Value + self.option2Value + self.option3Value
//    }
//    
//    var body: some View {
//        VStack {
//            PollView(poll: TiltifyCampaignPoll(active: true, amountRaised: .init(currency: "USD", value: "\(self.totalValue)"), id: UUID(), insertedAt: "", name: "Poll Name", options: [
//                .init(amountRaised: .init(currency: "USD", value: "\(self.option1Value)"), id: UUID(), insertedAt: "", name: "Option 1", updatedAt: ""),
//                .init(amountRaised: .init(currency: "USD", value: "\(self.option2Value)"), id: UUID(), insertedAt: "", name: "Option 2", updatedAt: ""),
//                .init(amountRaised: .init(currency: "USD", value: "\(self.option3Value)"), id: UUID(), insertedAt: "", name: "Option 3", updatedAt: "")
//            ], updatedAt: ""), campaignId: UUID())
//                .frame(height: 300)
//            
//        }
//        
//        GroupBox {
//            Text("Option 1")
//            Slider(value: self.$option1Value, in: 0...100)
//        }
//        
//        GroupBox {
//            Text("Option 2")
//            Slider(value: self.$option2Value, in: 0...100)
//        }
//        
//        GroupBox {
//            Text("Option 3")
//            Slider(value: self.$option3Value, in: 0...100)
//        }
//    }
//}
//
//#Preview {
//    PollViewPreview()
//}
