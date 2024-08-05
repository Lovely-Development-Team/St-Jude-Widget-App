//
//  BlockGroupBoxStyle.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/4/24.
//

import SwiftUI

struct BlockGroupBoxStyle: GroupBoxStyle {
    @State var tint: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .background {
                BlockView(tint: self.tint)
                    .shadow(color: .black.opacity(0.5), radius: 0, x: 10 * Double.spriteScale, y: 10 * Double.spriteScale)
            }
    }
}
