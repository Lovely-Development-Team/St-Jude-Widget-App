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
    var light: ImageResource
    var dark: ImageResource? = nil
    
    var currentImage: ImageResource {
        if let dark = self.dark, self.colorScheme == .dark {
            return dark
        } else {
            return self.light
        }
    }
    
    var body: some View {
        Image(currentImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
//            .animation(.none, value: UUID())
    }
}

extension AdaptiveImage {
    func imageAtScale(scale: Double = .spriteScale) -> some View {
        Image.imageAtScale( self.currentImage, scale: scale)
    }
    
    func tiledImageAtScale(scale: Double = .spriteScale, axis: Axis? = nil) -> some View {
        Image.tiledImageAtScale(self.currentImage, scale: scale, axis: axis)
    }
}

extension AdaptiveImage {
    var isMyke: Bool {
        let mykeImages: [ImageResource] = [
            .mykeIdle2024, .mykeWalk12024, .mykeWalk22024, .mykeWalk32024, .mykeWalk42024
        ]
        return mykeImages.contains(self.light)
    }
    
    var isStephen: Bool {
        let stephenImages: [ImageResource] = [
            .stephenIdle2024, .stephenWalk12024, .stephenWalk22024, .stephenWalk32024, .stephenWalk42024
        ]
        return stephenImages.contains(self.light)
    }
    
    @ViewBuilder
    static func background(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .background2024, dark: .background2024)
    }
    
    @ViewBuilder
    static func backgroundTall(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .backgroundTall2024, dark: .backgroundTall2024Dark)
    }
    
    @ViewBuilder
    static func backgroundStripe(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .backgroundStripe2024, dark: .backgroundStripe2024Dark)
    }
    
    @ViewBuilder
    static func backgroundStripeTall(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .backgroundStripeTall2024, dark: .backgroundStripeTall2024Dark)
    }
    
    @ViewBuilder
    static func bush(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .bush2024, dark: .bush2024Dark)
    }
    
    @ViewBuilder
    static func cloud(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .cloud2024, dark: .cloud2024Dark)
    }
    
    @ViewBuilder
    static func flower(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .flower12024, dark: .flower12024Dark)
    }
    
    static func flowerAnimation(colorScheme: ColorScheme) -> [AdaptiveImage] {
        return [
            // repeat 4 times for a full rotation
            .init(colorScheme: colorScheme, light: .flower12024, dark: .flower12024Dark),
            .init(colorScheme: colorScheme, light: .flower22024, dark: .flower22024Dark),
            .init(colorScheme: colorScheme, light: .flower32024, dark: .flower32024Dark),
            .init(colorScheme: colorScheme, light: .flower42024, dark: .flower42024Dark),
            .init(colorScheme: colorScheme, light: .flower12024, dark: .flower12024Dark),
            .init(colorScheme: colorScheme, light: .flower22024, dark: .flower22024Dark),
            .init(colorScheme: colorScheme, light: .flower32024, dark: .flower32024Dark),
            .init(colorScheme: colorScheme, light: .flower42024, dark: .flower42024Dark),
            .init(colorScheme: colorScheme, light: .flower12024, dark: .flower12024Dark),
            .init(colorScheme: colorScheme, light: .flower22024, dark: .flower22024Dark),
            .init(colorScheme: colorScheme, light: .flower32024, dark: .flower32024Dark),
            .init(colorScheme: colorScheme, light: .flower42024, dark: .flower42024Dark),
            .init(colorScheme: colorScheme, light: .flower12024, dark: .flower12024Dark),
            .init(colorScheme: colorScheme, light: .flower22024, dark: .flower22024Dark),
            .init(colorScheme: colorScheme, light: .flower32024, dark: .flower32024Dark),
            .init(colorScheme: colorScheme, light: .flower42024, dark: .flower42024Dark)
        ]
    }
    
    @ViewBuilder
    static func tallflower(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .tallflower12024, dark: .tallflower12024Dark)
    }
    
    static func tallFlowerAnimation(colorScheme: ColorScheme) -> [AdaptiveImage] {
        return [
            // repeat 4 times for a full rotation
            .init(colorScheme: colorScheme, light: .tallflower12024, dark: .tallflower12024Dark),
            .init(colorScheme: colorScheme, light: .tallflower22024, dark: .tallflower22024Dark),
            .init(colorScheme: colorScheme, light: .tallflower32024, dark: .tallflower32024Dark),
            .init(colorScheme: colorScheme, light: .tallflower42024, dark: .tallflower42024Dark),
            .init(colorScheme: colorScheme, light: .tallflower12024, dark: .tallflower12024Dark),
            .init(colorScheme: colorScheme, light: .tallflower22024, dark: .tallflower22024Dark),
            .init(colorScheme: colorScheme, light: .tallflower32024, dark: .tallflower32024Dark),
            .init(colorScheme: colorScheme, light: .tallflower42024, dark: .tallflower42024Dark),
            .init(colorScheme: colorScheme, light: .tallflower12024, dark: .tallflower12024Dark),
            .init(colorScheme: colorScheme, light: .tallflower22024, dark: .tallflower22024Dark),
            .init(colorScheme: colorScheme, light: .tallflower32024, dark: .tallflower32024Dark),
            .init(colorScheme: colorScheme, light: .tallflower42024, dark: .tallflower42024Dark),
            .init(colorScheme: colorScheme, light: .tallflower12024, dark: .tallflower12024Dark),
            .init(colorScheme: colorScheme, light: .tallflower22024, dark: .tallflower22024Dark),
            .init(colorScheme: colorScheme, light: .tallflower32024, dark: .tallflower32024Dark),
            .init(colorScheme: colorScheme, light: .tallflower42024, dark: .tallflower42024Dark)
        ]
    }
    
    @ViewBuilder
    static func groundRepeatable(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .groundRepeatable2024, dark: .groundRepeatable2024Dark)
    }
    
    @ViewBuilder
    static func arena(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .arena, dark: .arena)
    }
    
    @ViewBuilder
    static func arenaFloor(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .arenaFloorTiles, dark: .arenaFloorTiles)
    }

    @ViewBuilder
    static func ground(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .ground2024, dark: .ground2024Dark)
    }
    
    @ViewBuilder
    static func groundSlope(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .groundSlope2024, dark: .groundSlope2024Dark)
    }
    
    @ViewBuilder
    static func myke(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .mykeIdle2024)
    }
    
    @ViewBuilder
    static func skyRepeatable(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .skyRepeatable2024, dark: .skyRepeatable2024Dark)
    }
    
    @ViewBuilder
    static func stephen(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .stephenIdle2024)
    }
    
    @ViewBuilder
    static func undergroundRepeatable(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .undergroundRepeatable2024, dark: .undergroundRepeatable2024Dark)
    }
    
    @ViewBuilder
    static func questionBox(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .questionBox2024)
    }
    
    @ViewBuilder
    static func coin(colorScheme: ColorScheme) -> AdaptiveImage {
        AdaptiveImage(colorScheme: colorScheme, light: .coin2024)
    }
    
    static func mykeWalkCycle(colorScheme: ColorScheme) -> [AdaptiveImage] {
        return [
            AdaptiveImage(colorScheme: colorScheme, light: .mykeWalk12024),
            AdaptiveImage(colorScheme: colorScheme, light: .mykeWalk22024),
            AdaptiveImage(colorScheme: colorScheme, light: .mykeWalk32024),
            AdaptiveImage(colorScheme: colorScheme, light: .mykeWalk42024)
        ]
    }
    
    static func stephenWalkCycle(colorScheme: ColorScheme) -> [AdaptiveImage] {
        return [
            AdaptiveImage(colorScheme: colorScheme, light: .stephenWalk12024),
            AdaptiveImage(colorScheme: colorScheme, light: .stephenWalk22024),
            AdaptiveImage(colorScheme: colorScheme, light: .stephenWalk32024),
            AdaptiveImage(colorScheme: colorScheme, light: .stephenWalk42024)
        ]
    }
    
    static func coinAnimation(colorScheme: ColorScheme) -> [AdaptiveImage] {
        return [
            AdaptiveImage(colorScheme: colorScheme, light: .coinAnimation20241),
            AdaptiveImage(colorScheme: colorScheme, light: .coinAnimation20242),
            AdaptiveImage(colorScheme: colorScheme, light: .coinAnimation20243),
            AdaptiveImage(colorScheme: colorScheme, light: .coinAnimation20244),
            AdaptiveImage(colorScheme: colorScheme, light: .coinAnimation20245),
            AdaptiveImage(colorScheme: colorScheme, light: .coinAnimation20242),
            AdaptiveImage(colorScheme: colorScheme, light: .coinAnimation20243),
            AdaptiveImage(colorScheme: colorScheme, light: .coinAnimation20244)
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
            AdaptiveImage(colorScheme: colorScheme, light: .sky24)
        ].reversed()
    }
    
    static func isoGround(colorScheme: ColorScheme) -> AdaptiveImage {
        return AdaptiveImage(colorScheme: colorScheme, light: .isoground2024, dark: .isoground2024Dark)
    }
    
    static func jonyCube(colorScheme: ColorScheme) -> AdaptiveImage {
        return AdaptiveImage(colorScheme: colorScheme, light: .jonycubePixel2024)
    }
    
    static func dogcow(colorScheme: ColorScheme) -> AdaptiveImage {
        return AdaptiveImage(colorScheme: colorScheme, light: .dogcowIdle)
    }
    
    static func dogcowJump(colorScheme: ColorScheme) -> AdaptiveImage {
        return AdaptiveImage(colorScheme: colorScheme, light: .dogcowJump)
    }
    
    static func dogcowWalkCycle(colorScheme: ColorScheme) -> [AdaptiveImage] {
        return [
            AdaptiveImage(colorScheme: colorScheme, light: .dogcow1),
            AdaptiveImage(colorScheme: colorScheme, light: .dogcow2),
            AdaptiveImage(colorScheme: colorScheme, light: .dogcow3),
            AdaptiveImage(colorScheme: colorScheme, light: .dogcow4),
            AdaptiveImage(colorScheme: colorScheme, light: .dogcow5),
            AdaptiveImage(colorScheme: colorScheme, light: .dogcow6)
        ]
    }
    
    static func happyCleaningFace(colorScheme: ColorScheme) -> AdaptiveImage {
        return AdaptiveImage(colorScheme: colorScheme, light: .happyCleaningFace20241)
    }
    
    static func happyCleaningFaceAnimation(colorScheme: ColorScheme) -> [AdaptiveImage] {
        return [
            AdaptiveImage(colorScheme: colorScheme, light: .happyCleaningFace20241),
            AdaptiveImage(colorScheme: colorScheme, light: .happyCleaningFace20242),
            AdaptiveImage(colorScheme: colorScheme, light: .happyCleaningFace20243),
            AdaptiveImage(colorScheme: colorScheme, light: .happyCleaningFace20244),
            AdaptiveImage(colorScheme: colorScheme, light: .happyCleaningFace20241),
            AdaptiveImage(colorScheme: colorScheme, light: .happyCleaningFace20242),
            AdaptiveImage(colorScheme: colorScheme, light: .happyCleaningFace20243),
            AdaptiveImage(colorScheme: colorScheme, light: .happyCleaningFace20244)
        ]
    }
    
    static func weirdFish(colorScheme: ColorScheme) -> AdaptiveImage {
        return AdaptiveImage(colorScheme: colorScheme, light: .weirdfish2024)
    }
}
