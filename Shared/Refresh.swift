//
//  Refresh.swift
//  Refresh
//
//  Created by David on 24/08/2021.
//

import Foundation
import BackgroundTasks

func submitRefreshTask() {
    let request = BGAppRefreshTaskRequest(identifier: "com.rosemaryorchard.stjude.refresh")
    // Fetch no earlier than 1 hour from now
    request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)
    
    do {
        try BGTaskScheduler.shared.submit(request)
        refreshLogger.error("Submitted background refresh task")
    } catch {
        refreshLogger.error("Could not submit background refresh task: \(error.localizedDescription)")
    }
}
