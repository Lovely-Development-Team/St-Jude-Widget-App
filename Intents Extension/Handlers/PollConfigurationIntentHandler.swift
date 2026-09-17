//
//  PollConfigurationIntentHandler.swift
//  Intents Extension
//
//  Created by Justin Hamilton on 9/12/26.
//

import Foundation
import Intents

class PollConfigurationIntentHandler: NSObject, PollConfigurationIntentHandling {
    func resolveAppearance(for intent: PollConfigurationIntent) async -> WidgetAppearanceResolutionResult {
        return .success(with: intent.appearance)
    }
    
    func resolvePoll(for intent: PollConfigurationIntent) async -> WidgetPollResolutionResult {
        guard let poll = intent.poll else {
            return .notRequired()
        }
        
        return .success(with: poll)
    }
    
    func providePollOptionsCollection(for intent: PollConfigurationIntent) async throws -> INObjectCollection<WidgetPoll> {
        
        let teamEventPolls = try await AppDatabase.shared.fetchPollsForTeamEvent()
        let campaignPolls = try await AppDatabase.shared.fetchPollsForStarredCampaigns()
        
        var pollCampaignNames: [UUID: String] = [:]
        for poll in teamEventPolls + campaignPolls {
            pollCampaignNames[poll.id] = await poll.parentCampaignName()
        }
        
        let widgetPolls: [WidgetPoll] = ([] + teamEventPolls + campaignPolls).map { poll in
            let widgetPoll = WidgetPoll(identifier: poll.id.uuidString, display: poll.name, subtitle: pollCampaignNames[poll.id], image: nil)
            widgetPoll.parentCampaignId = poll.campaignId?.uuidString
            widgetPoll.parentTeamEventId = poll.teamEventId?.uuidString
            return widgetPoll
        }
        
        return INObjectCollection(items: widgetPolls)
    }
}

class PollLockScreenConfigurationIntentHandler: NSObject, PollLockScreenConfigurationIntentHandling {
    func resolvePoll(for intent: PollLockScreenConfigurationIntent) async -> WidgetPollResolutionResult {
        guard let poll = intent.poll else {
            return .notRequired()
        }
        
        return .success(with: poll)
    }
    
    func providePollOptionsCollection(for intent: PollLockScreenConfigurationIntent) async throws -> INObjectCollection<WidgetPoll> {
        
        let teamEventPolls = try await AppDatabase.shared.fetchPollsForTeamEvent()
        let campaignPolls = try await AppDatabase.shared.fetchPollsForStarredCampaigns()
        
        var pollCampaignNames: [UUID: String] = [:]
        for poll in teamEventPolls + campaignPolls {
            pollCampaignNames[poll.id] = await poll.parentCampaignName()
        }
        
        let widgetPolls: [WidgetPoll] = ([] + teamEventPolls + campaignPolls).map { poll in
            let widgetPoll = WidgetPoll(identifier: poll.id.uuidString, display: poll.name, subtitle: pollCampaignNames[poll.id], image: nil)
            widgetPoll.parentCampaignId = poll.campaignId?.uuidString
            widgetPoll.parentTeamEventId = poll.teamEventId?.uuidString
            return widgetPoll
        }
        
        return INObjectCollection(items: widgetPolls)
    }
}
