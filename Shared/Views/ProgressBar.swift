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
    var barColour = Color(UIColor.systemGray).opacity(0.3)
#else
    var barColour = Color(NSColor.systemGray).opacity(0.3)
#endif
    
    let fillColor: Color
    var circularShape: Bool = false
    var circleStrokeWidth: CGFloat = 30
    var showDivider: Bool = false
    var dividerColor: Color = .white
    var dividerWidth: CGFloat = 1
    var stroke: Bool = false
    var disablePixelBorder: Bool = false
    
    @ViewBuilder
    func longProgressBar(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                .foregroundColor(barColour)
            Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                .foregroundColor(fillColor)
            if showDivider && value != 0 && value != 1 {
                Rectangle()
                    .fill(dividerColor)
                    .frame(width: dividerWidth)
                    .offset(x: min(CGFloat(self.value)*geometry.size.width, geometry.size.width))
                
            }
        }
    }
    
    var circleProgressBar: some View {
        ZStack {
            Circle()
//                .trim(from: 0, to: 0.9)
                .stroke(
                    barColour,
                    style: StrokeStyle(
                        lineWidth: circleStrokeWidth,
                        lineCap: .round
                    )
                )
            Circle()
                .trim(from: 0, to: CGFloat(value))
                .stroke(
                    fillColor,
                    style: StrokeStyle(
                        lineWidth: circleStrokeWidth,
                        lineCap: .round
                    )
                )
        }
        .rotationEffect(.degrees(-90))
        .padding(circleStrokeWidth / 2)
    }
    
    @ViewBuilder
    var pixeledProgressBar: some View {
        GeometryReader { geometry in
            if disablePixelBorder {
                longProgressBar(geometry: geometry)
                    .clipShape(Capsule())
            } else {
                longProgressBar(geometry: geometry)
                    .modifier(PixelRounding(geometry: geometry))
            }
        }
    }
    
    var body: some View {
        if circularShape {
            circleProgressBar
        } else {
            if stroke {
                pixeledProgressBar
                    .compositingGroup()
                    .shadow(color: dividerColor, radius: 0.4)
                    .shadow(color: dividerColor, radius: 0.4)
                    .shadow(color: dividerColor, radius: 0.4)
                    .shadow(color: dividerColor, radius: 0.4)
                    .shadow(color: dividerColor, radius: 0.4)
                    .shadow(color: dividerColor, radius: 0.4)
                    .shadow(color: dividerColor, radius: 0.4)
                    .shadow(color: dividerColor, radius: 0.4)
            } else {
                pixeledProgressBar
            }
        }
    }
}


struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressBar(value: .constant(0.55), barColour: .green, fillColor: .red, showDivider: true, dividerColor: .black, dividerWidth: 2, stroke: true)
                .frame(height: 30)
//            ProgressBar(value: .constant(0.25), fillColor: .red, circularShape: true, circleStrokeWidth: 50)
        }
        .padding()
    }
}
