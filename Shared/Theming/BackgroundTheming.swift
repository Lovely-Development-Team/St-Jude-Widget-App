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
            RandomLandscapeView(forMainScreen: forMainScreen)
        case .campaign2025:
            if forMainScreen {
                StandingThrowingView2025()
            } else {
                EmptyView()
            }
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func skyView(forMainScreen: Bool = true) -> some View {
        Group {
            switch self {
            case .campaign2024:
                SkyView()
            case .campaign2025:
                SkyView2025(fadeOut: true, showGraffiti: forMainScreen)
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
        Color.clear
            .overlay {
                GeometryReader { geometry in
                    Group {
                        switch self {
                        case .campaign2024:
                            Image.tiledImageAtScale(.undergroundRepeatable2024)
                        case .campaign2025:
                            Color.arenaFloor
                        default:
                            EmptyView()
                        }
                    }
                        .frame(height: geometry.size.height + 1000)
                }
            }
    }
}
