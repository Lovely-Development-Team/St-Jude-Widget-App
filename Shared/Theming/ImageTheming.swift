//
//  ImageTheming.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 7/31/26.
//

import SwiftUI

extension Theme {
    var mascotImage: ImageResource {
        switch self {
        case .campaign2024, .campaign2025:
            return .l2CuPixel2024
        case .campaign2026:
            return .cowbotL2Cu
        default:
            return .l2Cu
        }
    }
    
    var mascotHeadImage: ImageResource {
        switch self {
        case .campaign2024, .campaign2025:
            return .l2CuHeadPixel
        default:
            return .l2CuHeadOutline
        }
    }
    
    var headToHeadWinnerToken1: ImageResource? {
        switch self {
        case .campaign2026:
            return .challengeCoinMyke2026
        default:
            return nil
        }
    }
    
    var headToHeadWinnerToken2: ImageResource? {
        switch self {
        case .campaign2026:
            return .challengeCoinStephen2026
        default:
            return nil
        }
    }
}
