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

    init() {
        updateNavBarFont()
    }

    func updateNavBarFont() {
        UINavigationBar.appearance().titleTextAttributes = [.font : UserDefaults.shared.disablePixelFont ? UIFont.preferredFont(forTextStyle: .headline) : UIFont(name: Font.customFontName, size: UIFont.preferredFont(forTextStyle: .headline).pointSize) ?? UIFont.systemFont(ofSize: 20)]
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UserDefaults.shared.disablePixelFont ? UIFont.preferredFont(forTextStyle: .largeTitle) : UIFont(name: Font.customFontName, size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)  ?? UIFont.systemFont(ofSize: 20)]
    }
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    // MARK: 2025
    private let competitors = Players.allCases.shuffled()
    
    // MARK: 2023
    @State private var teamEvent: TeamEvent? = nil
    @State private var teamEventObservation = AppDatabase.shared.observeTeamEventObservation()
    @State private var teamEventCancellable: DatabaseCancellable?
    
    @State private var showSheet: CampaignListSheet? = nil
    
    // MARK: 2022
    
    @State private var allCampaigns: [Campaign] = []
    @State private var headToHeads: [HeadToHeadWithCampaigns] = []
    @StateObject private var apiClient = ApiClient.shared
    
    @State private var fundraiserSortOrder: FundraiserSortOrder = .byName
    @State private var compactListMode: Bool = false
    @State private var selectedCampaignId: UUID? = nil
    
    @State private var showSearchBar: Bool = false
    @State private var searchText = ""
    
    @State private var isRefreshing: Bool = false
    @State private var isLoading: Bool = true
    @State private var showStephen: Bool = false
    
    @State private var showHeadToHeads: Bool = true
    @State private var rotationAnimation: Bool = false
    
    @AppStorage(UserDefaults.iconsUnlockedKey, store: UserDefaults.shared) private var iconsUnlocked: Bool = false
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
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
    
    var searchResults: [Campaign] {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return allCampaigns
        } else {
            return allCampaigns.filter { $0.title.lowercased().contains(query) || $0.user.username.lowercased().contains(query) }
        }
    }
    
    @ViewBuilder
    var headToHeadList: some View {
        ForEach(headToHeads, id: \.headToHead.id) { headToHead in
            NavigationLink(destination: HeadToHeadView(campaign1: headToHead.campaign1, campaign2: headToHead.campaign2).tint(.white)) {
                HeadToHeadListItem(headToHead: headToHead)
            }
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
                    Label("Remove Head to Head", image: "trash.pixel")
                }
            }
        }
        .compositingGroup()
    }
    
    @ViewBuilder
    var topView: some View {
        VStack(spacing: 0) {
            Group {
                VStack {
                    Group {
                        if let teamEvent = teamEvent {
                            NavigationLink(destination: CampaignView(teamEvent: teamEvent), tag: teamEvent.id, selection: $selectedCampaignId) {
                                TeamEventCardView(teamEvent: teamEvent, showDisclosureIndicator: true, showShareSheet: .constant(false), showBackground: false)
                            }
                            .buttonStyle(BlockButtonStyle(tint: WidgetAppearance.caseyLights))
                            .padding()
                        } else {
                            TeamEventCardView(teamEvent: teamEvent, showDisclosureIndicator: true, showShareSheet: .constant(false))
                                .padding()
                        }
                    }
                    .zIndex(1)
//                    RandomLandscapeView(data: self.$landscapeData) {
//                        EmptyView()
//                    }
                    .zIndex(0)
                }
            }
            .frame(maxWidth: Double.stretchedContentMaxWidth)
            
            AdaptiveImage.groundRepeatable(colorScheme: self.colorScheme)
                .tiledImageAtScale(axis: .horizontal)
        }
        .frame(maxWidth: .infinity)
        .background(alignment: .bottom) {
            ZStack(alignment: .bottom) {
                SkyView()
            }
            .mask {
                LinearGradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white, location: 0.25),
                    .init(color: .white, location: 1)
                ], startPoint: .top, endPoint: .bottom)
            }
        }
    }
        
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
                            }
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 4)
                            .aspectRatio(1.0, contentMode: .fit)
                            .background {
                                GeometryReader { geometry in
                                    Color.brandBlue
                                        .modifier(PixelRounding(geometry: geometry))
                                }
                            }
                        }
                        Spacer()
                        Image("pixel-chevron-right")
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(showHeadToHeads ? 90 : 0))
                    }
                }
                .buttonStyle(.plain)
                if headToHeads.count == 0 {
                    if showHeadToHeads {
                        VStack {
                            Button(action: {
                                showSheet = .startHeadToHead
                            }, label: {
                                Text("Add a Head to Head")
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            })
                            .buttonStyle(BlockButtonStyle(tint: .brandBlue))
                            .foregroundStyle(Color.white)
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
        .padding(.horizontal)
        .frame(maxWidth: Double.stretchedContentMaxWidth)
        .groupBoxStyle(BlockGroupBoxStyle())
    }
    
    @ViewBuilder
    func fundraiserHeaderView(scrollViewReader: SwiftUI.ScrollViewProxy) -> some View {
        Group {
            if allCampaigns.count != 0 {
                if dynamicTypeSize >= .xLarge {
                    GroupBox {
                        VStack(spacing: 0) {
                            HStack {
                                Text("Fundraisers")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            HStack {
                                Text("\(allCampaigns.count)")
                                    .foregroundColor(.secondary)
                                    .background(
                                        Color.secondarySystemBackground
                                            .cornerRadius(15)
                                    )
                                Spacer()
                                Button(action: {
                                    showSheet = .leaderBoard
                                }) {
                                    Label("Leaderboard", image: "pixel-trophy")
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
                                    Image("pixel-settings")
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
                                    Label("Search", image: "pixel-magnify")
                                        .labelStyle(.iconOnly)
                                }
                            }
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle())
                    .padding(.horizontal)
                } else {
                    GroupBox {
                        HStack {
                            Text("Fundraisers")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(allCampaigns.count)")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Color.secondarySystemBackground
                                        .cornerRadius(15)
                                )
                            Button(action: {
                                showSheet = .leaderBoard
                            }) {
                                Label("Leaderboard", image: "pixel-trophy")
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
                                Image("pixel-settings")
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
                                Label("Search", image: "pixel-magnify")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle())
                    .padding(.horizontal)
                }
            }

            if allCampaigns.count != 0 {
                
                if showSearchBar {
                    GroupBox {
                        SearchBar(text: $searchText, placeholder: "Search...", showingMyself: $showSearchBar)
                            .id("SEARCH_BAR")
                    }
                    .groupBoxStyle(BlockGroupBoxStyle(tint: .secondarySystemBackground, padding: false))
                    .padding(.horizontal)
                }
                Button(action: {
                    showSheet = .randomPicker
                }) {
                    HStack {
                        Image("pixel-question")
                        Text("Play for a random Fundraiser!")
                            .multilineTextAlignment(.leading)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        Image("pixel-chevron-right")
                    }
                    .foregroundColor(.black)
                }
                .padding(.horizontal)
                .buttonStyle(BlockButtonStyle(tint: WidgetAppearance.stephenLights))
            } else {
                Group {
                    if isLoading {
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
                        .groupBoxStyle(BlockGroupBoxStyle())
                        
                    } else {
                        GroupBox {
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .padding(.top, 40)
                                    .padding(.bottom, 10)
                                    .foregroundStyle(.white)
                                Text("No fundraisers yet")
                                    .foregroundStyle(.white)
                                Link(destination: URL(string: "https://tiltify.com/\(TEAM_EVENT_VANITY)/\(TEAM_EVENT_SLUG)/start/cause-summary")!, label: {
                                    Text("Be the first and create your own!")
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                })
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                                .buttonStyle(BlockButtonStyle(tint: .white))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .groupBoxStyle(BlockGroupBoxStyle(tint: .brandRed))
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: Double.stretchedContentMaxWidth)
    }
    
    @ViewBuilder
    var fundraiserListView: some View {
        if(allCampaigns.count != 0) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: .infinity), alignment: .top)]) {
                
                ForEach(Array(searchResults.enumerated()), id: \.offset) { index, campaign in
                        NavigationLink(destination: CampaignView(initialCampaign: campaign)) {
                            FundraiserListItem(campaign: campaign, sortOrder: fundraiserSortOrder, compact: compactListMode, showBackground: false, showShareSheet: .constant(false))
                        }
                        .buttonStyle(BlockButtonStyle())
                        .contextMenu {
                            Button(action: {
                                showSheet = .continueHeadToHead(campaign: campaign)
                            }) {
                                Label("Start Head to Head", image: "pixel-trophy")
                            }
                            Button(action: {
                                Task {
                                    await starOrUnstar(campaign: campaign)
                                }
                            }) {
                                Label(campaign.isStarred ? "Unfavourite" : "Favourite", image: campaign.isStarred ? "heart.pixel" : "heart.fill.pixel")
                            }
                        }
                }
            }
            .padding(.horizontal)
            if searchText.lowercased() == "jonycube" || searchText.lowercased() == "jony cube" {
                AdaptiveImage.jonyCube(colorScheme: self.colorScheme)
                    .imageAtScale(scale: 0.5)
            } else if searchText.lowercased() == "l2cu" {
                AdaptiveImage(colorScheme: self.colorScheme, light: .l2CuPixelLight)
                    .imageAtScale(scale: 0.5)
            }
        }
    }
    
    @ViewBuilder
    var easterEggView: some View {
        Button(action: {
            showSheet = .easterEgg
        }, label: {
            HStack {
                Text("App from the Lovely Developers")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Image(.l2CuHeadPixel)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibility(hidden: true)
                
            }
            .frame(maxWidth: .infinity)
        })
        .buttonStyle(BlockButtonStyle())
        .padding(.horizontal)
        .frame(maxWidth: Double.stretchedContentMaxWidth)
    }
    
    @ViewBuilder
    var widgetCompatibilityView: some View {
        //                        if selectedCampaignId != nil {
        /// In order to open a selected campaign when a widget is tapped, the corresponding
        /// NavigationLink needs to be loaded. That  isn't guaranteed when they are presented
        /// in a Lazy grid as below, so we create a bunch of empty/invisible NavigationLinks to
        /// trigger on the widget tap instead
        ForEach(allCampaigns, id: \.id) { campaign in
            NavigationLink(destination: CampaignView(initialCampaign: campaign), tag: campaign.id, selection: $selectedCampaignId) {
                EmptyView()
            }
        }
        
        ForEach(headToHeads, id: \.headToHead.id) { headToHead in
            NavigationLink(destination: HeadToHeadView(campaign1: headToHead.campaign1, campaign2: headToHead.campaign2), tag: headToHead.headToHead.id, selection: $selectedCampaignId) {
                EmptyView()
            }
        }
    }
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollViewReader in
                VStack(spacing: 0) {
                    VStack{
                        topView
                        
                        HStack{
                            StandingToThrowingView(player: competitors.first!, isMirrored:true)
                            Spacer()
                            StandingToThrowingView(player: competitors.last!)
                        }
                        Spacer()
                            .padding(10)
                    }
                    .background(AdaptiveImage(colorScheme: self.colorScheme, light: .blankWall).imageAtScale())

                    VStack {
                        CountdownView()
                            .padding(.horizontal)
                        headToHeadListView
                        fundraiserHeaderView(scrollViewReader: scrollViewReader)
                        fundraiserListView
                        easterEggView
                        widgetCompatibilityView
                    }
                    .padding(.bottom)
                    .frame(maxWidth: .infinity)
                    .background(AdaptiveImage(colorScheme: self.colorScheme, light: .blankWallFloor).tiledImageAtScale())
                }
                .rotationEffect(Angle(degrees: rotationAnimation ? 0 : 360))
                
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
        .onChange(of: fundraiserSortOrder) { newValue in
            UserDefaults.shared.campaignListSortOrder = newValue
            Task {
                let newAllCampaigns = sortCampaigns(allCampaigns)
                DispatchQueue.main.async {
                    allCampaigns = newAllCampaigns
                }
            }
        }
        .onChange(of: compactListMode) { newValue in
            UserDefaults.shared.campaignListCompactView = newValue
        }
        .onChange(of: showHeadToHeads) { newValue in
            UserDefaults.shared.expandHeadToHeadSection = newValue
        }
        .onAppear {
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
                    AboutView(campaignChoiceID: self.$selectedCampaignId)
                }
            case .leaderBoard:
                NavigationView {
                    Leaderboard(campaigns: allCampaigns) { campaign in
                        showSheet = nil
                        selectedCampaignId = campaign.id
                    }
                }
            case .randomPicker:
                NavigationView {
                    RandomCampaignPickerView2024(campaignChoiceID: self.$selectedCampaignId, allCampaigns: allCampaigns)
                        .navigationTitle("Pick a block!")
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
                    Image("info.button.pixel")
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
                        Image("pixel-refresh")
                            .opacity(isRefreshing ? 0 : 1)
                    }
                }
                .keyboardShortcut("r")
                .disabled(isRefreshing)
            }
        }
        .onOpenURL { url in
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false), components.host == "campaign", let queryComponents = components.queryItems?.reduce(into: [String: String](), { (result, item) in
                result[item.name] = item.value
            }), let id = queryComponents["id"] {
                selectedCampaignId = UUID(uuidString: id)
                showSheet = nil
            }
        }
        .onChange(of: searchText, perform: { value in
            if value.lowercased() == "do a barrel roll" {
                rotationAnimation = false
                withAnimation(.easeInOut(duration: 2.0)) {
                    rotationAnimation = true
                }
            }
        })
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
                            iconsUnlocked = apiCampaign.totalRaisedNumerical >= TLDMilestones.IconsUnlocked
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
                        iconsUnlocked = apiCampaign.totalRaisedNumerical >= TLDMilestones.IconsUnlocked
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
            allCampaigns = sortCampaigns(try await AppDatabase.shared.fetchAllCampaigns().filter { !HIDDEN_CAMPAIGN_IDS.contains($0.id) })
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
