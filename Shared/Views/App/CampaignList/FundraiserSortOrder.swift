//
//  FundraiserSortOrder.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/18/25.
//

import Foundation

enum FundraiserSortOrder: Int, CaseIterable {
    case byName
    case byAmountRaised
    case byAmountRemaining
    case byGoal
    case byPercentage
    
    var description: String {
        switch self {
        case .byName:
            return "Name"
        case .byAmountRaised:
            return "Amount Raised"
        case .byGoal:
            return "Goal"
        case .byPercentage:
            return "Percentage"
        case .byAmountRemaining:
            return "Amount Remaining"
        }
    }
    
    var iconName: String {
        switch self {
        case .byName:
            return "characters.lowercase"
        case .byAmountRaised, .byAmountRemaining:
            return "dollarsign.arrow.trianglehead.counterclockwise.rotate.90"
        case .byGoal:
            return "dollarsign.circle.fill"
        case .byPercentage:
            return "percent"
        }
    }
}
