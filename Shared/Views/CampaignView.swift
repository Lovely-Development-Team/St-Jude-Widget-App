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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    // MARK: 2024
    @State private var landscapeData = RandomLandscapeData(isForMainScreen: false)
    
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
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    init(initialCampaign: Campaign) {
        _initialCampaign = State(wrappedValue: initialCampaign)
        _teamEvent = State(wrappedValue: nil)
        _campaignObservation = State(wrappedValue: AppDatabase.shared.observeCampaignObservation(for: initialCampaign))
    }
    
    init(teamEvent: TeamEvent) {
        _initialCampaign = State(wrappedValue: initialCampaign)
        _teamEvent = State(wrappedValue: teamEvent)
        _teamEventObservation = State(wrappedValue: AppDatabase.shared.observeTeamEventObservation())
    }
    
    var fundraiserURL: URL {
        if let initialCampaign = initialCampaign {
            return URL(string: "https://tiltify.com/@\(initialCampaign.user.slug)/\(initialCampaign.slug)")!
        } else {
            return URL(string: "https://stjude.org/relay")!
        }
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
    func topView(scrollViewReader: SwiftUI.ScrollViewProxy) -> some View {
        Group {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Group {
                        VStack {
                            if let initialCampaign = initialCampaign {
                                FundraiserListItem(campaign: initialCampaign, sortOrder: .byGoal, showDisclosureIndicator: false, showShareIcon: true, showShareSheet: $showShareView)
                            } else if let teamEvent = teamEvent {
                                TeamEventCardView(teamEvent: teamEvent, showDisclosureIndicator: false, showShareIcon: true, showShareSheet: $showShareView)
                                //                    Text("Annual Fundraising Totals")
                                //                        .fullWidth()
                                //                        .font(.headline)
                                //                        .padding(.top)
                                //                    StJudeTotals(currentTotal: teamEvent.totalRaisedNumerical)
                                //                        .frame(height: 150)
                                //                        .padding(.bottom)
                                GroupBox {
                                    VStack {
                                        HStack(spacing: 4) {
//                                            if grandTotalRaised >= 2500000 {
//                                                Image(.partyPopperFillPixel)
//                                            }
                                            Text("Lifetime Total")
                                                .textCase(.uppercase)
                                            Spacer()
                                        }
                                        .font(.caption)
                                        .foregroundColor(.accentColor)
                                        Text(grandTotalRaisedDescription)
                                            .textSelection(.enabled)
                                            .fullWidth()
                                            .font(.title)
                                            .bold()
                                    }
                                }
                                .groupBoxStyle(BlockGroupBoxStyle())
                                //                            .padding(.vertical, 8)
                            }

#if DEBUG
                            if let initialCampaign = initialCampaign {
                                GroupBox {
                                    Text("\(initialCampaign.id)")
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
                                .groupBoxStyle(BlockGroupBoxStyle())
                            }
#endif

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
                                .buttonStyle(BlockButtonStyle(disabled: milestones.isEmpty))
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
                                .buttonStyle(BlockButtonStyle(disabled: rewards.isEmpty))
                                .disabled(rewards.isEmpty)
                            }
                                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            
                            ZStack {
                                if let egg = easterEggDirectory[initialCampaign?.id ?? teamEvent?.id ?? UUID()] {
                                    if let left = egg.left {
                                        HStack {
                                            left
                                            Spacer()
                                        }
                                    }
                                    if let right = egg.right {
                                        HStack {
                                            Spacer()
                                            right
                                        }
                                    }
                                }

                                Link(destination: fundraiserURL, label: {
                                    Text("Visit the \(teamEvent == nil ? "fundraiser" : "event")!")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                })
                                .buttonStyle(BlockButtonStyle(tint: .accentColor))
                                //                .padding(10)
                                //                .padding(.horizontal, 20)
                                //                .background(Color.accentColor)
                                //                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                //                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                //                .padding(.top)

                            }
                        }
                    }
                    .padding()

//                    RandomLandscapeView(data: self.$landscapeData) {}
                }
                .frame(maxWidth: Double.stretchedContentMaxWidth)
                
//                AdaptiveImage.groundRepeatable(colorScheme: self.colorScheme)
//                    .tiledImageAtScale(axis: .horizontal)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .background{
            SkyView2025(fadeOut: true)
        }
    }
    
    @ViewBuilder
    func contents(scrollViewReader: SwiftUI.ScrollViewProxy) -> some View {
        Group {
            VStack {
                GroupBox {
                    Text(description)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .groupBoxStyle(BlockGroupBoxStyle())

                if let topDonor = topDonor {
                    GroupBox {
                        VStack(spacing: 5) {
                            HStack(spacing: 4) {
                                Image(.crownPixel)
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
                            .foregroundColor(.accentColor)
                            HStack(alignment: .top) {
                                Text(topDonor.name)
                                    .multilineTextAlignment(.leading)
                                    .font(.headline)
                                Spacer()
                                Text(topDonor.amount.description(showFullCurrencySymbol: false))
                            }
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle())
                }

                if donations.count > 1, let campaign = initialCampaign ?? relayCampaign {
                    NavigationLink(destination: DonorList(campaign: campaign, donations: $donations, topDonor: $topDonor)) {
                        VStack {
                            HStack {
                                Text("Recent Donations")
                                Spacer()
                                Image("pixel-chevron-right")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(BlockButtonStyle())
                }

                if !milestones.isEmpty {
                                        
                    GroupBox {
                        VStack(spacing: 10) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("Milestones")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                                Spacer()

                                Text("\(milestones.count)")
                                    .foregroundColor(.secondary)

                            }
                            ForEach(milestones, id: \.id) { milestone in
                                MilestoneListView(milestone: milestone, reached: milestoneReached(for: milestone), percentage: milestonePercentage(for: milestone))
                            }
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle())
                    .id("Milestones")
                }

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
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top) {
                                        Text(reward.name)
                                            .font(.headline)
                                        Spacer()
                                        Text(reward.amount.description(showFullCurrencySymbol: false))
                                            .foregroundColor(.accentColor)
                                    }
                                    HStack(alignment: .top) {
                                        if let url = URL(string: reward.imageSrc ?? "") {
                                            KFImage.url(url)
                                                .resizable()
                                                .placeholder {
                                                    ProgressView()
                                                        .frame(width: 45, height: 45)
                                                }.aspectRatio(contentMode: .fit)
                                                .frame(width: 45, height: 45)
                                                .modifier(PixelRounding())
                                        }
                                        VStack {
                                            Text(reward.description)
                                                .font(.caption)
                                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)


                                            if initialCampaign?.user.username == "TheLovelyDevelopers" && reward.name.contains("App Supporter") {
                                                HStack {
                                                    Button(action: {
                                                        showSupporterSheet = true
                                                    }, label: {
                                                        Text("Supporters")
                                                            .font(.headline)
                                                            .foregroundColor(.white)
                                                    })
                                                    .buttonStyle(BlockButtonStyle(tint: .accentColor))
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }

                                }
                                if reward != rewards.last {
                                    Rectangle()
                                        .frame(height: 10 * Double.spriteScale)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle())
                    .id("Rewards")
                }
            }
            .padding(.vertical)
            .padding(.horizontal)
            .frame(maxWidth: Double.stretchedContentMaxWidth)
        }
        .frame(maxWidth: .infinity)
        .background(alignment: .top) {
            TiledArenaFloorView()
        }
    }
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollViewReader in
                VStack(spacing:0) {
                    self.topView(scrollViewReader: scrollViewReader)
                    self.contents(scrollViewReader:scrollViewReader)
                        .background {
                            GeometryReader { geometry in
                                Color.arenaFloor
                                    .frame(height:geometry.size.height + 1000)
                                    .animation(.none, value: UUID())
                            }
                        }
                }
            }
        }
        .refreshable {
            await refresh()
        }
        .onReceive(timer) { _ in
            Task {
                await refresh()
            }
        }
        .onAppear {
            
            // Campaign change watch
            if let campaignObservation = campaignObservation {
                campaignCancellable = AppDatabase.shared.start(observation: campaignObservation) { error in
                    dataLogger.error("Error observing stored campaign: \(error.localizedDescription)")
                } onChange: { event in
                    fetchTask?.cancel()
                    fetchTask = Task {
                        await fetch()
                    }
                }
            } else if let teamEventObservation = teamEventObservation {
                campaignCancellable = AppDatabase.shared.start(observation: teamEventObservation) { error in
                    dataLogger.error("Error observing stored team event: \(error.localizedDescription)")
                } onChange: { event in
                    fetchTask?.cancel()
                    fetchTask = Task {
                        await fetch()
                    }
                }
            }
            
            // New API fetch
            Task {
                await refresh()
            }
            
        }
        .sheet(isPresented: $showShareView) {
            if let campaign = initialCampaign {
                ShareCampaignView(campaign: campaign)
            } else if let teamEvent = teamEvent {
                ShareCampaignView(teamEvent: teamEvent)
            }
        }
        .sheet(isPresented: $showSupporterSheet) {
            SupporterView()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        await starOrUnstar()
                    }
                }) {
                    Label("Starred", image: initialCampaign?.isStarred ?? false ? "heart.fill.pixel" : "heart.pixel")
                }
                .opacity(initialCampaign != nil ? 1 : 0)
                .disabled(teamEvent != nil)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isRefreshing = true
                    Task {
                        await refresh()
                        isRefreshing = false
                    }
                }) {
                    ZStack {
                        if isRefreshing {
                            ProgressView()
                        }
                        Image("pixel-refresh")
                            .opacity(isRefreshing ? 0 : 1)
                    }
                }
                .keyboardShortcut("r")
                .disabled(isRefreshing)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        
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
        
        if let existingTeamEvent = teamEvent {
            
            if let apiEventData = await TiltifyAPIClient.shared.getFundraisingEvent() {
                dataLogger.debug("[CampignView] API fetched TeamEvent: \(apiEventData.name)")
                let apiEvent = TeamEvent(from: apiEventData)
                do {
                    teamEvent = apiEvent
                    if try await AppDatabase.shared.updateTeamEvent(apiEvent, changesFrom: existingTeamEvent) {
                        dataLogger.info("[CampignView] Updated team event \(apiEvent.name) (id: \(apiEvent.id)")
                    }
                } catch {
                    dataLogger.error("[CampignView] Updating stored team event failed: \(error.localizedDescription)")
                }
                
                await self.updateMilestonesInDatabase(forId: TEAM_EVENT_ID)
                await self.updateRewardsInDatabase(forId: TEAM_EVENT_ID)
                
                let apiTopDonor = await TiltifyAPIClient.shared.getCampaignTopDonor(forId: TEAM_EVENT_ID)
                let apiDonations = await TiltifyAPIClient.shared.getCampaignDonations(forId: TEAM_EVENT_ID)
                withAnimation {
                    topDonor = apiTopDonor
                    donations = apiDonations
                }
                
            } else {
                dataLogger.debug("[CampignView] Could not update team event")
            }
            
            await fetch()
            
        } else if let initialCampaign = initialCampaign {
            
            dataLogger.info("Campaign UUID: \(initialCampaign.id.uuidString)")
            
            await updateCampaignFromAPI(for: initialCampaign, updateLocalCampaignState: true)
            await fetch()
            
        }
        
    }
    
    func updateMilestonesInDatabase(forId id: UUID) async {
        let apiMilestones = await TiltifyAPIClient.shared.getCampaignMilestones(forId: id)
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
        
        guard let response = await TiltifyAPIClient.shared.getCampaign(withId: campaign.id) else {
            return
        }
        
        dataLogger.debug("\(campaign.id) Fetched campaign from the API: \(response.name)")
        
        let apiCampaign = campaign.updated(from: response)
        do {
            if try await AppDatabase.shared.updateCampaign(apiCampaign, changesFrom: campaign) {
                dataLogger.info("\(campaign.id) Updated stored campaign: \(apiCampaign.id)")
                if updateLocalCampaignState {
                    self.initialCampaign = apiCampaign
                }
            }
        } catch {
            dataLogger.error("\(campaign.id) Updating stored campaign failed: \(error.localizedDescription)")
        }
        
        dataLogger.debug("\(campaign.id) Updating campaign from the API!")
        
        await updateMilestonesInDatabase(forId: campaign.id)
        await updateRewardsInDatabase(forId: campaign.id)
        
        let apiTopDonor = await TiltifyAPIClient.shared.getCampaignTopDonor(forId: campaign.id)
        let apiDonations = await TiltifyAPIClient.shared.getCampaignDonations(forId: campaign.id)
        withAnimation {
            topDonor = apiTopDonor
            donations = apiDonations
        }
        
    }
    
    /// Fetches the campaign data from GRDB
    func fetch() async {
        if let teamEvent = teamEvent {
            do {
                dataLogger.notice("Fetching stored team event")
                self.teamEvent = try await AppDatabase.shared.fetchTeamEvent()
                dataLogger.notice("Fetched stored team event")
            } catch {
                dataLogger.error("Failed to fetch stored team event: \(error.localizedDescription)")
            }
            await fetchRewardsAndMilestones(for: teamEvent)
        } else if let initialCampaign = initialCampaign {
            do {
                dataLogger.notice("Fetching stored campaign: \(initialCampaign.id)")
                self.initialCampaign = try await AppDatabase.shared.fetchCampaign(with: initialCampaign.id)
                dataLogger.notice("Fetched stored campaign: \(initialCampaign.id)")
            } catch {
                dataLogger.error("Failed to fetch stored campaign \(initialCampaign.id): \(error.localizedDescription)")
            }
            await fetchRewardsAndMilestones(for: initialCampaign)
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
    static var previews: some View {
        NavigationView {
            CampaignView(initialCampaign: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "Aaron's Campaign for St Jude", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "294.00"), user: TiltifyUser(username: "agmcleod", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil), description: "I'm fundraising for St. Jude Children's Research Hospital.")))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Label("Back", systemImage: "chevron.left")
                    }
                }
        }
    }
}
