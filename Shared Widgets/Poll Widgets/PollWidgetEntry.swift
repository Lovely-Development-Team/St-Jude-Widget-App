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
}
