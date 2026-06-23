//
//  ButtonTheming.swift
//  St Jude
//
//  Created by Justin Hamilton on 6/13/26.
//

import SwiftUI

enum ButtonType {
    case primary
    case secondary
    case plain
}

extension View {
    @ViewBuilder
    func themedButton(type: ButtonType = .primary,
                      tint: Color? = nil,
                      textColor: Color = Theme.current.contentColorForAccent,
                      capsuleShape: Bool = true,
                      boldText: Bool = true) -> some View {
        switch type {
        case .secondary:
            self.themedSecondaryButton(tint: tint ?? .secondarySystemBackground,
                                       textColor: textColor,
                                       capsuleShape: capsuleShape,
                                       boldText: boldText)
        case .plain:
            buttonStyle(PlainButtonStyle())
        default:
            self.themedPrimaryButton(tint: tint ?? Theme.current.accentColor,
                                     textColor: textColor,
                                     capsuleShape: capsuleShape,
                                     boldText: boldText)
        }
    }
    
    @ViewBuilder
    private func themedPrimaryButton(tint: Color,
                                     textColor: Color,
                                     capsuleShape: Bool,
                                     boldText: Bool) -> some View {
        switch Theme.current {
        case .campaign2024:
            buttonStyle(BlockButtonStyle(tint: tint, overrideTextColor: textColor))
        default:
            buttonStyle(PrimaryButtonStyle(useGlass: true,
                                           tint: tint,
                                           useCapsuleShape: capsuleShape,
                                           useBoldText: boldText,
                                           overrideTextColor: textColor))
        }
    }
    
    @ViewBuilder
    private func themedSecondaryButton(tint: Color,
                                       textColor: Color,
                                       capsuleShape: Bool,
                                       boldText: Bool) -> some View {
        switch Theme.current {
        case .campaign2024:
            buttonStyle(BlockButtonStyle(tint: tint,
                                         overrideTextColor: textColor))
        default:
            buttonStyle(PrimaryButtonStyle(useGlass: false,
                                           tint: tint,
                                           useCapsuleShape: capsuleShape,
                                           useBoldText: boldText,
                                           overrideTextColor: textColor))
        }
    }
}
