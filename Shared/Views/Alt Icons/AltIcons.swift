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
    case logo
    
    var id: String {
        self.rawValue
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
        switch self {
        case .original:
            return Image(uiImage: Bundle.main.icon ?? UIImage())
                .resizable()
                .modifier(PixelRounding())
        default:
            if let fileName {
                return Image("\(fileName)-preview")
                    .resizable()
                    .modifier(PixelRounding())
            }
            return Image(uiImage: Bundle.main.icon ?? UIImage())
                .resizable()
                .modifier(PixelRounding())
        }
    }
    
    func set() {
        appLogger.debug("Setting icon to \(self.fileName ?? "nil")...")
        UIApplication.shared.setAlternateIconName(self.fileName)
    }
    
}
