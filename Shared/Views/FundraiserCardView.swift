//
//  FundraiserCardView.swift
//  St Jude
//
//  Created by Ben Cardy on 29/08/2022.
//

import SwiftUI

struct FundraiserCardView: View {
    
    let fundraisingEvent: FundraisingEvent?
    let showDisclosureIndicator: Bool
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(fundraisingEvent?.name ?? "Relay FM for St. Jude 2022")
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 2)
                
                if showDisclosureIndicator {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .opacity(0.8)
                }
            }
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
    }
}
