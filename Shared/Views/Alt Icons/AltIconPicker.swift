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
    @State private var showUnlockAlert: Bool = false
    
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024: Bool = false
    @AppStorage(UserDefaults.iconsUnlockedKey, store: UserDefaults.shared) private var iconsUnlocked: Bool = false
//    @State private var iconsUnlocked = true
    
    let iconWidth: CGFloat = 80
    
    @Binding var campaignChoiceID: UUID?
    
    let done: (Bool) -> ()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack {
                    Spacer()
                    Text("Choose your icon")
                        .font(.title)
                        .padding(.vertical)
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
                if !iconsUnlocked {
                    Button(action: {
                        campaignChoiceID = TLD_CAMPAIGN
                        done(true)
                    }) {
                        HStack {
                            Text("Help us reach our milestone of \(formatCurrency(from: TLDMilestones.IconsUnlocked, currency: "USD", showFullCurrencySymbol: false).1) to unlock custom icons for the app!")
                                .fullWidth()
                            Image(.pixelChevronRight)                            
                        }
                    }
                    .buttonStyle(BlockButtonStyle())
                    .padding()
                }
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())], spacing: 10) {
                    ForEach(AltIcon.allCases) { icon in
                        VStack {
                            if ((iconsUnlocked || icon == .original) && (!icon.isCursed || easterEggEnabled2024)) {
                                Button(action: {
                                    setIcon(to: icon)
                                }) {
                                    icon.image
                                        .frame(width: iconWidth, height: iconWidth)
                                }
                                .buttonStyle(BlockButtonStyle(tint: icon.fileName == chosenIconName ? WidgetAppearance.skyBlue : .secondarySystemBackground))
                            } else {
                                Button(action: {
                                    if iconsUnlocked {
                                        self.showSecretsAlert = true
                                    } else {
                                        self.showUnlockAlert = true
                                    }
                                }) {
                                    ZStack {
                                        icon.image
                                            .frame(width: iconWidth, height: iconWidth)
                                            .blur(radius: 10)
                                        if iconsUnlocked {
                                            Image(.pixelQuestion)
                                                .imageScale(.large)
                                        } else {
                                            Image(.lockFillPixel)
                                                .imageScale(.large)
                                        }
                                    }
                                }
                                .buttonStyle(BlockButtonStyle(tint: icon.fileName == chosenIconName ? WidgetAppearance.skyBlue : .secondarySystemBackground))
                            }
                        }
                    }
                }
                .padding()
                
                Button(action: {
                    done(false)
                }, label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .fullWidth(alignment: .center)
                })
                .buttonStyle(BlockButtonStyle(tint: .accentColor))
                .padding([.bottom, .horizontal])
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
        .alert("What's this?", isPresented: self.$showUnlockAlert, actions: {
            Button(action: {
                self.campaignChoiceID = TLD_CAMPAIGN
                self.done(true)
            }, label: {
                Text("Visit our campaign!")
            })
            Button(action: {}, label: {
                Text("Maybe later")
            })
        }, message: {
            Text("Help us reach our milestone of \(formatCurrency(from: TLDMilestones.IconsUnlocked, currency: "USD", showFullCurrencySymbol: false).1) to unlock custom icons for the app!")
        })
    }
    
    func setIcon(to icon: AltIcon) {
        if iconsUnlocked {
            icon.set()
            chosenIconName = icon.fileName
        } else {
            showUnlockAlert = true
        }
    }
    
}

#Preview {
    AltIconPicker(campaignChoiceID: .constant(nil)) { _ in
        
    }
}
