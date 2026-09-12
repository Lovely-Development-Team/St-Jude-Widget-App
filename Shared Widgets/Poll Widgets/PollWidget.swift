//
//  PollWidget.swift
//  Intents Extension
//
//  Created by Justin Hamilton on 9/12/26.
//

import WidgetKit
import SwiftUI
import Intents

struct PollWidget: Widget {
    let kind: String = "PollWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: self.kind,
                            intent: PollConfigurationIntent.self,
                            provider: PollWidgetTimelineProvider(),
                            content: { entry in
            PollWidgetEntryView(poll: entry.poll,
                                options: entry.options,
                                parentCampaign: entry.parentCampaign,
                                appearance: entry.configuration.appearance,
                                showFullCurrencySymbol: entry.configuration.showFullCurrencySymbol?.boolValue ?? false)
        })
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge,
            .accessoryInline,
            .accessoryRectangular
        ])
        .configurationDisplayName("Poll")
        .description("Keep tabs on your favorite poll from the Relay campaign or your starred campaigns!")
    }
}
