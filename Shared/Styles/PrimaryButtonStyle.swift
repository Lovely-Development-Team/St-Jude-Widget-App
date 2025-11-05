//
//  PrimaryButtonStyle.swift
//  St Jude
//
//  Created by Justin Hamilton on 10/31/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var tint: Color = .accentColor
    
    @ViewBuilder
    func content(configuration: Configuration) -> some View {
        configuration.label
            .padding()
    }
    
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            self.content(configuration: configuration)
                .glassEffect(.regular.tint(self.tint).interactive())
        } else {
            self.content(configuration: configuration)
                .background {
                    self.tint
                }
                .clipShape(Capsule())
                .shadow(radius: 10)
                .opacity(configuration.isPressed ? 0.5 : 1.0)
        }
    }
}
