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
    @AppStorage(UserDefaults.selectedThemeKey, store: UserDefaults.shared) private var selectedThemeId: Int = 0
    
    // 2024 Settings
    @AppStorage(UserDefaults.disablePixelFontKey, store: UserDefaults.shared) private var disablePixelFont: Bool = false
    @AppStorage(UserDefaults.disableSoundsKey, store: UserDefaults.shared) private var disableSounds: Bool = false
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024: Bool = false
    @AppStorage(UserDefaults.disableCombosKey, store: UserDefaults.shared) private var disableCombos: Bool = false
    
    // 2025 Settings
    @AppStorage(UserDefaults.selectedAccentColorKey, store: UserDefaults.shared) private var selectedAccentColor: Int = Player.randomInitial.rawValue
    @AppStorage(UserDefaults.debugGlowOpacityKey, store: UserDefaults.shared) private var debugGlowOpacity: Double = 0.5
    @AppStorage(UserDefaults.debugEdgeHighlightOpacityKey, store: UserDefaults.shared) private var debugEdgeHighlightOpacity: Double = 1.0
    
    private var stephenPostUrlString: String? { "https://512pixels.net/2026/08/st-jude-2026/" }
    private var mykePostUrlString: String? { "https://www.theenthusiast.net/relay-for-st-jude-2026/" }
    
    @State private var showSupporterSheet: Bool = false
    @State private var currentIcon: AltIcon? = nil
    @State private var showExtraIcons: Bool = false
    @Binding var tldCampaign: Campaign?
    @Binding var selectedDestination: CampaignListDestination?
    
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
                                .fullWidth(alignment: .center)
                        }
                        .themedButton(type: .primary, id: "stephen-post")
                    }
                    
                    if let mykePostUrlString = self.mykePostUrlString,
                       let mykePostUrl = URL(string: mykePostUrlString) {
                        Link(destination: mykePostUrl) {
                            Text("Read Myke's post")
                                .fullWidth(alignment: .center)
                        }
                        .themedButton(type: .primary, id: "myke-post")
                    }
                }
            }
        }
        .themedGroupBox(type: .primary, id: "top-group")
        
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
                            .fullWidth(alignment: .center)
                    })
                    .themedButton(type: .primary, id: "tildy-link")
                }
                
                VStack(spacing:10) {
                    Text("Our thanks go to everybody who donates to St. Jude via our fundraiser.")
                        .fullWidth()
                    Button(action: {
                        self.showSupporterSheet = true
                    }) {
                        Text("Supporters")
                            .fullWidth(alignment: .center)
                    }
                    .themedButton(type: .primary, id: "supporter-button")
                }
            }
        }
        .themedGroupBox(type: .primary, id: "about")
    }
    
    @ViewBuilder
    var settingsView: some View {
        GroupBox {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title3)
                    .bold()
                    .fullWidth()
                
                ToggleSetting(label: "Enable Sounds", setting: self.$disableSounds)
                
                ToggleSetting(label: "Enable Goal Multipliers", setting: self.$disableCombos)
            }
        }
        .themedGroupBox(type: .primary, id: "settings-group")
        
        #if DEBUG
        GroupBox {
            VStack(spacing: 20) {
                Text("Theme")
                    .font(.title3)
                    .bold()
                    .fullWidth()
                Text("DEBUG ONLY. Selecting a theme will quit the app")
                
                ForEach(Theme.allCases, id: \.rawValue) { theme in
                    Button(action: {
                        self.selectedThemeId = theme.rawValue
                        
                        // Quit app. Some things need to reset on startup
                        exit(0)
                    }, label: {
                        Text(theme.displayString)
                            .fullWidth(alignment: .center)
                    })
                    .themedButton(type: .primary,
                                  tint: self.selectedThemeId == theme.rawValue ? Theme.current.accentColor : .secondarySystemBackground,
                                  textColor: self.selectedThemeId == theme.rawValue ? Theme.current.contentColorForAccent : .primary, id: "theme")
                }
            }
        }
        .themedGroupBox(type: .primary, id: "theme-group")
        #endif
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
                        AltIconButton(currentIcon: self.$currentIcon, icon: icon, disabled: !showExtraIcons && icon.isExtra) {
                            if let tldCampaign {
                                self.dismiss()
                                self.selectedDestination = .campaign(tldCampaign, true)
                            }
                        }
                    }
                }
            }
        }
        .themedGroupBox(type: .primary, id: "alt-icon-group")
        .task {
            self.showExtraIcons = await TLDCampaign.milestoneReached(.alternateAppIcons)
        }
    }
    
    // Change this to reflect the tools used in development
    static var aiWasUsed: Bool = false
    
    @ViewBuilder
    var noAIView: some View {
        if !Self.aiWasUsed {
            Label(title: { Text("This app was developed by humans without the use of generative AI.") },
                  icon: {
                Image(.sparkleSlash)
            })
            .fullWidth(alignment: .center)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack {
                    self.headerView
                    Theme.current.topViewLandscape(forMainScreen: false)
                }
                    .padding(.bottom)
                    .padding(.horizontal)
                    .background {
                        Theme.current.skyView(forMainScreen: false)
                    }
                
                VStack {
                    self.descriptionView
                    self.settingsView
                    self.iconView
                    Group {
                        if Theme.isThemeApplied {
                            GroupBox {
                                self.noAIView
                            }
                            .themedGroupBox(type: .primary, id: "no-ai")
                        } else {
                            self.noAIView
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.top)
                .padding(.top)
                .padding(.horizontal)
                .background {
                    VStack(spacing: 0) {
                        Theme.current.landscapeToBackgroundTransition
                        Theme.current.backgroundView
                    }
                }
            }
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
            if let appIcon = UIApplication.shared.alternateIconName {
                self.currentIcon = AltIcon(rawValue: appIcon.replacingOccurrences(of: "icon-", with: "")) ?? .defaultIcon
            } else {
                self.currentIcon = AltIcon.defaultIcon
            }            
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
    AboutView(tldCampaign: .constant(nil), selectedDestination: .constant(nil))
}
