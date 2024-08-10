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
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var animate = false
    @State private var animationType: Animation? = .none
    @State private var showSupporterSheet: Bool = false
    #if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    let selectionHaptics = UISelectionFeedbackGenerator()
    #endif
    
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
    
    init() {
        affirmationToShow = affirmations.randomElement() ?? "Teamwork makes the dream work!"
    }
    
    var accessibilityLabel: Text {
        Text("L2CU (\"Lovely to See You\") says \"\(affirmationToShow)\"")
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
            .groupBoxStyle(BlockGroupBoxStyle())
            .padding()
            Spacer()
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
                Image("Team_Logo_F")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth:500, maxHeight: 200)
                    .scaledToFit()
                    .accessibility(hidden: true)
                    .offset(x: 0, y: animate ? -5 : 0)
                    .animation(animate ? .easeInOut(duration: 0.15).repeatForever(autoreverses: true) : animationType)
            }
            AdaptiveImage.groundRepeatable(colorScheme: self.colorScheme)
                .tiledImageAtScale(axis: .horizontal)
        }
        .background(alignment: .bottom) {
            AdaptiveImage.skyRepeatable(colorScheme: self.colorScheme)
                .tiledImageAtScale(axis: .horizontal)
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
        VStack(spacing:0) {
            self.topView
            VStack {
                GroupBox {
                    VStack {
                        Text("Love our apps?  Support our fundraiser!")
                            .allowsTightening(true)
                        //                        .padding(.top, 10)
                        //                        .padding(.bottom, -20)
                        Link(destination: URL(string: "https://tildy.dev/stjude")!, label: {
                            Text("tildy.dev/stjude")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        })
                        //                        .padding(.top, -5)
                        //                        .padding(.bottom, 10)
//                            .foregroundColor(.blue)
//                            .buttonStyle(PlainButtonStyle())
                        .buttonStyle(BlockButtonStyle(tint: .accentColor))
                    }
                }
                .groupBoxStyle(BlockGroupBoxStyle())
                Button(action: {
                    showSupporterSheet = true
                }, label: {
                    Text("Supporters")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                        .padding(10)
//                        .padding(.horizontal, 20)
//                        .background(Color.accentColor)
//                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                        .padding(.bottom)
                })
                .buttonStyle(BlockButtonStyle(tint: .accentColor))
                GroupBox {
                    VStack {
                        Text("L2CU drawing by rhl_. \nRelay for St. Jude crafted with care by The Lovely Developers. ")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(.secondary)
                        Button(action: {
                            openURL(URL(string: "https://tildy.dev")!)
                        }, label: {
                            Text("tildy.dev")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        })
                        //                    .padding(.top, 5.0)
                        //                    .padding(.bottom, 10)
                        //                    .font(.body)
                        //                    .foregroundColor(.blue)
                        //                    .buttonStyle(PlainButtonStyle())
                        .buttonStyle(BlockButtonStyle(tint: .accentColor))
                    }
                }
                .groupBoxStyle(BlockGroupBoxStyle())
                .padding(.bottom)
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
//            Text("Hi there!")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//            Button(action: {
//                withAnimation {
//                    #if !os(macOS)
//                    bounceHaptics.impactOccurred()
//                    #endif
//                    self.animate.toggle()
//                    self.animationType = .default
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    self.animate.toggle()
//                }
//            }) {
//                Image("Team_Logo_F")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth:500, maxHeight: 400)
//                    .padding(.bottom, 20)
//                    .padding(.horizontal, 30)
//                    .scaledToFit()
//                    .accessibility(hidden: true)
//                    .offset(x: 0, y: animate ? -5 : 0)
//                    .animation(animate ? .easeInOut(duration: 0.15).repeatForever(autoreverses: true) : animationType)
//            }
//                .buttonStyle(PlainButtonStyle())
//            HStack(spacing: 5) {
//                Button(action: {
//                    withAnimation {
//                        #if !os(macOS)
//                        selectionHaptics.selectionChanged()
//                        #endif
//                        self.showFullL2CUName.toggle()
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                        withAnimation {
//                            self.showFullL2CUName = false
//                        }
//                    }
//                }) {
//                    Text(showFullL2CUName ? "Lovely to See You" : "L2CU")
//                }
//                .buttonStyle(PlainButtonStyle())
//                Text("says:")
//            }
//            .font(.headline)
//            .padding(.bottom, 5.0)
//            Text("“\(affirmationToShow)”")
//                .font(.title)
//                .multilineTextAlignment(.center)
//                .allowsTightening(true)
//                .frame(maxWidth: .infinity, alignment: .center)
//            }
//            .padding(5.0)
        }
        .background {
            Color.skyBackground
        }
//        .padding(.top, 30)
//        .padding(10)
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
