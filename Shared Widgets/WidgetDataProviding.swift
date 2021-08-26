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
    internal func fetchStoredData() -> TiltifyWidgetData? {
        do {
            dataLogger.notice("Attempting to fetch stored data")
            guard let data = UserDefaults.shared.data(forKey: "relayData") else {
                dataLogger.notice("No stored data found")
                return nil
            }
            return try apiClient.jsonDecoder.decode(TiltifyWidgetData.self, from: data)
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
        _ = apiClient.fetchCampaign { result in
            switch result {
            case .failure(let error):
                dataLogger.error("Failed to populate snapshot: \(error.localizedDescription)")
                guard let campaign = fetchStoredData() else {
                    completion(SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: sampleCampaign))
                    return
                }
                completion(SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: campaign))
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
        _ = apiClient.fetchCampaign { result in
            var entries: [SimpleEntry] = []
            switch result {
            case .failure(let error):
                dataLogger.error("Failed to populate timeline: \(error.localizedDescription)")
                guard let campaign = fetchStoredData() else {
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
