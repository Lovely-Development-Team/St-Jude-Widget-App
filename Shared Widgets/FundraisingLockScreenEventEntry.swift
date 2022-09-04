//
//  FundraisingLockScreenEventEntry.swift
//  St Jude
//
//  Created by Ben Cardy on 04/09/2022.
//

import WidgetKit

struct FundraisingLockScreenEventEntry: TimelineEntry {
    let date: Date
    let configuration: FundraisingEventLockScreenConfigurationIntent
    let campaign: TiltifyWidgetData
}
