//
//  WheelLayout.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/11/25.
//

import SwiftUI

struct WheelLayout: Layout {
    var radius: Double
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let angle: Double = (2 * Double.pi) / Double(subviews.count)
        
        // apple sample code is the best thank you big tim
        
        for (index, subview) in subviews.enumerated() {
            // Find a vector with an appropriate size and rotation.
            var point = CGPoint(x: 0, y: -radius/2)
                .applying(CGAffineTransform(
                    rotationAngle: angle * Double(index)))
            
            
            // Shift the vector to the middle of the region.
            point.x += bounds.midX
            point.y += bounds.midY
            
            
            // Place the subview.
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
        
    }

}
