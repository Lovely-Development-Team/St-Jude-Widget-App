//
//  CampaignList.swift
//  St Jude
//
//  Created by Ben Cardy on 18/08/2022.
//

import SwiftUI
import GRDB

enum FundraiserSortOrder: CaseIterable {
    case byName
    case byAmountRaised
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
    
    @State private var fundraiserSortOrder: FundraiserSortOrder = .byName
    
    @ViewBuilder
    func mainProgressBar(value: Float, color: Color) -> some View {
        ProgressBar(value: .constant(value), fillColor: color)
            .frame(height: 15)
            .padding(.bottom, 2)
    }
    
    @ViewBuilder
    func mainAmountRaised(_ value: Text) -> some View {
        value
            .font(.largeTitle)
            .fontWeight(.bold)
            .minimumScaleFactor(0.7)
            .lineLimit(1)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    func mainPercentageReached(_ value: Text) -> some View {
        value
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .opacity(0.8)
    }
    
    var sortedCampaigns: [Campaign] {
        return campaigns.sorted { c1, c2 in
            if c1.user.username == "Relay FM" {
                return true
            }
            if c2.user.username == "Relay FM" {
                return false
            }
            switch fundraiserSortOrder {
            case .byAmountRaised:
                return c1.totalRaised.numericalValue > c2.totalRaised.numericalValue
            case .byGoal:
                return c1.goal.numericalValue > c2.goal.numericalValue
            case .byPercentage:
                return (c1.percentageReached ?? 0) > (c2.percentageReached ?? 0)
            default:
                if c1.name.lowercased() == c2.name.lowercased() {
                    return c1.id.uuidString < c2.id.uuidString
                }
                return c1.name.lowercased() < c2.name.lowercased()
            }
        }
    }
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text(fundraisingEvent?.name ?? "Relay FM for St. Jude 2022")
                        .multilineTextAlignment(.leading)
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 2)
                    Text(fundraisingEvent?.cause.name ?? "St. Jude Children's Research Hospital")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .opacity(0.8)
                        .padding(.bottom, 20)
                    if let fundraisingEvent = fundraisingEvent {
                        if let percentageReached =  fundraisingEvent.percentageReached {
                            mainProgressBar(value: Float(percentageReached), color: fundraisingEvent.colors.highlightColor)
                        }
                        mainAmountRaised(Text(fundraisingEvent.amountRaised.description(showFullCurrencySymbol: false)))
                        if let percentageReachedDesc = fundraisingEvent.percentageReachedDescription {
                            mainPercentageReached(Text("\(percentageReachedDesc) of \(fundraisingEvent.goal.description(showFullCurrencySymbol: false))"))
                        }
                    } else {
                        mainProgressBar(value: 0, color: .accentColor)
                        mainAmountRaised(Text("PLACEHOLDER"))
                            .redacted(reason: .placeholder)
                        mainPercentageReached(Text("PLACEHOLDER"))
                            .redacted(reason: .placeholder)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(fundraisingEvent?.colors.backgroundColor ?? Color(red: 13 / 255, green: 39 / 255, blue: 83 / 255))
                .cornerRadius(10)
                .padding()
                
                Link("Visit the fundraiser!", destination: URL(string: "https://stjude.org/relay")!)
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
                                fundraiserSortOrder = order
                            }) {
                                Label("Sort by \(order.description)", systemImage: fundraiserSortOrder == order ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                .padding(.horizontal)
                
                if campaigns.count != 0 {
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: .infinity), alignment: .top)], spacing: 0) {
                        
                        ForEach(sortedCampaigns, id: \.id) { campaign in
                            NavigationLink(destination: CampaignView(initialCampaign: campaign)) {
                                FundraiserListItem(campaign: campaign, sortOrder: fundraiserSortOrder)
                            }
                            .padding(.top)
                        }
                        
                    }
                    .padding(.horizontal)
                    
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
        .onAppear {
            fundraisingEventCancellable = AppDatabase.shared.start(observation: fundraisingEventObservation) { error in
                dataLogger.error("Error observing stored fundraiser: \(error.localizedDescription)")
            } onChange: { event in
                fundraisingEvent = event
                // When changes happen in quick succession, we don't want to concurrently fetch the same data
                fetchCampaignsTask?.cancel()
                fetchCampaignsTask = Task {
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
            
            Task {
                await refresh()
            }
        }
        .navigationTitle("Relay FM for St. Jude 2022")
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
            dataLogger.error("Updating stord fundraiser failed: \(error.localizedDescription)")
        }
        
        campaigns = await response.data.fundraisingEvent.publishedCampaigns.edges.asyncMap { apiCampaign in
            let storedCampaign: Campaign?
            do {
                storedCampaign = try await AppDatabase.shared.fetchCampaign(with: apiCampaign.node.publicId)
            } catch {
                return Campaign(from: apiCampaign.node, fundraiserId: apiEvent.id)
            }
            
            let campaign: Campaign
            do {
                // Same as above. In this case, we *really* don't want to update every campaign unless they've changed
                if let storedCampaign = storedCampaign {
                    campaign = storedCampaign.updated(fromCauseCampaign: apiCampaign.node, fundraiserId: apiEvent.id)
                    if try await AppDatabase.shared.updateCampaign(campaign, changesFrom: storedCampaign) {
                        dataLogger.info("Updated campaign '\(campaign.name)' (id: \(campaign.id)")
                    }
                    return campaign
                } else {
                    campaign = Campaign(from: apiCampaign.node, fundraiserId: apiEvent.id)
                    return try await AppDatabase.shared.saveCampaign(campaign)
                }
            } catch {
                dataLogger.error("Failed to save campaign: \(error.localizedDescription)")
                return campaign
            }
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
