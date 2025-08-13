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
        ProgressBar(value: .constant(value), fillColor: color)
            .frame(height: 15)
            .padding(.bottom, 2)
    }
    
    @ViewBuilder
    func mainAmountRaised(_ value: Text) -> some View {
        value
            .font(.largeTitle)
            .fontWeight(.bold)
            .minimumScaleFactor(0.7)
            .lineLimit(1)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    func mainPercentageReached(_ value: Text) -> some View {
        value
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .opacity(0.8)
    }
    
    @ViewBuilder
    var contents: some View {
        VStack(spacing: 0) {
            HStack {
                Text(teamEvent?.name ?? "Relay for St. Jude 2025")
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 2)
                                
                if showDisclosureIndicator {
                    Spacer()
                    Image(systemName:"chevron.right")
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
                        Label("Share", systemImage: "square.and.arrow.up")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            Text("St. Jude Children's Research Hospital")
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .opacity(0.8)
                .padding(.bottom, 20)
            if let teamEvent = teamEvent {
                if let percentageReached =  teamEvent.percentageReached {
                    mainProgressBar(value: Float(percentageReached), color: appearance.fillColor)
                }
                mainAmountRaised(Text(teamEvent.totalRaised.description(showFullCurrencySymbol: false)))
                if let percentageReachedDesc = teamEvent.percentageReachedDescription {
                    mainPercentageReached(Text("\(percentageReachedDesc) of \(teamEvent.goal.description(showFullCurrencySymbol: false))"))
                }
            } else {
                mainProgressBar(value: 0, color: appearance.fillColor)
                mainAmountRaised(Text("PLACEHOLDER"))
                    .redacted(reason: .placeholder)
                mainPercentageReached(Text("PLACEHOLDER"))
                    .redacted(reason: .placeholder)
            }
        }
        .foregroundColor(appearance.foregroundColor)
    }
    
    var body: some View {
        Group {
            if(self.showBackground) {
                self.contents
                    .padding()
                    .background(LinearGradient(colors: appearance.backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(10)
            } else {
                self.contents
            }
        }
        .sheet(item: $showShareLinkSheet) { url in
            ShareSheetView(activityItems: [url.url])
        }
    }
}
