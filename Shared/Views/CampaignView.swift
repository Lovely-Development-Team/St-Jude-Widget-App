//
//  CampaignView.swift
//  St Jude
//
//  Created by Ben Cardy on 25/08/2022.
//

import SwiftUI
import GRDB

struct CampaignView: View {
    
    @State private var campaignObservation: ValueObservation<ValueReducers.Fetch<Campaign?>>
    @State private var campaignCancellable: DatabaseCancellable?
    @State private var fetchTask: Task<(), Never>?
    
    @State private var initialCampaign: Campaign?
    @State private var milestones: [Milestone] = []
    @State private var rewards: [Reward] = []
    
    @StateObject private var apiClient = ApiClient.shared
    
    init(initialCampaign: Campaign) {
        _initialCampaign = State(wrappedValue: initialCampaign)
        _campaignObservation = State(wrappedValue: AppDatabase.shared.observeCampaignObservation(for: initialCampaign))
    }
    
    var fundraiserURL: URL {
        if let initialCampaign = initialCampaign {
            return URL(string: "https://tiltify.com/@\(initialCampaign.user.slug)/\(initialCampaign.slug)")!
        } else {
            return URL(string: "https://stjude.org/relay")!
        }
    }
    
    var body: some View {
        ScrollView {
            
            ScrollViewReader { scrollViewReader in
                
                if let initialCampaign = initialCampaign {
                    
                    FundraiserListItem(campaign: initialCampaign, sortOrder: .byGoal, showDisclosureIndicator: false)
                    
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
                            }
                        }
                        .disabled(rewards.isEmpty)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    
                    Link("Visit the fundraiser!", destination: fundraiserURL)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                        .padding(.horizontal, 20)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                    
                    if let description = initialCampaign.description {
                        
                        Text(description)
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical)
                        
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
                        
                        ForEach(milestones, id: \.id) { milestone in
                            HStack(alignment: .top) {
                                if milestone.amount.value <= initialCampaign.totalRaised.numericalValue {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                                Text("\(milestone.name)")
                                    .foregroundColor(milestone.amount.value <= initialCampaign.totalRaised.numericalValue ? .secondary : .primary)
                                Spacer()
                                Text(milestone.amount.description(showFullCurrencySymbol: false))
                                    .foregroundColor(.accentColor)
                                    .opacity(milestone.amount.value <= initialCampaign.totalRaised.numericalValue ? 0.75 : 1)
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
                                        AsyncImage(
                                            url: url,
                                            content: { image in
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 45, height: 45)
                                            },
                                            placeholder: {
                                                ProgressView()
                                                    .frame(width: 45, height: 45)
                                            }
                                        )
                                        .cornerRadius(5)
                                    }
                                    Text(reward.description)
                                        .font(.caption)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(.vertical, 8)
                            Divider()
                        }
                        
                    }
                    
                }
                
            }
            .padding()
            
        }
        .refreshable {
            await refresh()
        }
        .onAppear {
            
            // Campaign change watch
            campaignCancellable = AppDatabase.shared.start(observation: campaignObservation) { error in
                dataLogger.error("Error observing stored campaign: \(error.localizedDescription)")
            } onChange: { event in
                fetchTask?.cancel()
                fetchTask = Task {
                    await fetch()
                }
            }
            
            // New API fetch
            Task {
                await refresh()
            }
            
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
                .disabled(initialCampaign?.title ?? "" == "Relay FM")
            }
        }
        .navigationTitle(initialCampaign?.name ?? "Campaign")
        .navigationBarTitleDisplayMode(.inline)
        
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
        
        if let initialCampaign = initialCampaign {
            
            let response: TiltifyResponse
            do {
                response = try await apiClient.fetchCampaign(vanity: initialCampaign.user.slug, slug: initialCampaign.slug)
            } catch {
                dataLogger.error("Fetching campaign failed: \(error.localizedDescription)")
                return
            }
            
            let apiCampaign = initialCampaign.updated(fromCampaign: response.data.campaign, fundraiserId: initialCampaign.fundraisingEventId)
            do {
                if try await AppDatabase.shared.updateCampaign(apiCampaign, changesFrom: initialCampaign) {
                    dataLogger.info("Updated stored campaign: \(apiCampaign.id)")
                    self.initialCampaign = apiCampaign
                }
            } catch {
                dataLogger.error("Updating stored campaign failed: \(error.localizedDescription)")
            }
            
            var apiMilestones: [Int: Milestone] = response.data.campaign.milestones.reduce(into: [:]) { partialResult, ms in
                partialResult.updateValue(Milestone(from: ms, campaignId: initialCampaign.id), forKey: ms.id)
            }
            do {
                // For each milestone from the database...
                for dbMilestone in try await AppDatabase.shared.fetchSortedMilestones(for: initialCampaign) {
                    if let apiMilestone = apiMilestones[dbMilestone.id] {
                        apiMilestones.removeValue(forKey: dbMilestone.id)
                        // Update it from the API if it exists...
                        do {
                            try await AppDatabase.shared.updateMilestone(apiMilestone, changesFrom: dbMilestone)
                        } catch {
                            dataLogger.error("Failed to update Milestone \(apiMilestone.name): \(error.localizedDescription)")
                        }
                    } else {
                        // Remove it from the database if it doesn't...
                        do {
                            try await AppDatabase.shared.deleteMilestone(dbMilestone)
                        } catch {
                            dataLogger.error("Failed to delete Milestone \(dbMilestone.name): \(error.localizedDescription)")
                        }
                    }
                }
                // For each new milestone in the API, save it to the database
                for apiMilestone in apiMilestones.values {
                    do {
                        try await AppDatabase.shared.saveMilestone(apiMilestone)
                    } catch {
                        dataLogger.error("Failed to save Milestone \(apiMilestone.name): \(error.localizedDescription)")
                    }
                }
            } catch {
                dataLogger.error("Failed to fetch stored milestones for \(initialCampaign.id): \(error.localizedDescription)")
            }
            
            var apiRewards: [UUID: Reward] = response.data.campaign.rewards.reduce(into: [:]) { partialResult, reward in
                partialResult.updateValue(Reward(from: reward, campaignId: initialCampaign.id), forKey: reward.publicId)
            }
            do {
                // For each reward from the database...
                for dbReward in try await AppDatabase.shared.fetchSortedRewards(for: initialCampaign) {
                    if let apiReward = apiRewards[dbReward.id] {
                        apiRewards.removeValue(forKey: dbReward.id)
                        // Update it from the API if it exists...
                        do {
                            try await AppDatabase.shared.updateReward(apiReward, changesFrom: dbReward)
                        } catch {
                            dataLogger.error("Failed to update Reward \(apiReward.name): \(error.localizedDescription)")
                        }
                    } else {
                        // Remove it from the database if it doesn't...
                        do {
                            try await AppDatabase.shared.deleteReward(dbReward)
                        } catch {
                            dataLogger.error("Failed to delete Reward \(dbReward.name): \(error.localizedDescription)")
                        }
                    }
                }
                // For each new reward in the API, save it to the database
                for apiReward in apiRewards.values {
                    do {
                        try await AppDatabase.shared.saveReward(apiReward)
                    } catch {
                        dataLogger.error("Failed to save Reward \(apiReward.name): \(error.localizedDescription)")
                    }
                }
            } catch {
                dataLogger.error("Failed to fetch stored rewards for \(initialCampaign.id): \(error.localizedDescription)")
            }
            
            await fetch()
            
        }
        
    }
    
    /// Fetches the campaign data from GRDB
    func fetch() async {
        
        if let initialCampaign = initialCampaign {
            
            do {
                dataLogger.notice("Fetching stored campaign: \(initialCampaign.id)")
                self.initialCampaign = try await AppDatabase.shared.fetchCampaign(with: initialCampaign.id)
                dataLogger.notice("Fetched stored campaign: \(initialCampaign.id)")
            } catch {
                dataLogger.error("Failed to fetch stored campaign \(initialCampaign.id): \(error.localizedDescription)")
            }
            
            do {
                dataLogger.notice("Fetching stored milestones for \(initialCampaign.id)")
                self.milestones = try await AppDatabase.shared.fetchSortedMilestones(for: initialCampaign)
                dataLogger.notice("Fetched stored milestones for \(initialCampaign.id)")
            } catch {
                dataLogger.error("Failed to fetch stored milestones for \(initialCampaign.id): \(error.localizedDescription)")
            }
            do {
                dataLogger.notice("Fetching stored rewards for \(initialCampaign.id)")
                self.rewards = try await AppDatabase.shared.fetchSortedRewards(for: initialCampaign)
                dataLogger.notice("Fetched stored rewards for \(initialCampaign.id)")
            } catch {
                dataLogger.error("Failed to fetch stored rewards for \(initialCampaign.id): \(error.localizedDescription)")
            }
            
        }
        
    }
    
}

struct CampaignView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampaignView(initialCampaign: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "Aaron's Campaign for St Jude", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "294.00"), user: TiltifyUser(username: "agmcleod", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), description: "I'm fundraising for St. Jude Children's Research Hospital."), fundraiserId: UUID()))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Label("Back", systemImage: "chevron.left")
                    }
                }
        }
    }
}
