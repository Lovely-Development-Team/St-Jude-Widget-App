//
//  View.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/9/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func forSheet(displayMode: NavigationBarItem.TitleDisplayMode = .inline) -> some View {
        NavigationStack {
            self
                .navigationBarTitleDisplayMode(displayMode)
        }
    }
}
