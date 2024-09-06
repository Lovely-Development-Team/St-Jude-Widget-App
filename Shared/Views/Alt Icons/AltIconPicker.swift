//
//  AltIconPicker.swift
//  St Jude (iOS)
//
//  Created by Ben Cardy on 02/09/2024.
//

import UIKit
import SwiftUI

struct AltIconPicker: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var chosenIconName: String? = nil
    @State private var showSecretsAlert: Bool = false
    
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024: Bool = false
    
    let iconWidth: CGFloat = 80
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack {
                    Spacer()
                    Text("Choose your icon")
                        .font(.title)
                        .padding(.top)
                    Spacer()
                    AdaptiveImage.groundRepeatable(colorScheme: self.colorScheme)
                        .tiledImageAtScale(axis: .horizontal)
                }
                .frame(minHeight: 120)
                .background {
                    SkyView()
//                        .mask {
//                            LinearGradient(stops: [
//                                .init(color: .clear, location: 0),
//                                .init(color: .white, location: 0.25),
//                                .init(color: .white, location: 1)
//                            ], startPoint: .top, endPoint: .bottom)
//                        }
                }
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())], spacing: 10) {
                    ForEach(AltIcon.allCases) { icon in
                        VStack {
                            if (!icon.isCursed || easterEggEnabled2024) {
                                Button(action: {
                                    setIcon(to: icon)
                                }) {
                                    icon.image
                                        .frame(width: iconWidth, height: iconWidth)
                                }
                                .buttonStyle(BlockButtonStyle(tint: icon.fileName == chosenIconName ? WidgetAppearance.skyBlue : .secondarySystemBackground))
                            } else {
                                Button(action: {
                                    self.showSecretsAlert = true
                                }) {
                                    ZStack {
                                        icon.image
                                            .frame(width: iconWidth, height: iconWidth)
                                            .blur(radius: 10)
                                        Image(.pixelQuestion)
                                            .imageScale(.large)
                                    }
                                }
                                .buttonStyle(BlockButtonStyle(tint: icon.fileName == chosenIconName ? WidgetAppearance.skyBlue : .secondarySystemBackground))
                            }
                        }
                    }
                }
                .padding()
            }
            .background {
                GeometryReader { geometry in
                    AdaptiveImage(colorScheme: self.colorScheme, light: .undergroundRepeatable, dark: .undergroundRepeatableNight)
                        .tiledImageAtScale(scale: Double.spriteScale)
                        .frame(height:geometry.size.height + 1000)
                        .animation(.none, value: UUID())
                }
            }
            .task {
                chosenIconName = UIApplication.shared.alternateIconName
            }
        }
        .background {
            Color.skyBackground
        }
        .alert("Secrets!", isPresented: self.$showSecretsAlert, actions: {
            Button(action: {}, label: {
                Text("Who knows!")
            })
        }, message: {
            Text("What could be hiding under here?")
        })
    }
    
    func setIcon(to icon: AltIcon) {
        icon.set()
        chosenIconName = icon.fileName
    }
    
}

#Preview {
    AltIconPicker()
}
