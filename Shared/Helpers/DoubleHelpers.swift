//
//  DoubleHelpers.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/2/24.
//

import Foundation
import UIKit

extension Double {
    static var stretchedContentMaxWidth: Double = 500
    
    static var spriteScale = 0.25
    static var questionBoxWidth = (10 * 24) * Double.spriteScale
    static var hostSpriteWidth = (10 * 18) * Double.spriteScale
    
    static var dogcowSpriteWidth = (10 * 42) * Double.spriteScale
    static var jonycubeSpriteWidth = (10 * 34) * Double.spriteScale
    
    static var screenWidth: Double {
        if(UIDevice.current.orientation.isPortrait) {
            return UIScreen.main.bounds.width
        } else {
            return UIScreen.main.bounds.height
        }
    }
    
    func roundDown(toNearest value: Double) -> Double {
        return floor(self/value)*value
    }
}
