//
//  AltIcons.swift
//  St Jude (iOS)
//
//  Created by Ben Cardy on 02/09/2024.
//

import Foundation
import SwiftUI

enum AltIcon: String, CaseIterable, Identifiable {
    case original
    case flowers
    case l2cu
    case stephen
    case myke
    case stephenKart
    case mykeKart
    case questionblock
    case bush
    case cloud
    case jony
    case logo
    
    var id: String {
        self.rawValue
    }
    
    var isCursed: Bool {
        switch self {
        case .jony:
            return true
        default:
            return false
        }
    }
    
    var fileName: String? {
        switch self {
        case .original:
            return nil
        default:
            return "icon-\(self.rawValue)"
        }
    }
    
    var image: some View {
        Image(uiImage: UIImage(named: fileName ?? "AppIcon") ?? UIImage())
            .resizable()
            .modifier(PixelRounding())
    }
    
    func set() {
        appLogger.debug("Setting icon to \(self.fileName ?? "nil")...")
        UIApplication.shared.setAlternateIconName(self.fileName)
    }
    
}
