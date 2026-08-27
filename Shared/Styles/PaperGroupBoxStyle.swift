//
//  PaperGroupBoxStyle.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/26/26.
//

import SwiftUI

struct PaperGroupBoxStyle: GroupBoxStyle {
    
    var tint: Color = .white
    
    enum CornerStyle: CaseIterable {
        case fold
        case tear
        case plain
    }
    
    var topLeadingCornerImage: ImageResource {
        let style = CornerStyle.allCases.randomElement() ?? .plain
        
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
        let style = CornerStyle.allCases.randomElement() ?? .plain
        
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
        let style = CornerStyle.allCases.randomElement() ?? .plain
        
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
        let style = CornerStyle.allCases.randomElement() ?? .plain
        
        switch style {
        case .fold:
            return .paperFoldBR
        case .tear:
            return .paperTearBR
        default:
            return .paperPlainBR
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            configuration.content
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
                .colorMultiply(self.tint)
                .overlay(alignment: .top) {
                    Image.imageAtScale(.paperNail, scale: Theme.current.imageScale * 0.75)
                        .offset(y: 2)
                }
            }
            .compositingGroup()
            .shadow(radius: 10)
            .rotationEffect(.degrees(Double.random(in: -0.5...0.5)))
    }
}
