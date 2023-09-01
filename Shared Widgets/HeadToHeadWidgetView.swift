//
//  HeadToHeadWidgetView.swift
//  St Jude
//
//  Created by Justin Hamilton on 8/31/23.
//

import SwiftUI
import WidgetKit

struct HeadToHeadWidgetView: View {
    @Environment(\.widgetFamily) var family
    
    var entry: HeadToHeadProvider.Entry
    
    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(.clear, for: .widget)
        } else {
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        VStack {
            Text(entry.campaign1?.name ?? "Unknown")
            Text("VS")
            Text(entry.campaign2?.name ?? "Unknown")
            Text(entry.testString)
        }
    }
}
