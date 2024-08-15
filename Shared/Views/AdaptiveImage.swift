//
//  AdaptiveImage.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/3/24.
//

import SwiftUI

struct AdaptiveImage: View {
    var colorScheme: ColorScheme
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
            .animation(.none, value: UUID())
    }
}

extension AdaptiveImage {
    func imageAtScale(scale: Double = .spriteScale) -> some View {
        Image.imageAtScale(resource: self.currentImage, scale: scale)
    }
    
    func tiledImageAtScale(scale: Double = .spriteScale, axis: Axis? = nil) -> some View {
        Image.tiledImageAtScale(resource: self.currentImage, scale: scale, axis: axis)
    }
}

extension AdaptiveImage {
    @ViewBuilder
    static func background(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .background, dark: .backgroundNight)
    }
    @ViewBuilder
    static func backgroundTall(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .backgroundTall, dark: .backgroundTallNight)
    }
    @ViewBuilder
    static func backgroundStripe(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .backgroundStripe, dark: .backgroundStripeNight)
    }
    @ViewBuilder
    static func backgroundStripeTall(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .backgroundStripeTall, dark: .backgroundStripeTallNight)
    }
    @ViewBuilder
    static func bush(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .bush, dark: .bushNight)
    }
    @ViewBuilder
    static func cloud(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .cloud, dark: .cloudNight)
    }
    @ViewBuilder
    static func flower(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .flower, dark: .flowerNight)
    }
    @ViewBuilder
    static func groundRepeatable(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .groundRepeatable, dark: .groundRepeatableNight)
    }
    @ViewBuilder
    static func ground(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .ground, dark: .groundNight)
    }
    @ViewBuilder
    static func groundSlope(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .groundSlope, dark: .groundSlopeNight)
    }
    @ViewBuilder
    static func myke(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .mykeIdle)
    }
    @ViewBuilder
    static func skyRepeatable(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .skyRepeatable, dark: .skyRepeatableNight)
    }
    @ViewBuilder
    static func stephen(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .stephenIdle)
    }
    @ViewBuilder
    static func undergroundRepeatable(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .undergroundRepeatable, dark: .undergroundRepeatableNight)
    }
    @ViewBuilder
    static func questionBox(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .questionBox, dark: .questionBoxNight)
    }
    @ViewBuilder
    static func coin(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .coin)
    }
    static func mykeWalkCycle(colorScheme: ColorScheme) -> [AdaptiveImage] {
        return [
            AdaptiveImage(colorScheme: colorScheme, light: .mykeWalk1),
            AdaptiveImage(colorScheme: colorScheme, light: .mykeWalk2),
            AdaptiveImage(colorScheme: colorScheme, light: .mykeWalk3),
            AdaptiveImage(colorScheme: colorScheme, light: .mykeWalk4)
        ]
    }
    static func stephenWalkCycle(colorScheme: ColorScheme) -> [AdaptiveImage] {
        return [
            AdaptiveImage(colorScheme: colorScheme, light: .stephenWalk1),
            AdaptiveImage(colorScheme: colorScheme, light: .stephenWalk2),
            AdaptiveImage(colorScheme: colorScheme, light: .stephenWalk3),
            AdaptiveImage(colorScheme: colorScheme, light: .stephenWalk4)
        ]
    }
}
