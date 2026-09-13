//
//  PollWidget.swift
//  Intents Extension
//
//  Created by Justin Hamilton on 9/12/26.
//

import WidgetKit
import SwiftUI
import Intents

struct PollLockScreenWidget: Widget {
    let kind: String = "PollLockScreenWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: self.kind,
                            intent: PollLockScreenConfigurationIntent.self,
                            provider: PollLockScreenWidgetTimelineProvider(),
                            content: { entry in
            PollLockScreenWidgetEntryView(poll: entry.poll,
                                options: entry.options,
                                parentCampaign: entry.parentCampaign,
                                showFullCurrencySymbol: entry.configuration.showFullCurrencySymbol?.boolValue ?? false)
            .widgetURL(URL(string: entry.widgetURL)!)
        })
        .supportedFamilies([
            .accessoryInline,
            .accessoryRectangular
        ])
        .configurationDisplayName("Poll")
        .description("Keep tabs on your favorite poll from the Relay campaign or your starred campaigns!")
    }
}

#Preview(as: .accessoryInline, widget: {
    PollLockScreenWidget()
}, timeline: {
    PollLockScreenWidgetEntry(date: Date(), configuration: .init(),
                    poll: Poll.samplePoll,
                    options: PollOption.samplePollOptions,
                    parentCampaign: sampleCampaign,
                    openParentCampaign: false)
})

#Preview(as: .accessoryRectangular, widget: {
    PollLockScreenWidget()
}, timeline: {
    PollLockScreenWidgetEntry(date: Date(), configuration: .init(),
                    poll: Poll.samplePoll,
                    options: PollOption.samplePollOptions,
                    parentCampaign: sampleCampaign,
                    openParentCampaign: false)
})
