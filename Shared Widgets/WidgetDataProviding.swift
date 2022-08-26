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
        _ = apiClient.fetchCampaign(vanity: vanity ?? "relay-fm", slug: slug ?? "relay-fm-for-st-jude-2022", completion: completion)
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
}
