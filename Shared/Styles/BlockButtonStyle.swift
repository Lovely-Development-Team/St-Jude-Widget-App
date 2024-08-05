//
//  BlockButtonStyle.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/4/24.
//

import SwiftUI

struct BlockButtonStyle: ButtonStyle {
    @State var tint: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background {
                Group {
                    if(configuration.isPressed) {
                        BlockView(tint: self.tint, isPressed: true)
                    } else {
                        BlockView(tint: self.tint, isPressed: false)
                    }
                }
                .shadow(color: .black.opacity(configuration.isPressed ? 0 : 0.5), radius: 0, x: 10 * Double.spriteScale, y: 10 * Double.spriteScale)
                .animation(.none, value: UUID())
            }
    }
}
