//
//  EasterEggView.swift
//  EasterEggView
//
//  Created by Tony Scida on 9/1/21.
//

import SwiftUI

struct EasterEggView: View {
    
    @State private var animate = false
    @State private var animationType: Animation? = .none
    
    @State private var showFullL2CUName = false
    
    var body: some View {
        VStack {
            Text("Hi there!")
                .font(.largeTitle)
                .fontWeight(.bold)
            Button(action: {
                withAnimation {
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
                        self.showFullL2CUName.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.showFullL2CUName.toggle()
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
            Text("“Teamwork makes the dream work!”")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .allowsTightening(true)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
        .padding(.top, 30)
        .padding(10)
        .accessibilityElement(children: .combine)
    }
}

struct EasterEggView_Previews: PreviewProvider {
    static var previews: some View {
        EasterEggView()
    }
}
