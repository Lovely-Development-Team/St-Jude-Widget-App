//
//  ShareCampaignView.swift
//  St Jude
//
//  Created by Ben Cardy on 31/08/2022.
//

import SwiftUI

struct ShareCampaignView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var teamEvent: TeamEvent?
    @State private var campaign: Campaign?
    @State private var widgetData: TiltifyWidgetData = sampleCampaign

    @AppStorage(UserDefaults.disablePixelFontKey, store: UserDefaults.shared) private var disablePixelFontGlobally: Bool = false
    
    @AppStorage(UserDefaults.shareScreenshotShowMilestonesKey, store: UserDefaults.shared) private var showMilestones: Bool = false
    @AppStorage(UserDefaults.shareScreenshotShowMilestonePercentageKey, store: UserDefaults.shared) private var showMilestonePercentage: Bool = false
    @AppStorage(UserDefaults.shareScreenshotPreferFutureMilestonesKey , store: UserDefaults.shared) private var preferFutureMilestones: Bool = true
    @AppStorage(UserDefaults.shareScreenshotShowFullCurrencySymbolKey , store: UserDefaults.shared) private var showFullCurrencySymbol: Bool = false
    @AppStorage(UserDefaults.shareScreenshotShowMainGoalPercentageKey , store: UserDefaults.shared) private var showMainGoalPercentage: Bool = false
    @AppStorage(UserDefaults.shareScreenshotClipCornersKey, store: UserDefaults.shared) private var clipCorners: Bool = false
    @AppStorage(UserDefaults.shareScreenshotInitialAppearanceKey, store: UserDefaults.shared) private var appearance: WidgetAppearance = .yellow
    @AppStorage(UserDefaults.shareScreenshotDisablePixelThemeKey, store: UserDefaults.shared) private var disablePixelTheme: Bool = false
    @AppStorage(UserDefaults.shareScreenshotExport169Key, store: UserDefaults.shared) private var exportForInstagram: Bool = false
    
    @State private var renderedImage = Image(systemName: "photo")
    @State private var imageSize: CGSize = .zero
    
    init(campaign: Campaign) {
        self._teamEvent = State(wrappedValue: nil)
        self._campaign = State(wrappedValue: campaign)
    }
    
    init(teamEvent: TeamEvent) {
        self._teamEvent = State(wrappedValue: teamEvent)
        self._campaign = State(wrappedValue: nil)
    }
    
    var instagramView: some View {
        EntryView(campaign: $widgetData, showMilestones: showMilestones, preferFutureMilestones: preferFutureMilestones, showFullCurrencySymbol: showFullCurrencySymbol, showGoalPercentage: showMainGoalPercentage, showMilestonePercentage: showMilestonePercentage, appearance: appearance, useNormalBackgroundOniOS17: true, disablePixelFont: disablePixelTheme, centerVertically: true, additionalPadding: 40, mainProgressBarHeight: 30, milestoneProgressBarHeight: 20)
            .frame(width: 1080, height: 1920)
            .dynamicTypeSize(.accessibility3)
    }
    
    var standardView: some View {
        EntryView(campaign: $widgetData, showMilestones: showMilestones, preferFutureMilestones: preferFutureMilestones, showFullCurrencySymbol: showFullCurrencySymbol, showGoalPercentage: showMainGoalPercentage, showMilestonePercentage: showMilestonePercentage, appearance: appearance, useNormalBackgroundOniOS17: true, disablePixelFont: disablePixelTheme)
            .clipShape(RoundedRectangle(cornerRadius: (clipCorners ? 15 : 0)))
            .environment(\.font, Font.body(disablePixelFont: disablePixelTheme))
            .frame(minHeight: 169)
            .dynamicTypeSize(.medium)
    }
    
    @ViewBuilder
    var renderView: some View {
        if self.exportForInstagram {
            instagramView
                .environment(\.font, Font.body(disablePixelFont: disablePixelTheme))
        } else {
            standardView
                .environment(\.font, Font.body(disablePixelFont: disablePixelTheme))
        }
    }
    
    @Environment(\.displayScale) var displayScale
    
    @MainActor func render() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let renderer = ImageRenderer(content: self.renderView)
            renderer.scale = displayScale
            renderer.proposedSize = ProposedViewSize(self.exportForInstagram ? CGSize(width: 1080, height: 1920) : imageSize)
            if let uiImage = renderer.uiImage {
                renderedImage = Image(uiImage: uiImage)
            }
        }
    }
    
    @ViewBuilder
    @MainActor
    var headerView: some View {
        VStack(spacing: 0) {
            standardView
                .background {
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                self.imageSize = geo.frame(in: .global).size
                            }
                            .onChange(of: geo.frame(in: .global).size) { newValue in
                                self.imageSize = newValue
                            }
                    }
                }
                .cornerRadius((clipCorners ? 15 : 0))
                .padding(.horizontal)
            ShareLink(item: renderedImage, preview: SharePreview(Text("Fundraiser image"), image: renderedImage)) {
                Label("Share", image: "share.pixel")
            }
                .font(.headline)
                .foregroundColor(.white)
                .buttonStyle(BlockButtonStyle(tint: .accentColor))
                .padding()
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    headerView
                    VStack {
                        Toggle("Show Milestones", isOn: $showMilestones.animation()).padding(.top, 8).padding(.trailing)
                        Divider().opacity(0.75)
                        if showMilestones {
                            Toggle("Show Milestone Percentage", isOn: $showMilestonePercentage.animation()).padding(.trailing)
                            Divider().opacity(0.75)
                            Toggle("Prefer Future Milestones", isOn: $preferFutureMilestones.animation()).padding(.trailing)
                            Divider().opacity(0.75)
                        }
                        Toggle("Show Full Currency Symbol", isOn: $showFullCurrencySymbol.animation()).padding(.trailing)
                        Divider().opacity(0.75)
                        Toggle("Show Main Goal Percentage", isOn: $showMainGoalPercentage.animation()).padding(.trailing)
                        Divider().opacity(0.75)
                        Toggle("Rounded Corners", isOn: $clipCorners.animation()).padding(.trailing)
                        Divider().opacity(0.75)
                        Toggle("Disable Pixel Theme", isOn: disablePixelFontGlobally ? .constant(true) : $disablePixelTheme.animation()).padding(.trailing)
                            .disabled(disablePixelFontGlobally)
                        Divider().opacity(0.75)
                        Toggle("Export in 9:16", isOn: $exportForInstagram).padding(.trailing)
                        Divider().opacity(0.75)
                        HStack(alignment: .firstTextBaseline) {
                            Text("Appearance")
                            Spacer()
                            Picker("Appearance", selection: $appearance.animation()) {
                                ForEach(WidgetAppearance.allCases, id: \.self) { appearance in
                                    Text(appearance.name).tag(appearance)
                                }
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    .padding(.leading)
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(UIColor.systemBackground)))
                    .padding(.horizontal)
                    Text(clipCorners ? "Some popular social media platforms such as Discord may not display rounded corners as intended." : "")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color.secondary)
                        .padding(.horizontal, 30)
                        .padding(.bottom)
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
            }
            .background(Color.secondarySystemBackground)
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: appearance) { _ in
            render()
        }
        .onChange(of: exportForInstagram) { _ in
            render()
        }
        .onChange(of: clipCorners) { _ in
            render()
        }
        .onChange(of: showMilestones) { _ in
            render()
        }
        .onChange(of: showMilestonePercentage) { _ in
            render()
        }
        .onChange(of: preferFutureMilestones) { _ in
            render()
        }
        .onChange(of: showFullCurrencySymbol) { _ in
            render()
        }
        .onChange(of: showMainGoalPercentage) { _ in
            render()
        }
        .onChange(of: widgetData) { _ in
            render()
        }
        .onChange(of: disablePixelTheme) { _ in
            render()
        }
        .task {
            if let campaign = campaign {
                do {
                    widgetData = try await TiltifyWidgetData(from: campaign)
                } catch {
                    dataLogger.error("Unable to create TiltifyWidgetData from Campaign: \(error.localizedDescription)")
                }
            } else if let teamEvent = teamEvent {
                widgetData = await TiltifyWidgetData(from: teamEvent)
            }
            render()
        }
    }
}
