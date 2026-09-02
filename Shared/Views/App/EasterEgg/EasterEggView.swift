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
    
    private var affirmations: [String] {
        var list = [
            "Teamwork makes the dream work!",
            "You can do it!",
            "Remember to stay hydrated!",
            "You are so strong.",
            "Do you need something to eat or drink?",
            "I am so proud of the progress you've made.",
        ]
        
        if Theme.current == .campaign2026 {
            list.append("Yeehaw!")
        }
        
        return list
    }
    
    @State private var showCoinInput = false
    @State private var coinInput = ""
    
    private var viewTitle: String {
        if Theme.current == .campaign2026 {
            return "Howdy!"
        }
        
        return "Hi there!"
    }
    
    init() {
        affirmationToShow = affirmations.randomElement() ?? "Teamwork makes the dream work!"
    }
    
    var accessibilityLabel: Text {
        Text("PixL2CU (\"Lovely to See You\") says \"\(affirmationToShow)\"")
    }
    
    @ViewBuilder
    var topView: some View {
        VStack(spacing:0) {
            GroupBox {
                VStack {
                    HStack(spacing: 5) {
                        Button(action: {
                            withAnimation {
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
                        .themedButton(type: .plain, id: "l2cu")
                        Text("Cowbot says:")
                    }
                    Text("“\(affirmationToShow)”")
                        .font(Font.custom("KilnSansSpiked", size: UIFont.preferredFont(forTextStyle: .title3).pointSize))
                        .multilineTextAlignment(.center)
                        .allowsTightening(true)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .themedGroupBox(type: .primary, id: "l2cu-group")
        }
    }
    
    @ViewBuilder
    var mascotView: some View {
        Image(Theme.current.mascotImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
            .accessibility(hidden: true)
            .tapToAnimate(jumpHeight: 5)
    }
    
    @ViewBuilder
    var linksView: some View {
        GroupBox {
            VStack(alignment: .leading) {
                Text("Love our apps?")
                    .font(.title3)
                    .bold()
                Text("Support our fundraiser!")
                Link(destination: URL(string: "https://tildy.dev/stjude")!, label: {
                    Text("tildy.dev/stjude")
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                })
                .themedButton(type: .primary)
            }
        }
        .themedGroupBox(type: .primary, id: "support-link")
        GroupBox {
            VStack(alignment: .leading) {
                Text("Supporters")
                    .font(.title3)
                    .bold()
                Text("Our thanks to these awesome people for donating to our fundraiser!")
                    .font(.body)
                Button(action: {
                    showSupporterSheet = true
                }, label: {
                    Text("Supporters")
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                })
                .themedButton(type: .primary, id: "supporters")
            }
        }
        .themedGroupBox(type: .primary, id: "supporters-link")
        GroupBox {
            VStack(alignment: .leading) {
                Text("Credits")
                    .font(.title3)
                    .bold()
                Text("L2CU drawing by rhl__")
                if Theme.isThemeApplied {
                    if Theme.current.isPixel {
                        Text("Pixel art by Jelly\(Theme.current.didJustinContributeArt ? " and Justin" : "")")
                    } else {
                        Text("Art by Jelly\(Theme.current.didJustinContributeArt ? " and Justin" : "")")
                    }
                }
                
                Text("Relay for St. Jude crafted with care by The Lovely Developers")
                
                Button(action: {
                    openURL(URL(string: "https://tildy.dev")!)
                }, label: {
                    Text("tildy.dev")
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                })
                .themedButton(type: .primary)
            }
        }
        .themedGroupBox(type: .primary, id: "bottom-group")
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
                          .foregroundColor(Theme.current.accentColor)
                  }
                  .themedButton(type: .plain)
                  .padding(.horizontal, 15)
                  .padding(.vertical, 10)
        }
        #endif
        ScrollView {
            VStack(spacing: 0) {
                VStack {
                    self.topView
                    self.mascotView
                }
                .padding()
                .background {
                    Theme.current.skyView(forMainScreen: false)
                }
                
                VStack {
                    self.linksView
                }
                .padding(.top)
                .padding()
                .background {
                    VStack(spacing: 0) {
                        Theme.current.landscapeToBackgroundTransition
                        Theme.current.backgroundView
                    }
                }
            }
        }
        .navigationTitle(self.viewTitle)
        .accessibilityElement(children: .ignore)
        .accessibility(label: accessibilityLabel)
        .sheet(isPresented: $showSupporterSheet) {
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
    }
}

struct EasterEggView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EasterEggView()
                .forSheet(displayMode: .large)
        }
    }
}
