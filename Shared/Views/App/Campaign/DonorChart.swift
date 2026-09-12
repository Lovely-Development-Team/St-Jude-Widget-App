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
            .onChange(of: showDonationValues) {
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
