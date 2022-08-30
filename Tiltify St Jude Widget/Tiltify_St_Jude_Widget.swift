//
//  Tiltify_St_Jude_Widget.swift
//  Tiltify St Jude Widget
//
//  Created by David on 21/08/2021.
//

import WidgetKit
import SwiftUI
import Intents

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
       Tiltify_St_Jude_Widget()
   }
}

struct FundraisingEventWidget: Widget {
    let kind: String = "FundraisingEvent"
    @StateObject private var apiClient = ApiClient.shared
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: FundraisingEventConfigurationIntent.self, provider: FundraisingProvider()) { entry in
            FundraisingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Relay FM for St. Jude Fundraiser")
        .description("Displays the current status of the overall fundraiser.")
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
        .configurationDisplayName("Individual Campaign")
        .description("Displays the current fundraising status for a given campaign.")
        .onBackgroundURLSessionEvents(matching: ApiClient.backgroundSessionIdentifier) { identifier, completion in
            apiClient.backgroundCompletionHandler = completion
            // Access the background session to make sure it is initialised
            _ = apiClient.backgroundURLSession
        }
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
