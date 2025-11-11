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
    
    @AppStorage(UserDefaults.appAppearanceKey, store: UserDefaults.shared) private var appAppearance: Int = 2
    
    // 2024 Settings
    @AppStorage(UserDefaults.disablePixelFontKey, store: UserDefaults.shared) private var disablePixelFont: Bool = false
    @AppStorage(UserDefaults.playSoundsEvenWhenMutedKey, store: UserDefaults.shared) private var playSoundsEvenWhenMuted: Bool = false
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024: Bool = false
    @AppStorage(UserDefaults.disableCombosKey, store: UserDefaults.shared) private var disableCombos: Bool = false
    
    // 2025 Settings
    @AppStorage(UserDefaults.selectedAccentColorKey, store: UserDefaults.shared) private var selectedAccentColor: Int = Player.randomInitial.rawValue
    @AppStorage(UserDefaults.debugGlowOpacityKey, store: UserDefaults.shared) private var debugGlowOpacity: Double = 0.5
    @AppStorage(UserDefaults.debugEdgeHighlightOpacityKey, store: UserDefaults.shared) private var debugEdgeHighlightOpacity: Double = 1.0
    
    private var stephenPostUrlString: String? = "https://512pixels.net/2025/08/st-jude-2025/"
    private var mykePostUrlString: String? = "https://www.theenthusiast.net/relay-for-st-jude-2025/"
    
    @State private var showSupporterSheet: Bool = false
    @State private var currentIcon: AltIcon? = nil
    
    @ViewBuilder
    var headerView: some View {
        Image(.bannerForeground)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    @ViewBuilder
    var descriptionView: some View {
        GroupBox {
            VStack(spacing: 20) {
                Text("About St. Jude")
                    .font(.title3)
                    .bold()
                    .fullWidth()
                Text("The mission of St. Jude Children’s Research Hospital is to advance cures, and means of prevention, for paediatric catastrophic diseases through research and treatment. Consistent with the vision of founder Danny Thomas, no child is denied treatment based on race, religion or a family’s ability to pay.")
                    .fullWidth()
                Text("Every year throughout the month of September, Relay raises money for St. Jude to help continue its mission. Read more about the reason why, and this year's fundraiser, over at 512pixels.net.")
                    .fullWidth()
                
                VStack(spacing: 10) {
                    if let stephenPostUrlString = self.stephenPostUrlString,
                       let stephenPostUrl = URL(string: stephenPostUrlString) {
                        Link(destination: stephenPostUrl) {
                            Text("Read Stephen's post")
                                .foregroundColor(.black)
                                .fullWidth(alignment: .center)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    
                    if let mykePostUrlString = self.mykePostUrlString,
                       let mykePostUrl = URL(string: mykePostUrlString) {
                        Link(destination: mykePostUrl) {
                            Text("Read Myke's post")
                                .foregroundColor(.black)
                                .fullWidth(alignment: .center)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
            }
        }
        
        GroupBox {
            VStack(spacing:20) {
                Text("About the app")
                    .font(.title3)
                    .bold()
                    .fullWidth()
                VStack(spacing:10) {
                    Text("This app was developed by a group of friends from around the world, who came together thanks to Relay's membership program.")
                        .fullWidth()
                    Link(destination: URL(string: "https://tildy.dev/")!, label: {
                        Text("tildy.dev")
                            .foregroundColor(.black)
                            .fullWidth(alignment: .center)
                    })
                    .buttonStyle(PrimaryButtonStyle())
                }
                
                VStack(spacing:10) {
                    Text("Our thanks go to everybody who donates to St. Jude via our fundraiser.")
                        .fullWidth()
                    Button(action: {
                        self.showSupporterSheet = true
                    }) {
                        Text("Supporters")
                            .foregroundColor(.black)
                            .fullWidth(alignment: .center)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
    }
    
    @ViewBuilder
    var settingsView: some View {
        GroupBox {
            VStack(spacing: 20) {
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
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                self.headerView
                    .padding(.bottom)
                
                self.descriptionView
                self.settingsView
                self.iconView
            }
            .padding(.horizontal)
        }
        .navigationTitle("About")
        .sheet(isPresented: self.$showSupporterSheet) {
            SupportersView()
                .forSheet(displayMode: .large)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction, content: {
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

extension AboutView {
    func userColorScheme(appAppearance: Int, colorScheme: ColorScheme) -> ColorScheme {
        switch appAppearance {
        case 0:
            return .light
        case 1:
            return .dark
        default:
            return colorScheme
        }
    }
}

#Preview {
    AboutView()
}
