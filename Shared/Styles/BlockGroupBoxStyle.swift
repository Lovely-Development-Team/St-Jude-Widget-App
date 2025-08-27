//
//  BlockGroupBoxStyle.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/4/24.
//

import SwiftUI

struct BlockGroupBoxStyle: GroupBoxStyle {
    var tint: Color = .secondarySystemBackground
    var padding: Bool = true
    
    var edgeColor: Color? = .accentColor
    var shadowColor: Color? = .accentColor
    var scale: Double = Double.spriteScale
    
    var overridePositions: [ScaledNinePartImage.EdgePosition: ScaledNinePartImage.EdgePosition] = [:]
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if(self.padding) {
                configuration.content
                    .padding()
            } else {
                configuration.content
            }
        }
            .compositingGroup()
            .background {
                BlockView(tint: self.tint, scale: scale, edgeColor: self.edgeColor, shadowColor: self.shadowColor, overridePositions: self.overridePositions)
            }
    }
}
