//
//  PlainGroupBoxStyle.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/4/24.
//

import SwiftUI

struct ImageGroupBoxStyle: GroupBoxStyle {
    var background: ImageResource
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .padding()
            .background {
                Image(self.background)
                    .resizable()
                    .shadow(radius: 10)
            }
    }
}
