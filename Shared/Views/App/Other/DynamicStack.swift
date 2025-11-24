//
//  DynamicStack.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/19/25.
//

import SwiftUI

struct DynamicStack<Content: View>: View {
    var direction: Axis
    var spacing: CGFloat = 10
    var alignment: Alignment = .center
    @ViewBuilder var content: Content
    
    var body: some View {
        if self.direction == .horizontal {
            HStack(alignment: self.alignment.verticalComponent, spacing: self.spacing) {
                self.content
            }
        } else if self.direction == .vertical {
            VStack(alignment: self.alignment.horizontalComponent, spacing: self.spacing) {
                self.content
            }
        }
    }
}

extension Alignment {
    var horizontalComponent: HorizontalAlignment {
        switch self {
        case .bottomLeading, .leading, .topLeading:
            return .leading
        case .bottom, .center, .top:
            return .center
        case .bottomTrailing, .trailing, .topTrailing:
            return .trailing
        default:
            return .center
        }
    }
    
    var verticalComponent: VerticalAlignment {
        switch self {
        case .topLeading, .top, .topTrailing:
            return .top
        case .leading, .center, .trailing:
            return .center
        case .bottomLeading, .bottom, .bottomTrailing:
            return .bottom
        default:
            return .center
        }
    }
}
