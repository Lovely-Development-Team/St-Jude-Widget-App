//
//  PrimaryButtonStyle.swift
//  St Jude
//
//  Created by Justin Hamilton on 10/31/25.
//

import SwiftUI

struct ImageButtonStyle: ButtonStyle {
    var background: ImageResource
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background {
//                Image.tiledImageAtScale(self.background, scale: 1.0)
                Image(self.background)
                    .resizable()
                    .shadow(radius: 10)
            }
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}
