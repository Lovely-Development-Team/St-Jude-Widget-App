//
//  SkyView.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/16/24.
//

import SwiftUI

struct SkyView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var overrideColorScheme: ColorScheme? = nil
    
    private var slices: [AdaptiveImage] {
        AdaptiveImage.stretchSky(colorScheme: overrideColorScheme ?? self.colorScheme)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing:-1) {
                Color.skyBackground
                VStack(spacing:-1) {
                    ForEach(self.slices) { slice in
                        slice.tiledImageAtScale()
                    }
                }
                .frame(height: Double(geometry.size.height).roundDown(toNearest: Double(10 * self.slices.count) * Double.spriteScale))
            }
            .overlay {
                Color.black
                    .opacity((self.overrideColorScheme ?? self.colorScheme) == .dark ? 0.5 : 0.0)
            }
        }
    }
}

struct SkyView2025: View {
    @Environment(\.colorScheme) var colorScheme
    var fadeOut: Bool = false
    var showGraffiti: Bool = false
    
    var body: some View {
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
    }
}

struct SkyViewPreviewView: View {
    @State private var height: Double = 500
    @State private var fadeOut: Bool = false
    @State private var showGraffiti: Bool = false
    
    var body: some View {
        SkyView2025(fadeOut: self.fadeOut, showGraffiti: self.showGraffiti)
            .frame(width: 300, height: self.height)
            .border(.black)
//        Spacer()
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
    SkyViewPreviewView()
}
