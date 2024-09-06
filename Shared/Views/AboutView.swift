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
    @State private var showChangeIconSheet: Bool = false
    
    @State private var backgroundColor: Color = .black
    @State private var forceRefresh: Bool = false
    @State private var currentIcon: String? = nil
    
    @Binding var campaignChoiceID: UUID?
    
    @AppStorage(UserDefaults.disablePixelFontKey, store: UserDefaults.shared) private var disablePixelFont: Bool = false
    @AppStorage(UserDefaults.playSoundsEvenWhenMutedKey, store: UserDefaults.shared) private var playSoundsEvenWhenMuted: Bool = false
    @AppStorage(UserDefaults.appAppearanceKey, store: UserDefaults.shared) private var appAppearance: Int = 2
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024: Bool = false
    
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
                            Link(destination: URL(string: "https://512pixels.net/2024/08/relay-for-st-jude-2024/")!) {
                                Text("Read Stephen's post")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .fullWidth(alignment: .center)
                            }
                            .buttonStyle(BlockButtonStyle(tint: .accentColor))
                            .padding(.top)
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle())
                    
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
                                    .foregroundColor(.white)
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
                                    .foregroundColor(.white)
                                    .fullWidth(alignment: .center)
                            }
                            .buttonStyle(BlockButtonStyle(tint: .accentColor))
                            .padding(.top)
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle())
                    
                    GroupBox {
                        VStack {
                            Text("Use Pixel Font")
                            HStack {
                                Button(action: {
                                    disablePixelFont = false
                                }) {
                                    Text("Yes")
                                        .foregroundColor(disablePixelFont ? .primary : .white)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BlockButtonStyle(tint: disablePixelFont ? Color(uiColor: .systemGroupedBackground) : .accentColor))
                                Button(action: {
                                    disablePixelFont = true
                                }) {
                                    Text("No")
                                        .foregroundColor(disablePixelFont ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BlockButtonStyle(tint: disablePixelFont ? .accentColor : Color(uiColor: .systemGroupedBackground)))
                            }
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle())
                    
                    GroupBox {
                        VStack {
                            Text("Play Sounds When Muted")
                            HStack {
                                Button(action: {
                                    playSoundsEvenWhenMuted = true
                                    SoundEffectHelper.shared.setToPlayEvenOnMute()
                                }) {
                                    Text("Yes")
                                        .foregroundColor(playSoundsEvenWhenMuted ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BlockButtonStyle(tint: playSoundsEvenWhenMuted ? .accentColor : Color(uiColor: .systemGroupedBackground)))
                                Button(action: {
                                    playSoundsEvenWhenMuted = false
                                    SoundEffectHelper.shared.setToOnlyPlayWhenUnmuted()
                                }) {
                                    Text("No")
                                        .foregroundColor(playSoundsEvenWhenMuted ? .primary : .white    )
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BlockButtonStyle(tint: playSoundsEvenWhenMuted ? Color(uiColor: .systemGroupedBackground) : .accentColor))
                            }
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle())
                    
                    GroupBox {
                        VStack {
                            Text("Appearance")
                            HStack {
                                Button(action: {
                                    self.appAppearance = 0
                                }) {
                                    Text("Light")
                                        .foregroundColor((self.appAppearance == 0) ? .white : .primary    )
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BlockButtonStyle(tint: (self.appAppearance == 0) ? .accentColor : Color(uiColor: .systemGroupedBackground)))
                                Button(action: {
                                    self.appAppearance = 1
                                }) {
                                    Text("Dark")
                                        .foregroundColor((self.appAppearance == 1) ? .white : .primary    )
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(BlockButtonStyle(tint: (self.appAppearance == 1) ? .accentColor : Color(uiColor: .systemGroupedBackground)))
                                if dynamicTypeSize < .large {
                                    systemAppearanceButton
                                }
                            }
                            if dynamicTypeSize >= .large {
                                systemAppearanceButton
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .groupBoxStyle(BlockGroupBoxStyle())
                    
                    Button(action: {
                        self.showChangeIconSheet = true
                    }) {
                        HStack {
                            if let currentIcon = currentIcon {
                                Image(uiImage: UIImage(named: currentIcon) ?? UIImage())
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .modifier(PixelRounding())
                            }
                            Text("Change Icon")
                                .fullWidth()
                        }
                    }
                    .buttonStyle(BlockButtonStyle())
                    
                    if(self.easterEggEnabled2024) {
                        Button(action: {
                            UserDefaults.shared.easterEggEnabled2024 = false
                            self.dismiss()
                        }, label: {
                            Text("Disable Cursed Mode")
                                .font(.headline)
                                .foregroundColor(.white)
                                .fullWidth(alignment: .center)
                        })
                        .buttonStyle(BlockButtonStyle(tint: .accentColor))
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        self.dismiss()
                    }, label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .fullWidth(alignment: .center)
                    })
                    .buttonStyle(BlockButtonStyle(tint: .accentColor))
                    .padding([.top, .horizontal])
                    
                }
                .padding()
                .background {
                    GeometryReader { geometry in
                        AdaptiveImage(colorScheme: self.colorScheme, light: .undergroundRepeatable, dark: .undergroundRepeatableNight)
                            .tiledImageAtScale(scale: Double.spriteScale)
                            .frame(height:geometry.size.height + 1000)
                            .animation(.none, value: UUID())
                    }
                }
            }
        }
        .background {
            Color.skyBackground
        }
        .background(ignoresSafeAreaEdges: .all)
        .sheet(isPresented: $showSupporterSheet) {
            SupporterView()
        }
        .sheet(isPresented: $showChangeIconSheet) {
            AltIconPicker(campaignChoiceID: self.$campaignChoiceID) { shouldQuit in
                self.showChangeIconSheet = false
                self.currentIcon = UIApplication.shared.alternateIconName ?? "AppIcon"
                if shouldQuit {
                    self.dismiss()
                }
            }
        }
        .onAppear {
            self.currentIcon = UIApplication.shared.alternateIconName ?? "AppIcon"
        }
    }
    
    @ViewBuilder
    var systemAppearanceButton: some View {
        Button(action: {
            self.appAppearance = 2
        }) {
            Text("System")
                .foregroundColor((self.appAppearance == 2) ? .white : .primary    )
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(BlockButtonStyle(tint: (self.appAppearance == 2) ? .accentColor : Color(uiColor: .systemGroupedBackground)))
    }
    
}

struct AboutViewHeader: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var cloudMoved: Bool = false
    @State private var cloudOffset: CGFloat = 200
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var flowers: [CGFloat] = []
    @State private var landscapeData = RandomLandscapeData(isForMainScreen: false)
#if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
#endif
    var body: some View {
        VStack(spacing: 0) {
            Image(.bannerForeground)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom)
            RandomLandscapeView(data: self.$landscapeData) {}
            AdaptiveImage.groundRepeatable(colorScheme: self.colorScheme)
                .tiledImageAtScale(axis: .horizontal)
        }
        .onReceive(timer) { _ in
            withAnimation {
                self.cloudOffset -= 1
            }
        }
        .background {
            ZStack(alignment: .bottom) {
                SkyView()
                ForEach(flowers, id: \.self) { flowerOffset in
                    AdaptiveImage.flower(colorScheme: self.colorScheme)
                        .imageAtScale(scale: Double.spriteScale)
                        .transition(.move(edge: .bottom))
                        .offset(x: flowerOffset, y: -20)
                }
            }
        }
        .overlay {
            ZStack(alignment: .bottom) {
                AdaptiveImage.cloud(colorScheme: self.colorScheme)
                    .imageAtScale(scale: Double.spriteScale)
                    .offset(y: -Double.spriteScale * 50)
                    .offset(x: cloudOffset)
                    .onTapGesture {
#if !os(macOS)
                        bounceHaptics.impactOccurred()
#endif
                        withAnimation {
                            self.flowers.append(self.cloudOffset)
                        }
                    }
            }
        }
    }
}

#Preview {
    AboutView(campaignChoiceID: .constant(nil))
}
