//
//  HeadToHeadConfigurationIntentHandler.swift
//  Intents Extension
//
//  Created by Justin Hamilton on 8/31/23.
//

import Foundation
import Intents


class HeadToHeadConfigurationIntentHandler: NSObject, HeadToHeadConfigurationIntentHandling {
    func resolveHeadToHead(for intent: HeadToHeadConfigurationIntent) async -> WidgetHeadToHeadResolutionResult {
        guard let headToHead = intent.headToHead else {
            return .notRequired()
        }
        
        return .success(with: headToHead)
    }
    
    func resolveDisablePixelTheme(for intent: HeadToHeadConfigurationIntent) async -> INBooleanResolutionResult {
        return .success(with: intent.disablePixelTheme?.boolValue ?? true)
    }
    
    func provideHeadToHeadOptionsCollection(for intent: HeadToHeadConfigurationIntent) async throws -> INObjectCollection<WidgetHeadToHead> {
        let headToHeads = try await AppDatabase.shared.fetchAllHeadToHeads()
        
        let widgetHeadToHeads = headToHeads.compactMap { h2h in
            
            let widgetCampaign1 = INWidgetCampaign(identifier: h2h.campaign1.id.uuidString, display: "\(h2h.campaign1.user.name) - \(h2h.campaign1.title)")
            widgetCampaign1.slug = h2h.campaign1.slug
            widgetCampaign1.vanity = h2h.campaign1.user.slug
            
            let widgetCampaign2 = INWidgetCampaign(identifier: h2h.campaign2.id.uuidString, display: "\(h2h.campaign2.user.name) - \(h2h.campaign2.title)")
            widgetCampaign2.slug = h2h.campaign2.slug
            widgetCampaign2.vanity = h2h.campaign2.user.slug
            
            let widgetHeadToHead = WidgetHeadToHead(identifier: h2h.headToHead.id.uuidString, display: "\(h2h.campaign1.user.name) vs. \(h2h.campaign2.user.name)")
            widgetHeadToHead.campaign1 = widgetCampaign1
            widgetHeadToHead.campaign2 = widgetCampaign2
            
            return widgetHeadToHead
        }
        
        return INObjectCollection(items: widgetHeadToHeads)
    }
}
