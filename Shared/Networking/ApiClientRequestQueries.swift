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

let CAMPAIGNS_FOR_CAUSE_QUERY = """
query get_campaigns_by_fundraising_event_id($publicId: String!, $offset: Int) {
  fundraisingEvent(publicId: $publicId) {
    publishedCampaigns(limit: 20, offset: $offset) {
      pagination {
        hasNextPage
        limit
        offset
        total
      }
      edges {
        node {
          publicId
          name
          description
          slug
          live
          user {
            username
            slug
            avatar {
              alt
              src
            }
          }
          totalAmountRaised {
            value
            currency
          }
          goal {
            value
            currency
          }
        }
      }
    }
  }
}
"""

let CAUSE_QUERY = """
query get_cause_and_fe_by_slug($feSlug: String!, $causeSlug: String!) {
  cause(slug: $causeSlug) {
    publicId
    name
    slug
  }
  fundraisingEvent(slug: $feSlug, causeSlug: $causeSlug) {
    publicId
    name
    slug
    description
    status
    publishedCampaignsCount
    amountRaised {
      currency
      value
    }
    goal {
      currency
      value
    }
    colors {
      highlight
      background
    }
    publishedCampaigns {
      edges {
        node {
          publicId
          name
          description
          slug
          live
          user {
            username
            slug
            avatar {
              alt
              src
            }
          }
          totalAmountRaised {
            value
            currency
          }
          goal {
            value
            currency
          }
        }
      }
    }
  }
}
"""
