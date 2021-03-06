//
//  SampleCampaign.swift
//  SampleCampaign
//
//  Created by David on 25/08/2021.
//

import Foundation

let sampleCampaign = TiltifyWidgetData(from: TiltifyCampaign(avatar: nil, goal: TiltifyAmount(currency: "USD", value: "333333.33"), milestones: [], id: 121745, slug: "relay-st-jude-21", status: "published", team: nil, description: ". . .", totalAmountRaised: TiltifyAmount(currency: "USD", value: "19065.66"), name: "Relay FM for St. Jude 2021", originalGoal: TiltifyAmount(currency: "USD", value: "100")))

let sampleCampaignSingleMilestone = TiltifyWidgetData(from: TiltifyCampaign(avatar: nil,goal: TiltifyAmount(currency: "USD", value: "333333.33"), milestones: [TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "10000"), id: 1, name: "A milestone!")], id: 121745, slug: "relay-st-jude-21", status: "published", team: nil, description: ". . .", totalAmountRaised: TiltifyAmount(currency: "USD", value: "19065.66"), name: "Relay FM for St. Jude 2021", originalGoal: TiltifyAmount(currency: "USD", value: "100")))


let sampleCampaignTwoMilestones = TiltifyWidgetData(from: TiltifyCampaign(avatar: nil,
                                                                          goal: TiltifyAmount(currency: "USD", value: "333333.33"),
                                                                          milestones: [TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "10000"), id: 1, name: "A milestone!"), TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "100000"), id: 1, name: "A future milestone!")],
                                                                          id: 121745,
                                                                          slug: "relay-st-jude-21",
                                                                          status: "published",
                                                                          team: nil,
                                                                          description: ". . .",
                                                                          totalAmountRaised: TiltifyAmount(currency: "USD", value: "19065.66"),
                                                                          name: "Relay FM for St. Jude 2021",
                                                                          originalGoal: TiltifyAmount(currency: "USD", value: "100")))

let sampleCampaignThreeMilestones = TiltifyWidgetData(from: TiltifyCampaign(avatar: nil,
                                                                          goal: TiltifyAmount(currency: "USD", value: "333333.33"),
                                                                          milestones: [TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "10000"), id: 1, name: "A milestone!"), TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "100000"), id: 1, name: "A future milestone!"), TiltifyMilestone(amount: TiltifyAmount(currency: "USD", value: "150000"), id: 1, name: "A future milestone!")],
                                                                          id: 121745,
                                                                          slug: "relay-st-jude-21",
                                                                          status: "published",
                                                                          team: nil,
                                                                          description: ". . .",
                                                                          totalAmountRaised: TiltifyAmount(currency: "USD", value: "19065.66"),
                                                                          name: "Relay FM for St. Jude 2021",
                                                                          originalGoal: TiltifyAmount(currency: "USD", value: "100")))
