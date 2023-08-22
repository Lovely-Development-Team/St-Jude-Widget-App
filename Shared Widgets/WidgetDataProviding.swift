//
//  WidgetDataProviding.swift
//  WidgetDataProviding
//
//  Created by David on 25/08/2021.
//

import Foundation
import WidgetKit

protocol WidgetDataProviding: IntentTimelineProvider {
    var apiClient: ApiClient { get }
}

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
            UserDefaults.shared.set(try apiClient.jsonEncoder.encode(data), forKey: "relayData")
        } catch {
            dataLogger.error("Failed to store API response: \(error.localizedDescription)")
        }
    }
}

extension WidgetDataProviding {
    private func fetchCampaign(vanity: String?, slug: String?, completion: @escaping (Result<TiltifyResponse, Error>) -> ()) {
        _ = apiClient.fetchCampaign(vanity: vanity ?? "relay-fm", slug: slug ?? "relay-fm", completion: completion)
    }
    
    internal func fetchPlaceholder(in context: Context) -> SimpleEntry {
        if let data = UserDefaults.shared.data(forKey: "relayData") {
            do {
                let campaign = try apiClient.jsonDecoder.decode(TiltifyWidgetData.self, from: data)
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
                let campaign = try apiClient.jsonDecoder.decode(TiltifyWidgetData.self, from: data)
                return CampaignLockScreenEventEntry(date: Date(), configuration: CampaignLockScreenConfigurationIntent(), campaign: campaign)
            } catch {
                dataLogger.error("Failed to retrieve stored data for placeholder: \(error.localizedDescription)")
            }
        }
        return CampaignLockScreenEventEntry(date: Date(), configuration: CampaignLockScreenConfigurationIntent(), campaign: sampleCampaign)
    }
    
    internal func fetchSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        self.fetchCampaign(vanity: configuration.campaign?.vanity, slug: configuration.campaign?.slug) { result in
            switch result {
            case .failure(let error):
                dataLogger.error("Failed to populate snapshot: \(error.localizedDescription)")
                Task {
                    guard let campaignId = configuration.campaign?.identifier.flatMap({ UUID(uuidString: $0) }),
                          let campaign = await fetchStoredData(for: campaignId) else {
                        completion(SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: sampleCampaign))
                        return
                    }
                    completion(SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: campaign))
                }
                break
            case .success(let response):
                let campaign: TiltifyWidgetData = TiltifyWidgetData(from:response.data.campaign)
                let entry = SimpleEntry(date: Date(), configuration: configuration, campaign: campaign)
                storeData(campaign)
                completion(entry)
            }
        }
    }
    
    internal func fetchSnapshot(for configuration: CampaignLockScreenConfigurationIntent, in context: Context, completion: @escaping (CampaignLockScreenEventEntry) -> ()) {
        self.fetchCampaign(vanity: configuration.campaign?.vanity, slug: configuration.campaign?.slug) { result in
            switch result {
            case .failure(let error):
                dataLogger.error("Failed to populate snapshot: \(error.localizedDescription)")
                Task {
                    guard let campaignId = configuration.campaign?.identifier.flatMap({ UUID(uuidString: $0) }),
                          let campaign = await fetchStoredData(for: campaignId) else {
                        completion(CampaignLockScreenEventEntry(date: Date(), configuration: CampaignLockScreenConfigurationIntent(), campaign: sampleCampaign))
                        return
                    }
                    completion(CampaignLockScreenEventEntry(date: Date(), configuration: CampaignLockScreenConfigurationIntent(), campaign: campaign))
                }
                break
            case .success(let response):
                let campaign: TiltifyWidgetData = TiltifyWidgetData(from:response.data.campaign)
                let entry = CampaignLockScreenEventEntry(date: Date(), configuration: configuration, campaign: campaign)
                storeData(campaign)
                completion(entry)
            }
        }
    }
    
    internal func fetchTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        self.fetchCampaign(vanity: configuration.campaign?.vanity, slug: configuration.campaign?.slug) { result in
            Task {
                var entries: [SimpleEntry] = []
                switch result {
                case .failure(let error):
                    dataLogger.error("Failed to populate timeline: \(error.localizedDescription)")
                    guard let campaignId = configuration.campaign?.identifier.flatMap({ UUID(uuidString: $0) }),
                          let campaign = await fetchStoredData(for: campaignId) else {
                        let entry = SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: sampleCampaign)
                        completion(Timeline(entries: [entry], policy: .atEnd))
                        return
                    }
                    entries.append(SimpleEntry(date: Date(), configuration: configuration, campaign: campaign))
                    break
                case .success(let response):
                    let campaign: TiltifyWidgetData = TiltifyWidgetData(from: response.data.campaign)
                    let entry = SimpleEntry(date: Date(), configuration: configuration, campaign: campaign)
                    storeData(campaign)
                    entries.append(entry)
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
    }
    
    internal func fetchTimeline(for configuration: CampaignLockScreenConfigurationIntent, in context: Context, completion: @escaping (Timeline<CampaignLockScreenEventEntry>) -> ()) {
        self.fetchCampaign(vanity: configuration.campaign?.vanity, slug: configuration.campaign?.slug) { result in
            Task {
                var entries: [CampaignLockScreenEventEntry] = []
                switch result {
                case .failure(let error):
                    dataLogger.error("Failed to populate timeline: \(error.localizedDescription)")
                    guard let campaignId = configuration.campaign?.identifier.flatMap({ UUID(uuidString: $0) }),
                          let campaign = await fetchStoredData(for: campaignId) else {
                        let entry = CampaignLockScreenEventEntry(date: Date(), configuration: CampaignLockScreenConfigurationIntent(), campaign: sampleCampaign)
                        completion(Timeline(entries: [entry], policy: .atEnd))
                        return
                    }
                    entries.append(CampaignLockScreenEventEntry(date: Date(), configuration: configuration, campaign: campaign))
                    break
                case .success(let response):
                    let campaign: TiltifyWidgetData = TiltifyWidgetData(from: response.data.campaign)
                    let entry = CampaignLockScreenEventEntry(date: Date(), configuration: configuration, campaign: campaign)
                    storeData(campaign)
                    entries.append(entry)
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
    }
}

extension WidgetDataProviding {
    
    internal func fetchPlaceholder(in context: Context) -> FundraisingEventEntry {
        if let data = UserDefaults.shared.data(forKey: "relayData") {
            do {
                let campaign = try apiClient.jsonDecoder.decode(TiltifyWidgetData.self, from: data)
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
                let campaign = try apiClient.jsonDecoder.decode(TiltifyWidgetData.self, from: data)
                return FundraisingLockScreenEventEntry(date: Date(), configuration: FundraisingEventLockScreenConfigurationIntent(), campaign: campaign)
            } catch {
                dataLogger.error("Failed to retrieve stored data for placeholder: \(error.localizedDescription)")
            }
        }
        return FundraisingLockScreenEventEntry(date: Date(), configuration: FundraisingEventLockScreenConfigurationIntent(), campaign: sampleCampaign)
    }
    
    internal func fetchSnapshot(for configuration: FundraisingEventConfigurationIntent, in context: Context, completion: @escaping (FundraisingEventEntry) -> ()) {
        Task {
            if let teamEvent = await apiClient.fetchTeamEvent() {
                completion(FundraisingEventEntry(date: Date(), configuration: configuration, campaign: await TiltifyWidgetData(from: TeamEvent(from: teamEvent))))
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
    
    internal func fetchSnapshot(for configuration: FundraisingEventLockScreenConfigurationIntent, in context: Context, completion: @escaping (FundraisingLockScreenEventEntry) -> ()) {
        Task {
            if let teamEvent = await apiClient.fetchTeamEvent() {
                completion(FundraisingLockScreenEventEntry(date: Date(), configuration: configuration, campaign: await TiltifyWidgetData(from: TeamEvent(from: teamEvent))))
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
    
    internal func fetchTimeline(for configuration: FundraisingEventConfigurationIntent, in context: Context, completion: @escaping (Timeline<FundraisingEventEntry>) -> ()) {
        Task {
            if let teamEvent = await apiClient.fetchTeamEvent() {
                let widgetData = await TiltifyWidgetData(from: TeamEvent(from: teamEvent))
                let entry = FundraisingEventEntry(date: Date(), configuration: configuration, campaign: widgetData)
                completion(Timeline(entries: [entry], policy: .atEnd))
            } else {
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
    
    internal func fetchTimeline(for configuration: FundraisingEventLockScreenConfigurationIntent, in context: Context, completion: @escaping (Timeline<FundraisingLockScreenEventEntry>) -> ()) {
        Task {
            if let teamEvent = await apiClient.fetchTeamEvent() {
                let widgetData = await TiltifyWidgetData(from: TeamEvent(from: teamEvent))
                let entry = FundraisingLockScreenEventEntry(date: Date(), configuration: configuration, campaign: widgetData)
                completion(Timeline(entries: [entry], policy: .atEnd))
            } else {
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
