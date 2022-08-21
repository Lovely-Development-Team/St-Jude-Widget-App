//
//  SwiftUIView.swift
//  St Jude
//
//  Created by Tony Scida on 8/20/22.
//

import SwiftUI

struct MainCampaign: View {
    var causeData: TiltifyCauseData
    init(_ causeData: TiltifyCauseData) {
        self.causeData = causeData
    }
    
    var body: some View {
            VStack(spacing: 0) {
                    Text(causeData.cause.name)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .opacity(0.8)
                        .padding(.bottom, 2)
                Text(causeData.fundraisingEvent.name)
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)
                if let percentageReached =  causeData.fundraisingEvent.percentageReached {
                    ProgressBar(value: .constant(Float(percentageReached)), fillColor: causeData.fundraisingEvent.colors.highlightColor)
                        .frame(height: 15)
                        .padding(.bottom, 2)
                }
                Text(causeData.fundraisingEvent.amountRaised.description(showFullCurrencySymbol: false))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                if let percentageReachedDesc = causeData.fundraisingEvent.percentageReachedDescription {
                    Text("\(percentageReachedDesc) of \(causeData.fundraisingEvent.goal.description(showFullCurrencySymbol: false))")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .opacity(0.8)
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(causeData.fundraisingEvent.colors.backgroundColor)
            .cornerRadius(10)
            .padding()
       
    }
    
}

