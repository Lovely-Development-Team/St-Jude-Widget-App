//
//  EasterEggView.swift
//  EasterEggView
//
//  Created by Tony Scida on 9/1/21.
//

import SwiftUI

struct EasterEggView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var animate = false
    @State var animationType: Animation? = .none
    
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
                    .padding(.bottom, -50.0)
                    .scaledToFit()
                    .accessibility(hidden: true)
                    .offset(x: 0, y: animate ? -5 : 0)
                    .animation(animate ? .easeInOut(duration: 0.15).repeatForever(autoreverses: true) : animationType)
            }
            .buttonStyle(PlainButtonStyle())
            Text("L2CU says:")
                .font(.headline)
                .padding(.bottom, 5.0)
            Text("“Teamwork makes the dream work!”")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .allowsTightening(true)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction, content: {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            })
        })
    }
}

struct EasterEggView_Previews: PreviewProvider {
    static var previews: some View {
        EasterEggView()
    }
}
