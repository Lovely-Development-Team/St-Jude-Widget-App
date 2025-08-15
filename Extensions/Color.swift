//
//  Color.swift
//  Color
//
//  Created by David on 03/09/2021.
//

import Foundation
import SwiftUI

extension Color {
    
    static func rgb(_ red: Int, _ green: Int, _ blue: Int) -> Color {
        return Color(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }
    
#if os(macOS)
    static let secondarySystemBackground = Color(NSColor.controlBackgroundColor)
#else
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
#endif
    
#if os(macOS)
    static let tertiarySystemBackground = Color(NSColor.underPageBackgroundColor)
#else
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
#endif
    
#if os(macOS)
    static let quaternarySystemFill = Color(NSColor.windowBackgroundColor)
#else
    static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)
#endif
    
    
#if os(macOS)
    static let label = Color(NSColor.labelColor)
#else
    static let label = Color(UIColor.label)
#endif
    
#if !os(macOS)
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return Color(UIColor(self).darker(by: percentage) ?? UIColor.red)
    }
#else
    public func darker(by percentage: CGFloat = 30.0) -> Color {
        return Color(NSColor(self).darker(by: percentage) ?? NSColor.red)
    }
#endif
    
#if !os(macOS)
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        return Color(UIColor(self).lighter(by: percentage) ?? UIColor.red)
    }
#else
    public func lighter(by percentage: CGFloat = 30.0) -> Color {
        return Color(NSColor(self).lighter(by: percentage) ?? NSColor.red)
    }
#endif
    
}


#if !os(macOS)
public extension UIColor {
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }

}
#elseif os(macOS)

public extension NSColor {
    
    public func lighter(by percentage: CGFloat = 30.0) -> NSColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    public func darker(by percentage: CGFloat = 30.0) -> NSColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    public func adjust(by percentage: CGFloat = 30.0) -> NSColor? {
        guard let convertedColor = self.usingColorSpace(.extendedSRGB) ?? self.usingColorSpace(.deviceRGB) else {
            colourLogger.warning("Unable to convert to extendedSRGB or deviceRGB: \(self)")
            return nil
        }
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        convertedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return NSColor(calibratedRed: min(red + percentage/100, 1.0),
                       green: min(green + percentage/100, 1.0),
                       blue: min(blue + percentage/100, 1.0),
                       alpha: alpha)
    }

}
#endif

extension Color {
    
    static func from256bit(red: Double, green: Double, blue: Double) -> Color {
        Color(.displayP3, red: red / 255, green: green / 255, blue: blue / 255, opacity: 1)
    }
    
    static let brandYellow = from256bit(red: 247, green: 206, blue: 86)
    static let brandRed = from256bit(red: 194, green: 53, blue: 76)
    static let brandBlue = from256bit(red: 81, green: 184, blue: 212)
    static let brandGreen = from256bit(red: 120, green: 184, blue: 86)
    static let brandPurple = from256bit(red: 104, green: 54, blue: 139)
    static let skyBackground = Color("sky-background")
    
    static let arenaFloor = from256bit(red: 5, green: 14, blue: 17)
    
    static var randomBrandedColor: Color {
        return [Color.brandYellow, Color.brandRed, Color.brandBlue, Color.brandGreen, Color.brandPurple].randomElement() ?? Color.brandYellow
    }
}
