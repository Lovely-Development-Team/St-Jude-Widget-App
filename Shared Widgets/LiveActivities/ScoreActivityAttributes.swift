//
//  ScoreActivityAttributes.swift
//  St Jude
//
//  Created by David Stephens on 02/09/2026.
//

import ActivityKit


struct ScoreAttributes: ActivityAttributes {
    struct ContentState: Codable & Hashable {
        let myke: Double
        let stephen: Double
    }
    let activityType = "MykeVStephen"
}
