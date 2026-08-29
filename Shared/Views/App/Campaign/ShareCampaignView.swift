//
//  ShareCampaignView.swift
//  St Jude
//
//  Created by Ben Cardy on 31/08/2022.
//

import SwiftUI

extension CGSize {
    static let instagramStoryDimensions = CGSize(width: 1080, height: 1920)
}

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
    @AppStorage(UserDefaults.shareScreenshotDisableCombosKey, store: UserDefaults.shared) private var disableCombos: Bool = false
    
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
        EntryView(campaign: $widgetData, showMilestones: showMilestones, preferFutureMilestones: preferFutureMilestones, showFullCurrencySymbol: showFullCurrencySymbol, showGoalPercentage: showMainGoalPercentage, showMilestonePercentage: showMilestonePercentage, appearance: appearance, useNormalBackgroundOniOS17: true, disablePixelFont: disablePixelTheme, centerVertically: true, additionalPadding: 40, mainProgressBarHeight: 30, mainProgressBarPixelScale: .spriteScale * 2, milestoneProgressBarHeight: 20, disableCombos: disableCombos)
            .frame(width: CGSize.instagramStoryDimensions.width, height: CGSize.instagramStoryDimensions.height)
            .dynamicTypeSize(.accessibility3)
    }
    
    var standardView: some View {
        EntryView(campaign: $widgetData, showMilestones: showMilestones, preferFutureMilestones: preferFutureMilestones, showFullCurrencySymbol: showFullCurrencySymbol, showGoalPercentage: showMainGoalPercentage, showMilestonePercentage: showMilestonePercentage, appearance: appearance, useNormalBackgroundOniOS17: true, disablePixelFont: disablePixelTheme, disableCombos: disableCombos)
            .clipShape(RoundedRectangle(cornerRadius: (clipCorners ? 15 : 0)))
            .environment(\.font, Font.body/* TODO: (disablePixelFont: disablePixelTheme)*/)
            .frame(minHeight: 169)
            .dynamicTypeSize(.medium)
    }
    
    @ViewBuilder
    var renderView: some View {
        if self.exportForInstagram {
            instagramView
                .environment(\.font, Font.body/* TODO: (disablePixelFont: disablePixelTheme)*/)
        } else {
            standardView
                .environment(\.font, Font.body/* TODO: (disablePixelFont: disablePixelTheme)*/)
        }
    }
    
    @Environment(\.displayScale) var displayScale
    
    @MainActor func render() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let renderer = ImageRenderer(content: self.renderView)
            renderer.scale = displayScale
            renderer.proposedSize = ProposedViewSize(self.exportForInstagram ? .instagramStoryDimensions : imageSize)
            if let uiImage = renderer.uiImage {
                renderedImage = Image(uiImage: uiImage)
            }
        }
    }
    
    @ViewBuilder
    @MainActor
    var headerView: some View {
        VStack {
//            GroupBox {
                standardView
                    .background {
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    self.imageSize = geo.frame(in: .global).size
                                }
                                .onChange(of: geo.frame(in: .global).size) {
                                    self.imageSize = geo.frame(in: .global).size
                                }
                        }
                    }
                    .cornerRadius((clipCorners ? 15 : 0))
                    .padding(.bottom)
//            }
//            .themedGroupBox(type: .primary, id: "image-preview")
            ShareLink(item: renderedImage, preview: SharePreview(Text("Fundraiser image"), image: renderedImage)) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .themedButton(type: .primary, id: campaign?.id)
        }
        .padding(.bottom)
    }
    
    @ViewBuilder
    var settingsView: some View {
        GroupBox {
            VStack(spacing: 15) {
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible()), .init(.flexible()), .init(.flexible())], alignment: .leading, spacing: 10) {
                    ForEach(WidgetAppearance.allCases, id: \.self) { appearance in
                        Button(action: {
                            self.appearance = appearance
                        }) {
                            Color.clear
                            .aspectRatio(1, contentMode: .fill)
                            .overlay {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(appearance.backgroundColors.first ?? .primary)
                                        .stroke(self.appearance == appearance ? appearance.foregroundColor : .clear, lineWidth: 5)
                                        .shadow(radius: self.appearance == appearance ? 10 : 0)
                                    Circle()
                                        .fill(appearance.foregroundColor)
                                        .frame(width: 15, height: 15)
                                    Circle()
                                        .rotation(.degrees(-45))
                                        .trim(from: 0, to: 0.5)
                                        .fill(appearance.fillColor)
                                        .frame(width: 15, height: 15)
                                }
                            }
                        }
                        .sensoryFeedback(.success, trigger: self.appearance)
                    }
                }
                .padding(.top, 8)
                Toggle("Show Milestones", isOn: $showMilestones.animation())
                if showMilestones {
                    Toggle("Show Milestone Percentage", isOn: $showMilestonePercentage.animation())
                    Toggle("Prefer Future Milestones", isOn: $preferFutureMilestones.animation())
                }
                Toggle("Show Full Currency Symbol", isOn: $showFullCurrencySymbol.animation())
                Toggle("Show Main Goal Percentage", isOn: $showMainGoalPercentage.animation())
                Toggle(isOn: self.$clipCorners.animation(), label: {
                    VStack(alignment: .leading) {
                        Text("Rounded Corners")
                        if self.clipCorners {
                            Text("Some popular social media platforms such as Discord may not display rounded corners as intended.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                })
                //            Toggle("Disable Pixel Theme", isOn: disablePixelFontGlobally ? .constant(true) : $disablePixelTheme.animation())
                //                .disabled(disablePixelFontGlobally)
                Toggle("Export in 9:16", isOn: $exportForInstagram)
                Toggle("Disable Goal Multipliers", isOn: $disableCombos)
            }
        }
        .themedGroupBox(type: .primary)
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack {
                    self.headerView
                }
                .padding(.horizontal)
                .background {
                    Theme.current.skyView(forMainScreen: false)
                }
                VStack {
                    self.settingsView
                        .padding(.top)
                }
                .padding(.top)
                .padding(.horizontal)
                .background {
                    VStack(spacing: 0) {
                        Theme.current.landscapeToBackgroundTransition
                        Theme.current.backgroundView
                    }
                }
            }
        }
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
        .onChange(of: appearance) {
            render()
        }
        .onChange(of: exportForInstagram) {
            render()
        }
        .onChange(of: clipCorners) {
            render()
        }
        .onChange(of: showMilestones) {
            render()
        }
        .onChange(of: showMilestonePercentage) {
            render()
        }
        .onChange(of: preferFutureMilestones) {
            render()
        }
        .onChange(of: showFullCurrencySymbol) {
            render()
        }
        .onChange(of: showMainGoalPercentage) {
            render()
        }
        .onChange(of: widgetData) {
            render()
        }
        .onChange(of: disablePixelTheme) {
            render()
        }
        .onChange(of: disableCombos) {
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
