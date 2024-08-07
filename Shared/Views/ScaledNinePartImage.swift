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
    
    @State private var spacing: CGFloat = -1
    
    var body: some View {
//        Grid(horizontalSpacing: self.spacing, verticalSpacing: self.spacing) {
//            GridRow {
//                Image.imageAtScale(resource: self.topLeft, scale: self.scale)
//                Image.tiledImageAtScale(resource: self.top, scale: self.scale, axis: .horizontal)
//                Image.imageAtScale(resource: self.topRight, scale: self.scale)
//            }
//            GridRow {
//                Image.tiledImageAtScale(resource: self.left, scale: self.scale, axis: .vertical)
//                Image.tiledImageAtScale(resource: self.center, scale: self.scale)
//                Image.tiledImageAtScale(resource: self.right, scale: self.scale, axis: .vertical)
//            }
//            GridRow {
//                Image.imageAtScale(resource: self.bottomLeft, scale: self.scale)
//                Image.tiledImageAtScale(resource: self.bottom, scale: self.scale, axis: .horizontal)
//                Image.imageAtScale(resource: self.bottomRight, scale: self.scale)
//            }
//        }
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
}

struct BlockView: View {
    @State var tint: Color?
    @State var isPressed: Bool? = nil
    
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
                            scale: Double.spriteScale)
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
                            scale: Double.spriteScale)
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
