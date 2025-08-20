//
//  TiledArenaFloorView.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/20/25.
//

import SwiftUI

struct TiledArenaFloorView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Color.arenaFloorSkySeparator
                .frame(height: 10 * Double.spriteScale)
            AdaptiveImage(colorScheme: self.colorScheme, light: .arenaFloorTiles)
                .tiledImageAtScale()
                .frame(height: 100)
                .mask {
                    LinearGradient(colors: [
                        .white,
                        .white,
                        .white,
                        .white,
                        .white,
                        .clear
                    ], startPoint: .top, endPoint: .bottom)
                }
        }
    }
}

#Preview {
    TiledArenaFloorView()
}
