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
    @State private var timer: Timer?
    var onStart: (() -> Void)? = nil
    var action: (() -> Void)? = nil
    var onEnd: (() -> Void)? = nil
    @State private var pressing: Bool = false
    var timerDuration: Double = 0.05
    
    var edgeColor: Color? = .accentColor
    var shadowColor: Color? = .accentColor
    
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
        .background {
            Group {
                if(self.disabled) {
                    BlockView(tint: self.tint, edgeColor: self.edgeColor, shadowColor: self.shadowColor)
                } else {
                    if(configuration.isPressed || self.pressing) {
                        BlockView(tint: self.tint, isPressed: true, edgeColor: self.tint == .secondarySystemBackground ? edgeColor : nil, shadowColor: self.shadowColor)
                    } else {
                        BlockView(tint: self.tint, isPressed: false, edgeColor: self.tint == .secondarySystemBackground ? edgeColor : nil, shadowColor: self.shadowColor)
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
