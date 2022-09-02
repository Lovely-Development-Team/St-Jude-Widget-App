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
    var circularShape: Bool = false
    var circleStrokeWidth: CGFloat = 30
    
    var longProgressBar: some View {
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
    
    var circleProgressBar: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    foregroundColour,
                    style: StrokeStyle(
                        lineWidth: circleStrokeWidth,
                        lineCap: .round
                    )
                )
            Circle()
                .trim(from: 0, to: CGFloat(value) * 0.75)
                .stroke(
                    fillColor,
                    style: StrokeStyle(
                        lineWidth: circleStrokeWidth,
                        lineCap: .round
                    )
                )
        }
        .rotationEffect(.degrees(90 + 45))
        .padding(circleStrokeWidth / 2)
    }
    
    var body: some View {
        if circularShape {
            circleProgressBar
        } else {
            longProgressBar
        }
    }
}


struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressBar(value: .constant(0.55), fillColor: .red)
                .frame(height: 30)
            ProgressBar(value: .constant(0.25), fillColor: .red, circularShape: true, circleStrokeWidth: 50)
        }
    }
}
