//
//  PollWidgetTimelineProvider.swift
//  Intents Extension
//
//  Created by Justin Hamilton on 9/12/26.
//

import WidgetKit
import SwiftUI
import Intents

struct PollLockScreenWidgetTimelineProvider: IntentTimelineProvider, WidgetDataProviding {
    func placeholder(in context: Context) -> PollLockScreenWidgetEntry {
        return self.fetchPlaceholder(in: context)
    }
    
    func getSnapshot(for configuration: PollLockScreenConfigurationIntent, in context: Context, completion: @escaping @Sendable (PollLockScreenWidgetEntry) -> Void) {
        return self.fetchSnapshot(for: configuration, in: context, completion: completion)
    }
    
    func getTimeline(for configuration: PollLockScreenConfigurationIntent, in context: Context, completion: @escaping @Sendable (Timeline<PollLockScreenWidgetEntry>) -> Void) {
        return self.fetchTimeline(for: configuration, in: context, completion: completion)
    }
}
