//
//  LockScreenCircularView.swift
//  St Jude
//
//  Created by Ben Cardy on 04/09/2022.
//

import SwiftUI

struct LockScreenCircularView: View {
    
    let campaign: TiltifyWidgetData
    var shouldShowGoalPercentage: Bool = false
    
    var body: some View {
        ZStack {
            ProgressBar(value: .constant(Float(campaign.percentageReached ?? 0)), fillColor: .white, circularShape: true, circleStrokeWidth: 6)
            if shouldShowGoalPercentage {
                if campaign.percentageReached ?? 0 >= 1 {
                    Image(systemName: "party.popper.fill")
                } else {
                    Text(campaign.shortPercentageReachedDescription ?? "0%")
                        .font(.system(.headline, design: .rounded))
                }
            }
                    VStack {
                        Spacer()
                        Image(systemName: "dollarsign")
                            .font(.system(.caption, design: .rounded))
//                        Image("l2culogosvg")
//                            .renderingMode(.template)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .foregroundColor(.secondary)
//                            .frame(height: 15)
//                            .accessibility(hidden: true)
                    }
        }
    }
}

struct LockScreenCircularView_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenCircularView(campaign: sampleCampaign)
    }
}
