//
//  AdaptiveImage.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/3/24.
//

import SwiftUI

struct AdaptiveImage: View {
    @State var colorScheme: ColorScheme
    @State var light: ImageResource
    @State var dark: ImageResource? = nil
    
    var currentImage: ImageResource {
        if let dark = self.dark, self.colorScheme == .dark {
            return dark
        } else {
            return self.light
        }
    }
    
    var body: some View {
        Image(currentImage)
    }
}

extension AdaptiveImage {
    func imageAtScale(scale: Double = 1.0) -> some View {
        Image.imageAtScale(resource: self.currentImage, scale: scale)
    }
    
    func tiledImageAtScale(scale: Double = 1.0, axis: Axis? = nil) -> some View {
        Image.tiledImageAtScale(resource: self.currentImage, scale: scale, axis: axis)
    }
}
