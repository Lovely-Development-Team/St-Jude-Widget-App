//
//  CampaignList.swift
//  St Jude
//
//  Created by Ben Cardy on 18/08/2022.
//

import SwiftUI
import GRDB

enum FundraiserSortOrder: Int, CaseIterable {
    case byName
    case byAmountRaised
    case byAmountRemaining
    case byGoal
    case byPercentage
    
    var description: String {
        switch self {
        case .byName:
            return "Name"
        case .byAmountRaised:
            return "Amount Raised"
        case .byGoal:
            return "Goal"
        case .byPercentage:
            return "Percentage"
        case .byAmountRemaining:
            return "Amount Remaining"
        }
    }
    
}

enum CampaignListSheet: Identifiable {
    case aboutScreen
    case leaderBoard
    case randomPicker
    case easterEgg
    case startHeadToHead
    case continueHeadToHead(campaign: Campaign)
    
    var id: String {
        switch self {
        case .aboutScreen:
            return "aboutScreen"
        case .leaderBoard:
            return "leaderBoard"
        case .randomPicker:
            return "randomPicker"
        case .easterEgg:
            return "easterEgg"
        case .startHeadToHead:
            return "startHeadToHead"
        case let .continueHeadToHead(campaign):
            return "continueHeadToHead:\(campaign.id.uuidString)"
        }
    }
    
}

struct CampaignList: View {
    
    // MARK: 2023
    @State private var teamEvent: TeamEvent? = nil
    @State private var teamEventObservation = AppDatabase.shared.observeTeamEventObservation()
    @State private var teamEventCancellable: DatabaseCancellable?
    
    @State private var showSheet: CampaignListSheet? = nil
    
    // MARK: 2022
    
    @State private var campaigns: [Campaign] = []
    @State private var headToHeads: [HeadToHeadWithCampaigns] = []
    @StateObject private var apiClient = ApiClient.shared
    
    @State private var fundraiserSortOrder: FundraiserSortOrder = .byName
    @State private var compactListMode: Bool = false
    @State private var selectedCampaignId: UUID? = nil
    
    @State private var showSearchBar: Bool = false
    @State private var searchText = ""
    
    @State private var isRefreshing: Bool = false
    @State private var isLoading: Bool = true
    @State private var campaignsHaveClosed: Bool = false
    @State private var showStephen: Bool = false
    
    @State private var showHeadToHeads: Bool = true
    
    @AppStorage(UserDefaults.shouldShowHeadToHeadKey, store: UserDefaults.shared) private var shouldShowHeadToHead: Bool = false
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    let closingDate: Date? = Date(timeIntervalSince1970: 1696644050)
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func compareNames(c1: Campaign, c2: Campaign) -> Bool {
        if c1.name.lowercased() == c2.name.lowercased() {
            return c1.id.uuidString < c2.id.uuidString
        }
        return c1.name.lowercased() < c2.name.lowercased()
    }
    
    var sortedCampaigns: [Campaign] {
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
    
    var searchResults: [Campaign] {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return sortedCampaigns
        } else {
            return sortedCampaigns.filter { $0.title.lowercased().contains(query) || $0.user.username.lowercased().contains(query) }
        }
    }
    
    @ViewBuilder
    var headToHeadList: some View {
        ForEach(headToHeads, id: \.headToHead.id) { headToHead in
            NavigationLink(destination: HeadToHeadView(campaign1: headToHead.campaign1, campaign2: headToHead.campaign2).tint(.white)) {
                HeadToHeadListItem(headToHead: headToHead)
                    .contextMenu {
                        Button(role: .destructive) {
                            Task {
                                do {
                                    try await AppDatabase.shared.deleteHeadToHead(headToHead.headToHead)
                                } catch {
                                    dataLogger.error("Could not delete head to head: \(error.localizedDescription)")
                                }
                                await fetch()
                            }
                        } label: {
                            Label("Remove Head to Head", systemImage: "trash")
                        }
                    }
            }
            .tint(.white)
            .padding(.top)
        }
    }
    
    var body: some View {
        
        ScrollView {
            ScrollViewReader { scrollViewReader in
                VStack(spacing: 0) {
                    
                    if let teamEvent = teamEvent {
                        NavigationLink(destination: CampaignView(teamEvent: teamEvent), tag: teamEvent.id, selection: $selectedCampaignId) {
                            TeamEventCardView(teamEvent: teamEvent, showDisclosureIndicator: true, showShareSheet: .constant(false))
                        }
                        .padding()
                    } else {
                        TeamEventCardView(teamEvent: teamEvent, showDisclosureIndicator: true, showShareSheet: .constant(false))
                            .padding()
                    }
                    
                    if let closingDate = closingDate {
                        VStack {
                            if campaignsHaveClosed {
                                Text("Fundraisers are now closed!")
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                HStack(alignment: .top) {
                                    VStack {
                                        Group {
                                            Text("An enormous thank you to everyone who helped raise such a phenomenal amount.")
                                        }
                                        .multilineTextAlignment(.leading)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    }
                                    Image(showStephen ? .stephen : .myke)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60)
                                        .tapToWobble(anchor: .center)
                                }
                            } else {
                                Group {
                                    Text("Fundraisers close in ").bold() + Text(closingDate, style: .relative).bold() + Text("!").bold()
                                }
                                .font(.title2)
                                .multilineTextAlignment(.leading)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .padding(.bottom)
                    }
                    
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
                                }
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 4)
                                .background(
                                    Color.brandBlue
                                        .cornerRadius(15)
                                )
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .rotationEffect(.degrees(showHeadToHeads ? 90 : 0))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    if headToHeads.count == 0 {
                        if showHeadToHeads {
                            VStack {
                                Button("Add a Head to Head") {
                                    showSheet = .startHeadToHead
                                }
                                .foregroundStyle(Color.primary)
                                .fullWidth(alignment: .center)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10).fill(Color.brandBlue.opacity(0.2))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5])).foregroundStyle(Color.brandBlue)
                                )
                            }
                            .padding(.horizontal)
                            .padding(.top, 5)
                        }
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: .infinity), alignment: .top)], spacing: 0) {
                            if showHeadToHeads {
                                headToHeadList
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Fundraisers")
                            .font(.title)
                            .fontWeight(.bold)
                        if campaigns.count != 0 {
                            Text("\(campaigns.count - HIDDEN_CAMPAIGN_IDS.count)")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Color.secondarySystemBackground
                                        .cornerRadius(15)
                                )
                        }
                        Spacer()
                        Button(action: {
                            showSheet = .leaderBoard
                        }) {
                            Label("Leaderboard", systemImage: "trophy")
                                .labelStyle(.iconOnly)
                        }
                        Menu {
                            ForEach(FundraiserSortOrder.allCases, id: \.self) { order in
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
                                Label("Compact View", systemImage: compactListMode ? "checkmark" : "")
                            }
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                        Button(action: {
                            withAnimation {
                                showSearchBar = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        scrollViewReader.scrollTo("SEARCH_BAR", anchor: .top)
                                    }
                                }
                            }
                        }) {
                            Label("Search", systemImage: "magnifyingglass")
                                .labelStyle(.iconOnly)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if campaigns.count != 0 {
                        
                        if showSearchBar {
                            SearchBar(text: $searchText, placeholder: "Search...", showingMyself: $showSearchBar)
                                .padding(.horizontal, 8)
                                .id("SEARCH_BAR")
                        }
                        
//                        if selectedCampaignId != nil {
                            /// In order to open a selected campaign when a widget is tapped, the corresponding
                            /// NavigationLink needs to be loaded. That  isn't guaranteed when they are presented
                            /// in a Lazy grid as below, so we create a bunch of empty/invisible NavigationLinks to
                            /// trigger on the widget tap instead
                            ForEach(sortedCampaigns, id: \.id) { campaign in
                                NavigationLink(destination: CampaignView(initialCampaign: campaign), tag: campaign.id, selection: $selectedCampaignId) {
                                    EmptyView()
                                }
                            }
                            ForEach(headToHeads, id: \.headToHead.id) { headToHead in
                                NavigationLink(destination: HeadToHeadView(campaign1: headToHead.campaign1, campaign2: headToHead.campaign2), tag: headToHead.headToHead.id, selection: $selectedCampaignId) {
                                    EmptyView()
                                }
                            }
//                        }
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: .infinity), alignment: .top)], spacing: 0) {
                            
                            Button(action: {
                                showSheet = .randomPicker
                            }) {
                                GroupBox {
                                    HStack {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text("Spin the Wheel of Fundraisers!")
                                            .multilineTextAlignment(.leading)
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .foregroundColor(.primary)
                                }
                            }
                            .padding(.top)
                            
                            ForEach(searchResults, id: \.id) { campaign in
                                if !HIDDEN_CAMPAIGN_IDS.contains(campaign.id) {
                                    NavigationLink(destination: CampaignView(initialCampaign: campaign)) {
                                        FundraiserListItem(campaign: campaign, sortOrder: fundraiserSortOrder, compact: compactListMode, showShareSheet: .constant(false))
                                            .contextMenu {
                                                if shouldShowHeadToHead {
                                                    Button(action: {
                                                        showSheet = .continueHeadToHead(campaign: campaign)
                                                    }) {
                                                        Label("Start Head to Head", systemImage: "trophy")
                                                    }
                                                }
                                                Button(action: {
                                                    Task {
                                                        await starOrUnstar(campaign: campaign)
                                                    }
                                                }) {
                                                    Label(campaign.isStarred ? "Remove Star" : "Star", systemImage: campaign.isStarred ? "star" : "star.fill")
                                                }
                                            }
                                    }
                                    .padding(.top)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            showSheet = .easterEgg
                        }, label: {
                            HStack {
                                Text("App from the Lovely Developers")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Image("l2culogosvg")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.secondary)
                                    .frame(height: 15)
                                    .accessibility(hidden: true)
                                
                            }
                        })
                        .buttonStyle(PlainButtonStyle())
                        .padding()
                        
                    } else {
                        
                        if isLoading {
                            
                            ProgressView()
                                .padding(.top, 40)
                                .padding(.bottom, 10)
                            Text("Loading ...")
                                .padding(.bottom, 40)
                            
                        } else {
                            
                            Image(systemName: "exclamationmark.triangle")
                                .padding(.top, 40)
                                .padding(.bottom, 10)
                            Text("No fundraisers yet")
                            
                            Link("Be the first and create your own!", destination: URL(string: "https://tiltify.com/+relay-fm/relay-fm-for-st-jude-2023/start/cause-summary")!)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                                .padding(.horizontal, 20)
                                .background(Color.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .padding()
                            
                        }
                        
                    }
                }
                .padding(.bottom)
            }
        }
        .background(BrandShapeBackground())
        .refreshable {
            await refresh()
        }
        .onReceive(timer) { _ in
            Task {
                await refresh()
            }
        }
        .onReceive(countdownTimer) { _ in
            if let closingDate = closingDate {
                withAnimation {
                    campaignsHaveClosed = closingDate < Date()
                }
            }
        }
        .onChange(of: fundraiserSortOrder) { newValue in
            UserDefaults.shared.campaignListSortOrder = newValue
        }
        .onChange(of: compactListMode) { newValue in
            UserDefaults.shared.campaignListCompactView = newValue
        }
        .onChange(of: showHeadToHeads) { newValue in
            UserDefaults.shared.expandHeadToHeadSection = newValue
        }
        .onAppear {
            
            if let closingDate = closingDate {
                campaignsHaveClosed = closingDate < Date()
            }
            showStephen = Bool.random()
            showHeadToHeads = UserDefaults.shared.expandHeadToHeadSection
            fundraiserSortOrder = UserDefaults.shared.campaignListSortOrder
            compactListMode = UserDefaults.shared.campaignListCompactView
            
            teamEventCancellable = AppDatabase.shared.start(observation: teamEventObservation) { error in
                dataLogger.error("Error observing stored team event: \(error.localizedDescription)")
            } onChange: { event in
                teamEvent = event
            }
            
            Task {
                await fetch()
            }
            Task {
                await refresh()
            }
            
        }
        .sheet(item: $showSheet, onDismiss: {
            SoundEffectHelper.shared.stop()
        }) { sheet in
            switch sheet {
            case .aboutScreen:
                NavigationView {
                    AboutView()
                }
            case .leaderBoard:
                NavigationView {
                    Leaderboard(campaigns: campaigns) { campaign in
                        showSheet = nil
                        selectedCampaignId = campaign.id
                    }
                }
            case .randomPicker:
                NavigationStack {
                    RandomCampaignPickerView(campaignChoiceID: $selectedCampaignId,
                                             allCampaigns: campaigns)
                    .navigationTitle("Wheel of Fundraisers")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showSheet = nil
                            }
                            .animation(.linear(duration: 0))
                        }
                    }
                }
            case .easterEgg:
                EasterEggView()
                    .background(Color.secondarySystemBackground)
                    .edgesIgnoringSafeArea(.all)
            case .startHeadToHead:
                NavigationView {
                    ChooseCampaignView() { campaign in
                        showSheet = .continueHeadToHead(campaign: campaign)
                    }
                }
            case let .continueHeadToHead(firstCampaign):
                NavigationView {
                    ChooseCampaignView(otherCampaign: firstCampaign) { otherCampaign in
                        Task {
                            let headToHead = HeadToHead(id: UUID(), campaignId1: firstCampaign.id, campaignId2: otherCampaign.id)
                            do {
                                try await AppDatabase.shared.saveHeadToHead(headToHead)
                            } catch {
                                dataLogger.error("Could not create Head to Head: \(error.localizedDescription)")
                            }
                            await fetch()
                            selectedCampaignId = headToHead.id
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showSheet = .aboutScreen
                }) {
                    Label("About", systemImage: "info.circle")
                        .labelStyle(.iconOnly)
                }
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
        .navigationTitle("Relay FM for St. Jude 2023")
        .onOpenURL { url in
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false), components.host == "campaign", let queryComponents = components.queryItems?.reduce(into: [String: String](), { (result, item) in
                result[item.name] = item.value
            }), let id = queryComponents["id"] {
                selectedCampaignId = UUID(uuidString: id)
                showSheet = nil
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
    
    func refresh() async {
        
        if let apiEventData = await apiClient.fetchTeamEvent() {
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
        
        dataLogger.debug("Fetching campaigns...")
        let apiCampaigns = await apiClient.fetchCampaignsForTeamEvent()
        var keyedApiCampaigns: [UUID: Campaign] = apiCampaigns.reduce(into: [:]) { partialResult, campaign in
            partialResult.updateValue(Campaign(from: campaign), forKey: campaign.publicId)
        }
        dataLogger.debug("Fetching campaigns... Done")
        
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
                            shouldShowHeadToHead = apiCampaign.totalRaisedNumerical >= TLDMilestones.HeadToHead
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
                    if apiCampaign.id == TLD_CAMPAIGN {
                        shouldShowHeadToHead = apiCampaign.totalRaisedNumerical >= TLDMilestones.HeadToHead
                    }
                } catch {
                    dataLogger.error("Failed to save Campaign \(apiCampaign.id) \(apiCampaign.name): \(error.localizedDescription)")
                }
            }
        } catch {
            dataLogger.error("Could not update campaigns")
        }
        
        await fetch()
        
        self.isLoading = false
        
    }
    
    func fetch() async {
        do {
            dataLogger.notice("Fetched stored fundraiser")
            try Task.checkCancellation()
            campaigns = try await AppDatabase.shared.fetchAllCampaigns()
            dataLogger.notice("Fetched stored campaigns")
            let fetchedHeadToHeads = try await AppDatabase.shared.fetchAllHeadToHeads()
            withAnimation {
                headToHeads = fetchedHeadToHeads
            }
            dataLogger.notice("Fetched stored head to heads")
            
        } catch is CancellationError {
            dataLogger.info("Campaign fetch cancelled")
        }
        catch {
            dataLogger.error("Failed to fetch stored fundraiser: \(error.localizedDescription)")
        }
    }
    
}

struct CampaignList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampaignList()
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}
