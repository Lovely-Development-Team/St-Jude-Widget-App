//
//  HeadToHeadEntry.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/31/23.
//

import UIKit
import WidgetKit

struct HeadToHeadEntry: TimelineEntry {
    let date: Date
    let configuration: HeadToHeadConfigurationIntent
    let headToHeadId: UUID?
    let campaign1: TiltifyWidgetData?
    let campaign2: TiltifyWidgetData?
    let headToHeadEnabled: Bool
    
    var widgetUrlString: String? {
        guard let id = headToHeadId else { return nil }
        return "relay-fm-for-st-jude://campaign?id=\(id)"
    }
}
