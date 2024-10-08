//
//  CampaignTitle.swift
//  CampaignTitle
//
//  Created by David on 23/08/2021.
//

import SwiftUI
import WidgetKit

struct CampaignTitle: View {
    @Environment(\.widgetFamily) private var family
    
    let name: String
    var showingTwoMilestones: Bool = false
    var disablePixelFont: Bool = false
    
    var titleFont: Font {
        switch family {
        case .systemSmall:
            return .headline(disablePixelFont: disablePixelFont)
        case .systemMedium:
            return .title2(disablePixelFont: disablePixelFont)
        default:
            if showingTwoMilestones {
                return .title2(disablePixelFont: disablePixelFont)
            } else {
                return .largeTitle(disablePixelFont: disablePixelFont)
            }
        }
    }
    
    var body: some View {
        Text(name)
            .font(titleFont)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(family == .systemMedium ? 1 : 2)
            .minimumScaleFactor(0.6)
    }
}

struct CampaignTitle_Previews: PreviewProvider {
    static var previews: some View {
        CampaignTitle(name: "Relay for St. Jude 2022")
    }
}
