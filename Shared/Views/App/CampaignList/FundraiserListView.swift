//
//  FundraiserListView.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/18/25.
//

import SwiftUI

struct FundraiserListView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var namespace: Namespace.ID
    @State private var allCampaigns: [Campaign] = []
    @Binding var showSheet: CampaignListSheet?
    
    @State private var fundraiserSortOrder: FundraiserSortOrder = .byName
    @State private var compactListMode: Bool = false
    @Binding var selectedCampaignId: UUID?
    
    @State private var showSearchBar: Bool = false
    @State private var searchText = ""
    
    @Binding var isRefreshing: Bool
    @State private var isInitialLoad: Bool = true
    
    @State private var headToHeads: [HeadToHeadWithCampaigns] = []
    
    var searchResults: [Campaign] {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return allCampaigns
        } else {
            return allCampaigns.filter { $0.title.lowercased().contains(query) || $0.user.username.lowercased().contains(query) }
        }
    }
    
    @ViewBuilder
    var fundraiserHeaderView: some View {
        Group {
            if allCampaigns.count != 0 {
                GroupBox {
                    if self.showSearchBar {
                        SearchBar(text: $searchText, placeholder: "Search...", showingMyself: $showSearchBar)
                    } else {
                        VStack {
                            DynamicStack(direction: self.dynamicTypeSize >= .xLarge ? .vertical : .horizontal, alignment: .leading) {
                                Text("Fundraisers")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                if self.dynamicTypeSize < .xLarge {
                                    Spacer()
                                }
                                HStack {
                                    if self.allCampaigns.count != 0 {
                                        Text("\(allCampaigns.count)")
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                Color.tertiarySystemBackground
                                                    .cornerRadius(15)
                                            )
                                    }
                                    if self.dynamicTypeSize >= .xLarge {
                                        Spacer()
                                    }
                                    
                                    Button(action: {
                                        showSheet = .leaderBoard
                                    }) {
                                        Label("Leaderboard", systemImage: "trophy")
                                            .labelStyle(.iconOnly)
                                    }
                                    
                                    Menu {
                                        ForEach(FundraiserSortOrder.allCases, id: \.rawValue) { order in
                                            Button(action: {
                                                withAnimation {
                                                    fundraiserSortOrder = order
                                                }
                                            }) {
                                                Label("Sort by \(order.description)", systemImage: fundraiserSortOrder == order ? "checkmark" : "")
                                            }
                                        }
                                        Divider()
                                        Button(action: {
                                            withAnimation {
                                                compactListMode.toggle()
                                            }
                                        }) {
                                            Label("Compact View", systemImage: compactListMode ? "checkmark" : "rectangle.compress.vertical")
                                        }
                                    } label: {
                                        Image(systemName: "gear")
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            showSearchBar = true
                                        }
                                    }) {
                                        Label("Search", systemImage: "magnifyingglass")
                                            .labelStyle(.iconOnly)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if allCampaigns.count != 0 {
                if showSearchBar {
                }
            } else {
                Group {
                    if self.isInitialLoad {
                        self.loadingView
                    } else {
                        self.noFundraisersView
                    }
                }
            }
        }
        .frame(maxWidth: Double.stretchedContentMaxWidth)
    }
    
    @ViewBuilder
    var loadingView: some View {
        GroupBox {
            VStack {
                ProgressView()
                    .padding(.top, 40)
                    .padding(.bottom, 10)
                Text("Loading ...")
                    .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    var noFundraisersView: some View {
        GroupBox {
            VStack {
                Image(systemName: "exclamationmark.triangle")
                    .padding(.top, 40)
                    .padding(.bottom, 10)
                Text("No fundraisers yet")
                Link(destination: URL(string: "https://start.tiltify.com/?supportingFactId=1c6d5c76-1804-48fa-a474-2bfe1c52f48c")!, label: {
                    Text("Be the first and create your own!")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                })
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .buttonStyle(PrimaryButtonStyle())
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    var fundraiserListView: some View {
        if(allCampaigns.count != 0) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: .infinity), alignment: .top)]) {
                
                ForEach(Array(searchResults.enumerated()), id: \.offset) { index, campaign in
                        NavigationLink(value: CampaignListDestination.campaign(campaign, true)) {
                            GroupBox {
                                FundraiserListItem(campaign: campaign, sortOrder: fundraiserSortOrder, compact: compactListMode, showBackground: false, showShareSheet: .constant(false))
                            }
                            .zoomTransitioniOS26Source(id: "subCampaignCard-\(campaign.id)", namespace: self.namespace)
                        }
                        .buttonStyle(PlainButtonStyle())
//                        .buttonStyle(PrimaryButtonStyle(tint: .secondarySystemBackground, useCapsuleShape: false))
                        .contextMenu {
                            Button(action: {
                                showSheet = .continueHeadToHead(campaign: campaign)
                            }) {
                                Label(title: {
                                    Text("Start Head to Head")
                                }, icon: {
                                    Image(systemName: "trophy")
                                })
                            }
                            Button(action: {
                                Task {
                                    await starOrUnstar(campaign: campaign)
                                }
                            }) {
                                
                                Label(title: {
                                    Text(campaign.isStarred ? "Unfavourite" : "Favourite")
                                }, icon: {
                                    Image(systemName: campaign.isStarred ? "heart.fill" : "heart")
                                })
                            }
                        }
                }
            }
            // TODO: add these back
//            if searchText.lowercased() == "jonycube" || searchText.lowercased() == "jony cube" {
//                Image.imageAtScale(.jonycubePixel2024, scale: 0.5)
//            } else if searchText.lowercased() == "l2cu" {
//                Image.imageAtScale(.l2CuPixel2024, scale: 0.5)
//            }
        }
    }
    
    @ViewBuilder
    var fundraiserHeaderContainer: some View {
        if #available(iOS 26.0, *) {
            HStack {
                Text("Fundraisers")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                if self.allCampaigns.count != 0 {
                    Text("\(allCampaigns.count)")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Color.secondarySystemBackground
                                .cornerRadius(15)
                        )
                }
            }
        } else {
            self.fundraiserHeaderView
        }
    }
    
    @ViewBuilder
    var fundraiserListContainer: some View {
        if self.isInitialLoad {
            self.loadingView
        } else {
            if(allCampaigns.count != 0) {
                if #available(iOS 26.0, *) {
                    self.fundraiserListView
                        .toolbar {
                            ToolbarItem(placement: .bottomBar) {
                                Menu {
                                    ForEach(FundraiserSortOrder.allCases, id: \.rawValue) { order in
                                        Button(action: {
                                            withAnimation {
                                                fundraiserSortOrder = order
                                            }
                                        }) {
                                            Label("Sort by \(order.description)", systemImage: fundraiserSortOrder == order ? "checkmark" : "")
                                        }
                                    }
                                    Divider()
                                    Button(action: {
                                        withAnimation {
                                            compactListMode.toggle()
                                        }
                                    }) {
                                        Label("Compact View", systemImage: compactListMode ? "checkmark" : "rectangle.compress.vertical")
                                    }
                                } label: {
                                    Image(systemName: "line.3.horizontal.decrease")
                                }
                            }
                            ToolbarItem(placement: .bottomBar) {
                                Button(action: {
                                    showSheet = .leaderBoard
                                }) {
                                    Image(systemName: "trophy")
                                }
                                .zoomTransitioniOS26Source(id: "leaderboardButton", namespace: self.namespace)
                            }
                            ToolbarSpacer(.flexible, placement: .bottomBar)
                            DefaultToolbarItem(kind: .search, placement: .bottomBar)
                        }
                        .searchable(text: self.$searchText)
                        .searchToolbarBehavior(.minimize)
                } else {
                    self.fundraiserListView
                }
            } else {
                self.noFundraisersView
            }
        }
    }
    
    @ViewBuilder
    var extraOptionsView: some View {
        if self.allCampaigns.count != 0 {
            HeadToHeadListView(namespace: self.namespace, headToHeads: self.$headToHeads, showSheet: self.$showSheet, onDelete: {
                Task {
                    await self.fetch()
                }
            })
            if #available(iOS 18.0, *) {
                self.randomFundraiserButton
                .matchedTransitionSource(id: "randomFundraiserButton", in: self.namespace)
            } else {
                self.randomFundraiserButton
            }
        }
    }
    
    @ViewBuilder
    var randomFundraiserButton: some View {
        Button(action: {
            showSheet = .randomPicker
        }) {
            HStack {
                Text("Spin for a random Fundraiser!")
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
            }
        }
        .buttonStyle(PrimaryButtonStyle(useGlass: false))
    }
    
    var body: some View {
        VStack {
            self.fundraiserHeaderContainer
            self.extraOptionsView
            self.fundraiserListContainer
        }
        .onAppear {
            fundraiserSortOrder = UserDefaults.shared.campaignListSortOrder
            compactListMode = UserDefaults.shared.campaignListCompactView
            
            Task {
                await self.refresh()
            }
        }
        .onChange(of: self.isRefreshing) {
            if self.isRefreshing {
                Task {
                    await self.refresh()
                }
            }
        }
        
        .onChange(of: compactListMode) {
            UserDefaults.shared.campaignListCompactView = self.compactListMode
        }
        .onChange(of: fundraiserSortOrder) {
            UserDefaults.shared.campaignListSortOrder = self.fundraiserSortOrder
            Task {
                let newAllCampaigns = sortCampaigns(allCampaigns)
                DispatchQueue.main.async {
                    allCampaigns = newAllCampaigns
                }
            }
        }
        .onChange(of: searchText) {
            if self.searchText.lowercased() == "do a barrel roll" {
//                rotationAnimation = false
                withAnimation(.easeInOut(duration: 2.0)) {
//                    rotationAnimation = true
                }
            }
        }
    }
    
    func starOrUnstar(campaign: Campaign) async {
        let newCampaign = campaign.setStar(to: !campaign.isStarred)
        do {
            if try await AppDatabase.shared.updateCampaign(newCampaign, changesFrom: campaign) {
                dataLogger.info("Updated starring stored campaign: \(newCampaign.id)")
            }
        } catch {
            dataLogger.error("Starring/unstarring stored campaign failed: \(error.localizedDescription)")
        }
        await fetch()
    }
    
    func compareNames(c1: Campaign, c2: Campaign) -> Bool {
        if c1.name.lowercased() == c2.name.lowercased() {
            return c1.id.uuidString < c2.id.uuidString
        }
        return c1.name.lowercased() < c2.name.lowercased()
    }
    
    func sortCampaigns(_ campaigns: [Campaign]) -> [Campaign] {
        return campaigns.sorted { c1, c2 in
            if c1.isStarred && !c2.isStarred {
                return true
            }
            if c2.isStarred && !c1.isStarred {
                return false
            }
            switch fundraiserSortOrder {
            case .byAmountRaised:
                let v1 = c1.totalRaisedNumerical
                let v2 = c2.totalRaisedNumerical
                if v1 == v2 {
                    return compareNames(c1: c1, c2: c2)
                }
                return v1 > v2
            case .byGoal:
                let v1 = c1.goalNumerical
                let v2 = c2.goalNumerical
                if v1 == v2 {
                    return compareNames(c1: c1, c2: c2)
                }
                return v1 > v2
            case .byPercentage:
                let v1 = c1.percentageReached ?? 0
                let v2 = c2.percentageReached ?? 0
                if v1 == v2 {
                    return compareNames(c1: c1, c2: c2)
                }
                return v1 > v2
            case .byAmountRemaining:
                var v1 = c1.goalNumerical - c1.totalRaisedNumerical
                var v2 = c2.goalNumerical - c2.totalRaisedNumerical
                if v1 <= 0 {
                    v1 = .infinity
                }
                if v2 <= 0 {
                    v2 = .infinity
                }
                if v1 == v2 {
                    return compareNames(c1: c1, c2: c2)
                }
                return v1 < v2
            default:
                return compareNames(c1: c1, c2: c2)
            }
        }
    }
    
    func refresh() async {
        dataLogger.debug("Fetching campaigns...")
        let apiCampaigns = await TiltifyAPIClient.shared.getFundraisingEventCampaigns()
        var keyedApiCampaigns: [UUID: Campaign] = apiCampaigns.reduce(into: [:]) { partialResult, campaign in
            partialResult.updateValue(Campaign(from: campaign), forKey: campaign.id)
        }
        dataLogger.debug("Fetching campaigns... \(apiCampaigns.count) Done")
        
        do {
            // For each campaign from the database...
            for dbCampaign in try await AppDatabase.shared.fetchAllCampaigns() {
                if let apiCampaign = keyedApiCampaigns[dbCampaign.id] {
                    // Update it from the API if it exists...
                    keyedApiCampaigns.removeValue(forKey: dbCampaign.id)
                    let updateCampaign = dbCampaign.isStarred ? apiCampaign.setStar(to: true) : apiCampaign
                    do {
                        dataLogger.notice("Updating \(apiCampaign.name) - \(apiCampaign.totalRaised.description(showFullCurrencySymbol: false))")
                        try await AppDatabase.shared.updateCampaign(updateCampaign, changesFrom: dbCampaign)
                        if apiCampaign.id == TLD_CAMPAIGN {
//                            iconsUnlocked = apiCampaign.totalRaisedNumerical >= TLDMilestones.IconsUnlocked
                        }
                    } catch {
                        dataLogger.error("Failed to update campaign: \(updateCampaign.id) \(updateCampaign.name): \(error.localizedDescription)")
                    }
                } else {
                    // Remove it from the database if it doesn't...
                    do {
                        try await AppDatabase.shared.deleteCampaign(dbCampaign)
                    } catch {
                        dataLogger.error("Failed to delete campaign \(dbCampaign.id) \(dbCampaign.name): \(error.localizedDescription)")
                    }
                }
            }
            // For each new campaign in the API, save it to the database
            for apiCampaign in keyedApiCampaigns.values {
                do {
                    try await AppDatabase.shared.saveCampaign(apiCampaign)
                    // TODO: Maybe move this check into the settings view?
                    if apiCampaign.id == TLD_CAMPAIGN {
//                        iconsUnlocked = apiCampaign.totalRaisedNumerical >= TLDMilestones.IconsUnlocked
                    }
                } catch {
                    dataLogger.error("Failed to save Campaign \(apiCampaign.id) \(apiCampaign.name): \(error.localizedDescription)")
                }
            }
        } catch {
            dataLogger.error("Could not update campaigns")
        }
        
        await self.fetch()
        self.isRefreshing = false
        self.isInitialLoad = false
    }
    
    func fetch() async {
        // Fetch stored campaigns
        do {
            dataLogger.notice("Fetched stored fundraiser")
            try Task.checkCancellation()
            allCampaigns = sortCampaigns(try await AppDatabase.shared.fetchAllCampaigns().filter { !HIDDEN_CAMPAIGN_IDS.contains($0.id) })
        } catch {
            dataLogger.error("Failed to fetch stored fundraisers: \(error.localizedDescription)")
        }
        
        // Fetch stored head to heads
        do {
            let fetchedHeadToHeads = try await AppDatabase.shared.fetchAllHeadToHeads()
            withAnimation {
                headToHeads = fetchedHeadToHeads
            }
            dataLogger.notice("Fetched stored head to heads")
        } catch {
            dataLogger.error("Failed to fetch store head to heads: \(error.localizedDescription)")
        }
    }
}
