//
//  SampleCampaign.swift
//  SampleCampaign
//
//  Created by David on 25/08/2021.
//

import Foundation

let sampleUser = TiltifyUser(username: "Relay FM", slug: "relay-fm", avatar: nil)

let sampleCampaign = TiltifyWidgetData(from: TiltifyCampaign(publicId: UUID(), avatar: nil, goal: TiltifyAmount(currency: "USD", value: "494840.18"), milestones: [], slug: "relay-st-jude-21", status: "published", team: nil, user: sampleUser, description: ". . .", totalAmountRaised: TiltifyAmount(currency: "USD", value: "494732.32"), name: "Relay FM for St. Jude 2022", originalGoal: TiltifyAmount(currency: "USD", value: "100"), rewards: []))

let sampleCampaignSingleMilestone = TiltifyWidgetData(from: TiltifyCampaign(publicId: UUID(), avatar: nil,goal: TiltifyAmount(currency: "USD", value: "333333.33"), milestones: [TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "10000"), name: "A milestone!", publicId: UUID())], slug: "relay-st-jude-21", status: "published", team: nil, user: sampleUser, description: ". . .", totalAmountRaised: TiltifyAmount(currency: "USD", value: "19065.66"), name: "Relay FM for St. Jude 2022", originalGoal: TiltifyAmount(currency: "USD", value: "100"), rewards: []))


let sampleCampaignTwoMilestones = TiltifyWidgetData(from: TiltifyCampaign(publicId: UUID(), avatar: nil,
                                                                          goal: TiltifyAmount(currency: "USD", value: "404404.40"),
                                                                          milestones: [TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "10000"), name: "A milestone!", publicId: UUID()), TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "100000"), name: "A future milestone!", publicId: UUID())],
                                                                          slug: "relay-st-jude-21",
                                                                          status: "published",
                                                                          team: nil,
                                                                          user: sampleUser, description: ". . .",
                                                                          totalAmountRaised: TiltifyAmount(currency: "USD", value: "122.25"),
                                                                          name: "Relay FM for St. Jude 2022 (a)",
                                                                          originalGoal: TiltifyAmount(currency: "USD", value: "100"), rewards: []   ))

let sampleCampaignThreeMilestones = TiltifyWidgetData(from: TiltifyCampaign(publicId: UUID(), avatar: nil,
                                                                          goal: TiltifyAmount(currency: "USD", value: "333333.33"),
                                                                            milestones: [TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "10000"), name: "A milestone!", publicId: UUID()), TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "100000"), name: "A future milestone!", publicId: UUID()), TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "150000"), name: "A future milestone!", publicId: UUID())],
                                                                          slug: "relay-st-jude-21",
                                                                          status: "published",
                                                                          team: nil,
                                                                            user: sampleUser, description: ". . .",
                                                                          totalAmountRaised: TiltifyAmount(currency: "USD", value: "19065.66"),
                                                                          name: "Relay FM for St. Jude 2022 (b)",
                                                                            originalGoal: TiltifyAmount(currency: "USD", value: "100"), rewards: []))
