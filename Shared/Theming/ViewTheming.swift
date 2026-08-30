//
//  ViewTheming.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/27/26.
//

import SwiftUI

extension Theme {
    @ViewBuilder
    func randomCampaignPicker(selectedDestination: Binding<CampaignListDestination?>) -> some View {
        switch self {
        case .campaign2024:
            RandomCampaignPickerView2024(selectedDestination: selectedDestination)
        case .campaign2026:
            RandomCampaignPickerView2026(selectedDestination: selectedDestination)
        default:
            RandomCampaignPickerView(selectedDestination: selectedDestination)
        }
    }
}
