//
//  TextHelpers.swift
//  St Jude
//
//  Created by Ben Cardy on 31/08/2023.
//

import Foundation
import SwiftUI

struct FullWidthText: ViewModifier {

    var alignment: TextAlignment = .leading

    var frameAlignment: Alignment {
        switch alignment {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        case .center:
            return .center
        }
    }

    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(alignment)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: frameAlignment)
    }
}

extension View {
    func fullWidth(alignment: TextAlignment = .leading) -> some View {
        modifier(FullWidthText(alignment: alignment))
    }
}
