//
//  St_JudeApp.swift
//  Shared
//
//  Created by David on 21/08/2021.
//

import SwiftUI
import WidgetKit
import Intents

@main
struct St_JudeApp: App {
    @Environment(\.scenePhase) private var scenePhase
#if os(iOS)
    @UIApplicationDelegateAdaptor(StJudeAppDelegate.self) var appDelegate
#endif
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                CampaignList()
                    .onChange(of: scenePhase) { newValue in
                        if newValue == .active {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(.stack)
            .environment(\.font, Font.body)
        }
    }
}
