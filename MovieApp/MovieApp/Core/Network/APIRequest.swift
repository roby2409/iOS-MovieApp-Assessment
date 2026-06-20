//
//  APIRequest.swift
//  MovieApp
//
//  Created by Roby Setiawan on 19/06/26.
//

import Foundation


public struct APIRequest {
    public let endpoint: Endpoint
    public let path: String              
    public let query: String?            
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem] 
    public let body: Encodable?
    public let headers: [String: String]
    public let timeoutInterval: TimeInterval

    public init(
        endpoint: Endpoint,
        path: String = "",
        query: String? = nil,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        body: Encodable? = nil,
        headers: [String: String] = [:],
        timeoutInterval: TimeInterval = 30
    ) {
        self.endpoint = endpoint
        self.path = path
        self.query = query
        self.method = method
        self.queryItems = queryItems
        self.body = body
        self.headers = headers
        self.timeoutInterval = timeoutInterval
    }

    
    var fullPath: String {
        return path.isEmpty ? endpoint.rawValue : "\(endpoint.rawValue)/\(path)"
    }

    
    var parsedQueryItems: [URLQueryItem] {
        guard let query = query, !query.isEmpty else { return queryItems }
        let fromRawString: [URLQueryItem] = query
            .split(separator: "&")
            .compactMap { pair in
                let parts = pair.split(separator: "=", maxSplits: 1)
                guard parts.count == 2 else { return nil }
                return URLQueryItem(name: String(parts[0]), value: String(parts[1]))
            }
        return queryItems + fromRawString
    }
}
