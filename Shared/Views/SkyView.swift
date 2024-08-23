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

struct SkyViewPreviewView: View {
    @State private var height: Double = 500
    
    var body: some View {
        SkyView()
            .frame(width: 300, height: self.height)
            .border(.black)
//        Spacer()
        Slider(value: self.$height, in: 100...1000)
    }
}

#Preview {
    SkyViewPreviewView()
}
