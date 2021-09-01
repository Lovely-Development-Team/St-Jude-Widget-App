//
//  EasterEggView.swift
//  EasterEggView
//
//  Created by Tony Scida on 9/1/21.
//

import SwiftUI

struct EasterEggView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Image("Team_Logo_F")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: nil)
                    .padding(.bottom, -50.0)
                    .scaledToFit()
                    .accessibility(hidden: true)
                Text("L2CU Says")
                    .font(.headline)
                    .padding(.bottom, 5.0)
                Text("\"Teamwork makes the dream work\"")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .allowsTightening(true)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
            .accessibilityElement(children: .combine)
            .navigationBarTitle("Hi there!")
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction, content: {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Done")
                            .bold()
                    })
                })
            })
        }
    }
}

struct EasterEggView_Previews: PreviewProvider {
    static var previews: some View {
        EasterEggView()
    }
}
