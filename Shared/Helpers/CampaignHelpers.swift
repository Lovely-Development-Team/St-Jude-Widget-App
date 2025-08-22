//
//  CampaignHelpers.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/13/24.
//

import Foundation
import SwiftUI

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

extension TiltifyCampaignPollOption {
    func isMax(parentPoll: TiltifyCampaignPoll) -> Bool {
        
        // Search for ties, return false if there are any
        for option in parentPoll.options {
            if option.amountRaised.numericalValue == self.amountRaised.numericalValue {
                return false
            }
        }
        
        // Sort all options
        let sortedOptions = parentPoll.options.sorted {
            $0.amountRaised.numericalValue > $1.amountRaised.numericalValue
        }
        
        // Is self the highest one?
        return self.id == sortedOptions.first?.id
    }
    
    func percentageOfPoll(parentPoll: TiltifyCampaignPoll) -> Double {
        guard parentPoll.amountRaised.numericalValue > 0,
                self.amountRaised.numericalValue > 0,
                parentPoll.amountRaised.numericalValue > self.amountRaised.numericalValue else {
            return 0
        }
        
        return (self.amountRaised.numericalValue / parentPoll.amountRaised.numericalValue).rounded()
    }
    
    func percentageOfPollBinding<T>(parentPoll: TiltifyCampaignPoll, defaultValue: T) -> Binding<T> {
        return Binding<T>(get: {
            return self.percentageOfPoll(parentPoll: parentPoll) as? T ?? defaultValue
        }, set: {_ in})
    }
}
