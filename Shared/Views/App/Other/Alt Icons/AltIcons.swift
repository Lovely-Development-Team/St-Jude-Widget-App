//
//  AltIcons.swift
//  St Jude (iOS)
//
//  Created by Ben Cardy on 02/09/2024.
//

import Foundation
import SwiftUI

enum AltIcon: String, CaseIterable, Identifiable {
    case defaultIcon
    case regular
    case icon2024
    case icon2025
    
    var id: String {
        self.rawValue
    }
    
    var title: String {
        switch self {
        case .regular:
            return "Regular"
        case .icon2024:
            return "2024"
        case .icon2025:
            return "2025"
        default:
            return "Default"
        }
    }
    
    var fileName: String? {
        switch self {
        case .defaultIcon:
            return nil
        default:
            return "icon-\(self.rawValue)"
        }
    }
    
    var image: some View {
        switch self {
        case .defaultIcon:
            return Image(uiImage: Bundle.main.icon ?? UIImage())
                .resizable()
        default:
            if let fileName {
                return Image("\(fileName)-image")
                    .resizable()
            }
            return Image(uiImage: Bundle.main.icon ?? UIImage())
                .resizable()
        }
    }
    
    func set() {
        appLogger.debug("Setting icon to \(self.fileName ?? "nil")...")
        UIApplication.shared.setAlternateIconName(self.fileName)
    }
    
}
