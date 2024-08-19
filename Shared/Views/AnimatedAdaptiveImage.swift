//
//  AnimatedAdaptiveImage.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/14/24.
//

import SwiftUI

struct AnimatedAdaptiveImage: View {
    @Binding var idleImage: AdaptiveImage
    @Binding var images: [AdaptiveImage]
    @Binding var animating: Bool
    @State var interval: Double = 0.2
    
    @State private var imageIndex: Int = 0
    @State private var timer: Timer?
    
    @ViewBuilder
    var currentImage: some View {
        self.images[self.imageIndex]
            .imageAtScale()
    }
    
    var body: some View {
        Group {
            if(self.animating) {
                self.currentImage
            } else {
                self.idleImage
                    .imageAtScale()
            }
        }
            .animation(.none, value: UUID())
            .onChange(of: self.animating, perform: { _ in
                self.animateIfNeeded()
            })
            .onAppear {
                self.animateIfNeeded()
            }
    }
    
    func animateIfNeeded() {
        if(self.animating) {
            self.startAnimating()
        } else {
            self.stopAnimating()
        }
    }
    
    func startAnimating() {
        self.timer = Timer.scheduledTimer(withTimeInterval: self.interval, repeats: true, block: {_ in
            withAnimation(.none) {
                self.imageIndex = ((self.imageIndex+1) % self.images.count)
            }
        })
    }
    
    func stopAnimating() {
        self.timer?.invalidate()
        self.imageIndex = 0
    }
}