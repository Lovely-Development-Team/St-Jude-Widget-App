//
//  SkyView.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/16/24.
//

import SwiftUI

struct SkyView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing:-1) {
            ForEach(AdaptiveImage.stretchSky(colorScheme: self.colorScheme)) { slice in
                slice.tiledImageAtScale()
            }
        }
        .overlay {
            Color.black
                .opacity(self.colorScheme == .dark ? 0.5 : 0.0)
        }
    }
}

struct SkyViewPreviewView: View {
    @State var height: Double = 500
    
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
