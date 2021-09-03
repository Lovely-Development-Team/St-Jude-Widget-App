//
//  EasterEggView.swift
//  EasterEggView
//
//  Created by Tony Scida on 9/1/21.
//

import SwiftUI

struct EasterEggView: View {
    @Environment(\.openURL) var openURL
    
    @State private var animate = false
    @State private var animationType: Animation? = .none
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
    
    var body: some View {
        VStack {
            Text("Hi there!")
                .font(.largeTitle)
                .fontWeight(.bold)
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
                    .frame(height: nil)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 30)
                    .scaledToFit()
                    .accessibility(hidden: true)
                    .offset(x: 0, y: animate ? -5 : 0)
                    .animation(animate ? .easeInOut(duration: 0.15).repeatForever(autoreverses: true) : animationType)
            }
                .buttonStyle(PlainButtonStyle())
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
            .font(.headline)
            .padding(.bottom, 5.0)
            Text("“\(affirmationToShow)”")
                .font(.title)
                .multilineTextAlignment(.center)
                .allowsTightening(true)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
            Section{
            Text("L2CU drawing by rhl_. \nRelay FM for St. Jude crafted with care by The Lovely Devs. ")
                .font(.body)
                .multilineTextAlignment(.center)
                .allowsTightening(true)
                .minimumScaleFactor(0.7)
                .foregroundColor(.secondary)
                Button("tildy.dev") {
                    openURL(URL(string: "https://tildy.dev")!)
                }
                .allowsTightening(true)
                .minimumScaleFactor(0.7)
                .font(.body)
        
            }
            .padding(.horizontal)
            Spacer()

        }
        .padding(.top, 30)
        .padding(10)
        .accessibilityElement(children: .ignore)
        .accessibility(label: accessibilityLabel)
    }
}

struct EasterEggView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EasterEggView()
            EasterEggView()
        }
    }
}
