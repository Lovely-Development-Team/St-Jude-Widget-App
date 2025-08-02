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
    
    var enableCombosBinding: Binding<Bool> {
        return Binding<Bool>(get: {
            return !self.disableCombos
        }, set: { newValue in
            self.disableCombos = !newValue
        })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing:0) {
                Image(.bannerForeground)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.bottom)
                
                VStack {
                    
                    GroupBox {
                        VStack {
                            Text("About St. Jude")
                                .font(.title3)
                                .bold()
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
                            .buttonStyle(RoundedAccentButtonStyle())
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
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .fullWidth(alignment: .center)
                            })
                            .buttonStyle(RoundedAccentButtonStyle())
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
                            .buttonStyle(RoundedAccentButtonStyle())
                            .padding(.top)
                        }
                    }
                    
                    GroupBox {
                        Toggle(isOn: enableCombosBinding, label: {
                            Text("Enable Goal Multipliers")
                                .bold()
                        })
                        .tint(Color.accentColor)
                    }
                    
                    GroupBox {
                        VStack {
                            Text("Appearance")
                                .bold()
                            Picker(selection: self.$appAppearance, content: {
                                Text("Light")
                                    .tag(0)
                                Text("Dark")
                                    .tag(1)
                                Text("System")
                                    .tag(2)
                            }, label: {})
                            .pickerStyle(.segmented)
                        }
                    }
                    
//                    Button(action: {
//                        self.showChangeIconSheet = true
//                    }) {
//                        HStack {
//                            if let currentIcon = currentIcon {
//                                Image(uiImage: UIImage(named: currentIcon) ?? UIImage())
//                                    .resizable()
//                                    .frame(width: 50, height: 50)
//                                    .modifier(PixelRounding())
//                            }
//                            Text("Change Icon")
//                                .fullWidth()
//                        }
//                    }
                    
//                    if(self.easterEggEnabled2024) {
//                        Button(action: {
//                            UserDefaults.shared.easterEggEnabled2024 = false
//                            self.dismiss()
//                        }, label: {
//                            Text("Disable Cursed Mode")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                                .fullWidth(alignment: .center)
//                        })
//                        .padding(.horizontal)
//                    }
                    
                    Button(action: {
                        self.dismiss()
                    }, label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .fullWidth(alignment: .center)
                    })
                    .padding([.top, .horizontal])
                    .buttonStyle(RoundedAccentButtonStyle())
                    
                }
                .padding()
            }
        }
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
    }
    
}

#Preview {
    AboutView(campaignChoiceID: .constant(nil))
}
