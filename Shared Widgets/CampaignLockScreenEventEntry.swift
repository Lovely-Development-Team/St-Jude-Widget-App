//
//  CampaignLockScreenEventEntry.swift
//  St Jude
//
//  Created by Ben Cardy on 05/09/2022.
//

import WidgetKit

struct CampaignLockScreenEventEntry: TimelineEntry {
    let date: Date
    let configuration: CampaignLockScreenConfigurationIntent
    let campaign: TiltifyWidgetData?
}
