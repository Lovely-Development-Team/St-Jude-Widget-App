//
//  View+asImage.swift
//  St Jude
//
//  Created by Ben Cardy on 31/08/2022.
//

import SwiftUI
import UIKit

extension View {
    var asImage: UIImage {
        // Must ignore safe area due to a bug in iOS 15+ https://stackoverflow.com/a/69819567/1011161
        let controller = UIHostingController(rootView: self.edgesIgnoringSafeArea(.top))
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: targetSize)
        view?.backgroundColor = .clear

        let format = UIGraphicsImageRendererFormat()
        format.scale = 3 // Ensures 3x-scale images. You can customise this however you like.
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
