//
//  HeadToHeadEntry.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/31/23.
//

import WidgetKit

struct HeadToHeadEntry: TimelineEntry {
    let date: Date
    let configuration: HeadToHeadConfigurationIntent
    let campaign1: TiltifyWidgetData?
    let campaign2: TiltifyWidgetData?
    let testString: String
}
