//
//  ScoreIcon.swift
//  St Jude
//
//  Created by David Stephens on 03/09/2026.
//

import SwiftUI

struct ScoreIcon: View {
    let icon: ImageResource
    
    var body: some View {
        Image(icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 28, height: 28)
    }
}
