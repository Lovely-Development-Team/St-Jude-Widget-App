//
//  AppDelegate.swift
//  AppDelegate
//
//  Created by David on 23/08/2021.
//

import Foundation
import UIKit
import BackgroundTasks
import WidgetKit

class StJudeAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        guard identifier == ApiClient.backgroundSessionIdentifier else {
            completionHandler()
            return
        }
        let apiClient = ApiClient.shared
        apiClient.backgroundCompletionHandler = completionHandler
        // Access the background session to make sure it is initialised
        _ = apiClient.backgroundURLSession
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "org.dwrs.st-jude.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        UserDefaults.standard.register(
            defaults: [
                "inAppShowMilestones": true,
            ]
        )
        
        initNotificationCenter()
        
        return true
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        let apiClient = ApiClient.shared
        let dataTask = apiClient.fetchCampaign { result in
            submitRefreshTask()
            switch result {
            case .failure(let error):
                dataLogger.error("Request failed: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
                refreshLogger.info("Background refresh failed")
            case .success(let response):
                let widgetData = TiltifyWidgetData(from: response.data.campaign)
                do {
                    checkSignificantAmounts(for: widgetData)
                    checkNewMilestones(for: widgetData)
                    UserDefaults.shared.set(try apiClient.jsonEncoder.encode(widgetData), forKey: "relayData")
                    WidgetCenter.shared.reloadAllTimelines()
                    refreshLogger.info("Background refresh completed successfully.")
                    task.setTaskCompleted(success: true)
                } catch {
                    dataLogger.error("Failed to store API response: \(error.localizedDescription)")
                    task.setTaskCompleted(success: false)
                    refreshLogger.info("Background refresh failed")
                }
            }
        }
        task.expirationHandler = {
            refreshLogger.warning("Background refresh ran out of time. Cancelling and resubmitting")
            dataTask?.cancel()
            submitRefreshTask()
        }
    }
}
