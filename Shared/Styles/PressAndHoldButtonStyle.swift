//
//  PressAndHoldButtonStyle.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/8/24.
//

import SwiftUI

struct PressAndHoldButtonStyle: ButtonStyle {
    @State private var timer: Timer?
    
    var action: (() -> Void)
    
    @State private var pressing: Bool = false
    var timerDuration: Double = 0.05
    
    func gesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if(!self.pressing) {
                    self.pressing = true
                    self.action()
                    self.timer = Timer.scheduledTimer(withTimeInterval: self.timerDuration, repeats: true, block: { _ in
                        self.action()
                    })
                }
            }
            .onEnded { value in
                self.pressing = false
                self.timer?.invalidate()
                self.timer = nil
            }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .gesture(self.gesture())
    }
}

#Preview {
    Group {
        Button(action: {}, label: {
            Text("Press!")
        })
        .buttonStyle(PressAndHoldButtonStyle(action: {
            print("pressing")
        }))
    }
}
