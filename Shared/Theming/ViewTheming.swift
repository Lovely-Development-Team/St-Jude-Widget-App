//
//  ViewTheming.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/27/26.
//

import SwiftUI

extension Theme {
    @ViewBuilder
    func randomCampaignPicker(campaignChoice: Binding<UUID?>) -> some View {
        switch self {
        case .campaign2024:
            RandomCampaignPickerView2024(campaignChoiceID: campaignChoice)
        case .campaign2026:
            RandomCampaignPickerView2026()
        default:
            RandomCampaignPickerView(campaignChoiceID: campaignChoice)
        }
    }
}
