//
//  SkyView2025.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/10/25.
//

import SwiftUI

struct SkyView2025: View {
    @Environment(\.colorScheme) var colorScheme
    var fadeOut: Bool = false
    var showGraffiti: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Color.skyBackground2025
                .overlay(alignment: .bottom) {
                    ForEach(0..<25) { i in
                        AdaptiveImage(colorScheme: self.colorScheme, light: .gradientBand)
                            .tiledImageAtScale(axis: .horizontal)
                            .opacity(0.2)
                            .offset(y: -36 * Double(i))
                    }
                }
                .overlay(alignment: .bottom) {
                    if self.showGraffiti {
                        AdaptiveImage(colorScheme: self.colorScheme, light: .arenaGraffiti)
                            .imageAtScale()
                            .offset(y: -10)
                    } else {
                        EmptyView()
                    }
                }
                .clipped()
                .mask {
                    if self.fadeOut {
                        LinearGradient(colors: [
                            .white,
                            .white,
                            .white,
                            .white,
                            .clear
                        ], startPoint: .bottom, endPoint: .top)
                    } else {
                        Color.white
                    }
                }
            TiledArenaFloorView()
        }
    }
}

struct SkyView2025PreviewView: View {
    @State private var height: Double = 500
    @State private var fadeOut: Bool = false
    @State private var showGraffiti: Bool = false
    
    var body: some View {
        SkyView2025(fadeOut: self.fadeOut, showGraffiti: self.showGraffiti)
            .frame(width: 300, height: self.height)
            .border(.black)
        VStack {
            Slider(value: self.$height, in: 100...1000)
            Toggle(isOn: self.$fadeOut, label: {
                Text("Fade Out")
            })
            Toggle(isOn: self.$showGraffiti, label: {
                Text("Graffiti")
            })
        }
    }
}

#Preview {
    SkyView2025PreviewView()
}
