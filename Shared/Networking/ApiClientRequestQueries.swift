//
//  ApiClientRequestQueries.swift
//  St Jude
//
//  Created by Ben Cardy on 03/08/2023.
//

import Foundation

let TEAM_EVENT_REQUEST_QUERY = """
query get_team_event_by_vanity_and_slug($vanity: String!, $slug: String!) {
  teamEvent(vanity: $vanity, slug: $slug) {
    publicId
    legacyCampaignId
    name
    slug
    currentSlug
    status
    templateId
    publishedAt
    supportingCampaignCount
    colors {
      background
    }
    visibility {
      donate
      fePageCampaigns
      goal
      raised
      teamEventStats
      toolkit {
        url
        visible
      }
    }
    parentTeamEvent {
      slug
    }
    originalGoal {
      value
      currency
    }
    supportingType
    team {
      id
      publicId
      avatar {
        src
        alt
      }
      name
      slug
      memberCount
    }
    cause {
      id
      publicId
      name
      slug
      description
      avatar {
        alt
        height
        width
        src
      }
      paymentMethods {
        type
        currency
        sellerId
        minimumAmount {
          currency
          value
        }
      }
      paymentOptions {
        currency
        additionalDonorDetails
        additionalDonorDetailsType
        monthlyGiving
        monthlyGivingMinimumAmount
        minimumAmount
      }
    }
    fundraisingEvent {
      publicId
      legacyFundraisingEventId
      name
      slug
      avatar {
        alt
        height
        width
        src
      }
      paymentMethods {
        type
        currency
        sellerId
        minimumAmount {
          currency
          value
        }
      }
      paymentOptions {
        currency
        additionalDonorDetails
        additionalDonorDetailsType
        monthlyGiving
        minimumAmount
      }
    }
    supporting {
      cause {
        id
        publicId
        name
        slug
        description
        avatar {
          alt
          height
          width
          src
        }
        paymentMethods {
          type
          currency
          sellerId
          minimumAmount {
            currency
            value
          }
        }
        paymentOptions {
          currency
          additionalDonorDetails
          additionalDonorDetailsType
          monthlyGiving
          monthlyGivingMinimumAmount
          minimumAmount
        }
      }
      fundraisingEvent {
        publicId
        legacyFundraisingEventId
        name
        slug
        avatar {
          alt
          height
          width
          src
        }
        paymentMethods {
          type
          currency
          sellerId
          minimumAmount {
            currency
            value
          }
        }
        paymentOptions {
          currency
          additionalDonorDetails
          additionalDonorDetailsType
          monthlyGiving
          minimumAmount
        }
      }
    }
    description
    totalAmountRaised {
      currency
      value
    }
    goal {
      currency
      value
    }
    avatar {
      alt
      height
      width
      src
    }
    banner {
      alt
      height
      width
      src
    }
    livestream {
      type
      channel
    }
    milestones {
      publicId
      name
      amount {
        value
        currency
      }
      updatedAt
    }
    schedules {
      publicId
      name
      description
      startsAt
      endsAt
      updatedAt
    }
    rewards {
      active
      promoted
      fulfillment
      amount {
        currency
        value
      }
      name
      image {
        src
      }
      fairMarketValue {
        currency
        value
      }
      legal
      description
      publicId
      startsAt
      endsAt
      quantity
      remaining
      updatedAt
    }
    challenges {
      publicId
      amount {
        currency
        value
      }
      name
      active
      endsAt
      amountRaised {
        currency
        value
      }
      updatedAt
    }
    updatedAt
  }
}
"""

let DONOR_REQUEST_QUERY_2025 = """
query get_fact_donations_by_id_asc($id: ID!, $limit: Int!, $cursor: String) {
  fact(id: $id) {
    id
    donations(first: $limit, after: $cursor) {
      pageInfo {
        startCursor
        endCursor
        hasNextPage
        hasPreviousPage
      }
      edges {
        cursor
        node {
          id
          donorName
          donorComment
          completedAt
          amount {
            value
            currency
          }
          incentives {
            type
          }
        }
      }
    }
  }
}
"""

let DONOR_REQUEST_QUERY = """
query get_previous_donations_by_campaign($publicId: String!, $limit: Int!, $cursor: String) {
  campaign(publicId: $publicId) {
    topDonation {
      id
      amount {
        currency
        value
      }
      donorName
      donorComment
      completedAt
      incentives {
        type
        publicId
        name
      }
    }
    donations(first: $limit, after: $cursor) {
      edges {
        cursor
        node {
          id
          amount {
            value
            currency
          }
          donorName
          donorComment
          completedAt
          matchCount
          incentives {
            type
            publicId
            name
          }
          isMatch
        }
      }
      pageInfo {
        startCursor
        endCursor
        hasNextPage
        hasPreviousPage
      }
    }
  }
}
"""

let CAMPAIGN_REQUEST_QUERY_2025 = """
query get_default_template_fact($id: ID!) {
  fact(id: $id) {
    id
    currentSlug
    updatedAt
    trackers
    template {
      id
      theme
      panels {
        id
        name
      }
    }
    supportedFacts {
      id
      name
      link
      usageType
      currentSlug
    }
    ...DefaultTemplateFactAbout
    ...DefaultTemplateFactFAQ
    ...DefaultTemplateFactFundraiserRewards
    ...DefaultTemplateFactFundraisers
    ...DefaultTemplateFactHeader
    ...DefaultTemplateFactLeaderboards
    ...DefaultTemplateFactLiveDonations
    ...DefaultTemplateFactMilestones
    ...DefaultTemplateFactPolls
    ...DefaultTemplateFactRewards
    ...DefaultTemplateFactTargets
    ...DefaultTemplateFactTeamStats
    topDonation {
      id
      amount {
        currency
        value
      }
      donorComment
      donorName
      incentives {
        type
      }
    }
  }
}

fragment DefaultTemplateFactAbout on Fact {
  id
  name
  description
  contactEmail
  avatar {
    src
    alt
    height
    width
  }
  video
  image {
    src
    alt
    height
    width
  }
  usageType
  supportedFacts {
    id
    name
    description
    link
    avatar {
      src
      alt
      height
      width
    }
    usageType
  }
  template {
    id
    panels {
      id
      config {
        findOutMore
        findOutMoreLink
        contact
      }
    }
  }
}

fragment DefaultTemplateFactFAQ on Fact {
  id
  template {
    id
    primaryColor
    panels {
      id
      config {
        show
        faqUrl
        faqHeading
        faqDescription
      }
    }
  }
}

fragment DefaultTemplateFactFundraiserRewards on Fact {
  id
  fundraiserRewards {
    id
    title
    description
    label
    promoted
    amount {
      value
      currency
    }
    fairMarketValue {
      value
      currency
    }
    image {
      src
      alt
      height
      width
    }
  }
  template {
    id
    primaryColor
    panels {
      id
      config {
        show
        fundraiserRewardsHeading
        fundraiserRewardsDescription
      }
    }
  }
}

fragment DefaultTemplateFactFundraisers on Fact {
  id
  link
  template {
    id
    primaryColor
    panels {
      id
      config {
        show
      }
    }
  }
}

fragment DefaultTemplateFactHeader on Fact {
  id
  name
  fundraisingForName
  status
  usageType
  restricted
  avatar {
    src
    alt
    height
    width
  }
  region {
    id
    name
  }
  supportable
  featureSettings {
    monthlyGivingEnabled
  }
  totalAmountRaised {
    value
    currency
  }
  goal {
    value
    currency
  }
  originalGoal {
    value
    currency
  }
  donationMatches {
    id
    active
    startedAtAmount {
      value
      currency
    }
    matchedAmountTotalAmountRaised {
      value
      currency
    }
  }
  milestones {
    id
    name
    amount {
      value
      currency
    }
  }
  monthlyGivingStats {
    donorCount
    totalAmountRaised {
      value
      currency
    }
  }
  ownership {
    id
    name
    slug
  }
  shareLinks {
    supportLink
  }
  social {
    discord
    facebook
    instagram
    snapchat
    tiktok
    twitch
    twitter
    website
    youtube
  }
  supportedFacts {
    id
    name
    usageType
    link
    ownership {
      id
      name
    }
  }
  template {
    id
    primaryColor
    secondaryFont
    panels {
      id
      config {
        alignment
        heading
        subHeading
        donateButton
        donateMonthlyButton
        startFundraisingButton
        amountRaised
        fundraisingGoal
      }
    }
  }
}

fragment DefaultTemplateFactLeaderboards on Fact {
  id
  currency
  link
  template {
    id
    primaryColor
    panels {
      id
      config {
        show
        individual
        team
        donor
      }
    }
  }
}

fragment DefaultTemplateFactLiveDonations on Fact {
  id
  template {
    id
    secondaryFont
    panels {
      id
      config {
        show
        backgroundColor
      }
    }
  }
}

fragment DefaultTemplateFactMilestones on Fact {
  id
  milestones {
    id
    name
    amount {
      value
      currency
    }
    active
  }
}

fragment DefaultTemplateFactPolls on Fact {
  id
  polls {
    id
    active
    updatedAt
    ...DefaultTemplateFactPollsPoll
  }
}

fragment DefaultTemplateFactPollsPoll on Poll {
  id
  name
  amountRaised(factId: $id) {
    value
    currency
  }
  totalAmountRaised {
    value
    currency
  }
  ownerUsageType
  pollOptions {
    id
    name
    amountRaised(factId: $id) {
      value
      currency
    }
    totalAmountRaised {
      value
      currency
    }
  }
}

fragment DefaultTemplateFactRewards on Fact {
  id
  rewards {
    id
    updatedAt
    active
    promoted
    amount {
      value
      currency
    }
    ...DefaultTemplateFactRewardsReward
  }
}

fragment DefaultTemplateFactRewardsReward on Reward {
  id
  name
  description
  image {
    src
    alt
    height
    width
  }
  amount {
    value
    currency
  }
  quantity
  remaining
  endsAt
  startsAt
  ownerUsageType
}

fragment DefaultTemplateFactTargets on Fact {
  id
  challenges {
    id
    updatedAt
    active
    ...DefaultTemplateFactTargetsTarget
  }
}

fragment DefaultTemplateFactTargetsTarget on Challenge {
  id
  name
  amount {
    value
    currency
  }
  amountRaised {
    value
    currency
  }
  endsAt
}

fragment DefaultTemplateFactTeamStats on Fact {
  id
  publishedAt
  teamMemberCount
  supportingFactsCount(usageTypes: [CAMPAIGN])
  template {
    id
    primaryColor
    panels {
      id
      config {
        show
      }
    }
  }
}
"""

let CAMPAIGN_REQUEST_QUERY = """
query get_campaign_by_vanity_and_slug($vanity: String!, $slug: String!) {
  campaign(vanity: $vanity, slug: $slug) {
    publicId
    legacyCampaignId
    name
    slug
    status
    showPolyline
    membership {
      id
      status
    }
    originalGoal {
      value
      currency
    }
    region {
      name
    }
    team {
      id
      avatar {
        src
        alt
      }
      name
      slug
    }
    bonfireCampaign {
      id
      description
      featuredItemImage {
        src
      }
      featuredItemName
      featuredItemPrice {
        currency
        value
      }
      url
      products {
        id
        productType
        sellingPrice {
          value
          currency
        }
      }
    }
    supportedTeamEvent {
      publicId
      team {
        id
        avatar {
          src
          alt
        }
        name
        slug
      }
      avatar {
        alt
        height
        width
        src
      }
      name
      slug
      currentSlug
    }
    description
    totalAmountRaised {
      currency
      value
    }
    goal {
      currency
      value
    }
    avatar {
      alt
      height
      width
      src
    }
    user {
      id
      username
      slug
      avatar {
        src
        alt
      }
    }
    livestream {
      type
      channel
    }
    milestones {
      publicId
      name
      amount {
        value
        currency
      }
    }
    schedules {
      publicId
      name
      description
      startsAt
      endsAt
    }
    rewards {
      active
      promoted
      fulfillment
      amount {
        currency
        value
      }
      name
      image {
        src
      }
      fairMarketValue {
        currency
        value
      }
      legal
      description
      publicId
      startsAt
      endsAt
      quantity
      remaining
    }
    challenges {
      publicId
      amount {
        currency
        value
      }
      name
      active
      endsAt
      amountRaised {
        currency
        value
      }
    }
  }
}
"""

let CAMPAIGNS_FOR_TEAM_EVENT_QUERY = """
query get_supporting_campaigns_by_team_event_asc($vanity: String!, $slug: String!, $limit: Int!, $cursor: String) {
  teamEvent(vanity: $vanity, slug: $slug) {
    publicId
    supportingCampaigns(first: $limit, after: $cursor) {
      edges {
        cursor
        node {
          publicId
          name
          description
          user {
            id
            username
            slug
          }
          slug
          avatar {
            alt
            src
          }
          goal {
            value
            currency
          }
          amountRaised {
            value
            currency
          }
          totalAmountRaised {
            value
            currency
          }
        }
      }
      pageInfo {
        startCursor
        endCursor
        hasNextPage
        hasPreviousPage
      }
    }
  }
}
"""
