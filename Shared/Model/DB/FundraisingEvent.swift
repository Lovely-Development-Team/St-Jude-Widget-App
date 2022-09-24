//
//  FundraisingEvent.swift
//  St Jude
//
//  Created by David Stephens on 21/08/2022.
//

import Foundation
import GRDB

struct FundraisingEvent: Identifiable, Hashable {
    var id: UUID
    let name: String
    let slug: String
    private let amountRaisedCurrency: String
    private let amountRaisedValue: String?
    var amountRaised: TiltifyAmount {
        TiltifyAmount(currency: amountRaisedCurrency, value: amountRaisedValue)
    }
    let colors: TiltifyColors
    let description: String
    private let goalCurrency: String
    private let goalValue: String?
    var goal: TiltifyAmount {
        TiltifyAmount(currency: goalCurrency, value: goalValue)
    }
    private let causePublicId: UUID
    private let causeName: String
    private let causeSlug: String
    var cause: TiltifyCause {
        TiltifyCause(publicId: causePublicId, name: causeName, slug: causeSlug)
    }
    
    var percentageReached: Double? {
        return calcPercentage(goal: goal.value ?? "0", total: amountRaised.value ?? "0")
    }
    
    var percentageReachedDescription: String? {
        guard let percentageReached = percentageReached else {
            return nil
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.roundingMode = .down
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: percentageReached as NSNumber)
    }
}

extension TiltifyColors: DatabaseValueConvertible {}

extension FundraisingEvent: Codable, FetchableRecord, MutablePersistableRecord {
    fileprivate enum Columns {
        static let publicId = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let slug = Column(CodingKeys.slug)
        static let amountRaisedCurrency = Column(CodingKeys.amountRaisedCurrency)
        static let amountRaisedValue = Column(CodingKeys.amountRaisedValue)
        static let colors = Column(CodingKeys.colors)
        static let description = Column(CodingKeys.description)
        static let goalCurrency = Column(CodingKeys.goalCurrency)
        static let goalValue = Column(CodingKeys.goalValue)
        static let causeName = Column(CodingKeys.causeName)
        static let causeSlug = Column(CodingKeys.causeSlug)
    }
    
    static let campaigns = hasMany(Campaign.self)
    
    var campaigns: QueryInterfaceRequest<Campaign> {
        request(for: FundraisingEvent.campaigns)
    }
}

extension DerivableRequest where RowDecoder == FundraisingEvent {
    /// Order authors by name, in a localized case-insensitive fashion
    func orderByAmountRaised() -> Self {
        let name = FundraisingEvent.Columns.amountRaisedValue
        return order(name.collating(.localizedCaseInsensitiveCompare))
    }
    
    /// Filters authors from a country
    func filter(slug: String, causeSlug: String) -> Self {
        filter(FundraisingEvent.Columns.slug == slug && FundraisingEvent.Columns.causeSlug == causeSlug)
    }
}

extension FundraisingEvent {
    init(from apiData: TiltifyCauseData) {
        self.id = apiData.fundraisingEvent.publicId
        self.name = apiData.fundraisingEvent.name
        self.slug = apiData.fundraisingEvent.slug
        self.amountRaisedCurrency = apiData.fundraisingEvent.amountRaised.currency
        self.amountRaisedValue = apiData.fundraisingEvent.amountRaised.value
        self.colors = apiData.fundraisingEvent.colors
        self.description = apiData.fundraisingEvent.description
        self.goalCurrency = apiData.fundraisingEvent.goal.currency
        self.goalValue = apiData.fundraisingEvent.goal.value
        self.causePublicId = apiData.cause.publicId
        self.causeName = apiData.cause.name
        self.causeSlug = apiData.cause.slug
    }
}

