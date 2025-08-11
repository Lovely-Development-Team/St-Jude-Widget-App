//
//  EasterEggView.swift
//  EasterEggView
//
//  Created by Tony Scida on 9/1/21.
//

import SwiftUI

struct EasterEggView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss
    
    @State private var landscapeData = RandomLandscapeData(isForMainScreen: false)
    @State private var animate = false
    @State private var animationType: Animation? = .none
    @State private var showSupporterSheet: Bool = false
    #if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    let selectionHaptics = UISelectionFeedbackGenerator()
    #endif
    
    @AppStorage(UserDefaults.coinCountKey, store: UserDefaults.shared) private var coinCount: Int = 0
    @AppStorage(UserDefaults.easterEggEnabled2024Key, store: UserDefaults.shared) private var easterEggEnabled2024 = false
    
    @State private var showFullL2CUName = false
    private var affirmationToShow: String = "Teamwork makes the dream work!"
    
    private let affirmations: [String] = [
        "Teamwork makes the dream work!",
        "You can do it!",
        "Remember to stay hydrated!",
        "You are so strong.",
        "Do you need something to eat or drink?",
        "I am so proud of the progress you've made.",
    ]
    
    @State private var showCoinInput = false
    @State private var coinInput = ""
    
    init() {
        affirmationToShow = affirmations.randomElement() ?? "Teamwork makes the dream work!"
    }
    
    var accessibilityLabel: Text {
        Text("PixL2CU (\"Lovely to See You\") says \"\(affirmationToShow)\"")
    }
    
    @ViewBuilder var topView: some View {
        VStack(spacing:0) {
            GroupBox {
                VStack {
                    Text("Hi there!")
                        .font(.largeTitle)
                    HStack(spacing: 5) {
                        Button(action: {
                            withAnimation {
                                #if !os(macOS)
                                selectionHaptics.selectionChanged()
                                #endif
                                self.showFullL2CUName.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    self.showFullL2CUName = false
                                }
                            }
                        }) {
                            Text(showFullL2CUName ? "Lovely to See You" : "L2CU")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Text("says:")
                    }
                    .padding(.top, 1)
                    .font(.headline)
                    Text("“\(affirmationToShow)”")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .allowsTightening(true)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            }
            .padding()
            Spacer()
            
            ZStack(alignment: .top) {
                Button(action: {
                    withAnimation {
#if !os(macOS)
                        bounceHaptics.impactOccurred()
#endif
                        self.animate.toggle()
                        self.animationType = .default
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.animate.toggle()
                    }
                }) {
                    AdaptiveImage(colorScheme: self.colorScheme, light: .teamLogoF)
                        .imageAtScale(scale: .spriteScale * 2)
                        .accessibility(hidden: true)
                        .offset(x: 0, y: animate ? -5 : 0)
                        .animation(animate ? .easeInOut(duration: 0.15).repeatForever(autoreverses: true) : animationType)
                }
            }
        }
    }
    
    var body: some View {
        #if os(macOS)
        HStack {
            Spacer()
            Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                  }) {
                    Text("Dismiss")
                          .fontWeight(.semibold)
                          .foregroundColor(.blue)
                  }
                  .buttonStyle(PlainButtonStyle())
                  .padding(.horizontal, 15)
                  .padding(.vertical, 10)
        }
        #endif
        ScrollView {
            VStack(spacing:0) {
                self.topView
                VStack {
                    GroupBox {
                        VStack {
                            Text("Love our apps? \n Support our fundraiser!")
                                .allowsTightening(true)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            Link(destination: URL(string: "https://tildy.dev/stjude")!, label: {
                                Text("tildy.dev/stjude")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            })
                            .buttonStyle(RoundedAccentButtonStyle())
                        }
                    }
                    GroupBox {
                        VStack{
                            Text("Supporters")
                                .font(.title3)
                                .bold()
                                .allowsTightening(true)
                            Text("Our thanks to these awesome people for donating to our fundraiser!")
                                .font(.body)
                                .allowsTightening(true)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            Button(action: {
                                showSupporterSheet = true
                            }, label: {
                                Text("Supporters")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            })
                            .buttonStyle(RoundedAccentButtonStyle())
                        }
                    }
                    GroupBox {
                        VStack {
                            Text("L2CU drawing by rhl__.\nRelay for St. Jude crafted with care by The Lovely Developers. ")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Button(action: {
                                openURL(URL(string: "https://tildy.dev")!)
                            }, label: {
                                Text("tildy.dev")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            })
                            .buttonStyle(RoundedAccentButtonStyle())
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
                    .buttonStyle(RoundedAccentButtonStyle())
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: accessibilityLabel)
        .sheet(isPresented: $showSupporterSheet) {
            SupporterView()
        }
    }
}

struct EasterEggView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EasterEggView()
        }
    }
}
