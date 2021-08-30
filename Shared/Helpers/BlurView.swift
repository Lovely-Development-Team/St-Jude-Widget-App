//
//  BlurView.swift
//  BlurView
//
//  Created by Justin Hamilton on 8/30/21.
//

import Foundation
import SwiftUI

struct BlurView: UIViewRepresentable {
    typealias UIViewType = UIVisualEffectView
    
    var effect: UIVisualEffect?
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: self.effect)
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = self.effect
    }
}
