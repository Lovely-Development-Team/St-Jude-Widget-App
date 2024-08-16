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
    
    @AppStorage(UserDefaults.disablePixelFontKey, store: UserDefaults.shared) private var disablePixelFont: Bool = false
    @State private var mainAppViewID = UUID()
    @State private var navTitle = "Relay for St. Jude"
    
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
                    .navigationTitle(navTitle)
            }
            .id(mainAppViewID)
            .navigationViewStyle(.stack)
            .environment(\.font, Font.body)
            .onChange(of: disablePixelFont) { newValue in
                mainAppViewID = UUID()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
