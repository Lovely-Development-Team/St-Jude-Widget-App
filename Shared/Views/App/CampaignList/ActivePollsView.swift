//
//  ActivePollsView.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/11/26.
//

import SwiftUI

struct ActivePollsView: View {
    @State private var collapsed: Bool = false
    var activePolls: [Poll] = []
    
    var body: some View {
        Group {
            if !self.activePolls.isEmpty {
                GroupBox {
                    VStack() {
                        Button(action: {
                            withAnimation {
                                self.collapsed.toggle()
                            }
                        }, label: {
                            HStack {
                                Text("Active Polls")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("\(self.activePolls.count)")
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .rotationEffect(.degrees(self.collapsed ? 0 : 90))
                            }
                            .contentShape(Rectangle())
                        })
                        .themedButton(type: .plain, id: "activePollsHeader")
                        
                        if !self.collapsed {
                            ForEach(self.activePolls) { poll in
                                PollView(poll: poll, campaignId: (poll.campaignId ?? poll.teamEventId), showParentCampaignInfo: true)
                            }
                        }
                    }
                }
                .themedGroupBox(type: .primary, id: "campaignListActivePollsView")
            } else {
                EmptyView()
            }
        }
        .onAppear {
            self.collapsed = UserDefaults.shared.expandMainPollsSection
        }
    }
}

#Preview {
    ActivePollsView()
}
