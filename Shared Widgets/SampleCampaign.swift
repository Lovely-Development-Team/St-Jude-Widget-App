//
//  SampleCampaign.swift
//  SampleCampaign
//
//  Created by David on 25/08/2021.
//

import Foundation

let sampleCampaign = TiltifyWidgetData(from: TiltifyCampaign(publicId: "relay", avatar: nil, goal: TiltifyAmount(currency: "USD", value: "333333.33"), milestones: [], slug: "relay-st-jude-21", status: "published", team: nil, description: ". . .", totalAmountRaised: TiltifyAmount(currency: "USD", value: "19065.66"), name: "Relay FM for St. Jude 2022", originalGoal: TiltifyAmount(currency: "USD", value: "100"), rewards: []))

let sampleCampaignSingleMilestone = TiltifyWidgetData(from: TiltifyCampaign(publicId: "relay", avatar: nil,goal: TiltifyAmount(currency: "USD", value: "333333.33"), milestones: [TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "10000"), id: 1, name: "A milestone!")], slug: "relay-st-jude-21", status: "published", team: nil, description: ". . .", totalAmountRaised: TiltifyAmount(currency: "USD", value: "19065.66"), name: "Relay FM for St. Jude 2022", originalGoal: TiltifyAmount(currency: "USD", value: "100"), rewards: []))


let sampleCampaignTwoMilestones = TiltifyWidgetData(from: TiltifyCampaign(publicId: "relay", avatar: nil,
                                                                          goal: TiltifyAmount(currency: "USD", value: "404404.40"),
                                                                          milestones: [TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "10000"), id: 1, name: "A milestone!"), TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "100000"), id: 1, name: "A future milestone!")],
                                                                          slug: "relay-st-jude-21",
                                                                          status: "published",
                                                                          team: nil,
                                                                          description: ". . .",
                                                                          totalAmountRaised: TiltifyAmount(currency: "USD", value: "122.25"),
                                                                          name: "Relay FM for St. Jude 2022 (a)",
                                                                          originalGoal: TiltifyAmount(currency: "USD", value: "100"), rewards: []   ))

let sampleCampaignThreeMilestones = TiltifyWidgetData(from: TiltifyCampaign(publicId: "relay", avatar: nil,
                                                                          goal: TiltifyAmount(currency: "USD", value: "333333.33"),
                                                                          milestones: [TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "10000"), id: 1, name: "A milestone!"), TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "100000"), id: 1, name: "A future milestone!"), TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "150000"), id: 1, name: "A future milestone!")],
                                                                          slug: "relay-st-jude-21",
                                                                          status: "published",
                                                                          team: nil,
                                                                          description: ". . .",
                                                                          totalAmountRaised: TiltifyAmount(currency: "USD", value: "19065.66"),
                                                                          name: "Relay FM for St. Jude 2022 (b)",
                                                                            originalGoal: TiltifyAmount(currency: "USD", value: "100"), rewards: []))
