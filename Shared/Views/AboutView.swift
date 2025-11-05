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
    
    @AppStorage(UserDefaults.appAppearanceKey, store: UserDefaults.shared) private var appAppearance: Int = 2
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
    
    private var stephenPostUrlString: String? = "https://512pixels.net/2025/08/st-jude-2025/"
    private var mykePostUrlString: String? = "https://www.theenthusiast.net/relay-for-st-jude-2025/"
    
    // 2024 Settings
    @AppStorage(UserDefaults.disablePixelFontKey, store: UserDefaults.shared) private var disablePixelFont: Bool = false
    @AppStorage(UserDefaults.playSoundsEvenWhenMutedKey, store: UserDefaults.shared) private var playSoundsEvenWhenMuted: Bool = false
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024: Bool = false
    @AppStorage(UserDefaults.disableCombosKey, store: UserDefaults.shared) private var disableCombos: Bool = false
    
    // 2025 Settings
    @AppStorage(UserDefaults.selectedAccentColorKey, store: UserDefaults.shared) private var selectedAccentColor: Int = Player.randomInitial.rawValue
    @AppStorage(UserDefaults.debugGlowOpacityKey, store: UserDefaults.shared) private var debugGlowOpacity: Double = 0.5
    @AppStorage(UserDefaults.debugEdgeHighlightOpacityKey, store: UserDefaults.shared) private var debugEdgeHighlightOpacity: Double = 1.0
    
    @ViewBuilder
    var headerView: some View {
        VStack(spacing: 0) {
            Image(.bannerForeground)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
    
    @ViewBuilder
    var descriptionView: some View {
        GroupBox {
            VStack {
                Text("About St. Jude")
                    .font(.title3)
                    .bold()
                    .fullWidth()
                Text("The mission of St. Jude Children’s Research Hospital is to advance cures, and means of prevention, for paediatric catastrophic diseases through research and treatment. Consistent with the vision of founder Danny Thomas, no child is denied treatment based on race, religion or a family’s ability to pay.")
                    .fullWidth()
                    .padding(.top)
                Text("Every year throughout the month of September, Relay raises money for St. Jude to help continue its mission. Read more about the reason why, and this year's fundraiser, over at 512pixels.net.")
                    .fullWidth()
                    .padding(.top)
                
                Group {
                    if let stephenPostUrlString = self.stephenPostUrlString,
                       let stephenPostUrl = URL(string: stephenPostUrlString) {
                        Link(destination: stephenPostUrl) {
                            Text("Read Stephen's post")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .fullWidth(alignment: .center)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    
                    if let mykePostUrlString = self.mykePostUrlString,
                       let mykePostUrl = URL(string: mykePostUrlString) {
                        Link(destination: mykePostUrl) {
                            Text("Read Myke's post")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .fullWidth(alignment: .center)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .padding(.top)
            }
        }
        
        GroupBox {
            VStack {
                Text("About the app")
                    .font(.title3)
                    .bold()
                    .fullWidth()
                Text("This app was developed by a group of friends from around the world, who came together thanks to Relay's membership program.")
                    .fullWidth()
                    .padding(.top)
                Link(destination: URL(string: "https://tildy.dev/")!, label: {
                    Text("tildy.dev")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .fullWidth(alignment: .center)
                })
                .buttonStyle(PrimaryButtonStyle())
                Text("Our thanks go to everybody who donates to St. Jude via our fundraiser.")
                    .fullWidth()
                    .padding(.top)
                Button(action: {
                    showSupporterSheet = true
                }) {
                    Text("Supporters")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .fullWidth(alignment: .center)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
    
    @ViewBuilder
    var settingsView: some View {
        
        GroupBox {
            Text("Settings")
                .font(.title3)
                .bold()
                .fullWidth()
            
            ToggleSetting(label: "Play Sounds When Muted",
                          setting: self.$playSoundsEvenWhenMuted, onEnable: {
                SoundEffectHelper.shared.setToPlayEvenOnMute()
            },
                          onDisable: {
                SoundEffectHelper.shared.setToOnlyPlayWhenUnmuted()
            })
            
            ToggleSetting(label: "Enable Goal Multipliers", setting: self.$disableCombos)
        }
    }
    
    @ViewBuilder
    var iconView: some View {
        GroupBox {
            VStack {
                
                Text("Icon")
                    .font(.title3)
                    .bold()
                    .fullWidth()
                
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())], alignment: .leading, spacing: 10) {
                    ForEach(AltIcon.allCases) { icon in
                        AltIconButton(currentIcon: self.$currentIcon, icon: icon)
                    }
                }
                .padding(.bottom, 10)
                
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing:0) {
                
                self.headerView
                    .padding(.top)
                
                VStack {
                    self.descriptionView
                    
                    self.settingsView
                    
                    self.iconView
                }
                .padding()
            }
            .padding(.bottom)
        }
        .background(ignoresSafeAreaEdges: .all)
        .sheet(isPresented: $showSupporterSheet) {
            NavigationView {
                SupporterView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction, content: {
                Button(action: {
                    self.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            })
        }
        .onAppear {
            self.currentIcon = AltIcon(rawValue: UIApplication.shared.alternateIconName?.replacingOccurrences(of: "icon-", with: "") ?? "regular") ?? .regular
        }
    }
}

#Preview {
    AboutView()
}

struct ToggleSetting: View {
    var label: String
    @Binding var setting: Bool
    var onEnable: (() -> Void)? = nil
    var onDisable: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            Text(label)
                .fullWidth()
            HStack {
                Button(action: {
                    self.setting = false
                    self.onDisable?()
                    
                }) {
                    Text("Yes")
                        .fontWeight(.bold)
                        .foregroundColor(!self.setting ? .black : .primary)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle(tint: !self.setting ? .accentColor : .tertiarySystemBackground))
                Button(action: {
                    self.setting = true
                    self.onEnable?()
                }) {
                    Text("No")
                        .fontWeight(.bold)
                        .foregroundColor(self.setting ? .black : .primary)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle(tint: self.setting ? .accentColor : .tertiarySystemBackground))
            }
        }
        .padding(.top)
    }
}

struct AltIconButton: View {
    @Binding var currentIcon: AltIcon?
    var icon: AltIcon
    
    @ViewBuilder
    var content: some View {
        Button(action: {
            icon.set()
            withAnimation {
                currentIcon = icon
            }
        }) {
            icon.image
                .frame(width: 75, height: 75)
        }
    }
    
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                self.content
                    .buttonStyle(.plain)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 10))
            } else {
                self.content
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 10)
            }
        }
        .shadow(color: self.currentIcon == self.icon ? Color.accentColor : .black.opacity(0.5), radius: 10)
        .scaleEffect(self.currentIcon == self.icon ? 1.0 : 0.75)
    }
}

// 2024 theme settings
/*
GroupBox {
    VStack {
        Text("Use Pixel Font")
            .bold()
        HStack {
            Button(action: {
                disablePixelFont = false
            }) {
                Text("Yes")
                    .fontWeight(.bold)
                    .foregroundColor(!disablePixelFont ? .black : .primary)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle(tint: !disablePixelFont ? .accentColor : .tertiarySystemBackground))
            Button(action: {
                disablePixelFont = true
            }) {
                Text("No")
                    .fontWeight(.bold)
                    .foregroundColor(disablePixelFont ? .black : .primary)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle(tint: disablePixelFont ? .accentColor : .tertiarySystemBackground))
        }
    }
}
 */

// 2025 theme settings
/*
GroupBox {
    VStack {
        Text("Accent Color")
            .fontWeight(.bold)
        ForEach(Player.displayOrder) { player in
            let object = player.getPlayer()
            Button(action: {
                self.selectedAccentColor = player.rawValue
            }, label: {
                HStack {
                    Image.imageAtScale(object.headImage, scale: .spriteScale)
                        .scaleEffect(x: object.facingLeft ? -1 : 1)
                    Spacer()
                    Text(object.name)
                        .fontWeight(.bold)
                        .foregroundStyle(self.selectedAccentColor == player.rawValue ? .black : .white)

                    Spacer()
                }
                .padding(.horizontal)
            })
            .buttonStyle(PrimaryButtonStyle(tint: self.selectedAccentColor == player.rawValue ? .accentColor : .tertiarySystemBackground))
        }
        
        Text("Glow opacity")
            .fontWeight(.bold)
            .padding(.top)
        Slider(value: self.$debugGlowOpacity, in: 0...1)
            .padding(.bottom)
        
        Text("Edge highlight opacity")
            .fontWeight(.bold)
        Slider(value: self.$debugEdgeHighlightOpacity, in: 0...1)
    }
}
 */
