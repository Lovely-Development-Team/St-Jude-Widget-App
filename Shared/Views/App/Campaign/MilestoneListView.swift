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
    var percentage: Float = 0.4
    
    let breakPoint: DynamicTypeSize = .xLarge
    
    var layout: AnyLayout {
        if dynamicTypeSize < breakPoint {
            AnyLayout(HStackLayout(alignment: .top))
        } else {
            AnyLayout(VStackLayout(alignment: .leading))
        }
    }
    
    var body: some View {
        
        VStack(spacing: 5) {
            layout {
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(reached ? Theme.current.accentColor : .secondary)
                        .opacity(reached ? 1 : 0.25)
                    Text("\(milestone.name)")
                        .foregroundColor(reached ? .secondary : .primary)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                if dynamicTypeSize < breakPoint {
                    Spacer()
                }
                Text(milestone.amount.description(showFullCurrencySymbol: false))
                    .foregroundColor(Theme.current.accentColor)
                    .opacity(reached ? 0.75 : 1)
            }
            ProgressBar(value: .constant(percentage), fillColor: Theme.current.accentColor)
                .frame(height: 3)
                .opacity(reached ? 0.25 : 1)
        }
    }
}

#Preview {
    GroupBox {
        VStack(spacing: 10) {
            MilestoneListView(milestone: Milestone(from: TiltifyMilestone(amount: .init(currency: "USD", value: "13"), name: "Milestone 123", publicId: .init())), reached: true)
            MilestoneListView(milestone: Milestone(from: TiltifyMilestone(amount: .init(currency: "USD", value: "123"), name: "Milestone 123", publicId: .init())), reached: false)
        }
    }
    .padding()
}
