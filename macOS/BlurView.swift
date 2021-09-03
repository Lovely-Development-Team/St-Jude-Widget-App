//
//  BlurView.swift
//  BlurView
//
//  Created by David on 03/09/2021.
//

import Foundation
import SwiftUI

struct BlurView: NSViewRepresentable {
    typealias NSViewType = NSVisualEffectView
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        return view
    }
    
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        
    }
}
