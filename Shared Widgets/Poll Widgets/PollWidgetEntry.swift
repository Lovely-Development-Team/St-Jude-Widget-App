//
//  PollWidgetEntry.swift
//  Intents Extension
//
//  Created by Justin Hamilton on 9/12/26.
//

import WidgetKit

struct PollWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: PollConfigurationIntent
    
    let poll: Poll?
    let options: [PollOption]
    let parentCampaign: TiltifyWidgetData?
    let openParentCampaign: Bool
    
    var widgetURL: String {
        if let parentCampaign, self.openParentCampaign {
            return "relay-fm-for-st-jude://campaign?id=\(parentCampaign.id)"
        }
        return "relay-fm-for-st-jude://"
    }
}
