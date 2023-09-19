//
//  Tiltify_St_Jude_Widget.swift
//  Tiltify St Jude Widget
//
//  Created by David on 21/08/2021.
//

import WidgetKit
import SwiftUI
import Intents

struct CampaignLockScreenProvider: IntentTimelineProvider, WidgetDataProviding {
    let apiClient = ApiClient.shared
    
    func placeholder(in context: Context) -> CampaignLockScreenEventEntry {
        return fetchPlaceholder(in: context)
    }
    
    func getSnapshot(for configuration: CampaignLockScreenConfigurationIntent, in context: Context, completion: @escaping (CampaignLockScreenEventEntry) -> Void) {
        fetchSnapshot(for: configuration, in: context, completion: completion)
    }
    
    func getTimeline(for configuration: CampaignLockScreenConfigurationIntent, in context: Context, completion: @escaping (Timeline<CampaignLockScreenEventEntry>) -> Void) {
        fetchTimeline(for: configuration, in: context, completion: completion)
    }
    
}

struct FundraisingLockScreenProvider: IntentTimelineProvider, WidgetDataProviding {
    let apiClient = ApiClient.shared
    
    func placeholder(in context: Context) -> FundraisingLockScreenEventEntry {
        return fetchPlaceholder(in: context)
    }
    
    func getSnapshot(for configuration: FundraisingEventLockScreenConfigurationIntent, in context: Context, completion: @escaping (FundraisingLockScreenEventEntry) -> Void) {
        fetchSnapshot(for: configuration, in: context, completion: completion)
    }
    
    func getTimeline(for configuration: FundraisingEventLockScreenConfigurationIntent, in context: Context, completion: @escaping (Timeline<FundraisingLockScreenEventEntry>) -> Void) {
        fetchTimeline(for: configuration, in: context, completion: completion)
    }
    
}

struct FundraisingProvider: IntentTimelineProvider, WidgetDataProviding {
    let apiClient = ApiClient.shared
    
    func placeholder(in context: Context) -> FundraisingEventEntry {
        return fetchPlaceholder(in: context)
    }
    
    func getSnapshot(for configuration: FundraisingEventConfigurationIntent, in context: Context, completion: @escaping (FundraisingEventEntry) -> ()) {
        fetchSnapshot(for: configuration, in: context, completion: completion)
    }
    
    func getTimeline(for configuration: FundraisingEventConfigurationIntent, in context: Context, completion: @escaping (Timeline<FundraisingEventEntry>) -> ()) {
        fetchTimeline(for: configuration, in: context, completion: completion)
    }
}

struct HeadToHeadProvider: IntentTimelineProvider, WidgetDataProviding {
    let apiClient = ApiClient.shared

    func placeholder(in context: Context) -> HeadToHeadEntry {
        return fetchPlaceholder(in: context)
    }
    
    func getSnapshot(for configuration: HeadToHeadConfigurationIntent, in context: Context, completion: @escaping (HeadToHeadEntry) -> Void) {
        fetchSnapshot(for: configuration, in: context, completion: completion)
    }
    
    func getTimeline(for configuration: HeadToHeadConfigurationIntent, in context: Context, completion: @escaping (Timeline<HeadToHeadEntry>) -> Void) {
        fetchTimeline(for: configuration, in: context, completion: completion)
    }
}

struct Provider: IntentTimelineProvider, WidgetDataProviding {
    let apiClient = ApiClient.shared
    
    func placeholder(in context: Context) -> SimpleEntry {
        return fetchPlaceholder(in: context)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        fetchSnapshot(for: configuration, in: context, completion: completion)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        fetchTimeline(for: configuration, in: context, completion: completion)
    }
}

@main
struct TiltifyStJudeWidgets: WidgetBundle {
   var body: some Widget {
       FundraisingEventWidget()
       FundraisingLockScreenWidget()
       Tiltify_St_Jude_Widget()
       CampaignLockScreenWidget()
       HeadToHeadWidget()
       ScoreWidget()
   }
}

struct CampaignLockScreenWidget: Widget {
    let kind: String = "CampaignLockScreenWidget"
    @StateObject private var apiClient = ApiClient.shared
    
    var supportedFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [
                .accessoryInline,
                .accessoryRectangular,
                .accessoryCircular
            ]
        } else {
            return []
        }
    }
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: CampaignLockScreenConfigurationIntent.self, provider: CampaignLockScreenProvider()) { entry in
            CampaignLockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("Individual Fundraiser")
        .description("Displays the current status for a particular fundraiser.")
        .onBackgroundURLSessionEvents(matching: ApiClient.backgroundSessionIdentifier) { identifier, completion in
            apiClient.backgroundCompletionHandler = completion
            // Access the background session to make sure it is initialised
            _ = apiClient.backgroundURLSession
        }
        .supportedFamilies(supportedFamilies)
    }
    
}

struct FundraisingLockScreenWidget: Widget {
    let kind: String = "FundraisingLockScreenWidget"
    @StateObject private var apiClient = ApiClient.shared
    
    var supportedFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [
                .accessoryInline,
                .accessoryRectangular,
                .accessoryCircular
            ]
        } else {
            return []
        }
    }
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: FundraisingEventLockScreenConfigurationIntent.self, provider: FundraisingLockScreenProvider()) { entry in
            FundraisingLockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("Relay FM for St. Jude")
        .description("Displays the current status of the overall fundraising event.")
        .onBackgroundURLSessionEvents(matching: ApiClient.backgroundSessionIdentifier) { identifier, completion in
            apiClient.backgroundCompletionHandler = completion
            // Access the background session to make sure it is initialised
            _ = apiClient.backgroundURLSession
        }
        .supportedFamilies(supportedFamilies)
    }
}

struct HeadToHeadWidget: Widget {
    let kind: String = "HeadToHeadWidget"
    @StateObject private var apiClient = ApiClient.shared
    
    var supportedFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .systemExtraLarge,
                .accessoryInline,
                .accessoryRectangular,
                .accessoryCircular
            ]
        } else {
            return [
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .systemExtraLarge
            ]
        }
    }
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: HeadToHeadConfigurationIntent.self, provider: HeadToHeadProvider()) { entry in
            HeadToHeadWidgetView(entry: entry)
        }
        .configurationDisplayName("Head To Head")
        .description("Pit one campaign against another!")
        .onBackgroundURLSessionEvents(matching: ApiClient.backgroundSessionIdentifier) { identifier, completion in
            apiClient.backgroundCompletionHandler = completion
            // Access the background session to make sure it is initialised
            _ = apiClient.backgroundURLSession
        }
        .supportedFamilies(supportedFamilies)
    }
}

struct FundraisingEventWidget: Widget {
    let kind: String = "FundraisingEvent"
    @StateObject private var apiClient = ApiClient.shared
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: FundraisingEventConfigurationIntent.self, provider: FundraisingProvider()) { entry in
            FundraisingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Relay FM for St. Jude")
        .description("Displays the current status of the overall fundraising event.")
        .onBackgroundURLSessionEvents(matching: ApiClient.backgroundSessionIdentifier) { identifier, completion in
            apiClient.backgroundCompletionHandler = completion
            // Access the background session to make sure it is initialised
            _ = apiClient.backgroundURLSession
        }
    }
}

struct Tiltify_St_Jude_Widget: Widget {
    let kind: String = "Tiltify_St_Jude_Widget"
    @StateObject private var apiClient = ApiClient.shared
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Individual Fundraiser")
        .description("Displays the current status for a particular fundraiser.")
        .onBackgroundURLSessionEvents(matching: ApiClient.backgroundSessionIdentifier) { identifier, completion in
            apiClient.backgroundCompletionHandler = completion
            // Access the background session to make sure it is initialised
            _ = apiClient.backgroundURLSession
        }
    }
}


struct ScoreEntryProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScoreEntry {
        ScoreEntry(date: .now, score: Score(myke: .zero, stephen: .zero))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ScoreEntry) -> Void) {
        Task {
            if let score = await ApiClient.shared.fetchScore() {
                completion(ScoreEntry(date: .now, score: score))
            } else {
                completion(ScoreEntry(date: .now, score: Score(myke: .zero, stephen: .zero)))
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScoreEntry>) -> Void) {
        Task {
            let score: Score
            if let apiScore = await ApiClient.shared.fetchScore() {
                score = apiScore
            } else {
                score = Score(myke: .zero, stephen: .zero)
            }
            completion(Timeline(entries: [ScoreEntry(date: .now, score: score)], policy: .atEnd))
        }
    }
}

struct ScoreWidget: Widget {
    let kind: String = "ScoreWidget"
    
    var supportedFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .systemExtraLarge,
                .accessoryInline,
                .accessoryRectangular,
                .accessoryCircular
            ]
        } else {
            return [
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .systemExtraLarge
            ]
        }
    }
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScoreEntryProvider()) { entry in
            ScoreEntryView(entry: entry)
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Myke vs. Stephen")
        .description("Keep track of their scores.")
        .supportedFamilies(supportedFamilies)
    }
}

struct Tiltify_St_Jude_Widget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: sampleCampaign))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: sampleCampaign))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: sampleCampaign))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
