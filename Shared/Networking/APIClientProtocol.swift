//
//  APIClientProtocol.swift
//  St Jude
//
//  Created by Ben Cardy on 21/08/2025.
//

import Foundation

protocol APIClient {
    var baseUrl: URL { get }
    func send<T: APIRequest>(_ request: T) async throws -> T.Response
    var commonParameters: [URLQueryItem] { get }
    func commonHeaders<T: APIRequest>(for request: T) async -> [String: String]
}

extension APIClient {
    var commonParameters: [URLQueryItem] { [] }
    func commonHeaders<T: APIRequest>(for request: T) async -> [String: String] {
        [:]
    }
    
    func endpointRequest<T: APIRequest>(for request: T) async throws -> URLRequest {
        apiLogger.debug("Composing request for \(request.resourceName) with method \(request.method) and parameters \(request.parameters)")
        guard let baseUrl = URL(string: request.resourceName, relativeTo: self.baseUrl) else {
            fatalError("Invalid URL for resource \(request.resourceName)")
        }
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!
        components.queryItems = self.commonParameters + request.parameters
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = request.method
        apiLogger.debug("Composing request body: \(request.body.debugDescription)")
        if let body = request.body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            urlRequest.httpBody = try encoder.encode(body)
        }
        for (header, value) in request.headers.merging(await self.commonHeaders(for: request), uniquingKeysWith: { $1 }) {
            urlRequest.setValue(value, forHTTPHeaderField: header)
        }
        return urlRequest
    }
    
    func send<T: APIRequest>(_ request: T) async throws -> T.Response {
        let endpointRequest = try await self.endpointRequest(for: request)
        apiLogger.debug("Sending API request: \(endpointRequest) with body: \(endpointRequest.httpBody ?? Data()) and headers: \(endpointRequest.allHTTPHeaderFields ?? [:])")
        let (data, _) = try await URLSession.shared.data(for: endpointRequest)
        apiLogger.debug("Decoding response to \(T.Response.self): \(String(data: data, encoding: .utf8) ?? "no data")")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.Response.self, from: data)
    }
}

protocol APIRequest: Encodable {
    associatedtype Response: Decodable
    associatedtype Request: Encodable
    var resourceName: String { get }
    var method: String { get }
    var parameters: [URLQueryItem] { get }
    var body: Request? { get }
    var headers: [String: String] { get }
}

extension APIRequest {
    var parameters: [URLQueryItem] { [] }
    var method: String { "GET" }
    var headers: [String: String] { [:] }
}

protocol JSONAPIRequest: APIRequest {}
extension JSONAPIRequest {
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
    var method: String { "POST" }
}

struct EmptyBody: Encodable { }

protocol EmptyAPIRequest: APIRequest where Request == EmptyBody { }
extension EmptyAPIRequest {
    var body: EmptyBody? { nil }
}
