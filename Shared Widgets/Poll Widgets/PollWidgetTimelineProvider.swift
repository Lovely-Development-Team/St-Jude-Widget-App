//
//  PollWidgetTimelineProvider.swift
//  Intents Extension
//
//  Created by Justin Hamilton on 9/12/26.
//

import WidgetKit
import SwiftUI
import Intents

struct PollWidgetTimelineProvider: IntentTimelineProvider, WidgetDataProviding {
    func placeholder(in context: Context) -> PollWidgetEntry {
        return self.fetchPlaceholder(in: context)
    }
    
    func getSnapshot(for configuration: PollConfigurationIntent, in context: Context, completion: @escaping @Sendable (PollWidgetEntry) -> Void) {
        return self.fetchSnapshot(for: configuration, in: context, completion: completion)
    }
    
    func getTimeline(for configuration: PollConfigurationIntent, in context: Context, completion: @escaping @Sendable (Timeline<PollWidgetEntry>) -> Void) {
        return self.fetchTimeline(for: configuration, in: context, completion: completion)
    }
}
