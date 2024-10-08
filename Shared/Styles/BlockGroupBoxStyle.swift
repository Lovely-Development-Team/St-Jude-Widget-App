//
//  BlockGroupBoxStyle.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/4/24.
//

import SwiftUI

struct BlockGroupBoxStyle: GroupBoxStyle {
    var tint: Color = .secondarySystemBackground
    var padding: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if(self.padding) {
                configuration.content
                    .padding()
            } else {
                configuration.content
            }
        }
            .compositingGroup()
            .background {
                BlockView(tint: self.tint)
            }
    }
}
