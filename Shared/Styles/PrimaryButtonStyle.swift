//
//  PrimaryButtonStyle.swift
//  St Jude
//
//  Created by Justin Hamilton on 10/31/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var useGlass: Bool = true
    var tint: Color = Theme.current.accentColor
    var useCapsuleShape: Bool = true
    var cornerRadius: CGFloat = 10
    var useBoldText: Bool = true
    var padding: CGFloat = 15
    
    var overrideTextColor: Color? = nil
    
    @ViewBuilder
    func content(configuration: Configuration) -> some View {
        if let overrideTextColor = self.overrideTextColor {
            configuration.label
                .foregroundStyle(overrideTextColor)
                .padding(self.padding)
                .bold(self.useBoldText)
        } else {
            configuration.label
                .padding(self.padding)
                .bold(self.useBoldText)
        }
    }
    
    @ViewBuilder
    func capsuleShape(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *), self.useGlass {
            self.content(configuration: configuration)
                .contentShape(Rectangle())
                .glassEffect(.regular.tint(self.tint).interactive())
        } else {
            self.content(configuration: configuration)
                .background {
                    self.tint
                }
                .contentShape(Capsule())
                .clipShape(Capsule())
                .shadow(radius: self.cornerRadius)
                .opacity(configuration.isPressed ? 0.5 : 1.0)
        }
    }
    
    @ViewBuilder
    func roundRectShape(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *), self.useGlass {
            self.content(configuration: configuration)
                .contentShape(RoundedRectangle(cornerRadius: self.cornerRadius))
                .glassEffect(.regular.tint(self.tint).interactive(), in: .rect(cornerRadius: self.cornerRadius))
        } else {
            self.content(configuration: configuration)
                .background {
                    self.tint
                }
                .contentShape(RoundedRectangle(cornerRadius: self.cornerRadius))
                .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
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
