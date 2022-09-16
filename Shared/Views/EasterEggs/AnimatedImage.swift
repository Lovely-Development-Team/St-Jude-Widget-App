//
//  AnimatedImage.swift
//  TestAnimation
//
//  Created by Tony Scida on 9/5/22.
//

import SwiftUI

struct AnimatedImage: View {
    @State private var image: Image?
    @State private var imageIndex: Int = 0
    let imageNames: [String]
    @State private var tapped: Bool = false
    
    var interval: CGFloat = 0.06
    var timerLoops: Int = 50
    
#if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
#endif
    
    var staticImage: Image {
        if imageIndex < self.imageNames.count {
            return Image(self.imageNames[imageIndex])
        }
        return Image(self.imageNames.first!)
    }
    
    var body: some View {
        Group {
            if let image = image, tapped {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                staticImage
                    .resizable()
                    .scaledToFit()
            }
        }
        .onTapGesture {
#if !os(macOS)
            if !tapped {
                bounceHaptics.impactOccurred()
            }
#endif
            tapped.toggle()
            self.animate()
        }
    }
    
    private func animate() {
        var loopTimer = timerLoops
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if imageIndex < self.imageNames.count {
                self.image = Image(self.imageNames[imageIndex])
                imageIndex += 1
                loopTimer -= 1
            }
            else {
                imageIndex = 0
                if loopTimer <= 0 {
                    timer.invalidate()
                    tapped = false
                }
            }
            if !tapped {
                timer.invalidate()
            }
        }
    }
}

