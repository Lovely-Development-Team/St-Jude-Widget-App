//
//  WidgetSettingsView.swift
//  WidgetSettingsView
//
//  Created by Ben Cardy on 30/08/2021.
//

import UIKit
import SwiftUI

struct WidgetSettingsView: View {
    
    @Binding var showMilestones: Bool
    @Binding var showFullCurrencySymbol: Bool
    
    var body: some View {
        
        VStack(spacing: 15) {
            
            HStack {
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    //            Text(UIApplication.displayName)
                Text("Relay FM for St. Jude")
                    .font(.headline)
                Spacer()
            }
            
            Text("Displays the current Relay FM for St. Jude funraising status.")
                .font(.callout)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                Toggle("Show Milestones", isOn: $showMilestones)
                    .padding(10)
                    .padding(.horizontal, 10)
                Divider()
                    .offset(x: 20, y: 0)
                Toggle("Show Full Currency Symbol", isOn: $showFullCurrencySymbol)
                    .padding(10)
                    .padding(.horizontal, 10)
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            
            Spacer()
            
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        
    }
}

struct WidgetSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetSettingsView(showMilestones: .constant(false), showFullCurrencySymbol: .constant(true))
    }
}
