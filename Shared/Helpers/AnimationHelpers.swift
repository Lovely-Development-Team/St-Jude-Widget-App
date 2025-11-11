//
//  AnimationHelpers.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/9/25.
//

import SwiftUI

struct TapToAnimate: ViewModifier {
    struct AnimationValues {
        var yOffset: CGFloat = 0
        var rotation: Angle = .zero
    }
    var jumpHeight: CGFloat = 0
    var rotation: Angle = .zero
    
    var onTap: (() -> Void) = {}
    
    @State private var animate = false
    
    func body(content: Content) -> some View {
        Button(action: {
            self.animate.toggle()
            self.onTap()
            // TODO: add back haptics
        }, label: {
            content
        })
        .keyframeAnimator(initialValue: AnimationValues(),
                          trigger: self.animate,
                          content: { view, value in
            Group {
                view
                    .rotationEffect(value.rotation)
            }
            .offset(y: value.yOffset)
        }, keyframes: { value in
            // Why doesn't a for loop work here????
            KeyframeTrack(\.yOffset, content: {
                CubicKeyframe(-self.jumpHeight, duration: 0.15)
                CubicKeyframe(0, duration: 0.15)
                CubicKeyframe(-self.jumpHeight, duration: 0.15)
                CubicKeyframe(0, duration: 0.15)
                CubicKeyframe(-self.jumpHeight, duration: 0.15)
                CubicKeyframe(0, duration: 0.15)
                CubicKeyframe(-self.jumpHeight, duration: 0.15)
                CubicKeyframe(0, duration: 0.15)
                CubicKeyframe(-self.jumpHeight, duration: 0.15)
                CubicKeyframe(0, duration: 0.15)
            })
            
            KeyframeTrack(\.rotation, content: {
                CubicKeyframe(self.rotation, duration: 0.3)
                CubicKeyframe(-self.rotation, duration: 0.3)
                CubicKeyframe(self.rotation, duration: 0.3)
                CubicKeyframe(-self.rotation, duration: 0.3)
                CubicKeyframe(.zero, duration: 0.3)
            })
        })
    }
}

#Preview {
    VStack {
        Rectangle()
            .foregroundStyle(.red)
            .frame(width: 100, height: 100)
            .tapToAnimate(jumpHeight: 5)
        Rectangle()
            .foregroundStyle(.green)
            .frame(width: 100, height: 100)
            .tapToAnimate(rotation: .degrees(30))
        Rectangle()
            .foregroundStyle(.blue)
            .frame(width: 100, height: 100)
            .tapToAnimate(jumpHeight: 50, rotation: .degrees(30))
    }
}

extension View {
    @ViewBuilder
    func tapToAnimate(jumpHeight: CGFloat = 0, rotation: Angle = .zero) -> some View {
        self
            .modifier(TapToAnimate(jumpHeight: jumpHeight, rotation: rotation))
    }
}
