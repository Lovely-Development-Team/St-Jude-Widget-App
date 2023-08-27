//
//  ShapesView.swift
//  St Jude
//
//  Created by Tony Scida on 8/27/23.
//

import SwiftUI

struct ShapesView: View {
    var body: some View {
        Image("Asset 58")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth:120)
            .position(x: 0, y: 165)
            .opacity(0.4)
        Image("Asset 62")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth:150)
            .position(x: 400, y: 50)
            .opacity(0.4)
        Image("Asset 67")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth:20)
            .position(x: 0, y: 600)
            .opacity(0.4)
        Image("Asset 64")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth:200)
            .position(x: 400, y: 400)
            .opacity(0.4)
        Image("Asset 69")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth:200)
            .position(x: 50, y: 400)
            .opacity(0.4)
    }
}

#Preview {
    ShapesView()
}
