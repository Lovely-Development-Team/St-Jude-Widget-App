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
    let foregroundColour = Color(UIColor.systemGray).opacity(0.3)
    #else
    let foregroundColour = Color(NSColor.systemGray).opacity(0.3)
    #endif
    
    let fillColor: Color
    
    var mvoMode: Bool = false
    var mvoModeString: String {
        var result = ""
        for i in 1...15 {
            result += (Float(i) / Float(15)) < value ? "🟩" : "⬜️"
        }
        return result
    }
    
    var body: some View {
        GeometryReader { geometry in
            if mvoMode {
                Text(mvoModeString)
                    .font(.largeTitle)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
            } else {
                ZStack(alignment: .leading) {
                    Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                        .foregroundColor(foregroundColour)
                    Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                        .foregroundColor(fillColor)
                }.clipShape(Capsule())
            }
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressBar(value: .constant(0.55), fillColor: .red)
                .frame(height: 30)
            ProgressBar(value: .constant(0.2), fillColor: .red, mvoMode: true)
                .frame(height: 30)
        }
    }
}
