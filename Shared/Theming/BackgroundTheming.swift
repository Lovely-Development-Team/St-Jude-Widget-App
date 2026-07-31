//
//  BackgroundTheming.swift
//  St Jude
//
//  Created by Justin Hamilton on 6/23/26.
//

import SwiftUI

extension Theme {
    @ViewBuilder
    func topViewLandscape(forMainScreen: Bool = true) -> some View {
        switch self {
        case .campaign2024:
            RandomLandscapeView()
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    var skyView: some View {
        switch self {
        case .campaign2024:
            SkyView()
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    var landscapeToBackgroundTransition: some View {
        switch self {
        case .campaign2024:
            Image.tiledImageAtScale(.groundRepeatable2024, axis: .horizontal)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    var backgroundView: some View {
        switch self {
        case .campaign2024:
            Image.tiledImageAtScale(.undergroundRepeatable2024)
        default:
            EmptyView()
        }
    }
}
