//
//  BlockButtonStyle.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/4/24.
//

import SwiftUI

struct BlockButtonStyle: ButtonStyle {
    var tint: Color = .secondarySystemBackground
    var padding: Bool = true
    var disabled: Bool = false
    
    var usingPressAndHoldGesture: Bool = false
    @State var timer: Timer?
    var onStart: (() -> Void)? = nil
    var action: (() -> Void)? = nil
    var onEnd: (() -> Void)? = nil
    @State var pressing: Bool = false
    var timerDuration: Double = 0.05
    
    func gesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if(!self.pressing) {
                    self.onStart?()
                    self.action?()
                    self.pressing = true
                    self.timer = Timer.scheduledTimer(withTimeInterval: self.timerDuration, repeats: true, block: { _ in
                        self.action?()
                    })
                }
            }
            .onEnded { value in
                self.pressing = false
                self.timer?.invalidate()
                self.timer = nil
                self.onEnd?()
            }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if(self.padding) {
                configuration.label
                    .offset(x: (configuration.isPressed || self.pressing) ? 10 * Double.spriteScale : 0, y: (configuration.isPressed || self.pressing) ? 10 * Double.spriteScale : 0)
                    .animation(.none, value: UUID())
                    .padding()
            } else {
                configuration.label
                    .offset(x: (configuration.isPressed || self.pressing) ? 10 * Double.spriteScale : 0, y: (configuration.isPressed || self.pressing) ? 10 * Double.spriteScale : 0)
                    .animation(.none, value: UUID())
            }
        }
        .opacity(self.disabled ? 0.5 : 1.0)
        .background {
            Group {
                if(self.disabled) {
                    BlockView(tint: self.tint)
                } else {
                    if(configuration.isPressed || self.pressing) {
                        BlockView(tint: self.tint, isPressed: true)
                    } else {
                        BlockView(tint: self.tint, isPressed: false)
                    }
                }
            }
            .compositingGroup()
            .shadow(color: self.disabled ? .clear : .black.opacity(configuration.isPressed ? 0 : 0.5), radius: 0, x: 10 * Double.spriteScale, y: 10 * Double.spriteScale)
            .animation(.none, value: UUID())
        }
        .gesture(usingPressAndHoldGesture ? self.gesture() : nil)
    }
}
