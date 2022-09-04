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
            Rectangle()
                .fill(.clear)
                .frame(height: 80)
            if appear {
                Image("unicorn")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                    .offset(x: 40)
                    .offset(y: 5)
                    .transition(.move(edge: .trailing))
            }
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
