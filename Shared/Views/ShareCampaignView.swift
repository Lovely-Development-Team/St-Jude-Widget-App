//
//  ShareCampaignView.swift
//  St Jude
//
//  Created by Ben Cardy on 31/08/2022.
//

import SwiftUI

struct ImageToShare: Identifiable {
    let id: UUID
    let image: UIImage
}

struct ShareCampaignView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var fundraisingEvent: FundraisingEvent?
    @State private var campaign: Campaign?
    @State private var widgetData: TiltifyWidgetData = sampleCampaign
    
    @State private var showMilestones: Bool = false
    @State private var showMilestonePercentage: Bool = false
    @State private var preferFutureMilestones: Bool = true
    @State private var showFullCurrencySymbol: Bool = false
    @State private var showMainGoalPercentage: Bool = false
    @State private var useTrueBlackBackground: Bool = false
    @State private var appearance: WidgetAppearance = .stjude
    
    @State private var presentSystemShareSheet: ImageToShare? = nil
    
    init(fundraisingEvent: FundraisingEvent) {
        self._fundraisingEvent = State(wrappedValue: fundraisingEvent)
        self._campaign = State(wrappedValue: nil)
    }
    
    init(campaign: Campaign) {
        self._fundraisingEvent = State(wrappedValue: nil)
        self._campaign = State(wrappedValue: campaign)
    }
    
    var entryView: some View {
        EntryView(campaign: $widgetData, showMilestones: showMilestones, preferFutureMilestones: preferFutureMilestones, showFullCurrencySymbol: showFullCurrencySymbol, showGoalPercentage: showMainGoalPercentage, showMilestonePercentage: showMilestonePercentage, useTrueBlackBackground: useTrueBlackBackground, appearance: appearance)
            .frame(width: 350, height: 350)
            .clipShape(RoundedRectangle(cornerRadius: 25))
    }
    
    @ViewBuilder
    var headerView: some View {
        VStack(spacing: 0) {
            entryView
                .cornerRadius(25)
            Button(action: {
                presentSystemShareSheet = ImageToShare(id: UUID(), image: entryView.asImage)
            }) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(10)
            .padding(.horizontal, 20)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .padding()
            .sheet(item: $presentSystemShareSheet) { image in
                if let image = image {
                    ShareSheetView(activityItems: [image.image.pngData()])
                } else {
                    Text("No image generated.")
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: headerView.textCase(nil)) {
                    Toggle("Show Milestones", isOn: $showMilestones.animation())
                    if showMilestones {
                        Toggle("Show Milestone Percentage", isOn: $showMilestonePercentage.animation())
                        Toggle("Prefer Future Milestones", isOn: $preferFutureMilestones.animation())
                    }
                    Toggle("Show Full Currency Symbol", isOn: $showFullCurrencySymbol.animation())
                    Toggle("Show Main Goal Percentage", isOn: $showMainGoalPercentage.animation())
                    Toggle("Use True Black Background", isOn: $useTrueBlackBackground.animation())
                    Picker("Appearance", selection: $appearance.animation()) {
                        Text("Relay FM").tag(WidgetAppearance.relay)
                        Text("Relay FM (Inverted)").tag(WidgetAppearance.relayinverted)
                        Text("St. Jude").tag(WidgetAppearance.stjude)
                        Text("St. Jude (Inverted)").tag(WidgetAppearance.stjudeinverted)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                    }
                }
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: appearance) { newValue in
            UserDefaults.shared.shareScreenshotInitialAppearance = newValue
        }
        .onAppear {
            appearance = UserDefaults.shared.shareScreenshotInitialAppearance
            Task {
                if let campaign = campaign {
                    do {
                        widgetData = try await TiltifyWidgetData(from: campaign)
                    } catch {
                        dataLogger.error("Unable to create TiltifyWidgetData from Campaign: \(error.localizedDescription)")
                    }
                } else if let fundraisingEvent = fundraisingEvent {
                    widgetData = await TiltifyWidgetData(from: fundraisingEvent)
                }
            }
        }
    }
}
