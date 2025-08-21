//
//  WidgetDataProviding.swift
//  WidgetDataProviding
//
//  Created by David on 25/08/2021.
//

import Foundation
import WidgetKit

protocol WidgetDataProviding: IntentTimelineProvider { }

extension WidgetDataProviding {
    internal func fetchStoredData(for campaignId: UUID) async -> TiltifyWidgetData? {
        do {
            dataLogger.notice("Attempting to fetch stored data")
            guard let campaign = try await AppDatabase.shared.fetchCampaign(with: campaignId) else {
                dataLogger.notice("No stored data found")
                return nil
            }
            return try await TiltifyWidgetData(from: campaign)
        } catch {
            dataLogger.error("Failed to retrieve stored data for placeholder: \(error.localizedDescription)")
            return nil
        }
    }
    
    internal func storeData(_ data: TiltifyWidgetData) {
        do {
            UserDefaults.shared.set(try JSONEncoder().encode(data), forKey: "relayData")
        } catch {
            dataLogger.error("Failed to store API response: \(error.localizedDescription)")
        }
    }
}

// Converted to TiltifyAPIClient
extension WidgetDataProviding {
    
    internal func fetchPlaceholder(in context: Context) -> SimpleEntry {
        if let data = UserDefaults.shared.data(forKey: "relayData") {
            do {
                let campaign = try JSONDecoder().decode(TiltifyWidgetData.self, from: data)
                return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: campaign)
            } catch {
                dataLogger.error("Failed to retrieve stored data for placeholder: \(error.localizedDescription)")
            }
        }
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: sampleCampaign)
    }
    
    internal func fetchPlaceholder(in context: Context) -> CampaignLockScreenEventEntry {
        if let data = UserDefaults.shared.data(forKey: "relayData") {
            do {
                let campaign = try JSONDecoder().decode(TiltifyWidgetData.self, from: data)
                return CampaignLockScreenEventEntry(date: Date(), configuration: CampaignLockScreenConfigurationIntent(), campaign: campaign)
            } catch {
                dataLogger.error("Failed to retrieve stored data for placeholder: \(error.localizedDescription)")
            }
        }
        return CampaignLockScreenEventEntry(date: Date(), configuration: CampaignLockScreenConfigurationIntent(), campaign: sampleCampaign)
    }
    
    // Converted to TiltifyAPIClient
    internal func fetchSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            if let campaignData = await TiltifyAPIClient.shared.getCampaignWithMilestones(forId: TEAM_EVENT_ID) {
                let widgetData = TiltifyWidgetData(from: campaignData)
                let entry = SimpleEntry(date: Date(), configuration: configuration, campaign: widgetData)
                completion(entry)
                return
            } else {
                // Failed to fetch campaign data from API
                guard let campaignId = configuration.campaign?.identifier.flatMap({ UUID(uuidString: $0) }),
                      let campaign = await fetchStoredData(for: campaignId) else {
                    let entry = SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: sampleCampaign)
                    completion(entry)
                    return
                }
                completion(SimpleEntry(date: Date(), configuration: configuration, campaign: campaign))
            }
        }
    }
    
    // Converted to TiltifyAPIClient
    internal func fetchSnapshot(for configuration: CampaignLockScreenConfigurationIntent, in context: Context, completion: @escaping (CampaignLockScreenEventEntry) -> ()) {
        Task {
            if let campaignData = await TiltifyAPIClient.shared.getCampaignWithMilestones(forId: TEAM_EVENT_ID) {
                let widgetData = TiltifyWidgetData(from: campaignData)
                let entry = CampaignLockScreenEventEntry(date: Date(), configuration: configuration, campaign: widgetData)
                completion(entry)
                return
            } else {
                // Failed to fetch campaign data from API
                guard let campaignId = configuration.campaign?.identifier.flatMap({ UUID(uuidString: $0) }),
                      let campaign = await fetchStoredData(for: campaignId) else {
                    let entry = CampaignLockScreenEventEntry(date: Date(), configuration: CampaignLockScreenConfigurationIntent(), campaign: sampleCampaign)
                    completion(entry)
                    return
                }
                completion(CampaignLockScreenEventEntry(date: Date(), configuration: configuration, campaign: campaign))
            }
        }
    }
    
    // Converted to TiltifyAPIClient
    internal func fetchTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        if let campaign = configuration.campaign {
            Task {
                var entries: [SimpleEntry] = []
                if let campaignId = UUID(uuidString: campaign.identifier ?? ""), let campaignData = await TiltifyAPIClient.shared.getCampaignWithMilestones(forId: campaignId) {
                    let widgetData = TiltifyWidgetData(from: campaignData)
                    let entry = SimpleEntry(date: Date(), configuration: configuration, campaign: widgetData)
                    entries.append(entry)
                } else {
                    // Failed to fetch campaign data from API
                    guard let campaignId = configuration.campaign?.identifier.flatMap({ UUID(uuidString: $0) }),
                          let campaign = await fetchStoredData(for: campaignId) else {
                        let entry = SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: sampleCampaign)
                        completion(Timeline(entries: [entry], policy: .atEnd))
                        return
                    }
                    entries.append(SimpleEntry(date: Date(), configuration: configuration, campaign: campaign))
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        } else {
            let timeline = Timeline(entries: [
                SimpleEntry(date: Date(), configuration: configuration, campaign: nil)
            ], policy: .atEnd)
            completion(timeline)
        }
    }
    
    // Converted to TiltifyAPIClient
    internal func fetchTimeline(for configuration: CampaignLockScreenConfigurationIntent, in context: Context, completion: @escaping (Timeline<CampaignLockScreenEventEntry>) -> ()) {
        if let campaign = configuration.campaign {
            Task {
                var entries: [CampaignLockScreenEventEntry] = []
                if let campaignId = UUID(uuidString: campaign.identifier ?? ""), let campaignData = await TiltifyAPIClient.shared.getCampaignWithMilestones(forId: campaignId) {
                    let widgetData = TiltifyWidgetData(from: campaignData)
                    let entry = CampaignLockScreenEventEntry(date: Date(), configuration: configuration, campaign: widgetData)
                    entries.append(entry)
                } else {
                    // Failed to fetch campaign data from API
                    guard let campaignId = configuration.campaign?.identifier.flatMap({ UUID(uuidString: $0) }),
                          let campaign = await fetchStoredData(for: campaignId) else {
                        let entry = CampaignLockScreenEventEntry(date: Date(), configuration: CampaignLockScreenConfigurationIntent(), campaign: sampleCampaign)
                        completion(Timeline(entries: [entry], policy: .atEnd))
                        return
                    }
                    entries.append(CampaignLockScreenEventEntry(date: Date(), configuration: configuration, campaign: campaign))
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        } else {
            let timeline = Timeline(entries: [
                CampaignLockScreenEventEntry(date: Date(), configuration: configuration, campaign: nil)
            ], policy: .atEnd)
            completion(timeline)
        }
    }
}

// Converted to TiltifyAPIClient
extension WidgetDataProviding {
    
    internal func fetchPlaceholder(in context: Context) -> FundraisingEventEntry {
        if let data = UserDefaults.shared.data(forKey: "relayData") {
            do {
                let campaign = try JSONDecoder().decode(TiltifyWidgetData.self, from: data)
                return FundraisingEventEntry(date: Date(), configuration: FundraisingEventConfigurationIntent(), campaign: campaign)
            } catch {
                dataLogger.error("Failed to retrieve stored data for placeholder: \(error.localizedDescription)")
            }
        }
        return FundraisingEventEntry(date: Date(), configuration: FundraisingEventConfigurationIntent(), campaign: sampleCampaign)
    }
    
    internal func fetchPlaceholder(in context: Context) -> FundraisingLockScreenEventEntry {
        if let data = UserDefaults.shared.data(forKey: "relayData") {
            do {
                let campaign = try JSONDecoder().decode(TiltifyWidgetData.self, from: data)
                return FundraisingLockScreenEventEntry(date: Date(), configuration: FundraisingEventLockScreenConfigurationIntent(), campaign: campaign)
            } catch {
                dataLogger.error("Failed to retrieve stored data for placeholder: \(error.localizedDescription)")
            }
        }
        return FundraisingLockScreenEventEntry(date: Date(), configuration: FundraisingEventLockScreenConfigurationIntent(), campaign: sampleCampaign)
    }
    
    // Converted to TiltifyAPIClient
    internal func fetchSnapshot(for configuration: FundraisingEventConfigurationIntent, in context: Context, completion: @escaping (FundraisingEventEntry) -> ()) {
        Task {
            if let fundraisingEvent = await TiltifyAPIClient.shared.getFundraisingEvent() {
                let milestones = await TiltifyAPIClient.shared.getCampaignMilestones(forId: TEAM_EVENT_ID)
                let widgetData = TiltifyWidgetData(from: fundraisingEvent, milestones: milestones)
                let entry = FundraisingEventEntry(date: Date(), configuration: configuration, campaign: widgetData)
                completion(entry)
            } else {
                do {
                    if let teamEvent = try await AppDatabase.shared.fetchTeamEvent() {
                        completion(FundraisingEventEntry(date: Date(), configuration: FundraisingEventConfigurationIntent(), campaign: await TiltifyWidgetData(from: teamEvent)))
                    }
                } catch {
                    dataLogger.error("Could not fetch stored team event")
                }
            }
        }
    }
    
    // Converted to TiltifyAPIClient
    internal func fetchSnapshot(for configuration: FundraisingEventLockScreenConfigurationIntent, in context: Context, completion: @escaping (FundraisingLockScreenEventEntry) -> ()) {
        Task {
            if let fundraisingEvent = await TiltifyAPIClient.shared.getFundraisingEvent() {
                let milestones = await TiltifyAPIClient.shared.getCampaignMilestones(forId: TEAM_EVENT_ID)
                let widgetData = TiltifyWidgetData(from: fundraisingEvent, milestones: milestones)
                let entry = FundraisingLockScreenEventEntry(date: Date(), configuration: configuration, campaign: widgetData)
                completion(entry)
            } else {
                do {
                    if let teamEvent = try await AppDatabase.shared.fetchTeamEvent() {
                        completion(FundraisingLockScreenEventEntry(date: Date(), configuration: FundraisingEventLockScreenConfigurationIntent(), campaign: await TiltifyWidgetData(from: teamEvent)))
                    }
                } catch {
                    dataLogger.error("Could not fetch stored team event")
                }
            }
        }
    }
    
    // Converted to TiltifyAPIClient
    internal func fetchTimeline(for configuration: FundraisingEventConfigurationIntent, in context: Context, completion: @escaping (Timeline<FundraisingEventEntry>) -> ()) {
        Task {
            if let fundraisingEvent = await TiltifyAPIClient.shared.getFundraisingEvent() {
                let milestones = await TiltifyAPIClient.shared.getCampaignMilestones(forId: TEAM_EVENT_ID)
                let widgetData = TiltifyWidgetData(from: fundraisingEvent, milestones: milestones)
                let entry = FundraisingEventEntry(date: Date(), configuration: configuration, campaign: widgetData)
                completion(Timeline(entries: [entry], policy: .atEnd))
            } else {
                // Read from database instead of API
                do {
                    if let teamEvent = try await AppDatabase.shared.fetchTeamEvent() {
                        let widgetData = await TiltifyWidgetData(from: teamEvent)
                        let entry = FundraisingEventEntry(date: Date(), configuration: configuration, campaign: widgetData)
                        completion(Timeline(entries: [entry], policy: .atEnd))
                    } else {
                        let entry = FundraisingEventEntry(date: Date(), configuration: configuration, campaign: sampleCampaign)
                        completion(Timeline(entries: [entry], policy: .atEnd))
                    }
                } catch {
                    dataLogger.error("Could not fetch stored team event")
                    let entry = FundraisingEventEntry(date: Date(), configuration: configuration, campaign: sampleCampaign)
                    completion(Timeline(entries: [entry], policy: .atEnd))
                }
            }
        }
    }
    
    // Converted to TiltifyAPIClient
    internal func fetchTimeline(for configuration: FundraisingEventLockScreenConfigurationIntent, in context: Context, completion: @escaping (Timeline<FundraisingLockScreenEventEntry>) -> ()) {
        Task {
            if let fundraisingEvent = await TiltifyAPIClient.shared.getFundraisingEvent() {
                let milestones = await TiltifyAPIClient.shared.getCampaignMilestones(forId: TEAM_EVENT_ID)
                let widgetData = TiltifyWidgetData(from: fundraisingEvent, milestones: milestones)
                let entry = FundraisingLockScreenEventEntry(date: Date(), configuration: configuration, campaign: widgetData)
                completion(Timeline(entries: [entry], policy: .atEnd))
            } else {
                // Read from database instead of API
                do {
                    if let teamEvent = try await AppDatabase.shared.fetchTeamEvent() {
                        let widgetData = await TiltifyWidgetData(from: teamEvent)
                        let entry = FundraisingLockScreenEventEntry(date: Date(), configuration: configuration, campaign: widgetData)
                        completion(Timeline(entries: [entry], policy: .atEnd))
                    } else {
                        let entry = FundraisingLockScreenEventEntry(date: Date(), configuration: configuration, campaign: sampleCampaign)
                        completion(Timeline(entries: [entry], policy: .atEnd))
                    }
                } catch {
                    dataLogger.error("Could not fetch stored team event")
                    let entry = FundraisingLockScreenEventEntry(date: Date(), configuration: configuration, campaign: sampleCampaign)
                    completion(Timeline(entries: [entry], policy: .atEnd))
                }
            }
        }
    }
}

// Converted to TiltifyAPIClient
extension WidgetDataProviding {
    internal func fetchPlaceholder(in context: Context) -> HeadToHeadEntry {
        return HeadToHeadEntry(date: Date(), configuration: HeadToHeadConfigurationIntent(), headToHeadId: nil, campaign1: nil, campaign2: nil)
    }
    
    // Converted to TiltifyAPIClient
    internal func fetchSnapshot(for configuration: HeadToHeadConfigurationIntent, in context: Context, completion: @escaping (HeadToHeadEntry) -> ()) {
        
        guard let headToHead = configuration.headToHead, let campaign1 = headToHead.campaign1, let campaign2 = headToHead.campaign2 else {
            let entry = HeadToHeadEntry(date: Date(), configuration: configuration, headToHeadId: nil, campaign1: nil, campaign2: nil)
            completion(entry)
            return
        }
        
        Task {
            if let campaign1Id = UUID(uuidString: campaign1.identifier ?? ""),
               let campaign1Data = await TiltifyAPIClient.shared.getCampaignWithMilestones(forId: campaign1Id),
               let campaign2Id = UUID(uuidString: campaign2.identifier ?? ""),
               let campaign2Data = await TiltifyAPIClient.shared.getCampaignWithMilestones(forId: campaign2Id)
            {
                let widgetData1 = TiltifyWidgetData(from: campaign1Data)
                let widgetData2 = TiltifyWidgetData(from: campaign2Data)
                let entry = HeadToHeadEntry(date: Date(), configuration: configuration, headToHeadId: UUID(uuidString: headToHead.identifier ?? ""), campaign1: widgetData1, campaign2: widgetData2)
                completion(entry)
            } else {
                let entry = HeadToHeadEntry(date: Date(), configuration: HeadToHeadConfigurationIntent(), headToHeadId: nil, campaign1: nil, campaign2: nil)
                completion(entry)
            }
        }
    }
    
    // Converted to TiltifyAPIClient
    internal func fetchTimeline(for configuration: HeadToHeadConfigurationIntent, in context: Context, completion: @escaping (Timeline<HeadToHeadEntry>) -> ()) {
        
        guard let h2h = configuration.headToHead, let campaign1 = h2h.campaign1, let campaign2 = h2h.campaign2 else {
            let timeline = Timeline(entries: [
                HeadToHeadEntry(date: Date(), configuration: configuration, headToHeadId: nil, campaign1: nil, campaign2: nil)
            ], policy: .atEnd)
            completion(timeline)
            return
        }
        
        Task {
            var entries: [HeadToHeadEntry] = []
            if let campaign1Id = UUID(uuidString: campaign1.identifier ?? ""),
               let campaign1Data = await TiltifyAPIClient.shared.getCampaignWithMilestones(forId: campaign1Id),
               let campaign2Id = UUID(uuidString: campaign2.identifier ?? ""),
               let campaign2Data = await TiltifyAPIClient.shared.getCampaignWithMilestones(forId: campaign2Id)
            {
                let widgetData1 = TiltifyWidgetData(from: campaign1Data)
                let widgetData2 = TiltifyWidgetData(from: campaign2Data)
                let entry = HeadToHeadEntry(date: Date(), configuration: configuration, headToHeadId: UUID(uuidString: h2h.identifier ?? ""), campaign1: widgetData1, campaign2: widgetData2)
                entries.append(entry)
            } else {
                let entry = HeadToHeadEntry(date: Date(), configuration: HeadToHeadConfigurationIntent(), headToHeadId: nil, campaign1: nil, campaign2: nil)
                entries.append(entry)
            }
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}
