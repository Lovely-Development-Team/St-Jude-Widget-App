//
//  GroupBoxTheming.swift
//  St Jude
//
//  Created by Justin Hamilton on 6/13/26.
//

import SwiftUI

enum GroupBoxType {
    case primary
    case secondary
    case plain
}

extension View {
    @ViewBuilder
    func themedGroupBox(type: GroupBoxType,
                        primaryColor: Color? = nil,
                        secondaryColor: Color? = nil) -> some View {
        switch type {
        default:
            self.primaryGroupBoxStyle(primaryColor: primaryColor ?? .secondarySystemBackground,
                                      secondaryColor: .black)
        }
    }
    
    @ViewBuilder
    private func primaryGroupBoxStyle(primaryColor: Color,
                                      secondaryColor: Color) -> some View {
        switch Theme.current {
        case .campaign2024:
            groupBoxStyle(BlockGroupBoxStyle(tint: primaryColor,
                                             edgeColor: secondaryColor))
        default:
            groupBoxStyle(DefaultGroupBoxStyle())
        }
    }
}
