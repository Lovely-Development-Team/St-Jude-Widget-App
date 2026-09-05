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
    private var channelFetchTask: Task<Void, Never>?
    private var channelId: String?

    init() {
        pushToStartTokenTask = Task {
            for await token in Activity<ScoreAttributes>.pushToStartTokenUpdates {
                await ApiClient.shared.uploadPushToken(tokenType: .liveActivityStart, scopeId: ScoreAttributes().activityType, token: token)
            }
        }
        channelFetchTask = Task {
            channelId = await ApiClient.shared.fetchLiveActivityChannelId()
        }
    }

    deinit {
        pushToStartTokenTask?.cancel()
        channelFetchTask?.cancel()
    }

    @available(iOS 18.0, *)
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
                
                if channelId == nil {
                    channelId = await ApiClient.shared.fetchLiveActivityChannelId()
                }
                
                guard let channelId else {
                    apiLogger.error("Channel ID unexpectedly nil")
                    return
                }

                let activity = try Activity.request(
                    attributes: scoreAttributes,
                    content: .init(state: initialState, staleDate: nil),
                    pushType: .channel(channelId)
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
