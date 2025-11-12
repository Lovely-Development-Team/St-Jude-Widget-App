//
//  TeamEventCardView.swift
//  St Jude
//
//  Created by Ben Cardy on 29/08/2022.
//

import SwiftUI

struct TeamEventCardView: View {
    
    let teamEvent: TeamEvent?
    let showDisclosureIndicator: Bool
    var showShareIcon: Bool = false
    var appearance: WidgetAppearance = .stjude
    @Binding var showShareSheet: Bool
    @State private var showShareLinkSheet: ShareURL? = nil
    var showBackground: Bool = true
    @AppStorage(UserDefaults.disableCombosKey, store: UserDefaults.shared) var disableCombos: Bool = false
    
    @ViewBuilder
    func mainProgressBar(value: Float, color: Color) -> some View {
        ProgressBar(value: .constant(value), barColour: .contentColorForAccent.opacity(0.2), fillColor: color)
            .frame(height: 15)
    }
    
    @ViewBuilder
    func mainAmountRaised(_ value: Text) -> some View {
        value
            .font(.largeTitle)
            .fontWeight(.bold)
            .lineLimit(1)
    }
    
    @ViewBuilder
    func mainPercentageReached(_ value: Text) -> some View {
        value
            .opacity(0.8)
    }
    
    @ViewBuilder
    var contents: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(teamEvent?.name ?? "Relay for St. Jude 2025")
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                                
                if showDisclosureIndicator {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .opacity(0.8)
                } else if showShareIcon {
                    Spacer()
                    Menu {
                        Button(action: {
                            showShareSheet = true
                        }) {
                            Label("Share Image", systemImage: "photo")
                        }
                        Button(action: {
                            showShareLinkSheet = ShareURL(url: URL(string: "https://stjude.org/relay")!)
                        }) {
                            Label("Share Event Link", systemImage: "link")
                        }
                        Button(action: {
                            showShareLinkSheet = ShareURL(url: URL(string: "https://donate.tiltify.com/@relay-fm/relay-fm")!)
                        }) {
                            Label("Share Direct Donation Link", systemImage: "dollarsign")
                        }
                    } label: {
                        Label("Share", image: "share")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            Text("St. Jude Children's Research Hospital")
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .opacity(0.8)
            if let teamEvent = teamEvent {
                if let percentageReached =  teamEvent.percentageReached {
                    mainProgressBar(value: Float(percentageReached), color: .contentColorForAccent)
                }
                mainAmountRaised(Text(teamEvent.totalRaised.description(showFullCurrencySymbol: false)))
                if let percentageReachedDesc = teamEvent.percentageReachedDescription {
                    mainPercentageReached(Text("\(percentageReachedDesc) of \(teamEvent.goal.description(showFullCurrencySymbol: false))"))
                }
            } else {
                mainProgressBar(value: 0, color: .contentColorForAccent)
                mainAmountRaised(Text("PLACEHOLDER"))
                    .redacted(reason: .placeholder)
                mainPercentageReached(Text("PLACEHOLDER"))
                    .redacted(reason: .placeholder)
            }
        }
    }
    
    var body: some View {
        Group {
            if(self.showBackground) {
                GroupBox {
                    self.contents
                }
                .backgroundStyle(Color.accentColor)
            } else {
                self.contents
            }
        }
        .sheet(item: $showShareLinkSheet) { url in
            ShareSheetView(activityItems: [url.url])
        }
    }
}
