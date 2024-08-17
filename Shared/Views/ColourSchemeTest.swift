//
//  ColourSchemeTest.swift
//  St Jude
//
//  Created by Ben Cardy on 17/08/2024.
//

import SwiftUI

struct ColourSchemeTest: View {
    var body: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
            ForEach(WidgetAppearance.allCases, id: \.self) { appearance in
                VStack {
                    EntryView(campaign: .constant(sampleCampaign), showMilestones: false, preferFutureMilestones: false, showFullCurrencySymbol: false, showGoalPercentage: false, showMilestonePercentage: false, appearance: appearance, useNormalBackgroundOniOS17: true)
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    Text("\(appearance.name)")
                }
            }
        }
        .padding()
    }
}

#Preview {
    ColourSchemeTest()
}
