//
//  CampaignHelpers.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/13/24.
//

import Foundation

extension TeamEvent {
    var progressBarAmount: Double? {
        if(self.totalRaisedNumerical <= self.goalNumerical || UserDefaults.shared.disableCombos) {
            return self.percentageReached
        }
        return (self.totalRaisedNumerical.truncatingRemainder(dividingBy: self.goalNumerical))/self.goalNumerical
    }
}

extension Campaign {
    var progressBarAmount: Double? {
        if(self.totalRaisedNumerical <= self.goalNumerical || UserDefaults.shared.disableCombos) {
            return self.percentageReached
        }
        return (self.totalRaisedNumerical.truncatingRemainder(dividingBy: self.goalNumerical))/self.goalNumerical
    }
}

extension TiltifyWidgetData {
    func progressBarAmount(disableCombos: Bool = false) -> Double? {
        if(self.totalRaisedNumerical <= self.goal ?? 1 || disableCombos) {
            return self.percentageReached
        }
        return (self.totalRaisedNumerical.truncatingRemainder(dividingBy: (self.goal ?? 1)))/(self.goal ?? 1)
    }
}
