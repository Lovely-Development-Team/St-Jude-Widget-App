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


let xRayManAndMrYellow = CampaignViewEasterEgg(
    left: AnyView(
        Image("XRayMan")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .offset(x: -18)
            .offset(y: 5)
            .tapToWobble(degrees: 5, anchor: .bottom)
        ),
    right:
        AnyView(
            Image("MrYellow")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .offset(x: 15)
                .offset(y: 5)
                .tapToWobble(anchor: .bottom)
        )
)


let easterEggDirectory: [UUID: CampaignViewEasterEgg] = [
    // Tildy
    UUID(uuidString: "55F13472-5101-4490-ADA2-F0C995989672")!: CampaignViewEasterEgg(
        left: nil,
        right:
            AnyView(
                Image("Team_Logo_F")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                    .rotationEffect(.degrees(-30))
                    .offset(x: 40)
                    .offset(y: 5)
                    .tapToWobble(anchor: .bottomTrailing)
            )
    ),
    // Kathy
    UUID(uuidString: "DA41C497-DA79-4586-A802-03D0FB058F84")!: CampaignViewEasterEgg(
        left: nil,
        right:
            AnyView(
                Image("unicorn")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                    .offset(x: 40)
                    .offset(y: 5)
                    .tapToWobble()
            )
    ),
    // Relay
    UUID(uuidString: "8A17EE82-B90A-4ABA-A22F-E8CC7E8CF410")!: xRayManAndMrYellow,
    // Main Campaign
    UUID(uuidString: "8F4E607C-A117-4C11-9172-23D19C1BE96C")!: xRayManAndMrYellow,
]
