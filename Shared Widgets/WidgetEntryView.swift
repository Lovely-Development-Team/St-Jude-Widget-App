//
//  WidgetEntryView.swift
//  WidgetEntryView
//
//  Created by David on 25/08/2021.
//

import SwiftUI
import WidgetKit

struct WidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    
    var entry: Provider.Entry
    
    var showPreviousMilestone: Bool {
        return isExtraLargeSize(family: family) || entry.campaign.nextMilestone == nil
    }
    
    var titleFont: Font {
        switch family {
        case .systemSmall:
            return .headline
        case .systemMedium:
            return .title2
        default:
            return .largeTitle
        }
    }
    
    var raisedAmountFont: Font {
        switch family {
        case .systemSmall:
            return .headline
        default:
            return .largeTitle
        }
    }
    
    
    var body: some View {
        EntryView(campaign: .constant(entry.campaign), showMilestones: entry.configuration.showMilestones?.boolValue == true, showFullCurrencySymbol: entry.configuration.showFullCurrencySymbol?.boolValue ?? false)
    }
}
