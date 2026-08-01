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
        Group {
            switch self {
            case .campaign2024:
                SkyView()
            default:
                EmptyView()
            }
        }
        .mask {
            LinearGradient(stops: [
                .init(color: .white, location: 0),
                .init(color: .white, location: 0.5),
                .init(color: .clear, location: 0.9)
            ], startPoint: .bottom, endPoint: .top)
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
            Color.clear
                .overlay {
                    GeometryReader { geometry in
                        Image.tiledImageAtScale(.undergroundRepeatable2024)
                            .frame(height: geometry.size.height + 1000)
                    }
                }
        default:
            EmptyView()
        }
    }
}
