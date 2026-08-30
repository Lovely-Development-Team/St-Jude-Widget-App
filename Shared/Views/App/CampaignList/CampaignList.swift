//
//  CampaignList.swift
//  St Jude
//
//  Created by Ben Cardy on 18/08/2022.
//

import SwiftUI
import GRDB

enum CampaignListDestination: Hashable {
    case teamEvent(TeamEvent)
    case campaign(Campaign, Bool)
    case headToHead(HeadToHeadWithCampaigns)
}

struct CampaignList: View {
    @State private var fundraiserListIsRefreshing: Bool = true
    @State private var isRefreshing: Bool = true
    
    @State private var teamEvent: TeamEvent? = nil
    @State private var teamEventObservation = AppDatabase.shared.observeTeamEventObservation()
    @State private var teamEventCancellable: DatabaseCancellable?
    
    @State private var showSheet: CampaignListSheet? = nil
    
    @State private var selectedDestination: CampaignListDestination?
    
    @State private var rotationAnimation: Bool = false
    
    @Binding var navigationPath: NavigationPath
    
    @AppStorage(UserDefaults.iconsUnlockedKey, store: UserDefaults.shared) private var iconsUnlocked: Bool = false
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    // TODO: Fix this
//    @ViewBuilder
//    var widgetCompatibilityView: some View {
//        //                        if selectedCampaignId != nil {
//        /// In order to open a selected campaign when a widget is tapped, the corresponding
//        /// NavigationLink needs to be loaded. That  isn't guaranteed when they are presented
//        /// in a Lazy grid as below, so we create a bunch of empty/invisible NavigationLinks to
//        /// trigger on the widget tap instead
//        ForEach(allCampaigns, id: \.id) { campaign in
//            NavigationLink(destination: CampaignView(initialCampaign: campaign), tag: campaign.id, selection: $selectedCampaignId) {
//                EmptyView()
//            }
//        }
//        
//        ForEach(headToHeads, id: \.headToHead.id) { headToHead in
//            NavigationLink(destination: HeadToHeadView(campaign1: headToHead.campaign1, campaign2: headToHead.campaign2), tag: headToHead.headToHead.id, selection: $selectedCampaignId) {
//                EmptyView()
//            }
//        }
//    }
    
    @Namespace var namespace
    
    @ViewBuilder
    var topView: some View {
        VStack(spacing: 0) {
            Group {
                VStack {
                    Group {
                        if let teamEvent = teamEvent {
                            NavigationLink(value: CampaignListDestination.teamEvent(teamEvent)) {
                                TeamEventCardView(teamEvent: teamEvent, showDisclosureIndicator: true, showShareSheet: .constant(false), showBackground: false)
                                    .foregroundStyle(Theme.current.contentColorForAccent)
                            }
                            .themedButton(type: .primary,
                                          capsuleShape: false,
                                          boldText: false, id: teamEvent.id)
                            .padding(.vertical)
                            .zoomTransitioniOS26Source(id: "mainCampaignCard", namespace: self.namespace)
                        } else {
                            TeamEventCardView(teamEvent: teamEvent, showDisclosureIndicator: true, showShareSheet: .constant(false))
                                .padding(.vertical)
                                .foregroundStyle(Theme.current.contentColorForAccent)
                        }
                    }
                }
                .padding(.horizontal)
                Theme.current.topViewLandscape()
            }
            .frame(maxWidth: Double.stretchedContentMaxWidth)
        }
        .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollViewReader in
                VStack(spacing: 0) {
                    VStack{
                        self.topView
                    }
                    .background {
                        Theme.current.skyView()
                    }

                    Group {
                        VStack {
                            CountdownView()
                                .frame(maxWidth: Double.stretchedContentMaxWidth)
                            FundraiserListView(namespace: self.namespace,
                                               showSheet: self.$showSheet, selectedDestination: self.$selectedDestination,
                                               isRefreshing: self.$fundraiserListIsRefreshing)
                            .padding(.top)
                            self.easterEggView
                            // TODO: fix this
                            //                        widgetCompatibilityView
                        }
                        .padding(.top)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .background {
                        VStack(spacing: 0) {
                            Theme.current.landscapeToBackgroundTransition
                            Theme.current.backgroundView
                        }
                    }
                    .overlay(alignment: .bottom) {
                        if !self.isRefreshingAll {
                            Theme.current.campaignListEasterEggView
                                .offset(y: 700)
                        }
                    }
                }
                .rotationEffect(Angle(degrees: rotationAnimation ? 0 : 360))
            }
        }
        .navigationDestination(for: CampaignListDestination.self) { value in
            switch value {
            case let .teamEvent(teamEvent):
                CampaignView(teamEvent: teamEvent, namespace: self.namespace)
                    .zoomTransitioniOS26(id: "mainCampaignCard", namespace: self.namespace)
            case let .campaign(campaign, zoomTransition):
                if zoomTransition {
                    CampaignView(initialCampaign: campaign, namespace: self.namespace)
                        .zoomTransitioniOS26(id: "subCampaignCard-\(campaign.id)", namespace: self.namespace)
                } else {
                    CampaignView(initialCampaign: campaign, namespace: self.namespace)
                }
            case let .headToHead(headToHead):
                HeadToHeadView(campaign1: headToHead.campaign1, campaign2: headToHead.campaign2)
                    .zoomTransitioniOS26(id: "headToHead-\(headToHead.campaign1.id)-\(headToHead.campaign2.id)-", namespace: self.namespace)
            }
        }
        .navigationTitle("Relay for St. Jude")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showSheet = .aboutScreen
                }) {
                    Image(systemName: "info")
                }
                .zoomTransitioniOS26Source(id: "aboutButton", namespace: self.namespace)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.refreshAll()
                }) {
                    ZStack {
                        if self.isRefreshingAll {
                            ProgressView()
                        }
                        Image(systemName: "arrow.clockwise")
                            .opacity(self.isRefreshingAll ? 0 : 1)
                    }
                }
                .keyboardShortcut("r")
                .disabled(self.isRefreshingAll)
            }
        }
        // MARK: Data/Refreshing/Init
        .refreshable {
            self.refreshAll()
        }
        .onReceive(timer) { _ in
            self.refreshAll()
        }
        .onChange(of: self.isRefreshing) {
            Task {
                await refresh()
            }
        }
        .onChange(of: self.selectedDestination) {
            guard let destination = self.selectedDestination else {
                return
            }
            
            self.navigationPath.append(destination)
        }
        .onAppear {
            teamEventCancellable = AppDatabase.shared.start(observation: teamEventObservation) { error in
                dataLogger.error("Error observing stored team event: \(error.localizedDescription)")
            } onChange: { event in
                teamEvent = event
            }
            
            Task {
                await refresh()
            }
        }
        .onOpenURL { url in
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false), components.host == "campaign", let queryComponents = components.queryItems?.reduce(into: [String: String](), { (result, item) in
                result[item.name] = item.value
            }), let id = queryComponents["id"] {
                showSheet = nil
            }
        }
        // MARK: Sheets
        .sheet(item: $showSheet, onDismiss: {
            SoundEffectHelper.shared.stop()
        }) { sheet in
            CampaignListSheetContent(sheet: sheet,
                                     showSheet: self.$showSheet,
                                     selectedDestination: self.$selectedDestination,
                                     refreshFundraisers: self.$fundraiserListIsRefreshing,
                                     namespace: self.namespace)
        }
    }
    
}

// MARK: - Easter Egg
extension CampaignList {
    @ViewBuilder
    var easterEggView: some View {
        Button(action: {
            showSheet = .easterEgg
        }, label: {
            HStack {
                Text("App from the Lovely Developers")
                    .font(.caption)
                    .bold()
                Image(Theme.current.mascotHeadImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .accessibility(hidden: true)
                
            }
            .frame(maxWidth: .infinity)
        })
        .themedButton(type: .secondary, textColor: .primary, id: "easter-egg-link")
        .frame(maxWidth: Double.stretchedContentMaxWidth)
        .zoomTransitioniOS26Source(id: "easterEggButton", namespace: self.namespace)
    }
}

// MARK: - Data
extension CampaignList {
    func refreshAll() {
        self.isRefreshing = true
        self.fundraiserListIsRefreshing = true
    }
    
    var isRefreshingAll: Bool {
        return self.isRefreshing || self.fundraiserListIsRefreshing
    }
    
    func refresh() async {
        if let apiEventData = await TiltifyAPIClient.shared.getFundraisingEvent() {
            dataLogger.debug("API fetched TeamEvent: \(apiEventData.name)")
            let apiEvent = TeamEvent(from: apiEventData)
            do {
                if let existingTeamEvent = teamEvent {
                    teamEvent = apiEvent
                    if try await AppDatabase.shared.updateTeamEvent(apiEvent, changesFrom: existingTeamEvent) {
                        dataLogger.info("Updated team event \(apiEvent.name) (id: \(apiEvent.id)")
                    }
                } else {
                    dataLogger.debug("Saved new team event")
                    teamEvent = try! await AppDatabase.shared.saveTeamEvent(apiEvent)
                }
            } catch {
                dataLogger.error("Updating stored team event failed: \(error.localizedDescription)")
            }
        }
        self.isRefreshing = false
    }
}

struct CampaignList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampaignList(navigationPath: .constant(NavigationPath()))
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}
