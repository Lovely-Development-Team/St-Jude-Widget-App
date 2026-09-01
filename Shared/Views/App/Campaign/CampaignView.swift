//
//  CampaignView.swift
//  St Jude
//
//  Created by Ben Cardy on 25/08/2022.
//

import SwiftUI
import GRDB
import Kingfisher

struct CampaignView: View {
    var namespace: Namespace.ID
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    // MARK: 2023
    @State private var teamEvent: TeamEvent?
    @State private var teamEventObservation: ValueObservation<ValueReducers.Fetch<TeamEvent?>>?
    @State private var relayCampaign: Campaign? = nil
    
    // MARK: 2022
    
    @State private var campaignObservation: ValueObservation<ValueReducers.Fetch<Campaign?>>?
    @State private var campaignCancellable: DatabaseCancellable?
    @State private var fetchTask: Task<(), Never>?
    
    @State private var initialCampaign: Campaign?
    @State private var milestones: [Milestone] = []
    @State private var rewards: [Reward] = []
    
    @State private var donations: [TiltifyDonorsForCampaignDonation] = []
    @State private var topDonor: TiltifyTopDonor? = nil
    
    @State private var showShareView: Bool = false
    @State private var showSupporterSheet: Bool = false
    
    @State private var isRefreshing: Bool = false
    
    @State private var showPolls: Bool = true
    @State private var polls: [TiltifyCampaignPoll] = []
    
    @State private var hasDoneInitialAPIFetch: Bool = false
    
    @State private var logsContainer: LogsContainer = LogsContainer()
    @State private var refreshId: UUID = .init()
    
    private var activePolls: [TiltifyCampaignPoll] {
        return self.polls.filter { $0.active }
    }
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    init(initialCampaign: Campaign, namespace: Namespace.ID) {
        self.namespace = namespace
        _initialCampaign = State(wrappedValue: initialCampaign)
        _teamEvent = State(wrappedValue: nil)
        _campaignObservation = State(wrappedValue: AppDatabase.shared.observeCampaignObservation(for: initialCampaign))
        self.logsContainer.addLog("View initialized with Campaign, value \(initialCampaign.totalRaisedNumerical)")
    }
    
    init(teamEvent: TeamEvent, namespace: Namespace.ID) {
        self.namespace = namespace
        self.logsContainer.addLog("View initialized with Team Event, value \(teamEvent.totalRaisedNumerical)")
        _initialCampaign = State(wrappedValue: initialCampaign)
        _teamEvent = State(wrappedValue: teamEvent)
        _teamEventObservation = State(wrappedValue: AppDatabase.shared.observeTeamEventObservation())
    }
    
    var localId: UUID {
        teamEvent?.id ?? initialCampaign?.id ?? UUID()
    }
    
    var fundraiserURL: URL {
        if let initialCampaign = initialCampaign {
            return URL(string: "https://tiltify.com/@\(initialCampaign.user.slug)/\(initialCampaign.slug)")!
        } else {
            return URL(string: "https://stjude.org/relay")!
        }
    }
    
    var donateURL: URL {
        let id: UUID
        if let initialCampaign {
            id = initialCampaign.id
        } else {
            id = TEAM_EVENT_ID
        }
        return URL(string: "https://donate.tiltify.com/\(id.uuidString)")!
    }
    
    var description: AttributedString {
        let descr = teamEvent?.description ?? initialCampaign?.description ?? ""
        do {
            return try AttributedString(markdown: descr)
        } catch {
            return AttributedString(descr)
        }
    }
    
    func milestonePercentage(for milestone: Milestone) -> Float {
        let total = initialCampaign?.totalRaised.numericalValue ?? teamEvent?.totalRaised.numericalValue ?? 0
        return Float(min(1, total / milestone.amount.value))
    }
    
    func milestoneReached(for milestone: Milestone) -> Bool {
        if let initialCampaign = initialCampaign {
            return milestone.amount.value <= initialCampaign.totalRaised.numericalValue
        } else if let teamEvent = teamEvent {
            return milestone.amount.value <= teamEvent.totalRaised.numericalValue
        }
        return false
    }
    
    var grandTotalRaised: Double {
        PREVIOUS_TOTALS_RAISED.reduce(0) { $0 + $1.total } + (teamEvent?.totalRaisedNumerical ?? 0)
    }
    
    var grandTotalRaisedDescription: String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "USD"
        currencyFormatter.currencySymbol = "$"
        return currencyFormatter.string(from: grandTotalRaised as NSNumber) ?? "USD 0"
    }
    
    var milestoneAndRewardButtonColumns: [GridItem] {
        if dynamicTypeSize < .xLarge {
            return [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        } else {
            return [GridItem(.flexible())]
        }
    }
    
    @ViewBuilder
    var debugIdView: some View {
#if DEBUG
        if let initialCampaign = initialCampaign {
            GroupBox {
                Text("\(initialCampaign.id)")
                    .lineLimit(nil)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .contextMenu(menuItems: {
                        Button(action: {
                            UIPasteboard.general.string = initialCampaign.id.uuidString
                        }, label: {
                            Text("Copy")
                        })
                    })
            }
            .themedGroupBox(type: .primary, id: initialCampaign.id)
        }
#endif
    }
    
    @ViewBuilder
    func infoView(scrollViewReader: SwiftUI.ScrollViewProxy) -> some View {
        Group {
            VStack {
                VStack {
                    VStack {
                        // Top card view
                        if let initialCampaign = initialCampaign {
                            FundraiserListItem(campaign: initialCampaign, sortOrder: .byGoal, showDisclosureIndicator: false, showShareIcon: true, showShareSheet: $showShareView)
                        } else if let teamEvent = teamEvent {
                            TeamEventCardView(teamEvent: teamEvent, showDisclosureIndicator: false, showShareIcon: true, showShareSheet: $showShareView)
                                .foregroundStyle(Theme.current.contentColorForAccent)
                            
                            GroupBox {
                                VStack {
                                    HStack {
                                        // Optional threshold for a significant amount raised
                                        if let significantAmount = TeamEvent.significantAmount {
                                            if grandTotalRaised >= significantAmount {
                                                Image(systemName: "party.popper.fill")
                                            }
                                        }
                                        
                                        Text("Lifetime Total")
                                            .textCase(.uppercase)
                                        Spacer()
                                    }
                                    .font(.caption)
                                    .foregroundColor(Theme.current.accentColor)
                                    Text(grandTotalRaisedDescription)
                                        .textSelection(.enabled)
                                        .fullWidth()
                                        .font(.title)
                                        .bold()
                                }
                            }
                            .themedGroupBox(type: .primary, id: teamEvent.id)
                        }
                        
                        self.debugIdView
                        
                        // Milestone and Reward buttons
                        LazyVGrid(columns: milestoneAndRewardButtonColumns) {
                            Button(action: {
                                withAnimation {
                                    scrollViewReader.scrollTo("Milestones", anchor: .top)
                                }
                            }) {
                                HStack {
                                    Text("^[\(milestones.count) Milestone](inflect:true)")
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(milestones.isEmpty ? .secondary : .primary)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    Spacer()
                                }
                                .frame(minHeight: 0, maxHeight: .infinity)
                            }
                            .themedButton(type: .secondary, id: "milestones-\(localId)")
                            .disabled(milestones.isEmpty)
                            Button(action: {
                                withAnimation {
                                    scrollViewReader.scrollTo("Rewards", anchor: .top)
                                }
                            }) {
                                HStack {
                                    Text("^[\(rewards.count) Reward](inflect:true)")
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(rewards.isEmpty ? .secondary : .primary)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    Spacer()
                                }
                                .frame(minHeight: 0, maxHeight: .infinity)
                            }
                            .themedButton(type: .secondary, id: "rewards-\(localId)")
                            .disabled(rewards.isEmpty)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        
                        // TODO: Add back easter eggs here
                        // easterEggDirectory[initialCampaign?.id ?? teamEvent?.id ?? UUID()]
                        Link(destination: donateURL, label: {
                            Text("Donate Now!")
                                .font(.headline)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        })
                        .themedButton(type: .primary, id: "donate-now-\(localId)")
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    var descriptionView: some View {
        GroupBox {
            Text(description)
                .font(.caption)
                .multilineTextAlignment(.leading)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .themedGroupBox(type: .primary, id: "description-\(localId)")
        .padding(.vertical)
    }
    
    @ViewBuilder
    var donorsView: some View {
        if let topDonor = topDonor {
            GroupBox {
                VStack(spacing: 5) {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                        if donations.count == 1 {
                            Text("Top and only Donor")
                                .textCase(.uppercase)
                        } else {
                            Text("Top Donor")
                                .textCase(.uppercase)
                        }
                        Spacer()
                    }
                    .font(.caption)
                    .foregroundColor(Theme.current.accentColor)
                    HStack(alignment: .top) {
                        Text(topDonor.name)
                            .multilineTextAlignment(.leading)
                            .font(.headline)
                        Spacer()
                        Text(topDonor.amount.description(showFullCurrencySymbol: false))
                    }
                }
            }
            .themedGroupBox(type: .primary, id: "donor-group-\(localId)")
        }
        
        Group {
            if donations.count > 1 {
                NavigationLink(destination: DonorList(campaignId: initialCampaign?.id ?? TEAM_EVENT_ID, campaignLink: fundraiserURL, donations: $donations, topDonor: $topDonor)) {
                    VStack {
                        HStack {
                            Text("Recent Donations")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .themedButton(type: .secondary, textColor: .primary, id: "donations-\(localId)")
            }
        }
        .padding(.bottom)
    }
    
    @ViewBuilder
    var milestonesView: some View {
        if !milestones.isEmpty {
            GroupBox {
                VStack {
                    HStack {
                        Text("Milestones")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("\(milestones.count)")
                            .foregroundColor(.secondary)
                    }
                    ForEach(milestones, id: \.id) { milestone in
                        MilestoneListView(milestone: milestone, reached: milestoneReached(for: milestone), percentage: milestonePercentage(for: milestone))
                    }
                }
            }
            .themedGroupBox(type: .primary, id: "milestones-group")
            .id("Milestones")
        }
    }
    
    @ViewBuilder
    var pollsView: some View {
        if !self.activePolls.isEmpty {
            GroupBox {
                VStack(alignment: .leading) {
                    Button(action: {
                        withAnimation {
                            self.showPolls.toggle()
                        }
                    }, label: {
                        HStack {
                            Text("Polls")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(self.activePolls.count)")
                                .foregroundStyle(.secondary)
                            
                            Image(systemName:"chevron.right")
                                .foregroundStyle(.secondary)
                                .rotationEffect(.degrees(self.showPolls ? 90 : 0))
                        }
                        .contentShape(Rectangle())
                    })
                    .themedButton(type: .plain, id: "polls")
                    
                    if self.showPolls {
                        ForEach(self.activePolls, id: \.id) { poll in
                            PollView(poll: poll, campaignId: initialCampaign?.id ?? RELAY_CAMPAIGN)
                        }
                    }
                }
            }
            .themedGroupBox(type: .primary, id: "polls-group")
        }
    }
    
    @ViewBuilder
    var rewardsView: some View {
        if !rewards.isEmpty {
            GroupBox {
                VStack(spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Rewards")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(rewards.count)")
                            .foregroundColor(.secondary)
                        
                    }
                    ForEach(rewards, id: \.id) { reward in
                        CampaignRewardView(reward: reward, campaignUserName: self.initialCampaign?.user.username ?? "", showSupporterSheet: self.$showSupporterSheet)
                    }
                }
            }
            .themedGroupBox(type: .primary, id: "rewards-group")
            .id("Rewards")
        }
    }
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollViewReader in
                VStack(spacing: 0) {
                    HStack {
                        VStack {
                            // LogsView(logContainer: logsContainer)
                            self.infoView(scrollViewReader: scrollViewReader)
                        }
                        .frame(maxWidth: Double.stretchedContentMaxWidth)
                        .padding(.bottom)
                    }
                    .padding(.horizontal)
                    .background {
                        Theme.current.skyView(forMainScreen: false)
                    }
                    
                    HStack {
                        VStack {
                            self.descriptionView
                            
                            self.donorsView
                            
                            self.pollsView
                            
                            self.milestonesView
                            
                            self.rewardsView
                        }
                        .frame(maxWidth: Double.stretchedContentMaxWidth)
                    }
                    .padding()
                    .background {
                        VStack(spacing: 0) {
                            Theme.current.landscapeToBackgroundTransition
                            Theme.current.backgroundView
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showShareView) {
            if let campaign = initialCampaign {
                ShareCampaignView(campaign: campaign)
                    .forSheet()
            } else if let teamEvent = teamEvent {
                ShareCampaignView(teamEvent: teamEvent)
                    .forSheet()
            }
        }
        .sheet(isPresented: $showSupporterSheet) {
            SupportersView()
                .forSheet(displayMode: .large)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        await starOrUnstar()
                    }
                }) {
                    Label(title: {
                        Text("Starred")
                    }, icon: {
                        Image(systemName: self.initialCampaign?.isStarred ?? false ? "star.fill" : "star")
                    })
                }
                .opacity(initialCampaign != nil ? 1 : 0)
                .disabled(teamEvent != nil)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        refreshId = .init()
                    }
                }) {
                    ZStack {
                        if isRefreshing {
                            ProgressView()
                        }
                        Image(systemName: "arrow.clockwise")
                            .opacity(isRefreshing ? 0 : 1)
                    }
                }
                .keyboardShortcut("r")
                .disabled(isRefreshing)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        
        // Anything from this point on scares me. Sorry Ben
        .refreshable {
            refreshId = .init()
        }
        .onReceive(timer) { _ in
            refreshId = .init()
        }
        .task {
            logsContainer.addLog("View opened")
            
            // Campaign change watch
            if let campaignObservation = campaignObservation {
                campaignCancellable = AppDatabase.shared.start(observation: campaignObservation) { error in
                    dataLogger.error("Error observing stored campaign: \(error.localizedDescription)")
                    logsContainer.addLog("Error observing stored campaign: \(error.localizedDescription)")
                } onChange: { event in
                    fetchTask?.cancel()
                    fetchTask = Task {
                        logsContainer.addLog("Calling fetch from campaignObservation onChange")
                        await fetch()
                    }
                }
            } else if let teamEventObservation = teamEventObservation {
                campaignCancellable = AppDatabase.shared.start(observation: teamEventObservation) { error in
                    dataLogger.error("Error observing stored team event: \(error.localizedDescription)")
                    logsContainer.addLog("Error observing stored team event: \(error.localizedDescription)")
                } onChange: { event in
                    fetchTask?.cancel()
                    fetchTask = Task {
                        logsContainer.addLog("Calling fetch from teamEventObservation onChange")
                        await fetch()
                    }
                }
            }
            
        }
        .task(id: refreshId, {
            // New API fetch
            if !hasDoneInitialAPIFetch {
                logsContainer.addLog("Doing initial API fetch")
            }
            await refresh()
        })
        
    }
    
    var navigationTitle: String {
        if let initialCampaign = initialCampaign {
            return initialCampaign.name
        }
        if let teamEvent = teamEvent {
            return teamEvent.name
        }
        return "Campaign"
    }
    
    // MARK: - Data
    
    func starOrUnstar() async {
        if let initialCampaign = initialCampaign {
            let newCampaign = initialCampaign.setStar(to: !initialCampaign.isStarred)
            do {
                if try await AppDatabase.shared.updateCampaign(newCampaign, changesFrom: initialCampaign) {
                    dataLogger.info("Updated starring stored campaign: \(newCampaign.id)")
                }
            } catch {
                dataLogger.error("Starring/unstarring stored campaign failed: \(error.localizedDescription)")
            }
            self.initialCampaign = newCampaign
        }
    }
    
    /// Fetch data from the API, save it to the database
    func refresh() async {
        
        guard !isRefreshing else {
            dataLogger.notice("Skipping refresh as one is already in-progress")
            logsContainer.addLog("Skipping refresh as one is already in-progress")
            return
        }
        isRefreshing = true
        defer {
            isRefreshing = false
        }
        
        if let existingTeamEvent = teamEvent {
            
            logsContainer.addLog("Doing API fetch for Team Event")
            
            if let apiEventData = await TiltifyAPIClient.shared.getFundraisingEvent() {
                dataLogger.debug("[CampaignView] API fetched TeamEvent: \(apiEventData.name)")
                logsContainer.addLog("API fetched TeamEvent: \(apiEventData.totalAmountRaised.numericalValue)")
                let apiEvent = TeamEvent(from: apiEventData)
                do {
                    self.teamEvent = apiEvent
                    logsContainer.addLog("Updating stored team event from \(existingTeamEvent.totalRaisedNumerical) (\(existingTeamEvent.id)) to \(apiEvent.totalRaisedNumerical) (\(apiEvent.id))")
                    if try await AppDatabase.shared.updateTeamEvent(apiEvent, changesFrom: existingTeamEvent) {
                        dataLogger.info("[CampaignView] Updated team event \(apiEvent.name) (id: \(apiEvent.id)")
                        logsContainer.addLog("Updated team event in database, now: \(self.teamEvent?.totalRaisedNumerical ?? 99999)")
                    }
                } catch {
                    dataLogger.error("[CampaignView] Updating stored team event failed: \(error.localizedDescription)")
                    logsContainer.addLog("Updating stored team event failed: \(error.localizedDescription)")
                }
                
                await self.updateMilestonesInDatabase(forId: TEAM_EVENT_ID)
                await self.updateRewardsInDatabase(forId: TEAM_EVENT_ID)
                
                async let apiTopDonorFetch = TiltifyAPIClient.shared.getCampaignTopDonor(forId: TEAM_EVENT_ID)
                async let apiDonationsFetch = TiltifyAPIClient.shared.getCampaignDonations(forId: TEAM_EVENT_ID)
                async let apiPollsFetch = TiltifyAPIClient.shared.getCampaignPolls(forId: TEAM_EVENT_ID)
                
                let apiTopDonor = await apiTopDonorFetch
                let apiDonations = await apiDonationsFetch
                withAnimation {
                    topDonor = apiTopDonor
                    donations = apiDonations
                }
                
                let apiPolls = await apiPollsFetch
                if let apiPolls = apiPolls {
                    withAnimation {
                        self.polls = apiPolls
                    }
                }
                
            } else {
                dataLogger.debug("[CampaignView] Could not get team event from API")
                logsContainer.addLog("Could not get team event from API")
            }
            
            self.hasDoneInitialAPIFetch = true

            logsContainer.addLog("Calling fetch from database")
            await fetch()
            
        } else if let initialCampaign = initialCampaign {
            
            dataLogger.info("Campaign UUID: \(initialCampaign.id.uuidString)")
            logsContainer.addLog("Doing API fetch for Campaign \(initialCampaign.id)")
            
            await updateCampaignFromAPI(for: initialCampaign, updateLocalCampaignState: true)
            
            self.hasDoneInitialAPIFetch = true
            
            logsContainer.addLog("Calling fetch from database")
            await fetch()
            
        }
        
    }
    
    func updateMilestonesInDatabase(forId id: UUID) async {
        let apiMilestones: [TiltifyMilestone]
        if id == UUID(uuidString: FUNDRAISING_EVENT_PUBLIC_ID) {
            apiMilestones = await TiltifyAPIClient.shared.getFundraisingEventMilestones()
        } else {
            apiMilestones = await TiltifyAPIClient.shared.getCampaignMilestones(forId: id)
        }
        dataLogger.debug("Updating Milestones for campaign \(id) with \(milestones.count)")
        
        var keyedApiMilestones: [UUID: Milestone] = apiMilestones.filter { $0.active }.reduce(into: [:]) { partialResult, ms in
            let milestone: Milestone
            if teamEvent != nil {
                milestone = Milestone(from: ms, campaignId: nil, teamEventId: UUID(uuidString: FUNDRAISING_EVENT_PUBLIC_ID)!)
            } else {
                milestone = Milestone(from: ms, campaignId: id, teamEventId: nil)
            }
            partialResult.updateValue(milestone, forKey: ms.publicId)
        }
        
        do {
            let dbMilestones: [Milestone]
            if let teamEvent {
                dbMilestones = try await AppDatabase.shared.fetchSortedMilestones(for: teamEvent)
            } else {
                if let campaign = initialCampaign {
                    dbMilestones = try await AppDatabase.shared.fetchSortedMilestones(for: campaign)
                } else {
                    dbMilestones = []
                }
            }
            // For each milestone from the database...
            for dbMilestone in dbMilestones {
                if let apiMilestone = keyedApiMilestones[dbMilestone.id] {
                    // Update it from the API if it exists...
                    keyedApiMilestones.removeValue(forKey: dbMilestone.id)
                    dataLogger.debug("Updating Milestone \(apiMilestone.name)")
                    do {
                        try await AppDatabase.shared.updateMilestone(apiMilestone, changesFrom: dbMilestone)
                    } catch {
                        dataLogger.error("Failed to update Milestone: \(apiMilestone.name): \(error.localizedDescription)")
                    }
                } else {
                    // Remove it from the database if it doesn't...
                    dataLogger.debug("Removing Milestone \(dbMilestone.name)")
                    do {
                        try await AppDatabase.shared.deleteMilestone(dbMilestone)
                    } catch {
                        dataLogger.error("Failed to delete Milestone \(dbMilestone.name): \(error.localizedDescription)")
                    }
                }
            }
            // For each new milestone in the API, save it to the database
            for apiMilestone in keyedApiMilestones.values {
                dataLogger.debug("Creating Milestone: \(apiMilestone.name)")
                do {
                    try await AppDatabase.shared.saveMilestone(apiMilestone)
                } catch {
                    dataLogger.error("Failed to save Milestone \(apiMilestone.name): \(error.localizedDescription)")
                }
            }
        } catch {
            dataLogger.debug("Failed to update Milestones: \(error.localizedDescription)")
        }
        
    }
    
    func updateRewardsInDatabase(forId id: UUID) async {
        
        // TODO: Filter out rewards that are on all campaigns
        
        let apiRewards = await TiltifyAPIClient.shared.getCampaignRewards(forId: id)
        dataLogger.debug("Updating Rewards for campaign \(id) with \(rewards.count)")
        
        var keyedApiRewards: [UUID: Reward] = apiRewards.filter { $0.active }.reduce(into: [:]) { partialResult, reward in
            let rewardObj: Reward
            if teamEvent != nil {
                rewardObj = Reward(from: reward, campaignId: nil, teamEventId: UUID(uuidString: FUNDRAISING_EVENT_PUBLIC_ID)!)
            } else {
                rewardObj = Reward(from: reward, campaignId: id, teamEventId: nil)
            }
            partialResult.updateValue(rewardObj, forKey: reward.publicId)
        }
        
        do {
            let dbRewards: [Reward]
            if let teamEvent {
                dbRewards = try await AppDatabase.shared.fetchSortedRewards(for: teamEvent)
            } else {
                if let campaign = initialCampaign {
                    dbRewards = try await AppDatabase.shared.fetchSortedRewards(for: campaign)
                } else {
                    dbRewards = []
                }
            }
            // For each reward from the database...
            for dbReward in dbRewards {
                if let apiReward = keyedApiRewards[dbReward.id] {
                    // Update it from the API if it exists...
                    keyedApiRewards.removeValue(forKey: dbReward.id)
                    dataLogger.debug("Updating Reward \(apiReward.name)")
                    do {
                        try await AppDatabase.shared.updateReward(apiReward, changesFrom: dbReward)
                    } catch {
                        dataLogger.error("Failed to update Reward: \(apiReward.name): \(error.localizedDescription)")
                    }
                } else {
                    // Remove it from the database if it doesn't...
                    dataLogger.debug("Removing Reward \(dbReward.name)")
                    do {
                        try await AppDatabase.shared.deleteReward(dbReward)
                    } catch {
                        dataLogger.error("Failed to delete Reward \(dbReward.name): \(error.localizedDescription)")
                    }
                }
            }
            // For each new reward in the API, save it to the database
            for apiReward in keyedApiRewards.values {
                dataLogger.debug("Creating Reward: \(apiReward.name)")
                do {
                    try await AppDatabase.shared.saveReward(apiReward)
                } catch {
                    dataLogger.error("Failed to save Reward \(apiReward.name): \(error.localizedDescription)")
                }
            }
        } catch {
            dataLogger.debug("Failed to update Rewards: \(error.localizedDescription)")
        }
        
    }
    
    func updateCampaignFromAPI(for campaign: Campaign, updateLocalCampaignState: Bool = false) async {
        
        logsContainer.addLog("Updating campaign from API: \(campaign.id)")
        
        guard let response = await TiltifyAPIClient.shared.getCampaign(withId: campaign.id) else {
            logsContainer.addLog("Could not get campaign from API")
            return
        }
        
        dataLogger.debug("\(campaign.id) Fetched campaign from the API: \(response.name)")
        logsContainer.addLog("Fetched campaign from the API: \(response.totalAmountRaised.numericalValue)")
        
        let apiCampaign = campaign.updated(from: response)
        do {
            logsContainer.addLog("Updating stored campaign from \(campaign.totalRaisedNumerical) to \(apiCampaign.totalRaisedNumerical)")
            if try await AppDatabase.shared.updateCampaign(apiCampaign, changesFrom: campaign) {
                dataLogger.info("\(campaign.id) Updated stored campaign: \(apiCampaign.id)")
                logsContainer.addLog("Updated stored campaign in database, now: \(apiCampaign.totalRaisedNumerical)")
                if updateLocalCampaignState {
                    self.initialCampaign = apiCampaign
                }
            }
        } catch {
            logsContainer.addLog("Updating stored campaign failed: \(error.localizedDescription)")
            dataLogger.error("\(campaign.id) Updating stored campaign failed: \(error.localizedDescription)")
        }
        
        logsContainer.addLog("Updating milestones and rewards")
        
        await updateMilestonesInDatabase(forId: campaign.id)
        await updateRewardsInDatabase(forId: campaign.id)
        
        logsContainer.addLog("Done updating milestones and rewards")
        logsContainer.addLog("Updating donors and polls")
        
        let apiTopDonor = await TiltifyAPIClient.shared.getCampaignTopDonor(forId: campaign.id)
        let apiDonations = await TiltifyAPIClient.shared.getCampaignDonations(forId: campaign.id)
        withAnimation {
            topDonor = apiTopDonor
            donations = apiDonations
        }
        
        let apiPolls = await TiltifyAPIClient.shared.getCampaignPolls(forId: campaign.id)
        if let apiPolls = apiPolls {
            withAnimation {
                self.polls = apiPolls
            }
        }
        
        logsContainer.addLog("Done updating donors and polls")
        
    }
    
    /// Fetches the campaign data from GRDB
    func fetch() async {
        if let teamEvent = teamEvent {
            logsContainer.addLog("Fetching data for Team Event from database: done initial API fetch? \(hasDoneInitialAPIFetch)")
            if hasDoneInitialAPIFetch {
                do {
                    dataLogger.notice("Fetching stored team event")
                    logsContainer.addLog("Fetching stored team event")
                    self.teamEvent = try await AppDatabase.shared.fetchTeamEvent()
                    dataLogger.notice("Fetched stored team event")
                    logsContainer.addLog("Fetched stored team event: \(self.teamEvent?.totalRaisedNumerical ?? 99999)")
                } catch {
                    dataLogger.error("Failed to fetch stored team event: \(error.localizedDescription)")
                    logsContainer.addLog("Failed to fetch stored team event: \(error.localizedDescription)")
                }
            }
            logsContainer.addLog("Fetching rewards and milestones for team event")
            await fetchRewardsAndMilestones(for: teamEvent)
            logsContainer.addLog("Rewards and milestones fetched")
        } else if let initialCampaign = initialCampaign {
            logsContainer.addLog("Fetching data for Campaign from database: done initial API fetch? \(hasDoneInitialAPIFetch)")
            if hasDoneInitialAPIFetch {
                do {
                    dataLogger.notice("Fetching stored campaign: \(initialCampaign.id)")
                    logsContainer.addLog("Fetching stored campaign")
                    self.initialCampaign = try await AppDatabase.shared.fetchCampaign(with: initialCampaign.id)
                    dataLogger.notice("Fetched stored campaign: \(initialCampaign.id)")
                    logsContainer.addLog("Fetched stored campaign: \(self.initialCampaign?.totalRaisedNumerical ?? 99999)")
                } catch {
                    dataLogger.error("Failed to fetch stored campaign \(initialCampaign.id): \(error.localizedDescription)")
                    logsContainer.addLog("Failed to fetch stored campaign: \(error.localizedDescription)")
                }
            }
            logsContainer.addLog("Fetching rewards and milestones for campaign")
            await fetchRewardsAndMilestones(for: initialCampaign)
            logsContainer.addLog("Rewards and milestones fetched")
        }
    }
    
    func fetchRewardsAndMilestones(for teamEvent: TeamEvent) async {
        do {
            dataLogger.notice("Fetching stored milestones for team event")
            let fetchedMilestones = try await AppDatabase.shared.fetchSortedMilestones(for: teamEvent)
            withAnimation {
                self.milestones = fetchedMilestones
            }
            dataLogger.notice("Fetched stored milestones for team event")
        } catch {
            dataLogger.error("Failed to fetch stored milestones for team event: \(error.localizedDescription)")
        }
        do {
            dataLogger.notice("Fetching stored rewards for team event")
            let fetchedRewards = try await AppDatabase.shared.fetchSortedRewards(for: teamEvent)
            withAnimation {
                self.rewards = fetchedRewards
            }
            dataLogger.notice("Fetched stored rewards for team event")
        } catch {
            dataLogger.error("Failed to fetch stored rewards for team event: \(error.localizedDescription)")
        }
    }
    
    func fetchRewardsAndMilestones(for campaign: Campaign) async {
        
        do {
            dataLogger.notice("Fetching stored milestones for \(campaign.id)")
            let fetchedMilestones = try await AppDatabase.shared.fetchSortedMilestones(for: campaign)
            withAnimation {
                self.milestones = fetchedMilestones
            }
            dataLogger.notice("Fetched stored milestones for \(campaign.id)")
        } catch {
            dataLogger.error("Failed to fetch stored milestones for \(campaign.id): \(error.localizedDescription)")
        }
        do {
            dataLogger.notice("Fetching stored rewards for \(campaign.id)")
            let fetchedRewards = try await AppDatabase.shared.fetchSortedRewards(for: campaign)
            withAnimation {
                self.rewards = fetchedRewards
            }
            dataLogger.notice("Fetched stored rewards for \(campaign.id)")
        } catch {
            dataLogger.error("Failed to fetch stored rewards for \(campaign.id): \(error.localizedDescription)")
        }
        
    }
    
}

struct CampaignView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        NavigationView {
            CampaignView(initialCampaign: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "Aaron's Campaign for St Jude", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "294.00"), user: TiltifyUser(username: "agmcleod", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil), description: "I'm fundraising for St. Jude Children's Research Hospital.")), namespace: Self.namespace)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Label("Back", systemImage: "chevron.left")
                    }
                }
        }
    }
}
