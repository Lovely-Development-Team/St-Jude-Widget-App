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
    private var pushToStartTokenTask: Task<Void, Never>?
    private var pushTokenUpdatesTask: Task<Void, Never>?

    init() {
        pushToStartTokenTask = Task {
            for await token in Activity<ScoreAttributes>.pushToStartTokenUpdates {
                await ApiClient.shared.uploadPushToken(tokenType: .liveActivityStart, scopeId: ScoreAttributes().activityType, token: token)
            }
        }
    }

    deinit {
        pushToStartTokenTask?.cancel()
        pushTokenUpdatesTask?.cancel()
    }

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

                let activity = try Activity.request(
                    attributes: scoreAttributes,
                    content: .init(state: initialState, staleDate: nil),
                    pushType: .token
                )
                appLogger.info("Started live activity")

                pushTokenUpdatesTask?.cancel()
                pushTokenUpdatesTask = Task {
                    for await token in activity.pushTokenUpdates {
                        await ApiClient.shared.uploadPushToken(tokenType: .liveActivityUpdate, scopeId: activity.id, token: token)
                    }
                }
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
