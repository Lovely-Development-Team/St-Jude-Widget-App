//
//  LiveActivityController.swift
//  St Jude
//
//  Created by David Stephens on 03/09/2026.
//

import ActivityKit
import Observation

@Observable
class LiveActivityController {
    func start() async {
        if Activity<ScoreAttributes>.activities.isEmpty,
           ActivityAuthorizationInfo().areActivitiesEnabled {
            do {
                let scoreAttributes: ScoreAttributes
                let initialState: ScoreAttributes.ContentState
                if let score = await TiltifyAPIClient.shared.fetchStJudeScore() {
                    scoreAttributes = ScoreAttributes()
                    initialState = ScoreAttributes.ContentState(
                        myke: score.myke.score, stephen: score.stephen.score
                    )
                } else {
                    scoreAttributes = ScoreAttributes()
                    initialState = ScoreAttributes.ContentState(
                        myke: 0, stephen: 0
                    )
                }
                
                _ = try Activity.request(
                    attributes: scoreAttributes,
                    content: .init(state: initialState, staleDate: nil),
                    pushType: .token
                )
                appLogger.info("Started live activity")
            } catch {
                fatalError("""
                                Couldn't start activity
                                ------------------------
                                \(String(describing: error))
                                """)
            }
        }
    }
}
