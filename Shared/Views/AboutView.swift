//
//  AboutView.swift
//  St Jude
//
//  Created by Ben Cardy on 01/09/2022.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.dismiss) var dismiss
    @State private var showSupporterSheet: Bool = false
    
    @State private var backgroundColor: Color = .black
    @State private var forceRefresh: Bool = false
    @State private var currentIcon: AltIcon? = nil
    
    @Binding var campaignChoiceID: UUID?
    
    @AppStorage(UserDefaults.disablePixelFontKey, store: UserDefaults.shared) private var disablePixelFont: Bool = false
    @AppStorage(UserDefaults.playSoundsEvenWhenMutedKey, store: UserDefaults.shared) private var playSoundsEvenWhenMuted: Bool = false
    @AppStorage(UserDefaults.appAppearanceKey, store: UserDefaults.shared) private var appAppearance: Int = 2
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024: Bool = false
    @AppStorage(UserDefaults.disableCombosKey, store: UserDefaults.shared) private var disableCombos: Bool = false
    
    private var userColorScheme: ColorScheme? {
        switch self.appAppearance {
        case 0:
            return .light
        case 1:
            return .dark
        default:
            return self.colorScheme
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing:0) {
                AboutViewHeader()
                VStack {
                    
                    GroupBox {
                        VStack {
                            Text("About St. Jude")
                                .font(.title3)
                                .fullWidth()
                            Text("The mission of St. Jude Children’s Research Hospital is to advance cures, and means of prevention, for paediatric catastrophic diseases through research and treatment. Consistent with the vision of our founder Danny Thomas, no child is denied treatment based on race, religion or a family’s ability to pay.")
                                .fullWidth()
                                .padding(.top)
                            Text("Every year throughout the month of September, Relay raises money for St. Jude to help continue its mission. Read more about the reason why, and this year's fundraiser, over at 512pixels.net.")
                                .fullWidth()
                                .padding(.top)
                            Link(destination: URL(string: "https://512pixels.net/2025/08/st-jude-2025/")!) {
                                Text("Read Stephen's post")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .fullWidth(alignment: .center)
                            }
                            .buttonStyle(BlockButtonStyle(tint: .accentColor))
                            .padding(.top)
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle(edgeColor: .accentColor, shadowColor: .accentColor))
                    .padding(.top, -20)
                    
                    GroupBox {
                        VStack {
                            Text("About the app")
                                .font(.title3)
                                .fullWidth()
                            Text("This app was developed by a group of friends from around the world, who came together thanks to Relay's membership program.")
                                .fullWidth()
                                .padding(.top)
                            Link(destination: URL(string: "https://tildy.dev/")!, label: {
                                Text("tildy.dev")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .fullWidth(alignment: .center)
                            })
                            .buttonStyle(BlockButtonStyle(tint: .accentColor))
                            .padding(.top)
                            Text("Our thanks go to everybody who donates to St. Jude via our fundraiser.")
                                .fullWidth()
                                .padding(.top)
                            Button(action: {
                                showSupporterSheet = true
                            }) {
                                Text("Supporters")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .fullWidth(alignment: .center)
                            }
                            .buttonStyle(BlockButtonStyle(tint: .accentColor))
                            .padding(.top)
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle(edgeColor: .accentColor, shadowColor: .accentColor))
                    
                    GroupBox {
                        VStack {
                            Text("Use Pixel Font")
                            HStack {
                                Button(action: {
                                    disablePixelFont = false
                                }) {
                                    Text("Yes")
                                        .foregroundColor(disablePixelFont ? .primary : .black)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BlockButtonStyle(tint: disablePixelFont ? Color(uiColor: .systemGroupedBackground) : .accentColor))
                                Button(action: {
                                    disablePixelFont = true
                                }) {
                                    Text("No")
                                        .foregroundColor(disablePixelFont ? .black : .primary)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BlockButtonStyle(tint: disablePixelFont ? .accentColor : Color(uiColor: .systemGroupedBackground)))
                            }
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle(edgeColor: .accentColor, shadowColor: .accentColor))
                    
                    GroupBox {
                        VStack {
                            Text("Play Sounds When Muted")
                            HStack {
                                Button(action: {
                                    playSoundsEvenWhenMuted = true
                                    SoundEffectHelper.shared.setToPlayEvenOnMute()
                                }) {
                                    Text("Yes")
                                        .foregroundColor(playSoundsEvenWhenMuted ? .black : .primary)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BlockButtonStyle(tint: playSoundsEvenWhenMuted ? .accentColor : Color(uiColor: .systemGroupedBackground)))
                                Button(action: {
                                    playSoundsEvenWhenMuted = false
                                    SoundEffectHelper.shared.setToOnlyPlayWhenUnmuted()
                                }) {
                                    Text("No")
                                        .foregroundColor(playSoundsEvenWhenMuted ? .primary : .black    )
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BlockButtonStyle(tint: playSoundsEvenWhenMuted ? Color(uiColor: .systemGroupedBackground) : .accentColor))
                            }
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle(edgeColor: .accentColor, shadowColor: .accentColor))
                    
                    GroupBox {
                        VStack {
                            Text("Enable Goal Multipliers")
                            HStack {
                                Button(action: {
                                    disableCombos = false
                                }) {
                                    Text("Yes")
                                        .foregroundColor(disableCombos ? .primary : .black)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BlockButtonStyle(tint: disableCombos ? Color(uiColor: .systemGroupedBackground) : .accentColor))
                                Button(action: {
                                    disableCombos = true
                                }) {
                                    Text("No")
                                        .foregroundColor(disableCombos ? .black : .primary)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BlockButtonStyle(tint: disableCombos ? .accentColor : Color(uiColor: .systemGroupedBackground)))
                            }
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle(edgeColor: .accentColor, shadowColor: .accentColor))
                    
                    GroupBox {
                        VStack {
                            
//                            Text("Appearance")
//
//                            HStack {
//                                Button(action: {
//                                    self.appAppearance = 0
//                                }) {
//                                    Text("Light")
//                                        .foregroundColor((self.appAppearance == 0) ? .white : .primary    )
//                                        .frame(maxWidth: .infinity)
//                                }
//                                .buttonStyle(BlockButtonStyle(tint: (self.appAppearance == 0) ? .accentColor : Color(uiColor: .systemGroupedBackground)))
//                                Button(action: {
//                                    self.appAppearance = 1
//                                }) {
//                                    Text("Dark")
//                                        .foregroundColor((self.appAppearance == 1) ? .white : .primary    )
//                                        .frame(maxWidth: .infinity)
//                                }
//                                .buttonStyle(BlockButtonStyle(tint: (self.appAppearance == 1) ? .accentColor : Color(uiColor: .systemGroupedBackground)))
//                                if dynamicTypeSize < .large {
//                                    systemAppearanceButton
//                                }
//                            }
//                            if dynamicTypeSize >= .large {
//                                systemAppearanceButton
//                            }
                            
                            Text("Icon")
                                .padding(.top, 5)
                            
                            LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())], spacing: 10) {
                                ForEach(AltIcon.allCases) { icon in
                                    VStack {
                                        Button(action: {
                                            icon.set()
                                            withAnimation {
                                                self.currentIcon = icon
                                            }
                                        }) {
                                            icon.image
                                                .frame(width: 60, height: 60)
                                        }
                                        .buttonStyle(BlockButtonStyle(tint: icon == currentIcon ? .accentColor : .secondarySystemBackground))
                                    }
                                }
                            }
                            .padding(.bottom, 10)
                            
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .groupBoxStyle(BlockGroupBoxStyle(edgeColor: .accentColor, shadowColor: .accentColor))
                    
                    Button(action: {
                        self.dismiss()
                    }, label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.black)
                            .fullWidth(alignment: .center)
                    })
                    .buttonStyle(BlockButtonStyle(tint: .accentColor))
                    .padding([.top, .horizontal])
                    
                }
                .padding()
                .background {
                    Color.arenaFloor
                }
            }
        }
        .background {
            Color.arenaFloor
        }
        .background(ignoresSafeAreaEdges: .all)
        .sheet(isPresented: $showSupporterSheet) {
            SupporterView()
        }
        .onAppear {
            self.currentIcon = AltIcon(rawValue: UIApplication.shared.alternateIconName?.replacingOccurrences(of: "icon-", with: "") ?? "original") ?? .original
        }
    }
    
    @ViewBuilder
    var systemAppearanceButton: some View {
        Button(action: {
            self.appAppearance = 2
        }) {
            Text("System")
                .foregroundColor((self.appAppearance == 2) ? .black : .primary    )
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(BlockButtonStyle(tint: (self.appAppearance == 2) ? .accentColor : Color(uiColor: .systemGroupedBackground)))
    }
    
}

struct FlowerPosition: Identifiable {
    var id = UUID()
    
    var offset: CGFloat
    var tall: Bool
}

struct AboutViewHeader: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(spacing: 0) {
            Image(.bannerForeground)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 80)
                .colorScheme(.dark)
        }
        .background {
            VStack(spacing: 0) {
                SkyView2025()
                TiledArenaFloorView()
            }
        }
        .overlay(alignment: .bottom) {
            Group {
                StandingToThrowingView(player: .stephen)
                StandingToThrowingView(player: .myke, isMirrored: true)
            }
            .padding(.bottom, 30)
            .padding(.horizontal)
        }
    }
}

#Preview {
    AboutView(campaignChoiceID: .constant(nil))
}
