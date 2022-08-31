//
//  CampaignList.swift
//  St Jude
//
//  Created by Ben Cardy on 18/08/2022.
//

import SwiftUI
import GRDB

enum FundraiserSortOrder: Int, CaseIterable {
    case byStarred
    case byName
    case byAmountRaised
    case byGoal
    case byPercentage
    
    var description: String {
        switch self {
        case .byStarred:
            return "Starred"
        case .byName:
            return "Name"
        case .byAmountRaised:
            return "Amount Raised"
        case .byGoal:
            return "Goal"
        case .byPercentage:
            return "Percentage"
        }
    }
    
}

struct CampaignList: View {
    @State private var fundraisingEvent: FundraisingEvent? = nil
    @State private var campaigns: [Campaign] = []
    @StateObject private var apiClient = ApiClient.shared
    
    @State private var fundraisingEventObservation = AppDatabase.shared.observeRelayFundraisingEventObservation()
    @State private var fundraisingEventCancellable: DatabaseCancellable?
    @State private var fetchCampaignsTask: Task<(), Never>?
    
    @State private var fundraiserSortOrder: FundraiserSortOrder = .byStarred
    @State private var compactListMode: Bool = false
    @State private var selectedCampaignId: UUID? = nil
    @State private var showEasterEggSheet: Bool = false
    
    func compareNames(c1: Campaign, c2: Campaign) -> Bool {
        if c1.name.lowercased() == c2.name.lowercased() {
            return c1.id.uuidString < c2.id.uuidString
        }
        return c1.name.lowercased() < c2.name.lowercased()
    }
    
    var sortedCampaigns: [Campaign] {
        return campaigns.sorted { c1, c2 in
            switch fundraiserSortOrder {
            case .byAmountRaised:
                let v1 = c1.totalRaised.numericalValue
                let v2 = c2.totalRaised.numericalValue
                if v1 == v2 {
                    return compareNames(c1: c1, c2: c2)
                }
                return v1 > v2
            case .byGoal:
                let v1 = c1.goal.numericalValue
                let v2 = c2.goal.numericalValue
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
            case .byStarred:
                if c1.isStarred && !c2.isStarred {
                    return true
                }
                if c2.isStarred && !c1.isStarred {
                    return false
                }
                return compareNames(c1: c1, c2: c2)
            default:
                return compareNames(c1: c1, c2: c2)
            }
        }
    }
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 0) {
                
                if let fundraisingEvent = fundraisingEvent {
                    NavigationLink(destination: CampaignView(fundraisingEvent: fundraisingEvent), tag: fundraisingEvent.id, selection: $selectedCampaignId) {
                        FundraiserCardView(fundraisingEvent: fundraisingEvent, showDisclosureIndicator: true, showShareSheet: .constant(false))
                            .padding()
                    }
                } else {
                    FundraiserCardView(fundraisingEvent: fundraisingEvent, showDisclosureIndicator: false, showShareSheet: .constant(false))
                        .padding()
                }
                
                Link("Visit the event!", destination: URL(string: "https://stjude.org/relay")!)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(10)
                    .padding(.horizontal, 20)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .padding(.bottom)
                
                HStack {
                    Text("Fundraisers")
                        .font(.title)
                        .fontWeight(.bold)
                    if campaigns.count != 0 {
                        Text("\(campaigns.count)")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Color.secondarySystemBackground
                                .cornerRadius(15)
                        )
                    }
                    Spacer()
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
                }
                .padding(.horizontal)
                
                if campaigns.count != 0 {
                    
                    if selectedCampaignId != nil {
                        /// In order to open a selected campaign when a widget is tapped, the corresponding
                        /// NavigationLink needs to be loaded. That  isn't guaranteed when they are presented
                        /// in a Lazy grid as below, so we create a bunch of empty/invisible NavigationLinks to
                        /// trigger on the widget tap instead
                        ForEach(sortedCampaigns, id: \.id) { campaign in
                            NavigationLink(destination: CampaignView(initialCampaign: campaign), tag: campaign.id, selection: $selectedCampaignId) {
                                EmptyView()
                            }
                        }
                    }
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: .infinity), alignment: .top)], spacing: 0) {
                        
                        ForEach(sortedCampaigns, id: \.id) { campaign in
                            NavigationLink(destination: CampaignView(initialCampaign: campaign)) {
                                FundraiserListItem(campaign: campaign, sortOrder: fundraiserSortOrder, compact: compactListMode, showShareSheet: .constant(false))
                            }
                            .padding(.top)
                        }
                        
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        showEasterEggSheet = true
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
                    
                    ProgressView()
                        .padding(.top, 40)
                        .padding(.bottom, 10)
                    Text("Loading ...")
                        .padding(.bottom, 40)
                    
                }
            }
            .padding(.bottom)
        }
        .refreshable {
            await refresh()
        }
        .onChange(of: fundraiserSortOrder) { newValue in
            UserDefaults.shared.campaignListSortOrder = newValue
        }
        .onChange(of: compactListMode) { newValue in
            UserDefaults.shared.campaignListCompactView = newValue
        }
        .onAppear {
            fundraiserSortOrder = UserDefaults.shared.campaignListSortOrder
            compactListMode = UserDefaults.shared.campaignListCompactView
            
            fundraisingEventCancellable = AppDatabase.shared.start(observation: fundraisingEventObservation) { error in
                dataLogger.error("Error observing stored fundraiser: \(error.localizedDescription)")
            } onChange: { event in
                fundraisingEvent = event
                // When changes happen in quick succession, we don't want to concurrently fetch the same data
                fetchCampaignsTask?.cancel()
                fetchCampaignsTask = Task {
                    await fetch()
                }
            }
            
            Task {
                await refresh()
            }
        }
        .sheet(isPresented: $showEasterEggSheet) {
            EasterEggView()
                .background(Color.secondarySystemBackground)
                .edgesIgnoringSafeArea(.all)
        }
        .navigationTitle("Relay FM for St. Jude 2022")
        .onOpenURL { url in
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false), components.host == "campaign", let queryComponents = components.queryItems?.reduce(into: [String: String](), { (result, item) in
                result[item.name] = item.value
            }), let id = queryComponents["id"] {
                selectedCampaignId = UUID(uuidString: id)
            }
        }
    }
    
    func refresh() async {
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
            if let existingEvent = fundraisingEvent {
                fundraisingEvent = apiEvent
                if try await AppDatabase.shared.updateFundraisingEvent(apiEvent, changesFrom: existingEvent) {
                    dataLogger.info("Updated fundraising event '\(apiEvent.name)' (id: \(apiEvent.id)")
                }
            } else {
                fundraisingEvent = try! await AppDatabase.shared.saveFundraisingEvent(apiEvent)
            }
        } catch {
            dataLogger.error("Updating stored fundraiser failed: \(error.localizedDescription)")
        }
        
        if let fundraisingEvent = fundraisingEvent {
            var apiCampaigns: [UUID: Campaign] = response.data.fundraisingEvent.publishedCampaigns.edges.reduce(into: [:]) { partialResult, campaign in
                partialResult.updateValue(Campaign(from: campaign.node, fundraiserId: apiEvent.id), forKey: campaign.node.publicId)
            }
            do {
                // For each campaign from the database...
                for dbCampaign in try await AppDatabase.shared.fetchAllCampaigns(for: fundraisingEvent) {
                    if let apiCampaign = apiCampaigns[dbCampaign.id] {
                        apiCampaigns.removeValue(forKey: dbCampaign.id)
                        // Update it from the API if it exists...
                        let updateCampaign = dbCampaign.isStarred ? apiCampaign.setStar(to: true) : apiCampaign
                        do {
                            dataLogger.notice("Updating \(apiCampaign.title) - \(apiCampaign.totalRaised.description(showFullCurrencySymbol: false))")
                            try await AppDatabase.shared.updateCampaign(updateCampaign, changesFrom: dbCampaign)
                        } catch {
                            dataLogger.error("Failed to update campaign: \(updateCampaign.id) \(updateCampaign.name): \(error.localizedDescription)")
                        }
                    } else {
                        // Remove it from the database if it doesn't...
                        do {
                            try await AppDatabase.shared.deleteCampaign(dbCampaign)
                        } catch {
                            dataLogger.error("Failed to delete Campaign \(dbCampaign.id) \(dbCampaign.name): \(error.localizedDescription)")
                        }
                    }
                }
                // For each new campaign in the API, save it to the database
                for apiCampaign in apiCampaigns.values {
                    do {
                        try await AppDatabase.shared.saveCampaign(apiCampaign)
                    } catch {
                        dataLogger.error("Failed to save Campaign \(apiCampaign.id) \(apiCampaign.name): \(error.localizedDescription)")
                    }
                }
            } catch {
                dataLogger.error("Failed to fetch stored campaigns: \(error.localizedDescription)")
            }
        }
        
        await fetch()
        
    }
    
    func fetch() async {
        do {
            if let fundraisingEvent = fundraisingEvent {
                dataLogger.notice("Fetched stored fundraiser")
                try Task.checkCancellation()
                campaigns = try await AppDatabase.shared.fetchAllCampaigns(for: fundraisingEvent)
                dataLogger.notice("Fetched stored campaigns")
            }
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
