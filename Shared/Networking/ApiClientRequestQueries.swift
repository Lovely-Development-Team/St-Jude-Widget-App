//
//  ApiClientRequestQueries.swift
//  St Jude
//
//  Created by Ben Cardy on 03/08/2023.
//

import Foundation

let GET_CAUSE_AND_FE_BY_SLUG_QUERY = """
query get_cause_and_fe_by_slug($feSlug: String!, $causeSlug: String!, $limit: Int!) {
  cause(slug: $causeSlug) {
    id
    causeFactPublicId
    name
    slug
    findOutMoreLink
    trackers
    avatar {
      alt
      height
      width
      src
      __typename
    }
    contact {
      email
      address {
        addressLine1
        addressLine2
        city
        country
        postalCode
        region
        __typename
      }
      __typename
    }
    paymentMethods {
      type
      currency
      sellerId
      minimumAmount {
        currency
        value
        __typename
      }
      __typename
    }
    paymentOptions {
      currency
      additionalDonorDetails
      additionalDonorDetailsType
      monthlyGiving
      monthlyGivingMinimumAmount
      minimumAmount
      __typename
    }
    __typename
  }
  fundraisingEvent(slug: $feSlug, causeSlug: $causeSlug) {
    publicId
    legacyFundraisingEventId
    name
    slug
    description
    status
    supportable
    trackers
    publishedCampaignsCount
    link
    fitnessTotals {
      averagePaceMinutesMile
      averagePaceMinutesKilometer
      totalSteps
      totalDistanceMiles
      totalDurationSeconds
      totalDistanceKilometers
      __typename
    }
    fitnessDailyActivity {
      date
      totalDistanceMiles
      totalDistanceKilometers
      __typename
    }
    fitnessGoals {
      currentValue
      goal
      type
      __typename
    }
    fitnessSettings {
      measurementUnit
      __typename
    }
    amountRaised {
      currency
      value
      __typename
    }
    totalAmountRaised {
      currency
      value
      __typename
    }
    goal {
      currency
      value
      __typename
    }
    avatar {
      alt
      height
      width
      src
      __typename
    }
    image {
      src
      __typename
    }
    banner {
      src
      __typename
    }
    colors {
      highlight
      background
      __typename
    }
    paymentMethods {
      type
      currency
      sellerId
      minimumAmount {
        currency
        value
        __typename
      }
      __typename
    }
    paymentOptions {
      currency
      additionalDonorDetails
      monthlyGiving
      minimumAmount
      __typename
    }
    video
    templateId
    headerIntro
    headerTitle
    headerFontFamily
    impactPointsHeader
    impactPoints {
      name
      description
      amount {
        currency
        value
        __typename
      }
      __typename
    }
    descriptionFontFamily
    contactEmail
    sponsorList {
      id
      name
      alt
      link
      image {
        src
        __typename
      }
      __typename
    }
    fitnessGoals {
      type
      id
      goal
      currentValue
      __typename
    }
    fitnessSettings {
      measurementUnit
      __typename
    }
    publishedCampaigns(limit: $limit) {
      edges {
        node {
          ... on Campaign {
            publicId
            name
            slug
            live
            user {
              id
              username
              slug
              avatar {
                src
                alt
                __typename
              }
              __typename
            }
            avatar {
              src
              alt
              __typename
            }
            totalAmountRaised {
              value
              currency
              __typename
            }
            goal {
              value
              currency
              __typename
            }
            cardImage {
              src
              alt
              __typename
            }
            __typename
          }
          ... on TeamEvent {
            publicId
            name
            slug
            currentSlug
            live
            team {
              id
              name
              slug
              avatar {
                src
                alt
                __typename
              }
              __typename
            }
            avatar {
              src
              alt
              __typename
            }
            totalAmountRaised {
              value
              currency
              __typename
            }
            goal {
              value
              currency
              __typename
            }
            cardImage {
              src
              alt
              __typename
            }
            __typename
          }
          __typename
        }
        __typename
      }
      __typename
    }
    visibility {
      donate
      goal
      raised
      monthlyGivingTotals
      headerTitle
      headerIntro
      fePageCampaigns
      teamLeaderboard {
        visible
        __typename
      }
      userLeaderboard {
        visible
        __typename
      }
      toolkit {
        visible
        url
        description
        __typename
      }
      __typename
    }
    social {
      discord
      facebook
      instagram
      snapchat
      tiktok
      twitter
      website
      youtube
      __typename
    }
    monthlyGiving {
      totalAmountRaised {
        currency
        value
        __typename
      }
      donorCount
      __typename
    }
    incentives {
      id
      title
      description
      label
      promoted
      fairMarketValue {
        value
        currency
        __typename
      }
      amount {
        value
        currency
        __typename
      }
      image {
        src
        alt
        __typename
      }
      __typename
    }
    registrationSetting {
      enabled
      __typename
    }
    __typename
  }
}
"""

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
        __typename
      }
      ...DefaultTemplateFactElements
      __typename
    }
    supportedFacts {
      id
      name
      link
      usageType
      currentSlug
      __typename
    }
    ...DefaultTemplateFactAbout
    ...DefaultTemplateFactAuctionHouses
    ...DefaultTemplateFactBonfire
    ...DefaultTemplateFactCurrentEvents
    ...DefaultTemplateFactFAQ
    ...DefaultTemplateFactFeaturedMedia
    ...DefaultTemplateFactFitnessData
    ...DefaultTemplateFactFundraiserRewards
    ...DefaultTemplateFactFundraisers
    ...DefaultTemplateFactHeader
    ...DefaultTemplateFactImpactPoints
    ...DefaultTemplateFactLeaderboards
    ...DefaultTemplateFactLiveDonations
    ...DefaultTemplateFactMilestones
    ...DefaultTemplateFactPolls
    ...DefaultTemplateFactRewards
    ...DefaultTemplateFactSchedules
    ...DefaultTemplateFactSponsors
    ...DefaultTemplateFactTargets
    ...DefaultTemplateFactTeamStats
    ...DefaultTemplateFactToolkit
    ...DefaultTemplateFactUpdates
    __typename
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
    __typename
  }
  video
  image {
    src
    alt
    height
    width
    __typename
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
      __typename
    }
    usageType
    __typename
  }
  template {
    id
    panels {
      id
      config {
        findOutMore
        findOutMoreLink
        contact
        __typename
      }
      __typename
    }
    __typename
  }
  __typename
}

fragment DefaultTemplateFactAuctionHouses on Fact {
  id
  __typename
}

fragment DefaultTemplateFactBonfire on Fact {
  id
  bonfire {
    id
    description
    featuredItemImage {
      src
      alt
      width
      height
      __typename
    }
    featuredItemName
    featuredItemPrice {
      currency
      value
      __typename
    }
    itemsSold
    products {
      id
      productType
      sellingPrice {
        currency
        value
        __typename
      }
      __typename
    }
    url
    __typename
  }
  __typename
}

fragment DefaultTemplateFactCurrentEvents on Fact {
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
        __typename
      }
      __typename
    }
    __typename
  }
  __typename
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
        __typename
      }
      __typename
    }
    __typename
  }
  __typename
}

fragment DefaultTemplateFactFeaturedMedia on Fact {
  id
  scheduleCount
  useScheduledMedia
  mediaTypes {
    id
    image {
      src
      alt
      height
      width
      __typename
    }
    provider
    value
    default
    position
    __typename
  }
  template {
    id
    panels {
      id
      config {
        fullWidth
        chat
        __typename
      }
      __typename
    }
    __typename
  }
  paginatedSchedules(first: 10, activeAndUpcoming: true) {
    edges {
      cursor
      node {
        id
        description
        endsAt
        name
        startsAt
        scheduledFact {
          id
          name
          avatar {
            src
            alt
            height
            width
            __typename
          }
          link
          mediaTypes {
            id
            image {
              src
              alt
              height
              width
              __typename
            }
            provider
            value
            default
            position
            __typename
          }
          __typename
        }
        ...DefaultTemplateFactFeaturedMediaCurrentScheduleItem
        ...DefaultTemplateFactFeaturedMediaFutureScheduleItem
        __typename
      }
      __typename
    }
    pageInfo {
      endCursor
      startCursor
      hasNextPage
      hasPreviousPage
      __typename
    }
    __typename
  }
  __typename
}

fragment DefaultTemplateFactFeaturedMediaCurrentScheduleItem on NewSchedule {
  id
  description
  endsAt
  name
  startsAt
  scheduledFact {
    id
    name
    avatar {
      src
      alt
      height
      width
      __typename
    }
    link
    __typename
  }
  __typename
}

fragment DefaultTemplateFactFeaturedMediaFutureScheduleItem on NewSchedule {
  id
  description
  name
  startsAt
  scheduledFact {
    id
    avatar {
      src
      alt
      height
      width
      __typename
    }
    __typename
  }
  __typename
}

fragment DefaultTemplateFactFitnessData on Fact {
  id
  template {
    id
    primaryColor
    panels {
      id
      config {
        show
        stats
        individualTime
        individualDistance
        teamDistance
        teamTime
        __typename
      }
      __typename
    }
    __typename
  }
  ...DefaultTemplateFactFitnessDataStats
  ...DefaultTemplateFactFitnessDataRecentActivities
  ...DefaultTemplateFactFitnessDataFitnessChart
  __typename
}

fragment DefaultTemplateFactFitnessDataStats on Fact {
  id
  fitnessMeasurementUnit
  fitnessTotals {
    averagePaceMinutesKilometer
    averagePaceMinutesMile
    totalDistanceKilometers
    totalDistanceMiles
    totalDurationSeconds
    totalSteps
    __typename
  }
  __typename
}

fragment DefaultTemplateFactFitnessDataRecentActivities on Fact {
  id
  fitnessActivities(first: 5) {
    edges {
      node {
        id
        ...DefaultTemplateFactFitnessDataRecentFitnessActivity
        __typename
      }
      __typename
    }
    __typename
  }
  ...DefaultTemplateFactFitnessDataRecentActivity
  __typename
}

fragment DefaultTemplateFactFitnessDataRecentActivity on Fact {
  id
  fitnessMeasurementUnit
  showPolyline
  __typename
}

fragment DefaultTemplateFactFitnessDataRecentFitnessActivity on NewFitnessActivity {
  distanceMiles
  id
  distanceKilometers
  durationSeconds
  steps
  elevationGainFeet
  elevationGainMeters
  paceMinutesMile
  paceMinutesKilometer
  startDate
  obfuscatedPolyline
  fitnessActivityType {
    id
    type
    __typename
  }
  __typename
}

fragment DefaultTemplateFactFitnessDataFitnessChart on Fact {
  id
  fitnessMeasurementUnit
  fitnessDailyActivities {
    date
    totalDistanceKilometers
    totalDistanceMiles
    __typename
  }
  __typename
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
      __typename
    }
    fairMarketValue {
      value
      currency
      __typename
    }
    image {
      src
      alt
      height
      width
      __typename
    }
    __typename
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
        __typename
      }
      __typename
    }
    __typename
  }
  __typename
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
        __typename
      }
      __typename
    }
    __typename
  }
  __typename
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
    __typename
  }
  region {
    id
    name
    __typename
  }
  supportable
  featureSettings {
    monthlyGivingEnabled
    __typename
  }
  totalAmountRaised {
    value
    currency
    __typename
  }
  goal {
    value
    currency
    __typename
  }
  originalGoal {
    value
    currency
    __typename
  }
  donationMatches {
    id
    active
    startedAtAmount {
      value
      currency
      __typename
    }
    matchedAmountTotalAmountRaised {
      value
      currency
      __typename
    }
    __typename
  }
  milestones {
    id
    name
    amount {
      value
      currency
      __typename
    }
    __typename
  }
  monthlyGivingStats {
    donorCount
    totalAmountRaised {
      value
      currency
      __typename
    }
    __typename
  }
  ownership {
    id
    name
    slug
    __typename
  }
  shareLinks {
    supportLink
    __typename
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
    __typename
  }
  supportedFacts {
    id
    name
    usageType
    link
    ownership {
      id
      name
      __typename
    }
    __typename
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
        __typename
      }
      __typename
    }
    __typename
  }
  ...DefaultTemplateFactHeaderDonationMatches
  ...DefaultTemplateFactHeaderFitnessgoals
  __typename
}

fragment DefaultTemplateFactHeaderDonationMatches on Fact {
  id
  donationMatches {
    id
    totalAmountRaised {
      value
      currency
      __typename
    }
    pledgedAmount {
      value
      currency
      __typename
    }
    endsAt
    ...DefaultTemplateFactHeaderDonationMatchesDonationMatch
    ...SharedComponentMatch
    __typename
  }
  __typename
}

fragment DefaultTemplateFactHeaderDonationMatchesDonationMatch on DonationMatch {
  id
  matchedBy
  totalAmountRaised {
    value
    currency
    __typename
  }
  pledgedAmount {
    value
    currency
    __typename
  }
  startsAt
  endsAt
  __typename
}

fragment SharedComponentMatch on DonationMatch {
  id
  matchedBy
  totalAmountRaised {
    value
    currency
    __typename
  }
  pledgedAmount {
    value
    currency
    __typename
  }
  startsAt
  endsAt
  active
  __typename
}

fragment DefaultTemplateFactHeaderFitnessgoals on Fact {
  id
  fitnessMeasurementUnit
  fitnessGoals {
    id
    currentValue {
      unit
      value
      __typename
    }
    goal {
      unit
      value
      __typename
    }
    type
    __typename
  }
  template {
    id
    primaryColor
    panels {
      id
      config {
        distanceProgress
        stepProgress
        timeProgress
        __typename
      }
      __typename
    }
    __typename
  }
  __typename
}

fragment DefaultTemplateFactImpactPoints on Fact {
  id
  impactPoints {
    id
    name
    amount {
      value
      currency
      __typename
    }
    description
    __typename
  }
  template {
    id
    primaryColor
    panels {
      id
      config {
        show
        impactPointsHeader
        __typename
      }
      __typename
    }
    __typename
  }
  __typename
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
        __typename
      }
      __typename
    }
    __typename
  }
  __typename
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
        __typename
      }
      __typename
    }
    __typename
  }
  __typename
}

fragment DefaultTemplateFactMilestones on Fact {
  id
  milestones {
    id
    name
    amount {
      value
      currency
      __typename
    }
    active
    __typename
  }
  __typename
}

fragment DefaultTemplateFactPolls on Fact {
  id
  polls {
    id
    active
    updatedAt
    ...DefaultTemplateFactPollsPoll
    __typename
  }
  __typename
}

fragment DefaultTemplateFactPollsPoll on Poll {
  id
  name
  amountRaised(factId: $id) {
    value
    currency
    __typename
  }
  totalAmountRaised {
    value
    currency
    __typename
  }
  ownerUsageType
  pollOptions {
    id
    name
    amountRaised(factId: $id) {
      value
      currency
      __typename
    }
    totalAmountRaised {
      value
      currency
      __typename
    }
    __typename
  }
  __typename
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
      __typename
    }
    ...DefaultTemplateFactRewardsReward
    __typename
  }
  __typename
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
    __typename
  }
  amount {
    value
    currency
    __typename
  }
  quantity
  remaining
  endsAt
  startsAt
  ownerUsageType
  __typename
}

fragment DefaultTemplateFactSchedules on Fact {
  id
  scheduleCount
  paginatedSchedules(first: 10, activeAndUpcoming: true) {
    edges {
      cursor
      node {
        id
        ...DefaultTemplateFactSchedulesSchedule
        __typename
      }
      __typename
    }
    pageInfo {
      endCursor
      startCursor
      hasNextPage
      hasPreviousPage
      __typename
    }
    __typename
  }
  __typename
}

fragment DefaultTemplateFactSchedulesSchedule on NewSchedule {
  id
  description
  endsAt
  name
  startsAt
  scheduledFact {
    id
    name
    avatar {
      src
      alt
      height
      width
      __typename
    }
    link
    __typename
  }
  __typename
}

fragment DefaultTemplateFactSponsors on Fact {
  id
  sponsors {
    id
    name
    link
    image {
      src
      alt
      height
      width
      __typename
    }
    __typename
  }
  template {
    id
    primaryColor
    panels {
      id
      config {
        show
        sponsorHeading
        sponsorDescription
        __typename
      }
      __typename
    }
    __typename
  }
  __typename
}

fragment DefaultTemplateFactTargets on Fact {
  id
  challenges {
    id
    updatedAt
    active
    ...DefaultTemplateFactTargetsTarget
    __typename
  }
  __typename
}

fragment DefaultTemplateFactTargetsTarget on Challenge {
  id
  name
  amount {
    value
    currency
    __typename
  }
  amountRaised {
    value
    currency
    __typename
  }
  endsAt
  __typename
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
        __typename
      }
      __typename
    }
    __typename
  }
  __typename
}

fragment DefaultTemplateFactToolkit on Fact {
  id
  template {
    id
    primaryColor
    panels {
      id
      config {
        show
        toolkitUrl
        toolkitHeading
        toolkitDescription
        __typename
      }
      __typename
    }
    __typename
  }
  __typename
}

fragment DefaultTemplateFactElements on FactTemplate {
  id
  primaryFont
  secondaryFont
  panels {
    id
    name
    config {
      backgroundColor
      customBackgroundColor
      __typename
    }
    __typename
  }
  __typename
}

fragment DefaultTemplateFactUpdates on Fact {
  id
  factUpdates {
    id
    ...DefaultTemplateFactUpdatesFactUpdate
    __typename
  }
  __typename
}

fragment DefaultTemplateFactUpdatesFactUpdate on FactUpdate {
  id
  description
  insertedAt
  title
  image {
    src
    alt
    height
    width
    __typename
  }
  __typename
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
