//
//  BackgroundTheming.swift
//  St Jude
//
//  Created by Justin Hamilton on 6/23/26.
//

import SwiftUI

extension Theme {
    @ViewBuilder
    func topViewLandscape(forMainScreen: Bool = true, showMyke: Bool = true, showStephen: Bool = true, showBuildings: Bool = true) -> some View {
        switch self {
        case .campaign2024:
            RandomLandscapeView(forMainScreen: forMainScreen)
        case .campaign2025:
            if forMainScreen {
                StandingThrowingView2025()
            } else {
                EmptyView()
            }
        case .campaign2026:
            LandscapeView2026(forMainScreen: forMainScreen, showMyke: showMyke, showStephen: showStephen, showBuildings: showBuildings)
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
            case .campaign2026:
                ZStack(alignment: .bottom) {
                    Color.from256bit(red: 184, green: 192, blue: 177)
                    Image(forMainScreen ? .sky2026 : .sky2026Plain)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: Double.stretchedContentMaxWidth)
                        .background(ignoresSafeAreaEdges: .all)
                        .background {
                            HStack(spacing: 0) {
                                ForEach(0..<50, id: \.self) { _ in
                                    Image(.sky2026Stretchleft)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                
                                ForEach(0..<50, id: \.self) { _ in
                                    Image(.sky2026Stretchright)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            }
                                .frame(width: 10000)
                        }
                }

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
        case .campaign2026:
            Image.tiledImageAtScale(.transition2026, scale: Theme.current.imageScale, axis: .horizontal)
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
                        case .campaign2026:
                            Image.tiledImageAtScale(.woodBackground2026, scale: Theme.current.imageScale)
                        default:
                            EmptyView()
                        }
                    }
                        .frame(height: geometry.size.height + 1000)
                }
            }
    }
    
    @ViewBuilder
    var campaignListEasterEggView: some View {
        Group {
            switch self {
            case .campaign2026:
                Image(.graveyard2026)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: Double.stretchedContentMaxWidth)
            default:
                EmptyView()
            }
        }
    }
}
