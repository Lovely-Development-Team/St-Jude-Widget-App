//
//  SharePollView.swift
//  Intents Extension
//
//  Created by Justin Hamilton on 9/12/26.
//

import SwiftUI
import WidgetKit

let renderedPollShareImageFileName = "St Jude Fundraiser Poll.png"

struct SharePollView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var poll: Poll
    var options: [PollOption]
    var parentCampaign: Campaign?
    var parentTeamEvent: TeamEvent?
    
    @State private var widgetData: TiltifyWidgetData? = nil

    @AppStorage(UserDefaults.shareScreenshotShowFullCurrencySymbolKey , store: UserDefaults.shared) private var showFullCurrencySymbol: Bool = false
    @AppStorage(UserDefaults.shareScreenshotClipCornersKey, store: UserDefaults.shared) private var clipCorners: Bool = false
    @AppStorage(UserDefaults.shareScreenshotInitialAppearanceKey, store: UserDefaults.shared) private var appearance: WidgetAppearance = .yellow
    @AppStorage(UserDefaults.shareScreenshotExport169Key, store: UserDefaults.shared) private var exportForInstagram: Bool = false
    @AppStorage(UserDefaults.shareScreenshotPollDisbleParentCampaignInfoKey, store: UserDefaults.shared) private var hideParentCampaignInfo: Bool = false
    
    @State private var renderedImage = Image(systemName: "photo")
    @State private var renderedImageURL: URL? = nil
    @State private var shareActivityItems: [Any]? = nil
    @State private var imageSize: CGSize = .zero
    
    var instagramView: some View {
        PollWidgetEntryView(poll: self.poll,
                            options: self.options,
                            parentCampaign: self.widgetData,
                            appearance: self.appearance,
                            showFullCurrencySymbol: self.showFullCurrencySymbol,
                            showParentCampaignInfo: !self.hideParentCampaignInfo,
                            useNormalBackground: true,
                            isForWidget: false,
                            overrideWidgetFamily: .systemExtraLarge)
            .frame(width: CGSize.instagramStoryDimensions.width, height: CGSize.instagramStoryDimensions.height)
            .dynamicTypeSize(.accessibility3)
    }
    
    var standardView: some View {
        PollWidgetEntryView(poll: self.poll,
                            options: self.options,
                            parentCampaign: self.widgetData,
                            appearance: self.appearance,
                            showFullCurrencySymbol: self.showFullCurrencySymbol,
                            showParentCampaignInfo: !self.hideParentCampaignInfo,
                            useNormalBackground: true,
                            isForWidget: false,
                            overrideWidgetFamily: .systemExtraLarge)
            .clipShape(RoundedRectangle(cornerRadius: (clipCorners ? 15 : 0)))
            .environment(\.font, Font.body)
            .frame(minHeight: 169)
            .dynamicTypeSize(.medium)
    }
    
    @ViewBuilder
    var renderView: some View {
        if self.exportForInstagram {
            instagramView
                .environment(\.font, Font.body)
        } else {
            standardView
                .environment(\.font, Font.body)
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
                renderedImageURL = writeToTemporaryFile(uiImage)
            }
        }
    }
    
    // macOS sharing fixes, needs an actual file with a proper filename
    private func writeToTemporaryFile(_ uiImage: UIImage) -> URL? {
        guard let data = uiImage.pngData() else {
            dataLogger.error("Unable to create PNG data from rendered image")
            return nil
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(renderedShareImageFileName)
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            dataLogger.error("Unable to write rendered image to \(url.path): \(error.localizedDescription)")
            return nil
        }
    }
    
    @ViewBuilder
    @MainActor
    var headerView: some View {
        VStack {
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
            if ProcessInfo.processInfo.isiOSAppOnMac {
                Button(action: {
                    if let renderedImageURL {
                        shareActivityItems = [renderedImageURL]
                    }
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .themedButton(type: .primary, id: self.poll.id)
                .disabled(renderedImageURL == nil)
                .background {
                    ShareSheetPresenter(activityItems: $shareActivityItems)
                }
            } else if let renderedImageURL {
                ShareLink(item: renderedImageURL, preview: SharePreview(Text("Fundraiser image"), image: renderedImage)) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .themedButton(type: .primary, id: self.poll.id)
            } else {
                Button(action: {}) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .themedButton(type: .primary, id: self.poll.id)
                .disabled(true)
            }
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
                                        .fill(.clear)
                                        .stroke(self.appearance == appearance ? appearance.foregroundColor : .clear, lineWidth: 5)
                                        .background {
                                            appearance.background(isForWidget: false)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 8)).clipped()
                                        .shadow(radius: self.appearance == appearance ? 10 : 0)
                                    Circle()
                                        .fill(appearance.foregroundColor)
                                        .frame(width: 20, height: 20)
                                    Circle()
                                        .rotation(.degrees(-45))
                                        .trim(from: 0, to: 0.5)
                                        .fill(appearance.fillColor)
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                        .sensoryFeedback(.success, trigger: self.appearance)
                    }
                }
                .padding(.top, 8)
                Toggle("Hide Parent Campaign Info", isOn: self.$hideParentCampaignInfo.animation())
                Toggle("Show Full Currency Symbol", isOn: $showFullCurrencySymbol.animation())
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
                Toggle("Export in 9:16", isOn: $exportForInstagram)
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
        .onChange(of: self.hideParentCampaignInfo) {
            render()
        }
        .onChange(of: self.appearance) {
            render()
        }
        .onChange(of: self.exportForInstagram) {
            render()
        }
        .onChange(of: self.clipCorners) {
            render()
        }
        .onChange(of: self.showFullCurrencySymbol) {
            render()
        }
        .onChange(of: self.poll) {
            render()
        }
        .onChange(of: self.options) {
            render()
        }
        .onChange(of: self.widgetData) {
            render()
        }
        .task {
            do {
                if let parentCampaign {
                    self.widgetData = try await TiltifyWidgetData(from: parentCampaign)
                } else if let parentTeamEvent {
                    self.widgetData = await TiltifyWidgetData(from: parentTeamEvent)
                }
            } catch {
                dataLogger.error("Failed to create widgetData: \(error.localizedDescription)")
            }
            
            render()
        }
    }
}
