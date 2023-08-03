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
    
    // MARK: 2023
    @State private var teamEvent: TeamEvent?
    @State private var teamEventObservation: ValueObservation<ValueReducers.Fetch<TeamEvent?>>?
    
    // MARK: 2022
    
    @State private var campaignObservation: ValueObservation<ValueReducers.Fetch<Campaign?>>?
    @State private var fundraisingEventObservation: ValueObservation<ValueReducers.Fetch<FundraisingEvent?>>?
    @State private var campaignCancellable: DatabaseCancellable?
    @State private var fetchTask: Task<(), Never>?
    
    @State private var initialCampaign: Campaign?
    @State private var fundraisingEvent: FundraisingEvent?
    @State private var milestones: [Milestone] = []
    @State private var rewards: [Reward] = []
    
    @State private var donations: [TiltifyDonorsForCampaignDonation] = []
    @State private var topDonor: TiltifyDonorsForCampaignDonation? = nil
    
    @State private var showShareView: Bool = false
    @State private var showSupporterSheet: Bool = false
    
    @State private var isRefreshing: Bool = false
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    @StateObject private var apiClient = ApiClient.shared
    
    init(initialCampaign: Campaign) {
        _fundraisingEvent = State(wrappedValue: nil)
        _initialCampaign = State(wrappedValue: initialCampaign)
        _teamEvent = State(wrappedValue: nil)
        _campaignObservation = State(wrappedValue: AppDatabase.shared.observeCampaignObservation(for: initialCampaign))
        _fundraisingEventObservation = State(wrappedValue: nil)
    }
    
    init(fundraisingEvent: FundraisingEvent) {
        _initialCampaign = State(wrappedValue: initialCampaign)
        _fundraisingEvent = State(wrappedValue: fundraisingEvent)
        _teamEvent = State(wrappedValue: nil)
        _campaignObservation = State(wrappedValue: nil)
        _fundraisingEventObservation = State(wrappedValue: AppDatabase.shared.observeRelayFundraisingEventObservation())
    }
    
    init(teamEvent: TeamEvent) {
        _initialCampaign = State(wrappedValue: initialCampaign)
        _fundraisingEvent = State(wrappedValue: fundraisingEvent)
        _teamEvent = State(wrappedValue: teamEvent)
        _campaignObservation = State(wrappedValue: nil)
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
        let descr = fundraisingEvent?.description ?? teamEvent?.description ?? initialCampaign?.description ?? ""
        do {
            return try AttributedString(markdown: descr)
        } catch {
            return AttributedString(descr)
        }
    }
    
    func milestoneReached(for milestone: Milestone) -> Bool {
        if let fundraisingEvent = fundraisingEvent {
            return milestone.amount.value <= fundraisingEvent.amountRaised.numericalValue
        } else if let initialCampaign = initialCampaign {
            return milestone.amount.value <= initialCampaign.totalRaised.numericalValue
        } else if let teamEvent = teamEvent {
            return milestone.amount.value <= teamEvent.totalRaised.numericalValue
        }
        return false
    }
    
    var body: some View {
        ScrollView {
            
            ScrollViewReader { scrollViewReader in
                
                if let fundraisingEvent = fundraisingEvent {
                    FundraiserCardView(fundraisingEvent: fundraisingEvent, showDisclosureIndicator: false, showShareIcon: true, showShareSheet: $showShareView)
                } else if let initialCampaign = initialCampaign {
                    
                    FundraiserListItem(campaign: initialCampaign, sortOrder: .byGoal, showDisclosureIndicator: false, showShareIcon: true, showShareSheet: $showShareView)
                    
                } else if let teamEvent = teamEvent {
                    TeamEventCardView(teamEvent: teamEvent, showDisclosureIndicator: false, showShareIcon: true, showShareSheet: $showShareView)
                }
                
                LazyVGrid(columns: [GridItem(.flexible()),
                                    GridItem(.flexible())]) {
                    Button(action: {
                        withAnimation {
                            scrollViewReader.scrollTo("Milestones", anchor: .top)
                        }
                    }) {
                        GroupBox {
                            HStack {
                                Image(systemName: "flag")
                                Spacer()
                                Text("\(milestones.count) Milestones")
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                Spacer()
                            }
                            .frame(minHeight: 0, maxHeight: .infinity)
                        }
                    }
                    .disabled(milestones.isEmpty)
                    Button(action: {
                        withAnimation {
                            scrollViewReader.scrollTo("Rewards", anchor: .top)
                        }
                    }) {
                        GroupBox {
                            HStack {
                                Image(systemName: "rosette")
                                Spacer()
                                Text("\(rewards.count) Rewards")
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                Spacer()
                            }
                            .frame(minHeight: 0, maxHeight: .infinity)
                        }
                    }
                    .disabled(rewards.isEmpty)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                
                ZStack {
                    
                    if let egg = easterEggDirectory[initialCampaign?.id ?? fundraisingEvent?.id ?? teamEvent?.id ?? UUID()] {
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
                    
                    Link("Visit the \(fundraisingEvent == nil ? "fundraiser" : "event")!", destination: fundraiserURL)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                        .padding(.horizontal, 20)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                    
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                
                Text(description)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical)
                
                if let topDonor = topDonor {
                    GroupBox {
                        VStack(spacing: 5) {
                            HStack(spacing: 4) {
                                Image(systemName: "crown")
                                Text("Top Donor")
                                    .textCase(.uppercase)
                                Spacer()
                            }
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            HStack(alignment: .top) {
                                Text(topDonor.donorName)
                                    .multilineTextAlignment(.leading)
                                    .font(.headline)
                                Spacer()
                                Text(topDonor.amount.description(showFullCurrencySymbol: false))
                            }
                            if let comment = topDonor.donorComment {
                                Text(comment)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                
                if !donations.isEmpty, let campaign = initialCampaign {
                    NavigationLink(destination: DonorList(campaign: campaign, donations: $donations, topDonor: $topDonor)) {
                        GroupBox {
                            HStack {
                                Text("Recent Donations")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            
                        }
                    }
                    .padding(.bottom)
                    
                    if #available(iOS 16.0, *), donations.count >= 4 {
                        DonorChart(donations: donations, total: campaign.totalRaised)
                            .frame(height: 80)
                            .padding(.horizontal)
                            .padding(.bottom)
                        
                    }
                }
                
                if !milestones.isEmpty {
                    
                    HStack {
                        
                        Text("Milestones")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        Text("\(milestones.count)")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Color.secondarySystemBackground
                                    .cornerRadius(15)
                            )
                        
                    }
                    .id("Milestones")
                    
                    if initialCampaign?.user.name == "Relay FM" {
                        GroupBox {
                            HStack(alignment: .top) {
                                Image(systemName: "info.circle")
                                    .padding(.top, 2)
                                Text("These milestones are achieved when the overall fundraiser total reaches the specified amount, not this specific campaign.")
                                    .font(.caption)
                                    .multilineTextAlignment(.leading)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    
                    ForEach(milestones, id: \.id) { milestone in
                        let reached = milestoneReached(for: milestone)
                        HStack(alignment: .top) {
                            if reached {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                            }
                            Text("\(milestone.name)")
                                .foregroundColor(reached ? .secondary : .primary)
                            Spacer()
                            Text(milestone.amount.description(showFullCurrencySymbol: false))
                                .foregroundColor(.accentColor)
                                .opacity(reached ? 0.75 : 1)
                        }
                        .padding(.vertical, 8)
                        Divider()
                    }
                    
                }
                
                if !rewards.isEmpty {
                    
                    HStack {
                        
                        Text("Rewards")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.top, milestones.isEmpty ? 0 : 10)
                        
                        Text("\(rewards.count)")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Color.secondarySystemBackground
                                    .cornerRadius(15)
                            )
                        
                    }
                    .id("Rewards")
                    
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
                                        .cornerRadius(5)
                                }
                                VStack {
                                    Text(reward.description)
                                        .font(.caption)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    
                                    
                                    if initialCampaign?.user.username == "TheLovelyDevelopers" && reward.name.contains("App Supporter") {
                                        Button(action: {
                                            showSupporterSheet = true
                                        }, label: {
                                            Text("Supporters")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding(5)
                                                .padding(.horizontal, 10)
                                                .background(Color.accentColor)
                                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        })
                                    }
                                }
                            }
                            
                        }
                        .padding(.vertical, 8)
                        Divider()
                    }
                    
                }
                
            }
            .padding()
            
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
            if let fundraisingEventObservation = fundraisingEventObservation {
                campaignCancellable = AppDatabase.shared.start(observation: fundraisingEventObservation) { error in
                    dataLogger.error("Error observing stored fundraising event: \(error.localizedDescription)")
                } onChange: { event in
                    fetchTask?.cancel()
                    fetchTask = Task {
                        await fetch()
                    }
                }
            } else if let campaignObservation = campaignObservation {
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
            if let fundraisingEvent = fundraisingEvent {
                ShareCampaignView(fundraisingEvent: fundraisingEvent)
            } else if let campaign = initialCampaign {
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
                    Label("Starred", systemImage: initialCampaign?.isStarred ?? false ? "star.fill" : "star")
                }
                .opacity(initialCampaign != nil ? 1 : 0)
                .disabled(fundraisingEvent != nil || teamEvent != nil)
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
                        Label("Refresh", systemImage: "arrow.clockwise")
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
        if let fundraisingEvent = fundraisingEvent {
            return fundraisingEvent.name
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
        
        if let fundraisingEvent = fundraisingEvent {
            
            let response: TiltifyCauseResponse
            do {
                response = try await apiClient.fetchCause()
            } catch {
                dataLogger.error("Fetching cause failed: \(error.localizedDescription)")
                return
            }
            let apiEvent = FundraisingEvent(from: response.data)
            do {
                // Always saving the new event would work fine, but only the amount raised is likely to change regularly,
                // so it's more efficient to update if we have an existing event
                if try await AppDatabase.shared.updateFundraisingEvent(apiEvent, changesFrom: fundraisingEvent) {
                    dataLogger.info("Updated fundraising event '\(apiEvent.name)' (id: \(apiEvent.id)")
                }
                self.fundraisingEvent = apiEvent
            } catch {
                dataLogger.error("Updating stored fundraiser failed: \(error.localizedDescription)")
            }
            
            dataLogger.info("Campaign UUID: \(fundraisingEvent.id.uuidString)")
            
            var relayCampaign: Campaign? = nil
            
            do {
                dataLogger.notice("Fetching Relay campaign")
                relayCampaign = try await AppDatabase.shared.fetchRelayCampaign()
                dataLogger.notice("Fetched Relay campaign")
            } catch {
                dataLogger.error("Failed to fetch Relay campaign: \(error.localizedDescription)")
            }
            
            if let relayCampaign = relayCampaign {
                await updateCampaignFromAPI(for: relayCampaign)
            }
            
            await fetch()
            
        } else if let existingTeamEvent = teamEvent {
            
            if let apiEventData = await apiClient.fetchTeamEvent() {
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
                
                await self.updateMilestonesInDatabase(forTeamEvent: existingTeamEvent, with: apiEventData.milestones)
                await self.updateRewardsInDatabase(forTeamEvent: existingTeamEvent, with: apiEventData.rewards)
                
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
    
    func updateMilestonesInDatabase(forCampaign campaign: Campaign? = nil, forTeamEvent teamEvent: TeamEvent? = nil, with apiMilestones: [TiltifyMilestone]) async {
        
        var keyedApiMilestones: [UUID: Milestone] = apiMilestones.reduce(into: [:]) { partialResult, ms in
            partialResult.updateValue(Milestone(from: ms, campaignId: campaign?.id, teamEventId: teamEvent?.id), forKey: ms.publicId)
        }
        
        do {
            let dbMilestones: [Milestone]
            if let teamEvent = teamEvent {
                dbMilestones = try await AppDatabase.shared.fetchSortedMilestones(for: teamEvent)
            } else {
                if let campaign = campaign {
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
    
    func updateRewardsInDatabase(forCampaign campaign: Campaign? = nil, forTeamEvent teamEvent: TeamEvent? = nil, with apiRewards: [TiltifyCampaignReward]) async {
        
        var keyedApiRewards: [UUID: Reward] = apiRewards.reduce(into: [:]) { partialResult, reward in
            partialResult.updateValue(Reward(from: reward, campaignId: campaign?.id, teamEventId: teamEvent?.id), forKey: reward.publicId)
        }
        
        do {
            let dbRewards: [Reward]
            if let teamEvent = teamEvent {
                dbRewards = try await AppDatabase.shared.fetchSortedRewards(for: teamEvent)
            } else {
                if let campaign = campaign {
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
        
        let response: TiltifyResponse
        do {
            response = try await apiClient.fetchCampaign(vanity: campaign.user.slug, slug: campaign.slug)
        } catch {
            dataLogger.error("\(campaign.id) Fetching campaign failed: \(error.localizedDescription)")
            return
        }
        
        let apiCampaign = campaign.updated(fromCampaign: response.data.campaign)
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
        
        await updateMilestonesInDatabase(forCampaign: apiCampaign, with: response.data.campaign.milestones)
        await updateRewardsInDatabase(forCampaign: apiCampaign, with: response.data.campaign.rewards)

        do {
            dataLogger.debug("Fetching donors for \(campaign.id)")
            let apiDonorsResponse = try await apiClient.fetchDonorsForCampaign(publicId: campaign.id.uuidString)
            withAnimation {
                donations = apiDonorsResponse.data.campaign.donations.edges.map { $0.node }
                topDonor = apiDonorsResponse.data.campaign.topDonation
            }
        } catch {
            dataLogger.error("Failed to load donors: \(error.localizedDescription)")
        }

    }
    
    /// Fetches the campaign data from GRDB
    func fetch() async {
        
        if fundraisingEvent != nil {
            
            do {
                dataLogger.notice("Fetching stored fundraising event")
                self.fundraisingEvent = try await AppDatabase.shared.fetchRelayFundraisingEvent()
                dataLogger.notice("Fetched stored fundraising event")
            } catch {
                dataLogger.error("Failed to fetch stored fundraising event: \(error.localizedDescription)")
            }
            
            var relayCampaign: Campaign? = nil
            
            do {
                dataLogger.notice("Fetching Relay campaign")
                relayCampaign = try await AppDatabase.shared.fetchRelayCampaign()
                dataLogger.notice("Fetched Relay campaign")
            } catch {
                dataLogger.error("Failed to fetch Relay campaign: \(error.localizedDescription)")
            }
            
            if let relayCampaign = relayCampaign {
                await fetchRewardsAndMilestones(for: relayCampaign)
            }
            
        } else if let teamEvent = teamEvent {
            
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
