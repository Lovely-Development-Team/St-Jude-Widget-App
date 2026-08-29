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
                        secondaryColor: Color? = nil,
                        id: AnyHashable? = nil) -> some View {
        switch type {
        default:
            self.primaryGroupBoxStyle(primaryColor: primaryColor ?? .secondarySystemBackground,
                                      secondaryColor: secondaryColor ?? .black, id: id)
        }
    }
    
    @ViewBuilder
    private func primaryGroupBoxStyle(primaryColor: Color,
                                      secondaryColor: Color,
                                      id: AnyHashable? = nil) -> some View {
        switch Theme.current {
        case .campaign2024:
            groupBoxStyle(BlockGroupBoxStyle(tint: primaryColor,
                                             edgeColor: secondaryColor))
        case .campaign2025:
            groupBoxStyle(BlockGroupBoxStyle(tint: secondaryColor,
                                             edgeColor: Theme.current.accentColor,
                                             shadowColor: Theme.current.accentColor))
        case .campaign2026:
            groupBoxStyle(PaperGroupBoxStyle(tint: primaryColor, id: id))
        default:
            groupBoxStyle(DefaultGroupBoxStyle())
                .backgroundStyle(primaryColor)
        }
    }
}
