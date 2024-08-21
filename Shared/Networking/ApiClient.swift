//
//  ApiClient.swift
//  ApiClient
//
//  Created by David on 22/08/2021.
//

import Foundation
import Combine
import WidgetKit

let TEAM_EVENT_VANITY = "+relay-for-st-jude"
//let TEAM_EVENT_SLUG = "relay-for-st-jude-2024"
let TEAM_EVENT_SLUG = "relay-fm-for-st-jude-2023"

struct TiltifyRequest: Codable {
    let operationName: String
    let variables: Dictionary<String, String>
    let query: String
}

struct TiltifyCampaignsForTeamEventRequestVariables: Codable {
    let vanity: String
    let slug: String
    let limit: Int
    var cursor: String? = nil
}

struct TiltifyCampaignsForTeamEventRequest: Codable {
    let operationName: String
    let variables: TiltifyCampaignsForTeamEventRequestVariables
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

struct TiltifyDonorsRequestVariables: Codable {
    let publicId: String
    let limit: Int
}

struct TiltifyDonorsRequest: Codable {
    let operationName: String
    let variables: TiltifyDonorsRequestVariables
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
    
    // MARK: 2023 Methods
    
    func buildScoreRequest() -> URLRequest {
        var request = URLRequest(url: URL(string: "https://stjude-scoreboard.snailedit.online/api/co-founders")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchScore() async -> Score? {
        do {
            let request = buildScoreRequest()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let decoded = String(data: data, encoding: .utf8) {
                dataLogger.debug("Score: \(decoded)")
            } else {
                dataLogger.debug("Score: not decodable")
            }
            return try JSONDecoder().decode(Score.self, from: data)
        } catch {
            dataLogger.error("Fetching score failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    func buildTeamEventRequest() throws -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.tiltify.com")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let body = TiltifyRequest(operationName: "get_team_event_by_vanity_and_slug",
                                  variables: ["vanity": TEAM_EVENT_VANITY, "slug": TEAM_EVENT_SLUG],
                                  query: TEAM_EVENT_REQUEST_QUERY)
        request.httpBody = try jsonEncoder.encode(body)
        return request
    }
    
    func fetchTeamEvent() async -> TiltifyTeamEvent? {
        do {
            let request = try buildTeamEventRequest()
            let (data, _) = try await URLSession.shared.data(for: request)
            let payload = try JSONDecoder().decode(TiltifyTeamEventResponse.self, from: data)
            return payload.data.teamEvent
        } catch {
            dataLogger.debug("Fetching Team Event failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    func buildCampaignsForTeamEventRequest(limit: Int, cursor: String? = nil) throws -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.tiltify.com")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let body = TiltifyCampaignsForTeamEventRequest(operationName: "get_supporting_campaigns_by_team_event_asc",
                                                       variables: TiltifyCampaignsForTeamEventRequestVariables(vanity: TEAM_EVENT_VANITY, slug: TEAM_EVENT_SLUG, limit: limit, cursor: cursor),
                                  query: CAMPAIGNS_FOR_TEAM_EVENT_QUERY)
        request.httpBody = try jsonEncoder.encode(body)
        return request
    }
    
    func fetchCampaignsForTeamEvent(limit: Int = 50, cursor: String? = nil) async -> TiltifySupportingCampaignsResponse? {
        do {
            let request = try buildCampaignsForTeamEventRequest(limit: limit, cursor: cursor)
            let (data, _) = try await URLSession.shared.data(for: request)
            let payload = try JSONDecoder().decode(TiltifySupportingCampaignsResponse.self, from: data)
            dataLogger.debug("Fetched: \(payload.data.teamEvent.supportingCampaigns.edges.count)")
            return payload
        } catch {
            dataLogger.debug("Fetching campaigns for team event failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    func fetchCampaignsForTeamEvent() async -> [TiltifyCauseCampaign] {
        var cursor: String? = nil
        var campaigns: [TiltifyCauseCampaign] = []
        while true {
            if let result = await fetchCampaignsForTeamEvent(cursor: cursor) {
                campaigns += result.data.teamEvent.supportingCampaigns.edges.map { $0.node }
                if result.data.teamEvent.supportingCampaigns.pageInfo.hasNextPage {
                    cursor = result.data.teamEvent.supportingCampaigns.pageInfo.endCursor
                } else {
                    break
                }
            } else {
                break
            }
        }
        dataLogger.debug("Found \(campaigns.count) campaigns")
        return campaigns
    }
    
    func buildDonorRequest(publicId: String) throws -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.tiltify.com")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let body = TiltifyDonorsRequest(operationName: "get_previous_donations_by_campaign",
                                  variables: TiltifyDonorsRequestVariables(publicId: publicId, limit: 25),
                                  query: DONOR_REQUEST_QUERY)
        request.httpBody = try jsonEncoder.encode(body)
        return request
    }
    
    func buildCampaignRequest(vanity: String, slug: String) throws -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.tiltify.com")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let body = TiltifyRequest(operationName: "get_campaign_by_vanity_and_slug",
                                  variables: ["vanity": "@\(vanity)", "slug": slug],
                                  query: CAMPAIGN_REQUEST_QUERY)
        request.httpBody = try jsonEncoder.encode(body)
        return request
    }
    
    @available(*, renamed: "fetchCampaign()")
    func fetchCampaign(vanity: String = "relay-for-st-jude", slug: String = "relay-for-st-jude", completion: @escaping (Result<TiltifyResponse, Error>) -> ()) -> URLSessionDataTask? {
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
    
    func fetchCampaign(vanity: String = "relay-for-st-jude", slug: String = "relay-for-st-jude") async throws -> TiltifyResponse {
        return try await withCheckedThrowingContinuation { continuation in
            _ = fetchCampaign(vanity: vanity, slug: slug) { result in
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
