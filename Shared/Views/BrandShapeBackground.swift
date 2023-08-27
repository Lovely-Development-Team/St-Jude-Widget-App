//
//  BrandShapeBackground.swift
//  St Jude
//
//  Created by Ben Cardy on 27/08/2023.
//

import SwiftUI

struct BrandShape: View {
    let number: Int
    var width: CGFloat = 120
    var body: some View {
        Image("Asset \(number)")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: width)
    }
}

struct BrandShapeBackground: View {
    var opacity: CGFloat = 0.3
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Spacer()
                BrandShape(number: 58)
                    .offset(x: -50)
                Spacer()
                BrandShape(number: 69, width: 200)
                    .offset(x: -30)
                Spacer()
                BrandShape(number: 67, width: 20)
                    .offset(x: -10)
                Spacer()
            }
            Spacer()
            VStack(alignment: .trailing) {
                BrandShape(number: 62, width: 150)
                    .offset(x: 50)
                    .padding(.top, 8)
                Spacer()
                BrandShape(number: 64, width: 200)
                    .offset(x: 100)
                Spacer()
            }
        }
        .opacity(opacity)
    }
}

#Preview {
    BrandShapeBackground()
}
