//
//  WidgetSettingsView.swift
//  WidgetSettingsView
//
//  Created by Ben Cardy on 30/08/2021.
//

import SwiftUI

struct WidgetSettingsView: View {
    
    @AppStorage(UserDefaults.inAppShowMilestonesKey, store: UserDefaults.shared)
    private var showMilestones: Bool = true
    @AppStorage(UserDefaults.inAppPreferFutureMilestonesKey, store: UserDefaults.shared)
    private var preferFutureMilestones: Bool = true
    @AppStorage(UserDefaults.inAppShowFullCurrencySymbolKey, store: UserDefaults.shared)
    private var showFullCurrencySymbol: Bool = false
    @AppStorage(UserDefaults.inAppShowGoalPercentageKey, store: UserDefaults.shared)
    private var showGoalPercentage: Bool = true
    @AppStorage(UserDefaults.inAppShowMilestonePercentageKey, store: UserDefaults.shared)
    private var showMilestonePercentage: Bool = true
    @AppStorage(UserDefaults.inAppUseTrueBlackBackgroundKey, store: UserDefaults.shared)
    private var useTrueBlackBackground: Bool = false
    var onDismiss: ()->()
    
    @State private var imageHeight: CGFloat = 0
    
    @ViewBuilder
    var milestoneSettings: some View {
        InAppSettingsToggle("Show Milestones", isOn: $showMilestones)
        SettingsDivider()
        if showMilestones {
            Group {
                Toggle("Show Milestone Percentage", isOn: $showMilestonePercentage)
                    .padding(10)
                    .padding(.horizontal, 10)
                GeometryReader { proxy in
                    Divider()
                        .offset(x: 20, y: 0)
                        .frame(width: proxy.size.width - 20)
                    
                }
                Toggle("Prefer Future Milestones (where available)", isOn: $preferFutureMilestones)
                    .padding(10)
                    .padding(.horizontal, 10)
                GeometryReader { proxy in
                    Divider()
                        .offset(x: 20, y: 0)
                        .frame(width: proxy.size.width - 20)
                    
                }
            }
        }
    }
    
    var settingsForm: some View {
        VStack(alignment: .trailing, spacing: 0) {
            milestoneSettings
            InAppSettingsToggle("Show Full Currency Symbol", isOn: $showFullCurrencySymbol)
            SettingsDivider()
            InAppSettingsToggle("Show Main Goal Percentage", isOn: $showGoalPercentage)
            SettingsDivider()
            InAppSettingsToggle("Use True Black Background", isOn: $useTrueBlackBackground)
        }.animation(.easeInOut)
    }
    
    var appIconImage: some View {
        #if os(macOS)
        Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
        #else
        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
        #endif
    }
    
    var body: some View {
        
        VStack(spacing: 15) {
            HStack {
                appIconImage
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .background(
                        GeometryReader() { geometry -> Color in
                            DispatchQueue.main.async {
                                self.imageHeight = geometry.size.height
                            }
                            return Color.clear
                        }
                    )
                    .accessibility(hidden: true)
                Text("Relay FM for St. Jude")
                    .font(.headline)
                Spacer()
                Button(action: {
                    self.onDismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: self.imageHeight, height: self.imageHeight, alignment: .center)
                        .foregroundColor(.secondary)
                        .accessibility(label: Text("Close"))
                })
            }
            
            ScrollView(showsIndicators: false) {
                Text("Displays the current Relay FM for St. Jude fundraising status.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            
                settingsForm
                    .background(
                        Color.quaternarySystemFill
                            .cornerRadius(15)
                    )
                    .padding(.bottom)
            }
        }
        .padding([.top, .horizontal])
        .background(Color.tertiarySystemBackground)
        .accessibilityAction(.escape, onDismiss)
    }
}

struct WidgetSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetSettingsView(onDismiss: {})
            .frame(height: 375)
    }
}
