//
//  MilestoneListView.swift
//  St Jude
//
//  Created by Ben Cardy on 22/08/2024.
//

import SwiftUI

struct MilestoneListView: View {
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    let milestone: Milestone
    let reached: Bool
    
    let breakPoint: DynamicTypeSize = .xLarge
    
    var layout: AnyLayout {
        if dynamicTypeSize < breakPoint {
            AnyLayout(HStackLayout(alignment: .top))
        } else {
            AnyLayout(VStackLayout(alignment: .leading))
        }
    }
    
    var body: some View {
        
        layout {
            HStack(alignment: .top) {
                Image(.checkmarkSealFillPixel)
                    .foregroundColor(reached ? .green : .secondary)
                    .opacity(reached ? 1 : 0.25)
                Text("\(milestone.name)")
                    .foregroundColor(reached ? .secondary : .primary)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            if dynamicTypeSize < breakPoint {
                Spacer()
            }
            Text(milestone.amount.description(showFullCurrencySymbol: false))
                .foregroundColor(.accentColor)
                .opacity(reached ? 0.75 : 1)
        }
    }
}

#Preview {
    VStack {
        MilestoneListView(milestone: Milestone(from: TiltifyMilestone(amount: .init(currency: "USD", value: "13"), name: "Milestone 123", publicId: .init())), reached: false)
            .padding()
        MilestoneListView(milestone: Milestone(from: TiltifyMilestone(amount: .init(currency: "USD", value: "123"), name: "Milestone 123", publicId: .init())), reached: false)
            .padding()
    }
}
