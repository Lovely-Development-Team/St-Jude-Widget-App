//
//  macOS_Widget.swift
//  macOS Widget
//
//  Created by David on 25/08/2021.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider, WidgetDataProviding {
    let apiClient: ApiClient = ApiClient.shared
    
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
struct macOS_Widget: Widget {
    let kind: String = "macOS_Widget"
    @StateObject private var apiClient = ApiClient.shared

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Relay FM for St. Jude")
        .description("Displays the current Relay FM for St. Jude fundraising status.")
    }
}

struct macOS_Widget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: sampleCampaign))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: sampleCampaign))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: sampleCampaign))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
