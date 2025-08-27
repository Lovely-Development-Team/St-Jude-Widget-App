//
//  ScaledNinePartImage.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/2/24.
//

import SwiftUI

struct ScaledNinePartImage: View {
    
    enum EdgePosition {
        case topLeft
        case top
        case topRight
        case left
        case center
        case right
        case bottomLeft
        case bottom
        case bottomRight
    }
    
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
    
    var overridePositions: [EdgePosition: EdgePosition] = [:]
    
    @State private var spacing: CGFloat = -1
    
    func positionImage(for position: EdgePosition, checkOverrides: Bool = true) -> ImageResource {
        if checkOverrides, let override = self.overridePositions[position] {
            return self.positionImage(for: override, checkOverrides: false)
        }
        
        switch position {
        case .topLeft:
            return self.topLeft
        case .top:
            return self.top
        case .topRight:
            return self.topRight
        case .left:
            return self.left
        case .center:
            return self.center
        case .right:
            return self.right
        case .bottomLeft:
            return self.bottomLeft
        case .bottom:
            return self.bottom
        case .bottomRight:
            return self.bottomRight
        }
    }
    
    var body: some View {
        Group {
            VStack(spacing:self.spacing) {
                HStack(spacing:self.spacing) {
                    Image.imageAtScale(resource: self.positionImage(for: .topLeft), scale: self.scale)
                    Image.tiledImageAtScale(resource: self.positionImage(for: .top), scale: self.scale, axis: .horizontal)
                    Image.imageAtScale(resource: self.positionImage(for: .topRight), scale: self.scale)
                }
                HStack(spacing:self.spacing) {
                    Image.tiledImageAtScale(resource: self.positionImage(for: .left), scale: self.scale, axis: .vertical)
                    Spacer()
                    Image.tiledImageAtScale(resource: self.positionImage(for: .right), scale: self.scale, axis: .vertical)
                }
                HStack(spacing:self.spacing) {
                    Image.imageAtScale(resource: self.positionImage(for: .bottomLeft), scale: self.scale)
                    Image.tiledImageAtScale(resource: self.positionImage(for: .bottom), scale: self.scale, axis: .horizontal)
                    Image.imageAtScale(resource: self.positionImage(for: .bottomRight), scale: self.scale)
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
    var edgeColor: Color?
    var shadowColor: Color?
    
    var overridePositions: [ScaledNinePartImage.EdgePosition: ScaledNinePartImage.EdgePosition] = [:]
    
    // TODO: Remove
    @AppStorage(UserDefaults.debugGlowOpacityKey, store: UserDefaults.shared) private var debugGlowOpacity: Double = 0.5
    @AppStorage(UserDefaults.debugEdgeHighlightOpacityKey, store: UserDefaults.shared) private var debugEdgeHighlightOpacity: Double = 1.0
    
    
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
                            scale: self.scale,
                            overridePositions: self.overridePositions)
    }
    
    @ViewBuilder
    func buttonImageViewEdge(isPressed: Bool) -> some View {
        ScaledNinePartImage(topLeft: isPressed ? .blockButtonRepeatableTopLeftEdgePressed : .blockButtonRepeatableTopLeftEdge,
                            top: isPressed ? .blockButtonRepeatableTopEdgePressed : .blockButtonRepeatableTopEdge,
                            topRight: isPressed ? .blockButtonRepeatableTopRightEdgePressed : .blockButtonRepeatableTopRightEdge,
                            left: isPressed ? .blockButtonRepeatableLeftEdgePressed : .blockButtonRepeatableLeftEdge,
                            center: .blockRepeatableSolidEdge,
                            right: isPressed ? .blockButtonRepeatableRightEdgePressed : .blockButtonRepeatableRightEdge,
                            bottomLeft: isPressed ? .blockButtonRepeatableBottomLeftEdgePressed : .blockButtonRepeatableBottomLeftEdge,
                            bottom: isPressed ? .blockButtonRepeatableBottomEdgePressed : .blockButtonRepeatableBottomEdge,
                            bottomRight: isPressed ? .blockButtonRepeatableBottomRightEdgePressed : .blockButtonRepeatableBottomRightEdge,
                            scale: self.scale,
                            overridePositions: self.overridePositions)
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
                            scale: self.scale,
                            overridePositions: self.overridePositions)
    }
    
    @ViewBuilder
    var regularImageViewEdge: some View {
        ScaledNinePartImage(topLeft: .blockRepeatableTopLeftEdge,
                            top: .blockRepeatableSolidEdge,
                            topRight: .blockRepeatableTopRightEdge,
                            left: .blockRepeatableSolidEdge,
                            center: .blockRepeatableCenter,
                            right: .blockRepeatableSolidEdge,
                            bottomLeft: .blockRepeatableBottomLeftEdge,
                            bottom: .blockRepeatableSolidEdge,
                            bottomRight: .blockRepeatableBottomRightEdge,
                            scale: self.scale,
                            overridePositions: self.overridePositions)
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
        Group {
            if let tint = self.tint {
                self.content
                    .colorMultiply(tint)
            } else {
                self.content
            }
        }
        .background(alignment: .center) {
            Group {
                if let edgeColor = self.edgeColor {
                    if let isPressed = self.isPressed {
                        self.buttonImageViewEdge(isPressed: isPressed)
                            .colorMultiply(edgeColor)
                            .opacity(self.debugEdgeHighlightOpacity)
                    } else {
                        ZStack {
                            self.regularImageViewEdge
                                .colorMultiply(edgeColor)
                                .opacity(self.debugEdgeHighlightOpacity)
                        }
                    }
                } else {
                    if let tint = self.tint {
                        if let isPressed = self.isPressed {
                            self.buttonImageViewEdge(isPressed: isPressed)
                                .colorMultiply(.gray)
                                .colorInvert()
                                .colorMultiply(tint)
                        } else {
                            self.regularImageViewEdge
                                .colorMultiply(tint)
                                .opacity(self.debugEdgeHighlightOpacity)
                        }
                    } else {
                        if let isPressed = self.isPressed {
                            self.buttonImageViewEdge(isPressed: isPressed)
                                .colorMultiply(.gray.lighter(by: 0.1))
                                .colorInvert()
                                .colorMultiply(.secondarySystemBackground.darker(by: 0.5))
                        } else {
                            self.regularImageViewEdge
                                .colorMultiply(.secondarySystemBackground)
                                .opacity(self.debugEdgeHighlightOpacity)
                        }
                    }
                }
            }
            .compositingGroup()
        }
        // TODO: Remove debug multiplier
        .shadow(color: (self.shadowColor ?? .clear).opacity(self.debugGlowOpacity), radius: 10)
    }
}

struct BlockButtonPreview: View {
    @State private var isPressed: Bool = false
    @State private var tintColor: Color = .red
    @State private var edgeColor: Color = .blue
    
    var body: some View {
        VStack {
            Toggle(isOn: self.$isPressed, label: {
                Text("Pressed")
            })
            ColorPicker("Tint", selection: self.$tintColor)
            ColorPicker("Edge", selection: self.$edgeColor)
            BlockView(tint: self.tintColor, isPressed: self.isPressed, scale: 0.75)
                .frame(width: 300, height: 100)
            BlockView(tint: self.tintColor, isPressed: self.isPressed, scale: 0.75, edgeColor: self.edgeColor)
                .frame(width: 300, height: 100)
        }
    }
}

#Preview {
    BlockButtonPreview()
}
