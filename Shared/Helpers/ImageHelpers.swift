//
//  ImageHelpers.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/3/24.
//

import Foundation
import SwiftUI

extension Image {
    static func imageAtScale(resource: ImageResource, scale: Double = Double.spriteScale) -> some View {
        let image = UIImage(resource: resource)
        let imageSize = image.size
        return Image(uiImage: image)
            .resizable()
            .frame(width: imageSize.width * scale, height: imageSize.height * scale)
    }
    
    static func tiledImageAtScale(resource: ImageResource, scale: Double = Double.spriteScale, axis: Axis? = nil) -> some View {
        let image = UIImage(resource: resource)
        let imageSize = image.size
        
        // oh god uikit image resizing why
        let newSize = CGSize(width: floor(imageSize.width * scale), height: floor(imageSize.height * scale))
        let rect = CGRect(origin: .zero, size: newSize)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let newImage = renderer.image(actions: { _ in
            image.draw(in: rect)
        })
        
        guard let axis = axis else {
            return Image(uiImage:newImage)
                .resizable(resizingMode: .tile)
                .frame(alignment: .center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.none, value: UUID())
        }
        
        switch axis {
        case .horizontal:
            return Image(uiImage:newImage)
                    .resizable(resizingMode: .tile)
                    .frame(height: floor(imageSize.height * scale), alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .animation(.none, value: UUID())
        case .vertical:
            return Image(uiImage:newImage)
                    .resizable(resizingMode: .tile)
                    .frame(width: floor(imageSize.width * scale), alignment: .center)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .animation(.none, value: UUID())
        }

    }
}
