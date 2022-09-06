//
//  UnicornView.swift
//  St Jude
//
//  Created by Ben Cardy on 04/09/2022.
//

import SwiftUI

struct UnicornView: View {
    
    @State private var appear: Bool = false
    
    var body: some View {
        HStack {
            if appear {
                Image("unicorn")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .frame(height: 80)
                    .offset(x: -40)
                    .offset(y: 5)
                    .transition(.move(edge: .leading))
            }
            Rectangle()
                .fill(.clear)
                .frame(height: 80)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    appear = true
                }
            }
        }
    }
    
}
