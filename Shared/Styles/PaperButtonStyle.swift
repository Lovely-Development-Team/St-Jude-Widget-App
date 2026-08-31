//
//  PaperButtonStyle.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/26/26.
//

import SwiftUI

struct PaperButtonStyle: ButtonStyle {
    var tint: Color = .white
    var id: AnyHashable? = UUID()
    
    func combinedId(with other: AnyHashable) -> Int {
        let ownHash = id?.hashValue ?? UUID().hashValue
        let otherHash = other.hashValue
        
        return ownHash.hashValue &+ otherHash.hashValue
    }
    
    // TODO: the corners change whenever the view refreshes because the vars are recalculated.
    // please help fix this
    enum CornerStyle: CaseIterable {
        case fold
        case tear
        case plain
        
        static func style(for id: Int) -> Self {
            return CornerStyle.allCases[abs(id) % CornerStyle.allCases.count]
        }
        
    }
    
    var topLeadingCornerImage: ImageResource {
        let style = CornerStyle.style(for: combinedId(with: 0))
        
        switch style {
        case .fold:
            return .paperFoldTL
        case .tear:
            return .paperTearTL
        default:
            return .paperPlainTL
        }
    }
    
    var topTrailingCornerImage: ImageResource {
        let style = CornerStyle.style(for: combinedId(with: 1))
        
        switch style {
        case .fold:
            return .paperFoldTR
        case .tear:
            return .paperTearTR
        default:
            return .paperPlainTR
        }
    }
    
    var bottomLeadingCornerImage: ImageResource {
        let style = CornerStyle.style(for: combinedId(with: 2))
        
        switch style {
        case .fold:
            return .paperFoldBL
        case .tear:
            return .paperTearBL
        default:
            return .paperPlainBL
        }
    }
    
    var bottomTrailingCornerImage: ImageResource {
        let style = CornerStyle.style(for: combinedId(with: 3))
        
        switch style {
        case .fold:
            return .paperFoldBR
        case .tear:
            return .paperTearBR
        default:
            return .paperPlainBR
        }
    }
    
    var rotation: Double {
        let choice = (Double(UInt64(bitPattern: Int64(id.hashValue)) >> 11) * 0x1p-53) - 0.5
        return choice
    }
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            configuration.label
                .padding()
        }
            .background {
                ScaledNinePartImage(topLeft: self.topLeadingCornerImage,
                                    top: .paperTop,
                                    topRight: self.topTrailingCornerImage,
                                    left: .paperLeft,
                                    center: .paperCenter,
                                    right: .paperRight,
                                    bottomLeft: self.bottomLeadingCornerImage,
                                    bottom: .paperBottom,
                                    bottomRight: self.bottomTrailingCornerImage,
                                    scale: Theme.current.imageScale / 4)
                .colorMultiply(.paperColor2026)
                .colorMultiply(self.tint)
                .overlay(alignment: .top) {
                    Image.imageAtScale(.paperNail, scale: Theme.current.imageScale * 0.75)
                        .offset(y: 2)
                }
            }
            .compositingGroup()
            .shadow(radius: 10)
            .rotationEffect(.degrees(rotation))
            .opacity(configuration.isPressed ? 0.5 : 1.0)
    }
}
