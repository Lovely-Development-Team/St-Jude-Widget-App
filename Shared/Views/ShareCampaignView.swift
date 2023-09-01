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
    
    @State private var teamEvent: TeamEvent?
    @State private var campaign: Campaign?
    @State private var widgetData: TiltifyWidgetData = sampleCampaign
    
    @State private var showMilestones: Bool = false
    @State private var showMilestonePercentage: Bool = false
    @State private var preferFutureMilestones: Bool = true
    @State private var showFullCurrencySymbol: Bool = false
    @State private var showMainGoalPercentage: Bool = false
    @State private var appearance: WidgetAppearance = .yellow
    @State private var clipCorners: Bool = false
    
    @State private var presentSystemShareSheet: ImageToShare? = nil
        
    init(campaign: Campaign) {
        self._teamEvent = State(wrappedValue: nil)
        self._campaign = State(wrappedValue: campaign)
    }
    
    init(teamEvent: TeamEvent) {
        self._teamEvent = State(wrappedValue: teamEvent)
        self._campaign = State(wrappedValue: nil)
    }
    
    var entryView: some View {
        EntryView(campaign: $widgetData, showMilestones: showMilestones, preferFutureMilestones: preferFutureMilestones, showFullCurrencySymbol: showFullCurrencySymbol, showGoalPercentage: showMainGoalPercentage, showMilestonePercentage: showMilestonePercentage, appearance: appearance, useNormalBackgroundOniOS17: true)
            .frame(minWidth: 350, maxWidth: 350, minHeight: 200, maxHeight: 450)
            .clipShape(RoundedRectangle(cornerRadius: (clipCorners ? 15 : 0)))
    }
    
    @ViewBuilder
    @MainActor
    var headerView: some View {
        VStack(spacing: 0) {
            entryView
                .cornerRadius((clipCorners ? 15 : 0))
            Button(action: {
                    let renderer =  ImageRenderer(content: entryView)
                    renderer.scale = 3.0
                    if let image =  renderer.cgImage {
                        presentSystemShareSheet = ImageToShare(id: UUID(), image: UIImage(cgImage: image))
                    }
                                
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
                if let data = image.image.pngData() {
                    ShareSheetView(activityItems: [data])
                } else {
                    ShareSheetView(activityItems: [image.image])
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: headerView.textCase(nil), footer: Text(clipCorners ? "Some popular social media platforms such as Discord may not display rounded corners as intended." : "")) {
                    Toggle("Show Milestones", isOn: $showMilestones.animation())
                    if showMilestones {
                        Toggle("Show Milestone Percentage", isOn: $showMilestonePercentage.animation())
                        Toggle("Prefer Future Milestones", isOn: $preferFutureMilestones.animation())
                    }
                    Toggle("Show Full Currency Symbol", isOn: $showFullCurrencySymbol.animation())
                    Toggle("Show Main Goal Percentage", isOn: $showMainGoalPercentage.animation())
                    Picker("Appearance", selection: $appearance.animation()) {
                        Text("Relay FM").tag(WidgetAppearance.relay)
                        Text("St. Jude").tag(WidgetAppearance.stjude)
                        Text("Relay FM (True Black)").tag(WidgetAppearance.relaytrueblack)
                        Text("St. Jude (True Black)").tag(WidgetAppearance.stjudetrueblack)
                        Text("Yellow").tag(WidgetAppearance.yellow)
                        Text("Red").tag(WidgetAppearance.red)
                        Text("Blue").tag(WidgetAppearance.blue)
                        Text("Green").tag(WidgetAppearance.green)
                        Text("Purple").tag(WidgetAppearance.purple)
                    }
                    Toggle("Rounded Corners", isOn: $clipCorners.animation())
                    
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
        .onChange(of: clipCorners) { newValue in
            UserDefaults.shared.shareScreenshotClipCorners = newValue
        }
        .onAppear {
            appearance = UserDefaults.shared.shareScreenshotInitialAppearance
            clipCorners = UserDefaults.shared.shareScreenshotClipCorners
            Task {
                if let campaign = campaign {
                    do {
                        widgetData = try await TiltifyWidgetData(from: campaign)
                    } catch {
                        dataLogger.error("Unable to create TiltifyWidgetData from Campaign: \(error.localizedDescription)")
                    }
                } else if let teamEvent = teamEvent {
                    widgetData = await TiltifyWidgetData(from: teamEvent)
                }
            }
        }
    }
}
