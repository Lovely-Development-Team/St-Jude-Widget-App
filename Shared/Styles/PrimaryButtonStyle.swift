//
//  PrimaryButtonStyle.swift
//  St Jude
//
//  Created by Justin Hamilton on 10/31/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var tint: Color = .accentColor
    var useCapsuleShape: Bool = true
    var cornerRadius: CGFloat = 10
    var useBoldText: Bool = true
    
    @ViewBuilder
    func content(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .bold(self.useBoldText)
    }
    
    @ViewBuilder
    func capsuleShape(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            self.content(configuration: configuration)
                .contentShape(Capsule())
                .glassEffect(.regular.tint(self.tint).interactive())
        } else {
            self.content(configuration: configuration)
                .background {
                    self.tint
                }
                .contentShape(Capsule())
                .shadow(radius: self.cornerRadius)
                .opacity(configuration.isPressed ? 0.5 : 1.0)
        }
    }
    
    @ViewBuilder
    func roundRectShape(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            self.content(configuration: configuration)
                .contentShape(RoundedRectangle(cornerRadius: self.cornerRadius))
                .glassEffect(.regular.tint(self.tint).interactive(), in: .rect(cornerRadius: self.cornerRadius))
        } else {
            self.content(configuration: configuration)
                .background {
                    self.tint
                }
                .contentShape(RoundedRectangle(cornerRadius: self.cornerRadius))
                .shadow(radius: self.cornerRadius)
                .opacity(configuration.isPressed ? 0.5 : 1.0)
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        if self.useCapsuleShape {
            self.capsuleShape(configuration: configuration)
        } else {
            self.roundRectShape(configuration: configuration)
        }
    }
}
