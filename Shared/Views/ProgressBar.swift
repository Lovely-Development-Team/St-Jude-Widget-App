//
//  ProgressBar.swift
//  ProgressBar
//
//  Created by David on 23/08/2021.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var value: Float
    
    #if os(iOS)
    let foregroundColour = Color(UIColor.systemGray)
    #else
    let foregroundColour = Color(NSColor.systemGray)
    #endif
    
    let fillColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(foregroundColour)
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(fillColor)
            }.clipShape(Capsule())
        }
    }
}
