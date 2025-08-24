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
    
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(UserDefaults.disablePixelFontKey, store: UserDefaults.shared) private var disablePixelFont: Bool = false
    @AppStorage(UserDefaults.selectedAccentColorKey, store: UserDefaults.shared) private var selectedAccentColorKey = 0
    @State private var mainAppViewID = UUID()
    @State private var navTitle = "Relay for St. Jude"
    
    @State private var globalAlertTitle = ""
    @State private var globalAlertMessage = ""
    @State private var globalAlertShown = false
    
    private var selectedAccentColor: Color {
        return (Player(rawValue: self.selectedAccentColorKey) ?? .randomInitial).getPlayer().color
    }
    
    @AppStorage(UserDefaults.appAppearanceKey, store: UserDefaults.shared) private var appAppearance: Int = 2
    
    private var userColorScheme: ColorScheme? {
        switch self.appAppearance {
        case 0:
            return .light
        case 1:
            return .dark
        default:
            return nil
        }
    }

    func changeSystemButtomColor(){
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(self.selectedAccentColor)
    }
    
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
//                    .navigationTitle(navTitle)
            }
            .id(mainAppViewID)
            .navigationViewStyle(.stack)
            .environment(\.font, Font.body)
            .onChange(of: disablePixelFont) { newValue in
                mainAppViewID = UUID()
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onChange(of: appAppearance) { newValue in
                mainAppViewID = UUID()
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onAppear(){
                changeSystemButtomColor()
            }
            .onChange(of: selectedAccentColorKey){
                changeSystemButtomColor()
            }
            .preferredColorScheme(.dark)
            .onReceive(NotificationCenter.default.publisher(for: .displayGlobalNotification)) { message in
                guard let userInfo = message.userInfo,
                      let title = userInfo[NotificationCenter.globalNotificationTitleKey] as? String,
                      let message = userInfo[NotificationCenter.globalNotificationMessageKey] as? String else {
                    return
                }
                globalAlertTitle = title
                globalAlertMessage = message
                globalAlertShown = true
            }
            .alert(globalAlertTitle, isPresented: $globalAlertShown, actions: {
                Button(action: {
                    globalAlertTitle = ""
                    globalAlertMessage = ""
                    globalAlertShown = false
                }, label: {
                    Text("OK")
                })
            }, message: {
                Text(globalAlertMessage)
            })
            .accentColor(self.selectedAccentColor)
            .tint(self.selectedAccentColor)
            .onAppear {
                // set the default accent color to either myke or stephen. hilarious prank
                if UserDefaults.shared.object(forKey: UserDefaults.selectedAccentColorKey) == nil {
                    UserDefaults.shared.selectedAccentColor = Player.randomInitial.rawValue
                }
            }
        }
    }
}
