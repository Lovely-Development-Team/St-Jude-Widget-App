//
//  BlockButtonStyle.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/4/24.
//

import SwiftUI

struct BlockButtonStyle: ButtonStyle {
    @State var tint: Color = .secondarySystemBackground
    @State var padding: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if(self.padding) {
                configuration.label
                    .offset(x: configuration.isPressed ? 10 * Double.spriteScale : 0, y: configuration.isPressed ? 10 * Double.spriteScale : 0)
                    .animation(.none, value: UUID())
                    .padding()
            } else {
                configuration.label
                    .offset(x: configuration.isPressed ? 10 * Double.spriteScale : 0, y: configuration.isPressed ? 10 * Double.spriteScale : 0)
                    .animation(.none, value: UUID())
            }
        }
        .background {
            Group {
                if(configuration.isPressed) {
                    BlockView(tint: self.tint, isPressed: true)
                } else {
                    BlockView(tint: self.tint, isPressed: false)
                }
            }
            .compositingGroup()
            .shadow(color: .black.opacity(configuration.isPressed ? 0 : 0.5), radius: 0, x: 10 * Double.spriteScale, y: 10 * Double.spriteScale)
            .animation(.none, value: UUID())
        }
    }
}
