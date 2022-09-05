//
//  AnimatedImage.swift
//  TestAnimation
//
//  Created by Tony Scida on 9/5/22.
//

import SwiftUI

struct AnimatedImage: View {
    @State private var image: Image?
    let imageNames: [String]
    @State private var tapped: Bool = false

    var body: some View {
      Group {
          if tapped {
              image?
                  .resizable()
                  .scaledToFit()
          } else {
              Image(self.imageNames.first!)
                  .resizable()
                  .scaledToFit()
          }
      }
      .onTapGesture {
          tapped.toggle()
          self.animate()
      }
    }
    
    private func animate() {
      var imageIndex: Int = 0
        var timerLoops: Int = 50
       
    
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if imageIndex < self.imageNames.count {
                print(timerLoops)
                self.image = Image(self.imageNames[imageIndex])
                imageIndex += 1
                timerLoops -= 1
            }
            else {
                imageIndex = 0
                if timerLoops <= 0 {
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

