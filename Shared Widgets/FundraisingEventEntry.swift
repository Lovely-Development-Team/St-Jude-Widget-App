//
//  FundraisingEventEntry.swift
//  St Jude
//
//  Created by David Stephens on 30/08/2022.
//

import WidgetKit

struct FundraisingEventEntry: TimelineEntry {
    let date: Date
    let configuration: FundraisingEventConfigurationIntent
    let campaign: TiltifyWidgetData
}
