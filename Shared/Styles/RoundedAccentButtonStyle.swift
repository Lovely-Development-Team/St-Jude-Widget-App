//
//  RoundedAccentButtonStyle.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/1/25.
//

import SwiftUI

struct RoundedAccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .padding(.horizontal, 20)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
    }
}
