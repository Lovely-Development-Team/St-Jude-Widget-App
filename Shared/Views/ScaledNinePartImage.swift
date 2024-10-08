//
//  ScaledNinePartImage.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/2/24.
//

import SwiftUI

struct ScaledNinePartImage: View {
    
    var topLeft: ImageResource
    var top: ImageResource
    var topRight: ImageResource
    var left: ImageResource
    var center: ImageResource
    var right: ImageResource
    var bottomLeft: ImageResource
    var bottom: ImageResource
    var bottomRight: ImageResource
    
    var scale = 1.0
    
    @State private var spacing: CGFloat = -1
    
    var body: some View {
        Group {
            VStack(spacing:self.spacing) {
                HStack(spacing:self.spacing) {
                    Image.imageAtScale(resource: self.topLeft, scale: self.scale)
                    Image.tiledImageAtScale(resource: self.top, scale: self.scale, axis: .horizontal)
                    Image.imageAtScale(resource: self.topRight, scale: self.scale)
                }
                HStack(spacing:self.spacing) {
                    Image.tiledImageAtScale(resource: self.left, scale: self.scale, axis: .vertical)
                    Spacer()
                    Image.tiledImageAtScale(resource: self.right, scale: self.scale, axis: .vertical)
                }
                HStack(spacing:self.spacing) {
                    Image.imageAtScale(resource: self.bottomLeft, scale: self.scale)
                    Image.tiledImageAtScale(resource: self.bottom, scale: self.scale, axis: .horizontal)
                    Image.imageAtScale(resource: self.bottomRight, scale: self.scale)
                }
            }
            .overlay {
                Image.tiledImageAtScale(resource: self.center, scale: self.scale)
                    .clipShape(RoundedRectangle(cornerRadius: (60 * self.scale)))
                    .padding((60 * self.scale) / 2)
            }
        }
        .compositingGroup()
        .opacity(1)
    }
}

struct BlockView: View {
    var tint: Color?
    var isPressed: Bool? = nil
    var scale: Double = Double.spriteScale
    
    @ViewBuilder
    func buttonImageView(isPressed: Bool) -> some View {
        ScaledNinePartImage(topLeft: isPressed ? .blockButtonRepeatableTopLeftPressed : .blockButtonRepeatableTopLeft,
                            top: isPressed ? .blockButtonRepeatableTopPressed : .blockButtonRepeatableTop,
                            topRight: isPressed ? .blockButtonRepeatableTopRightPressed : .blockButtonRepeatableTopRight,
                            left: isPressed ? .blockButtonRepeatableLeftPressed : .blockButtonRepeatableLeft,
                            center: isPressed ? .blockButtonRepeatableCenterPressed : .blockButtonRepeatableCenter,
                            right: isPressed ? .blockButtonRepeatableRightPressed : .blockButtonRepeatableRight,
                            bottomLeft: isPressed ? .blockButtonRepeatableBottomLeftPressed : .blockButtonRepeatableBottomLeft,
                            bottom: isPressed ? .blockButtonRepeatableBottomPressed : .blockButtonRepeatableBottom,
                            bottomRight: isPressed ? .blockButtonRepeatableBottomRightPressed : .blockButtonRepeatableBottomRight,
                            scale: self.scale)
    }
    
    @ViewBuilder
    var regularImageView: some View {
        ScaledNinePartImage(topLeft: .blockRepeatableTopLeft,
                            top: .blockRepeatableTop,
                            topRight: .blockRepeatableTopRight,
                            left: .blockRepeatableLeft,
                            center: .blockRepeatableCenter,
                            right: .blockRepeatableRight,
                            bottomLeft: .blockRepeatableBottomLeft,
                            bottom: .blockRepeatableBottom,
                            bottomRight: .blockRepeatableBottomRight,
                            scale: self.scale)
    }
    
    @ViewBuilder 
    var content: some View {
        Group {
            if let isPressed = self.isPressed {
                self.buttonImageView(isPressed: isPressed)
            } else {
                self.regularImageView
            }
        }
    }
    
    var body: some View {
        if let tint = self.tint {
            self.content
                .colorMultiply(tint)
        } else {
            self.content
        }
    }
}

#Preview {
    VStack {
        BlockView(tint: .blue, scale: 0.75)
        .frame(width: 300, height: 150)
        BlockView(tint: .red, scale: 0.75)
        .frame(width: 300, height: 150)
        .opacity(0.5)
        DisclosureGroup(
            content: {
                BlockView(tint: .green, scale: 0.75)
                .frame(width: 300, height: 150)
            },
            label: { Text("Disclosure") }
        )
    }
}
