//
//  EasterEggDirectory.swift
//  St Jude
//
//  Created by Ben Cardy on 03/09/2022.
//

import SwiftUI
import Foundation

struct CampaignViewEasterEgg {
    let left: AnyView?
    let right: AnyView?
}

let mykeImages = ["myke_dance_01", "myke_dance_02", "myke_dance_03", "myke_dance_04", "myke_dance_05", "myke_dance_06", "myke_dance_07", "myke_dance_08", "myke_dance_09", "myke_dance_10"]
let stephenImages = ["stephen_swing_01", "stephen_swing_02", "stephen_swing_03", "stephen_swing_04", "stephen_swing_05", "stephen_swing_06", "stephen_swing_07", "stephen_swing_08", "stephen_swing_09", "stephen_swing_10"]

let xRayManAndMrYellow = CampaignViewEasterEgg(
    left: AnyView(
        AnimatedImage(imageNames: mykeImages, timerLoops: 70)
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .offset(x: -18)
            .offset(y: 5)
    ),
    right: AnyView(
        AnimatedImage(imageNames: stephenImages, interval: 0.1)
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .offset(x: 15)
            .offset(y: 5)
    )
)


let easterEggDirectory: [UUID: CampaignViewEasterEgg] = [:]
    // Tildy
//    TLD_CAMPAIGN: CampaignViewEasterEgg(
//        left: nil,
//        right: AnyView(
//            Image("Team_Logo_F")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(height: 80)
//                .rotationEffect(.degrees(-30))
//                .offset(x: 40)
//                .offset(y: 5)
//                .tapToWobble(anchor: .bottomTrailing)
//        )
//    ),
    // Kathy
//    UUID(uuidString: "96DA85C6-8E24-4757-811B-F8CDE9EB402E")!: CampaignViewEasterEgg(
//        left: AnyView(UnicornView()),
//        right: AnyView(
//            Image("unicorn-left")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(height: 80)
//                .rotationEffect(.degrees(15))
//                .tapToWobble(anchor: .center)
//                .offset(x: 35)
//                .offset(y: 5)
//        )
//    ),
    // Relay
//    RELAY_FUNDRAISER_ID: xRayManAndMrYellow,
    // Main Campaign
//    UUID(uuidString: "8F4E607C-A117-4C11-9172-23D19C1BE96C")!: xRayManAndMrYellow,
    // Viticci
//    UUID(uuidString: "A4C28DED-BDFB-4CAA-8CA5-3D04447FF8CB")!: CampaignViewEasterEgg(
//        left: AnyView(
//            Image("weirdfish")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 60, height: 60)
//                .rotationEffect(.degrees(-30))
//                .offset(x: -30)
//                .offset(y: 5)
//                .tapToWobble(anchor: .center)
//        ),
//        right: nil
//    ),
    // MVO
//    UUID(uuidString: "1DB7C0E6-63ED-4E50-B876-05E630C941CF")!: CampaignViewEasterEgg(
//        left: AnyView(
//            Image("jonycube")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 80, height: 80)
//                .rotationEffect(.degrees(-20))
//                .tapToWobble(degrees: -720, anchor: .center)
//                .offset(x: -40)
//                .offset(y: 5)
//        ),
//        right: nil
//    ),
//    UUID(uuidString: "583538BF-DCB3-4C7E-A5FA-7EE82AA4EF5D")!: CampaignViewEasterEgg(left: AnyView(
//        Image(.officialHistorianLogo)
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 80, height: 80)
//            .tapToWobble(anchor: .center)
//            .offset(x: -10)
//            .offset(y: 5)
//        ),
//        right: nil
//    )
//]

var konamiCodeEasterEggEnabled: Bool {
    // TODO: Update this to check the TLD fundraiser for the dollar amount we want
    return true
}

var konamiCodeEasterEggDollarThreshold: Double = 1000000
