//
//  ApiClient.swift
//  ApiClient
//
//  Created by David on 22/08/2021.
//

import Foundation
import Combine
import WidgetKit

struct TiltifyRequest: Codable {
    let operationName: String
    let variables: Dictionary<String, String>
    let query: String
}


struct TiltifyGetCampaignsRequestVariables: Codable {
    let publicId: String
    let offset: Int
}

struct TiltifyGetCampaignsRequest: Codable {
    let operationName: String
    let variables: TiltifyGetCampaignsRequestVariables
    let query: String
}


class ApiClient: NSObject, ObservableObject, URLSessionDelegate, URLSessionDataDelegate {
    static let shared = ApiClient()
    static let backgroundSessionIdentifier = "FetchCampaignBackgroundSession"
    
    private override init() {
        super.init()
    }
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    var backgroundCompletionHandler: (() -> Void)?
    
    func backgroundPost() {
        
    }
    
    func buildDonorRequest(publicId: String) throws -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.tiltify.com")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let queryString = """
query get_previous_donations_by_campaign($publicId: String!, $cursor: String) {
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
        id
      }
    }
    donations(first: 50, after: $cursor) {
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
          incentives {
            type
            id
            name
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
        let body = TiltifyRequest(operationName: "get_previous_donations_by_campaign",
                                  variables: ["publicId": publicId],
                                  query: queryString)
        request.httpBody = try jsonEncoder.encode(body)
        return request
    }
    
    func buildCampaignRequest(vanity: String, slug: String) throws -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.tiltify.com")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let queryString = """
query get_campaign_by_vanity_and_slug($vanity: String, $slug: String) {
  campaign(vanity: $vanity, slug: $slug) {
    publicId
    name
    slug
    status
    originalGoal {
      value
      currency
    }
    user {
      username
      slug
      avatar {
        alt
        src
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
    milestones {
      id
      name
      amount {
        value
        currency
      }
    }
    rewards {
      active
      publicId
      id
      amount {
        value
        currency
      }
      description
      name
      quantity
      remaining
      image {
        src
      }
    }
  }
}
"""
        let body = TiltifyRequest(operationName: "get_campaign_by_vanity_and_slug",
                                  variables: ["vanity": "@\(vanity)", "slug": slug],
                                  query: queryString)
        request.httpBody = try jsonEncoder.encode(body)
        return request
    }
    
    func buildCampaignsForCauseRequest(offsetBy offset: Int) throws -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.tiltify.com")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let queryString = """
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
        let body = TiltifyGetCampaignsRequest(operationName: "get_campaigns_by_fundraising_event_id",
                                              variables: TiltifyGetCampaignsRequestVariables(publicId: "8f4e607c-a117-4c11-9172-23d19c1be96c", offset: offset),
                                              query: queryString)
        request.httpBody = try jsonEncoder.encode(body)
        return request
    }
    
    func buildCauseRequest() throws -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.tiltify.com")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let queryString = """
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
        let body = TiltifyRequest(operationName: "get_cause_and_fe_by_slug",
                                  variables: ["causeSlug": "st-jude-children-s-research-hospital", "feSlug": "relay-fm-for-st-jude-2022"],
                                  query: queryString)
        request.httpBody = try jsonEncoder.encode(body)
        return request
    }
    
    @available(*, renamed: "fetchCampaign()")
    func fetchCampaign(vanity: String = "relay-fm", slug: String = "relay-fm-for-st-jude-2022", completion: @escaping (Result<TiltifyResponse, Error>) -> ()) -> URLSessionDataTask? {
        do {
            let request = try buildCampaignRequest(vanity: vanity, slug: slug)
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(TiltifyError.noData))
                    return
                }
                completion(Result {
                    let payload = try JSONDecoder().decode(TiltifyResponse.self, from: data)
                    return payload
                })
            }
            dataTask.resume()
            return dataTask
        } catch {
            completion(.failure(error))
            return nil
        }
    }
    
    func fetchCampaign(vanity: String = "relay-fm", slug: String = "relay-fm-for-st-jude-2022") async throws -> TiltifyResponse {
        return try await withCheckedThrowingContinuation { continuation in
            _ = fetchCampaign(vanity: vanity, slug: slug) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    @available(*, renamed: "fetchCause()")
    func fetchCause(completion: @escaping (Result<TiltifyCauseResponse, Error>) -> ()) -> URLSessionDataTask? {
        do {
            let request = try buildCauseRequest()
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(TiltifyError.noData))
                    return
                }
                completion(Result {
                    let payload = try JSONDecoder().decode(TiltifyCauseResponse.self, from: data)
                    return payload
                })
            }
            dataTask.resume()
            return dataTask
        } catch {
            completion(.failure(error))
            return nil
        }
    }
    
    func fetchCause() async throws -> TiltifyCauseResponse {
        return try await withCheckedThrowingContinuation { continuation in
            _ = fetchCause { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func fetchCampaignsForCause(offsetBy offset: Int, completion: @escaping (Result<TiltifyCampaignsForCauseResponse, Error>) -> ()) -> URLSessionDataTask? {
        do {
            let request = try buildCampaignsForCauseRequest(offsetBy: offset)
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(TiltifyError.noData))
                    return
                }
                completion(Result {
                    let payload = try JSONDecoder().decode(TiltifyCampaignsForCauseResponse.self, from: data)
                    return payload
                })
                return
            }
            dataTask.resume()
            return dataTask
        } catch {
            completion(.failure(error))
            return nil
        }
    }
    
    func fetchCampaignsForCause(offsetBy offset: Int) async throws -> TiltifyCampaignsForCauseResponse {
        return try await withCheckedThrowingContinuation { continuation in
            _ = fetchCampaignsForCause(offsetBy: offset) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func fetchDonorsForCampaign(publicId: String, completion: @escaping (Result<TiltifyDonorsForCampaignResponse, Error>) -> ()) -> URLSessionDataTask? {
        do {
            let request = try buildDonorRequest(publicId: publicId)
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(TiltifyError.noData))
                    return
                }
                completion(Result {
                    let payload = try JSONDecoder().decode(TiltifyDonorsForCampaignResponse.self, from: data)
                    return payload
                })
                return
            }
            dataTask.resume()
            return dataTask
        } catch {
            completion(.failure(error))
            return nil
        }
    }
    
    func fetchDonorsForCampaign(publicId: String) async throws -> TiltifyDonorsForCampaignResponse {
        return try await withCheckedThrowingContinuation { continuation in
            _ = fetchDonorsForCampaign(publicId: publicId) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    lazy var backgroundURLSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: Self.backgroundSessionIdentifier)
        config.sessionSendsLaunchEvents = true
        config.waitsForConnectivity = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
//    urls
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            WidgetCenter.shared.reloadAllTimelines()
            guard let backgroundCompletionHandler = self.backgroundCompletionHandler else {
                return
            }
            backgroundCompletionHandler()
        }
    }
}

enum TiltifyError: Error {
    case noData
}
