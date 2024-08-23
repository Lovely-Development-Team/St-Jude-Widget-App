//
//  UndegroundBackground.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/8/24.
//

import SwiftUI

struct UndergroundBackground: ViewModifier {
    var colorScheme: ColorScheme
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geometry in
                    AdaptiveImage(colorScheme: self.colorScheme, light: .undergroundRepeatable, dark: .undergroundRepeatableNight)
                        .tiledImageAtScale(scale: Double.spriteScale)
                        .frame(height:geometry.size.height + 1000)
                        .animation(.none, value: UUID())
                }
            }
    }
}
