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
                            Link(destination: URL(string: "https://512pixels.net/2025/08/st-jude-2025/")!) {
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
                        VStack(spacing: 0) {
                            
                            Text("Appearance")
                                .bold()
                                .fullWidth()
                                .padding(.bottom, 20)
                            
                            Picker(selection: self.$appAppearance, content: {
                                Text("Light")
                                    .tag(0)
                                Text("Dark")
                                    .tag(1)
                                Text("System")
                                    .tag(2)
                            }, label: {})
                            .pickerStyle(.segmented)
                            .padding(.bottom, 20)
                            
                            LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible()), .init(.flexible())], spacing: 10) {
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
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .overlay {
                                                    if icon == currentIcon {
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(lineWidth: 3)
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 10)
                            
                        }
                    }
                    
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
        .onAppear {
            self.currentIcon = AltIcon(rawValue: UIApplication.shared.alternateIconName ?? "original") ?? .original
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
