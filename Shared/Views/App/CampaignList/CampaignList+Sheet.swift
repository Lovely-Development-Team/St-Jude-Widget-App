//
//  CampaignList+Sheet.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/18/25.
//

import SwiftUI

struct CampaignListSheetContent: View {
    var sheet: CampaignListSheet
    @Binding var showSheet: CampaignListSheet?
    @Binding var selectedDestination: CampaignListDestination?
    @Binding var refreshFundraisers: Bool
    
    @State private var tldCampaign: Campaign? = nil
    
    var namespace: Namespace.ID
    
    var body: some View {
        Group {
            switch sheet {
            case .aboutScreen:
                AboutView(tldCampaign: $tldCampaign, selectedDestination: $selectedDestination)
                    .forSheet()
                    .zoomTransitioniOS26(id: "aboutButton", namespace: self.namespace)
            case .leaderBoard:
                Leaderboard() { campaign in
                    showSheet = nil
                    self.selectedDestination = .campaign(campaign, true)
                }
                .forSheet(displayMode: .large)
                .zoomTransitioniOS26(id: "leaderboardButton", namespace: self.namespace)
            case .randomPicker:
                Theme.current.randomCampaignPicker(selectedDestination: self.$selectedDestination)
                    .forSheet()
                    .zoomTransitioniOS26(id: "randomFundraiserButton", namespace: self.namespace)
            case .easterEgg:
                EasterEggView()
                    .forSheet(displayMode: .large)
                    .zoomTransitioniOS26(id: "easterEggButton", namespace: self.namespace)
            case .startHeadToHead:
                ChooseCampaignView() { campaign in
                    showSheet = .continueHeadToHead(campaign: campaign)
                }
                .forSheet(displayMode: .large)
            case let .continueHeadToHead(firstCampaign):
                ChooseCampaignView(otherCampaign: firstCampaign) { otherCampaign in
                    Task {
                        let headToHead = HeadToHead(id: UUID(), campaignId1: firstCampaign.id, campaignId2: otherCampaign.id)
                        do {
                            try await AppDatabase.shared.saveHeadToHead(headToHead)
                        } catch {
                            dataLogger.error("Could not create Head to Head: \(error.localizedDescription)")
                        }
                        self.selectedDestination = .headToHead(HeadToHeadWithCampaigns(headToHead: headToHead, campaign1: firstCampaign, campaign2: otherCampaign))
                    }
                    self.refreshFundraisers = true
                }
                .forSheet(displayMode: .large)
            }
        }
        .onAppear {
            Task {
                self.tldCampaign = try? await AppDatabase.shared.fetchCampaign(with: TLD_CAMPAIGN)
            }
        }
    }
}

enum CampaignListSheet: Identifiable {
    case aboutScreen
    case leaderBoard
    case randomPicker
    case easterEgg
    case startHeadToHead
    case continueHeadToHead(campaign: Campaign)
    
    var id: String {
        switch self {
        case .aboutScreen:
            return "aboutScreen"
        case .leaderBoard:
            return "leaderBoard"
        case .randomPicker:
            return "randomPicker"
        case .easterEgg:
            return "easterEgg"
        case .startHeadToHead:
            return "startHeadToHead"
        case let .continueHeadToHead(campaign):
            return "continueHeadToHead:\(campaign.id.uuidString)"
        }
    }
}
