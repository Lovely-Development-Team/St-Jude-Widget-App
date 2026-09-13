//
//  DateHelpers.swift
//  Intents Extension
//
//  Created by Justin Hamilton on 9/12/26.
//

import Foundation
import SwiftUI

extension TimeInterval {
    static let oneDay: TimeInterval = 60 * 60 * 24
}

extension Date {
    func isInTheNext(seconds: TimeInterval) -> Bool {
        let comparisonDate = Date().addingTimeInterval(seconds)
        
        return comparisonDate >= self && self >= Date()
    }
    
    func isInTheLast(seconds: TimeInterval) -> Bool {
        let comparisonDate = Date().addingTimeInterval(-seconds)
        return comparisonDate <= self && self <= Date()
    }
}

struct DateHelperTestView: View {
    @State private var now: Date = Date()
    @State private var timeIntervalOffset: TimeInterval = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var testDate: Date {
        return self.now.addingTimeInterval(timeIntervalOffset)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Text("Now: \(ISO8601DateFormatter().string(from: self.now))")
                Text("Test date: \(ISO8601DateFormatter().string(from: self.testDate))")
                Text("Is in last 12 hours: \(self.testDate.isInTheLast(seconds: 60 * 60 * 12) ? "yes" : "no")")
                Text("Is in next 12 hours: \(self.testDate.isInTheNext(seconds: 60 * 60 * 12) ? "yes" : "no")")
                Slider(value: self.$timeIntervalOffset, in: -(60 * 60 * 24)...(60 * 60 * 24), step: 1.0)
            }
            .navigationTitle("Date Helpers Testing")
        }
        .onReceive(self.timer) { _ in
            self.now = Date()
        }
    }
}

#Preview {
    DateHelperTestView()
}
