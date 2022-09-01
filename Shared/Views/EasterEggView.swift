//
//  EasterEggView.swift
//  EasterEggView
//
//  Created by Tony Scida on 9/1/21.
//

import SwiftUI

struct EasterEggView: View {
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
                    .frame(maxWidth:500, maxHeight: 400)
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
            
            Text("Love our apps?  Support our fundraiser at \n")
                .allowsTightening(true)
                .padding(.top, 10)
                .padding(.bottom, -20)
            Link("tildy.dev/stjude", destination: URL(string: "https://tildy.dev/stjude")!)
                .padding(.top, -5)
                .padding(.bottom, 10)
                .allowsTightening(true)
                .minimumScaleFactor(0.7)
                .font(.body)
                .foregroundColor(.blue)
                .buttonStyle(PlainButtonStyle())
            Button(action: {
                showSupporterSheet = true
            }, label: {
                Text("Supporters")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(10)
                    .padding(.horizontal, 20)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .padding(.bottom)
            })
            Spacer()
            Section{
                Text("L2CU drawing by rhl_. \nRelay FM for St. Jude crafted with care by The Lovely Developers. ")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.secondary)
                Button("tildy.dev") {
                        openURL(URL(string: "https://tildy.dev")!)
                }
                .padding(.top, 5.0)
                .padding(.bottom, 10)
                .allowsTightening(true)
                .minimumScaleFactor(0.7)
                .font(.body)
                .foregroundColor(.blue)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(5.0)
        }
        .padding(.top, 30)
        .padding(10)
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
