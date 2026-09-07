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

enum GameCenterHelper {
    private static var didAuthenticate = false

    static func authenticateIfNeeded() {
        guard !didAuthenticate else { return }
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
        }
        #endif
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
    let leaderboardID: String
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let viewController = GKGameCenterViewController(leaderboardID: leaderboardID, playerScope: .global, timeScope: .allTime)
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
