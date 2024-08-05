//
//  ScaledNinePartImage.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/2/24.
//

import SwiftUI

struct ScaledNinePartImage: View {
    
    @State var topLeft: ImageResource
    @State var top: ImageResource
    @State var topRight: ImageResource
    @State var left: ImageResource
    @State var center: ImageResource
    @State var right: ImageResource
    @State var bottomLeft: ImageResource
    @State var bottom: ImageResource
    @State var bottomRight: ImageResource
    
    @State var scale = 1.0
    
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                Image.imageAtScale(resource: self.topLeft, scale: self.scale)
                Image.tiledImageAtScale(resource: self.top, scale: self.scale, axis: .horizontal)
                Image.imageAtScale(resource: self.topRight, scale: self.scale)
            }
            GridRow {
                Image.tiledImageAtScale(resource: self.left, scale: self.scale, axis: .vertical)
                Image.tiledImageAtScale(resource: self.center, scale: self.scale)
                Image.tiledImageAtScale(resource: self.right, scale: self.scale, axis: .vertical)
            }
            GridRow {
                Image.imageAtScale(resource: self.bottomLeft, scale: self.scale)
                Image.tiledImageAtScale(resource: self.bottom, scale: self.scale, axis: .horizontal)
                Image.imageAtScale(resource: self.bottomRight, scale: self.scale)
            }
        }
    }
}

struct BlockView: View {
    @State var tint: Color?
    @State var isPressed = false
    
    @ViewBuilder
    var imageView: some View {
        ScaledNinePartImage(topLeft: self.isPressed ? .blockRepeatableTopLeftPressed : .blockRepeatableTopLeft,
                            top: self.isPressed ? .blockRepeatableTopPressed : .blockRepeatableTop,
                            topRight: self.isPressed ? .blockRepeatableTopRightPressed : .blockRepeatableTopRight,
                            left: self.isPressed ? .blockRepeatableLeftPressed : .blockRepeatableLeft,
                            center: self.isPressed ? .blockRepeatableCenterPressed : .blockRepeatableCenter,
                            right: self.isPressed ? .blockRepeatableRightPressed : .blockRepeatableRight,
                            bottomLeft: self.isPressed ? .blockRepeatableBottomLeftPressed : .blockRepeatableBottomLeft,
                            bottom: self.isPressed ? .blockRepeatableBottomPressed : .blockRepeatableBottom,
                            bottomRight: self.isPressed ? .blockRepeatableBottomRightPressed : .blockRepeatableBottomRight,
                            scale: Double.spriteScale)
    }
    
    var body: some View {
        if let tint = self.tint {
            self.imageView
                .colorMultiply(tint)
        } else {
            self.imageView
        }
    }
}

#Preview {
    ScaledNinePartImage(
        topLeft: .blockRepeatableTopLeft,
        top: .blockRepeatableTop,
        topRight: .blockRepeatableTopRight,
        left: .blockRepeatableLeft,
        center: .blockRepeatableCenter,
        right: .blockRepeatableRight,
        bottomLeft: .blockRepeatableBottomLeft,
        bottom: .blockRepeatableBottom,
        bottomRight: .blockRepeatableBottomRight)
        .frame(width: 300, height: 200)
        .border(.black)
}
