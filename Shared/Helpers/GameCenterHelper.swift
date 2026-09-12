//
//  GameCenterHelper.swift
//  St Jude
//

import Foundation
import GameKit
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum GameCenterLeaderboard: String, Identifiable {
    case quickdraw = "quickdraw"
    case unicornHunter = "unicornhunter"
    
    var id: String { self.rawValue }
}

enum GameCenterHelper {
    private static var didAuthenticate = false

    static var isDisabled: Bool {
        UserDefaults.shared.disableGameCenter
    }

    static func authenticateIfNeeded(onAuthenticated: @escaping () -> Void = {}) {
        guard !isDisabled, !didAuthenticate else { return }
        didAuthenticate = true

        #if canImport(UIKit)
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController {
                DispatchQueue.main.async {
                    Self.topViewController()?.present(viewController, animated: true)
                }
                return
            }
            if let error {
                appLogger.warning("Game Center authentication failed: \(error.localizedDescription)")
                return
            }
            onAuthenticated()
        }
        #endif
    }
    
    static func submitScoreForQuickDraw(_ score: TimeInterval) async {
        guard !isDisabled else { return }
        let calculatedScore = Int(round(score * 100))
        appLogger.debug("QuickDraw score being submitted: \(calculatedScore) from \(score)")
        await submitScore(calculatedScore, for: .quickdraw)
    }

    static func submitScore(_ score: Int, for leaderboard: GameCenterLeaderboard) async {
        guard !isDisabled else { return }
        do {
            appLogger.debug("Submitting score \(score) for \(leaderboard.rawValue)")
            try await GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboard.rawValue])
        } catch {
            appLogger.warning("Game Center score submission failed: \(error.localizedDescription)")
        }
    }

    static func loadLocalPlayerBestScore(leaderboard: GameCenterLeaderboard) async -> Int? {
        guard !isDisabled, GKLocalPlayer.local.isAuthenticated else { return nil }
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboard.rawValue])
            guard let gkLeaderboard = leaderboards.first else { return nil }
            let (localPlayerEntry, _) = try await gkLeaderboard.loadEntries(for: [GKLocalPlayer.local], timeScope: .allTime)
            let score = localPlayerEntry?.score
            appLogger.debug("Loaded Game Center best score for '\(leaderboard.rawValue)': \(score.debugDescription)")
            return localPlayerEntry?.score
        } catch {
            appLogger.error("Failed to load Game Center best score for '\(leaderboard.rawValue)': \(error.localizedDescription)")
            return nil
        }
    }

    #if canImport(UIKit)
    private static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .flatMap({ $0.windows })
        .first(where: { $0.isKeyWindow })?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    #endif
}

#if canImport(UIKit)
struct GameCenterLeaderboardView: UIViewControllerRepresentable {
    let leaderboard: GameCenterLeaderboard
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let viewController = GKGameCenterViewController(leaderboardID: leaderboard.rawValue, playerScope: .global, timeScope: .allTime)
        viewController.gameCenterDelegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    final class Coordinator: NSObject, GKGameCenterControllerDelegate {
        let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            dismiss()
        }
    }
}
#endif
