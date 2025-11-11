//
//  DonorChart.swift
//  St Jude
//
//  Created by Ben Cardy on 17/09/2022.
//

import SwiftUI
import Charts

struct DonorChartValue: Identifiable {
    let id: UUID
    let amount: Double
    let date: Date
}

struct DonorChart: View {
    
    #if !os(macOS)
    let haptics = UIImpactFeedbackGenerator(style: .light)
    #endif
    
    let donations: [TiltifyDonorsForCampaignDonation]
    let total: TiltifyAmount
    
    @State private var maxValue: Double = 0
    @State private var minValue: Double = 0
    @State private var showDonationValues: Bool = false
    @State private var chartValues: [DonorChartValue] = []
    
    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(chartValues) { donation in
                    if showDonationValues {
                        BarMark(
                            x: .value("Date", donation.date),
                            y: .value("Donation Amount", donation.amount),
                            width: 2
                        )
                    } else {
                        LineMark(
                            x: .value("Date", donation.date),
                            y: .value("Donation Amount", donation.amount)
                        )
                    }
                }
            }
            .chartYScale(domain: ClosedRange(uncheckedBounds: (minValue, maxValue)))
            .chartYAxis(.hidden)
            //            .chartXAxis(.hidden)
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .onTapGesture {
                showDonationValues.toggle()
                #if !os(macOS)
                haptics.impactOccurred()
                #endif
            }
            .onAppear {
                calculateChartValues()
            }
            .onChange(of: showDonationValues) { newValue in
                calculateChartValues()
            }
        } else {
            Text("Sorry!")
        }
    }
    
    func calculateChartValues() {
        let reversedDonations = donations.filter {
            $0.donationDate != nil
        }
        if showDonationValues {
            chartValues = reversedDonations.map { DonorChartValue(id: $0.id, amount: $0.amount.numericalValue, date: $0.donationDate!)}
            maxValue = donations.map { $0.amount.numericalValue }.max() ?? total.numericalValue
            minValue = 0
        } else {
            var runningTotal = total.numericalValue
            var runningAmounts: [DonorChartValue] = []
            for donation in reversedDonations {
                runningAmounts.append(
                    DonorChartValue(id: donation.id, amount: runningTotal, date: donation.donationDate!)
                )
                runningTotal = runningTotal - donation.amount.numericalValue
            }
            chartValues = runningAmounts.reversed()
            maxValue = total.numericalValue
            minValue = chartValues[0].amount
        }
    }
    
}

struct DonorChart_Previews: PreviewProvider {
    static var previews: some View {
        DonorChart(donations: [St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Jorge A Hernandez", donorComment: nil, incentives: [], completedAt: "2022-09-17T06:31:42.164219Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Anonymous", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T05:55:26.852399Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("500.00")), donorName: "Anonymous", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T05:35:21.583257Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("20")), donorName: "M. Johnson", donorComment: nil, incentives: [], completedAt: "2022-09-17T05:13:28.955353Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Anonymous", donorComment: nil, incentives: [], completedAt: "2022-09-17T05:00:45.705512Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("700.00")), donorName: "Jason and Amy Hollowed", donorComment: Optional("In memory of Jaxson, who would’ve been a senior in high school this year."), incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T04:52:21.044504Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("150.00")), donorName: "Jirah Cox", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T04:44:15.088562Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("60.00")), donorName: "Hugo Firth", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T03:37:29.600621Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Anonymous", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T03:18:53.618959Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("5.00")), donorName: "Jung", donorComment: nil, incentives: [], completedAt: "2022-09-17T03:07:37.454497Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Ben Harrison", donorComment: nil, incentives: [], completedAt: "2022-09-17T03:01:33.782535Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("25.00")), donorName: "Ken Ohrtman", donorComment: nil, incentives: [], completedAt: "2022-09-17T02:57:28.582118Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Abram", donorComment: Optional("ATP!"), incentives: [], completedAt: "2022-09-17T02:53:50.890245Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Glennhk", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T02:52:12.648653Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("1500.00")), donorName: "JB", donorComment: Optional("Thank you to Stephen and Myke for their efforts with this campaign, and a podcast network where shenanigans and banter are mixed with thoughtfulness and smart commentary."), incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T02:45:38.674766Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Anonymous", donorComment: Optional("#ATP"), incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T02:31:51.421194Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Mitch", donorComment: Optional("For The Kids FTK"), incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T02:28:22.931174Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Bryn Behrenshausen", donorComment: nil, incentives: [], completedAt: "2022-09-17T02:25:23.580353Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("20")), donorName: "Anonymous", donorComment: nil, incentives: [], completedAt: "2022-09-17T02:13:59.934213Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Timothy J Rousseau", donorComment: nil, incentives: [], completedAt: "2022-09-17T02:11:47.684381Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "George", donorComment: nil, incentives: [], completedAt: "2022-09-17T01:51:24.026506Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("61.00")), donorName: "P Beatty", donorComment: Optional("#caseycheated"), incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T01:44:55.580997Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("50.00")), donorName: "Tom Pagano", donorComment: nil, incentives: [], completedAt: "2022-09-17T01:44:32.396984Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("200.00")), donorName: "dgreene196", donorComment: nil, incentives: [], completedAt: "2022-09-17T01:24:22.609643Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Kerry Nelson", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T01:11:18.194700Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("250.00")), donorName: "Anonymous", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T01:11:08.123527Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("250.00")), donorName: "April & William Brendel", donorComment: Optional("Thanks for doing this, Relay and ATP ❤️"), incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T00:57:58.637920Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Anonymous", donorComment: Optional("<3"), incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T00:53:58.288039Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("20")), donorName: "Anonymous", donorComment: nil, incentives: [], completedAt: "2022-09-17T00:51:28.815833Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("25.00")), donorName: "Anonymous", donorComment: nil, incentives: [], completedAt: "2022-09-17T00:45:30.913883Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("180.00")), donorName: "jburka", donorComment: nil, incentives: [], completedAt: "2022-09-17T00:45:28.470151Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("109.24")), donorName: "Chek", donorComment: Optional("Getting married on 9/24... f*uck cancer!"), incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T00:40:40.051438Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("25.00")), donorName: "Nicolle Hahn", donorComment: Optional("Blessings from a cancer survivor."), incentives: [], completedAt: "2022-09-17T00:23:41.939046Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("500.00")), donorName: "Nancy & John Kauk", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T00:16:56.795170Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("50.00")), donorName: "Anonymous", donorComment: nil, incentives: [], completedAt: "2022-09-17T00:13:47.784547Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Anonymous", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T00:10:13.461096Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("1000.00")), donorName: "Jonathan", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T00:06:37.829418Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("60.00")), donorName: "Tunkle Casts", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T00:05:05.672578Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("60.00")), donorName: "EVB BALLOOM BROS 🎈🎈🎈", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T00:03:30.873709Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("50.00")), donorName: "Christopher", donorComment: nil, incentives: [], completedAt: "2022-09-17T00:03:26.565528Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Kennymati", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T00:03:19.299629Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Alfie Scenna", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-17T00:02:02.215566Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("314.15")), donorName: "The Bordens Family", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-16T23:59:29.999444Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("60.00")), donorName: "Dan Schwartz", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-16T23:54:07.543707Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("60.00")), donorName: "Ben Lozano", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-16T23:51:10.909490Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Anonymous", donorComment: nil, incentives: [], completedAt: "2022-09-16T23:47:48.228566Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("50.00")), donorName: "Anonymous", donorComment: nil, incentives: [], completedAt: "2022-09-16T23:47:30.026778Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("20")), donorName: "nougatmachine", donorComment: nil, incentives: [], completedAt: "2022-09-16T23:46:42.263786Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("100.00")), donorName: "Techtrocity", donorComment: nil, incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-16T23:44:53.850565Z"), St_Jude.TiltifyDonorsForCampaignDonation(id: UUID(), amount: St_Jude.TiltifyAmount(currency: "USD", value: Optional("512.00")), donorName: "Deborah Abel & Mark Barr", donorComment: Optional("$1 for each of Stephen\'s pixels!"), incentives: [St_Jude.TiltifyDonorsForCampaignDonationIncentive(type: "reward")], completedAt: "2022-09-16T23:41:07.921271Z")],
                   total: TiltifyAmount(currency: "USD", value: "313560.45"))
        .frame(height: 100)
        .padding()
    }
}
