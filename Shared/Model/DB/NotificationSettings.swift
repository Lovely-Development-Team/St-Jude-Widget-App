//
//  NotificationSettings.swift
//  St Jude
//
//  Created by Ben Cardy on 11/09/2022.
//

import Foundation
import GRDB

/// The NotificationSettings struct.
struct NotificationSettings: Identifiable, Hashable {
    var id: UUID
    var notifyOnGoalReached: Bool
    var notifyOnMilestonesReached: Bool
    var notifyOnNewMilestone: Bool
    var notifyOnNewReward: Bool
    var customNotificationAmount: Double?
}

extension NotificationSettings: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let id = Column(CodingKeys.id)
        static let notifyOnGoalReached = Column(CodingKeys.notifyOnGoalReached)
        static let notifyOnMilestonesReached = Column(CodingKeys.notifyOnMilestonesReached)
        static let notifyOnNewMilestone = Column(CodingKeys.notifyOnNewMilestone)
        static let notifyOnNewReward = Column(CodingKeys.notifyOnNewReward)
        static let customNotificationAmount = Column(CodingKeys.customNotificationAmount)
    }
}
