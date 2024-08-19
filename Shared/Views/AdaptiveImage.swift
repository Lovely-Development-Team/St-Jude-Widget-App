//
//  AdaptiveImage.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/3/24.
//

import SwiftUI

struct AdaptiveImage: View, Identifiable {
    var id = UUID()
    
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
    var isMyke: Bool {
        let mykeImages: [ImageResource] = [
            .mykeIdle, .mykeWalk1, .mykeWalk2, .mykeWalk3, .mykeWalk4
        ]
        return mykeImages.contains(self.light)
    }
    
    var isStephen: Bool {
        let stephenImages: [ImageResource] = [
            .stephenIdle, .stephenWalk1, .stephenWalk2, .stephenWalk3, .stephenWalk4
        ]
        return stephenImages.contains(self.light)
    }
    
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
        AdaptiveImage(colorScheme: colorScheme, light: .questionBox)
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
    
    static func coinAnimation(colorScheme: ColorScheme) -> [AdaptiveImage] {
        return [
            AdaptiveImage(colorScheme: colorScheme, light: .coin1),
            AdaptiveImage(colorScheme: colorScheme, light: .coin2),
            AdaptiveImage(colorScheme: colorScheme, light: .coin3),
            AdaptiveImage(colorScheme: colorScheme, light: .coin4),
            AdaptiveImage(colorScheme: colorScheme, light: .coin5),
            AdaptiveImage(colorScheme: colorScheme, light: .coin2),
            AdaptiveImage(colorScheme: colorScheme, light: .coin3),
            AdaptiveImage(colorScheme: colorScheme, light: .coin4)
        ]
    }
    
    static func stretchSky(colorScheme: ColorScheme) -> [AdaptiveImage] {
        return [
            AdaptiveImage(colorScheme: colorScheme, light: .sky1),
            AdaptiveImage(colorScheme: colorScheme, light: .sky2),
            AdaptiveImage(colorScheme: colorScheme, light: .sky3),
            AdaptiveImage(colorScheme: colorScheme, light: .sky4),
            AdaptiveImage(colorScheme: colorScheme, light: .sky5),
            AdaptiveImage(colorScheme: colorScheme, light: .sky6),
            AdaptiveImage(colorScheme: colorScheme, light: .sky7),
            AdaptiveImage(colorScheme: colorScheme, light: .sky8),
            AdaptiveImage(colorScheme: colorScheme, light: .sky9),
            AdaptiveImage(colorScheme: colorScheme, light: .sky10),
            AdaptiveImage(colorScheme: colorScheme, light: .sky11),
            AdaptiveImage(colorScheme: colorScheme, light: .sky12),
            AdaptiveImage(colorScheme: colorScheme, light: .sky13),
            AdaptiveImage(colorScheme: colorScheme, light: .sky14),
            AdaptiveImage(colorScheme: colorScheme, light: .sky15),
            AdaptiveImage(colorScheme: colorScheme, light: .sky16),
            AdaptiveImage(colorScheme: colorScheme, light: .sky17),
            AdaptiveImage(colorScheme: colorScheme, light: .sky18),
            AdaptiveImage(colorScheme: colorScheme, light: .sky19),
            AdaptiveImage(colorScheme: colorScheme, light: .sky20),
            AdaptiveImage(colorScheme: colorScheme, light: .sky21),
            AdaptiveImage(colorScheme: colorScheme, light: .sky22),
            AdaptiveImage(colorScheme: colorScheme, light: .sky23),
            AdaptiveImage(colorScheme: colorScheme, light: .sky24),
            AdaptiveImage(colorScheme: colorScheme, light: .sky25)
        ].reversed()
    }
    
    static func isoGround(colorScheme: ColorScheme) -> AdaptiveImage {
        return AdaptiveImage(colorScheme: colorScheme, light: .isoground, dark: .isogroundNight)
    }
    
    static func jonyCube(colorScheme: ColorScheme) -> AdaptiveImage {
        return AdaptiveImage(colorScheme: colorScheme, light: .jonycubePixel)
    }
    
    static func dogcow(colorScheme: ColorScheme) -> AdaptiveImage {
        return AdaptiveImage(colorScheme: colorScheme, light: .dogcow)
    }
}
