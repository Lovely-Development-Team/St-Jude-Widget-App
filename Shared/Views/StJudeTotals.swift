//
//  StJudeTotals.swift
//  St Jude
//
//  Created by Ben Cardy on 03/09/2023.
//

import SwiftUI
import Charts

struct FundraisingDataPoint: Identifiable {
    var id: String { year }
    let year: String
    let goal: Double
    let total: Double
}

let PREVIOUS_TOTALS_RAISED: [FundraisingDataPoint] = [
    .init(year: "2019", goal: 75000, total: 315939.56),
    .init(year: "2020", goal: 315000, total: 484000),
    .init(year: "2021", goal: 333333.33, total: 701220.26),
    .init(year: "2022", goal: 494840.18, total: 706397.1),
]

func getShortNumber(from number: Double) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.maximumFractionDigits = 0
    return numberFormatter.string(from: number as NSNumber) ?? "\(number)"
}

struct StJudeTotals: View {

    #if !os(macOS)
    let haptics = UIImpactFeedbackGenerator(style: .light)
    #endif
    
    var currentTotal: Double = 293000
    
    @State private var lineGraph: Bool = false
    
    var totalRaised: [FundraisingDataPoint] {
        PREVIOUS_TOTALS_RAISED + [
            .init(year: "2023", goal: 293000, total: currentTotal)
        ]
    }
    
    var axisMarks: [Double] {
        let maxTotal = totalRaised.map { $0.total }.max() ?? 10
        var marks: [Double] = []
        var count: Int = 0
        repeat {
            marks.append(250000 * Double(count))
            count += 1
        } while marks.last ?? 0 < maxTotal
        return marks
    }
    
    var body: some View {
        Chart(totalRaised) { total in
            
            PointMark(x: .value("Year", total.year), y: .value("USD", total.goal))
                .foregroundStyle(Color.brandPurple)
                .opacity(0.75)
                .symbolSize(lineGraph ? 50 : 0)
            RectangleMark(x: .value("Year", total.year), y: .value("USD", total.goal), width: .ratio(lineGraph ? 0.2 : 0), height: lineGraph ? 1 : 0)
                .foregroundStyle(Color.brandPurple)
                .opacity(1)
            LineMark(x: .value("Year", total.year), y: .value("USD", lineGraph ? total.total : 0))
                .opacity(lineGraph ? 1 : 0)
                .foregroundStyle(Color.accentColor.opacity(total.year == "2023" ? 1 : 0.5))
            PointMark(x: .value("Year", total.year), y: .value("USD", lineGraph ? total.total : 0))
                .symbolSize(lineGraph ? 50 : 0)
            
            BarMark(x: .value("Year", total.year), y: .value("USD", lineGraph ? 0 : total.total), width: .ratio(0.6))
                .foregroundStyle(Color.accentColor.opacity(total.year == "2023" ? 1 : 0.5))
            RectangleMark(x: .value("Year", total.year), y: .value("USD", total.goal), width: .ratio(lineGraph ? 0 : 0.75), height: 1)
                .foregroundStyle(Color.brandPurple)
                .opacity(lineGraph ? 0 : 1)
            
        }
        .chartYAxis {
            AxisMarks(
                values: axisMarks
            ) { value in
                if let val = value.as(Double.self) {
                    let shortVal = val / 1000
                    AxisValueLabel("$\(getShortNumber(from: shortVal))k")
                    AxisGridLine()
                }
            }
        }
        .onTapGesture {
            withAnimation {
                lineGraph.toggle()
            }
            #if !os(macOS)
            haptics.impactOccurred()
            #endif
        }
    }
}

#Preview {
    ScrollView {
        StJudeTotals()
            .frame(height: 150)
            .padding()
    }
}
