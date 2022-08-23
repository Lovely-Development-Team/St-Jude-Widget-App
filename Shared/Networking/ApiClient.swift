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
  }
}
"""
        let body = TiltifyRequest(operationName: "get_campaign_by_vanity_and_slug",
                                  variables: ["vanity": "@\(vanity)", "slug": slug],
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
          slug
          live
          user {
            username
            slug
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
