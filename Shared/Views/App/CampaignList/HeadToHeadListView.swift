//
//  HeadToHeadListView.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/19/25.
//

import SwiftUI

struct HeadToHeadListView: View {
    var namespace: Namespace.ID
    @Binding var headToHeads: [HeadToHeadWithCampaigns]
    @State private var showHeadToHeads: Bool = true
    @Binding var showSheet: CampaignListSheet?
    var onDelete: (() -> Void)
    
    @ViewBuilder
    var headToHeadListView: some View {
        GroupBox {
            VStack {
                Button(action: {
                    withAnimation {
                        showHeadToHeads.toggle()
                    }
                }) {
                    HStack {
                        Text("Head to Head")
                            .font(.title2)
                            .fontWeight(.bold)
                        if headToHeads.count > 0 {
                            Button(action: {
                                showSheet = .startHeadToHead
                            }) {
                                Label("Start Head to Head", systemImage: "plus").labelStyle(.iconOnly)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(Color.accentColor)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 4)
                            .aspectRatio(1.0, contentMode: .fit)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(showHeadToHeads ? 90 : 0))
                    }
                    .contentShape(Rectangle())
                }
                .themedButton(type: .plain)
                if headToHeads.count == 0 {
                    if showHeadToHeads {
                        VStack {
                            Button(action: {
                                showSheet = .startHeadToHead
                            }, label: {
                                Text("Add a Head to Head")
                                    .font(.headline)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            })
                            .themedButton(type: .primary)
                        }
                    }
                } else {
                    if showHeadToHeads {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: .infinity), alignment: .top)], spacing: 10) {
                            headToHeadList
                        }
                    }
                }
            }
        }
        .frame(maxWidth: Double.stretchedContentMaxWidth)
    }
    
    @ViewBuilder
    var headToHeadList: some View {
        ForEach(headToHeads, id: \.headToHead.id) { headToHead in
            NavigationLink(value: CampaignListDestination.headToHead(headToHead)) {
                HeadToHeadListItem(headToHead: headToHead)
                    .zoomTransitioniOS26Source(id: "headToHead-\(headToHead.campaign1.id)-\(headToHead.campaign2.id)-", namespace: self.namespace)
            }
            .contextMenu {
                Button(role: .destructive) {
                    Task {
                        do {
                            try await AppDatabase.shared.deleteHeadToHead(headToHead.headToHead)
                        } catch {
                            dataLogger.error("Could not delete head to head: \(error.localizedDescription)")
                        }
                        self.onDelete()
                    }
                } label: {
                    Label("Remove Head to Head", systemImage: "trash")
                }
            }
        }
        .compositingGroup()
    }
    
    var body: some View {
        self.headToHeadListView
            .onChange(of: self.showHeadToHeads) {
                UserDefaults.shared.expandHeadToHeadSection = self.showHeadToHeads
            }
            .onAppear {
                self.showHeadToHeads = UserDefaults.shared.expandHeadToHeadSection
            }
    }
}
